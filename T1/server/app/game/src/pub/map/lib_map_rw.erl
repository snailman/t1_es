%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. 五月 2018 17:09
%%%-------------------------------------------------------------------
-module(lib_map_rw).
-author("mawenhong").
-include("gs_map_inc.hrl").
-include("gs_cache_inc.hrl").
-include("gs_map_unit_inc.hrl").
-include("gs_move_inc.hrl").

%%
-export([init/1]).
-export([add_obj_to_ets/1, del_obj_to_ets/1]).
-export([
    get_obj/1,
    get_player/1, get_player_size/0,
    get_monster/1,  get_monster_size/0,
    get_npc/1, get_pet/1
]).

-export([
    get_obj_maps/1,
    get_player_map/0, get_monster_map/0, get_npc_map/0, get_pet_map/0,
    set_player_map/1, set_monster_map/1, set_npc_map/1, set_pet_map/1
]).
-export([
    get_map_id/0, get_line_id/0,get_map_hook/0,
    update_move_timer/0,
    get_move_timer_delta/0,
    get_move_timer_now/0,
    get_move_timer_pass_time/1
]).


%% define
-define(MAP_MON_MAPS,       monster_maps).
-define(MAP_PLAYER_MAPS,    player_maps).
-define(MAP_NPC_MAPS,      pet_maps).
-define(MAP_PET_MAPS,      pet_maps).
-define(MAP_ID, map_id__).
-define(LINE_ID, line_id__).
-define(MAP_HOOK, map_hook__).
-define(MOVE_TIMER, map_move_timer__).

%%%-------------------------------------------------------------------
init(State) ->
    Now = misc_time:milli_seconds(),
    put(?MAP_ID,        State#m_map_state.map_id),
    put(?LINE_ID,       State#m_map_state.line_id),
    put(?MAP_HOOK,      State#m_map_state.hook_mod),
    put(?MOVE_TIMER,    #m_move_timer{now = Now, latest_up = Now, delta = 0}),
    set_player_map(#{}),
    set_monster_map(#{}),
    set_pet_map(#{}),
    set_npc_map(#{}),
    ok.

get_obj_maps(Uid) ->
    Type = lib_unit_rw:get_type(Uid),
    case Type of
        ?OBJ_USR -> get_player_map();
        ?OBJ_MON -> get_monster_map();
        ?OBJ_PET -> get_pet_map();
        ?OBJ_NPC -> get_npc_map();
        _ -> undefined
    end.

get_player_map() -> get(?MAP_PLAYER_MAPS).
set_player_map(Maps) -> erlang:put(?MAP_PLAYER_MAPS,   Maps).

get_monster_map() -> get(?MAP_MON_MAPS).
set_monster_map(Maps) -> erlang:put(?MAP_MON_MAPS,   Maps).

get_pet_map() -> get(?MAP_PET_MAPS).
set_pet_map(Maps) -> erlang:put(?MAP_PET_MAPS,   Maps).

get_npc_map() -> get(?MAP_NPC_MAPS).
set_npc_map(Maps) -> erlang:put(?MAP_NPC_MAPS,   Maps).



%%-------------------------------------------------------------------
get_map_id()        -> get(?MAP_ID).
get_line_id()       -> get(?LINE_ID).
get_map_hook()      -> get(?MAP_HOOK).

%%-------------------------------------------------------------------
get_obj(Uid) ->
    Type = lib_unit_rw:get_type(Uid),
    case Type of
        ?OBJ_USR -> get_player(Uid);
        ?OBJ_MON -> get_monster(Uid);
        ?OBJ_PET -> get_pet(Uid);
        ?OBJ_NPC -> get_npc(Uid);
        _ -> undefined
    end.
%%-------------------------------------------------------------------
get_player(Uid) ->
    case ets:lookup(?ETS_CACHE_MAP_PLAYER, Uid) of
        [#m_cache_map_unit{} = Unit | _] -> Unit;
        _ -> undefined
    end.

get_player_size() ->
    maps:size(lib_map_rw:get_player_map()).

%%-------------------------------------------------------------------
get_monster(Uid) ->
    case ets:lookup(?ETS_CACHE_MAP_MONSTER, Uid) of
        [#m_cache_map_unit{} = Unit | _] -> Unit;
        _ -> undefined
    end.

get_monster_size() ->
    maps:size( lib_map_rw:get_monster_map() ).

%%-------------------------------------------------------------------
get_npc(Uid) ->
    case ets:lookup(?ETS_CACHE_MAP_NPC, Uid) of
        [#m_cache_map_unit{} = Unit | _] -> Unit;
        _ -> undefined
    end.

%%-------------------------------------------------------------------
get_pet(Uid) ->
    case ets:lookup(?ETS_CACHE_MAP_PET, Uid) of
        [#m_cache_map_unit{} = Unit | _] -> Unit;
        _ -> undefined
    end.

%%-------------------------------------------------------------------
add_obj_to_ets(#m_cache_map_unit{type = ?OBJ_MON, uid = Uid} = Unit) ->
    ets:insert(?ETS_CACHE_MAP_MONSTER, Unit),
    lib_map_rw:set_monster_map( maps:put(Uid, Uid, lib_map_rw:get_monster_map()) ),
    ok;
add_obj_to_ets(#m_cache_map_unit{type = ?OBJ_USR, uid = Uid} = Unit) ->
    ets:insert(?ETS_CACHE_MAP_PLAYER, Unit),
    lib_map_rw:set_player_map( maps:put(Uid, Uid, lib_map_rw:get_player_map()) ),
    ok;
add_obj_to_ets(_) ->
    ok.

del_obj_to_ets(#m_cache_map_unit{uid = Uid, type = ?OBJ_MON}) ->
    ets:delete(?ETS_CACHE_MAP_MONSTER, Uid),
    lib_map_rw:set_monster_map( maps:remove(Uid, lib_map_rw:get_monster_map()) ),
    ok;
del_obj_to_ets(#m_cache_map_unit{uid = Uid, type = ?OBJ_USR}) ->
    ets:update_element(?ETS_CACHE_MAP_PLAYER, Uid, [{#m_cache_map_unit.map_id, 0}, {#m_cache_map_unit.line_id, 0}]),
    lib_map_rw:set_player_map( maps:remove(Uid, lib_map_rw:get_player_map()) ),
    ok;
del_obj_to_ets(_) ->
    ok.
%%-------------------------------------------------------------------
update_move_timer() ->
    Now = misc_time:milli_seconds(),
    #m_move_timer{latest_up = Latest} = get(?MOVE_TIMER),
    put(?MOVE_TIMER, #m_move_timer{now = Now, latest_up = Now, delta = Now - Latest}),
    ok.

%%-------------------------------------------------------------------
get_move_timer_now() ->
    #m_move_timer{now = Now} = get(?MOVE_TIMER),
    Now.

get_move_timer_pass_time(StartTime) ->
    #m_move_timer{now = Now} = get(?MOVE_TIMER),
    Now - StartTime.

get_move_timer_delta() ->
    #m_move_timer{delta = Delta} = get(?MOVE_TIMER),
    Delta.

%%-------------------------------------------------------------------







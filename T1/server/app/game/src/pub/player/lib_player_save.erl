%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. 五月 2018 9:51
%%%-------------------------------------------------------------------
-module(lib_player_save).
-author("mawenhong").
-include("logger.hrl").
-include("gs_cache_inc.hrl").

%% API
-export([save/1]).

%%-------------------------------------------------------------------
save(Uid) ->
    #m_cache_player_pub{
        aid = Aid, pos = Pos, mid = Mid, mpid = MPid
    } = Player = gs_cache:get_player_pub(Uid),
    ?DEBUG("save player aid ~w uid ~w in map ~w|~w",[Aid, Uid, Mid, MPid]),
    NewPlayer = case vector3:valid(Pos) of
                    true -> Player;
                    _ ->
                        NewPos = gs_map_creator_interface:map_init_pos(Mid),
                        Player#m_cache_player_pub{pos = NewPos}
                end,
    gs_db_interface:action_data_(Aid, save_player, NewPlayer),
    ok.

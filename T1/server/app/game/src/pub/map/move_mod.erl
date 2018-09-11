%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. 五月 2018 8:54
%%%-------------------------------------------------------------------
-module(move_mod).
-author("mawenhong").
-include("logger.hrl").
-include("netmsg.hrl").
-include("gs_cache.hrl").
-include("map_core.hrl").
-include("map_unit_cache.hrl").
-include("movement.hrl").
-include_lib("stdlib/include/assert.hrl").

%% API
-export([init/3, update/1]).
-export([
    stop_move/2, stop_move_force/2,
    start_player_walk/3, on_obj_pos_change/2, stop_player_move/2,
    start_monster_walk/4, is_can_monster_walk/4
]).
-export([cal_move_msg/1]).
%%-export([cal_move_msg_info/2]).

%%-------------------------------------------------------------------
init(Uid, Pos, Face) ->
    move_rw:set_cur_move(Uid, ?EMS_STAND),
    move_rw:set_next_move(Uid, ?EMS_STAND),
    move_rw:set_cur_pos(Uid, Pos),
    move_rw:set_face(Uid, Face),
    move_rw:set_dir(Uid, Face),
    move_rw:set_start_pos(Uid, Pos),
    move_rw:set_dest_pos(Uid, Pos),
    move_rw:set_vis_tile_idx(Uid, 0),
    move_rw:set_force_stopped(Uid, false),
    move_rw:set_move_speed(Uid, 20),
    ok.

start_walk_set(Uid, CurMove, NextMove, Src, Dst, Face, Dir, Now, PathList) ->
    move_rw:set_cur_move(Uid, CurMove),
    move_rw:set_next_move(Uid, NextMove),
    move_rw:set_face(Uid, Face),
    move_rw:set_dir(Uid, Dir),
    move_rw:set_start_pos(Uid, Src),
    move_rw:set_dest_pos(Uid, Dst),
    move_rw:set_seg_move_time(Uid, 0),
    move_rw:set_start_time(Uid, Now),
    move_rw:set_force_stopped(Uid, false),
    move_rw:set_path_list(Uid, PathList),
    ok.

stop_move_set(Uid, Pos) ->
    move_rw:set_cur_move(Uid, ?EMS_STAND),
    move_rw:set_next_move(Uid, ?EMS_STAND),
    move_rw:set_start_pos(Uid, Pos),
    move_rw:set_dest_pos(Uid, Pos),
    move_rw:set_seg_move_time(Uid, 0),
    move_rw:set_force_stopped(Uid, false),
    move_rw:set_path_list(Uid, []),
    ok.

%%-------------------------------------------------------------------
start_player_walk(Uid, Start, End) ->
    case is_player_can_walk(Uid, Start, End) of
        true -> start_player_walk_1(Uid, Start, End);
        _ -> error
    end.

-ifdef(TEST).
test_path() ->
    [
        vector3:new(150.0, 0, 150.0),
        vector3:new(200.0, 0, 150.0),
        vector3:new(250.0, 0, 200.0),
        vector3:new(300.0, 0, 50.00),
        vector3:new(350.0, 0, 250.0),
        vector3:new(400.0, 0, 200.0),
        vector3:new(420.0, 0, 300.0),
        vector3:new(25.00, 0, 280.0),
        vector3:new(30.01, 0, 230.0),
        vector3:new(40.01, 0, 100.0),
        vector3:new(180.0, 0, 250.0)
    ].

test_dir() ->
    S = vector3:new(150.0, 0, 150.0),
    E = vector3:new(200.0, 0, 150.0),
    vector3:subtract(E, S).
-endif.

start_player_walk_1(Uid, Start, End) ->
%%    Dir = test_dir(),
%%    Way = test_path(),

    Way = [End],
    Dir = vector3:subtract(End, Start),
    Speed = get_move_speed_by_state(Uid, ?EMS_WALK),
    PathList = make_path_list([], Start, Way, Speed),
    Now = map_rw:get_move_timer_now(),
    %% 调试日志
%%    TotalDist = lists:foldl(
%%        fun(#m_move_pos{dist = DistCur}, Acc) -> Acc + DistCur end, 0, PathList),
%%    TotalTime = TotalDist / Speed * 1000,
%%    ?WARN("player ~p start move from ~w to ~w, dist ~w, ~w(ms)",
%%        [Uid, Start, lists:last(Way), TotalDist, TotalTime]),

    % 路点变化时同步到ETS
    start_walk_set(Uid, ?EMS_WALK, ?EMS_STAND, Start, End, Dir, Dir, Now, PathList),
    on_obj_pos_change(Uid, Start),
    map_view:sync_movement_to_big_visual_tile(Uid),
    hook_map:on_start_move(Uid),
    ok.

stop_player_move(Uid, Pos) ->
    case is_player_can_stop(Uid, Pos) of
        true -> stop_player_move_1(Uid, Pos);
        _ -> error
    end.

stop_player_move_1(Uid, Pos) ->
    stop_move_set(Uid, Pos),
    on_obj_pos_change(Uid, Pos),
    map_view:sync_movement_to_big_visual_tile(Uid),
    ok.

%%-------------------------------------------------------------------
is_player_can_walk(_Uid, _Pos, _End) -> true.

is_player_can_stop(Uid, Pos) ->
    R1 = is_pos_valid(Pos),
    is_distance_safe(R1, Uid, Pos).

is_distance_safe(true, _Uid, _Pos) -> true;
is_distance_safe(False, _Uid, _Pos) -> False.

is_pos_valid(_Pos) -> true.

%%-------------------------------------------------------------------
make_path_list(Acc, _Start, [], _Speed) -> lists:reverse(Acc);
make_path_list(Acc, Start, [Tar | Left], Speed) ->
    R = make_move_r(Start, Tar, Speed),
    make_path_list([R | Acc], Tar, Left, Speed).

%%-------------------------------------------------------------------
make_move_r(Start, End, Speed) ->
    Dist = vector3:dist(Start, End),
    #m_move_pos{
        dist = Dist,
        speed = Speed,
        start_pos = Start,
        end_pos = End,
        dir = vector3:subtract(End, Start)
    }.

%%-------------------------------------------------------------------
update(Unit) -> update_dispatcher(Unit).

%%-------------------------------------------------------------------
update_dispatcher(#m_cache_map_unit{type = ?UNIT_PLAYER, uid = Uid} = Unit) ->
    update_player_move(Unit, move_rw:get_cur_move(Uid));
update_dispatcher(#m_cache_map_unit{type = ?UNIT_MON, uid = Uid} = Unit) ->
    update_monster_move(Unit, move_rw:get_cur_move(Uid));
update_dispatcher(_Obj) -> skip.

%%-------------------------------------------------------------------
update_player_move(Unit, ?EMS_WALK) ->
    #m_cache_map_unit{uid = Uid} = Unit,

    CurPos = move_rw:get_cur_pos(Uid),
    PathList = move_rw:get_path_list(Uid),
    Delta = map_rw:get_move_timer_delta(),
    MovedTime = move_rw:get_seg_move_time(Uid),
    update_role_walk(Uid, CurPos, PathList, MovedTime + Delta),
    ok;
update_player_move(_Obj, _Move) -> skip.

%%-------------------------------------------------------------------
update_monster_move(Unit, ?EMS_WALK) ->
    #m_cache_map_unit{uid = Uid} = Unit,

    CurPos = move_rw:get_cur_pos(Uid),
    PathList = move_rw:get_path_list(Uid),
    Delta = map_rw:get_move_timer_delta(),
    MovedTime = move_rw:get_seg_move_time(Uid),
    update_monster_walk(Uid, CurPos, PathList, MovedTime + Delta),
    ok;
update_monster_move(_Obj, _Move) -> skip.

%%-------------------------------------------------------------------
update_role_walk(Uid, _CurPos, [], _MoveTime) ->
%%    ?WARN("mapid ~p player ~w arrived ~w", [self(), Uid, CurPos]),
    move_rw:set_cur_move(Uid, ?EMS_STAND),
    move_rw:set_next_move(Uid, ?EMS_STAND),
    move_rw:set_start_time(Uid, map_rw:get_move_timer_now()),
    ?ENR_ARRIVE;
update_role_walk(Uid, _CurPos, PathList, MoveTime) ->

    Dir = move_rw:get_dir(Uid),
    Dst = move_rw:get_dest_pos(Uid),
    {NewPos, NewPathList, MoreTime} = linear_pos(PathList, MoveTime, keep),

%%    ?DEBUG("mapid ~p ~w from ~w to ~w move time ~p",
%%        [self(), Unit#m_map_obj.uid, CurPos, NewPos, MoveTime]),
%%    ?DEBUG("# ~p,~p", [NewPos#vector3.x, NewPos#vector3.z]),
    on_obj_pos_change(Uid, NewPos),

    case NewPathList of
        ?ENR_TOBECONTINUED ->
            move_rw:set_seg_move_time(Uid, MoveTime),
            ?ENR_TOBECONTINUED;
        [] ->
            move_rw:set_path_list(Uid, []),
            move_rw:set_seg_move_time(Uid, MoreTime),
            {?ENR_TOBECONTINUED, [], Dir, Dst, MoreTime};
        [#m_move_pos{end_pos = End, dir = TarDir} | _] ->
%%            ?DEBUG("new dest ~w, dir ~w",[End, TarDir]),
            move_rw:set_path_list(Uid, NewPathList),
            move_rw:set_dir(Uid, TarDir),
            move_rw:set_dest_pos(Uid, End),
            move_rw:set_seg_move_time(Uid, MoreTime),
            {?ENR_TOBECONTINUED, NewPathList, TarDir, End, MoreTime}
    end.

%%-------------------------------------------------------------------
-spec linear_pos(vector3:vector3(), list(), keep | changed) ->
    {vector3:vector3(), list() | ?ENR_TOBECONTINUED, float()}.

linear_pos([MovePos] = PL, MoveTime, Flag) ->
    #m_move_pos{dist = Dist, start_pos = Start, end_pos = End, speed = Speed} = MovePos,
    MoveDist = calc_move_dist(Speed, MoveTime),
    if
        MoveDist < Dist -> linear_pos_1(Start, End, MoveDist / Dist, MoveTime, PL, Flag);
        true -> {End, [], 0}
    end;
linear_pos([MovePos | PathList] = PL, MoveTime, Flag) ->
    #m_move_pos{dist = Dist, start_pos = Start, end_pos = End, speed = Speed} = MovePos,
    MoveDist = calc_move_dist(Speed, MoveTime),
    if
        MoveDist == Dist -> {End, PathList, 0};
        MoveDist < Dist -> linear_pos_1(Start, End, MoveDist / Dist, MoveTime, PL, Flag);
        true -> linear_pos(PathList, calc_move_time(Speed, MoveDist - Dist), changed)
    end.

calc_move_dist(Speed, MoveTime) ->
    MoveTime * Speed / 1000.

calc_move_time(Speed, Dist) ->
    erlang:ceil(Dist / Speed * 1000).


%%-------------------------------------------------------------------
linear_pos_1(StartPos, EndPos, K0, MoveTime, PathList, Flag) ->
    K1 = if K0 < 0 -> 0; true -> K0 end,
    K2 = if K1 > 1 -> 1; true -> K1 end,
    Dst = vector3:linear_interpolation(StartPos, EndPos, K2),
    linear_pos_2(Dst, PathList, MoveTime, Flag).

%%-------------------------------------------------------------------
linear_pos_2(Dst, _PathList, _MoveTime, keep) ->
    {Dst, ?ENR_TOBECONTINUED, 0};
linear_pos_2(Dst, PathList, MoveTime, changed) ->
    {Dst, PathList, MoveTime}.

%%-------------------------------------------------------------------
on_obj_pos_change(Uid, Tar) ->
    %
    %% ?DEBUG("~w pos change ~w", [Uid, Tar]),
    Src = move_rw:get_cur_pos(Uid),
    Unit = map_rw:get_obj(Uid),
    OldVisIndex = map_view:pos_to_vis_index(Src),
    NewVisIndex = map_view:pos_to_vis_index(Tar),
%%    ?DEBUG("in map ~p obj ~p ~ts pos change from ~w, ~w",
%%        [lib_map_rw:get_map_id(), Uid, Unit#m_map_obj.name, Src, Tar]),
    ?assert(OldVisIndex > 0 andalso NewVisIndex > 0),
    move_rw:set_cur_pos(Uid, Tar),
    map_view:sync_change_pos_visual_tile(Unit, OldVisIndex, NewVisIndex),
    move_rw:set_vis_tile_idx(Uid, NewVisIndex),
    on_obj_pos_changed(unit_rw:get_type(Uid), Uid, Tar),
    ok.

on_obj_pos_changed(?UNIT_PLAYER, Uid, Tar) ->
    gs_cache:update_player_pub(Uid, {#m_cache_player_pub.pos, Tar}),
    ok;
on_obj_pos_changed(Type, Uid, Tar) ->
    ?ERROR("on_obj_pos_changed(~w,~w,~w)", [Type, Uid, Tar]),
    ok.

%%-------------------------------------------------------------------
cal_move_msg(Uid) ->
    do_cal_move_msg(move_rw:get_cur_move(Uid), Uid).

do_cal_move_msg(?EMS_WALK, Uid) ->
    Src = move_rw:get_start_pos(Uid),
    Dst = move_rw:get_dest_pos(Uid),
    Type = unit_rw:get_type(Uid),
    Speed = get_move_speed_by_state(Uid, ?EMS_WALK),
    StartTime = move_rw:get_start_time(Uid),
    #pk_GS2U_SyncWalk{
        uid = Uid, type = Type,
        move_time = map_rw:get_move_timer_pass_time(StartTime),
        src_x = vector3:x(Src), src_y = vector3:z(Src),
        dst_x = vector3:x(Dst), dst_y = vector3:z(Dst),
        speed = Speed
    };
do_cal_move_msg(?EMS_STAND, Uid) ->
    Pos = move_rw:get_start_pos(Uid),
    Type = unit_rw:get_type(Uid),
    #pk_GS2U_SyncStand{
        uid = Uid,
        type = Type,
        cur_x = vector3:x(Pos),
        cur_y = vector3:z(Pos)
    };
do_cal_move_msg(
    S, Uid
) when S =:= ?EMS_MONSTER_PATROL;S =:= ?EMS_MONSTER_WALK;S =:= ?EMS_MONSTER_FLEE ->
    Src = move_rw:get_start_pos(Uid),
    Dst = move_rw:get_dest_pos(Uid),
    Type = unit_rw:get_type(Uid),
    Speed = get_move_speed_by_state(Uid, S),
    StartTime = move_rw:get_start_time(Uid),
    #pk_GS2U_SyncWalk{
        uid = Uid, type = Type,
        move_time = map_rw:get_move_timer_pass_time(StartTime),
        src_x = vector3:x(Src), src_y = vector3:z(Src),
        dst_x = vector3:x(Dst), dst_y = vector3:z(Dst),
        speed = Speed
    };
do_cal_move_msg(_S, _Uid) ->
    undefined.

%%-------------------------------------------------------------------
start_monster_walk(Uid, Dst, MoveState, NeedCheck) ->
    case is_can_monster_walk(Uid, Dst, MoveState, NeedCheck) of
        true -> do_start_monster_walk(Uid, Dst, MoveState);
        _ -> false
    end.

do_start_monster_walk(Uid, Dst, MoveState) ->
    Way = [Dst],
    Start = move_rw:get_cur_pos(Uid),
    Dir = vector3:subtract(Dst, Start),
    Now = map_rw:get_move_timer_now(),
    Speed = move_rw:get_move_speed(Uid),
    PathList = make_path_list([], Start, Way, Speed),

    %%
    TotalDist = lists:foldl(
        fun(#m_move_pos{dist = DistCur}, Acc) -> Acc + DistCur end, 0, PathList),
    TotalTime = TotalDist / Speed * 1000,
    ?WARN("monster ~p start move from ~w to ~w, dist ~w, ~w(ms)",
        [Uid, Start, lists:last(Way), TotalDist, TotalTime]),

    % 
    start_walk_set(Uid, MoveState, ?EMS_STAND, Start, Dst, Dir, Dir, Now, PathList),
    map_view:sync_movement_to_big_visual_tile(Uid),
    hook_map:on_start_move(Uid),
    true.


is_can_monster_walk(Uid, _Dst, _MoveState, _NeedCheck) ->
    % todo 检查怪物状态、检查目标点等等
    unit:is_unit_cant_move_state(Uid),
    true.


%%-------------------------------------------------------------------
update_monster_walk(Uid, CurPos, [], _MoveTime) ->
    ?WARN("mapid ~p monster ~w arrived ~w", [self(), Uid, CurPos]),
    move_rw:set_cur_move(Uid, ?EMS_STAND),
    move_rw:set_next_move(Uid, ?EMS_STAND),
    move_rw:set_start_time(Uid, map_rw:get_move_timer_now()),
    ?ENR_ARRIVE;
update_monster_walk(Uid, _CurPos, PathList, MoveTime) ->

    Dir = move_rw:get_dir(Uid),
    Dst = move_rw:get_dest_pos(Uid),
    {NewPos, NewPathList, MoreTime} = linear_pos(PathList, MoveTime, keep),

    on_obj_pos_change(Uid, NewPos),

    case NewPathList of
        ?ENR_TOBECONTINUED ->
            move_rw:set_seg_move_time(Uid, MoveTime),
            ?ENR_TOBECONTINUED;
        [] ->
            move_rw:set_path_list(Uid, []),
            move_rw:set_seg_move_time(Uid, MoreTime),
            {?ENR_TOBECONTINUED, [], Dir, Dst, MoreTime};
        [#m_move_pos{end_pos = End, dir = TarDir} | _] ->
%%            ?DEBUG("new dest ~w, dir ~w",[End, TarDir]),
            move_rw:set_path_list(Uid, NewPathList),
            move_rw:set_dir(Uid, TarDir),
            move_rw:set_dest_pos(Uid, End),
            move_rw:set_seg_move_time(Uid, MoreTime),
            {?ENR_TOBECONTINUED, NewPathList, TarDir, End, MoreTime}
    end.


stop_move(Uid, NeedBroadcast) ->
    CurMove = move_rw:get_cur_move(Uid),
    if
        CurMove =:= ?EMS_WALK;
        CurMove =:= ?EMS_MONSTER_PATROL;
        CurMove =:= ?EMS_MONSTER_FLEE;
        CurMove =:= ?EMS_MONSTER_WALK ->
            CurPos = move_rw:get_cur_pos(Uid),
            stop_move_set(Uid, CurPos),
            move_rw:set_force_stopped(Uid, true),
            case NeedBroadcast of
                true -> map_view:sync_movement_to_big_visual_tile(Uid);
                _ -> skip
            end;
        true -> skip
    end,
    ok.

stop_move_force(Uid, NeedBroadcast) ->
    CurMove = move_rw:get_cur_move(Uid),
    if
        CurMove =:= ?EMS_WALK;
        CurMove =:= ?EMS_MONSTER_PATROL;
        CurMove =:= ?EMS_MONSTER_FLEE;
        CurMove =:= ?EMS_MONSTER_WALK ->
            CurPos = move_rw:get_cur_pos(Uid),
            stop_move_set(Uid, CurPos),
            case NeedBroadcast of
                true -> map_view:sync_movement_to_big_visual_tile(Uid);
                _ -> skip
            end;
        true -> skip
    end,
    ok.

get_move_speed_by_state(Uid, ?EMS_MONSTER_PATROL) ->
    move_rw:get_move_speed(Uid) * 0.5;
get_move_speed_by_state(Uid, ?EMS_MONSTER_FLEE) ->
    move_rw:get_move_speed(Uid) * 1.1;
get_move_speed_by_state(Uid, ?EMS_MONSTER_WALK) ->
    move_rw:get_move_speed(Uid);
get_move_speed_by_state(Uid, _) ->
    move_rw:get_move_speed(Uid).
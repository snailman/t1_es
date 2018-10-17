%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2018, <COMPANY>
%%% @doc  玩家进程其他模块可调用的接口
%%%
%%% @end
%%% Created : 12. 六月 2018 17:22
%%%-------------------------------------------------------------------
-module(player_pub).
-author("mawenhong").
-include("logger.hrl").
-include("pub_def.hrl").
-include("map_core.hrl").
-include("gs_common_rec.hrl").
-include("gs_cache.hrl").


%% API
%% 玩家进程其他模块可调用的接口
-export([
    % 关掉网络 、获取socket 、终止进程、发送网络消息
    shutdown/1, socket/0, stop/1, send_net_msg/1
]).

-export([
    % 改变分组
    change_group_/1,
    % 换地图、回之前的地图
    change_map_/3, change_pre_map_/0,
    % 改变战斗属性
    player_change_combat_prop_/1,
    % 本地图传送、开始移动、停止移动
    teleport_/1, start_move_/2, stop_move_/2,
    % 给我所在的地图发送消息
    send_map_msg_/1, send_map_msg_/2,
    % 给我所在地图所有玩家进程发消息或者发送网络消息
    broadcast_map_msg_/1, broadcast_map_msg_/2, broadcast_map_net_msg_/1,
    % 给我视野范围内的所有玩家进程发消息或者发送网络消息
    broadcast_map_view_msg_/1, broadcast_map_view_msg_/2, broadcast_map_view_net_msg_/1
]).


%%-------------------------------------------------------------------
-spec shutdown(How) -> ok when
    How :: read | write | read_write.
shutdown(How) -> player_tcp_handler:shutdown(How).
stop(Reason) -> player_tcp_handler:stop(Reason).
socket() -> player_tcp_handler:socket().
%%-------------------------------------------------------------------

-spec send_net_msg(Msg :: list() | tuple()) -> ok.
send_net_msg(Msg) -> player_tcp_handler:send_net_msg(Msg).

%%-------------------------------------------------------------------
send_map_msg_(MsgId) ->
    #m_player_map{map_pid = MapPid} = player_rw:get_map(),
    ps:send(MapPid, MsgId),
    ok.

send_map_msg_(MsgId, Msg) ->
    #m_player_map{map_pid = MapPid} = player_rw:get_map(),
    ps:send(MapPid, MsgId, Msg),
    ok.

%%-------------------------------------------------------------------
broadcast_map_msg_(MsgId) ->
    #m_player_map{map_pid = MapPid} = player_rw:get_map(),
    ps:send(MapPid, msg_broadcast, {MsgId}),
    ok.

broadcast_map_msg_(MsgId, Msg) ->
    #m_player_map{map_pid = MapPid} = player_rw:get_map(),
    ps:send(MapPid, msg_broadcast, {MsgId, Msg}),
    ok.

broadcast_map_net_msg_(NetMsg) ->
    #m_player_map{map_pid = MapPid} = player_rw:get_map(),
    ps:send(MapPid, net_msg_broadcast, NetMsg),
    ok.

%%-------------------------------------------------------------------
broadcast_map_view_msg_(MsgId) ->
    Uid = player_rw:get_uid(),
    #m_player_map{map_pid = MapPid} = player_rw:get_map(),
    ps:send(MapPid, msg_broadcast_view, {Uid, MsgId}),
    ok.

broadcast_map_view_msg_(MsgId, Msg) ->
    Uid = player_rw:get_uid(),
    #m_player_map{map_pid = MapPid} = player_rw:get_map(),
    ps:send(MapPid, msg_broadcast_view, {Uid, MsgId, Msg}),
    ok.

broadcast_map_view_net_msg_(NetMsg) ->
    Uid = player_rw:get_uid(),
    #m_player_map{map_pid = MapPid} = player_rw:get_map(),
    ps:send(MapPid, net_msg_broadcast_view, {Uid, NetMsg}),
    ok.

%%-------------------------------------------------------------------
change_pre_map_() ->
    player_interface:change_pre_map_(self()).

%%-------------------------------------------------------------------
change_map_(DestMapID, LineId, TarPos) ->
    ps:send(self(), passive_change_req, {DestMapID, LineId, TarPos}).

%%-------------------------------------------------------------------
change_group_(GroupId) ->
    Uid = player_rw:get_uid(),
    #m_player_map{map_pid = MapPid} = player_rw:get_map(),
    ps:send(MapPid, change_group, {Uid, GroupId}),
    ok.

%%-------------------------------------------------------------------
teleport_(NewPos) -> ps:send(self(), teleport, NewPos).

%%-------------------------------------------------------------------
start_move_(MapPid, Req) -> map_interface:player_move_(MapPid, Req).

%%-------------------------------------------------------------------
stop_move_(MapPid, Req) -> map_interface:player_stop_move_(MapPid, Req).

%%--------------------------------
player_change_combat_prop_(Req) ->
    #m_player_map{map_pid = MapPid} = player_rw:get_map(),
    map_interface:player_change_combat_prop_(MapPid, Req),
    ok.






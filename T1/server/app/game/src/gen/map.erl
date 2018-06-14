
%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 六月 2018 9:58
%%%-------------------------------------------------------------------
-module(map).
-author("mawenhong").
-include("map.hrl").
%% API
%%--------------------------------
%% WARNING!!! WARNING!!! WARNING!!!
%% call
-export([player_join/2, player_exit/2, player_teleport/2]).
%%--------------------------------
%%
-export([
    player_move_/2, player_change_attr/2
]).
-export([status_/1]).


%%--------------------------------
%%--------------------------------
%% WARNING!!! WARNING!!! WARNING!!!
%% call
player_exit(MapPid, Req) ->
    gen_server:call(MapPid, {player_exit, Req}, ?MAP_CALL_TIMEOUT).
%%--------------------------------
player_join(MapPid, Obj) ->
    gen_server:call(MapPid, {player_join, Obj}, ?MAP_CALL_TIMEOUT).
%%--------------------------------
player_teleport(MapPid, Req) ->
    gen_server:call(MapPid, {player_teleport, Req}, ?MAP_CALL_TIMEOUT).
%%--------------------------------
%%--------------------------------


player_change_attr(MapPid, Req) ->
    ps:send(MapPid, player_change_attr, Req),
    ok.


%%--------------------------------
player_move_(MapPid, Req) ->
    ps:send(MapPid, start_move, Req).

%%--------------------------------
status_(MapPid) -> ps:send(MapPid, status).
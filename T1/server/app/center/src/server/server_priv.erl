%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. 十月 2017 10:12
%%%-------------------------------------------------------------------
-module(server_priv).
-author("mawenhong").

-include("logger.hrl").
-include("pub_def.hrl").
-include("pub_rec.hrl").
-include("common_rec.hrl").
-include("common_def.hrl").
-include("cs_ps_def.hrl").
-include("cs_priv.hrl").

%% API
-export([
    nodedown/2, sync/0
]).

-export([get_sid/0, get_from_pid/0, get_type/0, set_info/3]).


%%-------------------------------------------------------------------
get_sid() -> case get(serverID) of undefined -> 0; V -> V end.
get_from_pid() -> case get(serverPid) of undefined -> 0; V -> V end.
get_type() -> case get(serverType) of undefined -> 0; V -> V end.
set_info(Sid, FromPid, Type) ->
    put(serverPid, FromPid),
    put(serverID, Sid),
    put(serverType, Type),
    ok.
%%-------------------------------------------------------------------


sync() ->
    Sid = get_sid(),
    Node = erlang:node(get_from_pid()),
    ?WARN("server[~p]sync start...", [Node]),
    cs_cache:add_check_server(Sid),
    ps:send_with_from(get_from_pid(), syncAllData),
    cs_share:sync(Node),
    sync_over(Node, Sid),
    ok.



sync_over(GSNode, Sid) ->
    
    ?WARN("server[~p] sync done #", [GSNode]),
    all_ready(Sid),
    [Info] = misc_mnesia:dirty_read(?MNESIA_SERVER_INFO, Sid),
    misc_mnesia:dirty_write(?MNESIA_SERVER_INFO, Info#m_share_server_info{status = ?SEVER_STATUS_DONE}),
    ps:send_with_from(?CS_SVR_MGR_OTP, allReadyNow, {Sid}),
    erlang:garbage_collect(self()),
    ok.

all_ready(_ServerID) ->
    ps:send_with_from(get_from_pid(), startNow),
    Node = erlang:node(get_from_pid()),
    ?WARN("####[~p][~p][ok]####", [Node, misc:registered_name()]),
    ok.


%%-------------------------------------------------------------------
nodedown(GSNode, OtpName) ->
    Sid = server_priv:get_sid(),
    Type = server_priv:get_type(),
    ps:send(?CS_SVR_MGR_OTP, nodedown, {GSNode, server_priv:get_sid()}),
    ?WARN("server[~p], stop worker[~p][~p] now", [GSNode, self(), OtpName]),
    common_interface:send_msg_2_all_server(server_down, {Sid, Type, GSNode}),
    ok.


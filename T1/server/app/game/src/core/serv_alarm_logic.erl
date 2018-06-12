%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. 六月 2018 15:09
%%%-------------------------------------------------------------------
-module(serv_alarm_logic).
-author("mawenhong").
-include("pub_common.hrl").
-include("common_record.hrl").
-include("mem_record.hrl").

%% API
-export([init/0]).

-define(ETS_ALARM_POLICY, ets_alarm_policy).
-define(ETS_ALARM_PLAYER, ets_alarm_player).

init() ->
    ets:new(?ETS_ALARM_POLICY, [protected, set, named_table, {keypos, #m_alarm_policy.id}, ?ETS_RC, ?ETS_WC]),
    ets:new(?ETS_ALARM_PLAYER, [protected, set, named_table, {keypos, #m_alarm_player.uid}, ?ETS_RC, ?ETS_WC]),
    ok.





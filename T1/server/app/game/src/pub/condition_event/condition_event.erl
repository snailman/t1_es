%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. 九月 2018 16:41
%%%-------------------------------------------------------------------
-module(condition_event).
-author("mawenhong").

-include("logger.hrl").
-include("gs_cache.hrl").
-include("condition_event.hrl").
%%-include("cfg_conditional_event.hrl").
%% API
-export([action_all/2, action/2]).


action_all(EventList, Params) when is_list(EventList) ->
    condition_event:action(EventList, Params),
    ok;
action_all(_EventList, _Params) ->
    skip.


action([Conditions, EventTrue, EventFalse], Params) ->
    case condition_loop(true, Conditions, Params) of
        true -> event_loop(EventTrue, Params);
        _Any -> event_loop(EventFalse, Params)
    end,
    ok;
action(_Any,_Params) -> skip.


%%-------------------------------------------------------------------
%%    [[逻辑关系，主分类，分类的ID，参数1，参数2，参数3]]
condition_loop(
    Result,
    [[?CONDITION_OR | _] = Condition | Conditions],
    Params
) ->
    Bool = condition_action:check(Condition, Params) orelse Result,
    condition_loop(Bool, Conditions, Params);
condition_loop(
    Result,
    [[?CONDITION_AND | _] = Condition | Conditions],
    Params
) ->
    Bool = condition_action:check(Condition, Params) andalso Result,
    condition_loop(Bool, Conditions, Params);
condition_loop(Result, [_Condition | Conditions], Params) ->
    condition_loop(Result, Conditions, Params);
condition_loop(Result, _AnyOther, _Params) ->
    Result.

%%-------------------------------------------------------------------
event_loop([], _Params) -> skip;
event_loop([[]], _Params) -> skip;
event_loop(Events, Params) ->
    lists:foreach(
        fun(Event) ->
            event_action:action(Event, Params)
        end, Events).


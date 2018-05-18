%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 十二月 2017 17:12
%%%-------------------------------------------------------------------

-module(common_error_logger_h).

-behaviour(gen_event).

%% gen_event callbacks
-export([
    init/1, handle_event/2, handle_call/2, handle_info/2, terminate/2,
    code_change/3
]).


%%%----------------------------------------------------------------------
%%% Callback functions from gen_event
%%%----------------------------------------------------------------------

%%----------------------------------------------------------------------
%% Func: init/1
%% Returns: {ok, State}          |
%%          Other
%%----------------------------------------------------------------------
init(Handler) ->
    {ok, Handler}.

%%----------------------------------------------------------------------
%% Func: handle_event/2
%% Returns: {ok, State}                                |
%%          {swap_handler, Args1, State1, Mod2, Args2} |
%%          remove_handler                              
%%----------------------------------------------------------------------
handle_event(Event, State) ->
    ps:send(State, {event, Event}),
    {ok, State}.

%%----------------------------------------------------------------------
%% Func: handle_call/2
%% Returns: {ok, Reply, State}                                |
%%          {swap_handler, Reply, Args1, State1, Mod2, Args2} |
%%          {remove_handler, Reply}                            
%%----------------------------------------------------------------------
handle_call(_Request, State) ->
    Reply = ok,
    {ok, Reply, State}.

%%----------------------------------------------------------------------
%% Func: handle_info/2
%% Returns: {ok, State}                                |
%%          {swap_handler, Args1, State1, Mod2, Args2} |
%%          remove_handler                              
%%----------------------------------------------------------------------
handle_info({'EXIT', _Fd, _Reason}, _State) ->
    remove_handler;
handle_info(_Info, State) ->
    {ok, State}.

%%----------------------------------------------------------------------
%% Func: terminate/2
%% Purpose: Shutdown the server
%% Returns: any
%%----------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%----------------------------------------------------------------------
%%% Internal functions
%%%----------------------------------------------------------------------




	    

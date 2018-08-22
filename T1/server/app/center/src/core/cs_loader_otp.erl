%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. 六月 2018 10:34
%%%-------------------------------------------------------------------
-module(cs_loader_otp).
-author("mawenhong").

-behaviour(gen_serverw).
-include("logger.hrl").
-include("pub_def.hrl").
-include("cs_ps_def.hrl").

%% API
-export([start_link/0]).
-export([mod_init/1, do_handle_call/3, do_handle_info/2, do_handle_cast/2]).

%%%===================================================================
%%% public functions
%%%===================================================================
start_link() ->
    gen_serverw:start_link({local, ?CS_LOADER_OTP}, ?MODULE, [], []).

%%%===================================================================
%%% Internal functions
%%%===================================================================	
mod_init(_Args) ->
    erlang:process_flag(trap_exit, true),
    erlang:process_flag(priority, high),
    TaskList = lib_cs_loader:task_list(),
    ?WARN("loader task list ~p", [TaskList]),
    ps:send(self(), start_all_task),
    {ok, TaskList}.

%%--------------------------------------------------------------------
do_handle_call(task_all_done, _From, State) ->
    Ret = ?if_else(State =:= [], true, State),
    {reply,  Ret, State};
do_handle_call(Request, From, State) ->
    ?ERROR("undeal call ~w from ~w", [Request, From]),
    {reply, ok, State}.

%%--------------------------------------------------------------------
do_handle_info(start_all_task, State) ->
    lib_cs_loader:start_all_task(),
    {noreply, State};
do_handle_info({task_done, Task}, State) ->
    LeftTaskList = lists:delete(Task, State),
    ?WARN("task ~p done, task list left ~p",[Task, LeftTaskList]),
    {noreply, LeftTaskList};
do_handle_info(Info, State) ->
    lib_cs_loader:on_info_msg(Info),
    {noreply, State}.

%%--------------------------------------------------------------------
do_handle_cast(Request, State) ->
    ?ERROR("undeal cast ~w", [Request]),
    {noreply, State}.

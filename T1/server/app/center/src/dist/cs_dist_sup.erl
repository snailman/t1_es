%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. 八月 2018 15:05
%%%-------------------------------------------------------------------
-module(cs_dist_sup).
-author("mawenhong").


-behaviour(supervisor).
-include("pub_def.hrl").

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).


%%--------------------------------------------------------------------
%% @doc
%% Starts the supervisor
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
    {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
%%
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
    {ok, {SupFlags :: {RestartStrategy :: supervisor:strategy(),
        MaxR :: non_neg_integer(), MaxT :: non_neg_integer()},
        [ChildSpec :: supervisor:child_spec()]
    }} |
    ignore |
    {error, Reason :: term()}).
init([]) ->
    {
        ok,
        {
            {one_for_one, 5, 10},
            [
                %% 把逻辑进程挂到这个下面
                ?CHILD(cs_dist_core_srv, worker)
            ]
        }
    }.

%%%===================================================================
%%% Internal functions
%%%===================================================================

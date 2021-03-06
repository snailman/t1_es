%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 十二月 2017 17:12
%%%-------------------------------------------------------------------

-module(pg_local).

-export([join/2, leave/2, get_members/1, in_group/2]).
-export([sync/0]). %% intended for testing only; not part of official API
-export([start/0, start_link/0, init/1, handle_call/3, handle_cast/2,
         handle_info/2, terminate/2]).

%%----------------------------------------------------------------------------

-type name() :: term().

-spec start_link() -> {'ok', pid()} | {'error', any()}.
-spec start() -> {'ok', pid()} | {'error', any()}.
-spec join(name(), pid()) -> 'ok'.
-spec leave(name(), pid()) -> 'ok'.
-spec get_members(name()) -> [pid()].
-spec in_group(name(), pid()) -> boolean().

-spec sync() -> 'ok'.

%%----------------------------------------------------------------------------

%%%
%%% Exported functions
%%%

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

start() ->
    ensure_started().

join(Name, Pid) when is_pid(Pid) ->
    _ = ensure_started(),
    gen_server:cast(?MODULE, {join, Name, Pid}).

leave(Name, Pid) when is_pid(Pid) ->
    _ = ensure_started(),
    gen_server:cast(?MODULE, {leave, Name, Pid}).

get_members(Name) ->
    _ = ensure_started(),
    group_members(Name).

in_group(Name, Pid) ->
    _ = ensure_started(),
    %% The join message is a cast and thus can race, but we want to
    %% keep it that way to be fast in the common case.
    case member_present(Name, Pid) of
        true  -> true;
        false -> sync(),
                 member_present(Name, Pid)
    end.

sync() ->
    _ = ensure_started(),
    gen_server:call(?MODULE, sync, infinity).

%%%
%%% Callback functions from gen_server
%%%

-record(state, {}).

init([]) ->
    pg_local_table = ets:new(pg_local_table, [ordered_set, protected, named_table]),
    {ok, #state{}}.

handle_call(sync, _From, S) ->
    {reply, ok, S};

handle_call(Request, From, S) ->
    error_logger:warning_msg("The pg_local server received an unexpected message:\n"
                             "handle_call(~p, ~p, _)\n",
                             [Request, From]),
    {noreply, S}.

handle_cast({join, Name, Pid}, S) ->
    _ = join_group(Name, Pid),
    {noreply, S};
handle_cast({leave, Name, Pid}, S) ->
    leave_group(Name, Pid),
    {noreply, S};
handle_cast(_, S) ->
    {noreply, S}.

handle_info({'DOWN', MonitorRef, process, _Pid, _Info}, S) ->
    member_died(MonitorRef),
    {noreply, S};
handle_info(_, S) ->
    {noreply, S}.

terminate(_Reason, _S) ->
    true = ets:delete(pg_local_table),
    ok.

%%%
%%% Local functions
%%%

%%% One ETS table, pg_local_table, is used for bookkeeping. The type of the
%%% table is ordered_set, and the fast matching of partially
%%% instantiated keys is used extensively.
%%%
%%% {{ref, Pid}, MonitorRef, Counter}
%%% {{ref, MonitorRef}, Pid}
%%%    Each process has one monitor. Counter is incremented when the
%%%    Pid joins some group.
%%% {{member, Name, Pid}, _}
%%%    Pid is a member of group Name, GroupCounter is incremented when the
%%%    Pid joins the group Name.
%%% {{pid, Pid, Name}}
%%%    Pid is a member of group Name.

member_died(Ref) ->
    [{{ref, Ref}, Pid}] = ets:lookup(pg_local_table, {ref, Ref}),
    Names = member_groups(Pid),
    _ = [leave_group(Name, P) ||
            Name <- Names,
            P <- member_in_group(Pid, Name)],
    ok.

join_group(Name, Pid) ->
    Ref_Pid = {ref, Pid},
    try _ = ets:update_counter(pg_local_table, Ref_Pid, {3, +1})
    catch _:_:_ ->
            Ref = erlang:monitor(process, Pid),
            true = ets:insert(pg_local_table, {Ref_Pid, Ref, 1}),
            true = ets:insert(pg_local_table, {{ref, Ref}, Pid})
    end,
    Member_Name_Pid = {member, Name, Pid},
    try _ = ets:update_counter(pg_local_table, Member_Name_Pid, {2, +1})
    catch _:_:_ ->
            true = ets:insert(pg_local_table, {Member_Name_Pid, 1}),
            true = ets:insert(pg_local_table, {{pid, Pid, Name}})
    end.

leave_group(Name, Pid) ->
    Member_Name_Pid = {member, Name, Pid},
    try ets:update_counter(pg_local_table, Member_Name_Pid, {2, -1}) of
        N ->
            if
                N =:= 0 ->
                    true = ets:delete(pg_local_table, {pid, Pid, Name}),
                    true = ets:delete(pg_local_table, Member_Name_Pid);
                true ->
                    ok
            end,
            Ref_Pid = {ref, Pid},
            case ets:update_counter(pg_local_table, Ref_Pid, {3, -1}) of
                0 ->
                    [{Ref_Pid,Ref,0}] = ets:lookup(pg_local_table, Ref_Pid),
                    true = ets:delete(pg_local_table, {ref, Ref}),
                    true = ets:delete(pg_local_table, Ref_Pid),
                    true = erlang:demonitor(Ref, [flush]),
                    ok;
                _ ->
                    ok
            end
    catch _:_:_ ->
            ok
    end.

group_members(Name) ->
    [P ||
        [P, N] <- ets:match(pg_local_table, {{member, Name, '$1'},'$2'}),
        _ <- lists:seq(1, N)].

member_in_group(Pid, Name) ->
    [{{member, Name, Pid}, N}] = ets:lookup(pg_local_table, {member, Name, Pid}),
    lists:duplicate(N, Pid).

member_present(Name, Pid) ->
    case ets:lookup(pg_local_table, {member, Name, Pid}) of
        [_] -> true;
        []  -> false
    end.

member_groups(Pid) ->
    [Name || [Name] <- ets:match(pg_local_table, {{pid, Pid, '$1'}})].

ensure_started() ->
    case whereis(?MODULE) of
        undefined ->
            C = {pg_local, {?MODULE, start_link, []}, permanent,
                 16#ffffffff, worker, [?MODULE]},
            supervisor:start_child(kernel_safe_sup, C);
        PgLocalPid ->
            {ok, PgLocalPid}
    end.

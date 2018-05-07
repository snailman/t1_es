%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. 十二月 2017 14:12
%%%-------------------------------------------------------------------
-module(mysql_interface).
-author("mawenhong").

%% API
-export([
    execute/3, execute/4,
    query/2, query/3, query/4,
    transaction/2, transaction/3, transaction/4,
    with/2
]).

%% API
-export([
    as_record/3, as_record/4, as_record/5, as_maps/2,
    get_rows_count/1,
    succeed/1
]).


%% @doc Execute a mysql prepared statement with given params.
execute(PoolName, StatementRef, Params) ->
    mysql_poolboy:execute(PoolName, StatementRef, Params).

%% @doc Execute a mysql prepared statement with given params and timeout
execute(PoolName, StatementRef, Params, Timeout) ->
    mysql_poolboy:execute(PoolName, StatementRef, Params, Timeout).

%% @doc Executes a query to a mysql connection in a given pool.
query(PoolName, Query) ->
    mysql_poolboy:query(PoolName, Query).

%% @doc Executes a query to a mysql connection in a given pool with either
%% list of query parameters or a timeout value.
query(PoolName, Query, ParamsOrTimeout) ->
    mysql_poolboy:query(PoolName, Query, ParamsOrTimeout).

%% @doc Executes a query to a mysql connection in a given pool with both
%% a list of query parameters and a timeout value.
query(PoolName, Query, Params, Timeout) ->
    mysql_poolboy:query(PoolName, Query, Params, Timeout).

%% @doc Wrapper to poolboy:transaction/2. Since it is not a mysql transaction.
%% Example instead of:
%% Conn = mysql_poolboy:checkout(mypool),
%% try
%%     mysql:query(Conn, "SELECT...")
%%  after
%%     mysql_poolboy:checkin(mypool, Conn)
%%  end.
%%
%% mysql_poolboy:with(mypool, fun (Conn) -> mysql:query(Conn, "SELECT...") end).
with(PoolName, Fun) when is_function(Fun, 1) ->
    mysql_poolboy:with(PoolName, Fun).

%% @doc Executes a mysql transaction fun. The fun needs to take one argument
%% which is the mysql connection.
transaction(PoolName, TransactionFun) when is_function(TransactionFun, 1) ->
    mysql_poolboy:transaction(PoolName, TransactionFun).

%% @doc Executes a transaction fun. Args list needs be the same length as
%% TransactionFun arity - 1.
transaction(PoolName, TransactionFun, Args)
    when is_function(TransactionFun, length(Args) + 1) ->
    mysql_poolboy:transaction(PoolName, TransactionFun, Args).

%% @doc Same as transaction/3 but with the number of retries the mysql
%% transaction should try to execute.
transaction(PoolName, TransactionFun, Args, Retries)
    when is_function(TransactionFun, length(Args) + 1) ->
    mysql_poolboy:transaction(PoolName, TransactionFun, Args, Retries).




%%-include("emysql.hrl").

%% @doc
succeed({error,_ErrorReason})-> false;
succeed(ok)-> true;
succeed({ok, _Fields, _Rows})-> true;
succeed({atomic,_}) -> true;
%%succeed(#error_packet{}) -> false;
%%succeed(#result_packet{}) -> true;
%%succeed(#ok_packet{}) -> true;
%%succeed([H | _L]) -> succeed(H);
succeed(_Any) -> false.



%% @doc package row data as records
as_record(Columns, Rows, RecordName, Fields, Fun)
    when is_atom(RecordName), is_list(Fields), is_function(Fun) ->
    S = lists:seq(1, length(Columns)),
    P = lists:zip([binary_to_atom(C1, utf8) || C1 <- Columns], S),
    F = fun(FieldName) ->
        case proplists:lookup(FieldName, P) of
            none ->
                fun(_) -> undefined end;
            {FieldName, Pos} ->
                fun(Row) -> lists:nth(Pos, Row) end
        end
        end,
    Fs = [ F(FieldName) || FieldName <- Fields ],
    F1 = fun(Row) ->
        RecordData = [ Fx(Row) || Fx <- Fs ],
        Fun(list_to_tuple([RecordName|RecordData]))
         end,
    [F1(Row) || Row <- Rows].

as_record(Columns, Rows, RecordName, Fields)
    when is_atom(RecordName), is_list(Fields) ->
    as_record(Columns, Rows, RecordName, Fields, fun(A) -> A end).

as_record({_, Columns, Rows}, RecordName, Fields)->
    as_record(Columns, Rows, RecordName, Fields).


%% @doc
get_rows_count({ok, _Fields, Rows})-> erlang:length(Rows);
get_rows_count(Rows) when is_list(Rows) -> erlang:length(Rows);
get_rows_count(_) -> 0.



%%
%% @doc package row data as a map
as_maps(undefined, undefined) ->
    [];
as_maps(Fields, undefined)
    when is_list(Fields) ->
    [];
as_maps(Fields, [])
    when is_list(Fields) ->
    [];
as_maps(Fields, Rows)
    when is_list(Fields), is_list(Rows) ->
    [begin
         maps:from_list([{binary_to_atom(K,utf8), V} || {K, V} <- lists:zip(Fields, R)])
     end || R <- Rows].

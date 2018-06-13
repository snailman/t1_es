%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. 六月 2018 14:12
%%%-------------------------------------------------------------------
-module(r2_rw_code).
-author("mawenhong").
-include("map_obj.hrl").
-include("db_record.hrl").
-include("rw_record.hrl").
-define(LogFileOptions, [exclusive, append, raw, binary]).
%% API
-export([run/0]).

-define(HEADER_SEC,
    "%%% This File Is AUTO GENERATED, Don't Modify it MANUALLY!!!\n"
    "%%% This File Is AUTO GENERATED, Don't Modify it MANUALLY!!!\n"
    "%%% This File Is AUTO GENERATED, Don't Modify it MANUALLY!!!\n"
).

-define(SPLIT_LINE, "%%-------------------------------------------------------------------\n").

run() ->
    try
        multi_to_code(
            "..\\src\\lib\\map\\lib_obj_rw.erl",
            lib_obj_rw,
            [
                ["logger.hrl", "rw_record.hrl"],
                [
                    {m_map_obj_rw, record_info(fields, m_map_obj_rw), none, ["Uid"], "hook_map:on_rw_update"}
                ]
            ]
        ),
        multi_to_code(
            "..\\src\\lib\\player\\lib_player_rw.erl",
            lib_player_rw,
            [
                ["logger.hrl", "player_status.hrl", "rw_record.hrl", "vector3.hrl"],
                [
                    {m_player_rw, record_info(fields, m_player_rw), none, [], "hook_player:on_rw_update"}
                ]
            ]
        ),
        ok
    catch _:Err:ST ->
        io:format("~p,~p~n", [Err, ST])
    end,
    ok.



multi_to_code(Fname, ModName, [IncFiles, Cfgs]) ->
    file:write_file(Fname, ""),
    write_file(Fname, "~ts", [?SPLIT_LINE]),
    write_file(Fname, "~ts", [?HEADER_SEC]),
    write_file(Fname, "~ts", [?SPLIT_LINE]),

    write_file(Fname, "-module(~p).~n~n", [ModName]),
    write_file(Fname, "~ts", [?SPLIT_LINE]),

    inc_files(Fname, IncFiles),
    write_file(Fname, "~ts~n", [?SPLIT_LINE]),

    lists:foreach(
        fun({_Record, FieldList, Suffix, ExParams, _HookUpdate}) ->
            ExParamN = erlang:length(ExParams),
            lists:foreach(
                fun(Field) ->
                    field_fun_export(Fname, Field, Suffix, ExParamN, ExParamN + 1)
                end, FieldList),

            field_fun_export_del(Fname, del, Suffix, ExParamN),
            field_fun_export_to(Fname, to, Suffix, ExParamN),
            
            write_file(Fname, "~ts", [?SPLIT_LINE]),
            ok
        end, Cfgs),

    write_file(Fname, "~ts", [?SPLIT_LINE]),

    lists:foreach(
        fun({Record, FieldList, Suffix, ExParams, HookUpdate}) ->
            ExParamS = string:join(ExParams, ","),
            lists:foreach(
                fun(Field) ->
                    write_file(Fname, "~ts%% #~p.~p\n", [?SPLIT_LINE, Record, Field]),
                    field_fun(Fname, Field, Suffix, ExParamS, HookUpdate)
                end, FieldList),

            del_fun(Fname, Suffix, del, FieldList, ExParamS),
            to_record(Fname, Suffix, to, Record, FieldList, ExParamS),

            write_file(Fname, "~ts", [?SPLIT_LINE]),
            ok
        end, Cfgs),


    file:close(Fname),
    ok.

inc_files(Fd, Incs) ->
    lists:foreach(
        fun(Inc) ->
            write_file(Fd, "-include(\"~ts\").\n", [Inc])
        end, Incs),
    ok.
%%-----------------------------------------------------------------------

%%-----------------------------------------------------------------------
field_fun_export(Fd, Field, none, GetN, SetN) ->
    S = io_lib:format("-export([get_~p/~p, get_~p_def/~p, set_~p/~p]).",
        [Field,  GetN, Field,  GetN+1, Field, SetN]),
    write_file(Fd, "~ts~n", [S]),
    ok;
field_fun_export(Fd, Field, Suffix, GetN, SetN) ->
    S = io_lib:format("-export([get_~p_~p/~p, get_~p_~p_def/~p, set_~p_~p/~p]).",
        [Suffix, Field, GetN, Suffix, Field, GetN+1, Suffix, Field, SetN]),
    write_file(Fd, "~ts~n", [S]),
    ok.


field_fun_export_del(Fd, F, none, N) ->
    S = io_lib:format("-export([~p/~p]).", [F, N]),
    write_file(Fd, "~ts~n", [S]),
    ok;
field_fun_export_del(Fd, F, Suffix, N) ->
    S = io_lib:format("-export([~p_~p/~p]).", [F, Suffix, N]),
    write_file(Fd, "~ts~n", [S]),
    ok.

field_fun_export_to(Fd, F, none, N) ->
    S = io_lib:format("-export([~p_record/~p]).", [F, N]),
    write_file(Fd, "~ts~n", [S]),
    ok;
field_fun_export_to(Fd, F, Suffix, N) ->
    S = io_lib:format("-export([~p_~p_record/~p]).", [F, Suffix, N]),
    write_file(Fd, "~ts~n", [S]),
    ok.


%%-----------------------------------------------------------------------

field_fun(Fd, Field, Suffix, [], HookUpdate) ->
    case Suffix of
        none ->
            write_file(Fd, "get_~p()-> get(~p).~n", [Field, Field]),
            write_file(Fd, "get_~p_def(Def)->\n\tcase get(~p) of\n\t\tundefined -> Def;\n\t\tV -> V\n\tend.~n", [Field, Field]),
            case HookUpdate of
                [] -> write_file(Fd, "set_~p(V)-> put(~p, V).~n~n", [Field, Field]);
                _ -> write_file(Fd, "set_~p(V)-> put(~p, V), ~ts(~p, V).~n~n", [Field, Field, HookUpdate, Field])
            end,
            ok;
        _ ->
            write_file(Fd, "get_~p_~p()-> get(~p).~n", [Suffix, Field, Field]),
            write_file(Fd, "get_~p_~p_def(Def)->\n\tcase get(~p) of\n\t undefined -> Def;\n\tV -> V\n\tend.~n", [Suffix, Field, Field]),

            case HookUpdate of
                [] -> write_file(Fd, "set_~p_~p(V)-> put(~p, V).~n~n", [Suffix, Field, Field]);
                _ -> write_file(Fd, "set_~p_~p(V)-> put(~p, V), ~ts(~p, V).~n~n", [Suffix, Field, Field, HookUpdate, Field])
            end,
            ok
    end,
    ok;
field_fun(Fd, Field, Suffix, ExParam, HookUpdate) ->
    case Suffix of
        none ->
            write_file(Fd, "get_~p(~ts)-> get({~p,~ts}).~n", [Field, ExParam, Field, ExParam]),
            write_file(Fd, "get_~p_def(~ts, Def)->\n\tcase get({~p,~ts}) of\n\t\tundefined -> Def;\n\t\tV -> V\n\tend.~n", [Field, ExParam, Field, ExParam]),
            case HookUpdate of
                [] -> write_file(Fd, "set_~p(~ts, V)-> put({~p,~ts}, V).~n~n", [Field, ExParam, Field, ExParam]);
                _ -> write_file(Fd, "set_~p(~ts, V)-> put({~p,~ts}, V), ~ts(~ts, ~p, V).~n~n",
                        [Field, ExParam, Field, ExParam,  HookUpdate, ExParam, Field])
            end,
            ok;
        _ ->
            write_file(Fd, "get_~p_~p(~ts)-> get({~p,~ts}).~n", [ Suffix, Field, ExParam, Field, ExParam]),
            write_file(Fd, "get_~p_~p_def(~ts)->\n\tcase get({~p,~ts}) of\n\t\tundefined -> Def;\n\t\tV -> V\n\tend.~n", [ Suffix, Field, ExParam, Field, ExParam]),
            case HookUpdate of
                [] -> write_file(Fd, "set_~p_~p(~ts, V)-> put({~p,~ts}, V).~n~n", [Suffix, Field, ExParam, Field, ExParam]);
                _ -> write_file(Fd, "set_~p_~p(~ts, V)-> put({~p,~ts}, V), ~ts(~ts, ~p, V).~n~n",
                        [Suffix, Field, ExParam, Field, ExParam,  HookUpdate, ExParam, Field])
            end,
            ok
    end,

    ok.

del_fun(Fd, Suffix, FuncName, FieldList, []) ->
    case Suffix of
        none -> write_file(Fd, "~p()->\n", [FuncName]);
        _ ->   write_file(Fd, "~p_~p()->\n", [FuncName, Suffix])
    end,
    lists:foreach(
        fun(Field) ->
            write_file(Fd, "\terase(~p),\n", [Field])
        end, FieldList),
    write_file(Fd, "\tok.\n"),
    ok;
del_fun(Fd, Suffix, FuncName,  FieldList, ExParam) ->
    case Suffix of
        none -> write_file(Fd, "~p(~ts)->\n", [FuncName, ExParam]);
        _ ->    write_file(Fd, "~p_~p(~ts)->\n", [FuncName, Suffix, ExParam])
    end,
    lists:foreach(
        fun(Field) ->
            write_file(Fd, "\terase({~p, ~ts}),\n", [Field, ExParam])
        end, FieldList),
    write_file(Fd, "\tok.\n"),
    ok.

to_record(Fd, Suffix, FuncName, Record, FieldList, []) ->
    case Suffix of
        none -> write_file(Fd, "~p_record()->\n", [FuncName]);
        _ ->   write_file(Fd, "~p_~p_record()->\n", [FuncName, Suffix])
    end,
    write_file(Fd, "\t#~p{\n", [Record]),

    Str0 = [
        io_lib:format("\t\t~p = get_~p()", [Field, Field]) || Field <- FieldList],
    Str1 = string:join(Str0, ",\n"),
    write_file(Fd, "~ts\n", [Str1]),
    write_file(Fd, "\t}.\n"),
    ok;
to_record(Fd, Suffix, FuncName, Record, FieldList, ExParam) ->
    case Suffix of
        none -> write_file(Fd, "~p_record(~ts)->\n", [FuncName, ExParam]);
        _ ->   write_file(Fd, "~p_~p_record(~ts)->\n", [FuncName, Suffix, ExParam])
    end,
    write_file(Fd, "\t#~p{\n", [Record]),

    Str0 =
        case Suffix of
            none ->
                [io_lib:format("\t\t~p = get_~p(~ts)", [Field, Field, ExParam]) || Field <- FieldList];
            _ -> [io_lib:format("\t\t~p = get_~p_~p(~ts)", [Field, Suffix, Field, ExParam]) || Field <- FieldList]
        end,
    Str1 = string:join(Str0, ",\n"),
    write_file(Fd, "~ts\n", [Str1]),
    write_file(Fd, "\t}.\n"),
    ok.

%%-------------------------------------------------------------------
write_file(Fd, Fmt) ->
    file:write_file(Fd, Fmt, [append]).
%%-------------------------------------------------------------------
write_file(Fd, Fmt, Args) ->
    file:write_file(Fd, io_lib:format(Fmt, Args), [append]).
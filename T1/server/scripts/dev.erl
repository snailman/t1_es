#!/usr/bin/env escript
%%%-------------------------------------------------------------------
%%% @author mwh
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. 六 2017 9:32
%%%-------------------------------------------------------------------

%% 热更新
-define(ST_GS, 1).
-define(ST_CS, 2).
-define(ST_HTTP, 3).

-define(OP_REF, 	xref).
-define(OP_STATIC, 	static_check).
-define(OP_DEL_LOG, delLog).

main(_) ->
	menu(),
	ok.

menu() ->
	io:format(
		"~n##########################################################~n"
		"~n#selectServer to ~p ~n"
		"\t~p.gameserver~n"
		"\t~p.centerServer~n"
%%		"\t~p.httpserver~n"
		"\t0.exit~n"
		"~n##########################################################~n~n"
		, [Op, ?ST_GS, ?ST_CS]),
	InputNoStr = io:get_line("["++ atom_to_list(Op) ++"]:"),
	[T | _] = string:tokens(string_strip(InputNoStr, "\n"), " "),
	{IT, _} = string:to_integer(T),
	dispatchInput2(IT, Op).

dispatchInput2(0,_O)->
	ok;
dispatchInput2(S,O)->
	dispatchInput3(S, O),
	menu(O),
	ok.

dispatchInput3(?ST_GS, compile)->
	erlang:spawn(fun()-> os:cmd("cd ..\\app\\game\\scripts\\ && start compile.bat") end),
	ok;
dispatchInput3(?ST_GS, pkg)->
	erlang:spawn(fun()-> os:cmd("start escript.exe ps_gs.ers") end),
	ok;
dispatchInput3(?ST_CS, compile)->
	erlang:spawn(fun()-> os:cmd("cd ..\\app\\center\\scripts && start compile.bat") end),
	ok;
dispatchInput3(?ST_CS, pkg)->
	erlang:spawn(fun()-> os:cmd("start escript.exe ps_cs.ers") end),
	ok;
dispatchInput3(?ST_HTTP, compile)->
	erlang:spawn(fun()-> os:cmd("cd ..\\httpserver\\script && start ces_fast.bat") end),
	ok;
dispatchInput3(?ST_HTTP, pkg)->
	erlang:spawn(fun()-> os:cmd("start escript.exe ps_http.ers") end),
	ok;
dispatchInput3(_S,_O)->
	ok.

string_strip(Str, []) ->
	Str;
string_strip(Str, [CH | L]) ->
	string_strip(string:strip(Str, both, CH), L).
%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. 一月 2019 14:40
%%%-------------------------------------------------------------------
-author("Administrator").

-ifndef(FASTLOG_HRL).
-define(FASTLOG_HRL, true).


-define(DEFAULT_SINK, fastlog_sink).

-define(DISCARD_ACTIVE,  active).
-define(DISCARD_PASSIVE, passive).
-define(DISCARD_FORBID,  forbid).
-define(DISCARD_KEY, dicard_log).
-define(DISCARD_STDIO_KEY, dicard_stdio_log).
-define(MASTER_NODE, master_of_slave).

-endif.

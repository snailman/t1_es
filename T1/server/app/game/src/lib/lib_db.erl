%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. 五月 2018 14:22
%%%-------------------------------------------------------------------
-module(lib_db).
-author("mawenhong").
-include("logger.hrl").
-include("record.hrl").
-include("login.hrl").

%% API
-export([load_account_info/1]).

load_account_info(AccName) ->
    #r_account_info{account_name = AccName, account_id = 9999}.

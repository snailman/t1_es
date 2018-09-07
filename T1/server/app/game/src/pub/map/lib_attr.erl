%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 六月 2018 15:25
%%%-------------------------------------------------------------------
-module(lib_attr).
-author("mawenhong").
-include("logger.hrl").
-include("gs_common_rec.hrl").
-include("gs_map_unit_inc.hrl").
-include("netmsg.hrl").
-include("gs_combat_inc.hrl").
-include("pub_rec.hrl").
%% API
-export([
    calc/5, change_attr/1, change_attr/3, change_attr/5
]).



%%-------------------------------------------------------------------
change_attr(#r_player_change_prop_req{
    uid = Uid,
    add = AddList, multi = MultiList,
    add_del = AddList_Del, multi_del = MultiList_Del
}) ->
    do_change_attr(Uid, AddList, MultiList, AddList_Del, MultiList_Del),
    ok.

%%-------------------------------------------------------------------
change_attr(Uid, AddList, MultiList) ->
    do_change_attr(Uid, AddList, MultiList, [], []),
    ok.

change_attr(Uid, AddList, MultiList, AddList_Del, MultiList_Del) ->
    do_change_attr(Uid, AddList, MultiList, AddList_Del, MultiList_Del),
    ok.

do_change_attr(Uid, AddList, MultiList, AddList_Del, MultiList_Del) ->
    PropList = lib_unit_rw:get_attr(Uid),
    lib_attr:calc(PropList, AddList, MultiList, AddList_Del, MultiList_Del),
    ok.

calc(_PropList, _AddList, _MultiList, _AddList_Del, _MultiList_Del) ->
    ok.

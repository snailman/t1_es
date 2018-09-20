%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 六月 2018 14:48
%%%-------------------------------------------------------------------
-module(mod_buff).
-author("mawenhong").

-include("logger.hrl").
-include("pub_def.hrl").
-include("netmsg.hrl").
-include("gs_cache.hrl").
-include("gs_common_rec.hrl").

%% API
-export([add_buff/3, tick/1]).

%%-------------------------------------------------------------------
%%-------------------------------------------------------------------
add_buff(_Uid, _BuffId, _SrcUid) -> ok.

tick(#m_cache_map_object{uid = Uid}) ->
    BuffList = object_rw:get_buff_list_def(Uid, []),
    {_DelBuffList, NewBuffList} = tick_all_buff(BuffList, Uid, [], []),
    object_rw:set_buff_list(Uid, NewBuffList),
    %%

    ok.

tick_all_buff([], _Uid,  Delete, Continue) ->
    {Delete, Continue};
tick_all_buff([Buff | BuffList], Uid, Delete, Continue) ->
    case tick_one_buff(Uid, Buff) of
         delete  -> tick_all_buff(BuffList, Uid, [Buff | Delete], Continue);
         NewBuff -> tick_all_buff(BuffList, Uid, Delete, [NewBuff | Continue])
    end.

tick_one_buff(Uid, Buff) ->
    buff_effect:active(Uid, Buff),
    Buff;
tick_one_buff(_Uid, _Buff) ->
    delete.
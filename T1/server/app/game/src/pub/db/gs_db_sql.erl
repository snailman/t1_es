%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. 五月 2018 11:41
%%%-------------------------------------------------------------------
-module(gs_db_sql).
-author("mawenhong").

%% API
-export([sql/1]).

sql(load_serv_start) ->
    <<"call get_serv_start(?)">>;
sql(load_all_role_info) ->
    <<"select * from player where sid=? limit ?,?">>;
sql(load_all_role_info_cnt) ->
    <<"select count(*) from player where sid=?">>;
sql(load_acount) ->
    <<"select * from account where account_crc = ?">>;
sql(insert_acount) ->
   <<"insert account(aid,account,account_crc, plat_account, plat_name, device, imei, idfa, mac, create_time, version_hash_code)
     values(?,?,?,?,?,?,?,?,?,?,?);">>;
sql(insert_player) ->
    <<"insert player(aid, uid, sid, name, level, sex, camp, race, career, head,
    map_id, line, x, y, old_map_id, old_line, old_x, old_y, version)
    values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)">>;
sql(save_player) ->
    <<"update player set career=?, level=?, map_id=?,line=?,x=?,y=?,"
    "old_map_id=?, old_line=?, old_x=?, old_y=?, version = ? where uid=?">>;
sql(load_player) ->
    <<"select * from player where uid = ?">>;
sql(load_player_list) ->
    <<"select * from player where aid = ?">>;
sql(_) ->
    <<"">>.
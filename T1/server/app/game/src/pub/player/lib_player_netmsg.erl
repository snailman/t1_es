%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 五月 2018 16:06
%%%-------------------------------------------------------------------
-module(lib_player_netmsg).
-author("mawenhong").
-include("logger.hrl").
-include("netmsg.hrl").
-include("gs_map_inc.hrl").

-include("gs_player_status.hrl").
-include("gs_common_rec.hrl").
-include("gs_cache_inc.hrl").


%% API
-export([handle/1]).

handle(#pk_U2GS_ExitGame{}) ->
    lib_player_pub:stop(client_req_exit),
    ok;
handle(#pk_U2GS_HearBeat{}) ->
    lib_player_pub:send_net_msg(#pk_GS2U_HearBeat{now = misc_time:localtime_seconds()}),
    ok;
handle(#pk_U2GS_Login_Normal{
    platformName = PlatName,
    platformAccount = PlatAccount,
    sign = Token
}) ->
    ?DEBUG("mod_login:login_"),
    lib_player_rw:set_status(?PS_VERIFY),
    gs_login_interface:login_(#r_login_req{
        plat_name = PlatName, plat_account_name = PlatAccount,
        access_token = Token, player_pid = self()
    }),
    ok;
handle(#pk_U2GS_RequestCreatePlayer{
    name = Name, camp = Camp,
    career = Career, race = Race,
    sex = Sex, head = Head
}) ->
    BornMid = gs_map_creator_interface:born_map_id(),
    V = gs_map_creator_interface:born_map_pos(),
    lib_player_priv:create_player_(#r_create_player_req{
       name = Name, camp = Camp, career = Career, race = Race, sex = Sex,
        head = Head, mid = BornMid, x = vector3:x(V), y = vector3:z(V), sid = gs_conf:get_sid()
    }),
    ok;
handle(#pk_U2GS_SelPlayerEnterGame{uid = Uid}) ->
    lib_player_priv:select_player(Uid),
    ok;
handle(#pk_U2GS_GetPlayerInitData{}) ->
%%    lib_player_base:send_init_data(),
    ok;
handle(#pk_U2GS_PlayerWalk{dst_x = DX, dst_y = DY}) ->
    Tar = vector3:new(DX, 0, DY),
    lib_player_base:start_walk(Tar),
    ok;
handle(#pk_U2GS_PlayerStopWalk{cur_x = X, cur_y = Y}) ->
    Pos = vector3:new(X, 0, Y),
    lib_player_base:stop_move(Pos),
    ok;
handle(#pk_U2GS_UseSkill{tar_uid = Tar, x = X, y = Y, skill_id = SkillId, serial = Serial}) ->
    Pos = vector3:new(X, 0, Y),
    lib_player_combat:use_skill(SkillId, Tar, Pos, Serial),
    ok;
handle(#pk_U2GS_SkillInterrupt{}) ->
    ok;
handle(#pk_U2GS_ChangeMap{map_id = MapId, x = X, y = Y}) ->
    Pos = vector3:new(X, 0, Y),
    ?DEBUG("### client request change to map ~p",[MapId]),
    lib_player_pub:change_map_(MapId, 0, Pos),
    ok;
handle(_Msg) ->
%%    ?DEBUG("~p", [Msg]),
    ok.
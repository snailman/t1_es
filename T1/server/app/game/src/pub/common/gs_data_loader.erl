%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 八月 2018 11:34
%%%-------------------------------------------------------------------
-module(gs_data_loader).
-behavior(data_loader).
-author("mawenhong").

-include("logger.hrl").
-include("pub_rec.hrl").
-include("gs_ps_def.hrl").

-export([
    start_link/0,  %% 启动进程并且指定进程名字
    task_list/0,  %% 返回task list
    info/1,    %% 处理加载进程发回的消息
    task_all_done/0 %% 用于外部检查任务是否全部完成
]).

-export([
    show_todo/0, %% 输出进行中的任务列表
    show_all/0   %% 输出所有任务列表
]).

%%-------------------------------------------------------------------
%% 通用部分
start_link() -> data_loader:start_link(?GS_LOADER_OTP, ?MODULE).
task_all_done() -> data_loader:task_all_done(?GS_LOADER_OTP).
show_todo() -> data_loader:show_todo(?GS_LOADER_OTP).
show_all() -> data_loader:show_all(?GS_LOADER_OTP).
%%-------------------------------------------------------------------
%%-------------------------------------------------------------------
%% 任务列表
task_list() ->
    [
        ?LOADER_TASK_GROUP(1, serv_start, ?TASK_SEQ, seq_base_load()),
        ?LOADER_TASK_GROUP(2, load_all_role_info, ?TASK_PARALLEL, parallel_load())
    ].

seq_base_load() ->
    Sid = gs_conf:get_sid(),
    [
        ?LOADER_TASK(serv_start,            {gs_db_interface, action_public_, [1, serv_start, Sid]})
    ].

parallel_load() ->
    Sid = gs_conf:get_sid(),
    [
        ?LOADER_TASK(load_all_role_info,    {gs_db_interface, action_data_,   [1, load_all_role_info, Sid]})
    ].


%%-------------------------------------------------------------------
%% 消息处理
info({serv_start_ack, RunNo}) ->
    try
        gs_conf:set_run_no(RunNo),
        AreaId = gs_conf:get_area(),
        Sid = gs_conf:get_sid(),
        uid_gen:init(AreaId, Sid, RunNo),
        data_loader:task_done(?GS_LOADER_OTP, serv_start)
    catch _:Err:ST ->
        misc:halt("save serv_start failed, error ~p, current stack ~p", [Err, ST])
    end,
    ok;
info({load_all_role_info_ack, List}) ->
    lists:foreach(
        fun(Player) -> gs_cache_interface:add_player_pub(Player) end, List),
    ok;
info(load_all_role_info_ack_end) ->
    data_loader:task_done(?GS_LOADER_OTP, load_all_role_info),
    ok;
info(Info) ->
    ?ERROR("undeal info ~w", [Info]).
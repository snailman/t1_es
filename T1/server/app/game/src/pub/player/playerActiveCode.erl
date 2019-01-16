%%%-------------------------------------------------------------------
%%% @author Zhangdong
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%% 激活码领取
%%% @end
%%% Created : 02. 九月 2014 18:01
%%%-------------------------------------------------------------------
-module(playerActiveCode).
-author("Zhangdong").
-include("playerPrivate.hrl").

%% 请求领取激活码CD
-define(RequestActiveCodeCD, 5).
%% 普通激活码，同批次，一个角色只能使用一个。
-define(NormalActiveCode, 0).
%% 万能码参数
-define(AllPowerfulCodeParam, 1).
%% 实体码参数（相对于默认0激活码，同一批次可以多次使用）
%% 该类型一般不通过GM后台生成，而是手动生成导入数据库
%% 由发行方使用该码打印在实体商品上进行活动
-define(GoodsCodeParam, 2).

%% API
-export([
	getActiveCodeRequest/1,
	getActiveCodeRequestAck/1,
	updateActiveCodeAck/5
]).

-spec getActiveCodeRequest(ActiveCode::string()) -> ok.
getActiveCodeRequest(ActiveCode)->
	case variant:getGlobalBitVariant(?Setting_GlobalBitVarReadOnly_Hide_ActiveCode) of
		true ->
			Len = erlang:length(ActiveCode),
			case Len >= 4 andalso Len =< 16 of
				true ->
					IsTimeTooShort =
						case playerState:getLastGetActiveCodeTime() of
							undefined ->
								playerState:setLastGetActiveCodeTime(misc_time:utc_seconds()),
								false;
							LastGetActiveCodeTime->
								case (misc_time:utc_seconds() - LastGetActiveCodeTime) < ?RequestActiveCodeCD of
									true->
										true;
									_->
										false
								end
						end,
					case IsTimeTooShort of
						true->
							?ERROR("getActiveCodeRequest player ~p too fast", [playerState:getRoleID()]),
							playerMsg:sendTipsErrorCodeMsg(?ErrorCode_ActiveCode_Fail_TooFast),
							skip;
						_->
							gsSendMsg:sendMsg2DBServer(getActiveCodeRequest, playerState:getAccountID(), {ActiveCode, playerState:getRoleID()})
					end;
				_ ->
					playerMsg:sendTipsErrorCodeMsg(?ErrorCode_ActiveCode_Fail_NotExist)
			end;
		_ ->
			playerMsg:sendTipsErrorCodeMsg(?ErrorCode_SystemNotOpen)
	end,
	ok.

-spec getActiveCodeRequestAck({{ActiveCode::string(), RoleID::uint64()}, GetActiveCodeInfo::#recActiveCodeInfo{}}) -> ok.
getActiveCodeRequestAck(
	{{ActiveCode, RoleID},
		#recActiveCodeInfo{
			id = ID,
			item_id = Item_ID,
			item_count = Item_Count,
			param = Param,
			valide_time_begin = BeginTime,
			valide_time_end = EndTime,
			valide_server_id_list = ServerList,
			get_player_id = GetPlayerID,
			get_count = GetCount
		}})->
	?INFO("RoleID[~p] ActiveCode[~ts] GetActiveCodeInfo.id[~p] [~p,~p]", [RoleID, ActiveCode, ID, Param, GetCount]),

	if
		ID < 1 ->
			%%该激活码不存在
			playerMsg:sendTipsErrorCodeMsg(?ErrorCode_ActiveCode_Fail_NotExist);
		GetPlayerID /= 0 ->
			%%已经有玩家使用过该激活码
			playerMsg:sendTipsErrorCodeMsg(?ErrorCode_ActiveCode_Fail_Used);
		GetCount > 0 andalso Param /= ?GoodsCodeParam ->
			%%该批次的激活码玩家已经领取过了，只有实业码可以使用多个
			playerMsg:sendTipsErrorCodeMsg(?ErrorCode_ActiveCode_Fail_BatchUsed);
		true ->
			IsTimeOut =
				case (BeginTime =/= undefined) andalso (EndTime =/= undefined) of
					true->
						Now = misc_time:getLocalDateTime,
						{_,BeginTime2} = BeginTime,
						{_,EndTime2} = EndTime,
						{BeginDay,_} = calendar:time_difference(BeginTime2, Now),
						{EndDay,_} = calendar:time_difference(Now, EndTime2),
						(BeginDay >= 0) andalso (EndDay >= 0);
					false->
						true
				end,
			case IsTimeOut of
				false ->
					%%激活码已经过期
					playerMsg:sendTipsErrorCodeMsg(?ErrorCode_ActiveCode_Fail_TimeOut);
				_ ->
					ServerList2 = binary_to_list(ServerList),
					IsLocalRequest =
						case ServerList2 =:= "[]" of
							true->
								true;
							false->
								ServerList3 = misc:string_to_term(ServerList2),
								lists:member(gsMainLogic:getDBID4GS(), ServerList3)
						end,
					case IsLocalRequest of
						false ->
							%%非本服可以领取
							playerMsg:sendTipsErrorCodeMsg(?ErrorCode_ActiveCode_Fail_ServerID);
						_ ->
							case Param of
								?AllPowerfulCodeParam ->
									%% 如果是万能码，同批次，不同的码，都可以使用
									%% 已经领取的万能码
									EvenGetACIDList =
										case playerState2:getPlayerDataElement(#rec_playerdata.activeCode4Many) of
											undefined -> [];
											L -> L
										end,
									case lists:member(ID, EvenGetACIDList) of
										true ->
											playerMsg:sendTipsErrorCodeMsg(?ErrorCode_ActiveCode_Fail_Used);
										_ ->
											%% 设置玩家已经领取的万用礼包码
											playerState2:setPlayerDataElement(#rec_playerdata.activeCode4Many, [ID|EvenGetACIDList]),
											%% 保存
											gsSendMsg:sendMsg2DBServer(saveActiveCode4Role, playerState:getAccountID(),
												{
													ID,
													playerState:getRoleID(),
													playerState:getAccountID(),
													playerState:getPlateformAccountID(),
													playerState:getPlateformID(),
													Item_ID,
													Item_Count
												})
									end;
								_ ->
									%% 可以领取了，通知数据库更新，根据数据库更新结果再给物品
									gsSendMsg:sendMsg2DBServer(updateActiveCode, playerState:getAccountID(),
										{
											ActiveCode,
											playerState:getRoleID(),
											playerState:getAccountID(),
											playerState:getPlateformAccountID(),
											playerState:getPlateformID(),
											Item_ID,
											Item_Count
										})
							end
					end
			end
	end,
	ok.

-spec updateActiveCodeAck(ActiveCode, RoleID, Ret, Item_ID, Item_Count) -> ok
	when ActiveCode::string(), RoleID::uint(), Ret::uint(), Item_ID::uint(), Item_Count::uint().
updateActiveCodeAck(ActiveCode, RoleID, Ret, Item_ID, Item_Count)->
	?INFO("updateActiveCodeAck [~p]", [{ActiveCode, RoleID, Ret, Item_ID, Item_Count}]),
	Ret2 = case erlang:is_binary(Ret) of
			   true -> binary_to_list(Ret);
			   _ -> Ret
		   end,
	Ret3 = case erlang:is_list(Ret2) of
			   true -> list_to_integer(Ret2);
			   _ -> Ret2
		   end,
	case Ret3 >= 0 of
		true ->
			%% 数据库更新成功，给物品
			case getCfg:getCfgPStack(cfg_item, Item_ID) of
				#itemCfg{maxAmount = MaxAmount} when Item_Count =< MaxAmount ->
					PLog = #recPLogTSItem{
						old = 0,
						new = Item_Count,
						change = Item_Count,
						target = ?PLogTS_PlayerSelf,
						source = ?PLogTS_ActiveCode,
						gold = 0,
						goldtype = 0,
						changReason = ?ItemSourceActiveCode,
						reasonParam = 0
					},
					playerPackage:addGoodsAndMail(Item_ID, Item_Count, true, 0, PLog),
					playerMsg:sendTipsErrorCodeMsg(?ErrorCode_ActiveCode_Succ),
					Msg = #pk_GS2U_ShowGainGoodsOrCoinsInfo{
						gainReason = "",
						listcoins = [],
						listGoods = [#pk_OneGoodsInfo{
								itemID = Item_ID,
								itemNum = Item_Count,
								quality = 0,
								isBind = 1}]},
					playerMsg:sendNetMsg(Msg);
				_->
					%% 错误的id
					playerMsg:sendTipsErrorCodeMsg(?ErrorCode_ActiveCode_Fail_Exception)
			end;
		false ->
			%% 数据库更新失败，只有一种可能，刚检测过的激活码被其他人领取了
			playerMsg:sendTipsErrorCodeMsg(?ErrorCode_ActiveCode_Fail_Exception)
	end,
	ok.

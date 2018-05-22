%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 五月 2018 14:10
%%%-------------------------------------------------------------------
-module(lib_obj).
-author("mawenhong").

-include("logger.hrl").
-include("map.hrl").
-include("map_obj.hrl").

%% API

-export([obj_type/1]).
-export([is_player/1, is_monster/1, is_pet/1, is_npc/1]).

%%%-------------------------------------------------------------------
obj_type(Obj) -> Obj#r_map_obj.type.

%%%-------------------------------------------------------------------
is_npc(Obj)     -> Obj#r_map_obj.type =:= ?OBJ_NPC.
is_pet(Obj)     -> Obj#r_map_obj.type =:= ?OBJ_PET.
is_player(Obj)  -> Obj#r_map_obj.type =:= ?OBJ_USR.
is_monster(Obj) -> Obj#r_map_obj.type =:= ?OBJ_MON.
%%%-------------------------------------------------------------------


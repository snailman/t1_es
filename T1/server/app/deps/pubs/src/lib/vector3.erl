%%%-------------------------------------------------------------------
%%% @author mawenhong
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. 五月 2018 10:41
%%%-------------------------------------------------------------------
-module(vector3).
-author("mawenhong").

-include("vector3.hrl").
%% API
-export([new/3]).
-export([x/1,y/1,z/1]).
-export([add/2]).
-export([subtract/2]).
-export([multi/2]).
-export([divi/2]).
-export([behind/3]).
-export([front/3]).
-export([is_behind/3]). %% src 是否在目标反面
-export([is_front/3]). %% src 是否在目标正面
-export([normalized/1]).
-export([dist/1, dist_sq/1]).
-export([dist/2, dist_sq/2]).
-export([linear_lerp/3]).

new(X, Y, Z) ->
    #vector3{x = float(X), y = float(Y), z = float(Z)}.

x(V) -> V#vector3.x.
y(V) -> V#vector3.y.
z(V) -> V#vector3.z.

%%
add(V1, V2) ->
    #vector3{x = X1, y = Y1, z = Z1} = V1,
    #vector3{x = X2, y = Y2, z = Z2} = V2,
    #vector3{x = X1 + X2, y = Y1 + Y2, z = Z1 + Z2}.

%%
subtract(V1, V2) ->
    #vector3{x = X1, y = Y1, z = Z1} = V1,
    #vector3{x = X2, y = Y2, z = Z2} = V2,
    #vector3{x = X1 - X2, y = Y1 - Y2, z = Z1 - Z2}.

%%
multi(V, Factor) ->
    #vector3{x = X, y = Y, z = Z} = V,
    #vector3{x = X * Factor, y = Y * Factor, z = Z * Factor}.

%%
divi(_V, Factor) when Factor == 0 ->
    #vector3{};
divi(V, Factor) ->
    #vector3{x = X, y = Y, z = Z} = V,
    #vector3{x = X / Factor, y = Y / Factor, z = Z / Factor}.

%%
normalized(V) ->
    Len = vector3:dist(V),
    case Len == 0 of
        true -> V;
        _ ->
            #vector3{x = X, y = Y, z = Z} = V,
            #vector3{x = X / Len, y = Y / Len, z = Z / Len}
    end.

%%
is_behind(Src, Dst, DstFace) ->
    %
    #vector3{x = X2, y = Y2, z = Z2} = DstFace,
    % dir
    #vector3{x = X1, y = Y1, z = Z1} = vector3:subtract(Src, Dst),
    % |A|*|B|*cosθ
    (X1 * X2 + Y1 * Y2 + Z1 * Z2) < 0.
%%
behind(Src, Dst, Dist) ->
    % dir
    Dir = vector3:subtract(Src, Dst),
    % normalize
    Normal = vector3:normalized(Dir),
    % *
    Delta = vector3:multi(Normal, -Dist),
    % +
    vector3:add(Src, Delta).

%%
front(Src, Dst, Dist) ->
    % dir
    Dir = vector3:subtract(Src, Dst),
    % normalize
    Normal = vector3:normalized(Dir),
    % *
    Delta = vector3:multi(Normal, Dist),
    % +
    vector3:add(Src, Delta).

%%
is_front(Src, Dst, DstFace) ->
    %
    #vector3{x = X2, y = Y2, z = Z2} = DstFace,
    % dir
    #vector3{x = X1, y = Y1, z = Z1} = vector3:subtract(Src, Dst),
    % |A|*|B|*cosθ
    (X1 * X2 + Y1 * Y2 + Z1 * Z2) >= 0.

%%
dist(V) ->
    Sq = vector3:dist_sq(V),
    math:sqrt(Sq).

dist_sq(V) ->
    #vector3{x = X, y = Y, z = Z} = V,
    X * X + Y * Y + Z * Z.

%%
dist(V1, V2) ->
    Sq = vector3:dist_sq(V1, V2),
    math:sqrt(Sq).

%%
dist_sq(V1, V2) ->
    #vector3{x = X1, y = Y1, z = Z1} = V1,
    #vector3{x = X2, y = Y2, z = Z2} = V2,
    X = X1 - X2, Y = Y1 - Y2, Z = Z1 - Z2,
    X * X + Y * Y + Z * Z.

%%
linear_lerp(Src, Dst, Factor) ->
    #vector3{x = X1, y = Y1, z = Z1} = Src,
    #vector3{x = X2, y = Y2, z = Z2} = Dst,
    #vector3{
        x = X1 * (1 - Factor) + X2 * Factor,
        y = Y1 * (1 - Factor) + Y2 * Factor,
        z = Z1 * (1 - Factor) + Z2 * Factor
    }.

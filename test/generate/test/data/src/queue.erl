-file("queue.erl", 1).

-module(queue).

-export([new/0, is_queue/1, is_empty/1, len/1, to_list/1, from_list/1, member/2]).

-export([in/2, in_r/2, out/1, out_r/1]).

-export([get/1, get_r/1, peek/1, peek_r/1, drop/1, drop_r/1]).

-export([reverse/1, join/2, split/2, filter/2]).

-export([cons/2, head/1, tail/1, snoc/2, last/1, daeh/1, init/1, liat/1]).

-export_type([queue/0, queue/1]).

-export([lait/1]).

-deprecated([{lait,1,"use queue:liat/1 instead"}]).

-opaque(queue(Item)::{[Item],[Item]}).

-type(queue()::queue(_)).

-spec(new() -> queue()).

new() ->
    {[],[]}.

-spec(is_queue(Term::term()) -> boolean()).

is_queue({R,F})
    when is_list(R),
    is_list(F)->
    true;
is_queue(_) ->
    false.

-spec(is_empty(Q::queue()) -> boolean()).

is_empty({[],[]}) ->
    true;
is_empty({In,Out})
    when is_list(In),
    is_list(Out)->
    false;
is_empty(Q) ->
    error(badarg,[Q]).

-spec(len(Q::queue()) -> non_neg_integer()).

len({R,F})
    when is_list(R),
    is_list(F)->
    length(R) + length(F);
len(Q) ->
    error(badarg,[Q]).

-spec(to_list(Q::queue(Item)) -> [Item]).

to_list({In,Out})
    when is_list(In),
    is_list(Out)->
    Out ++ lists:reverse(In,[]);
to_list(Q) ->
    error(badarg,[Q]).

-spec(from_list(L::[Item]) -> queue(Item)).

from_list(L)
    when is_list(L)->
    f2r(L);
from_list(L) ->
    error(badarg,[L]).

-spec(member(Item,Q::queue(Item)) -> boolean()).

member(X,{R,F})
    when is_list(R),
    is_list(F)->
    lists:member(X,R) orelse lists:member(X,F);
member(X,Q) ->
    error(badarg,[X, Q]).

-spec(in(Item,Q1::queue(Item)) -> Q2::queue(Item)).

in(X,{[_] = In,[]}) ->
    {[X],In};
in(X,{In,Out})
    when is_list(In),
    is_list(Out)->
    {[X| In],Out};
in(X,Q) ->
    error(badarg,[X, Q]).

-spec(in_r(Item,Q1::queue(Item)) -> Q2::queue(Item)).

in_r(X,{[],[_] = F}) ->
    {F,[X]};
in_r(X,{R,F})
    when is_list(R),
    is_list(F)->
    {R,[X| F]};
in_r(X,Q) ->
    error(badarg,[X, Q]).

-spec(out(Q1::queue(Item)) -> {{value,Item},Q2::queue(Item)}|{empty,Q1::queue(Item)}).

out({[],[]} = Q) ->
    {empty,Q};
out({[V],[]}) ->
    {{value,V},{[],[]}};
out({[Y| In],[]}) ->
    [V| Out] = lists:reverse(In,[]),
    {{value,V},{[Y],Out}};
out({In,[V]})
    when is_list(In)->
    {{value,V},r2f(In)};
out({In,[V| Out]})
    when is_list(In)->
    {{value,V},{In,Out}};
out(Q) ->
    error(badarg,[Q]).

-spec(out_r(Q1::queue(Item)) -> {{value,Item},Q2::queue(Item)}|{empty,Q1::queue(Item)}).

out_r({[],[]} = Q) ->
    {empty,Q};
out_r({[],[V]}) ->
    {{value,V},{[],[]}};
out_r({[],[Y| Out]}) ->
    [V| In] = lists:reverse(Out,[]),
    {{value,V},{In,[Y]}};
out_r({[V],Out})
    when is_list(Out)->
    {{value,V},f2r(Out)};
out_r({[V| In],Out})
    when is_list(Out)->
    {{value,V},{In,Out}};
out_r(Q) ->
    error(badarg,[Q]).

-spec(get(Q::queue(Item)) -> Item).

get({[],[]} = Q) ->
    error(empty,[Q]);
get({R,F})
    when is_list(R),
    is_list(F)->
    get(R,F);
get(Q) ->
    error(badarg,[Q]).

-spec(get(list(),list()) -> term()).

get(R,[H| _])
    when is_list(R)->
    H;
get([H],[]) ->
    H;
get([_| R],[]) ->
    lists:last(R).

-spec(get_r(Q::queue(Item)) -> Item).

get_r({[],[]} = Q) ->
    error(empty,[Q]);
get_r({[H| _],F})
    when is_list(F)->
    H;
get_r({[],[H]}) ->
    H;
get_r({[],[_| F]}) ->
    lists:last(F);
get_r(Q) ->
    error(badarg,[Q]).

-spec(peek(Q::queue(Item)) -> empty|{value,Item}).

peek({[],[]}) ->
    empty;
peek({R,[H| _]})
    when is_list(R)->
    {value,H};
peek({[H],[]}) ->
    {value,H};
peek({[_| R],[]}) ->
    {value,lists:last(R)};
peek(Q) ->
    error(badarg,[Q]).

-spec(peek_r(Q::queue(Item)) -> empty|{value,Item}).

peek_r({[],[]}) ->
    empty;
peek_r({[H| _],F})
    when is_list(F)->
    {value,H};
peek_r({[],[H]}) ->
    {value,H};
peek_r({[],[_| R]}) ->
    {value,lists:last(R)};
peek_r(Q) ->
    error(badarg,[Q]).

-spec(drop(Q1::queue(Item)) -> Q2::queue(Item)).

drop({[],[]} = Q) ->
    error(empty,[Q]);
drop({[_],[]}) ->
    {[],[]};
drop({[Y| R],[]}) ->
    [_| F] = lists:reverse(R,[]),
    {[Y],F};
drop({R,[_]})
    when is_list(R)->
    r2f(R);
drop({R,[_| F]})
    when is_list(R)->
    {R,F};
drop(Q) ->
    error(badarg,[Q]).

-spec(drop_r(Q1::queue(Item)) -> Q2::queue(Item)).

drop_r({[],[]} = Q) ->
    error(empty,[Q]);
drop_r({[],[_]}) ->
    {[],[]};
drop_r({[],[Y| F]}) ->
    [_| R] = lists:reverse(F,[]),
    {R,[Y]};
drop_r({[_],F})
    when is_list(F)->
    f2r(F);
drop_r({[_| R],F})
    when is_list(F)->
    {R,F};
drop_r(Q) ->
    error(badarg,[Q]).

-spec(reverse(Q1::queue(Item)) -> Q2::queue(Item)).

reverse({R,F})
    when is_list(R),
    is_list(F)->
    {F,R};
reverse(Q) ->
    error(badarg,[Q]).

-spec(join(Q1::queue(Item),Q2::queue(Item)) -> Q3::queue(Item)).

join({R,F} = Q,{[],[]})
    when is_list(R),
    is_list(F)->
    Q;
join({[],[]},{R,F} = Q)
    when is_list(R),
    is_list(F)->
    Q;
join({R1,F1},{R2,F2})
    when is_list(R1),
    is_list(F1),
    is_list(R2),
    is_list(F2)->
    {R2,F1 ++ lists:reverse(R1,F2)};
join(Q1,Q2) ->
    error(badarg,[Q1, Q2]).

-spec(split(N::non_neg_integer(),Q1::queue(Item)) -> {Q2::queue(Item),Q3::queue(Item)}).

split(0,{R,F} = Q)
    when is_list(R),
    is_list(F)->
    {{[],[]},Q};
split(N,{R,F} = Q)
    when is_integer(N),
    N >= 1,
    is_list(R),
    is_list(F)->
    Lf = length(F),
    if N < Lf ->
        [X| F1] = F,
        split_f1_to_r2(N - 1,R,F1,[],[X]);N > Lf ->
        Lr = length(R),
        M = Lr - (N - Lf),
        if M < 0 ->
            error(badarg,[N, Q]);M > 0 ->
            [X| R1] = R,
            split_r1_to_f2(M - 1,R1,F,[X],[]);true ->
            {Q,{[],[]}} end;true ->
        {f2r(F),r2f(R)} end;
split(N,Q) ->
    error(badarg,[N, Q]).

split_f1_to_r2(0,R1,F1,R2,F2) ->
    {{R2,F2},{R1,F1}};
split_f1_to_r2(N,R1,[X| F1],R2,F2) ->
    split_f1_to_r2(N - 1,R1,F1,[X| R2],F2).

split_r1_to_f2(0,R1,F1,R2,F2) ->
    {{R1,F1},{R2,F2}};
split_r1_to_f2(N,[X| R1],F1,R2,F2) ->
    split_r1_to_f2(N - 1,R1,F1,R2,[X| F2]).

-spec(filter(Fun,Q1::queue(Item)) -> Q2::queue(Item) when Fun::fun((Item) -> boolean()|[Item])).

filter(Fun,{R0,F0})
    when is_function(Fun,1),
    is_list(R0),
    is_list(F0)->
    F = filter_f(Fun,F0),
    R = filter_r(Fun,R0),
    if R =:= [] ->
        f2r(F);F =:= [] ->
        r2f(R);true ->
        {R,F} end;
filter(Fun,Q) ->
    error(badarg,[Fun, Q]).

filter_f(_,[]) ->
    [];
filter_f(Fun,[X| F]) ->
    case Fun(X) of
        true->
            [X| filter_f(Fun,F)];
        false->
            filter_f(Fun,F);
        L
            when is_list(L)->
            L ++ filter_f(Fun,F)
    end.

filter_r(_,[]) ->
    [];
filter_r(Fun,[X| R0]) ->
    R = filter_r(Fun,R0),
    case Fun(X) of
        true->
            [X| R];
        false->
            R;
        L
            when is_list(L)->
            lists:reverse(L,R)
    end.

-spec(cons(Item,Q1::queue(Item)) -> Q2::queue(Item)).

cons(X,Q) ->
    in_r(X,Q).

-spec(head(Q::queue(Item)) -> Item).

head({[],[]} = Q) ->
    error(empty,[Q]);
head({R,F})
    when is_list(R),
    is_list(F)->
    get(R,F);
head(Q) ->
    error(badarg,[Q]).

-spec(tail(Q1::queue(Item)) -> Q2::queue(Item)).

tail(Q) ->
    drop(Q).

-spec(snoc(Q1::queue(Item),Item) -> Q2::queue(Item)).

snoc(Q,X) ->
    in(X,Q).

-spec(daeh(Q::queue(Item)) -> Item).

daeh(Q) ->
    get_r(Q).

-spec(last(Q::queue(Item)) -> Item).

last(Q) ->
    get_r(Q).

-spec(liat(Q1::queue(Item)) -> Q2::queue(Item)).

liat(Q) ->
    drop_r(Q).

-spec(lait(Q1::queue(Item)) -> Q2::queue(Item)).

lait(Q) ->
    drop_r(Q).

-spec(init(Q1::queue(Item)) -> Q2::queue(Item)).

init(Q) ->
    drop_r(Q).

-compile({inline,[{r2f,1}, {f2r,1}]}).

r2f([]) ->
    {[],[]};
r2f([_] = R) ->
    {[],R};
r2f([X, Y]) ->
    {[X],[Y]};
r2f(List) ->
    {FF,RR} = lists:split(length(List) div 2 + 1,List),
    {FF,lists:reverse(RR,[])}.

f2r([]) ->
    {[],[]};
f2r([_] = F) ->
    {F,[]};
f2r([X, Y]) ->
    {[Y],[X]};
f2r(List) ->
    {FF,RR} = lists:split(length(List) div 2 + 1,List),
    {lists:reverse(RR,[]),FF}.
-file("dict.erl", 1).

-module(dict).

-export([new/0, is_key/2, to_list/1, from_list/1, size/1, is_empty/1]).

-export([fetch/2, find/2, fetch_keys/1, erase/2, take/2]).

-export([store/3, append/3, append_list/3, update/3, update/4, update_counter/3]).

-export([fold/3, map/2, filter/2, merge/3]).

-export_type([dict/0, dict/2]).

-type(segs(_Key,_Value)::tuple()).

-record(dict,{size = 0::non_neg_integer(),n = 16::non_neg_integer(),maxn = 16::non_neg_integer(),bso = 16 div 2::non_neg_integer(),exp_size = 16 * 5::non_neg_integer(),con_size = 16 * 3::non_neg_integer(),empty::tuple(),segs::segs(_,_)}).

-type(dict()::dict(_,_)).

-opaque(dict(Key,Value)::#dict{segs::segs(Key,Value)}).

-spec(new() -> dict()).

new() ->
    Empty = mk_seg(16),
    #dict{empty = Empty,segs = {Empty}}.

-spec(is_key(Key,Dict) -> boolean() when Dict::dict(Key,Value::term())).

is_key(Key,D) ->
    Slot = get_slot(D,Key),
    Bkt = get_bucket(D,Slot),
    find_key(Key,Bkt).

find_key(K,[[K| _Val]| _]) ->
    true;
find_key(K,[_| Bkt]) ->
    find_key(K,Bkt);
find_key(_,[]) ->
    false.

-spec(to_list(Dict) -> List when Dict::dict(Key,Value),List::[{Key,Value}]).

to_list(D) ->
    fold(fun (Key,Val,List)->
        [{Key,Val}| List] end,[],D).

-spec(from_list(List) -> Dict when Dict::dict(Key,Value),List::[{Key,Value}]).

from_list(L) ->
    lists:foldl(fun ({K,V},D)->
        store(K,V,D) end,new(),L).

-spec(size(Dict) -> non_neg_integer() when Dict::dict()).

size(#dict{size = N})
    when is_integer(N),
    N >= 0->
    N.

-spec(is_empty(Dict) -> boolean() when Dict::dict()).

is_empty(#dict{size = N}) ->
    N =:= 0.

-spec(fetch(Key,Dict) -> Value when Dict::dict(Key,Value)).

fetch(Key,D) ->
    Slot = get_slot(D,Key),
    Bkt = get_bucket(D,Slot),
    try fetch_val(Key,Bkt)
        catch
            throw:badarg->
                error(badarg,[Key, D]) end.

fetch_val(K,[[K| Val]| _]) ->
    Val;
fetch_val(K,[_| Bkt]) ->
    fetch_val(K,Bkt);
fetch_val(_,[]) ->
    throw(badarg).

-spec(find(Key,Dict) -> {ok,Value}|error when Dict::dict(Key,Value)).

find(Key,D) ->
    Slot = get_slot(D,Key),
    Bkt = get_bucket(D,Slot),
    find_val(Key,Bkt).

find_val(K,[[K| Val]| _]) ->
    {ok,Val};
find_val(K,[_| Bkt]) ->
    find_val(K,Bkt);
find_val(_,[]) ->
    error.

-spec(fetch_keys(Dict) -> Keys when Dict::dict(Key,Value::term()),Keys::[Key]).

fetch_keys(D) ->
    fold(fun (Key,_Val,Keys)->
        [Key| Keys] end,[],D).

-spec(erase(Key,Dict1) -> Dict2 when Dict1::dict(Key,Value),Dict2::dict(Key,Value)).

erase(Key,D0) ->
    Slot = get_slot(D0,Key),
    {D1,Dc} = on_bucket(fun (B0)->
        erase_key(Key,B0) end,D0,Slot),
    maybe_contract(D1,Dc).

erase_key(Key,[[Key| _Val]| Bkt]) ->
    {Bkt,1};
erase_key(Key,[E| Bkt0]) ->
    {Bkt1,Dc} = erase_key(Key,Bkt0),
    {[E| Bkt1],Dc};
erase_key(_,[]) ->
    {[],0}.

-spec(take(Key,Dict) -> {Value,Dict1}|error when Dict::dict(Key,Value),Dict1::dict(Key,Value),Key::term(),Value::term()).

take(Key,D0) ->
    Slot = get_slot(D0,Key),
    case on_bucket(fun (B0)->
        take_key(Key,B0) end,D0,Slot) of
        {D1,{Value,Dc}}->
            {Value,maybe_contract(D1,Dc)};
        {_,error}->
            error
    end.

take_key(Key,[[Key| Val]| Bkt]) ->
    {Bkt,{Val,1}};
take_key(Key,[E| Bkt0]) ->
    {Bkt1,Res} = take_key(Key,Bkt0),
    {[E| Bkt1],Res};
take_key(_,[]) ->
    {[],error}.

-spec(store(Key,Value,Dict1) -> Dict2 when Dict1::dict(Key,Value),Dict2::dict(Key,Value)).

store(Key,Val,D0) ->
    Slot = get_slot(D0,Key),
    {D1,Ic} = on_bucket(fun (B0)->
        store_bkt_val(Key,Val,B0) end,D0,Slot),
    maybe_expand(D1,Ic).

store_bkt_val(Key,New,[[Key| _Old]| Bkt]) ->
    {[[Key| New]| Bkt],0};
store_bkt_val(Key,New,[Other| Bkt0]) ->
    {Bkt1,Ic} = store_bkt_val(Key,New,Bkt0),
    {[Other| Bkt1],Ic};
store_bkt_val(Key,New,[]) ->
    {[[Key| New]],1}.

-spec(append(Key,Value,Dict1) -> Dict2 when Dict1::dict(Key,Value),Dict2::dict(Key,Value)).

append(Key,Val,D0) ->
    Slot = get_slot(D0,Key),
    {D1,Ic} = on_bucket(fun (B0)->
        append_bkt(Key,Val,B0) end,D0,Slot),
    maybe_expand(D1,Ic).

append_bkt(Key,Val,[[Key| Bag]| Bkt]) ->
    {[[Key| Bag ++ [Val]]| Bkt],0};
append_bkt(Key,Val,[Other| Bkt0]) ->
    {Bkt1,Ic} = append_bkt(Key,Val,Bkt0),
    {[Other| Bkt1],Ic};
append_bkt(Key,Val,[]) ->
    {[[Key, Val]],1}.

-spec(append_list(Key,ValList,Dict1) -> Dict2 when Dict1::dict(Key,Value),Dict2::dict(Key,Value),ValList::[Value]).

append_list(Key,L,D0) ->
    Slot = get_slot(D0,Key),
    {D1,Ic} = on_bucket(fun (B0)->
        app_list_bkt(Key,L,B0) end,D0,Slot),
    maybe_expand(D1,Ic).

app_list_bkt(Key,L,[[Key| Bag]| Bkt]) ->
    {[[Key| Bag ++ L]| Bkt],0};
app_list_bkt(Key,L,[Other| Bkt0]) ->
    {Bkt1,Ic} = app_list_bkt(Key,L,Bkt0),
    {[Other| Bkt1],Ic};
app_list_bkt(Key,L,[]) ->
    {[[Key| L]],1}.

-spec(update(Key,Fun,Dict1) -> Dict2 when Dict1::dict(Key,Value),Dict2::dict(Key,Value),Fun::fun((Value1::Value) -> Value2::Value)).

update(Key,F,D0) ->
    Slot = get_slot(D0,Key),
    try on_bucket(fun (B0)->
        update_bkt(Key,F,B0) end,D0,Slot) of 
        {D1,_Uv}->
            D1
        catch
            throw:badarg->
                error(badarg,[Key, F, D0]) end.

update_bkt(Key,F,[[Key| Val]| Bkt]) ->
    Upd = F(Val),
    {[[Key| Upd]| Bkt],Upd};
update_bkt(Key,F,[Other| Bkt0]) ->
    {Bkt1,Upd} = update_bkt(Key,F,Bkt0),
    {[Other| Bkt1],Upd};
update_bkt(_Key,_F,[]) ->
    throw(badarg).

-spec(update(Key,Fun,Initial,Dict1) -> Dict2 when Dict1::dict(Key,Value),Dict2::dict(Key,Value),Fun::fun((Value1::Value) -> Value2::Value),Initial::Value).

update(Key,F,Init,D0) ->
    Slot = get_slot(D0,Key),
    {D1,Ic} = on_bucket(fun (B0)->
        update_bkt(Key,F,Init,B0) end,D0,Slot),
    maybe_expand(D1,Ic).

update_bkt(Key,F,_,[[Key| Val]| Bkt]) ->
    {[[Key| F(Val)]| Bkt],0};
update_bkt(Key,F,I,[Other| Bkt0]) ->
    {Bkt1,Ic} = update_bkt(Key,F,I,Bkt0),
    {[Other| Bkt1],Ic};
update_bkt(Key,F,I,[])
    when is_function(F,1)->
    {[[Key| I]],1}.

-spec(update_counter(Key,Increment,Dict1) -> Dict2 when Dict1::dict(Key,Value),Dict2::dict(Key,Value),Increment::number()).

update_counter(Key,Incr,D0)
    when is_number(Incr)->
    Slot = get_slot(D0,Key),
    {D1,Ic} = on_bucket(fun (B0)->
        counter_bkt(Key,Incr,B0) end,D0,Slot),
    maybe_expand(D1,Ic).

-dialyzer({no_improper_lists,{counter_bkt,3}}).

counter_bkt(Key,I,[[Key| Val]| Bkt]) ->
    {[[Key| Val + I]| Bkt],0};
counter_bkt(Key,I,[Other| Bkt0]) ->
    {Bkt1,Ic} = counter_bkt(Key,I,Bkt0),
    {[Other| Bkt1],Ic};
counter_bkt(Key,I,[]) ->
    {[[Key| I]],1}.

-spec(fold(Fun,Acc0,Dict) -> Acc1 when Fun::fun((Key,Value,AccIn) -> AccOut),Dict::dict(Key,Value),Acc0::Acc,Acc1::Acc,AccIn::Acc,AccOut::Acc).

fold(F,Acc,D) ->
    fold_dict(F,Acc,D).

-spec(map(Fun,Dict1) -> Dict2 when Fun::fun((Key,Value1) -> Value2),Dict1::dict(Key,Value1),Dict2::dict(Key,Value2)).

map(F,D) ->
    map_dict(F,D).

-spec(filter(Pred,Dict1) -> Dict2 when Pred::fun((Key,Value) -> boolean()),Dict1::dict(Key,Value),Dict2::dict(Key,Value)).

filter(F,D) ->
    filter_dict(F,D).

-spec(merge(Fun,Dict1,Dict2) -> Dict3 when Fun::fun((Key,Value1,Value2) -> Value),Dict1::dict(Key,Value1),Dict2::dict(Key,Value2),Dict3::dict(Key,Value)).

merge(F,D1,D2)
    when D1#dict.size < D2#dict.size->
    fold_dict(fun (K,V1,D)->
        update(K,fun (V2)->
            F(K,V1,V2) end,V1,D) end,D2,D1);
merge(F,D1,D2) ->
    fold_dict(fun (K,V2,D)->
        update(K,fun (V1)->
            F(K,V1,V2) end,V2,D) end,D1,D2).

get_slot(T,Key) ->
    H = erlang:phash(Key,T#dict.maxn),
    if H > T#dict.n ->
        H - T#dict.bso;true ->
        H end.

get_bucket(T,Slot) ->
    get_bucket_s(T#dict.segs,Slot).

on_bucket(F,T,Slot) ->
    SegI = (Slot - 1) div 16 + 1,
    BktI = (Slot - 1) rem 16 + 1,
    Segs = T#dict.segs,
    Seg = element(SegI,Segs),
    B0 = element(BktI,Seg),
    {B1,Res} = F(B0),
    {T#dict{segs = setelement(SegI,Segs,setelement(BktI,Seg,B1))},Res}.

fold_dict(F,Acc,#dict{size = 0})
    when is_function(F,3)->
    Acc;
fold_dict(F,Acc,D) ->
    Segs = D#dict.segs,
    fold_segs(F,Acc,Segs,tuple_size(Segs)).

fold_segs(F,Acc,Segs,I)
    when I >= 1->
    Seg = element(I,Segs),
    fold_segs(F,fold_seg(F,Acc,Seg,tuple_size(Seg)),Segs,I - 1);
fold_segs(F,Acc,_,0)
    when is_function(F,3)->
    Acc.

fold_seg(F,Acc,Seg,I)
    when I >= 1->
    fold_seg(F,fold_bucket(F,Acc,element(I,Seg)),Seg,I - 1);
fold_seg(F,Acc,_,0)
    when is_function(F,3)->
    Acc.

fold_bucket(F,Acc,[[Key| Val]| Bkt]) ->
    fold_bucket(F,F(Key,Val,Acc),Bkt);
fold_bucket(F,Acc,[])
    when is_function(F,3)->
    Acc.

map_dict(F,#dict{size = 0} = Dict)
    when is_function(F,2)->
    Dict;
map_dict(F,D) ->
    Segs0 = tuple_to_list(D#dict.segs),
    Segs1 = map_seg_list(F,Segs0),
    D#dict{segs = list_to_tuple(Segs1)}.

map_seg_list(F,[Seg| Segs]) ->
    Bkts0 = tuple_to_list(Seg),
    Bkts1 = map_bkt_list(F,Bkts0),
    [list_to_tuple(Bkts1)| map_seg_list(F,Segs)];
map_seg_list(F,[])
    when is_function(F,2)->
    [].

map_bkt_list(F,[Bkt0| Bkts]) ->
    [map_bucket(F,Bkt0)| map_bkt_list(F,Bkts)];
map_bkt_list(F,[])
    when is_function(F,2)->
    [].

map_bucket(F,[[Key| Val]| Bkt]) ->
    [[Key| F(Key,Val)]| map_bucket(F,Bkt)];
map_bucket(F,[])
    when is_function(F,2)->
    [].

filter_dict(F,#dict{size = 0} = Dict)
    when is_function(F,2)->
    Dict;
filter_dict(F,D) ->
    Segs0 = tuple_to_list(D#dict.segs),
    {Segs1,Fc} = filter_seg_list(F,Segs0,[],0),
    maybe_contract(D#dict{segs = list_to_tuple(Segs1)},Fc).

filter_seg_list(F,[Seg| Segs],Fss,Fc0) ->
    Bkts0 = tuple_to_list(Seg),
    {Bkts1,Fc1} = filter_bkt_list(F,Bkts0,[],Fc0),
    filter_seg_list(F,Segs,[list_to_tuple(Bkts1)| Fss],Fc1);
filter_seg_list(F,[],Fss,Fc)
    when is_function(F,2)->
    {lists:reverse(Fss,[]),Fc}.

filter_bkt_list(F,[Bkt0| Bkts],Fbs,Fc0) ->
    {Bkt1,Fc1} = filter_bucket(F,Bkt0,[],Fc0),
    filter_bkt_list(F,Bkts,[Bkt1| Fbs],Fc1);
filter_bkt_list(F,[],Fbs,Fc)
    when is_function(F,2)->
    {lists:reverse(Fbs),Fc}.

filter_bucket(F,[[Key| Val] = E| Bkt],Fb,Fc) ->
    case F(Key,Val) of
        true->
            filter_bucket(F,Bkt,[E| Fb],Fc);
        false->
            filter_bucket(F,Bkt,Fb,Fc + 1)
    end;
filter_bucket(F,[],Fb,Fc)
    when is_function(F,2)->
    {lists:reverse(Fb),Fc}.

get_bucket_s(Segs,Slot) ->
    SegI = (Slot - 1) div 16 + 1,
    BktI = (Slot - 1) rem 16 + 1,
    element(BktI,element(SegI,Segs)).

put_bucket_s(Segs,Slot,Bkt) ->
    SegI = (Slot - 1) div 16 + 1,
    BktI = (Slot - 1) rem 16 + 1,
    Seg = setelement(BktI,element(SegI,Segs),Bkt),
    setelement(SegI,Segs,Seg).

maybe_expand(T,0) ->
    maybe_expand_aux(T,0);
maybe_expand(T,1) ->
    maybe_expand_aux(T,1).

maybe_expand_aux(T0,Ic)
    when T0#dict.size + Ic > T0#dict.exp_size->
    T = maybe_expand_segs(T0),
    N = T#dict.n + 1,
    Segs0 = T#dict.segs,
    Slot1 = N - T#dict.bso,
    B = get_bucket_s(Segs0,Slot1),
    Slot2 = N,
    [B1| B2] = rehash(B,Slot1,Slot2,T#dict.maxn),
    Segs1 = put_bucket_s(Segs0,Slot1,B1),
    Segs2 = put_bucket_s(Segs1,Slot2,B2),
    T#dict{size = T#dict.size + Ic,n = N,exp_size = N * 5,con_size = N * 3,segs = Segs2};
maybe_expand_aux(T,Ic) ->
    T#dict{size = T#dict.size + Ic}.

maybe_expand_segs(T)
    when T#dict.n =:= T#dict.maxn->
    T#dict{maxn = 2 * T#dict.maxn,bso = 2 * T#dict.bso,segs = expand_segs(T#dict.segs,T#dict.empty)};
maybe_expand_segs(T) ->
    T.

maybe_contract(T,Dc)
    when T#dict.size - Dc < T#dict.con_size,
    T#dict.n > 16->
    N = T#dict.n,
    Slot1 = N - T#dict.bso,
    Segs0 = T#dict.segs,
    B1 = get_bucket_s(Segs0,Slot1),
    Slot2 = N,
    B2 = get_bucket_s(Segs0,Slot2),
    Segs1 = put_bucket_s(Segs0,Slot1,B1 ++ B2),
    Segs2 = put_bucket_s(Segs1,Slot2,[]),
    N1 = N - 1,
    maybe_contract_segs(T#dict{size = T#dict.size - Dc,n = N1,exp_size = N1 * 5,con_size = N1 * 3,segs = Segs2});
maybe_contract(T,Dc) ->
    T#dict{size = T#dict.size - Dc}.

maybe_contract_segs(T)
    when T#dict.n =:= T#dict.bso->
    T#dict{maxn = T#dict.maxn div 2,bso = T#dict.bso div 2,segs = contract_segs(T#dict.segs)};
maybe_contract_segs(T) ->
    T.

rehash([[Key| _Bag] = KeyBag| T],Slot1,Slot2,MaxN) ->
    [L1| L2] = rehash(T,Slot1,Slot2,MaxN),
    case erlang:phash(Key,MaxN) of
        Slot1->
            [[KeyBag| L1]| L2];
        Slot2->
            [L1, KeyBag| L2]
    end;
rehash([],_Slot1,_Slot2,_MaxN) ->
    [[]].

mk_seg(16) ->
    {[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]}.

expand_segs({B1},Empty) ->
    {B1,Empty};
expand_segs({B1,B2},Empty) ->
    {B1,B2,Empty,Empty};
expand_segs({B1,B2,B3,B4},Empty) ->
    {B1,B2,B3,B4,Empty,Empty,Empty,Empty};
expand_segs({B1,B2,B3,B4,B5,B6,B7,B8},Empty) ->
    {B1,B2,B3,B4,B5,B6,B7,B8,Empty,Empty,Empty,Empty,Empty,Empty,Empty,Empty};
expand_segs({B1,B2,B3,B4,B5,B6,B7,B8,B9,B10,B11,B12,B13,B14,B15,B16},Empty) ->
    {B1,B2,B3,B4,B5,B6,B7,B8,B9,B10,B11,B12,B13,B14,B15,B16,Empty,Empty,Empty,Empty,Empty,Empty,Empty,Empty,Empty,Empty,Empty,Empty,Empty,Empty,Empty,Empty};
expand_segs(Segs,Empty) ->
    list_to_tuple(tuple_to_list(Segs) ++ lists:duplicate(tuple_size(Segs),Empty)).

contract_segs({B1,_}) ->
    {B1};
contract_segs({B1,B2,_,_}) ->
    {B1,B2};
contract_segs({B1,B2,B3,B4,_,_,_,_}) ->
    {B1,B2,B3,B4};
contract_segs({B1,B2,B3,B4,B5,B6,B7,B8,_,_,_,_,_,_,_,_}) ->
    {B1,B2,B3,B4,B5,B6,B7,B8};
contract_segs({B1,B2,B3,B4,B5,B6,B7,B8,B9,B10,B11,B12,B13,B14,B15,B16,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_}) ->
    {B1,B2,B3,B4,B5,B6,B7,B8,B9,B10,B11,B12,B13,B14,B15,B16};
contract_segs(Segs) ->
    Ss = tuple_size(Segs) div 2,
    list_to_tuple(lists:sublist(tuple_to_list(Segs),1,Ss)).
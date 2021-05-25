-file("sofs.erl", 1).

-module(sofs).

-export([from_term/1, from_term/2, from_external/2, empty_set/0, is_type/1, set/1, set/2, from_sets/1, relation/1, relation/2, a_function/1, a_function/2, family/1, family/2, to_external/1, type/1, to_sets/1, no_elements/1, specification/2, union/2, intersection/2, difference/2, symdiff/2, symmetric_partition/2, product/1, product/2, constant_function/2, is_equal/2, is_subset/2, is_sofs_set/1, is_set/1, is_empty_set/1, is_disjoint/2]).

-export([union/1, intersection/1, canonical_relation/1]).

-export([relation_to_family/1, domain/1, range/1, field/1, relative_product/1, relative_product/2, relative_product1/2, converse/1, image/2, inverse_image/2, strict_relation/1, weak_relation/1, extension/3, is_a_function/1]).

-export([composite/2, inverse/1]).

-export([restriction/2, restriction/3, drestriction/2, drestriction/3, substitution/2, projection/2, partition/1, partition/2, partition/3, multiple_relative_product/2, join/4]).

-export([family_to_relation/1, family_specification/2, union_of_family/1, intersection_of_family/1, family_union/1, family_intersection/1, family_domain/1, family_range/1, family_field/1, family_union/2, family_intersection/2, family_difference/2, partition_family/2, family_projection/2]).

-export([family_to_digraph/1, family_to_digraph/2, digraph_to_family/1, digraph_to_family/2]).

-export([fam2rel/1, rel2fam/1]).

-import(lists, [any/2, append/1, flatten/1, foreach/2, keysort/2, last/1, map/2, mapfoldl/3, member/2, merge/2, reverse/1, reverse/2, sort/1, umerge/1, umerge/2, usort/1]).

-compile({inline,[{family_to_relation,1}, {relation_to_family,1}]}).

-compile({inline,[{rel,2}, {a_func,2}, {fam,2}, {term2set,2}]}).

-compile({inline,[{external_fun,1}, {element_type,1}]}).

-compile({inline,[{unify_types,2}, {match_types,2}, {test_rel,3}, {symdiff,3}, {subst,3}]}).

-compile({inline,[{fam_binop,3}]}).

-record('Set',{data = []::list(),type = type::term()}).

-record('OrdSet',{orddata = {}::tuple()|atom(),ordtype = type::term()}).

-export_type([anyset/0, binary_relation/0, external_set/0, a_function/0, family/0, relation/0, set_of_sets/0, set_fun/0, spec_fun/0, type/0]).

-export_type([ordset/0, a_set/0]).

-type(anyset()::ordset()|a_set()).

-type(binary_relation()::relation()).

-type(external_set()::term()).

-type(a_function()::relation()).

-type(family()::a_function()).

-opaque(ordset()::#'OrdSet'{}).

-type(relation()::a_set()).

-opaque(a_set()::#'Set'{}).

-type(set_of_sets()::a_set()).

-type(set_fun()::pos_integer()|{external,fun((external_set()) -> external_set())}|fun((anyset()) -> anyset())).

-type(spec_fun()::{external,fun((external_set()) -> boolean())}|fun((anyset()) -> boolean())).

-type(type()::term()).

-type(tuple_of(_T)::tuple()).

-spec(from_term(Term) -> AnySet when AnySet::anyset(),Term::term()).

from_term(T) ->
    Type = case T of
        _
            when is_list(T)->
            [_];
        _->
            _
    end,
    try setify(T,Type)
        catch
            _:_->
                error(badarg) end.

-spec(from_term(Term,Type) -> AnySet when AnySet::anyset(),Term::term(),Type::type()).

from_term(L,T) ->
    case is_type(T) of
        true->
            try setify(L,T)
                catch
                    _:_->
                        error(badarg) end;
        false->
            error(badarg)
    end.

-spec(from_external(ExternalSet,Type) -> AnySet when ExternalSet::external_set(),AnySet::anyset(),Type::type()).

from_external(L,[Type]) ->
    #'Set'{data = L,type = Type};
from_external(T,Type) ->
    #'OrdSet'{orddata = T,ordtype = Type}.

-spec(empty_set() -> Set when Set::a_set()).

empty_set() ->
    #'Set'{data = [],type = _}.

-spec(is_type(Term) -> Bool when Bool::boolean(),Term::term()).

is_type(Atom)
    when is_atom(Atom),
    Atom =/= _->
    true;
is_type([T]) ->
    is_element_type(T);
is_type(T)
    when tuple_size(T) > 0->
    is_types(tuple_size(T),T);
is_type(_T) ->
    false.

-spec(set(Terms) -> Set when Set::a_set(),Terms::[term()]).

set(L) ->
    try usort(L) of 
        SL->
            #'Set'{data = SL,type = atom}
        catch
            _:_->
                error(badarg) end.

-spec(set(Terms,Type) -> Set when Set::a_set(),Terms::[term()],Type::type()).

set(L,[Type])
    when is_atom(Type),
    Type =/= _->
    try usort(L) of 
        SL->
            #'Set'{data = SL,type = Type}
        catch
            _:_->
                error(badarg) end;
set(L,[_] = T) ->
    try setify(L,T)
        catch
            _:_->
                error(badarg) end;
set(_,_) ->
    error(badarg).

-spec(from_sets(ListOfSets) -> Set when Set::a_set(),ListOfSets::[anyset()];(TupleOfSets) -> Ordset when Ordset::ordset(),TupleOfSets::tuple_of(anyset())).

from_sets(Ss)
    when is_list(Ss)->
    case set_of_sets(Ss,[],_) of
        {error,Error}->
            error(Error);
        Set->
            Set
    end;
from_sets(Tuple)
    when is_tuple(Tuple)->
    case ordset_of_sets(tuple_to_list(Tuple),[],[]) of
        error->
            error(badarg);
        Set->
            Set
    end;
from_sets(_) ->
    error(badarg).

-spec(relation(Tuples) -> Relation when Relation::relation(),Tuples::[tuple()]).

relation([]) ->
    #'Set'{data = [],type = {atom,atom}};
relation(Ts = [T| _])
    when is_tuple(T)->
    try rel(Ts,tuple_size(T))
        catch
            _:_->
                error(badarg) end;
relation(_) ->
    error(badarg).

-spec(relation(Tuples,Type) -> Relation when N::integer(),Type::N|type(),Relation::relation(),Tuples::[tuple()]).

relation(Ts,TS) ->
    try rel(Ts,TS)
        catch
            _:_->
                error(badarg) end.

-spec(a_function(Tuples) -> Function when Function::a_function(),Tuples::[tuple()]).

a_function(Ts) ->
    try func(Ts,{atom,atom}) of 
        Bad
            when is_atom(Bad)->
            error(Bad);
        Set->
            Set
        catch
            _:_->
                error(badarg) end.

-spec(a_function(Tuples,Type) -> Function when Function::a_function(),Tuples::[tuple()],Type::type()).

a_function(Ts,T) ->
    try a_func(Ts,T) of 
        Bad
            when is_atom(Bad)->
            error(Bad);
        Set->
            Set
        catch
            _:_->
                error(badarg) end.

-spec(family(Tuples) -> Family when Family::family(),Tuples::[tuple()]).

family(Ts) ->
    try fam2(Ts,{atom,[atom]}) of 
        Bad
            when is_atom(Bad)->
            error(Bad);
        Set->
            Set
        catch
            _:_->
                error(badarg) end.

-spec(family(Tuples,Type) -> Family when Family::family(),Tuples::[tuple()],Type::type()).

family(Ts,T) ->
    try fam(Ts,T) of 
        Bad
            when is_atom(Bad)->
            error(Bad);
        Set->
            Set
        catch
            _:_->
                error(badarg) end.

-spec(to_external(AnySet) -> ExternalSet when ExternalSet::external_set(),AnySet::anyset()).

to_external(S)
    when is_record(S,'Set')->
    S#'Set'.data;
to_external(S)
    when is_record(S,'OrdSet')->
    S#'OrdSet'.orddata.

-spec(type(AnySet) -> Type when AnySet::anyset(),Type::type()).

type(S)
    when is_record(S,'Set')->
    [S#'Set'.type];
type(S)
    when is_record(S,'OrdSet')->
    S#'OrdSet'.ordtype.

-spec(to_sets(ASet) -> Sets when ASet::a_set()|ordset(),Sets::tuple_of(AnySet)|[AnySet],AnySet::anyset()).

to_sets(S)
    when is_record(S,'Set')->
    case S#'Set'.type of
        [Type]->
            list_of_sets(S#'Set'.data,Type,[]);
        Type->
            list_of_ordsets(S#'Set'.data,Type,[])
    end;
to_sets(S)
    when is_record(S,'OrdSet'),
    is_tuple(S#'OrdSet'.ordtype)->
    tuple_of_sets(tuple_to_list(S#'OrdSet'.orddata),tuple_to_list(S#'OrdSet'.ordtype),[]);
to_sets(S)
    when is_record(S,'OrdSet')->
    error(badarg).

-spec(no_elements(ASet) -> NoElements when ASet::a_set()|ordset(),NoElements::non_neg_integer()).

no_elements(S)
    when is_record(S,'Set')->
    length(S#'Set'.data);
no_elements(S)
    when is_record(S,'OrdSet'),
    is_tuple(S#'OrdSet'.ordtype)->
    tuple_size(S#'OrdSet'.orddata);
no_elements(S)
    when is_record(S,'OrdSet')->
    error(badarg).

-spec(specification(Fun,Set1) -> Set2 when Fun::spec_fun(),Set1::a_set(),Set2::a_set()).

specification(Fun,S)
    when is_record(S,'Set')->
    Type = S#'Set'.type,
    R = case external_fun(Fun) of
        false->
            spec(S#'Set'.data,Fun,element_type(Type),[]);
        XFun->
            specification(S#'Set'.data,XFun,[])
    end,
    case R of
        SL
            when is_list(SL)->
            #'Set'{data = SL,type = Type};
        Bad->
            error(Bad)
    end.

-spec(union(Set1,Set2) -> Set3 when Set1::a_set(),Set2::a_set(),Set3::a_set()).

union(S1,S2)
    when is_record(S1,'Set'),
    is_record(S2,'Set')->
    case unify_types(S1#'Set'.type,S2#'Set'.type) of
        []->
            error(type_mismatch);
        Type->
            #'Set'{data = umerge(S1#'Set'.data,S2#'Set'.data),type = Type}
    end.

-spec(intersection(Set1,Set2) -> Set3 when Set1::a_set(),Set2::a_set(),Set3::a_set()).

intersection(S1,S2)
    when is_record(S1,'Set'),
    is_record(S2,'Set')->
    case unify_types(S1#'Set'.type,S2#'Set'.type) of
        []->
            error(type_mismatch);
        Type->
            #'Set'{data = intersection(S1#'Set'.data,S2#'Set'.data,[]),type = Type}
    end.

-spec(difference(Set1,Set2) -> Set3 when Set1::a_set(),Set2::a_set(),Set3::a_set()).

difference(S1,S2)
    when is_record(S1,'Set'),
    is_record(S2,'Set')->
    case unify_types(S1#'Set'.type,S2#'Set'.type) of
        []->
            error(type_mismatch);
        Type->
            #'Set'{data = difference(S1#'Set'.data,S2#'Set'.data,[]),type = Type}
    end.

-spec(symdiff(Set1,Set2) -> Set3 when Set1::a_set(),Set2::a_set(),Set3::a_set()).

symdiff(S1,S2)
    when is_record(S1,'Set'),
    is_record(S2,'Set')->
    case unify_types(S1#'Set'.type,S2#'Set'.type) of
        []->
            error(type_mismatch);
        Type->
            #'Set'{data = symdiff(S1#'Set'.data,S2#'Set'.data,[]),type = Type}
    end.

-spec(symmetric_partition(Set1,Set2) -> {Set3,Set4,Set5} when Set1::a_set(),Set2::a_set(),Set3::a_set(),Set4::a_set(),Set5::a_set()).

symmetric_partition(S1,S2)
    when is_record(S1,'Set'),
    is_record(S2,'Set')->
    case unify_types(S1#'Set'.type,S2#'Set'.type) of
        []->
            error(type_mismatch);
        Type->
            sympart(S1#'Set'.data,S2#'Set'.data,[],[],[],Type)
    end.

-spec(product(Set1,Set2) -> BinRel when BinRel::binary_relation(),Set1::a_set(),Set2::a_set()).

product(S1,S2)
    when is_record(S1,'Set'),
    is_record(S2,'Set')->
    if S1#'Set'.type =:= _ ->
        S1;S2#'Set'.type =:= _ ->
        S2;true ->
        F = fun (E)->
            {0,E} end,
        T = {S1#'Set'.type,S2#'Set'.type},
        #'Set'{data = relprod(map(F,S1#'Set'.data),map(F,S2#'Set'.data)),type = T} end.

-spec(product(TupleOfSets) -> Relation when Relation::relation(),TupleOfSets::tuple_of(a_set())).

product({S1,S2}) ->
    product(S1,S2);
product(T)
    when is_tuple(T)->
    Ss = tuple_to_list(T),
    try sets_to_list(Ss) of 
        []->
            error(badarg);
        L->
            Type = types(Ss,[]),
            case member([],L) of
                true->
                    empty_set();
                false->
                    #'Set'{data = reverse(prod(L,[],[])),type = Type}
            end
        catch
            _:_->
                error(badarg) end.

-spec(constant_function(Set,AnySet) -> Function when AnySet::anyset(),Function::a_function(),Set::a_set()).

constant_function(S,E)
    when is_record(S,'Set')->
    case {S#'Set'.type,is_sofs_set(E)} of
        {_,true}->
            S;
        {Type,true}->
            NType = {Type,type(E)},
            #'Set'{data = constant_function(S#'Set'.data,to_external(E),[]),type = NType};
        _->
            error(badarg)
    end;
constant_function(S,_)
    when is_record(S,'OrdSet')->
    error(badarg).

-spec(is_equal(AnySet1,AnySet2) -> Bool when AnySet1::anyset(),AnySet2::anyset(),Bool::boolean()).

is_equal(S1,S2)
    when is_record(S1,'Set'),
    is_record(S2,'Set')->
    case match_types(S1#'Set'.type,S2#'Set'.type) of
        true->
            S1#'Set'.data == S2#'Set'.data;
        false->
            error(type_mismatch)
    end;
is_equal(S1,S2)
    when is_record(S1,'OrdSet'),
    is_record(S2,'OrdSet')->
    case match_types(S1#'OrdSet'.ordtype,S2#'OrdSet'.ordtype) of
        true->
            S1#'OrdSet'.orddata == S2#'OrdSet'.orddata;
        false->
            error(type_mismatch)
    end;
is_equal(S1,S2)
    when is_record(S1,'Set'),
    is_record(S2,'OrdSet')->
    error(type_mismatch);
is_equal(S1,S2)
    when is_record(S1,'OrdSet'),
    is_record(S2,'Set')->
    error(type_mismatch).

-spec(is_subset(Set1,Set2) -> Bool when Bool::boolean(),Set1::a_set(),Set2::a_set()).

is_subset(S1,S2)
    when is_record(S1,'Set'),
    is_record(S2,'Set')->
    case match_types(S1#'Set'.type,S2#'Set'.type) of
        true->
            subset(S1#'Set'.data,S2#'Set'.data);
        false->
            error(type_mismatch)
    end.

-spec(is_sofs_set(Term) -> Bool when Bool::boolean(),Term::term()).

is_sofs_set(S)
    when is_record(S,'Set')->
    true;
is_sofs_set(S)
    when is_record(S,'OrdSet')->
    true;
is_sofs_set(_S) ->
    false.

-spec(is_set(AnySet) -> Bool when AnySet::anyset(),Bool::boolean()).

is_set(S)
    when is_record(S,'Set')->
    true;
is_set(S)
    when is_record(S,'OrdSet')->
    false.

-spec(is_empty_set(AnySet) -> Bool when AnySet::anyset(),Bool::boolean()).

is_empty_set(S)
    when is_record(S,'Set')->
    S#'Set'.data =:= [];
is_empty_set(S)
    when is_record(S,'OrdSet')->
    false.

-spec(is_disjoint(Set1,Set2) -> Bool when Bool::boolean(),Set1::a_set(),Set2::a_set()).

is_disjoint(S1,S2)
    when is_record(S1,'Set'),
    is_record(S2,'Set')->
    case match_types(S1#'Set'.type,S2#'Set'.type) of
        true->
            case S1#'Set'.data of
                []->
                    true;
                [A| As]->
                    disjoint(S2#'Set'.data,A,As)
            end;
        false->
            error(type_mismatch)
    end.

-spec(union(SetOfSets) -> Set when Set::a_set(),SetOfSets::set_of_sets()).

union(Sets)
    when is_record(Sets,'Set')->
    case Sets#'Set'.type of
        [Type]->
            #'Set'{data = lunion(Sets#'Set'.data),type = Type};
        _->
            Sets;
        _->
            error(badarg)
    end.

-spec(intersection(SetOfSets) -> Set when Set::a_set(),SetOfSets::set_of_sets()).

intersection(Sets)
    when is_record(Sets,'Set')->
    case Sets#'Set'.data of
        []->
            error(badarg);
        [L| Ls]->
            case Sets#'Set'.type of
                [Type]->
                    #'Set'{data = lintersection(Ls,L),type = Type};
                _->
                    error(badarg)
            end
    end.

-spec(canonical_relation(SetOfSets) -> BinRel when BinRel::binary_relation(),SetOfSets::set_of_sets()).

canonical_relation(Sets)
    when is_record(Sets,'Set')->
    ST = Sets#'Set'.type,
    case ST of
        [_]->
            empty_set();
        [Type]->
            #'Set'{data = can_rel(Sets#'Set'.data,[]),type = {Type,ST}};
        _->
            Sets;
        _->
            error(badarg)
    end.

-spec(rel2fam(BinRel) -> Family when Family::family(),BinRel::binary_relation()).

rel2fam(R) ->
    relation_to_family(R).

-spec(relation_to_family(BinRel) -> Family when Family::family(),BinRel::binary_relation()).

relation_to_family(R)
    when is_record(R,'Set')->
    case R#'Set'.type of
        {DT,RT}->
            #'Set'{data = rel2family(R#'Set'.data),type = {DT,[RT]}};
        _->
            R;
        _Else->
            error(badarg)
    end.

-spec(domain(BinRel) -> Set when BinRel::binary_relation(),Set::a_set()).

domain(R)
    when is_record(R,'Set')->
    case R#'Set'.type of
        {DT,_}->
            #'Set'{data = dom(R#'Set'.data),type = DT};
        _->
            R;
        _Else->
            error(badarg)
    end.

-spec(range(BinRel) -> Set when BinRel::binary_relation(),Set::a_set()).

range(R)
    when is_record(R,'Set')->
    case R#'Set'.type of
        {_,RT}->
            #'Set'{data = ran(R#'Set'.data,[]),type = RT};
        _->
            R;
        _->
            error(badarg)
    end.

-spec(field(BinRel) -> Set when BinRel::binary_relation(),Set::a_set()).

field(R) ->
    union(domain(R),range(R)).

-spec(relative_product(ListOfBinRels) -> BinRel2 when ListOfBinRels::[BinRel, ...],BinRel::binary_relation(),BinRel2::binary_relation()).

relative_product(RT)
    when is_tuple(RT)->
    relative_product(tuple_to_list(RT));
relative_product(RL)
    when is_list(RL)->
    case relprod_n(RL,foo,false,false) of
        {error,Reason}->
            error(Reason);
        Reply->
            Reply
    end.

-spec(relative_product(ListOfBinRels,BinRel1) -> BinRel2 when ListOfBinRels::[BinRel, ...],BinRel::binary_relation(),BinRel1::binary_relation(),BinRel2::binary_relation();(BinRel1,BinRel2) -> BinRel3 when BinRel1::binary_relation(),BinRel2::binary_relation(),BinRel3::binary_relation()).

relative_product(R1,R2)
    when is_record(R1,'Set'),
    is_record(R2,'Set')->
    relative_product1(converse(R1),R2);
relative_product(RT,R)
    when is_tuple(RT),
    is_record(R,'Set')->
    relative_product(tuple_to_list(RT),R);
relative_product(RL,R)
    when is_list(RL),
    is_record(R,'Set')->
    EmptyR = case R#'Set'.type of
        {_,_}->
            R#'Set'.data =:= [];
        _->
            true;
        _->
            error(badarg)
    end,
    case relprod_n(RL,R,EmptyR,true) of
        {error,Reason}->
            error(Reason);
        Reply->
            Reply
    end.

-spec(relative_product1(BinRel1,BinRel2) -> BinRel3 when BinRel1::binary_relation(),BinRel2::binary_relation(),BinRel3::binary_relation()).

relative_product1(R1,R2)
    when is_record(R1,'Set'),
    is_record(R2,'Set')->
    {DTR1,RTR1} = case R1#'Set'.type of
        {_,_} = R1T->
            R1T;
        _->
            {_,_};
        _->
            error(badarg)
    end,
    {DTR2,RTR2} = case R2#'Set'.type of
        {_,_} = R2T->
            R2T;
        _->
            {_,_};
        _->
            error(badarg)
    end,
    case match_types(DTR1,DTR2) of
        true
            when DTR1 =:= _->
            R1;
        true
            when DTR2 =:= _->
            R2;
        true->
            #'Set'{data = relprod(R1#'Set'.data,R2#'Set'.data),type = {RTR1,RTR2}};
        false->
            error(type_mismatch)
    end.

-spec(converse(BinRel1) -> BinRel2 when BinRel1::binary_relation(),BinRel2::binary_relation()).

converse(R)
    when is_record(R,'Set')->
    case R#'Set'.type of
        {DT,RT}->
            #'Set'{data = converse(R#'Set'.data,[]),type = {RT,DT}};
        _->
            R;
        _->
            error(badarg)
    end.

-spec(image(BinRel,Set1) -> Set2 when BinRel::binary_relation(),Set1::a_set(),Set2::a_set()).

image(R,S)
    when is_record(R,'Set'),
    is_record(S,'Set')->
    case R#'Set'.type of
        {DT,RT}->
            case match_types(DT,S#'Set'.type) of
                true->
                    #'Set'{data = usort(restrict(S#'Set'.data,R#'Set'.data)),type = RT};
                false->
                    error(type_mismatch)
            end;
        _->
            R;
        _->
            error(badarg)
    end.

-spec(inverse_image(BinRel,Set1) -> Set2 when BinRel::binary_relation(),Set1::a_set(),Set2::a_set()).

inverse_image(R,S)
    when is_record(R,'Set'),
    is_record(S,'Set')->
    case R#'Set'.type of
        {DT,RT}->
            case match_types(RT,S#'Set'.type) of
                true->
                    NL = restrict(S#'Set'.data,converse(R#'Set'.data,[])),
                    #'Set'{data = usort(NL),type = DT};
                false->
                    error(type_mismatch)
            end;
        _->
            R;
        _->
            error(badarg)
    end.

-spec(strict_relation(BinRel1) -> BinRel2 when BinRel1::binary_relation(),BinRel2::binary_relation()).

strict_relation(R)
    when is_record(R,'Set')->
    case R#'Set'.type of
        Type = {_,_}->
            #'Set'{data = strict(R#'Set'.data,[]),type = Type};
        _->
            R;
        _->
            error(badarg)
    end.

-spec(weak_relation(BinRel1) -> BinRel2 when BinRel1::binary_relation(),BinRel2::binary_relation()).

weak_relation(R)
    when is_record(R,'Set')->
    case R#'Set'.type of
        {DT,RT}->
            case unify_types(DT,RT) of
                []->
                    error(badarg);
                Type->
                    #'Set'{data = weak(R#'Set'.data),type = {Type,Type}}
            end;
        _->
            R;
        _->
            error(badarg)
    end.

-spec(extension(BinRel1,Set,AnySet) -> BinRel2 when AnySet::anyset(),BinRel1::binary_relation(),BinRel2::binary_relation(),Set::a_set()).

extension(R,S,E)
    when is_record(R,'Set'),
    is_record(S,'Set')->
    case {R#'Set'.type,S#'Set'.type,is_sofs_set(E)} of
        {T = {DT,RT},ST,true}->
            case match_types(DT,ST) and match_types(RT,type(E)) of
                false->
                    error(type_mismatch);
                true->
                    RL = R#'Set'.data,
                    case extc([],S#'Set'.data,to_external(E),RL) of
                        []->
                            R;
                        L->
                            #'Set'{data = merge(RL,reverse(L)),type = T}
                    end
            end;
        {_,_,true}->
            R;
        {_,ST,true}->
            case type(E) of
                [_]->
                    R;
                ET->
                    #'Set'{data = [],type = {ST,ET}}
            end;
        {_,_,true}->
            error(badarg)
    end.

-spec(is_a_function(BinRel) -> Bool when Bool::boolean(),BinRel::binary_relation()).

is_a_function(R)
    when is_record(R,'Set')->
    case R#'Set'.type of
        {_,_}->
            case R#'Set'.data of
                []->
                    true;
                [{V,_}| Es]->
                    is_a_func(Es,V)
            end;
        _->
            true;
        _->
            error(badarg)
    end.

-spec(restriction(BinRel1,Set) -> BinRel2 when BinRel1::binary_relation(),BinRel2::binary_relation(),Set::a_set()).

restriction(Relation,Set) ->
    restriction(1,Relation,Set).

-spec(drestriction(BinRel1,Set) -> BinRel2 when BinRel1::binary_relation(),BinRel2::binary_relation(),Set::a_set()).

drestriction(Relation,Set) ->
    drestriction(1,Relation,Set).

-spec(composite(Function1,Function2) -> Function3 when Function1::a_function(),Function2::a_function(),Function3::a_function()).

composite(Fn1,Fn2)
    when is_record(Fn1,'Set'),
    is_record(Fn2,'Set')->
    {DTF1,RTF1} = case Fn1#'Set'.type of
        {_,_} = F1T->
            F1T;
        _->
            {_,_};
        _->
            error(badarg)
    end,
    {DTF2,RTF2} = case Fn2#'Set'.type of
        {_,_} = F2T->
            F2T;
        _->
            {_,_};
        _->
            error(badarg)
    end,
    case match_types(RTF1,DTF2) of
        true
            when DTF1 =:= _->
            Fn1;
        true
            when DTF2 =:= _->
            Fn2;
        true->
            case comp(Fn1#'Set'.data,Fn2#'Set'.data) of
                SL
                    when is_list(SL)->
                    #'Set'{data = sort(SL),type = {DTF1,RTF2}};
                Bad->
                    error(Bad)
            end;
        false->
            error(type_mismatch)
    end.

-spec(inverse(Function1) -> Function2 when Function1::a_function(),Function2::a_function()).

inverse(Fn)
    when is_record(Fn,'Set')->
    case Fn#'Set'.type of
        {DT,RT}->
            case inverse1(Fn#'Set'.data) of
                SL
                    when is_list(SL)->
                    #'Set'{data = SL,type = {RT,DT}};
                Bad->
                    error(Bad)
            end;
        _->
            Fn;
        _->
            error(badarg)
    end.

-spec(restriction(SetFun,Set1,Set2) -> Set3 when SetFun::set_fun(),Set1::a_set(),Set2::a_set(),Set3::a_set()).

restriction(I,R,S)
    when is_integer(I),
    is_record(R,'Set'),
    is_record(S,'Set')->
    RT = R#'Set'.type,
    ST = S#'Set'.type,
    case check_for_sort(RT,I) of
        empty->
            R;
        error->
            error(badarg);
        Sort->
            RL = R#'Set'.data,
            case {match_types(element(I,RT),ST),S#'Set'.data} of
                {true,_SL}
                    when RL =:= []->
                    R;
                {true,[]}->
                    #'Set'{data = [],type = RT};
                {true,[E| Es]}
                    when Sort =:= false->
                    #'Set'{data = reverse(restrict_n(I,RL,E,Es,[])),type = RT};
                {true,[E| Es]}->
                    #'Set'{data = sort(restrict_n(I,keysort(I,RL),E,Es,[])),type = RT};
                {false,_SL}->
                    error(type_mismatch)
            end
    end;
restriction(SetFun,S1,S2)
    when is_record(S1,'Set'),
    is_record(S2,'Set')->
    Type1 = S1#'Set'.type,
    Type2 = S2#'Set'.type,
    SL1 = S1#'Set'.data,
    case external_fun(SetFun) of
        false
            when Type2 =:= _->
            S2;
        false->
            case subst(SL1,SetFun,element_type(Type1)) of
                {NSL,NewType}->
                    case match_types(NewType,Type2) of
                        true->
                            NL = sort(restrict(S2#'Set'.data,converse(NSL,[]))),
                            #'Set'{data = NL,type = Type1};
                        false->
                            error(type_mismatch)
                    end;
                Bad->
                    error(Bad)
            end;
        _
            when Type1 =:= _->
            S1;
        _XFun
            when is_list(Type1)->
            error(badarg);
        XFun->
            FunT = XFun(Type1),
            try check_fun(Type1,XFun,FunT) of 
                Sort->
                    case match_types(FunT,Type2) of
                        true->
                            R1 = inverse_substitution(SL1,XFun,Sort),
                            #'Set'{data = sort(Sort,restrict(S2#'Set'.data,R1)),type = Type1};
                        false->
                            error(type_mismatch)
                    end
                catch
                    _:_->
                        error(badarg) end
    end.

-spec(drestriction(SetFun,Set1,Set2) -> Set3 when SetFun::set_fun(),Set1::a_set(),Set2::a_set(),Set3::a_set()).

drestriction(I,R,S)
    when is_integer(I),
    is_record(R,'Set'),
    is_record(S,'Set')->
    RT = R#'Set'.type,
    ST = S#'Set'.type,
    case check_for_sort(RT,I) of
        empty->
            R;
        error->
            error(badarg);
        Sort->
            RL = R#'Set'.data,
            case {match_types(element(I,RT),ST),S#'Set'.data} of
                {true,[]}->
                    R;
                {true,_SL}
                    when RL =:= []->
                    R;
                {true,[E| Es]}
                    when Sort =:= false->
                    #'Set'{data = diff_restrict_n(I,RL,E,Es,[]),type = RT};
                {true,[E| Es]}->
                    #'Set'{data = diff_restrict_n(I,keysort(I,RL),E,Es,[]),type = RT};
                {false,_SL}->
                    error(type_mismatch)
            end
    end;
drestriction(SetFun,S1,S2)
    when is_record(S1,'Set'),
    is_record(S2,'Set')->
    Type1 = S1#'Set'.type,
    Type2 = S2#'Set'.type,
    SL1 = S1#'Set'.data,
    case external_fun(SetFun) of
        false
            when Type2 =:= _->
            S1;
        false->
            case subst(SL1,SetFun,element_type(Type1)) of
                {NSL,NewType}->
                    case match_types(NewType,Type2) of
                        true->
                            SL2 = S2#'Set'.data,
                            NL = sort(diff_restrict(SL2,converse(NSL,[]))),
                            #'Set'{data = NL,type = Type1};
                        false->
                            error(type_mismatch)
                    end;
                Bad->
                    error(Bad)
            end;
        _
            when Type1 =:= _->
            S1;
        _XFun
            when is_list(Type1)->
            error(badarg);
        XFun->
            FunT = XFun(Type1),
            try check_fun(Type1,XFun,FunT) of 
                Sort->
                    case match_types(FunT,Type2) of
                        true->
                            R1 = inverse_substitution(SL1,XFun,Sort),
                            SL2 = S2#'Set'.data,
                            #'Set'{data = sort(Sort,diff_restrict(SL2,R1)),type = Type1};
                        false->
                            error(type_mismatch)
                    end
                catch
                    _:_->
                        error(badarg) end
    end.

-spec(projection(SetFun,Set1) -> Set2 when SetFun::set_fun(),Set1::a_set(),Set2::a_set()).

projection(I,Set)
    when is_integer(I),
    is_record(Set,'Set')->
    Type = Set#'Set'.type,
    case check_for_sort(Type,I) of
        empty->
            Set;
        error->
            error(badarg);
        _
            when I =:= 1->
            #'Set'{data = projection1(Set#'Set'.data),type = element(I,Type)};
        _->
            #'Set'{data = projection_n(Set#'Set'.data,I,[]),type = element(I,Type)}
    end;
projection(Fun,Set) ->
    range(substitution(Fun,Set)).

-spec(substitution(SetFun,Set1) -> Set2 when SetFun::set_fun(),Set1::a_set(),Set2::a_set()).

substitution(I,Set)
    when is_integer(I),
    is_record(Set,'Set')->
    Type = Set#'Set'.type,
    case check_for_sort(Type,I) of
        empty->
            Set;
        error->
            error(badarg);
        _Sort->
            NType = element(I,Type),
            NSL = substitute_element(Set#'Set'.data,I,[]),
            #'Set'{data = NSL,type = {Type,NType}}
    end;
substitution(SetFun,Set)
    when is_record(Set,'Set')->
    Type = Set#'Set'.type,
    L = Set#'Set'.data,
    case external_fun(SetFun) of
        false
            when L =/= []->
            case subst(L,SetFun,element_type(Type)) of
                {SL,NewType}->
                    #'Set'{data = reverse(SL),type = {Type,NewType}};
                Bad->
                    error(Bad)
            end;
        false->
            empty_set();
        _
            when Type =:= _->
            empty_set();
        _XFun
            when is_list(Type)->
            error(badarg);
        XFun->
            FunT = XFun(Type),
            try check_fun(Type,XFun,FunT) of 
                _Sort->
                    SL = substitute(L,XFun,[]),
                    #'Set'{data = SL,type = {Type,FunT}}
                catch
                    _:_->
                        error(badarg) end
    end.

-spec(partition(SetOfSets) -> Partition when SetOfSets::set_of_sets(),Partition::a_set()).

partition(Sets) ->
    F1 = relation_to_family(canonical_relation(Sets)),
    F2 = relation_to_family(converse(F1)),
    range(F2).

-spec(partition(SetFun,Set) -> Partition when SetFun::set_fun(),Partition::a_set(),Set::a_set()).

partition(I,Set)
    when is_integer(I),
    is_record(Set,'Set')->
    Type = Set#'Set'.type,
    case check_for_sort(Type,I) of
        empty->
            Set;
        error->
            error(badarg);
        false->
            #'Set'{data = partition_n(I,Set#'Set'.data),type = [Type]};
        true->
            #'Set'{data = partition_n(I,keysort(I,Set#'Set'.data)),type = [Type]}
    end;
partition(Fun,Set) ->
    range(partition_family(Fun,Set)).

-spec(partition(SetFun,Set1,Set2) -> {Set3,Set4} when SetFun::set_fun(),Set1::a_set(),Set2::a_set(),Set3::a_set(),Set4::a_set()).

partition(I,R,S)
    when is_integer(I),
    is_record(R,'Set'),
    is_record(S,'Set')->
    RT = R#'Set'.type,
    ST = S#'Set'.type,
    case check_for_sort(RT,I) of
        empty->
            {R,R};
        error->
            error(badarg);
        Sort->
            RL = R#'Set'.data,
            case {match_types(element(I,RT),ST),S#'Set'.data} of
                {true,_SL}
                    when RL =:= []->
                    {R,R};
                {true,[]}->
                    {#'Set'{data = [],type = RT},R};
                {true,[E| Es]}
                    when Sort =:= false->
                    [L1| L2] = partition3_n(I,RL,E,Es,[],[]),
                    {#'Set'{data = L1,type = RT},#'Set'{data = L2,type = RT}};
                {true,[E| Es]}->
                    [L1| L2] = partition3_n(I,keysort(I,RL),E,Es,[],[]),
                    {#'Set'{data = L1,type = RT},#'Set'{data = L2,type = RT}};
                {false,_SL}->
                    error(type_mismatch)
            end
    end;
partition(SetFun,S1,S2)
    when is_record(S1,'Set'),
    is_record(S2,'Set')->
    Type1 = S1#'Set'.type,
    Type2 = S2#'Set'.type,
    SL1 = S1#'Set'.data,
    case external_fun(SetFun) of
        false
            when Type2 =:= _->
            {S2,S1};
        false->
            case subst(SL1,SetFun,element_type(Type1)) of
                {NSL,NewType}->
                    case match_types(NewType,Type2) of
                        true->
                            R1 = converse(NSL,[]),
                            [L1| L2] = partition3(S2#'Set'.data,R1),
                            {#'Set'{data = sort(L1),type = Type1},#'Set'{data = sort(L2),type = Type1}};
                        false->
                            error(type_mismatch)
                    end;
                Bad->
                    error(Bad)
            end;
        _
            when Type1 =:= _->
            {S1,S1};
        _XFun
            when is_list(Type1)->
            error(badarg);
        XFun->
            FunT = XFun(Type1),
            try check_fun(Type1,XFun,FunT) of 
                Sort->
                    case match_types(FunT,Type2) of
                        true->
                            R1 = inverse_substitution(SL1,XFun,Sort),
                            [L1| L2] = partition3(S2#'Set'.data,R1),
                            {#'Set'{data = sort(L1),type = Type1},#'Set'{data = sort(L2),type = Type1}};
                        false->
                            error(type_mismatch)
                    end
                catch
                    _:_->
                        error(badarg) end
    end.

-spec(multiple_relative_product(TupleOfBinRels,BinRel1) -> BinRel2 when TupleOfBinRels::tuple_of(BinRel),BinRel::binary_relation(),BinRel1::binary_relation(),BinRel2::binary_relation()).

multiple_relative_product(T,R)
    when is_tuple(T),
    is_record(R,'Set')->
    case test_rel(R,tuple_size(T),eq) of
        true
            when R#'Set'.type =:= _->
            empty_set();
        true->
            MProd = mul_relprod(tuple_to_list(T),1,R),
            relative_product(MProd);
        false->
            error(badarg)
    end.

-spec(join(Relation1,I,Relation2,J) -> Relation3 when Relation1::relation(),Relation2::relation(),Relation3::relation(),I::pos_integer(),J::pos_integer()).

join(R1,I1,R2,I2)
    when is_record(R1,'Set'),
    is_record(R2,'Set'),
    is_integer(I1),
    is_integer(I2)->
    case test_rel(R1,I1,lte) and test_rel(R2,I2,lte) of
        false->
            error(badarg);
        true
            when R1#'Set'.type =:= _->
            R1;
        true
            when R2#'Set'.type =:= _->
            R2;
        true->
            L1 = (raise_element(R1,I1))#'Set'.data,
            L2 = (raise_element(R2,I2))#'Set'.data,
            T = relprod1(L1,L2),
            F = case (I1 =:= 1) and (I2 =:= 1) of
                true->
                    fun ({X,Y})->
                        join_element(X,Y) end;
                false->
                    fun ({X,Y})->
                        list_to_tuple(join_element(X,Y,I2)) end
            end,
            #'Set'{data = replace(T,F,[]),type = F({R1#'Set'.type,R2#'Set'.type})}
    end.

test_rel(R,I,C) ->
    case R#'Set'.type of
        Rel
            when is_tuple(Rel),
            C =:= eq,
            I =:= tuple_size(Rel)->
            true;
        Rel
            when is_tuple(Rel),
            C =:= lte,
            I >= 1,
            I =< tuple_size(Rel)->
            true;
        _->
            true;
        _->
            false
    end.

-spec(fam2rel(Family) -> BinRel when Family::family(),BinRel::binary_relation()).

fam2rel(F) ->
    family_to_relation(F).

-spec(family_to_relation(Family) -> BinRel when Family::family(),BinRel::binary_relation()).

family_to_relation(F)
    when is_record(F,'Set')->
    case F#'Set'.type of
        {DT,[RT]}->
            #'Set'{data = family2rel(F#'Set'.data,[]),type = {DT,RT}};
        _->
            F;
        _->
            error(badarg)
    end.

-spec(family_specification(Fun,Family1) -> Family2 when Fun::spec_fun(),Family1::family(),Family2::family()).

family_specification(Fun,F)
    when is_record(F,'Set')->
    case F#'Set'.type of
        {_DT,[Type]} = FType->
            R = case external_fun(Fun) of
                false->
                    fam_spec(F#'Set'.data,Fun,Type,[]);
                XFun->
                    fam_specification(F#'Set'.data,XFun,[])
            end,
            case R of
                SL
                    when is_list(SL)->
                    #'Set'{data = SL,type = FType};
                Bad->
                    error(Bad)
            end;
        _->
            F;
        _->
            error(badarg)
    end.

-spec(union_of_family(Family) -> Set when Family::family(),Set::a_set()).

union_of_family(F)
    when is_record(F,'Set')->
    case F#'Set'.type of
        {_DT,[Type]}->
            #'Set'{data = un_of_fam(F#'Set'.data,[]),type = Type};
        _->
            F;
        _->
            error(badarg)
    end.

-spec(intersection_of_family(Family) -> Set when Family::family(),Set::a_set()).

intersection_of_family(F)
    when is_record(F,'Set')->
    case F#'Set'.type of
        {_DT,[Type]}->
            case int_of_fam(F#'Set'.data) of
                FU
                    when is_list(FU)->
                    #'Set'{data = FU,type = Type};
                Bad->
                    error(Bad)
            end;
        _->
            error(badarg)
    end.

-spec(family_union(Family1) -> Family2 when Family1::family(),Family2::family()).

family_union(F)
    when is_record(F,'Set')->
    case F#'Set'.type of
        {DT,[[Type]]}->
            #'Set'{data = fam_un(F#'Set'.data,[]),type = {DT,[Type]}};
        _->
            F;
        _->
            error(badarg)
    end.

-spec(family_intersection(Family1) -> Family2 when Family1::family(),Family2::family()).

family_intersection(F)
    when is_record(F,'Set')->
    case F#'Set'.type of
        {DT,[[Type]]}->
            case fam_int(F#'Set'.data,[]) of
                FU
                    when is_list(FU)->
                    #'Set'{data = FU,type = {DT,[Type]}};
                Bad->
                    error(Bad)
            end;
        _->
            F;
        _->
            error(badarg)
    end.

-spec(family_domain(Family1) -> Family2 when Family1::family(),Family2::family()).

family_domain(F)
    when is_record(F,'Set')->
    case F#'Set'.type of
        {FDT,[{DT,_}]}->
            #'Set'{data = fam_dom(F#'Set'.data,[]),type = {FDT,[DT]}};
        _->
            F;
        {_,[_]}->
            F;
        _->
            error(badarg)
    end.

-spec(family_range(Family1) -> Family2 when Family1::family(),Family2::family()).

family_range(F)
    when is_record(F,'Set')->
    case F#'Set'.type of
        {DT,[{_,RT}]}->
            #'Set'{data = fam_ran(F#'Set'.data,[]),type = {DT,[RT]}};
        _->
            F;
        {_,[_]}->
            F;
        _->
            error(badarg)
    end.

-spec(family_field(Family1) -> Family2 when Family1::family(),Family2::family()).

family_field(F) ->
    family_union(family_domain(F),family_range(F)).

-spec(family_union(Family1,Family2) -> Family3 when Family1::family(),Family2::family(),Family3::family()).

family_union(F1,F2) ->
    fam_binop(F1,F2,fun fam_union/3).

-spec(family_intersection(Family1,Family2) -> Family3 when Family1::family(),Family2::family(),Family3::family()).

family_intersection(F1,F2) ->
    fam_binop(F1,F2,fun fam_intersect/3).

-spec(family_difference(Family1,Family2) -> Family3 when Family1::family(),Family2::family(),Family3::family()).

family_difference(F1,F2) ->
    fam_binop(F1,F2,fun fam_difference/3).

fam_binop(F1,F2,FF)
    when is_record(F1,'Set'),
    is_record(F2,'Set')->
    case unify_types(F1#'Set'.type,F2#'Set'.type) of
        []->
            error(type_mismatch);
        _->
            F1;
        Type = {_,[_]}->
            #'Set'{data = FF(F1#'Set'.data,F2#'Set'.data,[]),type = Type};
        _->
            error(badarg)
    end.

-spec(partition_family(SetFun,Set) -> Family when Family::family(),SetFun::set_fun(),Set::a_set()).

partition_family(I,Set)
    when is_integer(I),
    is_record(Set,'Set')->
    Type = Set#'Set'.type,
    case check_for_sort(Type,I) of
        empty->
            Set;
        error->
            error(badarg);
        false->
            #'Set'{data = fam_partition_n(I,Set#'Set'.data),type = {element(I,Type),[Type]}};
        true->
            #'Set'{data = fam_partition_n(I,keysort(I,Set#'Set'.data)),type = {element(I,Type),[Type]}}
    end;
partition_family(SetFun,Set)
    when is_record(Set,'Set')->
    Type = Set#'Set'.type,
    SL = Set#'Set'.data,
    case external_fun(SetFun) of
        false
            when SL =/= []->
            case subst(SL,SetFun,element_type(Type)) of
                {NSL,NewType}->
                    P = fam_partition(converse(NSL,[]),true),
                    #'Set'{data = reverse(P),type = {NewType,[Type]}};
                Bad->
                    error(Bad)
            end;
        false->
            empty_set();
        _
            when Type =:= _->
            empty_set();
        _XFun
            when is_list(Type)->
            error(badarg);
        XFun->
            DType = XFun(Type),
            try check_fun(Type,XFun,DType) of 
                Sort->
                    Ts = inverse_substitution(Set#'Set'.data,XFun,Sort),
                    P = fam_partition(Ts,Sort),
                    #'Set'{data = reverse(P),type = {DType,[Type]}}
                catch
                    _:_->
                        error(badarg) end
    end.

-spec(family_projection(SetFun,Family1) -> Family2 when SetFun::set_fun(),Family1::family(),Family2::family()).

family_projection(SetFun,F)
    when is_record(F,'Set')->
    case F#'Set'.type of
        {_,[_]}
            when [] =:= F#'Set'.data->
            empty_set();
        {DT,[Type]}->
            case external_fun(SetFun) of
                false->
                    case fam_proj(F#'Set'.data,SetFun,Type,_,[]) of
                        {SL,NewType}->
                            #'Set'{data = SL,type = {DT,NewType}};
                        Bad->
                            error(Bad)
                    end;
                _->
                    error(badarg)
            end;
        _->
            F;
        _->
            error(badarg)
    end.

-spec(family_to_digraph(Family) -> Graph when Graph::digraph:graph(),Family::family()).

family_to_digraph(F)
    when is_record(F,'Set')->
    case F#'Set'.type of
        {_,[_]}->
            fam2digraph(F,digraph:new());
        _->
            digraph:new();
        _Else->
            error(badarg)
    end.

-spec(family_to_digraph(Family,GraphType) -> Graph when Graph::digraph:graph(),Family::family(),GraphType::[digraph:d_type()]).

family_to_digraph(F,Type)
    when is_record(F,'Set')->
    case F#'Set'.type of
        {_,[_]}->
            ok;
        _->
            ok;
        _Else->
            error(badarg)
    end,
    try digraph:new(Type) of 
        G->
            case  catch fam2digraph(F,G) of
                {error,Reason}->
                    true = digraph:delete(G),
                    error(Reason);
                _->
                    G
            end
        catch
            error:badarg->
                error(badarg) end.

-spec(digraph_to_family(Graph) -> Family when Graph::digraph:graph(),Family::family()).

digraph_to_family(G) ->
    try digraph_family(G) of 
        L->
            #'Set'{data = L,type = {atom,[atom]}}
        catch
            _:_->
                error(badarg) end.

-spec(digraph_to_family(Graph,Type) -> Family when Graph::digraph:graph(),Family::family(),Type::type()).

digraph_to_family(G,T) ->
    case {is_type(T),T} of
        {true,[{_,[_]} = Type]}->
            try digraph_family(G) of 
                L->
                    #'Set'{data = L,type = Type}
                catch
                    _:_->
                        error(badarg) end;
        _->
            error(badarg)
    end.

is_types(0,_T) ->
    true;
is_types(I,T) ->
    case is_type(element(I,T)) of
        true->
            is_types(I - 1,T);
        false->
            false
    end.

is_element_type(_) ->
    true;
is_element_type(T) ->
    is_type(T).

set_of_sets([S| Ss],L,T0)
    when is_record(S,'Set')->
    case unify_types([S#'Set'.type],T0) of
        []->
            {error,type_mismatch};
        Type->
            set_of_sets(Ss,[S#'Set'.data| L],Type)
    end;
set_of_sets([S| Ss],L,T0)
    when is_record(S,'OrdSet')->
    case unify_types(S#'OrdSet'.ordtype,T0) of
        []->
            {error,type_mismatch};
        Type->
            set_of_sets(Ss,[S#'OrdSet'.orddata| L],Type)
    end;
set_of_sets([],L,T) ->
    #'Set'{data = usort(L),type = T};
set_of_sets(_,_L,_T) ->
    {error,badarg}.

ordset_of_sets([S| Ss],L,T)
    when is_record(S,'Set')->
    ordset_of_sets(Ss,[S#'Set'.data| L],[[S#'Set'.type]| T]);
ordset_of_sets([S| Ss],L,T)
    when is_record(S,'OrdSet')->
    ordset_of_sets(Ss,[S#'OrdSet'.orddata| L],[S#'OrdSet'.ordtype| T]);
ordset_of_sets([],L,T) ->
    #'OrdSet'{orddata = list_to_tuple(reverse(L)),ordtype = list_to_tuple(reverse(T))};
ordset_of_sets(_,_L,_T) ->
    error.

rel(Ts,[Type]) ->
    case is_type(Type) and atoms_only(Type,1) of
        true->
            rel(Ts,tuple_size(Type),Type);
        false->
            rel_type(Ts,[],Type)
    end;
rel(Ts,Sz) ->
    rel(Ts,Sz,erlang:make_tuple(Sz,atom)).

atoms_only(Type,I)
    when is_atom(element(I,Type))->
    atoms_only(Type,I + 1);
atoms_only(Type,I)
    when I > tuple_size(Type),
    is_tuple(Type)->
    true;
atoms_only(_Type,_I) ->
    false.

rel(Ts,Sz,Type)
    when Sz >= 1->
    SL = usort(Ts),
    rel(SL,SL,Sz,Type).

rel([T| Ts],L,Sz,Type)
    when tuple_size(T) =:= Sz->
    rel(Ts,L,Sz,Type);
rel([],L,_Sz,Type) ->
    #'Set'{data = L,type = Type}.

rel_type([E| Ts],L,Type) ->
    {NType,NE} = make_element(E,Type,Type),
    rel_type(Ts,[NE| L],NType);
rel_type([],[],_) ->
    empty_set();
rel_type([],SL,Type)
    when is_tuple(Type)->
    #'Set'{data = usort(SL),type = Type}.

a_func(Ts,T) ->
    case {T,is_type(T)} of
        {[{DT,RT} = Type],true}
            when is_atom(DT),
            is_atom(RT)->
            func(Ts,Type);
        {[Type],true}->
            func_type(Ts,[],Type,fun ({_,_})->
                true end)
    end.

func(L0,Type) ->
    L = usort(L0),
    func(L,L,L,Type).

func([{X,_}| Ts],X0,L,Type)
    when X /= X0->
    func(Ts,X,L,Type);
func([{X,_}| _Ts],X0,_L,_Type)
    when X == X0->
    bad_function;
func([],_X0,L,Type) ->
    #'Set'{data = L,type = Type}.

fam(Ts,T) ->
    case {T,is_type(T)} of
        {[{DT,[RT]} = Type],true}
            when is_atom(DT),
            is_atom(RT)->
            fam2(Ts,Type);
        {[Type],true}->
            func_type(Ts,[],Type,fun ({_,[_]})->
                true end)
    end.

fam2([],Type) ->
    #'Set'{data = [],type = Type};
fam2(Ts,Type) ->
    fam2(sort(Ts),Ts,[],Type).

fam2([{I,L}| T],I0,SL,Type)
    when I /= I0->
    fam2(T,I,[{I,usort(L)}| SL],Type);
fam2([{I,L}| T],I0,SL,Type)
    when I == I0->
    case {usort(L),SL} of
        {NL,[{_I,NL1}| _]}
            when NL == NL1->
            fam2(T,I0,SL,Type);
        _->
            bad_function
    end;
fam2([],_I0,SL,Type) ->
    #'Set'{data = reverse(SL),type = Type}.

func_type([E| T],SL,Type,F) ->
    {NType,NE} = make_element(E,Type,Type),
    func_type(T,[NE| SL],NType,F);
func_type([],[],_,_F) ->
    empty_set();
func_type([],SL,Type,F) ->
    true = F(Type),
    NL = usort(SL),
    check_function(NL,#'Set'{data = NL,type = Type}).

setify(L,[Atom])
    when is_atom(Atom),
    Atom =/= _->
    #'Set'{data = usort(L),type = Atom};
setify(L,[Type0]) ->
    try is_no_lists(Type0) of 
        N
            when is_integer(N)->
            rel(L,N,Type0);
        Sizes->
            make_oset(L,Sizes,L,Type0)
        catch
            _:_->
                {[Type],Set} = create(L,Type0,Type0,[]),
                #'Set'{data = Set,type = Type} end;
setify(E,Type0) ->
    {Type,OrdSet} = make_element(E,Type0,Type0),
    #'OrdSet'{orddata = OrdSet,ordtype = Type}.

is_no_lists(T)
    when is_tuple(T)->
    Sz = tuple_size(T),
    is_no_lists(T,Sz,Sz,[]).

is_no_lists(_T,0,Sz,[]) ->
    Sz;
is_no_lists(_T,0,Sz,L) ->
    {Sz,L};
is_no_lists(T,I,Sz,L)
    when is_atom(element(I,T))->
    is_no_lists(T,I - 1,Sz,L);
is_no_lists(T,I,Sz,L) ->
    is_no_lists(T,I - 1,Sz,[{I,is_no_lists(element(I,T))}| L]).

create([E| Es],T,T0,L) ->
    {NT,S} = make_element(E,T,T0),
    create(Es,NT,T0,[S| L]);
create([],T,_T0,L) ->
    {[T],usort(L)}.

make_element(C,_,_T0) ->
    make_element(C);
make_element(C,Atom,_)
    when is_atom(Atom),
     not is_list(C),
     not is_tuple(C)->
    {Atom,C};
make_element(C,Atom,Atom)
    when is_atom(Atom)->
    {Atom,C};
make_element(T,TT,_)
    when tuple_size(T) =:= tuple_size(TT)->
    make_tuple(tuple_to_list(T),tuple_to_list(TT),[],[],_);
make_element(T,TT,T0)
    when tuple_size(T) =:= tuple_size(TT)->
    make_tuple(tuple_to_list(T),tuple_to_list(TT),[],[],tuple_to_list(T0));
make_element(L,[LT],_)
    when is_list(L)->
    create(L,LT,_,[]);
make_element(L,[LT],[T0])
    when is_list(L)->
    create(L,LT,T0,[]).

make_tuple([E| Es],[T| Ts],NT,L,T0)
    when T0 =:= _->
    {ET,ES} = make_element(E,T,T0),
    make_tuple(Es,Ts,[ET| NT],[ES| L],T0);
make_tuple([E| Es],[T| Ts],NT,L,[T0| T0s]) ->
    {ET,ES} = make_element(E,T,T0),
    make_tuple(Es,Ts,[ET| NT],[ES| L],T0s);
make_tuple([],[],NT,L,_T0s)
    when NT =/= []->
    {list_to_tuple(reverse(NT)),list_to_tuple(reverse(L))}.

make_element(C)
    when  not is_list(C),
     not is_tuple(C)->
    {atom,C};
make_element(T)
    when is_tuple(T)->
    make_tuple(tuple_to_list(T),[],[]);
make_element(L)
    when is_list(L)->
    create(L,_,_,[]).

make_tuple([E| Es],T,L) ->
    {ET,ES} = make_element(E),
    make_tuple(Es,[ET| T],[ES| L]);
make_tuple([],T,L)
    when T =/= []->
    {list_to_tuple(reverse(T)),list_to_tuple(reverse(L))}.

make_oset([T| Ts],Szs,L,Type) ->
    true = test_oset(Szs,T,T),
    make_oset(Ts,Szs,L,Type);
make_oset([],_Szs,L,Type) ->
    #'Set'{data = usort(L),type = Type}.

test_oset({Sz,Args},T,T0)
    when tuple_size(T) =:= Sz->
    test_oset_args(Args,T,T0);
test_oset(Sz,T,_T0)
    when tuple_size(T) =:= Sz->
    true.

test_oset_args([{Arg,Szs}| Ss],T,T0) ->
    true = test_oset(Szs,element(Arg,T),T0),
    test_oset_args(Ss,T,T0);
test_oset_args([],_T,_T0) ->
    true.

list_of_sets([S| Ss],Type,L) ->
    list_of_sets(Ss,Type,[#'Set'{data = S,type = Type}| L]);
list_of_sets([],_Type,L) ->
    reverse(L).

list_of_ordsets([S| Ss],Type,L) ->
    list_of_ordsets(Ss,Type,[#'OrdSet'{orddata = S,ordtype = Type}| L]);
list_of_ordsets([],_Type,L) ->
    reverse(L).

tuple_of_sets([S| Ss],[[Type]| Types],L) ->
    tuple_of_sets(Ss,Types,[#'Set'{data = S,type = Type}| L]);
tuple_of_sets([S| Ss],[Type| Types],L) ->
    tuple_of_sets(Ss,Types,[#'OrdSet'{orddata = S,ordtype = Type}| L]);
tuple_of_sets([],[],L) ->
    list_to_tuple(reverse(L)).

spec([E| Es],Fun,Type,L) ->
    case Fun(term2set(E,Type)) of
        true->
            spec(Es,Fun,Type,[E| L]);
        false->
            spec(Es,Fun,Type,L);
        _->
            badarg
    end;
spec([],_Fun,_Type,L) ->
    reverse(L).

specification([E| Es],Fun,L) ->
    case Fun(E) of
        true->
            specification(Es,Fun,[E| L]);
        false->
            specification(Es,Fun,L);
        _->
            badarg
    end;
specification([],_Fun,L) ->
    reverse(L).

intersection([H1| T1],[H2| T2],L)
    when H1 < H2->
    intersection1(T1,T2,L,H2);
intersection([H1| T1],[H2| T2],L)
    when H1 == H2->
    intersection(T1,T2,[H1| L]);
intersection([H1| T1],[_H2| T2],L) ->
    intersection2(T1,T2,L,H1);
intersection(_,_,L) ->
    reverse(L).

intersection1([H1| T1],T2,L,H2)
    when H1 < H2->
    intersection1(T1,T2,L,H2);
intersection1([H1| T1],T2,L,H2)
    when H1 == H2->
    intersection(T1,T2,[H1| L]);
intersection1([H1| T1],T2,L,_H2) ->
    intersection2(T1,T2,L,H1);
intersection1(_,_,L,_) ->
    reverse(L).

intersection2(T1,[H2| T2],L,H1)
    when H1 > H2->
    intersection2(T1,T2,L,H1);
intersection2(T1,[H2| T2],L,H1)
    when H1 == H2->
    intersection(T1,T2,[H1| L]);
intersection2(T1,[H2| T2],L,_H1) ->
    intersection1(T1,T2,L,H2);
intersection2(_,_,L,_) ->
    reverse(L).

difference([H1| T1],[H2| T2],L)
    when H1 < H2->
    diff(T1,T2,[H1| L],H2);
difference([H1| T1],[H2| T2],L)
    when H1 == H2->
    difference(T1,T2,L);
difference([H1| T1],[_H2| T2],L) ->
    diff2(T1,T2,L,H1);
difference(L1,_,L) ->
    reverse(L,L1).

diff([H1| T1],T2,L,H2)
    when H1 < H2->
    diff(T1,T2,[H1| L],H2);
diff([H1| T1],T2,L,H2)
    when H1 == H2->
    difference(T1,T2,L);
diff([H1| T1],T2,L,_H2) ->
    diff2(T1,T2,L,H1);
diff(_,_,L,_) ->
    reverse(L).

diff2(T1,[H2| T2],L,H1)
    when H1 > H2->
    diff2(T1,T2,L,H1);
diff2(T1,[H2| T2],L,H1)
    when H1 == H2->
    difference(T1,T2,L);
diff2(T1,[H2| T2],L,H1) ->
    diff(T1,T2,[H1| L],H2);
diff2(T1,_,L,H1) ->
    reverse(L,[H1| T1]).

symdiff([H1| T1],T2,L) ->
    symdiff2(T1,T2,L,H1);
symdiff(_,T2,L) ->
    reverse(L,T2).

symdiff1([H1| T1],T2,L,H2)
    when H1 < H2->
    symdiff1(T1,T2,[H1| L],H2);
symdiff1([H1| T1],T2,L,H2)
    when H1 == H2->
    symdiff(T1,T2,L);
symdiff1([H1| T1],T2,L,H2) ->
    symdiff2(T1,T2,[H2| L],H1);
symdiff1(_,T2,L,H2) ->
    reverse(L,[H2| T2]).

symdiff2(T1,[H2| T2],L,H1)
    when H1 > H2->
    symdiff2(T1,T2,[H2| L],H1);
symdiff2(T1,[H2| T2],L,H1)
    when H1 == H2->
    symdiff(T1,T2,L);
symdiff2(T1,[H2| T2],L,H1) ->
    symdiff1(T1,T2,[H1| L],H2);
symdiff2(T1,_,L,H1) ->
    reverse(L,[H1| T1]).

sympart([H1| T1],[H2| T2],L1,L12,L2,T)
    when H1 < H2->
    sympart1(T1,T2,[H1| L1],L12,L2,T,H2);
sympart([H1| T1],[H2| T2],L1,L12,L2,T)
    when H1 == H2->
    sympart(T1,T2,L1,[H1| L12],L2,T);
sympart([H1| T1],[H2| T2],L1,L12,L2,T) ->
    sympart2(T1,T2,L1,L12,[H2| L2],T,H1);
sympart(S1,[],L1,L12,L2,T) ->
    {#'Set'{data = reverse(L1,S1),type = T},#'Set'{data = reverse(L12),type = T},#'Set'{data = reverse(L2),type = T}};
sympart(_,S2,L1,L12,L2,T) ->
    {#'Set'{data = reverse(L1),type = T},#'Set'{data = reverse(L12),type = T},#'Set'{data = reverse(L2,S2),type = T}}.

sympart1([H1| T1],T2,L1,L12,L2,T,H2)
    when H1 < H2->
    sympart1(T1,T2,[H1| L1],L12,L2,T,H2);
sympart1([H1| T1],T2,L1,L12,L2,T,H2)
    when H1 == H2->
    sympart(T1,T2,L1,[H1| L12],L2,T);
sympart1([H1| T1],T2,L1,L12,L2,T,H2) ->
    sympart2(T1,T2,L1,L12,[H2| L2],T,H1);
sympart1(_,T2,L1,L12,L2,T,H2) ->
    {#'Set'{data = reverse(L1),type = T},#'Set'{data = reverse(L12),type = T},#'Set'{data = reverse(L2,[H2| T2]),type = T}}.

sympart2(T1,[H2| T2],L1,L12,L2,T,H1)
    when H1 > H2->
    sympart2(T1,T2,L1,L12,[H2| L2],T,H1);
sympart2(T1,[H2| T2],L1,L12,L2,T,H1)
    when H1 == H2->
    sympart(T1,T2,L1,[H1| L12],L2,T);
sympart2(T1,[H2| T2],L1,L12,L2,T,H1) ->
    sympart1(T1,T2,[H1| L1],L12,L2,T,H2);
sympart2(T1,_,L1,L12,L2,T,H1) ->
    {#'Set'{data = reverse(L1,[H1| T1]),type = T},#'Set'{data = reverse(L12),type = T},#'Set'{data = reverse(L2),type = T}}.

prod([[E| Es]| Xs],T,L) ->
    prod(Es,Xs,T,prod(Xs,[E| T],L));
prod([],T,L) ->
    [list_to_tuple(reverse(T))| L].

prod([E| Es],Xs,T,L) ->
    prod(Es,Xs,T,prod(Xs,[E| T],L));
prod([],_Xs,_E,L) ->
    L.

constant_function([E| Es],X,L) ->
    constant_function(Es,X,[{E,X}| L]);
constant_function([],_X,L) ->
    reverse(L).

subset([H1| T1],[H2| T2])
    when H1 > H2->
    subset(T1,T2,H1);
subset([H1| T1],[H2| T2])
    when H1 == H2->
    subset(T1,T2);
subset(L1,_) ->
    L1 =:= [].

subset(T1,[H2| T2],H1)
    when H1 > H2->
    subset(T1,T2,H1);
subset(T1,[H2| T2],H1)
    when H1 == H2->
    subset(T1,T2);
subset(_,_,_) ->
    false.

disjoint([B| Bs],A,As)
    when A < B->
    disjoint(As,B,Bs);
disjoint([B| _Bs],A,_As)
    when A == B->
    false;
disjoint([_B| Bs],A,As) ->
    disjoint(Bs,A,As);
disjoint(_Bs,_A,_As) ->
    true.

lunion([[_] = S]) ->
    S;
lunion([[]| Ls]) ->
    lunion(Ls);
lunion([S| Ss]) ->
    umerge(lunion(Ss,last(S),[S],[]));
lunion([]) ->
    [].

lunion([[E] = S| Ss],Last,SL,Ls)
    when E > Last->
    lunion(Ss,E,[S| SL],Ls);
lunion([S| Ss],Last,SL,Ls)
    when hd(S) > Last->
    lunion(Ss,last(S),[S| SL],Ls);
lunion([S| Ss],_Last,SL,Ls) ->
    lunion(Ss,last(S),[S],[append(reverse(SL))| Ls]);
lunion([],_Last,SL,Ls) ->
    [append(reverse(SL))| Ls].

lintersection(_,[]) ->
    [];
lintersection([S| Ss],S0) ->
    lintersection(Ss,intersection(S,S0,[]));
lintersection([],S) ->
    S.

can_rel([S| Ss],L) ->
    can_rel(Ss,L,S,S);
can_rel([],L) ->
    sort(L).

can_rel(Ss,L,[E| Es],S) ->
    can_rel(Ss,[{E,S}| L],Es,S);
can_rel(Ss,L,_,_S) ->
    can_rel(Ss,L).

rel2family([{X,Y}| S]) ->
    rel2fam(S,X,[Y],[]);
rel2family([]) ->
    [].

rel2fam([{X,Y}| S],X0,YL,L)
    when X0 == X->
    rel2fam(S,X0,[Y| YL],L);
rel2fam([{X,Y}| S],X0,[A, B| YL],L) ->
    rel2fam(S,X,[Y],[{X0,reverse(YL,[B, A])}| L]);
rel2fam([{X,Y}| S],X0,YL,L) ->
    rel2fam(S,X,[Y],[{X0,YL}| L]);
rel2fam([],X,YL,L) ->
    reverse([{X,reverse(YL)}| L]).

dom([{X,_}| Es]) ->
    dom([],X,Es);
dom([] = L) ->
    L.

dom(L,X,[{X1,_}| Es])
    when X == X1->
    dom(L,X,Es);
dom(L,X,[{Y,_}| Es]) ->
    dom([X| L],Y,Es);
dom(L,X,[]) ->
    reverse(L,[X]).

ran([{_,Y}| Es],L) ->
    ran(Es,[Y| L]);
ran([],L) ->
    usort(L).

relprod(A,B) ->
    usort(relprod1(A,B)).

relprod1([{Ay,Ax}| A],B) ->
    relprod1(B,Ay,Ax,A,[]);
relprod1(_A,_B) ->
    [].

relprod1([{Bx,_By}| B],Ay,Ax,A,L)
    when Ay > Bx->
    relprod1(B,Ay,Ax,A,L);
relprod1([{Bx,By}| B],Ay,Ax,A,L)
    when Ay == Bx->
    relprod(B,Bx,By,A,[{Ax,By}| L],Ax,B,Ay);
relprod1([{Bx,By}| B],_Ay,_Ax,A,L) ->
    relprod2(B,Bx,By,A,L);
relprod1(_B,_Ay,_Ax,_A,L) ->
    L.

relprod2(B,Bx,By,[{Ay,_Ax}| A],L)
    when Ay < Bx->
    relprod2(B,Bx,By,A,L);
relprod2(B,Bx,By,[{Ay,Ax}| A],L)
    when Ay == Bx->
    relprod(B,Bx,By,A,[{Ax,By}| L],Ax,B,Ay);
relprod2(B,_Bx,_By,[{Ay,Ax}| A],L) ->
    relprod1(B,Ay,Ax,A,L);
relprod2(_,_,_,_,L) ->
    L.

relprod(B0,Bx0,By0,A0,L,Ax,[{Bx,By}| B],Ay)
    when Ay == Bx->
    relprod(B0,Bx0,By0,A0,[{Ax,By}| L],Ax,B,Ay);
relprod(B0,Bx0,By0,A0,L,_Ax,_B,_Ay) ->
    relprod2(B0,Bx0,By0,A0,L).

relprod_n([],_R,_EmptyG,_IsR) ->
    {error,badarg};
relprod_n(RL,R,EmptyR,IsR) ->
    case domain_type(RL,_) of
        Error = {error,_Reason}->
            Error;
        DType->
            Empty = any(fun is_empty_set/1,RL) or EmptyR,
            RType = range_type(RL,[]),
            Type = {DType,RType},
            Prod = case Empty of
                true
                    when DType =:= _;
                    RType =:= _->
                    empty_set();
                true->
                    #'Set'{data = [],type = Type};
                false->
                    TL = (relprod_n(RL))#'Set'.data,
                    Sz = length(RL),
                    Fun = fun ({X,A})->
                        {X,flat(Sz,A,[])} end,
                    #'Set'{data = map(Fun,TL),type = Type}
            end,
            case IsR of
                true->
                    relative_product(Prod,R);
                false->
                    Prod
            end
    end.

relprod_n([R| Rs]) ->
    relprod_n(Rs,R).

relprod_n([],R) ->
    R;
relprod_n([R| Rs],R0) ->
    T = raise_element(R0,1),
    R1 = relative_product1(T,R),
    NR = projection({external,fun ({{X,A},AS})->
        {X,{A,AS}} end},R1),
    relprod_n(Rs,NR).

flat(1,A,L) ->
    list_to_tuple([A| L]);
flat(N,{T,A},L) ->
    flat(N - 1,T,[A| L]).

domain_type([T| Ts],T0)
    when is_record(T,'Set')->
    case T#'Set'.type of
        {DT,_RT}->
            case unify_types(DT,T0) of
                []->
                    {error,type_mismatch};
                T1->
                    domain_type(Ts,T1)
            end;
        _->
            domain_type(Ts,T0);
        _->
            {error,badarg}
    end;
domain_type([],T0) ->
    T0.

range_type([T| Ts],L) ->
    case T#'Set'.type of
        {_DT,RT}->
            range_type(Ts,[RT| L]);
        _->
            _
    end;
range_type([],L) ->
    list_to_tuple(reverse(L)).

converse([{A,B}| X],L) ->
    converse(X,[{B,A}| L]);
converse([],L) ->
    sort(L).

strict([{E1,E2}| Es],L)
    when E1 == E2->
    strict(Es,L);
strict([E| Es],L) ->
    strict(Es,[E| L]);
strict([],L) ->
    reverse(L).

weak(Es) ->
    weak(Es,ran(Es,[]),[]).

weak(Es = [{X,_}| _],[Y| Ys],L)
    when X > Y->
    weak(Es,Ys,[{Y,Y}| L]);
weak(Es = [{X,_}| _],[Y| Ys],L)
    when X == Y->
    weak(Es,Ys,L);
weak([E = {X,Y}| Es],Ys,L)
    when X > Y->
    weak1(Es,Ys,[E| L],X);
weak([E = {X,Y}| Es],Ys,L)
    when X == Y->
    weak2(Es,Ys,[E| L],X);
weak([E = {X,_Y}| Es],Ys,L) ->
    weak2(Es,Ys,[E, {X,X}| L],X);
weak([],[Y| Ys],L) ->
    weak([],Ys,[{Y,Y}| L]);
weak([],[],L) ->
    reverse(L).

weak1([E = {X,Y}| Es],Ys,L,X0)
    when X > Y,
    X == X0->
    weak1(Es,Ys,[E| L],X);
weak1([E = {X,Y}| Es],Ys,L,X0)
    when X == Y,
    X == X0->
    weak2(Es,Ys,[E| L],X);
weak1([E = {X,_Y}| Es],Ys,L,X0)
    when X == X0->
    weak2(Es,Ys,[E, {X,X}| L],X);
weak1(Es,Ys,L,X) ->
    weak(Es,Ys,[{X,X}| L]).

weak2([E = {X,_Y}| Es],Ys,L,X0)
    when X == X0->
    weak2(Es,Ys,[E| L],X);
weak2(Es,Ys,L,_X) ->
    weak(Es,Ys,L).

extc(L,[D| Ds],C,Ts) ->
    extc(L,Ds,C,Ts,D);
extc(L,[],_C,_Ts) ->
    L.

extc(L,Ds,C,[{X,_Y}| Ts],D)
    when X < D->
    extc(L,Ds,C,Ts,D);
extc(L,Ds,C,[{X,_Y}| Ts],D)
    when X == D->
    extc(L,Ds,C,Ts);
extc(L,Ds,C,[{X,_Y}| Ts],D) ->
    extc2([{D,C}| L],Ds,C,Ts,X);
extc(L,Ds,C,[],D) ->
    extc_tail([{D,C}| L],Ds,C).

extc2(L,[D| Ds],C,Ts,X)
    when X > D->
    extc2([{D,C}| L],Ds,C,Ts,X);
extc2(L,[D| Ds],C,Ts,X)
    when X == D->
    extc(L,Ds,C,Ts);
extc2(L,[D| Ds],C,Ts,_X) ->
    extc(L,Ds,C,Ts,D);
extc2(L,[],_C,_Ts,_X) ->
    L.

extc_tail(L,[D| Ds],C) ->
    extc_tail([{D,C}| L],Ds,C);
extc_tail(L,[],_C) ->
    L.

is_a_func([{E,_}| Es],E0)
    when E /= E0->
    is_a_func(Es,E);
is_a_func(L,_E) ->
    L =:= [].

restrict_n(I,[T| Ts],Key,Keys,L) ->
    case element(I,T) of
        K
            when K < Key->
            restrict_n(I,Ts,Key,Keys,L);
        K
            when K == Key->
            restrict_n(I,Ts,Key,Keys,[T| L]);
        K->
            restrict_n(I,K,Ts,Keys,L,T)
    end;
restrict_n(_I,_Ts,_Key,_Keys,L) ->
    L.

restrict_n(I,K,Ts,[Key| Keys],L,E)
    when K > Key->
    restrict_n(I,K,Ts,Keys,L,E);
restrict_n(I,K,Ts,[Key| Keys],L,E)
    when K == Key->
    restrict_n(I,Ts,Key,Keys,[E| L]);
restrict_n(I,_K,Ts,[Key| Keys],L,_E) ->
    restrict_n(I,Ts,Key,Keys,L);
restrict_n(_I,_K,_Ts,_Keys,L,_E) ->
    L.

restrict([Key| Keys],Tuples) ->
    restrict(Tuples,Key,Keys,[]);
restrict(_Keys,_Tuples) ->
    [].

restrict([{K,_E}| Ts],Key,Keys,L)
    when K < Key->
    restrict(Ts,Key,Keys,L);
restrict([{K,E}| Ts],Key,Keys,L)
    when K == Key->
    restrict(Ts,Key,Keys,[E| L]);
restrict([{K,E}| Ts],_Key,Keys,L) ->
    restrict(Ts,K,Keys,L,E);
restrict(_Ts,_Key,_Keys,L) ->
    L.

restrict(Ts,K,[Key| Keys],L,E)
    when K > Key->
    restrict(Ts,K,Keys,L,E);
restrict(Ts,K,[Key| Keys],L,E)
    when K == Key->
    restrict(Ts,Key,Keys,[E| L]);
restrict(Ts,_K,[Key| Keys],L,_E) ->
    restrict(Ts,Key,Keys,L);
restrict(_Ts,_K,_Keys,L,_E) ->
    L.

diff_restrict_n(I,[T| Ts],Key,Keys,L) ->
    case element(I,T) of
        K
            when K < Key->
            diff_restrict_n(I,Ts,Key,Keys,[T| L]);
        K
            when K == Key->
            diff_restrict_n(I,Ts,Key,Keys,L);
        K->
            diff_restrict_n(I,K,Ts,Keys,L,T)
    end;
diff_restrict_n(I,_Ts,_Key,_Keys,L)
    when I =:= 1->
    reverse(L);
diff_restrict_n(_I,_Ts,_Key,_Keys,L) ->
    sort(L).

diff_restrict_n(I,K,Ts,[Key| Keys],L,T)
    when K > Key->
    diff_restrict_n(I,K,Ts,Keys,L,T);
diff_restrict_n(I,K,Ts,[Key| Keys],L,_T)
    when K == Key->
    diff_restrict_n(I,Ts,Key,Keys,L);
diff_restrict_n(I,_K,Ts,[Key| Keys],L,T) ->
    diff_restrict_n(I,Ts,Key,Keys,[T| L]);
diff_restrict_n(I,_K,Ts,_Keys,L,T)
    when I =:= 1->
    reverse(L,[T| Ts]);
diff_restrict_n(_I,_K,Ts,_Keys,L,T) ->
    sort([T| Ts ++ L]).

diff_restrict([Key| Keys],Tuples) ->
    diff_restrict(Tuples,Key,Keys,[]);
diff_restrict(_Keys,Tuples) ->
    diff_restrict_tail(Tuples,[]).

diff_restrict([{K,E}| Ts],Key,Keys,L)
    when K < Key->
    diff_restrict(Ts,Key,Keys,[E| L]);
diff_restrict([{K,_E}| Ts],Key,Keys,L)
    when K == Key->
    diff_restrict(Ts,Key,Keys,L);
diff_restrict([{K,E}| Ts],_Key,Keys,L) ->
    diff_restrict(Ts,K,Keys,L,E);
diff_restrict(_Ts,_Key,_Keys,L) ->
    L.

diff_restrict(Ts,K,[Key| Keys],L,E)
    when K > Key->
    diff_restrict(Ts,K,Keys,L,E);
diff_restrict(Ts,K,[Key| Keys],L,_E)
    when K == Key->
    diff_restrict(Ts,Key,Keys,L);
diff_restrict(Ts,_K,[Key| Keys],L,E) ->
    diff_restrict(Ts,Key,Keys,[E| L]);
diff_restrict(Ts,_K,_Keys,L,E) ->
    diff_restrict_tail(Ts,[E| L]).

diff_restrict_tail([{_K,E}| Ts],L) ->
    diff_restrict_tail(Ts,[E| L]);
diff_restrict_tail(_Ts,L) ->
    L.

comp([],B) ->
    check_function(B,[]);
comp(_A,[]) ->
    bad_function;
comp(A0,[{Bx,By}| B]) ->
    A = converse(A0,[]),
    check_function(A0,comp1(A,B,[],Bx,By)).

comp1([{Ay,Ax}| A],B,L,Bx,By)
    when Ay == Bx->
    comp1(A,B,[{Ax,By}| L],Bx,By);
comp1([{Ay,Ax}| A],B,L,Bx,_By)
    when Ay > Bx->
    comp2(A,B,L,Bx,Ay,Ax);
comp1([{Ay,_Ax}| _A],_B,_L,Bx,_By)
    when Ay < Bx->
    bad_function;
comp1([],B,L,Bx,_By) ->
    check_function(Bx,B,L).

comp2(A,[{Bx,_By}| B],L,Bx0,Ay,Ax)
    when Ay > Bx,
    Bx /= Bx0->
    comp2(A,B,L,Bx,Ay,Ax);
comp2(A,[{Bx,By}| B],L,_Bx0,Ay,Ax)
    when Ay == Bx->
    comp1(A,B,[{Ax,By}| L],Bx,By);
comp2(_A,_B,_L,_Bx0,_Ay,_Ax) ->
    bad_function.

inverse1([{A,B}| X]) ->
    inverse(X,A,[{B,A}]);
inverse1([]) ->
    [].

inverse([{A,B}| X],A0,L)
    when A0 /= A->
    inverse(X,A,[{B,A}| L]);
inverse([{A,_B}| _X],A0,_L)
    when A0 == A->
    bad_function;
inverse([],_A0,L) ->
    SL = [{V,_}| Es] = sort(L),
    case is_a_func(Es,V) of
        true->
            SL;
        false->
            bad_function
    end.

external_fun({external,Function})
    when is_atom(Function)->
    false;
external_fun({external,Fun}) ->
    Fun;
external_fun(_) ->
    false.

element_type([Type]) ->
    Type;
element_type(Type) ->
    Type.

subst(Ts,Fun,Type) ->
    subst(Ts,Fun,Type,_,[]).

subst([T| Ts],Fun,Type,NType,L) ->
    case setfun(T,Fun,Type,NType) of
        {SD,ST}->
            subst(Ts,Fun,Type,ST,[{T,SD}| L]);
        Bad->
            Bad
    end;
subst([],_Fun,_Type,NType,L) ->
    {L,NType}.

projection1([E| Es]) ->
    projection1([],element(1,E),Es);
projection1([] = L) ->
    L.

projection1(L,X,[E| Es]) ->
    case element(1,E) of
        X1
            when X == X1->
            projection1(L,X,Es);
        X1->
            projection1([X| L],X1,Es)
    end;
projection1(L,X,[]) ->
    reverse(L,[X]).

projection_n([E| Es],I,L) ->
    projection_n(Es,I,[element(I,E)| L]);
projection_n([],_I,L) ->
    usort(L).

substitute_element([T| Ts],I,L) ->
    substitute_element(Ts,I,[{T,element(I,T)}| L]);
substitute_element(_,_I,L) ->
    reverse(L).

substitute([T| Ts],Fun,L) ->
    substitute(Ts,Fun,[{T,Fun(T)}| L]);
substitute(_,_Fun,L) ->
    reverse(L).

partition_n(I,[E| Ts]) ->
    partition_n(I,Ts,element(I,E),[E],[]);
partition_n(_I,[]) ->
    [].

partition_n(I,[E| Ts],K,Es,P) ->
    case {element(I,E),Es} of
        {K1,_}
            when K == K1->
            partition_n(I,Ts,K,[E| Es],P);
        {K1,[_]}->
            partition_n(I,Ts,K1,[E],[Es| P]);
        {K1,_}->
            partition_n(I,Ts,K1,[E],[reverse(Es)| P])
    end;
partition_n(I,[],_K,Es,P)
    when I > 1->
    sort([reverse(Es)| P]);
partition_n(_I,[],_K,[_] = Es,P) ->
    reverse(P,[Es]);
partition_n(_I,[],_K,Es,P) ->
    reverse(P,[reverse(Es)]).

partition3_n(I,[T| Ts],Key,Keys,L1,L2) ->
    case element(I,T) of
        K
            when K < Key->
            partition3_n(I,Ts,Key,Keys,L1,[T| L2]);
        K
            when K == Key->
            partition3_n(I,Ts,Key,Keys,[T| L1],L2);
        K->
            partition3_n(I,K,Ts,Keys,L1,L2,T)
    end;
partition3_n(I,_Ts,_Key,_Keys,L1,L2)
    when I =:= 1->
    [reverse(L1)| reverse(L2)];
partition3_n(_I,_Ts,_Key,_Keys,L1,L2) ->
    [sort(L1)| sort(L2)].

partition3_n(I,K,Ts,[Key| Keys],L1,L2,T)
    when K > Key->
    partition3_n(I,K,Ts,Keys,L1,L2,T);
partition3_n(I,K,Ts,[Key| Keys],L1,L2,T)
    when K == Key->
    partition3_n(I,Ts,Key,Keys,[T| L1],L2);
partition3_n(I,_K,Ts,[Key| Keys],L1,L2,T) ->
    partition3_n(I,Ts,Key,Keys,L1,[T| L2]);
partition3_n(I,_K,Ts,_Keys,L1,L2,T)
    when I =:= 1->
    [reverse(L1)| reverse(L2,[T| Ts])];
partition3_n(_I,_K,Ts,_Keys,L1,L2,T) ->
    [sort(L1)| sort([T| Ts ++ L2])].

partition3([Key| Keys],Tuples) ->
    partition3(Tuples,Key,Keys,[],[]);
partition3(_Keys,Tuples) ->
    partition3_tail(Tuples,[],[]).

partition3([{K,E}| Ts],Key,Keys,L1,L2)
    when K < Key->
    partition3(Ts,Key,Keys,L1,[E| L2]);
partition3([{K,E}| Ts],Key,Keys,L1,L2)
    when K == Key->
    partition3(Ts,Key,Keys,[E| L1],L2);
partition3([{K,E}| Ts],_Key,Keys,L1,L2) ->
    partition3(Ts,K,Keys,L1,L2,E);
partition3(_Ts,_Key,_Keys,L1,L2) ->
    [L1| L2].

partition3(Ts,K,[Key| Keys],L1,L2,E)
    when K > Key->
    partition3(Ts,K,Keys,L1,L2,E);
partition3(Ts,K,[Key| Keys],L1,L2,E)
    when K == Key->
    partition3(Ts,Key,Keys,[E| L1],L2);
partition3(Ts,_K,[Key| Keys],L1,L2,E) ->
    partition3(Ts,Key,Keys,L1,[E| L2]);
partition3(Ts,_K,_Keys,L1,L2,E) ->
    partition3_tail(Ts,L1,[E| L2]).

partition3_tail([{_K,E}| Ts],L1,L2) ->
    partition3_tail(Ts,L1,[E| L2]);
partition3_tail(_Ts,L1,L2) ->
    [L1| L2].

replace([E| Es],F,L) ->
    replace(Es,F,[F(E)| L]);
replace(_,_F,L) ->
    sort(L).

mul_relprod([T| Ts],I,R)
    when is_record(T,'Set')->
    P = raise_element(R,I),
    F = relative_product1(P,T),
    [F| mul_relprod(Ts,I + 1,R)];
mul_relprod([],_I,_R) ->
    [].

raise_element(R,I) ->
    L = sort(I =/= 1,rearr(R#'Set'.data,I,[])),
    Type = R#'Set'.type,
    #'Set'{data = L,type = {element(I,Type),Type}}.

rearr([E| Es],I,L) ->
    rearr(Es,I,[{element(I,E),E}| L]);
rearr([],_I,L) ->
    L.

join_element(E1,E2) ->
    [_| L2] = tuple_to_list(E2),
    list_to_tuple(tuple_to_list(E1) ++ L2).

join_element(E1,E2,I2) ->
    tuple_to_list(E1) ++ join_element2(tuple_to_list(E2),1,I2).

join_element2([B| Bs],C,I2)
    when C =/= I2->
    [B| join_element2(Bs,C + 1,I2)];
join_element2([_| Bs],_C,_I2) ->
    Bs.

family2rel([{X,S}| F],L) ->
    fam2rel(F,L,X,S);
family2rel([],L) ->
    reverse(L).

fam2rel(F,L,X,[Y| Ys]) ->
    fam2rel(F,[{X,Y}| L],X,Ys);
fam2rel(F,L,_X,_) ->
    family2rel(F,L).

fam_spec([{_,S} = E| F],Fun,Type,L) ->
    case Fun(#'Set'{data = S,type = Type}) of
        true->
            fam_spec(F,Fun,Type,[E| L]);
        false->
            fam_spec(F,Fun,Type,L);
        _->
            badarg
    end;
fam_spec([],_Fun,_Type,L) ->
    reverse(L).

fam_specification([{_,S} = E| F],Fun,L) ->
    case Fun(S) of
        true->
            fam_specification(F,Fun,[E| L]);
        false->
            fam_specification(F,Fun,L);
        _->
            badarg
    end;
fam_specification([],_Fun,L) ->
    reverse(L).

un_of_fam([{_X,S}| F],L) ->
    un_of_fam(F,[S| L]);
un_of_fam([],L) ->
    lunion(sort(L)).

int_of_fam([{_,S}| F]) ->
    int_of_fam(F,[S]);
int_of_fam([]) ->
    badarg.

int_of_fam([{_,S}| F],L) ->
    int_of_fam(F,[S| L]);
int_of_fam([],[L| Ls]) ->
    lintersection(Ls,L).

fam_un([{X,S}| F],L) ->
    fam_un(F,[{X,lunion(S)}| L]);
fam_un([],L) ->
    reverse(L).

fam_int([{X,[S| Ss]}| F],L) ->
    fam_int(F,[{X,lintersection(Ss,S)}| L]);
fam_int([{_X,[]}| _F],_L) ->
    badarg;
fam_int([],L) ->
    reverse(L).

fam_dom([{X,S}| F],L) ->
    fam_dom(F,[{X,dom(S)}| L]);
fam_dom([],L) ->
    reverse(L).

fam_ran([{X,S}| F],L) ->
    fam_ran(F,[{X,ran(S,[])}| L]);
fam_ran([],L) ->
    reverse(L).

fam_union(F1 = [{A,_AS}| _AL],[B1 = {B,_BS}| BL],L)
    when A > B->
    fam_union(F1,BL,[B1| L]);
fam_union([{A,AS}| AL],[{B,BS}| BL],L)
    when A == B->
    fam_union(AL,BL,[{A,umerge(AS,BS)}| L]);
fam_union([A1| AL],F2,L) ->
    fam_union(AL,F2,[A1| L]);
fam_union(_,F2,L) ->
    reverse(L,F2).

fam_intersect(F1 = [{A,_AS}| _AL],[{B,_BS}| BL],L)
    when A > B->
    fam_intersect(F1,BL,L);
fam_intersect([{A,AS}| AL],[{B,BS}| BL],L)
    when A == B->
    fam_intersect(AL,BL,[{A,intersection(AS,BS,[])}| L]);
fam_intersect([_A1| AL],F2,L) ->
    fam_intersect(AL,F2,L);
fam_intersect(_,_,L) ->
    reverse(L).

fam_difference(F1 = [{A,_AS}| _AL],[{B,_BS}| BL],L)
    when A > B->
    fam_difference(F1,BL,L);
fam_difference([{A,AS}| AL],[{B,BS}| BL],L)
    when A == B->
    fam_difference(AL,BL,[{A,difference(AS,BS,[])}| L]);
fam_difference([A1| AL],F2,L) ->
    fam_difference(AL,F2,[A1| L]);
fam_difference(F1,_,L) ->
    reverse(L,F1).

check_function([{X,_}| XL],R) ->
    check_function(X,XL,R);
check_function([],R) ->
    R.

check_function(X0,[{X,_}| XL],R)
    when X0 /= X->
    check_function(X,XL,R);
check_function(X0,[{X,_}| _XL],_R)
    when X0 == X->
    bad_function;
check_function(_X0,[],R) ->
    R.

fam_partition_n(I,[E| Ts]) ->
    fam_partition_n(I,Ts,element(I,E),[E],[]);
fam_partition_n(_I,[]) ->
    [].

fam_partition_n(I,[E| Ts],K,Es,P) ->
    case {element(I,E),Es} of
        {K1,_}
            when K == K1->
            fam_partition_n(I,Ts,K,[E| Es],P);
        {K1,[_]}->
            fam_partition_n(I,Ts,K1,[E],[{K,Es}| P]);
        {K1,_}->
            fam_partition_n(I,Ts,K1,[E],[{K,reverse(Es)}| P])
    end;
fam_partition_n(_I,[],K,[_] = Es,P) ->
    reverse(P,[{K,Es}]);
fam_partition_n(_I,[],K,Es,P) ->
    reverse(P,[{K,reverse(Es)}]).

fam_partition([{K,Vs}| Ts],Sort) ->
    fam_partition(Ts,K,[Vs],[],Sort);
fam_partition([],_Sort) ->
    [].

fam_partition([{K1,V}| Ts],K,Vs,P,S)
    when K1 == K->
    fam_partition(Ts,K,[V| Vs],P,S);
fam_partition([{K1,V}| Ts],K,[_] = Vs,P,S) ->
    fam_partition(Ts,K1,[V],[{K,Vs}| P],S);
fam_partition([{K1,V}| Ts],K,Vs,P,S) ->
    fam_partition(Ts,K1,[V],[{K,sort(S,Vs)}| P],S);
fam_partition([],K,[_] = Vs,P,_S) ->
    [{K,Vs}| P];
fam_partition([],K,Vs,P,S) ->
    [{K,sort(S,Vs)}| P].

fam_proj([{X,S}| F],Fun,Type,NType,L) ->
    case setfun(S,Fun,Type,NType) of
        {SD,ST}->
            fam_proj(F,Fun,Type,ST,[{X,SD}| L]);
        Bad->
            Bad
    end;
fam_proj([],_Fun,_Type,NType,L) ->
    {reverse(L),NType}.

setfun(T,Fun,Type,NType) ->
    case Fun(term2set(T,Type)) of
        NS
            when is_record(NS,'Set')->
            case unify_types(NType,[NS#'Set'.type]) of
                []->
                    type_mismatch;
                NT->
                    {NS#'Set'.data,NT}
            end;
        NS
            when is_record(NS,'OrdSet')->
            case unify_types(NType,NT = NS#'OrdSet'.ordtype) of
                []->
                    type_mismatch;
                NT->
                    {NS#'OrdSet'.orddata,NT}
            end;
        _->
            badarg
    end.

term2set(L,Type)
    when is_list(L)->
    #'Set'{data = L,type = Type};
term2set(T,Type) ->
    #'OrdSet'{orddata = T,ordtype = Type}.

fam2digraph(F,G) ->
    Fun = fun ({From,ToL})->
        digraph:add_vertex(G,From),
        Fun2 = fun (To)->
            digraph:add_vertex(G,To),
            case digraph:add_edge(G,From,To) of
                {error,{bad_edge,_}}->
                    throw({error,cyclic});
                _->
                    true
            end end,
        foreach(Fun2,ToL) end,
    foreach(Fun,to_external(F)),
    G.

digraph_family(G) ->
    Vs = sort(digraph:vertices(G)),
    digraph_fam(Vs,Vs,G,[]).

digraph_fam([V| Vs],V0,G,L)
    when V /= V0->
    Ns = sort(digraph:out_neighbours(G,V)),
    digraph_fam(Vs,V,G,[{V,Ns}| L]);
digraph_fam([],_V0,_G,L) ->
    reverse(L).

check_fun(T,F,FunT) ->
    true = is_type(FunT),
    {NT,_MaxI} = number_tuples(T,1),
    L = flatten(tuple2list(F(NT))),
    has_hole(L,1).

number_tuples(T,N)
    when is_tuple(T)->
    {L,NN} = mapfoldl(fun number_tuples/2,N,tuple_to_list(T)),
    {list_to_tuple(L),NN};
number_tuples(_,N) ->
    {N,N + 1}.

tuple2list(T)
    when is_tuple(T)->
    map(fun tuple2list/1,tuple_to_list(T));
tuple2list(C) ->
    [C].

has_hole([I| Is],I0)
    when I =< I0->
    has_hole(Is,max(I + 1,I0));
has_hole(Is,_I) ->
    Is =/= [].

check_for_sort(T,_I)
    when T =:= _->
    empty;
check_for_sort(T,I)
    when is_tuple(T),
    I =< tuple_size(T),
    I >= 1->
    I > 1;
check_for_sort(_T,_I) ->
    error.

inverse_substitution(L,Fun,Sort) ->
    sort(Sort,fun_rearr(L,Fun,[])).

fun_rearr([E| Es],Fun,L) ->
    fun_rearr(Es,Fun,[{Fun(E),E}| L]);
fun_rearr([],_Fun,L) ->
    L.

sets_to_list(Ss) ->
    map(fun (S)
        when is_record(S,'Set')->
        S#'Set'.data end,Ss).

types([],L) ->
    list_to_tuple(reverse(L));
types([S| _Ss],_L)
    when S#'Set'.type =:= _->
    _;
types([S| Ss],L) ->
    types(Ss,[S#'Set'.type| L]).

unify_types(T,T) ->
    T;
unify_types(Type1,Type2) ->
     catch unify_types1(Type1,Type2).

unify_types1(Atom,Atom)
    when is_atom(Atom)->
    Atom;
unify_types1(_,Type) ->
    Type;
unify_types1(Type,_) ->
    Type;
unify_types1([Type1],[Type2]) ->
    [unify_types1(Type1,Type2)];
unify_types1(T1,T2)
    when tuple_size(T1) =:= tuple_size(T2)->
    unify_typesl(tuple_size(T1),T1,T2,[]);
unify_types1(_T1,_T2) ->
    throw([]).

unify_typesl(0,_T1,_T2,L) ->
    list_to_tuple(L);
unify_typesl(N,T1,T2,L) ->
    T = unify_types1(element(N,T1),element(N,T2)),
    unify_typesl(N - 1,T1,T2,[T| L]).

match_types(T,T) ->
    true;
match_types(Type1,Type2) ->
    match_types1(Type1,Type2).

match_types1(Atom,Atom)
    when is_atom(Atom)->
    true;
match_types1(_,_) ->
    true;
match_types1(_,_) ->
    true;
match_types1([Type1],[Type2]) ->
    match_types1(Type1,Type2);
match_types1(T1,T2)
    when tuple_size(T1) =:= tuple_size(T2)->
    match_typesl(tuple_size(T1),T1,T2);
match_types1(_T1,_T2) ->
    false.

match_typesl(0,_T1,_T2) ->
    true;
match_typesl(N,T1,T2) ->
    case match_types1(element(N,T1),element(N,T2)) of
        true->
            match_typesl(N - 1,T1,T2);
        false->
            false
    end.

sort(true,L) ->
    sort(L);
sort(false,L) ->
    reverse(L).
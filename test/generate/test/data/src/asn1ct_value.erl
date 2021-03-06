-file("asn1ct_value.erl", 1).

-module(asn1ct_value).

-file("asn1_records.hrl", 1).

-record(module, {pos,name,defid,tagdefault = 'EXPLICIT',exports = {exports,[]},imports = {imports,[]},extensiondefault = empty,typeorval}).

-record('ExtensionAdditionGroup', {number}).

-record('SEQUENCE', {pname = false,tablecinf = false,extaddgroup,components = []}).

-record('SET', {pname = false,sorted = false,tablecinf = false,components = []}).

-record('ComponentType', {pos,name,typespec,prop,tags,textual_order}).

-record('ObjectClassFieldType', {classname,class,fieldname,type}).

-record(typedef, {checked = false,pos,name,typespec}).

-record(classdef, {checked = false,pos,name,module,typespec}).

-record(valuedef, {checked = false,pos,name,type,value,module}).

-record(ptypedef, {checked = false,pos,name,args,typespec}).

-record(pvaluedef, {checked = false,pos,name,args,type,value}).

-record(pvaluesetdef, {checked = false,pos,name,args,type,valueset}).

-record(pobjectdef, {checked = false,pos,name,args,class,def}).

-record(pobjectsetdef, {checked = false,pos,name,args,class,def}).

-record('Constraint', {'SingleValue' = no,'SizeConstraint' = no,'ValueRange' = no,'PermittedAlphabet' = no,'ContainedSubtype' = no,'TypeConstraint' = no,'InnerSubtyping' = no,e = no,'Other' = no}).

-record(simpletableattributes, {objectsetname,c_name,c_index,usedclassfield,uniqueclassfield,valueindex}).

-record(type, {tag = [],def,constraint = [],tablecinf = [],inlined = no}).

-record(objectclass, {fields = [],syntax}).

-record('Object', {classname,gen = true,def}).

-record('ObjectSet', {class,gen = true,uniquefname,set}).

-record(tag, {class,number,type,form = 32}).

-record(cmap, {single_value = no,contained_subtype = no,value_range = no,size = no,permitted_alphabet = no,type_constraint = no,inner_subtyping = no}).

-record('EXTENSIONMARK', {pos,val}).

-record('SymbolsFromModule', {symbols,module,objid}).

-record('Externaltypereference', {pos,module,type}).

-record('Externalvaluereference', {pos,module,value}).

-record(seqtag,{pos::integer(),module::atom(),val::atom()}).

-record(state, {module,mname,tname,erule,parameters = [],inputmodules = [],abscomppath = [],recordtopname = [],options,sourcedir,error_context}).

-record(gen,{erule = ber::ber|per|jer,der = false::boolean(),jer = false::boolean(),aligned = false::boolean(),rec_prefix = ""::string(),macro_prefix = ""::string(),pack = record::record|map,options = []::[any()]}).

-record(abst,{name::module(),types,
values,
ptypes,
classes,
objects,
objsets}).

-record(gen_state, {active = false,prefix,inc_tag_pattern,tag_pattern,inc_type_pattern,type_pattern,func_name,namelist,tobe_refed_funcs = [],gen_refed_funcs = [],generated_functions = [],suffix_index = 1,current_suffix_index}).

-file("asn1ct_value.erl", 27).

-export([from_type/2]).

from_type(M,Typename) ->
    case asn1_db:dbload(M) of
        error->
            {error,{not_found,{M,Typename}}};
        ok->
            #typedef{typespec = Type} = asn1_db:dbget(M,Typename),
            from_type(M,[Typename],Type);
        Vdef
            when is_record(Vdef,valuedef)->
            from_value(Vdef);
        Err->
            {error,{other,Err}}
    end.

from_type(M,Typename,Type)
    when is_record(Type,type)->
    InnerType = get_inner(Type#type.def),
    case asn1ct_gen:type(InnerType) of
        #'Externaltypereference'{module = Emod,type = Etype}->
            from_type(Emod,Etype);
        {_,user}->
            from_type(M,InnerType);
        {primitive,bif}->
            from_type_prim(M,Type);
        'ASN1_OPEN_TYPE'->
            case Type#type.constraint of
                [#'Externaltypereference'{type = TrefConstraint}]->
                    from_type(M,TrefConstraint);
                _->
                    ERule = get_encoding_rule(M),
                    open_type_value(ERule)
            end;
        {constructed,bif}
            when Typename == ['EXTERNAL']->
            Val = from_type_constructed(M,Typename,InnerType,Type),
            T = case M:maps() of
                false->
                    transform_to_EXTERNAL1994;
                true->
                    transform_to_EXTERNAL1994_maps
            end,
            asn1ct_eval_ext:T(Val);
        {constructed,bif}->
            from_type_constructed(M,Typename,InnerType,Type)
    end;
from_type(M,Typename,#'ComponentType'{name = Name,typespec = Type}) ->
    from_type(M,[Name| Typename],Type);
from_type(_,_,_) ->
    undefined.

from_value(#valuedef{type = #type{def = 'INTEGER'},value = Val}) ->
    Val.

get_inner(A)
    when is_atom(A)->
    A;
get_inner(Ext)
    when is_record(Ext,'Externaltypereference')->
    Ext;
get_inner({typereference,_Pos,Name}) ->
    Name;
get_inner(T)
    when is_tuple(T)->
    case asn1ct_gen:get_inner(T) of
        {fixedtypevaluefield,_,Type}->
            Type#type.def;
        {typefield,_FieldName}->
            'ASN1_OPEN_TYPE';
        Other->
            Other
    end.

from_type_constructed(M,Typename,InnerType,D)
    when is_record(D,type)->
    case InnerType of
        'SET'->
            get_sequence(M,Typename,D);
        'SEQUENCE'->
            get_sequence(M,Typename,D);
        'CHOICE'->
            get_choice(M,Typename,D);
        'SEQUENCE OF'->
            {_,Type} = D#type.def,
            NameSuffix = asn1ct_gen:constructed_suffix(InnerType,Type#type.def),
            get_sequence_of(M,Typename,D,NameSuffix);
        'SET OF'->
            {_,Type} = D#type.def,
            NameSuffix = asn1ct_gen:constructed_suffix(InnerType,Type#type.def),
            get_sequence_of(M,Typename,D,NameSuffix)
    end.

get_sequence(M,Typename,Type) ->
    {_SEQorSET,CompList} = case Type#type.def of
        #'SEQUENCE'{components = Cl}->
            {'SEQUENCE',Cl};
        #'SET'{components = Cl}->
            {'SET',to_textual_order(Cl)}
    end,
    Cs = get_components(M,Typename,CompList),
    case M:maps() of
        false->
            RecordTag = list_to_atom(asn1ct_gen:list2rname(Typename)),
            list_to_tuple([RecordTag| [Val || {_,Val} <- Cs]]);
        true->
            maps:from_list(Cs)
    end.

get_components(M,Typename,{Root,Ext}) ->
    get_components2(M,Typename,filter_complist(Root ++ Ext));
get_components(M,Typename,{Rl1,El,Rl2}) ->
    get_components2(M,Typename,filter_complist(Rl1 ++ El ++ Rl2));
get_components(M,Typename,CompList) ->
    get_components2(M,Typename,CompList).

get_components2(M,Typename,[H| T]) ->
    #'ComponentType'{name = Name} = H,
    [{Name,from_type(M,Typename,H)}| get_components(M,Typename,T)];
get_components2(_,_,[]) ->
    [].

filter_complist(CompList)
    when is_list(CompList)->
    lists:filter(fun (#'ExtensionAdditionGroup'{})->
        false;('ExtensionAdditionGroupEnd')->
        false;(_)->
        true end,CompList).

get_choice(M,Typename,Type) ->
    {'CHOICE',TCompList} = Type#type.def,
    case TCompList of
        []->
            {asn1_EMPTY,asn1_EMPTY};
        {CompList,ExtList}->
            CList = CompList ++ ExtList,
            C = lists:nth(random(length(CList)),CList),
            {C#'ComponentType'.name,from_type(M,Typename,C)};
        CompList
            when is_list(CompList)->
            C = lists:nth(random(length(CompList)),CompList),
            {C#'ComponentType'.name,from_type(M,Typename,C)}
    end.

get_sequence_of(M,Typename,Type,TypeSuffix) ->
    {_,Oftype} = Type#type.def,
    C = Type#type.constraint,
    S = size_random(C),
    NewTypeName = [TypeSuffix| Typename],
    gen_list(M,NewTypeName,Oftype,S).

gen_list(_,_,_,0) ->
    [];
gen_list(M,Typename,Oftype,N) ->
    [from_type(M,Typename,Oftype)| gen_list(M,Typename,Oftype,N - 1)].

from_type_prim(M,D) ->
    C = D#type.constraint,
    case D#type.def of
        'INTEGER'->
            i_random(C);
        {'INTEGER',[_| _] = NNL}->
            case C of
                []->
                    {N,_} = lists:nth(random(length(NNL)),NNL),
                    N;
                _->
                    V = i_random(C),
                    case lists:keyfind(V,2,NNL) of
                        false->
                            V;
                        {N,V}->
                            N
                    end
            end;
        Enum
            when is_tuple(Enum),
            element(1,Enum) == 'ENUMERATED'->
            NamedNumberList = case Enum of
                {_,_,NNL}->
                    NNL;
                {_,NNL}->
                    NNL
            end,
            NNew = case NamedNumberList of
                {N1,N2}->
                    N1 ++ N2;
                _->
                    NamedNumberList
            end,
            NN = [X || {X,_} <- NNew],
            case NN of
                []->
                    io:format(user,"Enum = ~p~n",[Enum]),
                    asn1_EMPTY;
                _->
                    case C of
                        []->
                            lists:nth(random(length(NN)),NN);
                        _->
                            lists:nth(fun (0)->
                                1;(X)->
                                X end(i_random(C)),NN)
                    end
            end;
        {'BIT STRING',NamedNumberList}->
            NN = [X || {X,_} <- NamedNumberList],
            case NN of
                []->
                    random_unnamed_bit_string(M,C);
                _->
                    [lists:nth(random(length(NN)),NN)]
            end;
        'NULL'->
            'NULL';
        'OBJECT IDENTIFIER'->
            Len = random(3),
            Olist = [(random(1000) - 1) || _X <- lists:seq(1,Len)],
            list_to_tuple([random(3) - 1, random(40) - 1| Olist]);
        'RELATIVE-OID'->
            Len = random(5),
            Olist = [(random(65535) - 1) || _X <- lists:seq(1,Len)],
            list_to_tuple(Olist);
        'ObjectDescriptor'->
            "Dummy ObjectDescriptor";
        'REAL'->
            case random(3) of
                1->
                    case random(3) of
                        3->
                            {129,2,10};
                        2->
                            {1,2,1};
                        _->
                            {255,2,2}
                    end;
                _->
                    case random(2) of
                        2->
                            "123.E10";
                        _->
                            "-123.E-10"
                    end
            end;
        'BOOLEAN'->
            true;
        'OCTET STRING'->
            S0 = adjust_list(size_random(C),c_string(C,"OCTET STRING")),
            case M:legacy_erlang_types() of
                false->
                    list_to_binary(S0);
                true->
                    S0
            end;
        'NumericString'->
            adjust_list(size_random(C),c_string(C,"0123456789"));
        'TeletexString'->
            adjust_list(size_random(C),c_string(C,"TeletexString"));
        'T61String'->
            adjust_list(size_random(C),c_string(C,"T61String"));
        'VideotexString'->
            adjust_list(size_random(C),c_string(C,"VideotexString"));
        'UTCTime'->
            "97100211-0500";
        'GeneralizedTime'->
            "19971002103130.5";
        'GraphicString'->
            adjust_list(size_random(C),c_string(C,"GraphicString"));
        'VisibleString'->
            adjust_list(size_random(C),c_string(C,"VisibleString"));
        'GeneralString'->
            adjust_list(size_random(C),c_string(C,"GeneralString"));
        'PrintableString'->
            adjust_list(size_random(C),c_string(C,"PrintableString"));
        'IA5String'->
            adjust_list(size_random(C),c_string(C,"IA5String"));
        'BMPString'->
            adjust_list(size_random(C),c_string(C,"BMPString"));
        'UTF8String'->
            L = adjust_list(random(50),[$U, $T, $F, $8, $S, $t, $r, $i, $n, $g, 65535, 65518, 1114111, 65535, 4095]),
            unicode:characters_to_binary(L);
        'UniversalString'->
            adjust_list(size_random(C),c_string(C,"UniversalString"))
    end.

c_string(C,Default) ->
    case get_constraint(C,'PermittedAlphabet') of
        {'SingleValue',Sv}
            when is_list(Sv)->
            Sv;
        {'SingleValue',V}
            when is_integer(V)->
            [V];
        no->
            Default
    end.

random_unnamed_bit_string(M,C) ->
    Bl1 = lists:reverse(adjust_list(size_random(C),[1, 0, 1, 1])),
    Bl2 = lists:reverse(lists:dropwhile(fun (0)->
        true;(1)->
        false end,Bl1)),
    Val = case {length(Bl2),get_constraint(C,'SizeConstraint')} of
        {Len,Len}->
            Bl2;
        {_Len,Int}
            when is_integer(Int)->
            Bl1;
        {Len,{Min,_}}
            when Min > Len->
            Bl1;
        _->
            Bl2
    end,
    case M:bit_string_format() of
        legacy->
            Val;
        bitstring->
            <<<<B:1>> || B <- Val>>;
        compact->
            BitString = <<<<B:1>> || B <- Val>>,
            PadLen = (8 - bit_size(BitString) band 7) band 7,
            {PadLen,<<BitString/bitstring,0:PadLen>>}
    end.

random(Upper) ->
    rand:uniform(Upper).

size_random(C) ->
    case get_constraint(C,'SizeConstraint') of
        no->
            c_random({0,5},no);
        {{Lb,Ub},_}
            when is_integer(Lb),
            is_integer(Ub)->
            if Ub - Lb =< 4 ->
                c_random({Lb,Ub},no);true ->
                c_random({Lb,Lb + 4},no) end;
        {Lb,Ub}
            when Ub - Lb =< 4->
            c_random({Lb,Ub},no);
        {Lb,_}->
            c_random({Lb,Lb + 4},no);
        Sv->
            c_random(no,Sv)
    end.

i_random(C) ->
    c_random(get_constraint(C,'ValueRange'),get_constraint(C,'SingleValue')).

c_random(VRange,Single) ->
    case {VRange,Single} of
        {no,no}->
            random(268435455) - (268435455 bsr 1);
        {R,no}->
            case R of
                {Lb,Ub}
                    when is_integer(Lb),
                    is_integer(Ub)->
                    Range = Ub - Lb + 1,
                    Lb + (random(Range) - 1);
                {Lb,'MAX'}->
                    Lb + random(268435455) - 1;
                {'MIN',Ub}->
                    Ub - random(268435455) - 1;
                {A,{'ASN1_OK',B}}->
                    Range = B - A + 1,
                    A + (random(Range) - 1)
            end;
        {_,S}
            when is_integer(S)->
            S;
        {_,S}
            when is_list(S)->
            lists:nth(random(length(S)),S)
    end.

adjust_list(Len,Orig) ->
    adjust_list1(Len,Orig,Orig,[]).

adjust_list1(0,_Orig,[_Oh| _Ot],Acc) ->
    lists:reverse(Acc);
adjust_list1(Len,Orig,[],Acc) ->
    adjust_list1(Len,Orig,Orig,Acc);
adjust_list1(Len,Orig,[Oh| Ot],Acc) ->
    adjust_list1(Len - 1,Orig,Ot,[Oh| Acc]).

get_constraint(C,Key) ->
    case lists:keyfind(Key,1,C) of
        false->
            no;
        {'ValueRange',{Lb,Ub}}->
            {check_external(Lb),check_external(Ub)};
        {'SizeConstraint',N}->
            N;
        {Key,Value}->
            Value
    end.

check_external(ExtRef)
    when is_record(ExtRef,'Externalvaluereference')->
    #'Externalvaluereference'{module = Emod,value = Evalue} = ExtRef,
    from_type(Emod,Evalue);
check_external(Value) ->
    Value.

get_encoding_rule(M) ->
    Mod = if is_list(M) ->
        list_to_atom(M);true ->
        M end,
    case  catch Mod:encoding_rule() of
        A
            when is_atom(A)->
            A;
        _->
            unknown
    end.

open_type_value(ber) ->
    <<4,9,111,112,101,110,95,116,121,112,101>>;
open_type_value(_) ->
    <<"\n\topen_type">>.

to_textual_order({Root,Ext}) ->
    {to_textual_order(Root),Ext};
to_textual_order(Cs)
    when is_list(Cs)->
    case Cs of
        [#'ComponentType'{textual_order = undefined}| _]->
            Cs;
        _->
            lists:keysort(#'ComponentType'.textual_order,Cs)
    end.
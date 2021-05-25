-file("asn1ct_gen_ber_bin_v2.erl", 1).

-module(asn1ct_gen_ber_bin_v2).

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

-file("asn1ct_gen_ber_bin_v2.erl", 27).

-export([decode_class/1]).

-export([gen_encode/2, gen_encode/3, gen_decode/2, gen_decode/3]).

-export([gen_encode_prim/4]).

-export([gen_dec_prim/3]).

-export([gen_objectset_code/2, gen_obj_code/3]).

-export([encode_tag_val/3]).

-export([gen_inc_decode/2, gen_decode_selected/3]).

-export([extaddgroup2sequence/1]).

-export([dialyzer_suppressions/1]).

-import(asn1ct_gen, [emit/1]).

dialyzer_suppressions(_) ->
    case asn1ct:use_legacy_types() of
        false->
            ok;
        true->
            suppress({ber,encode_bit_string,4})
    end,
    suppress({ber,decode_selective,2}),
    emit(["    ok.", nl]).

suppress({M,F,A} = MFA) ->
    case asn1ct_func:is_used(MFA) of
        false->
            ok;
        true->
            Args = [(lists:concat(["element(", I, ", Arg)"])) || I <- lists:seq(1,A)],
            emit(["    ", {call,M,F,Args}, com, nl])
    end.

gen_encode(Erules,#typedef{} = D) ->
    gen_encode_user(Erules,#typedef{} = D,true).

gen_encode(Erules,Typename,Type)
    when is_record(Type,type)->
    InnerType = asn1ct_gen:get_inner(Type#type.def),
    ObjFun = case lists:keysearch(objfun,1,Type#type.tablecinf) of
        {value,{_,_Name}}->
            ", ObjFun";
        false->
            ""
    end,
    case asn1ct_gen:type(InnerType) of
        {constructed,bif}->
            Func = {asis,enc_func(asn1ct_gen:list2name(Typename))},
            emit([nl, nl, nl, "%%================================", nl, "%%  ", asn1ct_gen:list2name(Typename), nl, "%%================================", nl, Func, "(Val, TagIn", ObjFun, ") ->", nl, "   "]),
            asn1ct_gen:gen_encode_constructed(Erules,Typename,InnerType,Type);
        _->
            true
    end;
gen_encode(Erules,Tname,#'ComponentType'{name = Cname,typespec = Type}) ->
    NewTname = [Cname| Tname],
    NewType = Type#type{tag = []},
    gen_encode(Erules,NewTname,NewType).

gen_encode_user(Erules,#typedef{} = D,Wrapper) ->
    Typename = [D#typedef.name],
    Type = D#typedef.typespec,
    InnerType = asn1ct_gen:get_inner(Type#type.def),
    emit([nl, nl, "%%================================"]),
    emit([nl, "%%  ", Typename]),
    emit([nl, "%%================================", nl]),
    FuncName = {asis,enc_func(asn1ct_gen:list2name(Typename))},
    case Wrapper of
        true->
            OTag = Type#type.tag,
            Tag0 = [(encode_tag_val(decode_class(Class),Form,Number)) || #tag{class = Class,form = Form,number = Number} <- OTag],
            Tag = lists:reverse(Tag0),
            emit([FuncName, "(Val) ->", nl, "    ", FuncName, "(Val, ", {asis,Tag}, ").", nl, nl]);
        false->
            ok
    end,
    emit([FuncName, "(Val, TagIn) ->", nl]),
    CurrentMod = get(currmod),
    case asn1ct_gen:type(InnerType) of
        {constructed,bif}->
            asn1ct_gen:gen_encode_constructed(Erules,Typename,InnerType,D);
        {primitive,bif}->
            gen_encode_prim(ber,Type,"TagIn","Val"),
            emit([".", nl]);
        #'Externaltypereference'{module = CurrentMod,type = Etype}->
            emit(["   ", {asis,enc_func(Etype)}, "(Val, TagIn).", nl]);
        #'Externaltypereference'{module = Emod,type = Etype}->
            emit(["   ", {asis,Emod}, ":", {asis,enc_func(Etype)}, "(Val, TagIn).", nl]);
        'ASN1_OPEN_TYPE'->
            emit(["%% OPEN TYPE", nl]),
            gen_encode_prim(ber,Type#type{def = 'ASN1_OPEN_TYPE'},"TagIn","Val"),
            emit([".", nl])
    end.

gen_encode_prim(_Erules,#type{} = D,DoTag,Value) ->
    BitStringConstraint = get_size_constraint(D#type.constraint),
    MaxBitStrSize = case BitStringConstraint of
        []->
            none;
        {_,'MAX'}->
            none;
        {_,Max}->
            Max;
        Max
            when is_integer(Max)->
            Max
    end,
    asn1ct_name:new(enumval),
    Type = case D#type.def of
        'OCTET STRING'->
            restricted_string;
        'ObjectDescriptor'->
            restricted_string;
        'NumericString'->
            restricted_string;
        'TeletexString'->
            restricted_string;
        'T61String'->
            restricted_string;
        'VideotexString'->
            restricted_string;
        'GraphicString'->
            restricted_string;
        'VisibleString'->
            restricted_string;
        'GeneralString'->
            restricted_string;
        'PrintableString'->
            restricted_string;
        'IA5String'->
            restricted_string;
        'UTCTime'->
            restricted_string;
        'GeneralizedTime'->
            restricted_string;
        Other->
            Other
    end,
    case Type of
        restricted_string->
            call(encode_restricted_string,[Value, DoTag]);
        'BOOLEAN'->
            call(encode_boolean,[Value, DoTag]);
        'INTEGER'->
            call(encode_integer,[Value, DoTag]);
        {'INTEGER',NamedNumberList}->
            call(encode_integer,[Value, {asis,NamedNumberList}, DoTag]);
        {'ENUMERATED',NamedNumberList = {_,_}}->
            emit(["case ", Value, " of", nl]),
            emit_enc_enumerated_cases(NamedNumberList,DoTag);
        {'ENUMERATED',NamedNumberList}->
            emit(["case ", Value, " of", nl]),
            emit_enc_enumerated_cases(NamedNumberList,DoTag);
        'REAL'->
            asn1ct_name:new(realval),
            asn1ct_name:new(realsize),
            emit(["begin", nl, {curr,realval}, " = ", {call,real_common,ber_encode_real,[Value]}, com, nl, {curr,realsize}, " = ", {call,erlang,byte_size,[{curr,realval}]}, com, nl, {call,ber,encode_tags,[DoTag, {curr,realval}, {curr,realsize}]}, nl, "end"]);
        {'BIT STRING',[]}->
            case asn1ct:use_legacy_types() of
                false
                    when MaxBitStrSize =:= none->
                    call(encode_unnamed_bit_string,[Value, DoTag]);
                false->
                    call(encode_unnamed_bit_string,[{asis,MaxBitStrSize}, Value, DoTag]);
                true->
                    call(encode_bit_string,[{asis,BitStringConstraint}, Value, {asis,[]}, DoTag])
            end;
        {'BIT STRING',NamedNumberList}->
            case asn1ct:use_legacy_types() of
                false
                    when MaxBitStrSize =:= none->
                    call(encode_named_bit_string,[Value, {asis,NamedNumberList}, DoTag]);
                false->
                    call(encode_named_bit_string,[{asis,MaxBitStrSize}, Value, {asis,NamedNumberList}, DoTag]);
                true->
                    call(encode_bit_string,[{asis,BitStringConstraint}, Value, {asis,NamedNumberList}, DoTag])
            end;
        'NULL'->
            call(encode_null,[Value, DoTag]);
        'OBJECT IDENTIFIER'->
            call(encode_object_identifier,[Value, DoTag]);
        'RELATIVE-OID'->
            call(encode_relative_oid,[Value, DoTag]);
        'UniversalString'->
            call(encode_universal_string,[Value, DoTag]);
        'UTF8String'->
            call(encode_UTF8_string,[Value, DoTag]);
        'BMPString'->
            call(encode_BMP_string,[Value, DoTag]);
        'ASN1_OPEN_TYPE'->
            call(encode_open_type,[Value, DoTag])
    end.

emit_enc_enumerated_cases({L1,L2},Tags) ->
    emit_enc_enumerated_cases(L1 ++ L2,Tags,ext);
emit_enc_enumerated_cases(L,Tags) ->
    emit_enc_enumerated_cases(L,Tags,noext).

emit_enc_enumerated_cases([{EnumName,EnumVal}| T],Tags,Ext) ->
    {Bytes,Len} = encode_integer(EnumVal),
    emit([{asis,EnumName}, " -> ", {call,ber,encode_tags,[Tags, {asis,Bytes}, Len]}, ";", nl]),
    emit_enc_enumerated_cases(T,Tags,Ext);
emit_enc_enumerated_cases([],_Tags,_Ext) ->
    emit([{curr,enumval}, " -> exit({error,{asn1, {enumerated_not_in_range,", {curr,enumval}, "}}})"]),
    emit([nl, "end"]).

encode_integer(Val) ->
    Bytes = if Val >= 0 ->
        encode_integer_pos(Val,[]);true ->
        encode_integer_neg(Val,[]) end,
    {Bytes,length(Bytes)}.

encode_integer_pos(0,[B| _Acc] = L)
    when B < 128->
    L;
encode_integer_pos(N,Acc) ->
    encode_integer_pos(N bsr 8,[N band 255| Acc]).

encode_integer_neg(-1,[B1| _T] = L)
    when B1 > 127->
    L;
encode_integer_neg(N,Acc) ->
    encode_integer_neg(N bsr 8,[N band 255| Acc]).

gen_decode(Erules,Type)
    when is_record(Type,typedef)->
    Def = Type#typedef.typespec,
    InnerTag = Def#type.tag,
    Tag = [(decode_class(X#tag.class) bsl 10 + X#tag.number) || X <- InnerTag],
    FuncName0 = case {asn1ct:get_gen_state_field(active),asn1ct:get_gen_state_field(prefix)} of
        {true,Pref}->
            case asn1ct:current_sindex() of
                I
                    when is_integer(I),
                    I > 0->
                    [Pref, Type#typedef.name, "_", I];
                _->
                    [Pref, Type#typedef.name]
            end;
        {_,_}->
            ["dec_", Type#typedef.name]
    end,
    FuncName = {asis,list_to_atom(lists:concat(FuncName0))},
    emit([nl, nl, FuncName, "(Tlv) ->", nl, "   ", FuncName, "(Tlv, ", {asis,Tag}, ").", nl, nl, FuncName, "(Tlv, TagIn) ->", nl]),
    gen_decode_user(Erules,Type).

gen_inc_decode(Erules,Type)
    when is_record(Type,typedef)->
    Prefix = asn1ct:get_gen_state_field(prefix),
    Suffix = asn1ct_gen:index2suffix(asn1ct:current_sindex()),
    FuncName0 = [Prefix, Type#typedef.name, Suffix],
    FuncName = {asis,list_to_atom(lists:concat(FuncName0))},
    emit([nl, nl, FuncName, "(Tlv, TagIn) ->", nl]),
    gen_decode_user(Erules,Type).

gen_decode_selected(Erules,Type,FuncName) ->
    emit([FuncName, "(Bin) ->", nl]),
    Patterns = asn1ct:read_config_data(partial_decode),
    Pattern = case lists:keysearch(FuncName,1,Patterns) of
        {value,{_,P}}->
            P;
        false->
            exit({error,{internal,no_pattern_saved}})
    end,
    emit(["  case ", {call,ber,decode_selective,[{asis,Pattern}, "Bin"]}, " of", nl, "    {ok,Bin2} when is_binary(Bin2) ->", nl, "      {Tlv,_} = ", {call,ber,ber_decode_nif,["Bin2"]}, com, nl]),
    emit("{ok,"),
    gen_decode_selected_type(Erules,Type),
    emit(["};", nl, "    Err -> exit({error,{selective_decode,Err}})", nl, "  end.", nl]).

gen_decode_selected_type(_Erules,TypeDef) ->
    Def = TypeDef#typedef.typespec,
    InnerType = asn1ct_gen:get_inner(Def#type.def),
    BytesVar = "Tlv",
    Tag = [(decode_class(X#tag.class) bsl 10 + X#tag.number) || X <- Def#type.tag],
    case asn1ct_gen:type(InnerType) of
        'ASN1_OPEN_TYPE'->
            asn1ct_name:new(len),
            gen_dec_prim(Def#type{def = 'ASN1_OPEN_TYPE'},BytesVar,Tag);
        {primitive,bif}->
            asn1ct_name:new(len),
            gen_dec_prim(Def,BytesVar,Tag);
        {constructed,bif}->
            TopType = case TypeDef#typedef.name of
                A
                    when is_atom(A)->
                    [A];
                N->
                    N
            end,
            DecFunName = lists:concat(["'", dec, "_", asn1ct_gen:list2name(TopType), "'"]),
            emit([DecFunName, "(", BytesVar, ", ", {asis,Tag}, ")"]);
        TheType->
            DecFunName = mkfuncname(TheType,dec),
            emit([DecFunName, "(", BytesVar, ", ", {asis,Tag}, ")"])
    end.

gen_decode(Erules,Typename,Type)
    when is_record(Type,type)->
    InnerType = asn1ct_gen:get_inner(Type#type.def),
    FunctionName = case asn1ct:get_gen_state_field(active) of
        true->
            Pattern = asn1ct:get_gen_state_field(namelist),
            Suffix = case asn1ct:maybe_saved_sindex(Typename,Pattern) of
                I
                    when is_integer(I),
                    I > 0->
                    lists:concat(["_", I]);
                _->
                    ""
            end,
            lists:concat(["'dec-inc-", asn1ct_gen:list2name(Typename), Suffix]);
        _->
            lists:concat(["'dec_", asn1ct_gen:list2name(Typename)])
    end,
    case asn1ct_gen:type(InnerType) of
        {constructed,bif}->
            ObjFun = case Type#type.tablecinf of
                [{objfun,_}| _R]->
                    ", ObjFun";
                _->
                    ""
            end,
            emit([FunctionName, "'(Tlv, TagIn", ObjFun, ") ->", nl]),
            asn1ct_gen:gen_decode_constructed(Erules,Typename,InnerType,Type);
        Rec
            when is_record(Rec,'Externaltypereference')->
            case {Typename,asn1ct:get_gen_state_field(namelist)} of
                {[Cname| _],[{Cname,_}| _]}->
                    case asn1ct:is_function_generated(Typename) of
                        true->
                            ok;
                        _->
                            asn1ct:generated_refed_func(Typename),
                            #'Externaltypereference'{module = M,type = Name} = Rec,
                            TypeDef = asn1_db:dbget(M,Name),
                            gen_decode(Erules,TypeDef)
                    end;
                _->
                    true
            end;
        _->
            true
    end;
gen_decode(Erules,Tname,#'ComponentType'{name = Cname,typespec = Type}) ->
    NewTname = [Cname| Tname],
    NewType = Type#type{tag = []},
    case {asn1ct:get_gen_state_field(active),asn1ct:get_tobe_refed_func(NewTname)} of
        {true,{_,NameList}}->
            asn1ct:update_gen_state(namelist,NameList),
            gen_decode(Erules,NewTname,NewType);
        {No,_}
            when No == false;
            No == undefined->
            gen_decode(Erules,NewTname,NewType);
        _->
            ok
    end.

gen_decode_user(Erules,D)
    when is_record(D,typedef)->
    Typename = [D#typedef.name],
    Def = D#typedef.typespec,
    InnerType = asn1ct_gen:get_inner(Def#type.def),
    BytesVar = "Tlv",
    case asn1ct_gen:type(InnerType) of
        'ASN1_OPEN_TYPE'->
            asn1ct_name:new(len),
            gen_dec_prim(Def#type{def = 'ASN1_OPEN_TYPE'},BytesVar,{string,"TagIn"}),
            emit([".", nl, nl]);
        {primitive,bif}->
            asn1ct_name:new(len),
            gen_dec_prim(Def,BytesVar,{string,"TagIn"}),
            emit([".", nl, nl]);
        {constructed,bif}->
            asn1ct:update_namelist(D#typedef.name),
            asn1ct_gen:gen_decode_constructed(Erules,Typename,InnerType,D);
        TheType->
            DecFunName = mkfuncname(TheType,dec),
            emit([DecFunName, "(", BytesVar, ", TagIn).", nl, nl])
    end.

gen_dec_prim(Att,BytesVar,DoTag) ->
    Typename = Att#type.def,
    Constraint = get_size_constraint(Att#type.constraint),
    IntConstr = int_constr(Att#type.constraint),
    NewTypeName = case Typename of
        'NumericString'->
            restricted_string;
        'TeletexString'->
            restricted_string;
        'T61String'->
            restricted_string;
        'VideotexString'->
            restricted_string;
        'GraphicString'->
            restricted_string;
        'VisibleString'->
            restricted_string;
        'GeneralString'->
            restricted_string;
        'PrintableString'->
            restricted_string;
        'IA5String'->
            restricted_string;
        'ObjectDescriptor'->
            restricted_string;
        'UTCTime'->
            restricted_string;
        'GeneralizedTime'->
            restricted_string;
        'OCTET STRING'->
            case asn1ct:use_legacy_types() of
                true->
                    restricted_string;
                false->
                    Typename
            end;
        _->
            Typename
    end,
    TagStr = case DoTag of
        {string,Tag1}->
            Tag1;
        _
            when is_list(DoTag)->
            {asis,DoTag}
    end,
    case NewTypeName of
        'BOOLEAN'->
            call(decode_boolean,[BytesVar, TagStr]);
        'INTEGER'->
            check_constraint(decode_integer,[BytesVar, TagStr],IntConstr,identity,identity);
        {'INTEGER',NNL}->
            check_constraint(decode_integer,[BytesVar, TagStr],IntConstr,identity,fun (Val)->
                asn1ct_name:new(val),
                emit([{curr,val}, " = "]),
                Val(),
                emit([com, nl, {call,ber,number2name,[{curr,val}, {asis,NNL}]}]) end);
        {'ENUMERATED',NNL}->
            gen_dec_enumerated(BytesVar,NNL,TagStr);
        'REAL'->
            asn1ct_name:new(tmpbuf),
            emit(["begin", nl, {curr,tmpbuf}, " = ", {call,ber,match_tags,[BytesVar, TagStr]}, com, nl, {call,real_common,decode_real,[{curr,tmpbuf}]}, nl, "end", nl]);
        {'BIT STRING',NNL}->
            gen_dec_bit_string(BytesVar,Constraint,NNL,TagStr);
        'NULL'->
            call(decode_null,[BytesVar, TagStr]);
        'OBJECT IDENTIFIER'->
            call(decode_object_identifier,[BytesVar, TagStr]);
        'RELATIVE-OID'->
            call(decode_relative_oid,[BytesVar, TagStr]);
        'OCTET STRING'->
            check_constraint(decode_octet_string,[BytesVar, TagStr],Constraint,{erlang,byte_size},identity);
        restricted_string->
            check_constraint(decode_restricted_string,[BytesVar, TagStr],Constraint,{erlang,byte_size},fun (Val)->
                emit("binary_to_list("),
                Val(),
                emit(")") end);
        'UniversalString'->
            check_constraint(decode_universal_string,[BytesVar, TagStr],Constraint,{erlang,length},identity);
        'UTF8String'->
            call(decode_UTF8_string,[BytesVar, TagStr]);
        'BMPString'->
            check_constraint(decode_BMP_string,[BytesVar, TagStr],Constraint,{erlang,length},identity);
        'ASN1_OPEN_TYPE'->
            call(decode_open_type_as_binary,[BytesVar, TagStr])
    end.

-spec(int_constr(term()) -> []|{integer(),integer()|'MAX'}).

int_constr(C) ->
    case asn1ct_imm:effective_constraint(integer,C) of
        [{_,[]}]->
            [];
        [{'ValueRange',{'MIN',_}}]->
            [];
        [{'ValueRange',{_,_} = Range}]->
            Range;
        [{'SingleValue',Sv}]->
            Sv;
        []->
            []
    end.

gen_dec_bit_string(BytesVar,_Constraint,[_| _] = NNL,TagStr) ->
    call(decode_named_bit_string,[BytesVar, {asis,NNL}, TagStr]);
gen_dec_bit_string(BytesVar,Constraint,[],TagStr) ->
    case asn1ct:get_bit_string_format() of
        compact->
            check_constraint(decode_compact_bit_string,[BytesVar, TagStr],Constraint,{ber,compact_bit_string_size},identity);
        legacy->
            check_constraint(decode_native_bit_string,[BytesVar, TagStr],Constraint,{erlang,bit_size},fun (Val)->
                asn1ct_name:new(val),
                emit([{curr,val}, " = "]),
                Val(),
                emit([com, nl, {call,ber,native_to_legacy_bit_string,[{curr,val}]}]) end);
        bitstring->
            check_constraint(decode_native_bit_string,[BytesVar, TagStr],Constraint,{erlang,bit_size},identity)
    end.

check_constraint(F,Args,Constr,PreConstr0,ReturnVal0) ->
    PreConstr = case PreConstr0 of
        identity->
            fun (V)->
                V end;
        {Mod,Name}->
            fun (V)->
                asn1ct_name:new(c),
                emit([{curr,c}, " = ", {call,Mod,Name,[V]}, com, nl]),
                {curr,c} end
    end,
    ReturnVal = case ReturnVal0 of
        identity->
            fun (Val)->
                Val() end;
        _->
            ReturnVal0
    end,
    case Constr of
        []
            when ReturnVal0 =:= identity->
            call(F,Args);
        []->
            emit(["begin", nl]),
            ReturnVal(fun ()->
                call(F,Args) end),
            emit([nl, "end", nl]);
        _->
            asn1ct_name:new(val),
            emit(["begin", nl, {curr,val}, " = ", {call,ber,F,Args}, com, nl]),
            PreVal0 = asn1ct_gen:mk_var(asn1ct_name:curr(val)),
            PreVal = PreConstr(PreVal0),
            emit("if "),
            case Constr of
                {Min,Max}->
                    emit([{asis,Min}, " =< ", PreVal, ", ", PreVal, " =< ", {asis,Max}]);
                Sv
                    when is_integer(Sv)->
                    emit([PreVal, " =:= ", {asis,Sv}])
            end,
            emit([" ->", nl]),
            ReturnVal(fun ()->
                emit(PreVal0) end),
            emit([";", nl, "true ->", nl, "exit({error,{asn1,bad_range}})", nl, "end", nl, "end"])
    end.

gen_dec_enumerated(BytesVar,NNL0,TagStr) ->
    asn1ct_name:new(enum),
    emit(["case ", {call,ber,decode_integer,[BytesVar, TagStr]}, " of", nl]),
    NNL = case NNL0 of
        {L1,L2}->
            L1 ++ L2 ++ [accept];
        [_| _]->
            NNL0 ++ [error]
    end,
    gen_dec_enumerated_1(NNL),
    emit("end").

gen_dec_enumerated_1([accept]) ->
    asn1ct_name:new(default),
    emit([{curr,default}, " -> {asn1_enum,", {curr,default}, "}", nl]);
gen_dec_enumerated_1([error]) ->
    asn1ct_name:new(default),
    emit([{curr,default}, " -> exit({error,{asn1,{illegal_enumerated,", {curr,default}, "}}})", nl]);
gen_dec_enumerated_1([{V,K}| T]) ->
    emit([{asis,K}, " -> ", {asis,V}, ";", nl]),
    gen_dec_enumerated_1(T).

gen_obj_code(Erules,_Module,Obj)
    when is_record(Obj,typedef)->
    ObjName = Obj#typedef.name,
    Def = Obj#typedef.typespec,
    #'Externaltypereference'{module = M,type = ClName} = Def#'Object'.classname,
    Class = asn1_db:dbget(M,ClName),
    {object,_,Fields} = Def#'Object'.def,
    emit([nl, nl, nl, "%%================================", nl, "%%  ", ObjName, nl, "%%================================", nl]),
    EncConstructed = gen_encode_objectfields(ClName,get_class_fields(Class),ObjName,Fields,[]),
    emit(nl),
    gen_encode_constr_type(Erules,EncConstructed),
    emit(nl),
    DecConstructed = gen_decode_objectfields(ClName,get_class_fields(Class),ObjName,Fields,[]),
    emit(nl),
    gen_decode_constr_type(Erules,DecConstructed),
    emit_tlv_format_function().

gen_encode_objectfields(ClassName,[{typefield,Name,OptOrMand}| Rest],ObjName,ObjectFields,ConstrAcc) ->
    EmitFuncClause = fun (Arg)->
        emit([{asis,enc_func(ObjName)}, "(", {asis,Name}, ", ", Arg, ", _RestPrimFieldName) ->", nl]) end,
    MaybeConstr = case {get_object_field(Name,ObjectFields),OptOrMand} of
        {false,'OPTIONAL'}->
            EmitFuncClause("Val"),
            emit(["   {Val,0}"]),
            [];
        {false,{'DEFAULT',DefaultType}}->
            EmitFuncClause("Val"),
            gen_encode_default_call(ClassName,Name,DefaultType);
        {{Name,TypeSpec},_}->
            EmitFuncClause("Val"),
            gen_encode_field_call(ObjName,Name,TypeSpec)
    end,
    case more_genfields(Rest) of
        true->
            emit([";", nl]);
        false->
            emit([".", nl])
    end,
    gen_encode_objectfields(ClassName,Rest,ObjName,ObjectFields,MaybeConstr ++ ConstrAcc);
gen_encode_objectfields(ClassName,[{objectfield,Name,_,_,OptOrMand}| Rest],ObjName,ObjectFields,ConstrAcc) ->
    CurrentMod = get(currmod),
    EmitFuncClause = fun (Args)->
        emit([{asis,enc_func(ObjName)}, "(", {asis,Name}, ", ", Args, ") ->", nl]) end,
    case {get_object_field(Name,ObjectFields),OptOrMand} of
        {false,'OPTIONAL'}->
            EmitFuncClause("_,_"),
            emit(["  exit({error,{'use of missing field in object', ", {asis,Name}, "}})"]);
        {false,{'DEFAULT',_DefaultObject}}->
            exit({error,{asn1,{"not implemented yet",Name}}});
        {{Name,#'Externalvaluereference'{module = CurrentMod,value = TypeName}},_}->
            EmitFuncClause(" Val, [H|T]"),
            emit([indent(3), {asis,enc_func(TypeName)}, "(H, Val, T)"]);
        {{Name,#'Externalvaluereference'{module = M,value = TypeName}},_}->
            EmitFuncClause(" Val, [H|T]"),
            emit([indent(3), {asis,M}, ":", {asis,enc_func(TypeName)}, "(H, Val, T)"]);
        {{Name,#typedef{name = TypeName}},_}
            when is_atom(TypeName)->
            EmitFuncClause(" Val, [H|T]"),
            emit([indent(3), {asis,enc_func(TypeName)}, "(H, Val, T)"])
    end,
    case more_genfields(Rest) of
        true->
            emit([";", nl]);
        false->
            emit([".", nl])
    end,
    gen_encode_objectfields(ClassName,Rest,ObjName,ObjectFields,ConstrAcc);
gen_encode_objectfields(ClassName,[_C| Cs],O,OF,Acc) ->
    gen_encode_objectfields(ClassName,Cs,O,OF,Acc);
gen_encode_objectfields(_,[],_,_,Acc) ->
    Acc.

gen_encode_constr_type(Erules,[TypeDef| Rest])
    when is_record(TypeDef,typedef)->
    case is_already_generated(enc,TypeDef#typedef.name) of
        true->
            ok;
        false->
            gen_encode_user(Erules,TypeDef,false)
    end,
    gen_encode_constr_type(Erules,Rest);
gen_encode_constr_type(_,[]) ->
    ok.

gen_encode_field_call(_ObjName,_FieldName,#'Externaltypereference'{module = M,type = T}) ->
    CurrentMod = get(currmod),
    TDef = asn1_db:dbget(M,T),
    Def = TDef#typedef.typespec,
    OTag = Def#type.tag,
    Tag = [(encode_tag_val(decode_class(X#tag.class),X#tag.form,X#tag.number)) || X <- OTag],
    if M == CurrentMod ->
        emit(["   ", {asis,enc_func(T)}, "(Val, ", {asis,Tag}, ")"]),
        [];true ->
        emit(["   ", {asis,M}, ":", {asis,enc_func(T)}, "(Val, ", {asis,Tag}, ")"]),
        [] end;
gen_encode_field_call(ObjName,FieldName,Type) ->
    Def = Type#typedef.typespec,
    OTag = Def#type.tag,
    Tag = [(encode_tag_val(decode_class(X#tag.class),X#tag.form,X#tag.number)) || X <- OTag],
    case Type#typedef.name of
        {primitive,bif}->
            gen_encode_prim(ber,Def,{asis,lists:reverse(Tag)},"Val"),
            [];
        {constructed,bif}->
            Name = lists:concat([ObjName, _, FieldName]),
            emit(["   ", {asis,enc_func(Name)}, "(Val,", {asis,Tag}, ")"]),
            [Type#typedef{name = list_to_atom(Name)}];
        {ExtMod,TypeName}->
            emit(["   ", {asis,ExtMod}, ":", {asis,enc_func(TypeName)}, "(Val,", {asis,Tag}, ")"]),
            [];
        TypeName->
            emit(["   ", {asis,enc_func(TypeName)}, "(Val,", {asis,Tag}, ")"]),
            []
    end.

gen_encode_default_call(ClassName,FieldName,Type) ->
    CurrentMod = get(currmod),
    InnerType = asn1ct_gen:get_inner(Type#type.def),
    OTag = Type#type.tag,
    Tag = [(encode_tag_val(decode_class(X#tag.class),X#tag.form,X#tag.number)) || X <- OTag],
    case asn1ct_gen:type(InnerType) of
        {constructed,bif}->
            Name = lists:concat([ClassName, _, FieldName]),
            emit(["   ", {asis,enc_func(Name)}, "(Val, ", {asis,Tag}, ")"]),
            [#typedef{name = list_to_atom(Name),typespec = Type}];
        {primitive,bif}->
            gen_encode_prim(ber,Type,{asis,lists:reverse(Tag)},"Val"),
            [];
        #'Externaltypereference'{module = CurrentMod,type = Etype}->
            emit(["   'enc_", Etype, "'(Val, ", {asis,Tag}, ")", nl]),
            [];
        #'Externaltypereference'{module = Emod,type = Etype}->
            emit(["   '", Emod, "':'enc_", Etype, "'(Val, ", {asis,Tag}, ")", nl]),
            []
    end.

gen_decode_objectfields(ClassName,[{typefield,Name,OptOrMand}| Rest],ObjName,ObjectFields,ConstrAcc) ->
    EmitFuncClause = fun (Arg)->
        emit([{asis,dec_func(ObjName)}, "(", {asis,Name}, ", ", Arg, ",_) ->", nl]) end,
    MaybeConstr = case {get_object_field(Name,ObjectFields),OptOrMand} of
        {false,'OPTIONAL'}->
            EmitFuncClause(" Bytes"),
            emit(["   Bytes"]),
            [];
        {false,{'DEFAULT',DefaultType}}->
            EmitFuncClause("Bytes"),
            emit_tlv_format("Bytes"),
            gen_decode_default_call(ClassName,Name,"Tlv",DefaultType);
        {{Name,TypeSpec},_}->
            EmitFuncClause("Bytes"),
            emit_tlv_format("Bytes"),
            gen_decode_field_call(ObjName,Name,"Tlv",TypeSpec)
    end,
    case more_genfields(Rest) of
        true->
            emit([";", nl]);
        false->
            emit([".", nl])
    end,
    gen_decode_objectfields(ClassName,Rest,ObjName,ObjectFields,MaybeConstr ++ ConstrAcc);
gen_decode_objectfields(ClassName,[{objectfield,Name,_,_,OptOrMand}| Rest],ObjName,ObjectFields,ConstrAcc) ->
    CurrentMod = get(currmod),
    EmitFuncClause = fun (Args)->
        emit([{asis,dec_func(ObjName)}, "(", {asis,Name}, ", ", Args, ") ->", nl]) end,
    case {get_object_field(Name,ObjectFields),OptOrMand} of
        {false,'OPTIONAL'}->
            EmitFuncClause("_,_"),
            emit(["  exit({error,{'illegal use of missing field in obje" "ct', ", {asis,Name}, "}})"]);
        {false,{'DEFAULT',_DefaultObject}}->
            exit({error,{asn1,{"not implemented yet",Name}}});
        {{Name,#'Externalvaluereference'{module = CurrentMod,value = TypeName}},_}->
            EmitFuncClause("Bytes,[H|T]"),
            emit([indent(3), {asis,dec_func(TypeName)}, "(H, Bytes, T)"]);
        {{Name,#'Externalvaluereference'{module = M,value = TypeName}},_}->
            EmitFuncClause("Bytes,[H|T]"),
            emit([indent(3), {asis,M}, ":", {asis,dec_func(TypeName)}, "(H, Bytes, T)"]);
        {{Name,#typedef{name = TypeName}},_}
            when is_atom(TypeName)->
            EmitFuncClause("Bytes,[H|T]"),
            emit([indent(3), {asis,dec_func(TypeName)}, "(H, Bytes, T)"])
    end,
    case more_genfields(Rest) of
        true->
            emit([";", nl]);
        false->
            emit([".", nl])
    end,
    gen_decode_objectfields(ClassName,Rest,ObjName,ObjectFields,ConstrAcc);
gen_decode_objectfields(CN,[_C| Cs],O,OF,CAcc) ->
    gen_decode_objectfields(CN,Cs,O,OF,CAcc);
gen_decode_objectfields(_,[],_,_,CAcc) ->
    CAcc.

emit_tlv_format(Bytes) ->
    notice_tlv_format_gen(),
    emit(["  Tlv = tlv_format(", Bytes, "),", nl]).

notice_tlv_format_gen() ->
    Module = get(currmod),
    case get(tlv_format) of
        {done,Module}->
            ok;
        _->
            put(tlv_format,true)
    end.

emit_tlv_format_function() ->
    Module = get(currmod),
    case get(tlv_format) of
        true->
            emit_tlv_format_function1(),
            put(tlv_format,{done,Module});
        _->
            ok
    end.

emit_tlv_format_function1() ->
    emit(["tlv_format(Bytes) when is_binary(Bytes) ->", nl, "  {Tlv,_} = ", {call,ber,ber_decode_nif,["Bytes"]}, com, nl, "  Tlv;", nl, "tlv_format(Bytes) ->", nl, "  Bytes.", nl]).

gen_decode_constr_type(Erules,[TypeDef| Rest])
    when is_record(TypeDef,typedef)->
    case is_already_generated(dec,TypeDef#typedef.name) of
        true->
            ok;
        _->
            emit([nl, nl, "'dec_", TypeDef#typedef.name, "'(Tlv, TagIn) ->", nl]),
            gen_decode_user(Erules,TypeDef)
    end,
    gen_decode_constr_type(Erules,Rest);
gen_decode_constr_type(_,[]) ->
    ok.

gen_decode_field_call(_ObjName,_FieldName,Bytes,#'Externaltypereference'{module = M,type = T}) ->
    CurrentMod = get(currmod),
    TDef = asn1_db:dbget(M,T),
    Def = TDef#typedef.typespec,
    OTag = Def#type.tag,
    Tag = [(decode_class(X#tag.class) bsl 10 + X#tag.number) || X <- OTag],
    if M == CurrentMod ->
        emit(["   ", {asis,dec_func(T)}, "(", Bytes, ", ", {asis,Tag}, ")"]),
        [];true ->
        emit(["   ", {asis,M}, ":", {asis,dec_func(T)}, "(", Bytes, ", ", {asis,Tag}, ")"]),
        [] end;
gen_decode_field_call(ObjName,FieldName,Bytes,Type) ->
    Def = Type#typedef.typespec,
    OTag = Def#type.tag,
    Tag = [(decode_class(X#tag.class) bsl 10 + X#tag.number) || X <- OTag],
    case Type#typedef.name of
        {primitive,bif}->
            gen_dec_prim(Def,Bytes,Tag),
            [];
        {constructed,bif}->
            Name = lists:concat([ObjName, "_", FieldName]),
            emit(["   ", {asis,dec_func(Name)}, "(", Bytes, ",", {asis,Tag}, ")"]),
            [Type#typedef{name = list_to_atom(Name)}];
        {ExtMod,TypeName}->
            emit(["   ", {asis,ExtMod}, ":", {asis,dec_func(TypeName)}, "(", Bytes, ",", {asis,Tag}, ")"]),
            [];
        TypeName->
            emit(["   ", {asis,dec_func(TypeName)}, "(", Bytes, ",", {asis,Tag}, ")"]),
            []
    end.

gen_decode_default_call(ClassName,FieldName,Bytes,Type) ->
    CurrentMod = get(currmod),
    InnerType = asn1ct_gen:get_inner(Type#type.def),
    OTag = Type#type.tag,
    Tag = [(decode_class(X#tag.class) bsl 10 + X#tag.number) || X <- OTag],
    case asn1ct_gen:type(InnerType) of
        {constructed,bif}->
            emit(["   'dec_", ClassName, _, FieldName, "'(", Bytes, ",", {asis,Tag}, ")"]),
            [#typedef{name = list_to_atom(lists:concat([ClassName, _, FieldName])),typespec = Type}];
        {primitive,bif}->
            gen_dec_prim(Type,Bytes,Tag),
            [];
        #'Externaltypereference'{module = CurrentMod,type = Etype}->
            emit(["   'dec_", Etype, "'(", Bytes, " ,", {asis,Tag}, ")", nl]),
            [];
        #'Externaltypereference'{module = Emod,type = Etype}->
            emit(["   '", Emod, "':'dec_", Etype, "'(", Bytes, ", ", {asis,Tag}, ")", nl]),
            []
    end.

is_already_generated(Operation,Name) ->
    case get(class_default_type) of
        undefined->
            put(class_default_type,[{Operation,Name}]),
            false;
        GeneratedList->
            case lists:member({Operation,Name},GeneratedList) of
                true->
                    true;
                false->
                    put(class_default_type,[{Operation,Name}| GeneratedList]),
                    false
            end
    end.

more_genfields([]) ->
    false;
more_genfields([Field| Fields]) ->
    case element(1,Field) of
        typefield->
            true;
        objectfield->
            true;
        _->
            more_genfields(Fields)
    end.

gen_objectset_code(Erules,ObjSet) ->
    ObjSetName = ObjSet#typedef.name,
    Def = ObjSet#typedef.typespec,
    #'Externaltypereference'{module = ClassModule,type = ClassName} = Def#'ObjectSet'.class,
    ClassDef = asn1_db:dbget(ClassModule,ClassName),
    UniqueFName = Def#'ObjectSet'.uniquefname,
    Set = Def#'ObjectSet'.set,
    emit([nl, nl, nl, "%%================================", nl, "%%  ", ObjSetName, nl, "%%================================", nl]),
    case ClassName of
        {_Module,ExtClassName}->
            gen_objset_code(Erules,ObjSetName,UniqueFName,Set,ExtClassName,ClassDef);
        _->
            gen_objset_code(Erules,ObjSetName,UniqueFName,Set,ClassName,ClassDef)
    end,
    emit(nl).

gen_objset_code(Erules,ObjSetName,UniqueFName,Set,ClassName,ClassDef) ->
    ClassFields = get_class_fields(ClassDef),
    InternalFuncs = gen_objset_enc(Erules,ObjSetName,UniqueFName,Set,ClassName,ClassFields,1,[]),
    gen_objset_dec(Erules,ObjSetName,UniqueFName,Set,ClassName,ClassFields,1),
    gen_internal_funcs(Erules,InternalFuncs).

gen_objset_enc(_,_,{unique,undefined},_,_,_,_,_) ->
    [];
gen_objset_enc(Erules,ObjSetName,UniqueName,[{ObjName,Val,Fields}| T],ClName,ClFields,NthObj,Acc) ->
    CurrMod = get(currmod),
    {InternalFunc,NewNthObj} = case ObjName of
        {no_mod,no_name}->
            gen_inlined_enc_funs(Fields,ClFields,ObjSetName,Val,NthObj);
        {CurrMod,Name}->
            emit([asis_atom(["getenc_", ObjSetName]), "(Id) when Id =:= ", {asis,Val}, " ->", nl, "    fun ", asis_atom(["enc_", Name]), "/3;", nl]),
            {[],NthObj};
        {ModuleName,Name}->
            emit([asis_atom(["getenc_", ObjSetName]), "(Id) when Id =:= ", {asis,Val}, " ->", nl]),
            emit_ext_fun(enc,ModuleName,Name),
            emit([";", nl]),
            {[],NthObj};
        _->
            emit([asis_atom(["getenc_", ObjSetName]), "(", {asis,Val}, ") ->", nl, "  fun ", asis_atom(["enc_", ObjName]), "/3;", nl]),
            {[],NthObj}
    end,
    gen_objset_enc(Erules,ObjSetName,UniqueName,T,ClName,ClFields,NewNthObj,InternalFunc ++ Acc);
gen_objset_enc(_,ObjSetName,_UniqueName,['EXTENSIONMARK'],_ClName,_ClFields,_NthObj,Acc) ->
    emit([asis_atom(["getenc_", ObjSetName]), "(_) ->", nl, indent(2), "fun(_, Val, _RestPrimFieldName) ->", nl]),
    emit_enc_open_type(4),
    emit([nl, indent(2), "end.", nl, nl]),
    Acc;
gen_objset_enc(_,ObjSetName,UniqueName,[],_,_,_,Acc) ->
    emit_default_getenc(ObjSetName,UniqueName),
    emit([".", nl, nl]),
    Acc.

emit_ext_fun(EncDec,ModuleName,Name) ->
    emit([indent(3), "fun(T,V,O) -> '", ModuleName, "':'", EncDec, "_", Name, "'(T,V,O) end"]).

emit_default_getenc(ObjSetName,UniqueName) ->
    emit([asis_atom(["getenc_", ObjSetName]), "(ErrV) ->", nl, indent(3), "fun(C,V,_) ->", nl, "exit({'Type not compatible with table constraint',{component" ",C},{value,V}, {unique_name_and_value,", {asis,UniqueName}, ", ErrV}}) end"]).

gen_inlined_enc_funs(Fields,[{typefield,_,_}| _] = T,ObjSetName,Val,NthObj) ->
    emit([asis_atom(["getenc_", ObjSetName]), "(", {asis,Val}, ") ->", nl, indent(3), "fun(Type, Val, _RestPrimFieldName) ->", nl, indent(6), "case Type of", nl]),
    gen_inlined_enc_funs1(Fields,T,ObjSetName,[],NthObj,[]);
gen_inlined_enc_funs(Fields,[_| Rest],ObjSetName,Val,NthObj) ->
    gen_inlined_enc_funs(Fields,Rest,ObjSetName,Val,NthObj);
gen_inlined_enc_funs(_,[],_,_,NthObj) ->
    {[],NthObj}.

gen_inlined_enc_funs1(Fields,[{typefield,Name,_}| Rest],ObjSetName,Sep0,NthObj,Acc0) ->
    emit(Sep0),
    Sep = [";", nl],
    CurrMod = get(currmod),
    InternalDefFunName = asn1ct_gen:list2name([NthObj, Name, ObjSetName]),
    {Acc,NAdd} = case lists:keyfind(Name,1,Fields) of
        {_,#type{} = Type}->
            {Ret,N} = emit_inner_of_fun(Type,InternalDefFunName),
            {Ret ++ Acc0,N};
        {_,#typedef{} = Type}->
            emit([indent(9), {asis,Name}, " ->", nl]),
            {Ret,N} = emit_inner_of_fun(Type,InternalDefFunName),
            {Ret ++ Acc0,N};
        {_,#'Externaltypereference'{module = M,type = T}}->
            emit([indent(9), {asis,Name}, " ->", nl]),
            if M =:= CurrMod ->
                emit([indent(12), "'enc_", T, "'(Val)"]);true ->
                #typedef{typespec = Type} = asn1_db:dbget(M,T),
                OTag = Type#type.tag,
                Tag = [(encode_tag_val(decode_class(X#tag.class),X#tag.form,X#tag.number)) || X <- OTag],
                emit([indent(12), "'", M, "':'enc_", T, "'(Val, ", {asis,Tag}, ")"]) end,
            {Acc0,0};
        false->
            emit([indent(9), {asis,Name}, " ->", nl]),
            emit_enc_open_type(11),
            {Acc0,0}
    end,
    gen_inlined_enc_funs1(Fields,Rest,ObjSetName,Sep,NthObj + NAdd,Acc);
gen_inlined_enc_funs1(Fields,[_| Rest],ObjSetName,Sep,NthObj,Acc) ->
    gen_inlined_enc_funs1(Fields,Rest,ObjSetName,Sep,NthObj,Acc);
gen_inlined_enc_funs1(_,[],_,_,NthObj,Acc) ->
    emit([nl, indent(6), "end", nl, indent(3), "end;", nl]),
    {Acc,NthObj}.

emit_enc_open_type(I) ->
    Indent = indent(I),
    S = [Indent, "case Val of", nl, Indent, indent(2), "{asn1_OPENTYPE,Bin} when is_binary(Bin) ->", nl, Indent, indent(4), "{Bin,byte_size(Bin)}"| case asn1ct:use_legacy_types() of
        false->
            [nl, Indent, "end"];
        true->
            [";", nl, Indent, indent(2), "Bin when is_binary(Bin) ->", nl, Indent, indent(4), "{Bin,byte_size(Bin)};", nl, Indent, indent(2), "_ ->", nl, Indent, indent(4), "{Val,length(Val)}", nl, Indent, "end"]
    end],
    emit(S).

emit_inner_of_fun(TDef = #typedef{name = {ExtMod,Name},typespec = Type},InternalDefFunName) ->
    OTag = Type#type.tag,
    Tag = [(encode_tag_val(decode_class(X#tag.class),X#tag.form,X#tag.number)) || X <- OTag],
    case {ExtMod,Name} of
        {primitive,bif}->
            emit(indent(12)),
            gen_encode_prim(ber,Type,[{asis,lists:reverse(Tag)}],"Val"),
            {[],0};
        {constructed,bif}->
            emit([indent(12), "'enc_", InternalDefFunName, "'(Val, ", {asis,Tag}, ")"]),
            {[TDef#typedef{name = InternalDefFunName}],1};
        _->
            emit([indent(12), "'", ExtMod, "':'enc_", Name, "'(Val", {asis,Tag}, ")"]),
            {[],0}
    end;
emit_inner_of_fun(#typedef{name = Name},_) ->
    emit([indent(12), "'enc_", Name, "'(Val)"]),
    {[],0};
emit_inner_of_fun(Type,_)
    when is_record(Type,type)->
    CurrMod = get(currmod),
    case Type#type.def of
        Def
            when is_atom(Def)->
            OTag = Type#type.tag,
            Tag = [(encode_tag_val(decode_class(X#tag.class),X#tag.form,X#tag.number)) || X <- OTag],
            emit([indent(9), Def, " ->", nl, indent(12)]),
            gen_encode_prim(ber,Type,{asis,lists:reverse(Tag)},"Val");
        #'Externaltypereference'{module = CurrMod,type = T}->
            emit([indent(9), T, " ->", nl, indent(12), "'enc_", T, "'(Val)"]);
        #'Externaltypereference'{module = ExtMod,type = T}->
            #typedef{typespec = ExtType} = asn1_db:dbget(ExtMod,T),
            OTag = ExtType#type.tag,
            Tag = [(encode_tag_val(decode_class(X#tag.class),X#tag.form,X#tag.number)) || X <- OTag],
            emit([indent(9), T, " ->", nl, indent(12), ExtMod, ":'enc_", T, "'(Val, ", {asis,Tag}, ")"])
    end,
    {[],0}.

indent(N) ->
    lists:duplicate(N,32).

gen_objset_dec(_,_,{unique,undefined},_,_,_,_) ->
    ok;
gen_objset_dec(Erules,ObjSName,UniqueName,[{ObjName,Val,Fields}| T],ClName,ClFields,NthObj) ->
    CurrMod = get(currmod),
    NewNthObj = case ObjName of
        {no_mod,no_name}->
            gen_inlined_dec_funs(Fields,ClFields,ObjSName,Val,NthObj);
        {CurrMod,Name}->
            emit([asis_atom(["getdec_", ObjSName]), "(Id) when Id =:= ", {asis,Val}, " ->", nl, "    fun 'dec_", Name, "'/3;", nl]),
            NthObj;
        {ModuleName,Name}->
            emit([asis_atom(["getdec_", ObjSName]), "(Id) when Id =:= ", {asis,Val}, " ->", nl]),
            emit_ext_fun(dec,ModuleName,Name),
            emit([";", nl]),
            NthObj;
        _->
            emit([asis_atom(["getdec_", ObjSName]), "(", {asis,Val}, ") ->", nl, "    fun 'dec_", ObjName, "'/3;", nl]),
            NthObj
    end,
    gen_objset_dec(Erules,ObjSName,UniqueName,T,ClName,ClFields,NewNthObj);
gen_objset_dec(_,ObjSetName,_UniqueName,['EXTENSIONMARK'],_ClName,_ClFields,_NthObj) ->
    emit([asis_atom(["getdec_", ObjSetName]), "(_) ->", nl, indent(2), "fun(_,Bytes, _RestPrimFieldName) ->", nl]),
    emit_dec_open_type(4),
    emit([nl, indent(2), "end.", nl, nl]),
    ok;
gen_objset_dec(_,ObjSetName,UniqueName,[],_,_,_) ->
    emit_default_getdec(ObjSetName,UniqueName),
    emit([".", nl, nl]),
    ok.

emit_default_getdec(ObjSetName,UniqueName) ->
    emit(["'getdec_", ObjSetName, "'(ErrV) ->", nl]),
    emit([indent(2), "fun(C,V,_) -> exit({{component,C},{value,V},{unique_name_and" "_value,", {asis,UniqueName}, ", ErrV}}) end"]).

gen_inlined_dec_funs(Fields,[{typefield,_,_}| _] = ClFields,ObjSetName,Val,NthObj) ->
    emit(["'getdec_", ObjSetName, "'(", {asis,Val}, ") ->", nl]),
    emit([indent(3), "fun(Type, Bytes, _RestPrimFieldName) ->", nl, indent(6), "case Type of", nl]),
    gen_inlined_dec_funs1(Fields,ClFields,ObjSetName,"",NthObj);
gen_inlined_dec_funs(Fields,[_| ClFields],ObjSetName,Val,NthObj) ->
    gen_inlined_dec_funs(Fields,ClFields,ObjSetName,Val,NthObj);
gen_inlined_dec_funs(_,_,_,_,NthObj) ->
    NthObj.

gen_inlined_dec_funs1(Fields,[{typefield,Name,Prop}| Rest],ObjSetName,Sep0,NthObj) ->
    emit(Sep0),
    Sep = [";", nl],
    DecProp = case Prop of
        'OPTIONAL'->
            opt_or_default;
        {'DEFAULT',_}->
            opt_or_default;
        _->
            mandatory
    end,
    InternalDefFunName = [NthObj, Name, ObjSetName],
    N = case lists:keyfind(Name,1,Fields) of
        {_,#type{} = Type}->
            emit_inner_of_decfun(Type,DecProp,InternalDefFunName);
        {_,#typedef{} = Type}->
            emit([indent(9), {asis,Name}, " ->", nl]),
            emit_inner_of_decfun(Type,DecProp,InternalDefFunName);
        {_,#'Externaltypereference'{module = M,type = T}}->
            emit([indent(9), {asis,Name}, " ->", nl]),
            CurrMod = get(currmod),
            if M =:= CurrMod ->
                emit([indent(12), "'dec_", T, "'(Bytes)"]);true ->
                #typedef{typespec = Type} = asn1_db:dbget(M,T),
                OTag = Type#type.tag,
                Tag = [(decode_class(X#tag.class) bsl 10 + X#tag.number) || X <- OTag],
                emit([indent(12), "'", M, "':'dec_", T, "'(Bytes, ", {asis,Tag}, ")"]) end,
            0;
        false->
            emit([indent(9), {asis,Name}, " ->", nl]),
            emit_dec_open_type(11),
            0
    end,
    gen_inlined_dec_funs1(Fields,Rest,ObjSetName,Sep,NthObj + N);
gen_inlined_dec_funs1(Fields,[_| Rest],ObjSetName,Sep,NthObj) ->
    gen_inlined_dec_funs1(Fields,Rest,ObjSetName,Sep,NthObj);
gen_inlined_dec_funs1(_,[],_,_,NthObj) ->
    emit([nl, indent(6), "end", nl, indent(3), "end;", nl]),
    NthObj.

emit_dec_open_type(I) ->
    Indent = indent(I),
    S = case asn1ct:use_legacy_types() of
        false->
            [Indent, "case Bytes of", nl, Indent, indent(2), "Bin when is_binary(Bin) -> ", nl, Indent, indent(4), "{asn1_OPENTYPE,Bin};", nl, Indent, indent(2), "_ ->", nl, Indent, indent(4), "{asn1_OPENTYPE,", {call,ber,ber_encode,["Bytes"]}, "}", nl, Indent, "end"];
        true->
            [Indent, "case Bytes of", nl, Indent, indent(2), "Bin when is_binary(Bin) -> ", nl, Indent, indent(4), "Bin;", nl, Indent, indent(2), "_ ->", nl, Indent, indent(4), {call,ber,ber_encode,["Bytes"]}, nl, Indent, "end"]
    end,
    emit(S).

emit_inner_of_decfun(#typedef{name = {ExtName,Name},typespec = Type},_Prop,InternalDefFunName) ->
    OTag = Type#type.tag,
    Tag = [(decode_class(X#tag.class) bsl 10 + X#tag.number) || X <- OTag],
    case {ExtName,Name} of
        {primitive,bif}->
            emit(indent(12)),
            gen_dec_prim(Type,"Bytes",Tag),
            0;
        {constructed,bif}->
            emit([indent(12), "'dec_", asn1ct_gen:list2name(InternalDefFunName), "'(Bytes, ", {asis,Tag}, ")"]),
            1;
        _->
            emit([indent(12), "'", ExtName, "':'dec_", Name, "'(Bytes, ", {asis,Tag}, ")"]),
            0
    end;
emit_inner_of_decfun(#typedef{name = Name},_Prop,_) ->
    emit([indent(12), "'dec_", Name, "'(Bytes)"]),
    0;
emit_inner_of_decfun(#type{} = Type,_Prop,_) ->
    OTag = Type#type.tag,
    Tag = [(decode_class(X#tag.class) bsl 10 + X#tag.number) || X <- OTag],
    CurrMod = get(currmod),
    Def = Type#type.def,
    InnerType = asn1ct_gen:get_inner(Def),
    WhatKind = asn1ct_gen:type(InnerType),
    case WhatKind of
        {primitive,bif}->
            emit([indent(9), Def, " ->", nl, indent(12)]),
            gen_dec_prim(Type,"Bytes",Tag);
        #'Externaltypereference'{module = CurrMod,type = T}->
            emit([indent(9), T, " ->", nl, indent(12), "'dec_", T, "'(Bytes)"]);
        #'Externaltypereference'{module = ExtMod,type = T}->
            emit([indent(9), T, " ->", nl, indent(12), ExtMod, ":'dec_", T, "'(Bytes, ", {asis,Tag}, ")"])
    end,
    0.

gen_internal_funcs(_,[]) ->
    ok;
gen_internal_funcs(Erules,[TypeDef| Rest]) ->
    gen_encode_user(Erules,TypeDef,false),
    emit([nl, nl, "'dec_", TypeDef#typedef.name, "'(Tlv, TagIn) ->", nl]),
    gen_decode_user(Erules,TypeDef),
    gen_internal_funcs(Erules,Rest).

decode_class('UNIVERSAL') ->
    0;
decode_class('APPLICATION') ->
    64;
decode_class('CONTEXT') ->
    128;
decode_class('PRIVATE') ->
    192.

mkfuncname(#'Externaltypereference'{module = Mod,type = EType},DecOrEnc) ->
    CurrMod = get(currmod),
    case CurrMod of
        Mod->
            lists:concat(["'", DecOrEnc, "_", EType, "'"]);
        _->
            lists:concat(["'", Mod, "':'", DecOrEnc, "_", EType, "'"])
    end.

get_size_constraint(C) ->
    case lists:keyfind('SizeConstraint',1,C) of
        false->
            [];
        {_,{_,[]}}->
            [];
        {_,{Sv,Sv}}->
            Sv;
        {_,{_,_} = Tc}->
            Tc
    end.

get_class_fields(#classdef{typespec = ObjClass}) ->
    ObjClass#objectclass.fields;
get_class_fields(#objectclass{fields = Fields}) ->
    Fields;
get_class_fields(_) ->
    [].

get_object_field(Name,ObjectFields) ->
    case lists:keysearch(Name,1,ObjectFields) of
        {value,Field}->
            Field;
        false->
            false
    end.

encode_tag_val(Class,Form,TagNo)
    when TagNo =< 30->
    <<(Class bsr 6):2,(Form bsr 5):1,TagNo:5>>;
encode_tag_val(Class,Form,TagNo) ->
    {Octets,_Len} = mk_object_val(TagNo),
    BinOct = list_to_binary(Octets),
    <<(Class bsr 6):2,(Form bsr 5):1,31:5,BinOct/binary>>.

mk_object_val(Val)
    when Val =< 127->
    {[255 band Val],1};
mk_object_val(Val) ->
    mk_object_val(Val bsr 7,[Val band 127],1).

mk_object_val(0,Ack,Len) ->
    {Ack,Len};
mk_object_val(Val,Ack,Len) ->
    mk_object_val(Val bsr 7,[Val band 127 bor 128| Ack],Len + 1).

extaddgroup2sequence(ExtList)
    when is_list(ExtList)->
    lists:filter(fun (#'ExtensionAdditionGroup'{})->
        false;('ExtensionAdditionGroupEnd')->
        false;(_)->
        true end,ExtList).

call(F,Args) ->
    asn1ct_func:call(ber,F,Args).

enc_func(Tname) ->
    list_to_atom(lists:concat(["enc_", Tname])).

dec_func(Tname) ->
    list_to_atom(lists:concat(["dec_", Tname])).

asis_atom(List) ->
    {asis,list_to_atom(lists:concat(List))}.
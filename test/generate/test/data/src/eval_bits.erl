-file("eval_bits.erl", 1).

-module(eval_bits).

-compile({no_auto_import,[{error,1}]}).

-export([expr_grp/3, expr_grp/5, match_bits/6, match_bits/7, bin_gen/6]).

expr_grp(Fields,Bindings,EvalFun,[],_) ->
    expr_grp(Fields,Bindings,EvalFun,<<>>);
expr_grp(Fields,Bindings,EvalFun,ListOfBits,_) ->
    Bin = convert_list(ListOfBits),
    expr_grp(Fields,Bindings,EvalFun,Bin).

convert_list(List) ->
    <<<<X:1>> || X <- List>>.

expr_grp(Fields,Bindings,EvalFun) ->
    expr_grp(Fields,Bindings,EvalFun,<<>>).

expr_grp([Field| FS],Bs0,Lf,Acc) ->
    {Bin,Bs} = eval_field(Field,Bs0,Lf),
    expr_grp(FS,Bs,Lf,<<Acc/binary-unit:1,Bin/binary-unit:1>>);
expr_grp([],Bs0,_Lf,Acc) ->
    {value,Acc,Bs0}.

eval_field({bin_element,_,{string,_,S},{integer,_,8},[integer, {unit,1}, unsigned, big]},Bs0,_Fun) ->
    Latin1 = [(C band 255) || C <- S],
    {list_to_binary(Latin1),Bs0};
eval_field({bin_element,_,{string,_,S},default,default},Bs0,_Fun) ->
    Latin1 = [(C band 255) || C <- S],
    {list_to_binary(Latin1),Bs0};
eval_field({bin_element,Line,{string,_,S},Size0,Options0},Bs0,Fun) ->
    {Size1,[Type, {unit,Unit}, Sign, Endian]} = make_bit_type(Line,Size0,Options0),
    {value,Size,Bs1} = Fun(Size1,Bs0),
    Res = <<<<(eval_exp_field1(C,Size,Unit,Type,Endian,Sign))/bitstring>> || C <- S>>,
    case S of
        ""->
            _ = eval_exp_field1(0,Size,Unit,Type,Endian,Sign),
            ok;
        _->
            ok
    end,
    {Res,Bs1};
eval_field({bin_element,Line,E,Size0,Options0},Bs0,Fun) ->
    {value,V,Bs1} = Fun(E,Bs0),
    {Size1,[Type, {unit,Unit}, Sign, Endian]} = make_bit_type(Line,Size0,Options0),
    {value,Size,Bs} = Fun(Size1,Bs1),
    {eval_exp_field1(V,Size,Unit,Type,Endian,Sign),Bs}.

eval_exp_field1(V,Size,Unit,Type,Endian,Sign) ->
    try eval_exp_field(V,Size,Unit,Type,Endian,Sign)
        catch
            error:system_limit->
                erlang:raise(error,system_limit,element(2,process_info(self(),current_stacktrace)));
            error:_->
                erlang:raise(error,badarg,element(2,process_info(self(),current_stacktrace))) end.

eval_exp_field(Val,Size,Unit,integer,little,signed) ->
    <<Val:(Size * Unit)/little-signed>>;
eval_exp_field(Val,Size,Unit,integer,little,unsigned) ->
    <<Val:(Size * Unit)/little>>;
eval_exp_field(Val,Size,Unit,integer,native,signed) ->
    <<Val:(Size * Unit)/native-signed>>;
eval_exp_field(Val,Size,Unit,integer,native,unsigned) ->
    <<Val:(Size * Unit)/native>>;
eval_exp_field(Val,Size,Unit,integer,big,signed) ->
    <<Val:(Size * Unit)/signed>>;
eval_exp_field(Val,Size,Unit,integer,big,unsigned) ->
    <<Val:(Size * Unit)>>;
eval_exp_field(Val,_Size,_Unit,utf8,_,_) ->
    <<Val/utf8>>;
eval_exp_field(Val,_Size,_Unit,utf16,big,_) ->
    <<Val/big-utf16>>;
eval_exp_field(Val,_Size,_Unit,utf16,little,_) ->
    <<Val/little-utf16>>;
eval_exp_field(Val,_Size,_Unit,utf16,native,_) ->
    <<Val/native-utf16>>;
eval_exp_field(Val,_Size,_Unit,utf32,big,_) ->
    <<Val/big-utf32>>;
eval_exp_field(Val,_Size,_Unit,utf32,little,_) ->
    <<Val/little-utf32>>;
eval_exp_field(Val,_Size,_Unit,utf32,native,_) ->
    <<Val/native-utf32>>;
eval_exp_field(Val,Size,Unit,float,little,_) ->
    <<Val:(Size * Unit)/float-little>>;
eval_exp_field(Val,Size,Unit,float,native,_) ->
    <<Val:(Size * Unit)/float-native>>;
eval_exp_field(Val,Size,Unit,float,big,_) ->
    <<Val:(Size * Unit)/float>>;
eval_exp_field(Val,all,Unit,binary,_,_) ->
    case bit_size(Val) of
        Size
            when Size rem Unit =:= 0->
            <<Val:Size/binary-unit:1>>;
        _->
            erlang:raise(error,badarg,element(2,process_info(self(),current_stacktrace)))
    end;
eval_exp_field(Val,Size,Unit,binary,_,_) ->
    <<Val:(Size * Unit)/binary-unit:1>>.

bin_gen({bin,_,Fs},Bin,Bs0,BBs0,Mfun,Efun) ->
    bin_gen(Fs,Bin,Bs0,BBs0,Mfun,Efun,true).

bin_gen([F| Fs],Bin,Bs0,BBs0,Mfun,Efun,Flag)
    when is_function(Mfun,2),
    is_function(Efun,2)->
    case bin_gen_field(F,Bin,Bs0,BBs0,Mfun,Efun) of
        {match,Bs,BBs,Rest}->
            bin_gen(Fs,Rest,Bs,BBs,Mfun,Efun,Flag);
        {nomatch,Rest}->
            bin_gen(Fs,Rest,Bs0,BBs0,Mfun,Efun,false);
        done->
            done
    end;
bin_gen([],Bin,Bs0,_BBs0,_Mfun,_Efun,true) ->
    {match,Bin,Bs0};
bin_gen([],Bin,_Bs0,_BBs0,_Mfun,_Efun,false) ->
    {nomatch,Bin}.

bin_gen_field({bin_element,_,{string,_,S},default,default},Bin,Bs,BBs,_Mfun,_Efun) ->
    Bits = try list_to_binary(S)
        catch
            _:_->
                <<>> end,
    Size = length(S),
    case Bin of
        <<Bits:Size/binary,Rest/bitstring>>->
            {match,Bs,BBs,Rest};
        <<_:Size/binary,Rest/bitstring>>->
            {nomatch,Rest};
        _->
            done
    end;
bin_gen_field({bin_element,Line,{string,SLine,S},Size0,Options0},Bin0,Bs0,BBs0,Mfun,Efun) ->
    {Size1,[Type, {unit,Unit}, Sign, Endian]} = make_bit_type(Line,Size0,Options0),
    {value,Size,_BBs} = Efun(Size1,BBs0),
    F = fun (C,Bin,Bs,BBs)->
        bin_gen_field1(Bin,Type,Size,Unit,Sign,Endian,{integer,SLine,C},Bs,BBs,Mfun) end,
    bin_gen_field_string(S,Bin0,Bs0,BBs0,F);
bin_gen_field({bin_element,Line,VE,Size0,Options0},Bin,Bs0,BBs0,Mfun,Efun) ->
    {Size1,[Type, {unit,Unit}, Sign, Endian]} = make_bit_type(Line,Size0,Options0),
    V = erl_eval:partial_eval(VE),
    NewV = coerce_to_float(V,Type),
    {value,Size,_BBs} = Efun(Size1,BBs0),
    bin_gen_field1(Bin,Type,Size,Unit,Sign,Endian,NewV,Bs0,BBs0,Mfun).

bin_gen_field_string([],Rest,Bs,BBs,_F) ->
    {match,Bs,BBs,Rest};
bin_gen_field_string([C| Cs],Bin0,Bs0,BBs0,Fun) ->
    case Fun(C,Bin0,Bs0,BBs0) of
        {match,Bs,BBs,Rest}->
            bin_gen_field_string(Cs,Rest,Bs,BBs,Fun);
        {nomatch,Rest}->
            {nomatch,Rest};
        done->
            done
    end.

bin_gen_field1(Bin,Type,Size,Unit,Sign,Endian,NewV,Bs0,BBs0,Mfun) ->
    case  catch get_value(Bin,Type,Size,Unit,Sign,Endian) of
        {Val,<<_/bitstring>> = Rest}->
            case  catch Mfun(match,{NewV,Val,Bs0}) of
                {match,Bs}->
                    BBs = add_bin_binding(Mfun,NewV,Bs,BBs0),
                    {match,Bs,BBs,Rest};
                _->
                    {nomatch,Rest}
            end;
        _->
            done
    end.

match_bits(Fs,Bin,Bs0,BBs,Mfun,Efun,_) ->
    match_bits(Fs,Bin,Bs0,BBs,Mfun,Efun).

match_bits(Fs,Bin,Bs0,BBs,Mfun,Efun)
    when is_function(Mfun,2),
    is_function(Efun,2)->
    case  catch match_bits_1(Fs,Bin,Bs0,BBs,Mfun,Efun) of
        {match,Bs}->
            {match,Bs};
        invalid->
            throw(invalid);
        _Error->
            throw(nomatch)
    end.

match_bits_1([],<<>>,Bs,_BBs,_Mfun,_Efun) ->
    {match,Bs};
match_bits_1([F| Fs],Bits0,Bs0,BBs0,Mfun,Efun) ->
    {Bs,BBs,Bits} = match_field_1(F,Bits0,Bs0,BBs0,Mfun,Efun),
    match_bits_1(Fs,Bits,Bs,BBs,Mfun,Efun).

match_field_1({bin_element,_,{string,_,S},default,default},Bin,Bs,BBs,_Mfun,_Efun) ->
    Bits = list_to_binary(S),
    Size = byte_size(Bits),
    <<Bits:Size/binary,Rest/binary-unit:1>> = Bin,
    {Bs,BBs,Rest};
match_field_1({bin_element,Line,{string,SLine,S},Size0,Options0},Bin0,Bs0,BBs0,Mfun,Efun) ->
    {Size1,[Type, {unit,Unit}, Sign, Endian]} = make_bit_type(Line,Size0,Options0),
    Size2 = erl_eval:partial_eval(Size1),
    {value,Size,_BBs} = Efun(Size2,BBs0),
    F = fun (C,Bin,Bs,BBs)->
        match_field(Bin,Type,Size,Unit,Sign,Endian,{integer,SLine,C},Bs,BBs,Mfun) end,
    match_field_string(S,Bin0,Bs0,BBs0,F);
match_field_1({bin_element,Line,VE,Size0,Options0},Bin,Bs0,BBs0,Mfun,Efun) ->
    {Size1,[Type, {unit,Unit}, Sign, Endian]} = make_bit_type(Line,Size0,Options0),
    V = erl_eval:partial_eval(VE),
    NewV = coerce_to_float(V,Type),
    Size2 = erl_eval:partial_eval(Size1),
    {value,Size,_BBs} = Efun(Size2,BBs0),
    match_field(Bin,Type,Size,Unit,Sign,Endian,NewV,Bs0,BBs0,Mfun).

match_field_string([],Rest,Bs,BBs,_Fun) ->
    {Bs,BBs,Rest};
match_field_string([C| Cs],Bin0,Bs0,BBs0,Fun) ->
    {Bs,BBs,Bin} = Fun(C,Bin0,Bs0,BBs0),
    match_field_string(Cs,Bin,Bs,BBs,Fun).

match_field(Bin,Type,Size,Unit,Sign,Endian,NewV,Bs0,BBs0,Mfun) ->
    {Val,Rest} = get_value(Bin,Type,Size,Unit,Sign,Endian),
    {match,Bs} = Mfun(match,{NewV,Val,Bs0}),
    BBs = add_bin_binding(Mfun,NewV,Bs,BBs0),
    {Bs,BBs,Rest}.

coerce_to_float({integer,L,I} = E,float) ->
    try {float,L,float(I)}
        catch
            error:badarg->
                E;
            error:badarith->
                E end;
coerce_to_float(E,_Type) ->
    E.

add_bin_binding(_,{var,_,_},_Bs,BBs) ->
    BBs;
add_bin_binding(Mfun,{var,_,Name},Bs,BBs) ->
    {value,Value} = Mfun(binding,{Name,Bs}),
    Mfun(add_binding,{Name,Value,BBs});
add_bin_binding(_,_,_Bs,BBs) ->
    BBs.

get_value(Bin,integer,Size,Unit,Sign,Endian) ->
    get_integer(Bin,Size * Unit,Sign,Endian);
get_value(Bin,float,Size,Unit,_Sign,Endian) ->
    get_float(Bin,Size * Unit,Endian);
get_value(Bin,utf8,undefined,_Unit,_Sign,_Endian) ->
    <<I/utf8,Rest/bits>> = Bin,
    {I,Rest};
get_value(Bin,utf16,undefined,_Unit,_Sign,big) ->
    <<I/big-utf16,Rest/bits>> = Bin,
    {I,Rest};
get_value(Bin,utf16,undefined,_Unit,_Sign,little) ->
    <<I/little-utf16,Rest/bits>> = Bin,
    {I,Rest};
get_value(Bin,utf16,undefined,_Unit,_Sign,native) ->
    <<I/native-utf16,Rest/bits>> = Bin,
    {I,Rest};
get_value(Bin,utf32,undefined,_Unit,_Sign,big) ->
    <<Val/big-utf32,Rest/bits>> = Bin,
    {Val,Rest};
get_value(Bin,utf32,undefined,_Unit,_Sign,little) ->
    <<Val/little-utf32,Rest/bits>> = Bin,
    {Val,Rest};
get_value(Bin,utf32,undefined,_Unit,_Sign,native) ->
    <<Val/native-utf32,Rest/bits>> = Bin,
    {Val,Rest};
get_value(Bin,binary,all,Unit,_Sign,_Endian) ->
    0 = bit_size(Bin) rem Unit,
    {Bin,<<>>};
get_value(Bin,binary,Size,Unit,_Sign,_Endian) ->
    TotSize = Size * Unit,
    <<Val:TotSize/bitstring,Rest/bits>> = Bin,
    {Val,Rest}.

get_integer(Bin,Size,signed,little) ->
    <<Val:Size/little-signed,Rest/binary-unit:1>> = Bin,
    {Val,Rest};
get_integer(Bin,Size,unsigned,little) ->
    <<Val:Size/little,Rest/binary-unit:1>> = Bin,
    {Val,Rest};
get_integer(Bin,Size,signed,native) ->
    <<Val:Size/native-signed,Rest/binary-unit:1>> = Bin,
    {Val,Rest};
get_integer(Bin,Size,unsigned,native) ->
    <<Val:Size/native,Rest/binary-unit:1>> = Bin,
    {Val,Rest};
get_integer(Bin,Size,signed,big) ->
    <<Val:Size/signed,Rest/binary-unit:1>> = Bin,
    {Val,Rest};
get_integer(Bin,Size,unsigned,big) ->
    <<Val:Size,Rest/binary-unit:1>> = Bin,
    {Val,Rest}.

get_float(Bin,Size,little) ->
    <<Val:Size/float-little,Rest/binary-unit:1>> = Bin,
    {Val,Rest};
get_float(Bin,Size,native) ->
    <<Val:Size/float-native,Rest/binary-unit:1>> = Bin,
    {Val,Rest};
get_float(Bin,Size,big) ->
    <<Val:Size/float,Rest/binary-unit:1>> = Bin,
    {Val,Rest}.

make_bit_type(Line,default,Type0) ->
    case erl_bits:set_bit_type(default,Type0) of
        {ok,all,Bt}->
            {{atom,Line,all},erl_bits:as_list(Bt)};
        {ok,undefined,Bt}->
            {{atom,Line,undefined},erl_bits:as_list(Bt)};
        {ok,Size,Bt}->
            {{integer,Line,Size},erl_bits:as_list(Bt)};
        {error,Reason}->
            erlang:raise(error,Reason,element(2,process_info(self(),current_stacktrace)))
    end;
make_bit_type(_Line,Size,Type0) ->
    case erl_bits:set_bit_type(Size,Type0) of
        {ok,Size,Bt}->
            {Size,erl_bits:as_list(Bt)};
        {error,Reason}->
            erlang:raise(error,Reason,element(2,process_info(self(),current_stacktrace)))
    end.
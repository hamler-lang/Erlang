-file("ms_transform.erl", 1).

-module(ms_transform).

-export([format_error/1, transform_from_shell/3, parse_transform/2]).

-spec(format_error(Error) -> Chars when Error::{error,module(),term()},Chars::io_lib:chars()).

format_error({50,Name}) ->
    lists:flatten(io_lib:format("variable ~p shadowed in ms_transform f" "un head",[Name]));
format_error(1) ->
    "Parameter of ets/dbg:fun2ms/1 is not a literal fun";
format_error(2) ->
    "ets:fun2ms requires fun with single variable or tuple parameter";
format_error(3) ->
    "dbg:fun2ms requires fun with single variable or list parameter";
format_error(4) ->
    "in fun head, only matching (=) on toplevel can be translated into " "match_spec";
format_error(5) ->
    "fun with semicolon (;) in guard cannot be translated into match_sp" "ec";
format_error(16 + 0) ->
    "fun with guard matching ('=' in guard) is illegal as match_spec as" " well";
format_error({17 + 0,Name,Arithy}) ->
    lists:flatten(io_lib:format("fun containing the local function call" " '~tw/~w' (called in guard) cannot be " "translated into match_spec",[Name, Arithy]));
format_error({22 + 0,Module,Name,Arithy}) ->
    lists:flatten(io_lib:format("fun containing the remote function cal" "l '~w:~tw/~w' (called in guard) cannot" " be translated into match_spec",[Module, Name, Arithy]));
format_error({18 + 0,Str}) ->
    lists:flatten(io_lib:format("the language element ~ts (in guard) ca" "nnot be translated into match_spec",[Str]));
format_error({23 + 0,Var}) ->
    lists:flatten(io_lib:format("bit syntax construction with variable " "~w (in guard) cannot be translated int" "o match_spec",[Var]));
format_error({24 + 0,Operator}) ->
    lists:flatten(io_lib:format("the operator ~w is not allowed in guar" "ds",[Operator]));
format_error(16 + 100) ->
    "fun with body matching ('=' in body) is illegal as match_spec";
format_error({17 + 100,Name,Arithy}) ->
    lists:flatten(io_lib:format("fun containing the local function call" " '~tw/~w' (called in body) cannot be t" "ranslated into match_spec",[Name, Arithy]));
format_error({22 + 100,Module,Name,Arithy}) ->
    lists:flatten(io_lib:format("fun containing the remote function cal" "l '~w:~tw/~w' (called in body) cannot " "be translated into match_spec",[Module, Name, Arithy]));
format_error({18 + 100,Str}) ->
    lists:flatten(io_lib:format("the language element ~ts (in body) can" "not be translated into match_spec",[Str]));
format_error({23 + 100,Var}) ->
    lists:flatten(io_lib:format("bit syntax construction with variable " "~w (in body) cannot be translated into" " match_spec",[Var]));
format_error({24 + 100,Operator}) ->
    lists:flatten(io_lib:format("the operator ~w is not allowed in func" "tion bodies",[Operator]));
format_error({6,Str}) ->
    lists:flatten(io_lib:format("the variable ~s is unbound, cannot tra" "nslate into match_spec",[Str]));
format_error({7,Name}) ->
    lists:flatten(io_lib:format("fun head contains unknown record type " "~tw",[Name]));
format_error({8,RName,FName}) ->
    lists:flatten(io_lib:format("fun head contains reference to unknown" " field ~tw in record type ~tw",[FName, RName]));
format_error({9,RName,FName}) ->
    lists:flatten(io_lib:format("fun head contains already defined fiel" "d ~tw in record type ~tw",[FName, RName]));
format_error({10,Atom}) ->
    lists:flatten(io_lib:format("fun head contains atom ~w, which confl" "ics with reserved atoms in match_spec " "heads",[Atom]));
format_error({11,Atom}) ->
    lists:flatten(io_lib:format("fun head contains bit syntax matching " "of variable ~w, which cannot be transl" "ated into match_spec",[Atom]));
format_error({20 + 0,Name}) ->
    lists:flatten(io_lib:format("fun guard contains unknown record type" " ~tw",[Name]));
format_error({19 + 0,RName,FName}) ->
    lists:flatten(io_lib:format("fun guard contains reference to unknow" "n field ~tw in record type ~tw",[FName, RName]));
format_error({21 + 0,RName,FName}) ->
    lists:flatten(io_lib:format("fun guard contains already defined fie" "ld ~tw in record type ~tw",[FName, RName]));
format_error({20 + 100,Name}) ->
    lists:flatten(io_lib:format("fun body contains unknown record type " "~tw",[Name]));
format_error({19 + 100,RName,FName}) ->
    lists:flatten(io_lib:format("fun body contains reference to unknown" " field ~tw in record type ~tw",[FName, RName]));
format_error({21 + 100,RName,FName}) ->
    lists:flatten(io_lib:format("fun body contains already defined fiel" "d ~tw in record type ~tw",[FName, RName]));
format_error(Else) ->
    lists:flatten(io_lib:format("Unknown error code ~tw",[Else])).

-spec(transform_from_shell(Dialect,Clauses,BoundEnvironment) -> term() when Dialect::ets|dbg,Clauses::[erl_parse:abstract_clause()],BoundEnvironment::erl_eval:binding_struct()).

transform_from_shell(Dialect,Clauses,BoundEnvironment) ->
    SaveFilename = setup_filename(),
    case  catch ms_clause_list(1,Clauses,Dialect,gb_sets:new()) of
        {'EXIT',Reason}->
            cleanup_filename(SaveFilename),
            exit(Reason);
        {error,Line,R}->
            {error,[{cleanup_filename(SaveFilename),[{Line,ms_transform,R}]}],[]};
        Else->
            case  catch fixup_environment(Else,BoundEnvironment) of
                {error,Line1,R1}->
                    {error,[{cleanup_filename(SaveFilename),[{Line1,ms_transform,R1}]}],[]};
                Else1->
                    Ret = normalise(Else1),
                    cleanup_filename(SaveFilename),
                    Ret
            end
    end.

-spec(parse_transform(Forms,Options) -> Forms2|Errors|Warnings when Forms::[erl_parse:abstract_form()|erl_parse:form_info()],Forms2::[erl_parse:abstract_form()|erl_parse:form_info()],Options::term(),Errors::{error,ErrInfo::[tuple()],WarnInfo::[]},Warnings::{warning,Forms2,WarnInfo::[tuple()]}).

parse_transform(Forms,_Options) ->
    SaveFilename = setup_filename(),
    case  catch forms(Forms) of
        {'EXIT',Reason}->
            cleanup_filename(SaveFilename),
            exit(Reason);
        {error,Line,R}->
            {error,[{cleanup_filename(SaveFilename),[{Line,ms_transform,R}]}],[]};
        Else->
            case get_warnings() of
                []->
                    cleanup_filename(SaveFilename),
                    Else;
                WL->
                    FName = cleanup_filename(SaveFilename),
                    WList = [{FName,[{L,ms_transform,R}]} || {L,R} <- WL],
                    {warning,Else,WList}
            end
    end.

get_warnings() ->
    case get(warnings) of
        undefined->
            [];
        Else->
            Else
    end.

add_warning(Line,R) ->
    put(warnings,[{Line,R}| get_warnings()]).

setup_filename() ->
    {erase(filename),erase(records),erase(warnings)}.

put_filename(Name) ->
    put(filename,Name).

put_records(R) ->
    put(records,R),
    ok.

get_records() ->
    case get(records) of
        undefined->
            [];
        Else->
            Else
    end.

cleanup_filename({Old,OldRec,OldWarnings}) ->
    Ret = case erase(filename) of
        undefined->
            "TOP_LEVEL";
        X->
            X
    end,
    case OldRec of
        undefined->
            erase(records);
        Rec->
            put(records,Rec)
    end,
    case OldWarnings of
        undefined->
            erase(warnings);
        Warn->
            put(warnings,Warn)
    end,
    case Old of
        undefined->
            Ret;
        Y->
            put(filename,Y),
            Ret
    end.

add_record_definition({Name,FieldList}) ->
    {KeyList,_} = lists:foldl(fun (F,{L,C})->
        {[record_field(F,C)| L],C + 1} end,{[],2},FieldList),
    put_records([{Name,KeyList}| get_records()]).

record_field({record_field,_,{atom,Line0,FieldName}},C) ->
    {FieldName,C,{atom,Line0,undefined}};
record_field({record_field,_,{atom,_,FieldName},Def},C) ->
    {FieldName,C,Def};
record_field({typed_record_field,Field,_Type},C) ->
    record_field(Field,C).

forms([F0| Fs0]) ->
    F1 = form(F0),
    Fs1 = forms(Fs0),
    [F1| Fs1];
forms([]) ->
    [].

form({attribute,_,file,{Filename,_}} = Form) ->
    put_filename(Filename),
    Form;
form({attribute,_,record,Definition} = Form) ->
    add_record_definition(Definition),
    Form;
form({function,Line,Name0,Arity0,Clauses0}) ->
    {Name,Arity,Clauses} = function(Name0,Arity0,Clauses0),
    {function,Line,Name,Arity,Clauses};
form(AnyOther) ->
    AnyOther.

function(Name,Arity,Clauses0) ->
    Clauses1 = clauses(Clauses0),
    {Name,Arity,Clauses1}.

clauses([C0| Cs]) ->
    C1 = clause(C0,gb_sets:new()),
    C2 = clauses(Cs),
    [C1| C2];
clauses([]) ->
    [].

clause({clause,Line,H0,G0,B0},Bound) ->
    {H1,Bound1} = copy(H0,Bound),
    {B1,_Bound2} = copy(B0,Bound1),
    {clause,Line,H1,G0,B1}.

copy({call,Line,{remote,_Line2,{atom,_Line3,ets},{atom,_Line4,fun2ms}},As0},Bound) ->
    {transform_call(ets,Line,As0,Bound),Bound};
copy({call,Line,{remote,_Line2,{atom,_Line3,dbg},{atom,_Line4,fun2ms}},As0},Bound) ->
    {transform_call(dbg,Line,As0,Bound),Bound};
copy({match,Line,A,B},Bound) ->
    {B1,Bound1} = copy(B,Bound),
    {A1,Bound2} = copy(A,Bound),
    {{match,Line,A1,B1},gb_sets:union(Bound1,Bound2)};
copy({var,_Line,_} = VarDef,Bound) ->
    {VarDef,Bound};
copy({var,_Line,Name} = VarDef,Bound) ->
    Bound1 = gb_sets:add(Name,Bound),
    {VarDef,Bound1};
copy({'fun',Line,{clauses,Clauses}},Bound) ->
    {NewClauses,_IgnoredBindings} = copy_list(Clauses,Bound),
    {{'fun',Line,{clauses,NewClauses}},Bound};
copy({named_fun,Line,Name,Clauses},Bound) ->
    Bound1 = case Name of
        _->
            Bound;
        Name->
            gb_sets:add(Name,Bound)
    end,
    {NewClauses,_IgnoredBindings} = copy_list(Clauses,Bound1),
    {{named_fun,Line,Name,NewClauses},Bound};
copy({'case',Line,Of,ClausesList},Bound) ->
    {NewOf,NewBind0} = copy(Of,Bound),
    {NewClausesList,NewBindings} = copy_case_clauses(ClausesList,NewBind0,[]),
    {{'case',Line,NewOf,NewClausesList},NewBindings};
copy(T,Bound)
    when is_tuple(T)->
    {L,Bound1} = copy_list(tuple_to_list(T),Bound),
    {list_to_tuple(L),Bound1};
copy(L,Bound)
    when is_list(L)->
    copy_list(L,Bound);
copy(AnyOther,Bound) ->
    {AnyOther,Bound}.

copy_case_clauses([],Bound,AddSets) ->
    ReallyAdded = gb_sets:intersection(AddSets),
    {[],gb_sets:union(Bound,ReallyAdded)};
copy_case_clauses([{clause,Line,Match,Guard,Clauses}| T],Bound,AddSets) ->
    {NewMatch,MatchBinds} = copy(Match,Bound),
    {NewGuard,GuardBinds} = copy(Guard,MatchBinds),
    {NewClauses,AllBinds} = copy(Clauses,GuardBinds),
    AddedBinds = gb_sets:subtract(AllBinds,Bound),
    {NewTail,ExportedBindings} = copy_case_clauses(T,Bound,[AddedBinds| AddSets]),
    {[{clause,Line,NewMatch,NewGuard,NewClauses}| NewTail],ExportedBindings}.

copy_list([H| T],Bound) ->
    {C1,Bound1} = copy(H,Bound),
    {C2,Bound2} = copy_list(T,Bound1),
    {[C1| C2],Bound2};
copy_list([],Bound) ->
    {[],Bound}.

transform_call(Type,_Line,[{'fun',Line2,{clauses,ClauseList}}],Bound) ->
    ms_clause_list(Line2,ClauseList,Type,Bound);
transform_call(_Type,Line,_NoAbstractFun,_) ->
    throw({error,Line,1}).

ms_clause_expand({clause,Line,Parameters,Guard = [_, _| _],Body}) ->
    [{clause,Line,Parameters,[X],Body} || X <- Guard];
ms_clause_expand(_Other) ->
    false.

ms_clause_list(Line,[H| T],Type,Bound) ->
    case ms_clause_expand(H) of
        NewHead
            when is_list(NewHead)->
            ms_clause_list(Line,NewHead ++ T,Type,Bound);
        false->
            {cons,Line,ms_clause(H,Type,Bound),ms_clause_list(Line,T,Type,Bound)}
    end;
ms_clause_list(Line,[],_,_) ->
    {nil,Line}.

ms_clause({clause,Line,Parameters,Guards,Body},Type,Bound) ->
    check_type(Line,Parameters,Type),
    {MSHead,Bindings} = transform_head(Parameters,Bound),
    MSGuards = transform_guards(Line,Guards,Bindings),
    MSBody = transform_body(Line,Body,Bindings),
    {tuple,Line,[MSHead, MSGuards, MSBody]}.

check_type(_,[{var,_,_}],_) ->
    ok;
check_type(_,[{tuple,_,_}],ets) ->
    ok;
check_type(_,[{record,_,_,_}],ets) ->
    ok;
check_type(_,[{cons,_,_,_}],dbg) ->
    ok;
check_type(_,[{nil,_}],dbg) ->
    ok;
check_type(Line0,[{match,_,{var,_,_},X}],Any) ->
    check_type(Line0,[X],Any);
check_type(Line0,[{match,_,X,{var,_,_}}],Any) ->
    check_type(Line0,[X],Any);
check_type(Line,_Type,ets) ->
    throw({error,Line,2});
check_type(Line,_,dbg) ->
    throw({error,Line,3}).

-record(tgd, {b,p,eb}).

transform_guards(Line,[],_Bindings) ->
    {nil,Line};
transform_guards(Line,[G],Bindings) ->
    B = #tgd{b = Bindings,p = guard,eb = 0},
    tg0(Line,G,B);
transform_guards(Line,_,_) ->
    throw({error,Line,5}).

transform_body(Line,Body,Bindings) ->
    B = #tgd{b = Bindings,p = body,eb = 100},
    tg0(Line,Body,B).

guard_top_trans({call,Line0,{atom,Line1,OldTest},Params}) ->
    case old_bool_test(OldTest,length(Params)) of
        undefined->
            {call,Line0,{atom,Line1,OldTest},Params};
        Trans->
            {call,Line0,{atom,Line1,Trans},Params}
    end;
guard_top_trans(Else) ->
    Else.

tg0(Line,[],_) ->
    {nil,Line};
tg0(Line,[H0| T],B)
    when B#tgd.p =:= guard->
    H = guard_top_trans(H0),
    {cons,Line,tg(H,B),tg0(Line,T,B)};
tg0(Line,[H| T],B) ->
    {cons,Line,tg(H,B),tg0(Line,T,B)}.

tg({match,Line,_,_},B) ->
    throw({error,Line,16 + B#tgd.eb});
tg({op,Line,Operator,O1,O2} = Expr,B) ->
    case erl_eval:partial_eval(Expr) of
        Expr->
            {tuple,Line,[{atom,Line,Operator}, tg(O1,B), tg(O2,B)]};
        Value->
            Value
    end;
tg({op,Line,Operator,O1} = Expr,B) ->
    case erl_eval:partial_eval(Expr) of
        Expr->
            {tuple,Line,[{atom,Line,Operator}, tg(O1,B)]};
        Value->
            Value
    end;
tg({call,_Line,{atom,Line2,bindings},[]},_B) ->
    {atom,Line2,'$*'};
tg({call,_Line,{atom,Line2,object},[]},_B) ->
    {atom,Line2,'$_'};
tg({call,Line,{atom,_,is_record} = Call,[Object, {atom,Line3,RName} = R]},B) ->
    MSObject = tg(Object,B),
    RDefs = get_records(),
    case lists:keysearch(RName,1,RDefs) of
        {value,{RName,FieldList}}->
            RSize = length(FieldList) + 1,
            {tuple,Line,[Call, MSObject, R, {integer,Line3,RSize}]};
        _->
            throw({error,Line3,{20 + B#tgd.eb,RName}})
    end;
tg({call,Line,{atom,Line2,FunName},ParaList},B) ->
    case is_ms_function(FunName,length(ParaList),B#tgd.p) of
        true->
            {tuple,Line,[{atom,Line2,FunName}| lists:map(fun (X)->
                tg(X,B) end,ParaList)]};
        _->
            throw({error,Line,{17 + B#tgd.eb,FunName,length(ParaList)}})
    end;
tg({call,Line,{remote,_,{atom,_,erlang},{atom,Line2,FunName}},ParaList},B) ->
    L = length(ParaList),
    case is_imported_from_erlang(FunName,L,B#tgd.p) of
        true->
            case is_operator(FunName,L,B#tgd.p) of
                false->
                    tg({call,Line,{atom,Line2,FunName},ParaList},B);
                true->
                    tg(list_to_tuple([op, Line2, FunName| ParaList]),B)
            end;
        _->
            throw({error,Line,{22 + B#tgd.eb,erlang,FunName,length(ParaList)}})
    end;
tg({call,Line,{remote,_,{atom,_,ModuleName},{atom,_,FunName}},ParaList},B) ->
    throw({error,Line,{22 + B#tgd.eb,ModuleName,FunName,length(ParaList)}});
tg({cons,Line,H,T},B) ->
    {cons,Line,tg(H,B),tg(T,B)};
tg({nil,Line},_B) ->
    {nil,Line};
tg({tuple,Line,L},B) ->
    {tuple,Line,[{tuple,Line,lists:map(fun (X)->
        tg(X,B) end,L)}]};
tg({integer,Line,I},_) ->
    {integer,Line,I};
tg({char,Line,C},_) ->
    {char,Line,C};
tg({float,Line,F},_) ->
    {float,Line,F};
tg({atom,Line,A},_) ->
    case atom_to_list(A) of
        [$$| _]->
            {tuple,Line,[{atom,Line,const}, {atom,Line,A}]};
        _->
            {atom,Line,A}
    end;
tg({string,Line,S},_) ->
    {string,Line,S};
tg({var,Line,VarName},B) ->
    case lkup_bind(VarName,B#tgd.b) of
        undefined->
            {tuple,Line,[{atom,Line,const}, {var,Line,VarName}]};
        AtomName->
            {atom,Line,AtomName}
    end;
tg({record_field,Line,Object,RName,{atom,_Line1,KeyName}},B) ->
    RDefs = get_records(),
    case lists:keysearch(RName,1,RDefs) of
        {value,{RName,FieldList}}->
            case lists:keysearch(KeyName,1,FieldList) of
                {value,{KeyName,Position,_}}->
                    NewObject = tg(Object,B),
                    {tuple,Line,[{atom,Line,element}, {integer,Line,Position}, NewObject]};
                _->
                    throw({error,Line,{19 + B#tgd.eb,RName,KeyName}})
            end;
        _->
            throw({error,Line,{20 + B#tgd.eb,RName}})
    end;
tg({record,Line,RName,RFields},B) ->
    RDefs = get_records(),
    KeyList0 = lists:foldl(fun ({record_field,_,{atom,_,Key},Value},L)->
        NV = tg(Value,B),
        [{Key,NV}| L];({record_field,_,{var,_,_},Value},L)->
        NV = tg(Value,B),
        [{{default},NV}| L];(_,_)->
        throw({error,Line,{20 + B#tgd.eb,RName}}) end,[],RFields),
    DefValue = case lists:keysearch({default},1,KeyList0) of
        {value,{{default},OverriddenDefValue}}->
            {true,OverriddenDefValue};
        _->
            false
    end,
    KeyList = lists:keydelete({default},1,KeyList0),
    case lists:keysearch({default},1,KeyList) of
        {value,{{default},_}}->
            throw({error,Line,{21 + B#tgd.eb,RName,_}});
        _->
            ok
    end,
    case lists:keysearch(RName,1,RDefs) of
        {value,{RName,FieldList0}}->
            FieldList1 = lists:foldl(fun ({FN,_,Def},Acc)->
                El = case lists:keysearch(FN,1,KeyList) of
                    {value,{FN,X0}}->
                        X0;
                    _->
                        case DefValue of
                            {true,Overridden}->
                                Overridden;
                            false->
                                Def
                        end
                end,
                [El| Acc] end,[],FieldList0),
            check_multi_field(RName,Line,KeyList,21 + B#tgd.eb),
            check_undef_field(RName,Line,KeyList,FieldList0,19 + B#tgd.eb),
            {tuple,Line,[{tuple,Line,[{atom,Line,RName}| FieldList1]}]};
        _->
            throw({error,Line,{20 + B#tgd.eb,RName}})
    end;
tg({record_index,Line,RName,{atom,Line2,KeyName}},B) ->
    RDefs = get_records(),
    case lists:keysearch(RName,1,RDefs) of
        {value,{RName,FieldList}}->
            case lists:keysearch(KeyName,1,FieldList) of
                {value,{KeyName,Position,_}}->
                    {integer,Line2,Position};
                _->
                    throw({error,Line2,{19 + B#tgd.eb,RName,KeyName}})
            end;
        _->
            throw({error,Line,{20 + B#tgd.eb,RName}})
    end;
tg({record,Line,{var,Line2,_VName} = AVName,RName,RFields},B) ->
    RDefs = get_records(),
    MSVName = tg(AVName,B),
    KeyList = lists:foldl(fun ({record_field,_,{atom,_,Key},Value},L)->
        NV = tg(Value,B),
        [{Key,NV}| L];(_,_)->
        throw({error,Line,7}) end,[],RFields),
    case lists:keysearch(RName,1,RDefs) of
        {value,{RName,FieldList0}}->
            FieldList1 = lists:foldl(fun ({FN,Pos,_},Acc)->
                El = case lists:keysearch(FN,1,KeyList) of
                    {value,{FN,X0}}->
                        X0;
                    _->
                        {tuple,Line2,[{atom,Line2,element}, {integer,Line2,Pos}, MSVName]}
                end,
                [El| Acc] end,[],FieldList0),
            check_multi_field(RName,Line,KeyList,21 + B#tgd.eb),
            check_undef_field(RName,Line,KeyList,FieldList0,19 + B#tgd.eb),
            {tuple,Line,[{tuple,Line,[{atom,Line,RName}| FieldList1]}]};
        _->
            throw({error,Line,{20 + B#tgd.eb,RName}})
    end;
tg({bin_element,_Line0,{var,Line,A},_,_} = Whole,B) ->
    case lkup_bind(A,B#tgd.b) of
        undefined->
            Whole;
        _AtomName->
            throw({error,Line,{23 + B#tgd.eb,A}})
    end;
tg(default,_B) ->
    default;
tg({bin_element,Line,X,Y,Z},B) ->
    {bin_element,Line,tg(X,B),tg(Y,B),Z};
tg({bin,Line,List},B) ->
    {bin,Line,[(tg(X,B)) || X <- List]};
tg(T,B)
    when is_tuple(T),
    tuple_size(T) >= 2->
    Element = element(1,T),
    Line = element(2,T),
    throw({error,Line,{18 + B#tgd.eb,translate_language_element(Element)}});
tg(Other,B) ->
    Element = io_lib:format("unknown element ~tw",[Other]),
    throw({error,unknown,{18 + B#tgd.eb,Element}}).

transform_head([V],OuterBound) ->
    Bind = cre_bind(),
    {NewV,NewBind} = toplevel_head_match(V,Bind,OuterBound),
    th(NewV,NewBind,OuterBound).

toplevel_head_match({match,_,{var,Line,VName},Expr},B,OB) ->
    warn_var_clash(Line,VName,OB),
    {Expr,new_bind({VName,'$_'},B)};
toplevel_head_match({match,_,Expr,{var,Line,VName}},B,OB) ->
    warn_var_clash(Line,VName,OB),
    {Expr,new_bind({VName,'$_'},B)};
toplevel_head_match(Other,B,_OB) ->
    {Other,B}.

th({record,Line,RName,RFields},B,OB) ->
    RDefs = get_records(),
    {KeyList0,NewB} = lists:foldl(fun ({record_field,_,{atom,_,Key},Value},{L,B0})->
        {NV,B1} = th(Value,B0,OB),
        {[{Key,NV}| L],B1};({record_field,_,{var,_,_},Value},{L,B0})->
        {NV,B1} = th(Value,B0,OB),
        {[{{default},NV}| L],B1};(_,_)->
        throw({error,Line,{7,RName}}) end,{[],B},RFields),
    DefValue = case lists:keysearch({default},1,KeyList0) of
        {value,{{default},OverriddenDefValue}}->
            OverriddenDefValue;
        _->
            {atom,Line,_}
    end,
    KeyList = lists:keydelete({default},1,KeyList0),
    case lists:keysearch({default},1,KeyList) of
        {value,{{default},_}}->
            throw({error,Line,{9,RName,_}});
        _->
            ok
    end,
    case lists:keysearch(RName,1,RDefs) of
        {value,{RName,FieldList0}}->
            FieldList1 = lists:foldl(fun ({FN,_,_},Acc)->
                El = case lists:keysearch(FN,1,KeyList) of
                    {value,{FN,X0}}->
                        X0;
                    _->
                        DefValue
                end,
                [El| Acc] end,[],FieldList0),
            check_multi_field(RName,Line,KeyList,9),
            check_undef_field(RName,Line,KeyList,FieldList0,8),
            {{tuple,Line,[{atom,Line,RName}| FieldList1]},NewB};
        _->
            throw({error,Line,{7,RName}})
    end;
th({match,Line,_,_},_,_) ->
    throw({error,Line,4});
th({atom,Line,A},B,_OB) ->
    case atom_to_list(A) of
        [$$| NL]->
            case  catch list_to_integer(NL) of
                N
                    when is_integer(N)->
                    throw({error,Line,{10,A}});
                _->
                    {{atom,Line,A},B}
            end;
        _->
            {{atom,Line,A},B}
    end;
th({bin_element,_Line0,{var,Line,A},_,_},_,_) ->
    throw({error,Line,{11,A}});
th({var,Line,Name},B,OB) ->
    warn_var_clash(Line,Name,OB),
    case lkup_bind(Name,B) of
        undefined->
            NewB = new_bind(Name,B),
            {{atom,Line,lkup_bind(Name,NewB)},NewB};
        Trans->
            {{atom,Line,Trans},B}
    end;
th([H| T],B,OB) ->
    {NH,NB} = th(H,B,OB),
    {NT,NNB} = th(T,NB,OB),
    {[NH| NT],NNB};
th(T,B,OB)
    when is_tuple(T)->
    {L,NB} = th(tuple_to_list(T),B,OB),
    {list_to_tuple(L),NB};
th(Nonstruct,B,_OB) ->
    {Nonstruct,B}.

warn_var_clash(Anno,Name,OuterBound) ->
    case gb_sets:is_member(Name,OuterBound) of
        true->
            Line = erl_anno:line(Anno),
            add_warning(Line,{50,Name});
        _->
            ok
    end.

check_multi_field(_,_,[],_) ->
    ok;
check_multi_field(RName,Line,[{Key,_}| T],ErrCode) ->
    case lists:keymember(Key,1,T) of
        true->
            throw({error,Line,{ErrCode,RName,Key}});
        false->
            check_multi_field(RName,Line,T,ErrCode)
    end.

check_undef_field(_,_,[],_,_) ->
    ok;
check_undef_field(RName,Line,[{Key,_}| T],FieldList,ErrCode) ->
    case lists:keymember(Key,1,FieldList) of
        true->
            check_undef_field(RName,Line,T,FieldList,ErrCode);
        false->
            throw({error,Line,{ErrCode,RName,Key}})
    end.

cre_bind() ->
    {1,[{_,_}]}.

lkup_bind(Name,{_,List}) ->
    case lists:keysearch(Name,1,List) of
        {value,{Name,Trans}}->
            Trans;
        _->
            undefined
    end.

new_bind({Name,Trans},{Next,L}) ->
    {Next,[{Name,Trans}| L]};
new_bind(Name,{Next,L}) ->
    Trans = list_to_atom([$$| integer_to_list(Next)]),
    {Next + 1,[{Name,Trans}| L]}.

translate_language_element(Atom) ->
    Transtab = [{lc,"list comprehension"}, {bc,"binary comprehension"}, {block,"begin/end block"}, {'if',"if"}, {'case',"case"}, {'receive',"receive"}, {'try',"try"}, {'catch',"catch"}, {match,"match (=)"}, {remote,"external function call"}],
    case lists:keysearch(Atom,1,Transtab) of
        {value,{Atom,String}}->
            String;
        _->
            atom_to_list(Atom)
    end.

old_bool_test(atom,1) ->
    is_atom;
old_bool_test(float,1) ->
    is_float;
old_bool_test(integer,1) ->
    is_integer;
old_bool_test(list,1) ->
    is_list;
old_bool_test(number,1) ->
    is_number;
old_bool_test(pid,1) ->
    is_pid;
old_bool_test(port,1) ->
    is_port;
old_bool_test(reference,1) ->
    is_reference;
old_bool_test(tuple,1) ->
    is_tuple;
old_bool_test(binary,1) ->
    is_binary;
old_bool_test(function,1) ->
    is_function;
old_bool_test(record,2) ->
    is_record;
old_bool_test(_,_) ->
    undefined.

bool_test(is_atom,1) ->
    true;
bool_test(is_float,1) ->
    true;
bool_test(is_integer,1) ->
    true;
bool_test(is_list,1) ->
    true;
bool_test(is_number,1) ->
    true;
bool_test(is_pid,1) ->
    true;
bool_test(is_port,1) ->
    true;
bool_test(is_reference,1) ->
    true;
bool_test(is_tuple,1) ->
    true;
bool_test(is_map,1) ->
    true;
bool_test(is_map_key,2) ->
    true;
bool_test(is_binary,1) ->
    true;
bool_test(is_function,1) ->
    true;
bool_test(is_record,2) ->
    true;
bool_test(is_seq_trace,0) ->
    true;
bool_test(_,_) ->
    false.

real_guard_function(abs,1) ->
    true;
real_guard_function(element,2) ->
    true;
real_guard_function(hd,1) ->
    true;
real_guard_function(length,1) ->
    true;
real_guard_function(node,0) ->
    true;
real_guard_function(node,1) ->
    true;
real_guard_function(round,1) ->
    true;
real_guard_function(size,1) ->
    true;
real_guard_function(bit_size,1) ->
    true;
real_guard_function(map_size,1) ->
    true;
real_guard_function(map_get,2) ->
    true;
real_guard_function(tl,1) ->
    true;
real_guard_function(trunc,1) ->
    true;
real_guard_function(self,0) ->
    true;
real_guard_function(float,1) ->
    true;
real_guard_function(_,_) ->
    false.

pseudo_guard_function(get_tcw,0) ->
    true;
pseudo_guard_function(_,_) ->
    false.

guard_function(X,A) ->
    real_guard_function(X,A) or pseudo_guard_function(X,A).

action_function(set_seq_token,2) ->
    true;
action_function(get_seq_token,0) ->
    true;
action_function(message,1) ->
    true;
action_function(return_trace,0) ->
    true;
action_function(exception_trace,0) ->
    true;
action_function(process_dump,0) ->
    true;
action_function(enable_trace,1) ->
    true;
action_function(enable_trace,2) ->
    true;
action_function(disable_trace,1) ->
    true;
action_function(disable_trace,2) ->
    true;
action_function(display,1) ->
    true;
action_function(caller,0) ->
    true;
action_function(set_tcw,1) ->
    true;
action_function(silent,1) ->
    true;
action_function(trace,2) ->
    true;
action_function(trace,3) ->
    true;
action_function(_,_) ->
    false.

bool_operator('and',2) ->
    true;
bool_operator('or',2) ->
    true;
bool_operator('xor',2) ->
    true;
bool_operator('not',1) ->
    true;
bool_operator('andalso',2) ->
    true;
bool_operator('orelse',2) ->
    true;
bool_operator(_,_) ->
    false.

arith_operator('+',1) ->
    true;
arith_operator('+',2) ->
    true;
arith_operator('-',1) ->
    true;
arith_operator('-',2) ->
    true;
arith_operator('*',2) ->
    true;
arith_operator('/',2) ->
    true;
arith_operator('div',2) ->
    true;
arith_operator('rem',2) ->
    true;
arith_operator('band',2) ->
    true;
arith_operator('bor',2) ->
    true;
arith_operator('bxor',2) ->
    true;
arith_operator('bnot',1) ->
    true;
arith_operator('bsl',2) ->
    true;
arith_operator('bsr',2) ->
    true;
arith_operator(_,_) ->
    false.

cmp_operator('>',2) ->
    true;
cmp_operator('>=',2) ->
    true;
cmp_operator('<',2) ->
    true;
cmp_operator('=<',2) ->
    true;
cmp_operator('==',2) ->
    true;
cmp_operator('=:=',2) ->
    true;
cmp_operator('/=',2) ->
    true;
cmp_operator('=/=',2) ->
    true;
cmp_operator(_,_) ->
    false.

is_operator(X,A,_) ->
    bool_operator(X,A) or arith_operator(X,A) or cmp_operator(X,A).

is_imported_from_erlang(X,A,_) ->
    real_guard_function(X,A) or bool_test(X,A) or bool_operator(X,A) or arith_operator(X,A) or cmp_operator(X,A).

is_ms_function(X,A,body) ->
    action_function(X,A) or guard_function(X,A) or bool_test(X,A);
is_ms_function(X,A,guard) ->
    guard_function(X,A) or bool_test(X,A).

fixup_environment(L,B)
    when is_list(L)->
    lists:map(fun (X)->
        fixup_environment(X,B) end,L);
fixup_environment({var,Line,Name},B) ->
    case lists:keysearch(Name,1,B) of
        {value,{Name,Value}}->
            freeze(Line,Value);
        _->
            throw({error,Line,{6,atom_to_list(Name)}})
    end;
fixup_environment(T,B)
    when is_tuple(T)->
    list_to_tuple(lists:map(fun (X)->
        fixup_environment(X,B) end,tuple_to_list(T)));
fixup_environment(Other,_B) ->
    Other.

freeze(Line,Term) ->
    {frozen,Line,Term}.

normalise({frozen,_,Term}) ->
    Term;
normalise({char,_,C}) ->
    C;
normalise({integer,_,I}) ->
    I;
normalise({float,_,F}) ->
    F;
normalise({atom,_,A}) ->
    A;
normalise({string,_,S}) ->
    S;
normalise({nil,_}) ->
    [];
normalise({bin,_,Fs}) ->
    {value,B,_} = eval_bits:expr_grp(Fs,[],fun (E,_)->
        {value,normalise(E),[]} end,[],true),
    B;
normalise({cons,_,Head,Tail}) ->
    [normalise(Head)| normalise(Tail)];
normalise({op,_,'++',A,B}) ->
    normalise(A) ++ normalise(B);
normalise({tuple,_,Args}) ->
    list_to_tuple(normalise_list(Args));
normalise({map,_,Pairs0}) ->
    Pairs1 = lists:map(fun ({map_field_exact,_,K,V})->
        {normalise(K),normalise(V)} end,Pairs0),
    maps:from_list(Pairs1);
normalise({op,_,'+',{char,_,I}}) ->
    I;
normalise({op,_,'+',{integer,_,I}}) ->
    I;
normalise({op,_,'+',{float,_,F}}) ->
    F;
normalise({op,_,'-',{char,_,I}}) ->
    -I;
normalise({op,_,'-',{integer,_,I}}) ->
    -I;
normalise({op,_,'-',{float,_,F}}) ->
    -F.

normalise_list([H| T]) ->
    [normalise(H)| normalise_list(T)];
normalise_list([]) ->
    [].
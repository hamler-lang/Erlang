-file("xref_reader.erl", 1).

-module(xref_reader).

-export([module/5]).

-import(lists, [keysearch/3, member/2, reverse/1]).

-record(xrefr, {module = [],function = [],def_at = [],l_call_at = [],x_call_at = [],el = [],ex = [],x = [],df,builtins_too = false,is_abstr,funvars = [],matches = [],unresolved = [],lattrs = [],xattrs = [],battrs = [],on_load}).

-file("xref.hrl", 1).

-record(xref, {version = 1,mode = functions,variables = not_set_up,modules = dict:new(),applications = dict:new(),releases = dict:new(),library_path = [],libraries = dict:new(),builtins_default = false,recurse_default = false,verbose_default = false,warnings_default = true}).

-record(xref_mod, {name = ,app_name = [],dir = "",mtime,builtins,info,no_unresolved = 0,data}).

-record(xref_app, {name = ,rel_name = [],vsn = [],dir = ""}).

-record(xref_rel, {name = ,dir = ""}).

-record(xref_lib, {name = ,dir = ""}).

-record(xref_var, {name = ,value,vtype,otype,type}).

-file("xref_reader.erl", 50).

module(Module,Forms,CollectBuiltins,X,DF) ->
    Attrs = [{Attr,V} || {attribute,_Line,Attr,V} <- Forms],
    IsAbstract = xref_utils:is_abstract_module(Attrs),
    S = #xrefr{module = Module,builtins_too = CollectBuiltins,is_abstr = IsAbstract,x = X,df = DF},
    forms(Forms,S).

forms([F| Fs],S) ->
    S1 = form(F,S),
    forms(Fs,S1);
forms([],S) ->
    #xrefr{module = M,def_at = DefAt,l_call_at = LCallAt,x_call_at = XCallAt,el = LC,ex = XC,x = X,df = Depr,on_load = OnLoad,lattrs = AL,xattrs = AX,battrs = B,unresolved = U} = S,
    OL = case OnLoad of
        undefined->
            [];
        F->
            [{M,F,0}]
    end,
    #xrefr{def_at = DefAt,l_call_at = LCallAt,x_call_at = XCallAt,el = LC,ex = XC,x = X,df = Depr,on_load = OnLoad,lattrs = AL,xattrs = AX,battrs = B,unresolved = U} = S,
    Attrs = {lists:reverse(AL),lists:reverse(AX),lists:reverse(B)},
    {ok,M,{DefAt,LCallAt,XCallAt,LC,XC,X,Attrs,Depr,OL},U}.

form({attribute,Line,xref,Calls},S) ->
    #xrefr{module = M,function = Fun,lattrs = L,xattrs = X,battrs = B} = S,
    attr(Calls,erl_anno:line(Line),M,Fun,L,X,B,S);
form({attribute,_,on_load,{F,0}},S) ->
    S#xrefr{on_load = F};
form({attribute,_Line,_Attr,_Val},S) ->
    S;
form({function,_,module_info,0,_Clauses},S) ->
    S;
form({function,_,module_info,1,_Clauses},S) ->
    S;
form({function,0 = _Line,behaviour_info,1,_Clauses},S) ->
    S;
form({function,Anno,Name,Arity,Clauses},S) ->
    MFA0 = {S#xrefr.module,Name,Arity},
    MFA = adjust_arity(S,MFA0),
    S1 = S#xrefr{function = MFA},
    Line = erl_anno:line(Anno),
    S2 = S1#xrefr{def_at = [{MFA,Line}| S#xrefr.def_at]},
    S3 = clauses(Clauses,S2),
    S3#xrefr{function = []};
form(_,S) ->
    S.

clauses(Cls,S) ->
    #xrefr{funvars = FunVars,matches = Matches} = S,
    clauses(Cls,FunVars,Matches,S).

clauses([{clause,_Line,_H,G,B}| Cs],FunVars,Matches,S) ->
    S1 = case S#xrefr.builtins_too of
        true->
            expr(G,S);
        false->
            S
    end,
    S2 = expr(B,S1),
    S3 = S2#xrefr{funvars = FunVars,matches = Matches},
    clauses(Cs,S3);
clauses([],_FunVars,_Matches,S) ->
    S.

attr(NotList,Ln,M,Fun,AL,AX,B,S)
    when  not is_list(NotList)->
    attr([NotList],Ln,M,Fun,AL,AX,B,S);
attr([E = {From,To}| As],Ln,M,Fun,AL,AX,B,S) ->
    case mfa(From,M) of
        {_,_,MFA}
            when MFA =:= Fun;
            [] =:= Fun->
            attr(From,To,Ln,M,Fun,AL,AX,B,S,As,E);
        {_,_,_}->
            attr(As,Ln,M,Fun,AL,AX,[E| B],S);
        _->
            attr(Fun,E,Ln,M,Fun,AL,AX,B,S,As,E)
    end;
attr([To| As],Ln,M,Fun,AL,AX,B,S) ->
    attr(Fun,To,Ln,M,Fun,AL,AX,B,S,As,To);
attr([],_Ln,_M,_Fun,AL,AX,B,S) ->
    S#xrefr{lattrs = AL,xattrs = AX,battrs = B}.

attr(From,To,Ln,M,Fun,AL,AX,B,S,As,E) ->
    case {mfa(From,M),mfa(To,M)} of
        {{true,_,F},{_,external,T}}->
            attr(As,Ln,M,Fun,AL,[{{F,T},Ln}| AX],B,S);
        {{true,_,F},{_,local,T}}->
            attr(As,Ln,M,Fun,[{{F,T},Ln}| AL],AX,B,S);
        _->
            attr(As,Ln,M,Fun,AL,AX,[E| B],S)
    end.

mfa({F,A},M)
    when is_atom(F),
    is_integer(A)->
    {true,local,{M,F,A}};
mfa(MFA = {M,F,A},M1)
    when is_atom(M),
    is_atom(F),
    is_integer(A)->
    {M =:= M1,external,MFA};
mfa(_,_M) ->
    false.

expr({'if',_Line,Cs},S) ->
    clauses(Cs,S);
expr({'case',_Line,E,Cs},S) ->
    S1 = expr(E,S),
    clauses(Cs,S1);
expr({'receive',_Line,Cs},S) ->
    clauses(Cs,S);
expr({'receive',_Line,Cs,To,ToEs},S) ->
    S1 = expr(To,S),
    S2 = expr(ToEs,S1),
    clauses(Cs,S2);
expr({'try',_Line,Es,Scs,Ccs,As},S) ->
    S1 = expr(Es,S),
    S2 = clauses(Scs,S1),
    S3 = clauses(Ccs,S2),
    expr(As,S3);
expr({'fun',Line,{function,M,F,A}},S)
    when is_atom(M),
    is_atom(F),
    is_integer(A)->
    Fun = {'fun',Line,{function,{atom,Line,M},{atom,Line,F},{integer,Line,A}}},
    expr(Fun,S);
expr({'fun',Line,{function,{atom,_,Mod},{atom,_,Name},{integer,_,Arity}}},S) ->
    As = lists:duplicate(Arity,{atom,Line,foo}),
    external_call(Mod,Name,As,Line,false,S);
expr({'fun',Line,{function,Mod,Name,{integer,_,Arity}}},S) ->
    As = lists:duplicate(Arity,{atom,Line,foo}),
    external_call(erlang,apply,[Mod, Name, list2term(As)],Line,true,S);
expr({'fun',Line,{function,Mod,Name,_Arity}},S) ->
    As = {var,Line,_},
    external_call(erlang,apply,[Mod, Name, As],Line,true,S);
expr({'fun',Line,{function,Name,Arity},_Extra},S) ->
    handle_call(local,S#xrefr.module,Name,Arity,Line,S);
expr({'fun',_Line,{clauses,Cs},_Extra},S) ->
    clauses(Cs,S);
expr({'fun',Line,{function,Name,Arity}},S) ->
    handle_call(local,S#xrefr.module,Name,Arity,Line,S);
expr({'fun',_Line,{clauses,Cs}},S) ->
    clauses(Cs,S);
expr({named_fun,_Line,_,Cs},S) ->
    clauses(Cs,S);
expr({named_fun,_Line,Name,Cs},S) ->
    S1 = S#xrefr{funvars = [Name| S#xrefr.funvars]},
    clauses(Cs,S1);
expr({call,Line,{atom,_,Name},As},S) ->
    S1 = handle_call(local,S#xrefr.module,Name,length(As),Line,S),
    expr(As,S1);
expr({call,Line,{remote,_Line,{atom,_,Mod},{atom,_,Name}},As},S) ->
    external_call(Mod,Name,As,Line,false,S);
expr({call,Line,{remote,_Line,Mod,Name},As},S) ->
    external_call(erlang,apply,[Mod, Name, list2term(As)],Line,true,S);
expr({call,Line,F,As},S) ->
    external_call(erlang,apply,[F, list2term(As)],Line,true,S);
expr({match,_Line,{var,_,Var},{'fun',_,{clauses,Cs},_Extra}},S) ->
    S1 = S#xrefr{funvars = [Var| S#xrefr.funvars]},
    clauses(Cs,S1);
expr({match,_Line,{var,_,Var},{'fun',_,{clauses,Cs}}},S) ->
    S1 = S#xrefr{funvars = [Var| S#xrefr.funvars]},
    clauses(Cs,S1);
expr({match,_Line,{var,_,Var},{named_fun,_,_,_} = Fun},S) ->
    S1 = S#xrefr{funvars = [Var| S#xrefr.funvars]},
    expr(Fun,S1);
expr({match,_Line,{var,_,Var},E},S) ->
    S1 = S#xrefr{matches = [{Var,E}| S#xrefr.matches]},
    expr(E,S1);
expr({op,_Line,'orelse',Op1,Op2},S) ->
    expr([Op1, Op2],S);
expr({op,_Line,'andalso',Op1,Op2},S) ->
    expr([Op1, Op2],S);
expr({op,Line,Op,Operand1,Operand2},S) ->
    external_call(erlang,Op,[Operand1, Operand2],Line,false,S);
expr({op,Line,Op,Operand},S) ->
    external_call(erlang,Op,[Operand],Line,false,S);
expr(T,S)
    when is_tuple(T)->
    expr(tuple_to_list(T),S);
expr([E| Es],S) ->
    expr(Es,expr(E,S));
expr(_E,S) ->
    S.

external_call(Mod,Fun,ArgsList,Line,X,S) ->
    Arity = length(ArgsList),
    W = case xref_utils:is_funfun(Mod,Fun,Arity) of
        true
            when erlang =:= Mod,
            apply =:= Fun,
            2 =:= Arity->
            apply2;
        true
            when erts_debug =:= Mod,
            apply =:= Fun,
            4 =:= Arity->
            debug4;
        true
            when erlang =:= Mod,
            spawn_opt =:= Fun->
            Arity - 1;
        true->
            Arity;
        false
            when Mod =:= erlang->
            case erl_internal:type_test(Fun,Arity) of
                true->
                    type;
                false->
                    false
            end;
        false->
            false
    end,
    S1 = if W =:= type;
    X ->
        S;true ->
        handle_call(external,Mod,Fun,Arity,Line,S) end,
    case {W,ArgsList} of
        {false,_}->
            expr(ArgsList,S1);
        {type,_}->
            expr(ArgsList,S1);
        {apply2,[{tuple,_,[M, F]}, ArgsTerm]}->
            eval_args(M,F,ArgsTerm,Line,S1,ArgsList,[]);
        {1,[{tuple,_,[M, F]}| R]}->
            eval_args(M,F,list2term([]),Line,S1,ArgsList,R);
        {2,[Node, {tuple,_,[M, F]}| R]}->
            eval_args(M,F,list2term([]),Line,S1,ArgsList,[Node| R]);
        {3,[M, F, ArgsTerm| R]}->
            eval_args(M,F,ArgsTerm,Line,S1,ArgsList,R);
        {4,[Node, M, F, ArgsTerm| R]}->
            eval_args(M,F,ArgsTerm,Line,S1,ArgsList,[Node| R]);
        {debug4,[M, F, ArgsTerm, _]}->
            eval_args(M,F,ArgsTerm,Line,S1,ArgsList,[]);
        _Else->
            check_funarg(W,ArgsList,Line,S1)
    end.

eval_args(Mod,Fun,ArgsTerm,Line,S,ArgsList,Extra) ->
    {IsSimpleCall,M,F} = mod_fun(Mod,Fun),
    case term2list(ArgsTerm,[],S) of
        undefined->
            S1 = unresolved(M,F,-1,Line,S),
            expr(ArgsList,S1);
        ArgsList2
            when  not IsSimpleCall->
            S1 = unresolved(M,F,length(ArgsList2),Line,S),
            expr(ArgsList,S1);
        ArgsList2
            when IsSimpleCall->
            S1 = expr(Extra,S),
            external_call(M,F,ArgsList2,Line,false,S1)
    end.

mod_fun({atom,_,M1},{atom,_,F1}) ->
    {true,M1,F1};
mod_fun({atom,_,M1},_) ->
    {false,M1,'$F_EXPR'};
mod_fun(_,{atom,_,F1}) ->
    {false,'$M_EXPR',F1};
mod_fun(_,_) ->
    {false,'$M_EXPR','$F_EXPR'}.

check_funarg(W,ArgsList,Line,S) ->
    {FunArg,Args} = fun_args(W,ArgsList),
    S1 = case funarg(FunArg,S) of
        true->
            S;
        false
            when is_integer(W)->
            unresolved('$M_EXPR','$F_EXPR',0,Line,S);
        false->
            N = case term2list(Args,[],S) of
                undefined->
                    -1;
                As->
                    length(As)
            end,
            unresolved('$M_EXPR','$F_EXPR',N,Line,S)
    end,
    expr(ArgsList,S1).

funarg({'fun',_,_Clauses,_Extra},_S) ->
    true;
funarg({'fun',_,{clauses,_}},_S) ->
    true;
funarg({'fun',_,{function,_,_}},_S) ->
    true;
funarg({'fun',_,{function,_,_,_}},_S) ->
    true;
funarg({named_fun,_,_,_},_S) ->
    true;
funarg({var,_,Var},S) ->
    member(Var,S#xrefr.funvars);
funarg(_,_S) ->
    false.

fun_args(apply2,[FunArg, Args]) ->
    {FunArg,Args};
fun_args(1,[FunArg| Args]) ->
    {FunArg,Args};
fun_args(2,[_Node, FunArg| Args]) ->
    {FunArg,Args}.

list2term(L) ->
    A = erl_anno:new(0),
    list2term(L,A).

list2term([A| As],Anno) ->
    {cons,Anno,A,list2term(As)};
list2term([],Anno) ->
    {nil,Anno}.

term2list({cons,_Line,H,T},L,S) ->
    term2list(T,[H| L],S);
term2list({nil,_Line},L,_S) ->
    reverse(L);
term2list({var,_,Var},L,S) ->
    case keysearch(Var,1,S#xrefr.matches) of
        {value,{Var,E}}->
            term2list(E,L,S);
        false->
            undefined
    end;
term2list(_Else,_L,_S) ->
    undefined.

unresolved(M,F,A,Line,S) ->
    handle_call(external,{M,F,A},Line,S,true).

handle_call(Locality,Module,Name,Arity,Line,S) ->
    case xref_utils:is_builtin(Module,Name,Arity) of
        true
            when  not S#xrefr.builtins_too->
            S;
        _Else->
            To = {Module,Name,Arity},
            handle_call(Locality,To,Line,S,false)
    end.

handle_call(Locality,To0,Anno,S,IsUnres) ->
    From = S#xrefr.function,
    To = adjust_arity(S,To0),
    Call = {From,To},
    Line = erl_anno:line(Anno),
    CallAt = {Call,Line},
    S1 = if IsUnres ->
        S#xrefr{unresolved = [CallAt| S#xrefr.unresolved]};true ->
        S end,
    case Locality of
        local->
            S1#xrefr{el = [Call| S1#xrefr.el],l_call_at = [CallAt| S1#xrefr.l_call_at]};
        external->
            S1#xrefr{ex = [Call| S1#xrefr.ex],x_call_at = [CallAt| S1#xrefr.x_call_at]}
    end.

adjust_arity(#xrefr{is_abstr = true,module = M},{M,F,A} = MFA) ->
    case xref_utils:is_static_function(F,A) of
        true->
            MFA;
        false->
            {M,F,A - 1}
    end;
adjust_arity(_S,MFA) ->
    MFA.
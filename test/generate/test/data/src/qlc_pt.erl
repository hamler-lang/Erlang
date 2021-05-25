-file("qlc_pt.erl", 1).

-module(qlc_pt).

-export([parse_transform/2, transform_from_evaluator/2, transform_expression/2]).

-file("/usr/lib/erlang/lib/stdlib-3.14/include/ms_transform.hrl", 1).

-file("qlc_pt.erl", 28).

-record(qlc_lc, {lc,opt}).

-record(state, {imp,overridden,maxargs,records,xwarnings = [],intro_vars,node_info}).

-spec(parse_transform(Forms,Options) -> Forms2 when Forms::[erl_parse:abstract_form()|erl_parse:form_info()],Forms2::[erl_parse:abstract_form()|erl_parse:form_info()],Options::[Option],Option::type_checker|compile:option()).

parse_transform(Forms0,Options) ->
    ok,
    Imported = is_qlc_q_imported(Forms0),
    {Forms,FormsNoShadows,State} = initiate(Forms0,Imported),
    NodeInfo = State#state.node_info,
    try case called_from_type_checker(Options) of
        true->
            L = anno0(),
            {tuple,_,Fs0} = abstr(#qlc_lc{},L),
            F = fun (_Id,LC,A)->
                Init = simple(L,'V',LC,L),
                {{tuple,L,set_field(#qlc_lc.lc,Fs0,Init)},A} end,
            {Forms1,ok} = qlc_mapfold(F,ok,Forms,State),
            Forms1;
        false->
            case compile_messages(Forms,FormsNoShadows,Options,State) of
                {[],Warnings}->
                    ok,
                    {NewForms,State1} = transform(FormsNoShadows,State),
                    ExtraWs = State1#state.xwarnings,
                    {[],WForms} = no_duplicates(NewForms,[],Warnings,ExtraWs,Options),
                    restore_locations(WForms,State) ++ restore_anno(NewForms,NodeInfo);
                {Errors,Warnings}->
                    ok,
                    {EForms,WForms} = no_duplicates(FormsNoShadows,Errors,Warnings,[],Options),
                    restore_locations(EForms ++ WForms,State) ++ Forms0
            end
    end
        after true = ets:delete(NodeInfo) end.

-spec(transform_from_evaluator(LC,Bs) -> Return when LC::erl_parse:abstract_expr(),Bs::erl_eval:binding_struct(),Return::{ok,erl_parse:abstract_expr()}|{not_ok,{error,module(),Reason::term()}}).

transform_from_evaluator(LC,Bindings) ->
    ok,
    transform_expression(LC,Bindings,false).

-spec(transform_expression(LC,Bs) -> Return when LC::erl_parse:abstract_expr(),Bs::erl_eval:binding_struct(),Return::{ok,erl_parse:abstract_expr()}|{not_ok,[{error,Reason::term()}]}).

transform_expression(LC,Bindings) ->
    transform_expression(LC,Bindings,true).

called_from_type_checker(Options) ->
    lists:member(type_checker,Options).

transform_expression(LC,Bs0,WithLintErrors) ->
    L = anno1(),
    As = [{var,L,V} || {V,_Val} <- Bs0],
    Ar = length(As),
    F = {function,L,bar,Ar,[{clause,L,As,[],[{call,L,{remote,L,{atom,L,qlc},{atom,L,q}},[LC]}]}]},
    Forms0 = [{attribute,L,file,{"foo",L}}, {attribute,L,module,foo}, F],
    {Forms,FormsNoShadows,State} = initiate(Forms0,false),
    NodeInfo = State#state.node_info,
    Options = [],
    try compile_messages(Forms,FormsNoShadows,Options,State) of 
        {Errors0,_Warnings}->
            case restore_locations(Errors0,State) of
                []->
                    {NewForms,_State1} = transform(FormsNoShadows,State),
                    NewForms1 = restore_anno(NewForms,NodeInfo),
                    {function,L,bar,Ar,[{clause,L,As,[],[NF]}]} = lists:last(NewForms1),
                    {ok,NF};
                Errors
                    when WithLintErrors->
                    {not_ok,mforms(error,Errors)};
                Errors->
                    [{error,Reason}| _] = mforms(error,Errors),
                    {not_ok,{error,qlc,Reason}}
            end
        after true = ets:delete(NodeInfo) end.

initiate(Forms0,Imported) ->
    NodeInfo = ets:new(qlc,[]),
    true = ets:insert(NodeInfo,{var_n,0}),
    exclude_integers_from_unique_line_numbers(Forms0,NodeInfo),
    ok,
    IsOverridden = set_up_overridden(Forms0),
    State0 = #state{imp = Imported,overridden = IsOverridden,maxargs = 20,records = record_attributes(Forms0),node_info = NodeInfo},
    Forms = save_anno(Forms0,NodeInfo),
    FormsNoShadows = no_shadows(Forms,State0),
    IntroVars = intro_variables(FormsNoShadows,State0),
    State = State0#state{intro_vars = IntroVars},
    {Forms,FormsNoShadows,State}.

exclude_integers_from_unique_line_numbers(Forms,NodeInfo) ->
    Integers = find_integers(Forms),
    lists:foreach(fun (I)->
        ets:insert(NodeInfo,{I}) end,Integers).

find_integers(Forms) ->
    F = fun (A)->
        Fs1 = map_anno(fun (_)->
            A end,Forms),
        ordsets:from_list(integers(Fs1,[])) end,
    ordsets:to_list(ordsets:intersection(F(anno0()),F(anno1()))).

integers([E| Es],L) ->
    integers(Es,integers(E,L));
integers(T,L)
    when is_tuple(T)->
    integers(tuple_to_list(T),L);
integers(I,L)
    when is_integer(I),
    I > 0->
    [I| L];
integers(_,L) ->
    L.

-record(qid, {lcid,no}).

mforms(Tag,L) ->
    lists:sort([{Tag,M} || {_File,Ms} <- L,M <- Ms]).

no_duplicates(Forms,Errors,Warnings0,ExtraWarnings0,Options) ->
    ExtraWarnings = [W || W = {_File,[{_,qlc,Tag}]} <- ExtraWarnings0, not lists:member(Tag,[nomatch_pattern, nomatch_filter])],
    Warnings1 = mforms(Warnings0) -- [{File,[{L,v3_core,nomatch}]} || {File,[{L,qlc,M}]} <- mforms(ExtraWarnings),lists:member(M,[nomatch_pattern, nomatch_filter])] ++ [{File,[{L,sys_core_fold,nomatch_guard}]} || {File,[{L,qlc,M}]} <- mforms(ExtraWarnings),M =:= nomatch_filter],
    Warnings = Warnings1 ++ ExtraWarnings,
    {Es1,Ws1} = compile_forms(Forms,Options),
    Es = mforms(Errors) -- mforms(Es1),
    Ws = mforms(Warnings) -- mforms(Ws1),
    {mforms2(error,Es),mforms2(warning,Ws)}.

mforms(L) ->
    lists:sort([{File,[M]} || {File,Ms} <- L,M <- Ms]).

mforms2(Tag,L) ->
    Line = anno0(),
    ML = lists:flatmap(fun ({File,Ms})->
        [[{attribute,Line,file,{File,0}}, {Tag,M}] || M <- Ms] end,lists:sort(L)),
    lists:flatten(lists:sort(ML)).

restore_locations([T| Ts],State) ->
    [restore_locations(T,State)| restore_locations(Ts,State)];
restore_locations(T,State)
    when is_tuple(T)->
    list_to_tuple(restore_locations(tuple_to_list(T),State));
restore_locations(I,State)
    when I > 0->
    restore_loc(I,State);
restore_locations(T,_State) ->
    T.

is_qlc_q_imported(Forms) ->
    [[] || {attribute,_,import,{qlc,FAs}} <- Forms,{q,1} <- FAs] =/= [].

record_attributes(Forms) ->
    [A || A = {attribute,_,record,_D} <- Forms].

compile_messages(Forms,FormsNoShadows,Options,State) ->
    BGenF = fun (_QId,{b_generate,Line,_P,_LE} = BGen,GA,A)->
        M = {loc(Line),qlc,binary_generator},
        {BGen,[{get(qlc_current_file),[M]}| GA],A};(_QId,Q,GA,A)->
        {Q,GA,A} end,
    {_,BGens} = qual_fold(BGenF,[],[],Forms,State),
    GenForm = used_genvar_check(FormsNoShadows,State),
    ok,
    {GEs,_} = compile_forms([GenForm],Options),
    UsedGenVarMsgs = used_genvar_messages(GEs,State),
    NodeInfo = State#state.node_info,
    WarnFun = fun (_Id,LC,A)->
        {lc_nodes(LC,NodeInfo),A} end,
    {WForms,ok} = qlc_mapfold(WarnFun,ok,Forms,State),
    {Es,Ws} = compile_forms(WForms,Options),
    LcEs = lc_messages(Es,NodeInfo),
    LcWs = lc_messages(Ws,NodeInfo),
    Errors = badarg(Forms,State) ++ UsedGenVarMsgs ++ LcEs ++ BGens,
    Warnings = LcWs,
    {Errors,Warnings}.

badarg(Forms,State) ->
    F = fun (_Id,{lc,_L,_E,_Qs} = LC,Es)->
        {LC,Es};(Id,A,Es)->
        E = {get_lcid_line(Id),qlc,not_a_query_list_comprehension},
        {A,[{get(qlc_current_file),[E]}| Es]} end,
    {_,E0} = qlc_mapfold(F,[],Forms,State),
    E0.

lc_nodes(E,NodeInfo) ->
    map_anno(fun (Anno)->
        N = erl_anno:line(Anno),
        [{N,Data}] = ets:lookup(NodeInfo,N),
        NData = Data#{inside_lc=>true},
        true = ets:insert(NodeInfo,{N,NData}),
        Anno end,E).

used_genvar_messages(MsL,S) ->
    [{File,[{Loc,qlc,{used_generator_variable,V}}]} || {_,Ms} <- MsL,{XLoc,erl_lint,{unbound_var,_}} <- Ms,{Loc,File,V} <- [genvar_pos(XLoc,S)]].

lc_messages(MsL,NodeInfo) ->
    [{File,[{Loc,Mod,T} || {Loc,Mod,T} <- Ms,lc_loc(Loc,NodeInfo)]} || {File,Ms} <- MsL].

lc_loc(N,NodeInfo) ->
    case ets:lookup(NodeInfo,N) of
        [{N,#{inside_lc:=true}}]->
            true;
        [{N,_}]->
            false
    end.

genvar_pos(Location,S) ->
    case ets:lookup(S#state.node_info,Location) of
        [{Location,#{genvar_pos:=Pos}}]->
            Pos;
        []->
            Location
    end.

intro_variables(FormsNoShadows,State) ->
    NodeInfo = State#state.node_info,
    Fun = fun (QId,{T,_L,P0,_E0} = Q,{GVs,QIds},Foo)
        when T =:= b_generate;
        T =:= generate->
        PVs = qlc:var_ufold(fun ({var,_,V})->
            {QId,V} end,P0),
        {Q,{ordsets:to_list(PVs) ++ GVs,[{QId,[]}| QIds]},Foo};(QId,Filter0,{GVs,QIds},Foo)->
        Vs = ordsets:to_list(qlc:vars(Filter0)),
        AnyLine = anno0(),
        Vars = [{var,AnyLine,V} || V <- Vs],
        LC = embed_vars(Vars,AnyLine),
        LC1 = intro_anno(LC,before,QId,NodeInfo),
        LC2 = intro_anno(LC,'after',QId,NodeInfo),
        Filter = {block,AnyLine,[LC1, Filter0, LC2]},
        {Filter,{GVs,[{QId,[]}| QIds]},Foo} end,
    Acc0 = {[],[]},
    {FForms,{GenVars,QIds}} = qual_fold(Fun,Acc0,[],FormsNoShadows,State),
    Es0 = compile_errors(FForms),
    Before = [{QId,V} || {L,erl_lint,{unbound_var,V}} <- Es0,{_L,{QId,before}} <- ets:lookup(NodeInfo,L)],
    After = [{QId,V} || {L,erl_lint,{unbound_var,V}} <- Es0,{_L,{QId,'after'}} <- ets:lookup(NodeInfo,L)],
    Unsafe = [{QId,V} || {L,erl_lint,{unsafe_var,V,_Where}} <- Es0,{_L,{QId,'after'}} <- ets:lookup(NodeInfo,L)],
    ok,
    ok,
    ok,
    ok,
    IV = (Before -- After) -- Unsafe,
    I1 = family(IV ++ GenVars),
    sofs:to_external(sofs:family_union(sofs:family(QIds),I1)).

intro_anno(LC,Where,QId,NodeInfo) ->
    Data = {QId,Where},
    Fun = fun (Anno)->
        Location = erl_anno:location(Anno),
        true = ets:insert(NodeInfo,{Location,Data}),
        Anno end,
    map_anno(Fun,save_anno(LC,NodeInfo)).

compile_errors(FormsNoShadows) ->
    case compile_forms(FormsNoShadows,[]) of
        {[],_Warnings}->
            [];
        {Errors,_Warnings}->
            ok,
            lists:flatmap(fun ({_File,Es})->
                Es end,Errors)
    end.

compile_forms(Forms0,Options) ->
    Exclude = fun (eof)->
        true;(warning)->
        true;(error)->
        true;(_)->
        false end,
    Forms = [F || F <- Forms0, not Exclude(element(1,F))] ++ [{eof,0}],
    try case compile:noenv_forms(Forms,compile_options(Options)) of
        {ok,_ModName,Ws0}->
            {[],Ws0};
        {error,Es0,Ws0}->
            {Es0,Ws0}
    end
        catch
            _:_->
                case erl_lint:module(Forms,lint_options(Options)) of
                    {ok,Warnings}->
                        {[],Warnings};
                    {error,Errors,Warnings}->
                        {Errors,Warnings}
                end end.

compile_options(Options) ->
    No = [report, report_errors, report_warnings, 'P', 'E'| bitstr_options()],
    [strong_validation, return| skip_options(No,Options)].

lint_options(Options) ->
    skip_options(bitstr_options(),Options).

skip_options(Skip,Options) ->
    [O || O <- Options, not lists:member(O,Skip)].

bitstr_options() ->
    [binary_comprehension, bitlevel_binaries].

used_genvar_check(FormsNoShadows,State) ->
    NodeInfo = State#state.node_info,
    F = fun (QId,{T,Ln,_P,LE} = Q,{QsIVs0,Exprs0},IVsSoFar0)
        when T =:= b_generate;
        T =:= generate->
        F = fun (Var)->
            {var,Anno0,OrigVar} = undo_no_shadows(Var,State),
            {var,Anno,_} = NewVar = save_anno(Var,NodeInfo),
            Location0 = erl_anno:location(Anno0),
            Location = erl_anno:location(Anno),
            [{Location,Data}] = ets:lookup(NodeInfo,Location),
            Pos = {Location0,get(qlc_current_file),OrigVar},
            NData = Data#{genvar_pos=>Pos},
            true = ets:insert(NodeInfo,{Location,NData}),
            NewVar end,
        Vs = [Var || {var,_,V} = Var <- qlc:var_fold(F,[],LE),lists:member(V,IVsSoFar0)],
        Exprs = case Vs of
            []->
                Exprs0;
            _->
                [embed_vars(Vs,Ln)| Exprs0]
        end,
        {QsIVs,IVsSoFar} = q_intro_vars(QId,QsIVs0,IVsSoFar0),
        {Q,{QsIVs,Exprs},IVsSoFar};(QId,Filter,{QsIVs0,Exprs},IVsSoFar0)->
        {QsIVs,IVsSoFar} = q_intro_vars(QId,QsIVs0,IVsSoFar0),
        {Filter,{QsIVs,Exprs},IVsSoFar} end,
    Acc0 = {State#state.intro_vars,[{atom,anno0(),true}]},
    {_,{[],Exprs}} = qual_fold(F,Acc0,[],FormsNoShadows,State),
    FunctionNames = [Name || {function,_,Name,_,_} <- FormsNoShadows],
    UniqueFName = qlc:aux_name(used_genvar,1,gb_sets:from_list(FunctionNames)),
    A = anno0(),
    {function,A,UniqueFName,0,[{clause,A,[],[],lists:reverse(Exprs)}]}.

q_intro_vars(QId,[{QId,IVs}| QsIVs],IVsSoFar) ->
    {QsIVs,IVs ++ IVsSoFar}.

transform(FormsNoShadows,State) ->
    _ = erlang:system_flag(backtrace_depth,500),
    IntroVars = State#state.intro_vars,
    AllVars = gb_sets:from_list(ordsets:to_list(qlc:vars(FormsNoShadows))),
    ok,
    F1 = fun (QId,{generate,_,P,LE},Foo,{GoI,SI})->
        {{QId,GoI,SI,{gen,P,LE}},Foo,{GoI + 3,SI + 2}};(QId,F,Foo,{GoI,SI})->
        {{QId,GoI,SI,{fil,F}},Foo,{GoI + 2,SI + 1}} end,
    TemplS = qlc:template_state(),
    GoState = {TemplS + 1,TemplS + 1},
    {ModifiedForms1,_} = qual_fold(F1,[],GoState,FormsNoShadows,State),
    {_,Source0} = qual_fold(fun (_QId,{generate,_,_P,_E} = Q,Dict,Foo)->
        {Q,Dict,Foo};(QId,F,Dict,Foo)->
        {F,maps:put(QId,F,Dict),Foo} end,maps:new(),[],FormsNoShadows,State),
    {_,Source} = qlc_mapfold(fun (Id,{lc,_L,E,_Qs} = LC,Dict)->
        {LC,maps:put(Id,E,Dict)} end,Source0,FormsNoShadows,State),
    F2 = fun (Id,{lc,_L,E,Qs},{IntroVs0,XWarn0})->
        LcNo = get_lcid_no(Id),
        LcL = get_lcid_line(Id),
        [RL, Fun, Go, NGV, S0, RL0, Go0, AT, Err] = aux_vars(['RL', 'Fun', 'Go', 'C', 'S0', 'RL0', 'Go0', 'AT', 'E'],LcNo,AllVars),
        ok,
        {IntroVs,RestIntroVs} = lists:split(length(Qs),IntroVs0),
        IntroVs_Qs = lists:zip(IntroVs,Qs),
        F = fun ({{QId,IVs},{QId,GoI,SI,{gen,P,LE}}},AllIVs0)->
            GV = aux_var('C',LcNo,QId#qid.no,1,AllVars),
            GenIVs = [GV| IVs],
            {{QId,{GenIVs,{{gen,P,LE,GV},GoI,SI}}},GenIVs ++ AllIVs0};({{QId,IVs},{QId,GoI,SI,{fil,F}}},AllIVs0)->
            {{QId,{IVs,{{fil,F},GoI,SI}}},IVs ++ AllIVs0} end,
        {QCs,AllIVs} = lists:mapfoldl(F,[],IntroVs_Qs),
        Dependencies = qualifier_dependencies(Qs,IntroVs),
        L = no_compiler_warning(LcL),
        {EqColumnConstants,EqualColumnConstants,ExtraConsts,SizeInfo} = constants_and_sizes(Qs,E,Dependencies,AllIVs,State),
        {JoinInfo,XWarn} = join_kind(Qs,LcL,AllIVs,Dependencies,State),
        FWarn = warn_failing_qualifiers(Qs,AllIVs,Dependencies,State),
        JQs = join_quals(JoinInfo,QCs,L,LcNo,ExtraConsts,AllVars),
        XQCs = QCs ++ JQs,
        Cs0 = clauses(XQCs,RL,Fun,Go,NGV,Err,AllIVs,State),
        Template = template(E,RL,Fun,Go,AT,L,AllIVs,State),
        Fin = final(RL,AllIVs,L,State),
        FunC = {'fun',L,{clauses,Fin ++ Template ++ Cs0}},
        As0 = pack_args(abst_vars([S0, RL0, Fun, Go0| replace(AllIVs,AllIVs,nil)],L),L,State),
        AsW = abst_vars([S0, RL0, Go0],L),
        FunW = {'fun',L,{clauses,[{clause,L,AsW,[],[{match,L,{var,L,Fun},FunC}, {call,L,{var,L,Fun},As0}]}]}},
        OrigE0 = map_get(Id,Source),
        OrigE = undo_no_shadows(OrigE0,State),
        QCode = qcode(OrigE,XQCs,Source,L,State),
        Qdata = qdata(XQCs,L),
        TemplateInfo = template_columns(Qs,E,AllIVs,Dependencies,State),
        MSQs = match_spec_quals(E,Dependencies,Qs,State),
        Opt = opt_info(TemplateInfo,SizeInfo,JoinInfo,MSQs,L,EqColumnConstants,EqualColumnConstants),
        LCTuple = case qlc_kind(OrigE,Qs,State) of
            qlc->
                {tuple,L,[{atom,L,qlc_v1}, FunW, QCode, Qdata, Opt]};
            {simple,PL,LE,V}->
                Init = closure(LE,L),
                simple(L,V,Init,PL)
        end,
        LCFun = {'fun',L,{clauses,[{clause,L,[],[],[LCTuple]}]}},
        {tuple,_,Fs0} = abstr(#qlc_lc{},L),
        Fs = set_field(#qlc_lc.lc,Fs0,LCFun),
        {{tuple,L,Fs},{RestIntroVs,FWarn ++ XWarn ++ XWarn0}} end,
    {NForms,{[],XW}} = qlc_mapfold(F2,{IntroVars,[]},ModifiedForms1,State),
    display_forms(NForms),
    {NForms,State#state{xwarnings = XW}}.

join_kind(Qs,LcL,AllIVs,Dependencies,State) ->
    {EqualCols2,EqualColsN} = equal_columns(Qs,AllIVs,Dependencies,State),
    {MatchCols2,MatchColsN} = eq_columns(Qs,AllIVs,Dependencies,State),
    Tables = lists:usort([T || {C,_Skip} <- EqualCols2,{T,_} <- C] ++ [T || {C,_Skip} <- EqualCols2,T <- C,is_integer(T)]),
    if EqualColsN =/= [];
    MatchColsN =/= [] ->
        {[],[{get(qlc_current_file),[{LcL,qlc,too_complex_join}]}]};EqualCols2 =:= [],
    MatchCols2 =:= [] ->
        {[],[]};length(Tables) > 2 ->
        {[],[{get(qlc_current_file),[{LcL,qlc,too_many_joins}]}]};EqualCols2 =:= MatchCols2 ->
        {EqualCols2,[]};true ->
        {{EqualCols2,MatchCols2},[]} end.

qlc_kind(OrigE,Qs,State) ->
    {OrigFilterData,OrigGeneratorData} = qual_data(undo_no_shadows(Qs,State)),
    OrigAllFilters = filters_as_one(OrigFilterData),
    {_FilterData,GeneratorData} = qual_data(Qs),
    case {OrigE,OrigAllFilters,OrigGeneratorData} of
        {{var,_,V},{atom,_,true},[{_,{gen,{var,PatternL,V},_LE}}]}->
            [{_,{gen,_,LE}}] = GeneratorData,
            {simple,PatternL,LE,V};
        _->
            qlc
    end.

warn_failing_qualifiers(Qualifiers,AllIVs,Dependencies,State) ->
    {FilterData,GeneratorData} = qual_data(Qualifiers),
    Anon = 1,
    BindFun = fun (_Op,Value)->
        is_bindable(Value) end,
    {PFrame,_PatternVars} = pattern_frame(GeneratorData,BindFun,Anon,State),
    {_,_,Imported} = filter_info(FilterData,AllIVs,Dependencies,State),
    PFrames = frame2frames(PFrame),
    {_,Warnings} = lists:foldl(fun ({_QId,{fil,_Filter}},{[] = Frames,Warnings})->
        {Frames,Warnings};({_QId,{fil,Filter}},{Frames,Warnings})->
        case filter(reset_anno(Filter),Frames,BindFun,State,Imported) of
            []->
                {[],[{get(qlc_current_file),[{loc(element(2,Filter)),qlc,nomatch_filter}]}| Warnings]};
            Frames1->
                {Frames1,Warnings}
        end;({_QId,{gen,Pattern,_}},{Frames,Warnings})->
        case pattern(Pattern,Anon,[],BindFun,State) of
            {failed,_,_}->
                {Frames,[{get(qlc_current_file),[{loc(element(2,Pattern)),qlc,nomatch_pattern}]}| Warnings]};
            _->
                {Frames,Warnings}
        end end,{PFrames,[]},FilterData ++ GeneratorData),
    Warnings.

opt_info(TemplateInfo,Sizes,JoinInfo,MSQs,L,EqColumnConstants0,EqualColumnConstants0) ->
    SzCls = [{clause,L,[{integer,L,C}],[],[{integer,L,Sz}]} || {C,Sz} <- lists:sort(Sizes)] ++ [{clause,L,[{var,L,_}],[],[{atom,L,undefined}]}],
    S = [{size,{'fun',L,{clauses,SzCls}}}],
    J = case JoinInfo of
        []->
            [];
        _->
            [{join,abstr(JoinInfo,L)}]
    end,
    TCls0 = lists:append([[{clause,L,[abstr(Col,L), EqType],[],[abstr(TemplCols,L)]} || {Col,TemplCols} <- TemplateColumns] || {EqType,TemplateColumns} <- TemplateInfo]),
    TCls = lists:sort(TCls0) ++ [{clause,L,[{var,L,_}, {var,L,_}],[],[{nil,L}]}],
    T = [{template,{'fun',L,{clauses,TCls}}}],
    EqColumnConstants = opt_column_constants(EqColumnConstants0),
    CCs = opt_constants(L,EqColumnConstants),
    EqC = {constants,{'fun',L,{clauses,CCs}}},
    EqualColumnConstants = opt_column_constants(EqualColumnConstants0),
    ECCs = opt_constants(L,EqualColumnConstants),
    EqualC = {equal_constants,{'fun',L,{clauses,ECCs}}},
    C = [EqC| [EqualC || true <- [CCs =/= ECCs]]],
    ConstCols = [{IdNo,Col} || {{IdNo,Col},[_],_FilNs} <- EqualColumnConstants],
    ConstColsFamily = family_list(ConstCols),
    NSortedCols0 = [{IdNo,hd(lists:seq(1,length(Cols) + 1) -- Cols)} || {IdNo,Cols} <- ConstColsFamily],
    NCls = [{clause,L,[{integer,L,IdNo}],[],[{integer,L,N - 1}]} || {IdNo,N} <- NSortedCols0,N > 0] ++ [{clause,L,[{var,L,_}],[],[{integer,L,0}]}],
    N = [{n_leading_constant_columns,{'fun',L,{clauses,NCls}}}],
    ConstCls = [{clause,L,[{integer,L,IdNo}],[],[abstr(Cols,L)]} || {IdNo,Cols} <- ConstColsFamily] ++ [{clause,L,[{var,L,_}],[],[{nil,L}]}],
    CC = [{constant_columns,{'fun',L,{clauses,ConstCls}}}],
    MSCls = [{clause,L,[{integer,L,G}],[],[{tuple,L,[MS, abstr(Fs,L)]}]} || {G,MS,Fs} <- MSQs] ++ [{clause,L,[{var,L,_}],[],[{atom,L,undefined}]}],
    MS = [{match_specs,{'fun',L,{clauses,MSCls}}}],
    Cls = [{clause,L,[{atom,L,Tag}],[],[V]} || {Tag,V} <- lists:append([J, S, T, C, N, CC, MS])] ++ [{clause,L,[{var,L,_}],[],[{atom,L,undefined}]}],
    {'fun',L,{clauses,Cls}}.

opt_column_constants(ColumnConstants0) ->
    [CC || {{IdNo,_Col},Const,_FilNs} = CC <- ColumnConstants0,(IdNo =/= 0) or (length(Const) =:= 1)].

opt_constants(L,ColumnConstants) ->
    Ns = lists:usort([IdNo || {{IdNo,_Col},_Const,_FilNs} <- ColumnConstants]),
    [{clause,L,[{integer,L,IdNo}],[],[column_fun(ColumnConstants,IdNo,L)]} || IdNo <- Ns] ++ [{clause,L,[{var,L,_}],[],[{atom,L,no_column_fun}]}].

abstr(Term,Anno) ->
    erl_parse:abstract(Term,loc(Anno)).

join_quals(JoinInfo,QCs,L,LcNo,ExtraConstants,AllVars) ->
    {LastGoI,LastSI} = lists:foldl(fun ({_QId,{_QIVs,{{fil,_},GoI,SI}}},{GoI0,_SI0})
        when GoI >= GoI0->
        {GoI + 2,SI + 1};({_QId,{_QIVs,{{gen,_,_,_},GoI,SI}}},{GoI0,_SI0})
        when GoI >= GoI0->
        {GoI + 3,SI + 2};(_,A)->
        A end,{0,0},QCs),
    LastQId = lists:max([QId || {QId,{_QIVs,{_Q,_GoI,_SI}}} <- QCs]),
    QNums = case JoinInfo of
        {EqualCols,MatchCols}->
            EQs = join_qnums(EqualCols),
            MQs = join_qnums(MatchCols),
            [{Q1,Q2,'=:='} || {Q1,Q2} <- MQs] ++ [{Q1,Q2,'=='} || {Q1,Q2} <- EQs -- MQs];
        EqualCols->
            [{Q1,Q2,'=='} || {Q1,Q2} <- join_qnums(EqualCols)]
    end,
    LD = [begin [{QId1,P1,GV1,QIVs1}] = [{QId,P,GV,QIVs} || {QId,{QIVs,{{gen,P,_,GV},_GoI,_SI}}} <- QCs,QId#qid.no =:= Q1],
    [{QId2,P2,QIVs2}] = [{QId,P,QIVs -- [GV]} || {QId,{QIVs,{{gen,P,_,GV},_,_}}} <- QCs,QId#qid.no =:= Q2],
    {QId1,Op,P1,GV1,QIVs1 ++ QIVs2,QId2,P2} end || {Q1,Q2,Op} <- lists:usort(QNums)],
    Aux = abst_vars(aux_vars(['F', 'H', 'O', 'C'],LcNo,AllVars),L),
    F = fun ({QId1,Op,P1,GV1,QIVs,QId2,P2},{QId,GoI,SI})->
        AP1 = anon_pattern(P1),
        AP2 = anon_pattern(P2),
        Cs1 = join_handle_constants(QId1,ExtraConstants),
        Cs2 = join_handle_constants(QId2,ExtraConstants),
        H1 = join_handle(AP1,L,Aux,Cs1),
        H2 = join_handle(AP2,L,Aux,Cs2),
        Join = {join,Op,QId1#qid.no,QId2#qid.no,H1,H2,Cs1,Cs2},
        G = {NQId = QId#qid{no = QId#qid.no + 1},{QIVs,{{gen,{cons,L,P1,P2},Join,GV1},GoI,SI}}},
        A = {NQId,GoI + 3,SI + 2},
        {G,A} end,
    {Qs,_} = lists:mapfoldl(F,{LastQId,LastGoI,LastSI},LD),
    Qs.

join_qnums(Cols) ->
    lists:usort([{Q1,Q2} || {[{Q1,_C1}, {Q2,_C2}],_Skip} <- Cols]).

anon_pattern(P) ->
    MoreThanOnce = lists:usort(occ_vars(P) -- qlc:vars(P)),
    {AP,foo} = var_mapfold(fun ({var,L,V},A)->
        case lists:member(V,MoreThanOnce) of
            true->
                {{var,L,V},A};
            false->
                {{var,L,_},A}
        end end,foo,P),
    AP.

join_handle(AP,L,[F, H, O, C],Constants) ->
    case {AP,Constants} of
        {{var,_,_},[]}->
            {'fun',L,{clauses,[{clause,L,[H],[],[H]}]}};
        _->
            A = anno0(),
            G0 = [begin Call = {call,A,{atom,A,element},[{integer,A,Col}, O]},
            list2op([{op,A,Op,Con,Call} || {Con,Op} <- Cs],'or') end || {Col,Cs} <- Constants],
            G = if G0 =:= [] ->
                G0;true ->
                [G0] end,
            CC1 = {clause,L,[AP],G,[{cons,L,O,closure({call,L,F,[F, C]},L)}]},
            CC2 = {clause,L,[{var,L,_}],[],[{call,L,F,[F, C]}]},
            Case = {'case',L,O,[CC1, CC2]},
            Cls = [{clause,L,[{var,L,_}, {nil,L}],[],[{nil,L}]}, {clause,L,[F, {cons,L,O,C}],[],[Case]}, {clause,L,[F, C],[[{call,L,{atom,L,is_function},[C]}]],[{call,L,F,[F, {call,L,C,[]}]}]}, {clause,L,[{var,L,_}, C],[],[C]}],
            Fun = {'fun',L,{clauses,Cls}},
            {'fun',L,{clauses,[{clause,L,[H],[],[{match,L,F,Fun}, closure({call,L,F,[F, H]},L)]}]}}
    end.

join_handle_constants(QId,ExtraConstants) ->
    IdNo = QId#qid.no,
    case lists:keyfind(IdNo,1,ExtraConstants) of
        {IdNo,ConstOps}->
            ConstOps;
        false->
            []
    end.

column_fun(Columns,QualifierNumber,LcL) ->
    A = anno0(),
    ColCls0 = [begin true = Vs0 =/= [],
    Vs1 = list2cons(Vs0),
    Fils1 = {tuple,A,[{atom,A,FTag}, lists:foldr(fun (F,Ac)->
        {cons,A,{integer,A,F},Ac} end,{nil,A},Fils)]},
    Tag = case ordsets:to_list(qlc:vars(Vs1)) of
        Imp
            when length(Imp) > 0,
            length(Vs0) > 1->
            usort_needed;
        _->
            values
    end,
    Vs = {tuple,A,[{atom,A,Tag}, Vs1, Fils1]},
    {clause,A,[erl_parse:abstract(Col)],[],[Vs]} end || {{CIdNo,Col},Vs0,{FTag,Fils}} <- Columns,CIdNo =:= QualifierNumber] ++ [{clause,A,[{var,A,_}],[],[{atom,A,false}]}],
    ColCls = set_anno(ColCls0,LcL),
    {'fun',LcL,{clauses,ColCls}}.

template_columns(Qs0,E0,AllIVs,Dependencies,State) ->
    E = expand_expr_records(pre_expand(E0),State),
    TemplateAsPattern = template_as_pattern(E),
    Qs = [TemplateAsPattern| Qs0],
    EqualColumns = equal_columns2(Qs,AllIVs,Dependencies,State),
    MatchColumns = eq_columns2(Qs,AllIVs,Dependencies,State),
    Equal = template_cols(EqualColumns),
    Match = template_cols(MatchColumns),
    L = anno0(),
    if Match =:= Equal ->
        [{{var,L,_},Match}];true ->
        [{{atom,L,'=='},Equal}, {{atom,L,'=:='},Match}] end.

equal_columns2(Qualifiers,AllIVs,Dependencies,State) ->
    {JI,_Skip} = join_info(Qualifiers,AllIVs,Dependencies,State,_JoinOp = '=='),
    JI.

eq_columns2(Qualifiers,AllIVs,Dependencies,State) ->
    {JI,_SKip} = join_info(Qualifiers,AllIVs,Dependencies,State,_JoinOp = '=:='),
    JI.

template_cols(ColumnClasses) ->
    lists:sort([{{IdNo,Col},lists:usort(Cs)} || Class <- ColumnClasses,{IdNo,Col} <- Class,IdNo =/= 0,[] =/= (Cs = [C || {0,C} <- Class])]).

template_as_pattern(E) ->
    P = simple_template(E),
    {#qid{lcid = template,no = 0},foo,foo,{gen,P,{nil,anno0()}}}.

simple_template({call,L,{remote,_,{atom,_,erlang},{atom,_,element}} = Call,[{integer,_,I} = A1, A2]})
    when I > 0->
    {call,L,Call,[A1, simple_template(A2)]};
simple_template({var,_,_} = E) ->
    E;
simple_template({tuple,L,Es}) ->
    {tuple,L,[(simple_template(E)) || E <- Es]};
simple_template({cons,L,H,T}) ->
    {cons,L,simple_template(H),simple_template(T)};
simple_template(E) ->
    case  catch erl_parse:normalise(E) of
        {'EXIT',_}->
            unique_var();
        _->
            E
    end.

qualifier_dependencies(Qualifiers,IntroVs) ->
    Intro = sofs:relation([{IV,QId} || {QId,IVs} <- IntroVs,IV <- IVs]),
    {FilterData,_} = qual_data(Qualifiers),
    Used = sofs:relation([{QId,UV} || {QId,{fil,F}} <- FilterData,UV <- qlc:vars(F)]),
    Depend = sofs:strict_relation(sofs:relative_product(Used,Intro)),
    G = sofs:family_to_digraph(sofs:relation_to_family(Depend)),
    Dep0 = [{V,digraph_utils:reachable_neighbours([V],G)} || V <- digraph:vertices(G)],
    true = digraph:delete(G),
    FilterIds = sofs:set(filter_ids(Qualifiers)),
    Dep1 = sofs:restriction(sofs:family(Dep0),FilterIds),
    NoDep = sofs:constant_function(FilterIds,sofs:empty_set()),
    sofs:to_external(sofs:family_union(Dep1,NoDep)).

filter_ids(Qualifiers) ->
    {FilterData,_} = qual_data(Qualifiers),
    [QId || {QId,_} <- FilterData].

match_spec_quals(Template,Dependencies,Qualifiers,State) ->
    {FilterData,GeneratorData} = qual_data(Qualifiers),
    NoFilterGIds = [GId || {GId,_} <- GeneratorData] -- lists:flatmap(fun ({_,GIds})->
        GIds end,Dependencies),
    Filters = filter_list(FilterData,Dependencies,State),
    Candidates = [{QId2#qid.no,Pattern,[Filter],F} || {QId,[QId2]} <- Dependencies,{GQId,{gen,Pattern,_}} <- GeneratorData,GQId =:= QId2,{FQId,{fil,F}} = Filter <- Filters,FQId =:= QId] ++ [{GId#qid.no,Pattern,[],{atom,anno0(),true}} || {GId,{gen,Pattern,_}} <- GeneratorData,lists:member(GId,NoFilterGIds)],
    E = {nil,anno0()},
    GF = [{{GNum,Pattern},Filter} || {GNum,Pattern,Filter,F} <- Candidates,no =/= try_ms(E,Pattern,F,State)],
    GFF = sofs:relation_to_family(sofs:relation(GF,[{gnum_pattern,[filter]}])),
    GFFL = sofs:to_external(sofs:family_union(GFF)),
    try [{{GNum,Pattern},GFilterData}] = GFFL,
    true = length(GFilterData) =:= length(FilterData),
    [_] = GeneratorData,
    AbstrMS = gen_ms(Template,Pattern,GFilterData,State),
    [{GNum,AbstrMS,all}]
        catch
            _:_->
                {TemplVar,_} = anon_var({var,anno0(),_},0),
                [(one_gen_match_spec(GNum,Pattern,GFilterData,State,TemplVar)) || {{GNum,Pattern},GFilterData} <- GFFL] end.

one_gen_match_spec(GNum,Pattern0,GFilterData,State,TemplVar) ->
    {E,Pattern} = pattern_as_template(Pattern0,TemplVar),
    AbstrMS = gen_ms(E,Pattern,GFilterData,State),
    {GNum,AbstrMS,[(FId#qid.no) || {FId,_} <- GFilterData]}.

gen_ms(E,Pattern,GFilterData,State) ->
    {ok,MS,AMS} = try_ms(E,Pattern,filters_as_one(GFilterData),State),
    case MS of
        [{'$1',[true],['$1']}]->
            {atom,anno0(),no_match_spec};
        _->
            AMS
    end.

pattern_as_template({var,_,_},TemplVar) ->
    {TemplVar,TemplVar};
pattern_as_template({var,_,_} = V,_TemplVar) ->
    {V,V};
pattern_as_template({match,L,E,{var,_,_}},TemplVar) ->
    {TemplVar,{match,L,E,TemplVar}};
pattern_as_template({match,L,{var,_,_},E},TemplVar) ->
    {TemplVar,{match,L,E,TemplVar}};
pattern_as_template({match,_,_E,{var,_,_} = V} = P,_TemplVar) ->
    {V,P};
pattern_as_template({match,_,{var,_,_} = V,_E} = P,_TemplVar) ->
    {V,P};
pattern_as_template(E,TemplVar) ->
    L = anno0(),
    {TemplVar,{match,L,E,TemplVar}}.

constants_and_sizes(Qualifiers0,E,Dependencies,AllIVs,State) ->
    TemplateAsPattern = template_as_pattern(E),
    Qualifiers = [TemplateAsPattern| Qualifiers0],
    {FilterData,GeneratorData} = qual_data(Qualifiers),
    {Filter,Anon1,Imported} = filter_info(FilterData,AllIVs,Dependencies,State),
    PatBindFun = fun (_Op,Value)->
        is_bindable(Value) end,
    {PatternFrame,PatternVars} = pattern_frame(GeneratorData,PatBindFun,Anon1,State),
    PatternFrames = frame2frames(PatternFrame),
    FilterFun = fun (BindFun)->
        filter(Filter,PatternFrames,BindFun,State,Imported) end,
    SzFs = FilterFun(PatBindFun),
    SizeInfo = pattern_sizes(PatternVars,SzFs),
    SelectorFun = const_selector(Imported),
    PatternConstants = lists:flatten(frames_to_columns(PatternFrames,PatternVars,deref_pattern(Imported),SelectorFun,Imported,'=:=')),
    {EqColumnConstants,_EqExtraConsts} = constants(FilterFun,PatternVars,PatternConstants,PatternFrame,FilterData,Dependencies,_LookupOp1 = '=:=',Imported,State),
    {EqualColumnConstants,EqualExtraConsts} = constants(FilterFun,PatternVars,PatternConstants,PatternFrame,FilterData,Dependencies,_LookupOp2 = '==',Imported,State),
    ExtraCon1 = [{{GId,Col},{Val,Op}} || {Consts,Op} <- [{EqualExtraConsts,'=='}],{{GId,Col},Val} <- Consts],
    ExtraConstants = family_list([{GId,{Col,ValOps}} || {{GId,Col},ValOps} <- family_list(ExtraCon1)]),
    {EqColumnConstants,EqualColumnConstants,ExtraConstants,SizeInfo}.

constants(FilterFun,PatternVars,PatternConstants,PatternFrame,FilterData,Dependencies,LookupOp,Imported,State) ->
    BindFun = fun (_Op,Value)->
        is_bindable(Value) end,
    Fs = FilterFun(BindFun),
    SelectorFun = const_selector(Imported),
    ColumnConstants0 = frames_to_columns(Fs,PatternVars,deref_lookup(Imported,LookupOp),SelectorFun,Imported,LookupOp),
    ColumnConstants1 = lists:flatten(ColumnConstants0),
    ExtraConstants = [{{GId,Col},Val} || {{GId,Col},Vals} <- ColumnConstants1 -- PatternConstants,GId =/= 0,Val <- Vals],
    ColumnConstants = lu_skip(ColumnConstants1,FilterData,PatternFrame,PatternVars,Dependencies,State,Imported,LookupOp),
    {ColumnConstants,ExtraConstants}.

deref_lookup(Imported,'==') ->
    fun (PV,F)->
        deref_values(PV,F,Imported) end;
deref_lookup(Imported,'=:=') ->
    BFun = fun (DV,Op)->
        Op =:= '=:=' orelse free_of_integers(DV,Imported) end,
    fun (PV,F)->
        deref_values(PV,F,BFun,Imported) end.

lu_skip(ColConstants,FilterData,PatternFrame,PatternVars,Dependencies,State,Imported,LookupOp) ->
    FailSelector = fun (_Frame)->
        fun (Value)->
            {yes,Value} end end,
    PatternFrames = frame2frames(PatternFrame),
    PatternColumns = lists:flatten(frames_to_columns(PatternFrames,PatternVars,deref_pattern(Imported),FailSelector,Imported,LookupOp)),
    BindFun = fun (_Op,Value)->
        is_bindable(Value) end,
    ColFil = [{Column,FId#qid.no} || {FId,{fil,Fil}} <- filter_list(FilterData,Dependencies,State),[] =/= (SFs = safe_filter(reset_anno(Fil),PatternFrames,BindFun,State,Imported)),{GId,PV} <- PatternVars,[] =/= (Cols = hd(frames_to_columns(SFs,[{GId,PV}],deref_lu_skip(LookupOp,Imported),const_selector(Imported),Imported,LookupOp))),length(D = Cols -- PatternColumns) =:= 1,{{_,Col} = Column,Constants} <- D,lists:all(fun (Frame)->
        {VarI,FrameI} = unify_column(Frame,PV,Col,BindFun,Imported),
        VarValues = deref_skip(VarI,FrameI,LookupOp,Imported),
        {NV,F1} = unify_column(PatternFrame,PV,Col,BindFun,Imported),
        F2 = unify_var_bindings(VarValues,'=:=',NV,F1,BindFun,Imported,false),
        LookedUpConstants = case lists:keyfind(Column,1,ColConstants) of
            false->
                [];
            {Column,LUCs}->
                LUCs
        end,
        length(VarValues) =< 1 andalso Constants -- LookedUpConstants =:= [] andalso bindings_is_subset(Frame,F2,Imported) end,SFs)],
    ColFils = family_list(ColFil),
    [{Col,Constants,skip_tag(Col,ColFils,FilterData)} || {Col,Constants} <- ColConstants].

deref_skip(E,F,_LookupOp,Imported) ->
    deref(E,F,Imported).

deref_lu_skip('==',Imported) ->
    BFun = fun (DV,Op)->
        Op =:= '==' orelse free_of_integers(DV,Imported) end,
    fun (PV,F)->
        deref_values(PV,F,BFun,Imported) end;
deref_lu_skip('=:=',Imported) ->
    fun (PV,F)->
        deref_values(PV,F,Imported) end.

equal_columns(Qualifiers,AllIVs,Dependencies,State) ->
    {Cs,Skip} = join_info(Qualifiers,AllIVs,Dependencies,State,_JoinOp = '=='),
    join_gens(Cs,Qualifiers,Skip).

eq_columns(Qualifiers,AllIVs,Dependencies,State) ->
    {Cs,Skip} = join_info(Qualifiers,AllIVs,Dependencies,State,_JoinOp = '=:='),
    join_gens(Cs,Qualifiers,Skip).

join_gens(Cs0,Qs,Skip) ->
    Cs = [(family_list(C)) || C <- Cs0],
    {FD,_GeneratorData} = qual_data(Qs),
    {join_gens2(lists:filter(fun (C)->
        length(C) =:= 2 end,Cs),FD,Skip),join_gens2(lists:filter(fun (C)->
        length(C) > 2 end,Cs),FD,Skip)}.

join_gens2(Cs0,FilterData,Skip) ->
    [{J,skip_tag(case lists:keyfind(J,1,Skip) of
        {J,FilL}->
            FilL;
        false->
            []
    end,FilterData)} || J <- lists:append([(qlc:all_selections(C)) || C <- Cs0])].

skip_tag(FilList,FilterData) ->
    {if length(FilterData) =:= length(FilList) ->
        all;true ->
        some end,FilList}.

skip_tag(Col,ColFils,FilterData) ->
    case lists:keyfind(Col,1,ColFils) of
        {Col,FilL}->
            Tag = if length(FilterData) =:= length(FilL) ->
                all;true ->
                some end,
            {Tag,FilL};
        false->
            {some,[]}
    end.

join_info(Qualifiers,AllIVs,Dependencies,State,JoinOp) ->
    {FilterData,GeneratorData} = qual_data(Qualifiers),
    {Filter,Anon1,Imported} = filter_info(FilterData,AllIVs,Dependencies,State),
    BindFun = fun (_Op,V)->
        bind_no_const(V,Imported) end,
    {PatternFrame,PatternVars} = pattern_frame(GeneratorData,BindFun,Anon1,State),
    PatternFrames = frame2frames(PatternFrame),
    Fs = filter(Filter,PatternFrames,BindFun,State,Imported),
    SelectorFun = no_const_selector(Imported),
    Cols = frames_to_columns(Fs,PatternVars,fun (PV1,F)->
        deref_join(PV1,F,JoinOp) end,SelectorFun,Imported,'=:='),
    JC = join_classes(Cols),
    Skip = join_skip(JC,FilterData,PatternFrame,PatternVars,Dependencies,State,Imported,JoinOp),
    {JC,Skip}.

deref_join(E,Frame,'==') ->
    deref_values(E,Frame,_Imp = []);
deref_join(E,Frame,'=:=') ->
    deref_values(E,Frame,fun (_DV,Op)->
        Op =:= '=:=' end,all).

join_classes(Cols0) ->
    ColVar = sofs:relation(lists:append(Cols0)),
    Cols = sofs:partition(2,ColVar),
    [[C || {C,_} <- Cs] || Cs <- sofs:to_external(Cols),length(Cs) > 1].

join_skip(JoinClasses,FilterData,PatternFrame,PatternVars,Dependencies,State,Imported,JoinOp) ->
    PatternFrames = frame2frames(PatternFrame),
    ColFil = [{JoinClass,FId#qid.no} || [{Q1,C1}, {Q2,C2}] = JoinClass <- JoinClasses,{GId1,PV1} <- PatternVars,GId1#qid.no =:= Q1,{GId2,PV2} <- PatternVars,GId2#qid.no =:= Q2,{FId,{fil,Fil}} <- filter_list(FilterData,Dependencies,State),{value,{_,GIds}} <- [lists:keysearch(FId,1,Dependencies)],GIds =:= lists:sort([GId1, GId2]),begin BindFun = fun (_Op,V)->
        is_bindable(V) end,
    {V1,JF1} = unify_column(PatternFrame,PV1,C1,BindFun,Imported),
    {V2,JF2} = unify_column(JF1,PV2,C2,BindFun,Imported),
    JF = unify(JoinOp,V1,V2,JF2,BindFun,Imported),
    SFs = safe_filter(reset_anno(Fil),PatternFrames,BindFun,State,Imported),
    JImp = qlc:vars([SFs, JF]),
    lists:all(fun (Frame)->
        bindings_is_subset(Frame,JF,JImp) end,SFs) andalso SFs =/= [] end],
    family_list(ColFil).

filter_info(FilterData,AllIVs,Dependencies,State) ->
    FilterList = filter_list(FilterData,Dependencies,State),
    Filter0 = reset_anno(filters_as_one(FilterList)),
    Anon0 = 0,
    {Filter,Anon1} = anon_var(Filter0,Anon0),
    Imported = ordsets:subtract(qlc:vars(Filter),ordsets:from_list(AllIVs)),
    {Filter,Anon1,Imported}.

filter_list(FilterData,Dependencies,State) ->
    sel_gf(FilterData,1,Dependencies,State,[],[]).

sel_gf([],_N,_Deps,_RDs,_Gens,_Gens1) ->
    [];
sel_gf([{#qid{no = N} = Id,{fil,F}} = Fil| FData],N,Deps,State,Gens,Gens1) ->
    case is_guard_test(F,State) of
        true->
            {Id,GIds} = lists:keyfind(Id,1,Deps),
            case length(GIds) =< 1 of
                true->
                    case generators_in_scope(GIds,Gens1) of
                        true->
                            [Fil| sel_gf(FData,N + 1,Deps,State,Gens,Gens1)];
                        false->
                            sel_gf(FData,N + 1,Deps,State,[],[])
                    end;
                false->
                    case generators_in_scope(GIds,Gens) of
                        true->
                            [Fil| sel_gf(FData,N + 1,Deps,State,Gens,[])];
                        false->
                            sel_gf(FData,N + 1,Deps,State,[],[])
                    end
            end;
        false->
            sel_gf(FData,N + 1,Deps,State,[],[])
    end;
sel_gf(FData,N,Deps,State,Gens,Gens1) ->
    sel_gf(FData,N + 1,Deps,State,[N| Gens],[N| Gens1]).

generators_in_scope(GenIds,GenNumbers) ->
    lists:all(fun (#qid{no = N})->
        lists:member(N,GenNumbers) end,GenIds).

pattern_frame(GeneratorData,BindFun,Anon1,State) ->
    Frame0 = [],
    {PatternFrame,_Anon2,PatternVars} = lists:foldl(fun ({QId,{gen,Pattern,_}},{F0,An0,PVs})->
        {F1,An1,PV} = pattern(Pattern,An0,F0,BindFun,State),
        {F1,An1,[{QId,PV}| PVs]} end,{Frame0,Anon1,[]},GeneratorData),
    {PatternFrame,PatternVars}.

const_selector(Imported) ->
    selector(Imported,fun is_const/2).

no_const_selector(Imported) ->
    selector(Imported,fun (V,I)->
         not is_const(V,I) end).

selector(Imported,TestFun) ->
    fun (_Frame)->
        fun (Value)->
            case TestFun(Value,Imported) of
                true->
                    {yes,Value};
                false->
                    no
            end end end.

bind_no_const(Value,Imported) ->
    case is_const(Value,Imported) of
        true->
            false;
        false->
            is_bindable(Value)
    end.

is_const(Value,Imported) ->
    [] =:= ordsets:to_list(ordsets:subtract(qlc:vars(Value),Imported)).

is_bindable(Value) ->
    case normalise(Value) of
        {ok,_C}->
            true;
        not_ok->
            false
    end.

pattern(P0,AnonI,Frame0,BindFun,State) ->
    P1 = try expand_pattern_records(P0,State)
        catch
            _:_->
                P0 end,
    P2 = reset_anno(P1),
    {P3,AnonN} = anon_var(P2,AnonI),
    {P4,F1} = match_in_pattern(tuple2cons(P3),Frame0,BindFun),
    {P,F2} = element_calls(P4,F1,BindFun,_Imp = []),
    {var,_,PatternVar} = UniqueVar = unique_var(),
    F = unify('=:=',UniqueVar,P,F2,BindFun,_Imported = []),
    {F,AnonN,PatternVar}.

frame2frames(failed) ->
    [];
frame2frames(F) ->
    [F].

match_in_pattern({match,_,E10,E20},F0,BF) ->
    {E1,F1} = match_in_pattern(E10,F0,BF),
    {E2,F} = match_in_pattern(E20,F1,BF),
    E = case BF('=:=',E1) of
        true->
            E1;
        false->
            E2
    end,
    {E,unify('=:=',E1,E2,F,BF,_Imported = [])};
match_in_pattern(T,F0,BF)
    when is_tuple(T)->
    {L,F} = match_in_pattern(tuple_to_list(T),F0,BF),
    {list_to_tuple(L),F};
match_in_pattern([E0| Es0],F0,BF) ->
    {E,F1} = match_in_pattern(E0,F0,BF),
    {Es,F} = match_in_pattern(Es0,F1,BF),
    {[E| Es],F};
match_in_pattern(E,F,_BF) ->
    {E,F}.

anon_var(E,AnonI) ->
    var_mapfold(fun ({var,L,_},N)->
        {{var,L,N},N + 1};(Var,N)->
        {Var,N} end,AnonI,E).

reset_anno(T) ->
    set_anno(T,anno0()).

set_anno(T,A) ->
    map_anno(fun (_L)->
        A end,T).

-record(fstate, {state,bind_fun,imported}).

filter(_E,[] = Frames0,_BF,_State,_Imported) ->
    Frames0;
filter(E0,Frames0,BF,State,Imported) ->
    E = pre_expand(E0),
    FState = #fstate{state = State,bind_fun = BF,imported = Imported},
    filter1(E,Frames0,FState).

filter1({op,_,Op,L0,R0},Fs,FS)
    when Op =:= '=:=';
    Op =:= '=='->
    #fstate{state = S,bind_fun = BF,imported = Imported} = FS,
    lists:flatmap(fun (F0)->
        {L,F1} = prep_expr(L0,F0,S,BF,Imported),
        {R,F2} = prep_expr(R0,F1,S,BF,Imported),
        case unify(Op,L,R,F2,BF,Imported) of
            failed->
                [];
            F->
                [F]
        end end,Fs);
filter1({op,_,Op,L,R},Fs,FS)
    when Op =:= 'and';
    Op =:= 'andalso'->
    filter1(R,filter1(L,Fs,FS),FS);
filter1({op,_,Op,L,R},Fs,FS)
    when Op =:= 'or';
    Op =:= 'orelse';
    Op =:= 'xor'->
    filter1(L,Fs,FS) ++ filter1(R,Fs,FS);
filter1({atom,_,Atom},_Fs,_FS)
    when Atom =/= true->
    [];
filter1({call,L,{remote,_,{atom,_,erlang},{atom,_,is_record}},[T, R]},Fs,FS) ->
    filter1({op,L,'=:=',{call,L,{remote,L,{atom,L,erlang},{atom,L,element}},[{integer,L,1}, T]},R},Fs,FS);
filter1({call,L,{remote,L1,{atom,_,erlang} = M,{atom,L2,is_record}},[T, R, _Sz]},Fs,FS) ->
    filter1({call,L,{remote,L1,M,{atom,L2,is_record}},[T, R]},Fs,FS);
filter1(_E,Fs,_FS) ->
    Fs.

safe_filter(_E,[] = Frames0,_BF,_State,_Imported) ->
    Frames0;
safe_filter(E0,Frames0,BF,State,Imported) ->
    E = pre_expand(E0),
    FState = #fstate{state = State,bind_fun = BF,imported = Imported},
    safe_filter1(E,Frames0,FState).

safe_filter1({op,_,Op,L0,R0},Fs,FS)
    when Op =:= '=:=';
    Op =:= '=='->
    #fstate{state = S,bind_fun = BF,imported = Imported} = FS,
    lists:flatmap(fun (F0)->
        {L,F1} = prep_expr(L0,F0,S,BF,Imported),
        {R,F2} = prep_expr(R0,F1,S,BF,Imported),
        case safe_unify(Op,L,R,F2,BF,Imported) of
            failed->
                [];
            F->
                [F]
        end end,Fs);
safe_filter1({op,_,Op,L,R},Fs,FS)
    when Op =:= 'and';
    Op =:= 'andalso'->
    safe_filter1(R,safe_filter1(L,Fs,FS),FS);
safe_filter1({op,_,Op,L,R},Fs,FS)
    when Op =:= 'or';
    Op =:= 'orelse'->
    safe_filter1(L,Fs,FS) ++ safe_filter1(R,Fs,FS);
safe_filter1({atom,_,true},Fs,_FS) ->
    Fs;
safe_filter1(_E,_Fs,_FS) ->
    [].

pre_expand({call,L1,{atom,L2,record},As}) ->
    pre_expand({call,L1,{atom,L2,is_record},As});
pre_expand({call,L,{atom,_,_} = F,As}) ->
    pre_expand({call,L,{remote,L,{atom,L,erlang},F},As});
pre_expand({call,L,{tuple,_,[M, F]},As}) ->
    pre_expand({call,L,{remote,L,M,F},As});
pre_expand(T)
    when is_tuple(T)->
    list_to_tuple(pre_expand(tuple_to_list(T)));
pre_expand([E| Es]) ->
    [pre_expand(E)| pre_expand(Es)];
pre_expand(T) ->
    T.

frames_to_columns([],_PatternVars,_DerefFun,_SelectorFun,_Imp,_CompOp) ->
    [];
frames_to_columns(Fs,PatternVars,DerefFun,SelectorFun,Imp,CompOp) ->
    SizesVarsL = [begin PatVar = {var,anno0(),PV},
    PatternSizes = [(pattern_size([F],PatVar,false)) || F <- Fs],
    MaxPZ = lists:max([0| PatternSizes -- [undefined]]),
    Vars = pat_vars(MaxPZ),
    {PatternId#qid.no,PatVar,PatternSizes,Vars} end || {PatternId,PV} <- PatternVars],
    BF = fun (_Op,Value)->
        is_bindable(Value) end,
    Fun = fun ({_PatN,PatVar,PatSizes,Vars},Frames)->
        [(unify('=:=',pat_tuple(Sz,Vars),PatVar,Frame,BF,Imp)) || {Sz,Frame} <- lists:zip(PatSizes,Frames)] end,
    NFs = lists:foldl(Fun,Fs,SizesVarsL),
    [(frames2cols(NFs,PatN,PatSizes,Vars,DerefFun,SelectorFun,CompOp)) || {PatN,_PatVar,PatSizes,Vars} <- SizesVarsL].

frames2cols(Fs,PatN,PatSizes,Vars,DerefFun,SelectorFun,CompOp) ->
    Rs = [begin RL = [{{PatN,Col},cons2tuple(element(2,Const))} || {V,Col} <- lists:zip(lists:sublist(Vars,PatSz),lists:seq(1,PatSz)),tl(Consts = DerefFun(V,F)) =:= [],(Const = (SelectorFun(F))(hd(Consts))) =/= no],
    sofs:relation(RL) end || {F,PatSz} <- lists:zip(Fs,PatSizes)],
    Ss = sofs:from_sets(Rs),
    D = sofs:intersection(sofs:projection(fun (S)->
        sofs:projection(1,S) end,Ss)),
    Cs = sofs:restriction(sofs:relation_to_family(sofs:union(Ss)),D),
    [C || {_,Vs} = C <- sofs:to_external(Cs), not col_ignore(Vs,CompOp)].

pat_vars(N) ->
    [(unique_var()) || _ <- lists:seq(1,N)].

pat_tuple(Sz,Vars)
    when is_integer(Sz),
    Sz > 0->
    TupleTail = unique_var(),
    {cons_tuple,list2cons(lists:sublist(Vars,Sz) ++ TupleTail)};
pat_tuple(_,_Vars) ->
    unique_var().

col_ignore(_Vs,'=:=') ->
    false;
col_ignore(Vs,'==') ->
    length(Vs) =/= length(lists:usort([(element(2,normalise(V))) || V <- Vs])).

pattern_sizes(PatternVars,Fs) ->
    [{QId#qid.no,Size} || {QId,PV} <- PatternVars,undefined =/= (Size = pattern_size(Fs,{var,anno0(),PV},true))].

pattern_size(Fs,PatternVar,Exact) ->
    Fun = fun (F)->
        (deref_pattern(_Imported = []))(PatternVar,F) end,
    Derefs = lists:flatmap(Fun,Fs),
    Szs = [(pattern_sz(Cs,0,Exact)) || {cons_tuple,Cs} <- Derefs],
    case lists:usort(Szs) of
        [Sz]
            when is_integer(Sz),
            Sz >= 0->
            Sz;
        []
            when  not Exact->
            0;
        _->
            undefined
    end.

pattern_sz({cons,_,_C,E},Col,Exact) ->
    pattern_sz(E,Col + 1,Exact);
pattern_sz({nil,_},Sz,_Exact) ->
    Sz;
pattern_sz(_,_Sz,true) ->
    undefined;
pattern_sz(_,Sz,false) ->
    Sz.

deref_pattern(Imported) ->
    fun (PV,F)->
        deref_values(PV,F,Imported) end.

prep_expr(E,F,S,BF,Imported) ->
    element_calls(tuple2cons(expand_expr_records(E,S)),F,BF,Imported).

unify_column(Frame,Var,Col,BindFun,Imported) ->
    A = anno0(),
    Call = {call,A,{remote,A,{atom,A,erlang},{atom,A,element}},[{integer,A,Col}, {var,A,Var}]},
    element_calls(Call,Frame,BindFun,Imported).

element_calls({call,_,{remote,_,{atom,_,erlang},{atom,_,element}},[{integer,_,I}, Term0]},F0,BF,Imported)
    when I > 0->
    TupleTail = unique_var(),
    VarsL = [(unique_var()) || _ <- lists:seq(1,I)],
    Vars = VarsL ++ TupleTail,
    Tuple = {cons_tuple,list2cons(Vars)},
    VarI = lists:nth(I,VarsL),
    {Term,F} = element_calls(Term0,F0,BF,Imported),
    {VarI,unify('=:=',Tuple,Term,F,BF,Imported)};
element_calls(T,F0,BF,Imported)
    when is_tuple(T)->
    {L,F} = element_calls(tuple_to_list(T),F0,BF,Imported),
    {list_to_tuple(L),F};
element_calls([E0| Es0],F0,BF,Imported) ->
    {E,F1} = element_calls(E0,F0,BF,Imported),
    {Es,F} = element_calls(Es0,F1,BF,Imported),
    {[E| Es],F};
element_calls(E,F,_BF,_Imported) ->
    {E,F}.

unique_var() ->
    {var,anno0(),make_ref()}.

is_unique_var({var,_L,V}) ->
    is_reference(V).

expand_pattern_records(P,State) ->
    A = anno0(),
    E = {'case',A,{atom,A,true},[{clause,A,[P],[],[{atom,A,true}]}]},
    {'case',_,_,[{clause,A,[NP],_,_}]} = expand_expr_records(E,State),
    NP.

expand_expr_records(E,State) ->
    RecordDefs = State#state.records,
    A = anno1(),
    Forms0 = RecordDefs ++ [{function,A,foo,0,[{clause,A,[],[],[pe(E)]}]}],
    Forms = erl_expand_records:module(Forms0,[no_strict_record_tests]),
    {function,_,foo,0,[{clause,_,[],[],[NE]}]} = lists:last(Forms),
    NE.

pe({op,Line,Op,A}) ->
    erl_eval:partial_eval({op,Line,Op,pe(A)});
pe({op,Line,Op,L,R}) ->
    erl_eval:partial_eval({op,Line,Op,pe(L),pe(R)});
pe(T)
    when is_tuple(T)->
    list_to_tuple(pe(tuple_to_list(T)));
pe([E| Es]) ->
    [pe(E)| pe(Es)];
pe(E) ->
    E.

unify(Op,E1,E2,F,BF,Imported) ->
    unify(Op,E1,E2,F,BF,Imported,false).

safe_unify(Op,E1,E2,F,BF,Imported) ->
    unify(Op,E1,E2,F,BF,Imported,true).

unify(_Op,_E1,_E2,failed,_BF,_Imported,_Safe) ->
    failed;
unify(_Op,E,E,F,_BF,_Imported,_Safe) ->
    F;
unify(Op,{var,_,_} = Var,E2,F,BF,Imported,Safe) ->
    extend_frame(Op,Var,E2,F,BF,Imported,Safe);
unify(Op,E1,{var,_,_} = Var,F,BF,Imported,Safe) ->
    extend_frame(Op,Var,E1,F,BF,Imported,Safe);
unify(Op,{cons_tuple,Es1},{cons_tuple,Es2},F,BF,Imported,Safe) ->
    unify(Op,Es1,Es2,F,BF,Imported,Safe);
unify(Op,{cons,_,L1,R1},{cons,_,L2,R2},F,BF,Imported,Safe) ->
    E = unify(Op,L1,L2,F,BF,Imported,Safe),
    unify(Op,R1,R2,E,BF,Imported,Safe);
unify(Op,E1,E2,F,_BF,_Imported,Safe) ->
    try {ok,C1} = normalise(E1),
    {ok,C2} = normalise(E2),
    if Op =:= '=:=',
    C1 =:= C2 ->
        F;Op =:= '==',
    C1 == C2 ->
        F;true ->
        failed end
        catch
            error:_
                when Safe->
                failed;
            error:_
                when  not Safe->
                F end.

-record(bind, {var,value,op}).

extend_frame(Op,Var,Value,F,BF,Imported,Safe) ->
    case var_values(Var,F) of
        []->
            case Value of
                {var,_,_}->
                    case var_values(Value,F) of
                        []->
                            add_binding(Op,Value,Var,F,BF,Imported,Safe);
                        ValsOps->
                            maybe_add_binding(ValsOps,Op,Value,Var,F,BF,Imported,Safe)
                    end;
                _->
                    add_binding(Op,Var,Value,F,BF,Imported,Safe)
            end;
        ValsOps->
            maybe_add_binding(ValsOps,Op,Var,Value,F,BF,Imported,Safe)
    end.

maybe_add_binding(ValsOps,Op,Var,Value,F0,BF,Imported,Safe) ->
    case unify_var_bindings(ValsOps,Op,Value,F0,BF,Imported,Safe) of
        failed->
            failed;
        F->
            case already_bound(Op,Var,Value,F) of
                true->
                    F;
                false->
                    add_binding(Op,Var,Value,F,BF,Imported,Safe)
            end
    end.

already_bound(Op,Var,Value,F) ->
    BFun = fun (_DV,BOp)->
        Op =:= BOp end,
    DerefValue = deref_value(Value,Op,F,BFun,all),
    DerefVar = deref_var(Var,F,BFun,all),
    DerefValue -- DerefVar =:= [].

unify_var_bindings([],_Op,_Value,F,_BF,_Imported,_Safe) ->
    F;
unify_var_bindings([{VarValue,Op2}| Bindings],Op1,Value,F0,BF,Imported,Safe) ->
    Op = deref_op(Op1,Op2),
    case unify(Op,VarValue,Value,F0,BF,Imported,Safe) of
        failed->
            failed;
        F->
            unify_var_bindings(Bindings,Op1,Value,F,BF,Imported,Safe)
    end.

deref_op('=:=','=:=') ->
    '=:=';
deref_op(_,_) ->
    '=='.

var_values(Var,Frame) ->
    [{Value,Op} || #bind{value = Value,op = Op} <- var_bindings(Var,Frame)].

deref_var(Var,Frame,Imported) ->
    deref_var(Var,Frame,fun (_DV,_Op)->
        true end,Imported).

deref_var(Var,Frame,BFun,Imported) ->
    lists:usort([ValOp || #bind{value = Value,op = Op} <- var_bindings(Var,Frame),ValOp <- deref_value(Value,Op,Frame,BFun,Imported)]).

deref_value(Value,Op,Frame,BFun,Imported) ->
    lists:usort([{Val,value_op(ValOp,Op,Imported)} || {Val,_Op} = ValOp <- deref(Value,Frame,BFun,Imported)]).

add_binding(Op,Var0,Value0,F,BF,Imported,Safe) ->
    {Var,Value} = maybe_swap_var_value(Var0,Value0,F,Imported),
    case BF(Op,Value) of
        true->
            add_binding2(Var,Value,Op,F);
        false
            when Safe->
            failed;
        false
            when  not Safe->
            F
    end.

add_binding2(Var,Value,Op,F) ->
    case occurs(Var,Value,F) of
        true->
            failed;
        false->
            [#bind{var = Var,value = Value,op = Op}| F]
    end.

maybe_swap_var_value(Var,Value,Frame,Imported) ->
    case do_swap_var_value(Var,Value,Frame,Imported) of
        true->
            {Value,Var};
        false->
            {Var,Value}
    end.

do_swap_var_value({var,_,V1} = Var1,{var,_,V2} = Var2,F,Imported) ->
    case swap_vv(Var1,Var2,F) of
        []->
            case swap_vv(Var2,Var1,F) of
                []->
                    ordsets:is_element(V1,Imported) andalso  not ordsets:is_element(V2,Imported);
                _Bs->
                    true
            end;
        _Bs->
            false
    end;
do_swap_var_value(_,_,_F,_Imp) ->
    false.

swap_vv(V1,V2,F) ->
    [V || #bind{value = V} <- var_bindings(V1,F),V =:= V2].

normalise(E) ->
    case  catch erl_parse:normalise(var2const(cons2tuple(E))) of
        {'EXIT',_}->
            not_ok;
        C->
            {ok,C}
    end.

occurs(V,V,_F) ->
    true;
occurs(V,{var,_,_} = Var,F) ->
    lists:any(fun (B)->
        occurs(V,B#bind.value,F) end,var_bindings(Var,F));
occurs(V,T,F)
    when is_tuple(T)->
    lists:any(fun (E)->
        occurs(V,E,F) end,tuple_to_list(T));
occurs(V,[E| Es],F) ->
    occurs(V,E,F) orelse occurs(V,Es,F);
occurs(_V,_E,_F) ->
    false.

deref_values(E,Frame,Imported) ->
    deref_values(E,Frame,fun (_DV,_Op)->
        true end,Imported).

deref_values(E,Frame,BFun,Imported) ->
    lists:usort([V || {V,Op} <- deref(E,Frame,BFun,Imported),BFun(V,Op)]).

deref(E,F,Imp) ->
    BFun = fun (_DV,_Op)->
        true end,
    deref(E,F,BFun,Imp).

deref({var,_,_} = V,F,BFun,Imp) ->
    DBs = lists:flatmap(fun (B)->
        deref_binding(B,F,BFun,Imp) end,var_bindings(V,F)),
    case DBs of
        []->
            [{V,'=:='}];
        _->
            lists:usort(DBs)
    end;
deref(T,F,BFun,Imp)
    when is_tuple(T)->
    [{list_to_tuple(DL),Op} || {DL,Op} <- deref(tuple_to_list(T),F,BFun,Imp)];
deref(Es,F,BFun,Imp)
    when is_list(Es)->
    L = [(deref(C,F,BFun,Imp)) || C <- Es],
    lists:usort([(deref_list(S)) || S <- all_comb(L)]);
deref(E,_F,_BFun,_Imp) ->
    [{E,'=:='}].

var_bindings(Var,F) ->
    [B || #bind{var = V} = B <- F,V =:= Var].

deref_binding(Bind,Frame,BFun,Imp) ->
    #bind{value = Value,op = Op0} = Bind,
    [{Val,Op} || {Val,_Op} = ValOp <- deref(Value,Frame,BFun,Imp),BFun(Val,Op = value_op(ValOp,Op0,Imp))].

deref_list(L) ->
    Op = case lists:usort([Op || {_Val,Op} <- L]) of
        ['=:=']->
            '=:=';
        _->
            '=='
    end,
    {[V || {V,_Op} <- L],Op}.

value_op({_V,'=='},_BindOp,_Imp) ->
    '==';
value_op({_V,'=:='},_BindOp = '=:=',_Imp) ->
    '=:=';
value_op({V,'=:='},_BindOp = '==',Imp) ->
    case free_of_integers(V,Imp) of
        true->
            '=:=';
        false->
            '=='
    end.

all_comb([]) ->
    [[]];
all_comb([Cs| ICs]) ->
    [[C| L] || C <- Cs,L <- all_comb(ICs)].

free_of_integers(V,Imported) ->
     not has_integer(V) andalso  not has_imported_vars(V,Imported).

has_imported_vars(Value,all) ->
    qlc:vars(Value) =/= [];
has_imported_vars(Value,Imported) ->
    [Var || Var <- qlc:vars(Value),lists:member(Var,Imported)] =/= [].

has_integer(Abstr) ->
    try has_int(Abstr)
        catch
            throw:true->
                true end.

has_int({integer,_,I})
    when float(I) == I->
    throw(true);
has_int({float,_,F})
    when round(F) == F->
    throw(true);
has_int(T)
    when is_tuple(T)->
    has_int(tuple_to_list(T));
has_int([E| Es]) ->
    has_int(E),
    has_int(Es);
has_int(_) ->
    false.

tuple2cons({tuple,_,Es}) ->
    {cons_tuple,list2cons(tuple2cons(Es))};
tuple2cons(T)
    when is_tuple(T)->
    list_to_tuple(tuple2cons(tuple_to_list(T)));
tuple2cons([E| Es]) ->
    [tuple2cons(E)| tuple2cons(Es)];
tuple2cons(E) ->
    E.

list2cons([E| Es]) ->
    {cons,anno0(),E,list2cons(Es)};
list2cons([]) ->
    {nil,anno0()};
list2cons(E) ->
    E.

cons2tuple({cons_tuple,Es}) ->
    {tuple,anno0(),cons2list(Es)};
cons2tuple(T)
    when is_tuple(T)->
    list_to_tuple(cons2tuple(tuple_to_list(T)));
cons2tuple([E| Es]) ->
    [cons2tuple(E)| cons2tuple(Es)];
cons2tuple(E) ->
    E.

cons2list({cons,_,L,R}) ->
    [cons2tuple(L)| cons2list(R)];
cons2list({nil,_}) ->
    [];
cons2list(E) ->
    [cons2tuple(E)].

bindings_is_subset(F1,F2,Imported) ->
    BF = fun (_Op,_Value)->
        true end,
    F = lists:foldl(fun (#bind{var = V,value = Value,op = Op},Frame)->
        unify(Op,V,Value,Frame,BF,Imported) end,F2,F1),
    bindings_subset(F,F2,Imported) andalso bindings_subset(F2,F,Imported).

bindings_subset(F1,F2,Imp) ->
    Vars = lists:usort([V || #bind{var = V} <- F1, not is_unique_var(V)]),
    lists:all(fun (V)->
        deref_var(V,F1,Imp) =:= deref_var(V,F2,Imp) end,Vars).

try_ms(E,P,Fltr,State) ->
    L = anno1(),
    Fun = {'fun',L,{clauses,[{clause,L,[P],[[Fltr]],[E]}]}},
    Expr = {call,L,{remote,L,{atom,L,ets},{atom,L,fun2ms}},[Fun]},
    Form = {function,L,foo,0,[{clause,L,[],[],[Expr]}]},
    X = ms_transform:parse_transform(State#state.records ++ [Form],[]),
    case  catch begin {function,L,foo,0,[{clause,L,[],[],[MS0]}]} = lists:last(X),
    MS = erl_parse:normalise(var2const(MS0)),
    XMS = ets:match_spec_compile(MS),
    true = ets:is_compiled_ms(XMS),
    {ok,MS,MS0} end of
        {'EXIT',_Reason}->
            no;
        Reply->
            Reply
    end.

filters_as_one([]) ->
    {atom,anno0(),true};
filters_as_one(FilterData) ->
    [{_,{fil,Filter1}}| Filters] = lists:reverse(FilterData),
    lists:foldr(fun ({_QId,{fil,Filter}},AbstF)->
        {op,anno0(),'andalso',Filter,AbstF} end,Filter1,Filters).

qual_data(Qualifiers) ->
    F = fun (T)->
        [{QId,Q} || {QId,_,_,Q} <- Qualifiers,element(1,Q) =:= T] end,
    {F(fil),F(gen)}.

set_field(Pos,Fs,Data) ->
    lists:sublist(Fs,Pos - 1) ++ [Data] ++ lists:nthtail(Pos,Fs).

qdata([{#qid{no = QIdNo},{_QIVs,{{gen,_P,LE,_GV},GoI,SI}}}| QCs],L) ->
    Init = case LE of
        {join,Op,Q1,Q2,H1,H2,Cs1_0,Cs2_0}->
            Cs1 = qcon(Cs1_0),
            Cs2 = qcon(Cs2_0),
            Compat = {atom,L,v1},
            CF = closure({tuple,L,[Cs1, Cs2, Compat]},L),
            {tuple,L,[{atom,L,join}, {atom,L,Op}, {integer,L,Q1}, {integer,L,Q2}, H1, H2, CF]};
        _->
            closure(LE,L)
    end,
    {cons,L,{tuple,L,[{integer,L,QIdNo}, {integer,L,GoI}, {integer,L,SI}, {tuple,L,[{atom,L,gen}, Init]}]},qdata(QCs,L)};
qdata([{#qid{no = QIdNo},{_QIVs,{{fil,_F},GoI,SI}}}| QCs],L) ->
    {cons,L,{tuple,L,[{integer,L,QIdNo}, {integer,L,GoI}, {integer,L,SI}, {atom,L,fil}]},qdata(QCs,L)};
qdata([],L) ->
    {nil,L}.

qcon(Cs) ->
    A = anno0(),
    list2cons([{tuple,A,[{integer,A,Col}, list2cons(qcon1(ConstOps))]} || {Col,ConstOps} <- Cs]).

qcon1(ConstOps) ->
    A = anno0(),
    [{tuple,A,[Const, abstr(Op,A)]} || {Const,Op} <- ConstOps].

qcode(E,QCs,Source,L,State) ->
    CL = [begin Bin = term_to_binary(C,[compressed]),
    {bin,L,[{bin_element,L,{string,L,binary_to_list(Bin)},default,default}]} end || {_,C} <- lists:keysort(1,[{qlc:template_state(),E}| qcode(QCs,Source,State)])],
    {'fun',L,{clauses,[{clause,L,[],[],[{tuple,L,CL}]}]}}.

qcode([{_QId,{_QIvs,{{gen,P,_LE,_GV},GoI,_SI}}}| QCs],Source,State) ->
    [{GoI,undo_no_shadows(P,State)}| qcode(QCs,Source,State)];
qcode([{QId,{_QIVs,{{fil,_F},GoI,_SI}}}| QCs],Source,State) ->
    OrigF = map_get(QId,Source),
    [{GoI,undo_no_shadows(OrigF,State)}| qcode(QCs,Source,State)];
qcode([],_Source,_State) ->
    [].

closure(Code,L) ->
    {'fun',L,{clauses,[{clause,L,[],[],[Code]}]}}.

simple(L,Var,Init,Anno) ->
    {tuple,L,[{atom,L,simple_v1}, {atom,L,Var}, Init, abstr(loc(Anno),Anno)]}.

clauses([{QId,{QIVs,{QualData,GoI,S}}}| QCs],RL,Fun,Go,NGV,E,IVs,St) ->
    ok,
    ok,
    ok,
    L = no_compiler_warning(get_lcid_line(QId#qid.lcid)),
    Cs = case QualData of
        {gen,P,_LE,GV}->
            generator(S,QIVs,P,GV,NGV,E,IVs,RL,Fun,Go,GoI,L,St);
        {fil,F}->
            filter(F,L,QIVs,S,RL,Fun,Go,GoI,IVs,St)
    end,
    Cs ++ clauses(QCs,RL,Fun,Go,NGV,E,IVs,St);
clauses([],_RL,_Fun,_Go,_NGV,_IVs,_E,_St) ->
    [].

final(RL,IVs,L,State) ->
    IAs = replace(IVs,IVs,_),
    AsL = pack_args([{integer,L,0}| abst_vars([RL, _, _] ++ IAs,L)],L,State),
    Grd = [is_list_c(RL,L)],
    Rev = {call,L,{remote,L,{atom,L,lists},{atom,L,reverse}},[{var,L,RL}]},
    CL = {clause,L,AsL,[Grd],[Rev]},
    AsF = pack_args([{integer,L,0}| abst_vars([_, _, _] ++ IAs,L)],L,State),
    CF = {clause,L,AsF,[],[{nil,L}]},
    [CL, CF].

template(E,RL,Fun,Go,AT,L,IVs,State) ->
    I = qlc:template_state(),
    GoI = qlc:template_state(),
    ARL = {cons,L,E,abst_vars(RL,L)},
    Next = next(Go,GoI,L),
    As0 = abst_vars([RL, Fun, Go] ++ IVs,L),
    As = pack_args([{integer,L,I}| As0],L,State),
    NAs = pack_args([Next, ARL] ++ abst_vars([Fun, Go] ++ IVs,L),L,State),
    Grd = [is_list_c(RL,L)],
    CL = {clause,L,As,[Grd],[{call,L,{var,L,Fun},NAs}]},
    F = case split_args([Next| As0],L,State) of
        {ArgsL,ArgsT}->
            Call = {call,L,{var,L,Fun},ArgsL ++ [{var,L,AT}]},
            {block,L,[{match,L,{var,L,AT},ArgsT}, {'fun',L,{clauses,[{clause,L,[],[],[Call]}]}}]};
        FNAs->
            {'fun',L,{clauses,[{clause,L,[],[],[{call,L,{var,L,Fun},FNAs}]}]}}
    end,
    CF = {clause,L,As,[],[{cons,L,E,F}]},
    [CL, CF].

generator(S,QIVs,P,GV,NGV,E,IVs,RL,Fun,Go,GoI,L,State) ->
    ComAs = abst_vars([RL, Fun, Go],L),
    InitC = generator_init(S,L,GV,RL,Fun,Go,GoI,IVs,State),
    As = [{integer,L,S + 1}| ComAs ++ abst_vars(replace(QIVs -- [GV],IVs,_),L)],
    MatchS = next(Go,GoI + 1,L),
    AsM0 = [MatchS| ComAs ++ abst_vars(replace([GV],IVs,NGV),L)],
    AsM = pack_args(AsM0,L,State),
    ContS = {integer,L,S + 1},
    QIVs__GV = QIVs -- [GV],
    Tmp = replace([GV],replace(QIVs__GV,IVs,nil),NGV),
    AsC = pack_args([ContS| ComAs ++ abst_vars(Tmp,L)],L,State),
    DoneS = next(Go,GoI,L),
    AsD0 = [DoneS| ComAs ++ abst_vars(replace(QIVs,IVs,nil),L)],
    AsD = pack_args(AsD0,L,State),
    CsL = generator_list(P,GV,NGV,As,AsM,AsC,AsD,Fun,L,State),
    CsF = generator_cont(P,GV,NGV,E,As,AsM,AsC,AsD,Fun,L,State),
    [InitC| CsL ++ CsF].

generator_init(S,L,GV,RL,Fun,Go,GoI,IVs,State) ->
    As0 = abst_vars([RL, Fun, Go] ++ replace([GV],IVs,_),L),
    As = pack_args([{integer,L,S}| As0],L,State),
    Next = next(Go,GoI + 2,L),
    NAs = pack_args([{integer,L,S + 1}| replace([{var,L,_}],As0,Next)],L,State),
    {clause,L,As,[],[{call,L,{var,L,Fun},NAs}]}.

generator_list(P,GV,NGV,As,AsM,AsC,AsD,Fun,L,State) ->
    As1 = pack_args(replace([{var,L,GV}],As,{cons,L,P,{var,L,NGV}}),L,State),
    As2 = pack_args(replace([{var,L,GV}],As,{cons,L,{var,L,_},{var,L,NGV}}),L,State),
    As3 = pack_args(replace([{var,L,GV}],As,{nil,L}),L,State),
    CM = {clause,L,As1,[],[{call,L,{var,L,Fun},AsM}]},
    CC = {clause,L,As2,[],[{call,L,{var,L,Fun},AsC}]},
    CD = {clause,L,As3,[],[{call,L,{var,L,Fun},AsD}]},
    [CM, CC, CD].

generator_cont(P,GV,NGV,E,As0,AsM,AsC,AsD,Fun,L,State) ->
    As = pack_args(As0,L,State),
    CF1 = {cons,L,P,{var,L,NGV}},
    CF2 = {cons,L,{var,L,_},{var,L,NGV}},
    CF3 = {nil,L},
    CF4 = {var,L,E},
    CM = {clause,L,[CF1],[],[{call,L,{var,L,Fun},AsM}]},
    CC = {clause,L,[CF2],[],[{call,L,{var,L,Fun},AsC}]},
    CD = {clause,L,[CF3],[],[{call,L,{var,L,Fun},AsD}]},
    CE = {clause,L,[CF4],[],[CF4]},
    Cls = [CM, CC, CD, CE],
    B = {'case',L,{call,L,{var,L,GV},[]},Cls},
    [{clause,L,As,[],[B]}].

filter(E,L,QIVs,S,RL,Fun,Go,GoI,IVs,State) ->
    IAs = replace(QIVs,IVs,_),
    As = pack_args([{integer,L,S}| abst_vars([RL, Fun, Go] ++ IAs,L)],L,State),
    NAs = abst_vars([RL, Fun, Go] ++ IVs,L),
    TNext = next(Go,GoI + 1,L),
    FNext = next(Go,GoI,L),
    NAsT = pack_args([TNext| NAs],L,State),
    NAsF = pack_args([FNext| NAs],L,State),
    Body = case is_guard_test(E,State) of
        true->
            CT = {clause,L,[],[[E]],[{call,L,{var,L,Fun},NAsT}]},
            CF = {clause,L,[],[[{atom,L,true}]],[{call,L,{var,L,Fun},NAsF}]},
            [{'if',L,[CT, CF]}];
        false->
            CT = {clause,L,[{atom,L,true}],[],[{call,L,{var,L,Fun},NAsT}]},
            CF = {clause,L,[{atom,L,false}],[],[{call,L,{var,L,Fun},NAsF}]},
            [{'case',L,E,[CT, CF]}]
    end,
    [{clause,L,As,[],Body}].

pack_args(Args,L,State) ->
    case split_args(Args,L,State) of
        {ArgsL,ArgsT}->
            ArgsL ++ [ArgsT];
        _->
            Args
    end.

split_args(Args,L,State)
    when length(Args) > State#state.maxargs->
    {lists:sublist(Args,State#state.maxargs - 1),{tuple,L,lists:nthtail(State#state.maxargs - 1,Args)}};
split_args(Args,_L,_State) ->
    Args.

replace(Es,IEs,R) ->
    [case lists:member(E,Es) of
        true->
            R;
        false->
            E
    end || E <- IEs].

is_list_c(V,L) ->
    {call,L,{atom,L,is_list},[{var,L,V}]}.

next(Go,GoI,L) ->
    {call,L,{atom,L,element},[{integer,L,GoI}, {var,L,Go}]}.

aux_vars(Vars,LcN,AllVars) ->
    [(aux_var(Name,LcN,0,1,AllVars)) || Name <- Vars].

aux_var(Name,LcN,QN,N,AllVars) ->
    qlc:aux_name(lists:concat([Name, LcN, _, QN, _]),N,AllVars).

no_compiler_warning(L) ->
    Anno = erl_anno:new(L),
    erl_anno:set_generated(true,Anno).

loc(A) ->
    erl_anno:location(A).

list2op([E],_Op) ->
    E;
list2op([E| Es],Op) ->
    {op,anno0(),Op,E,list2op(Es,Op)}.

anno0() ->
    erl_anno:new(0).

anno1() ->
    erl_anno:new(1).

qual_fold(Fun,GlobAcc0,Acc0,Forms,State) ->
    F = fun (Id,{lc,L,E,Qs0},GA0)->
        {Qs,GA,_NA} = qual_fold(Qs0,Fun,GA0,Acc0,Id,1,[]),
        {{lc,L,E,Qs},GA};(_Id,Expr,GA)->
        {Expr,GA} end,
    qlc_mapfold(F,GlobAcc0,Forms,State).

qual_fold([Q0| Qs],F,GA0,A0,Id,No,NQs) ->
    QId = qid(Id,No),
    {Q,GA,A} = F(QId,Q0,GA0,A0),
    qual_fold(Qs,F,GA,A,Id,No + 1,[Q| NQs]);
qual_fold([],_F,GA,A,_Id,_No,NQs) ->
    {lists:reverse(NQs),GA,A}.

qlc_mapfold(Fun,Acc0,Forms0,State) ->
    {Forms,A,_NNo} = qlcmf(Forms0,Fun,State#state.imp,Acc0,1),
    erase(qlc_current_file),
    {Forms,A}.

qlcmf([E0| Es0],F,Imp,A0,No0) ->
    {E,A1,No1} = qlcmf(E0,F,Imp,A0,No0),
    {Es,A,No} = qlcmf(Es0,F,Imp,A1,No1),
    {[E| Es],A,No};
qlcmf({call,L1,{remote,L2,{atom,L3,qlc},{atom,L4,q}},[LC0| Os0]},F,Imp,A0,No0)
    when length(Os0) < 2->
    {Os,A1,No1} = qlcmf(Os0,F,Imp,A0,No0),
    {LC,A2,No} = qlcmf(LC0,F,Imp,A1,No1),
    NL = make_lcid(L1,No),
    {T,A} = F(NL,LC,A2),
    {{call,L1,{remote,L2,{atom,L3,qlc},{atom,L4,q}},[T| Os]},A,No + 1};
qlcmf({call,L,{atom,L2,q},[LC0| Os0]},F,Imp = true,A0,No0)
    when length(Os0) < 2->
    {Os,A1,No1} = qlcmf(Os0,F,Imp,A0,No0),
    {LC,A2,No} = qlcmf(LC0,F,Imp,A1,No1),
    NL = make_lcid(L,No),
    {T,A} = F(NL,LC,A2),
    {{call,L,{atom,L2,q},[T| Os]},A,No + 1};
qlcmf({attribute,_L,file,{File,_Line}} = Attr,_F,_Imp,A,No) ->
    put(qlc_current_file,File),
    {Attr,A,No};
qlcmf(T,F,Imp,A0,No0)
    when is_tuple(T)->
    {TL,A,No} = qlcmf(tuple_to_list(T),F,Imp,A0,No0),
    {list_to_tuple(TL),A,No};
qlcmf(T,_F,_Imp,A,No) ->
    {T,A,No}.

occ_vars(E) ->
    qlc:var_fold(fun ({var,_L,V})->
        V end,[],E).

save_anno(Abstr,NodeInfo) ->
    F = fun (Anno)->
        N = next_slot(NodeInfo),
        Location = erl_anno:location(Anno),
        Data = {N,#{location=>Location}},
        true = ets:insert(NodeInfo,Data),
        erl_anno:new(N) end,
    map_anno(F,Abstr).

next_slot(T) ->
    I = ets:update_counter(T,var_n,1),
    case ets:lookup(T,I) of
        []->
            I;
        _->
            next_slot(T)
    end.

restore_anno(Abstr,NodeInfo) ->
    F = fun (Anno)->
        Location = erl_anno:location(Anno),
        case ets:lookup(NodeInfo,Location) of
            [{Location,Data}]->
                OrigLocation = maps:get(location,Data),
                erl_anno:set_location(OrigLocation,Anno);
            [{Location}]->
                Anno;
            []->
                Anno
        end end,
    map_anno(F,Abstr).

restore_loc(Location,#state{node_info = NodeInfo}) ->
    case ets:lookup(NodeInfo,Location) of
        [{Location,#{location:=OrigLocation}}]->
            OrigLocation;
        [{Location}]->
            Location;
        []->
            Location
    end.

no_shadows(Forms0,State) ->
    AllVars = gb_sets:from_list(ordsets:to_list(qlc:vars(Forms0))),
    ok,
    VFun = fun (_Id,LC,Vs)->
        nos(LC,Vs) end,
    LI = ets:new(qlc,[]),
    UV = ets:new(qlc,[]),
    D0 = maps:new(),
    S1 = {LI,D0,UV,AllVars,[],State},
    _ = qlc_mapfold(VFun,S1,Forms0,State),
    ok,
    Singletons = ets:select(UV,[{{'$1',0},[],['$1']}]),
    ok,
    true = ets:delete_all_objects(LI),
    true = ets:delete_all_objects(UV),
    S2 = {LI,D0,UV,AllVars,Singletons,State},
    {Forms,_} = qlc_mapfold(VFun,S2,Forms0,State),
    true = ets:delete(LI),
    true = ets:delete(UV),
    Forms.

nos([E0| Es0],S0) ->
    {E,S1} = nos(E0,S0),
    {Es,S} = nos(Es0,S1),
    {[E| Es],S};
nos({'fun',L,{clauses,Cs}},S) ->
    NCs = [begin {H,S1} = nos_pattern(H0,S),
    {[G, B],_} = nos([G0, B0],S1),
    {clause,Ln,H,G,B} end || {clause,Ln,H0,G0,B0} <- Cs],
    {{'fun',L,{clauses,NCs}},S};
nos({named_fun,Loc,Name,Cs},S) ->
    {{var,NLoc,NName},S1} = case Name of
        _->
            S;
        Name->
            nos_pattern({var,Loc,Name},S)
    end,
    NCs = [begin {H,S2} = nos_pattern(H0,S1),
    {[G, B],_} = nos([G0, B0],S2),
    {clause,CLoc,H,G,B} end || {clause,CLoc,H0,G0,B0} <- Cs],
    {{named_fun,NLoc,NName,NCs},S};
nos({lc,L,E0,Qs0},S) ->
    F = fun ({T,Ln,P0,LE0},QS0)
        when T =:= b_generate;
        T =:= generate->
        {LE,_} = nos(LE0,QS0),
        {P,QS} = nos_pattern(P0,QS0),
        {{T,Ln,P,LE},QS};(Filter,QS)->
        nos(Filter,QS) end,
    {Qs,S1} = lists:mapfoldl(F,S,Qs0),
    {E,_} = nos(E0,S1),
    {{lc,L,E,Qs},S};
nos({var,L,V} = Var,{_LI,Vs,UV,_A,_Sg,State} = S)
    when V =/= _->
    case used_var(V,Vs,UV) of
        {true,VN}->
            nos_var(L,V,State),
            {{var,L,VN},S};
        false->
            {Var,S}
    end;
nos(T,S0)
    when is_tuple(T)->
    {TL,S} = nos(tuple_to_list(T),S0),
    {list_to_tuple(TL),S};
nos(T,S) ->
    {T,S}.

nos_pattern(P,S) ->
    {T,NS,_} = nos_pattern(P,S,[]),
    {T,NS}.

nos_pattern([P0| Ps0],S0,PVs0) ->
    {P,S1,PVs1} = nos_pattern(P0,S0,PVs0),
    {Ps,S,PVs} = nos_pattern(Ps0,S1,PVs1),
    {[P| Ps],S,PVs};
nos_pattern({var,L,V},{LI,Vs0,UV,A,Sg,State},PVs0)
    when V =/= _->
    {Name,Vs,PVs} = case lists:keyfind(V,1,PVs0) of
        {V,VN}->
            _ = used_var(V,Vs0,UV),
            {VN,Vs0,PVs0};
        false->
            {VN,Vs1} = next_var(V,Vs0,A,LI,UV),
            N = case lists:member(VN,Sg) of
                true->
                    _;
                false->
                    VN
            end,
            {N,Vs1,[{V,VN}| PVs0]}
    end,
    nos_var(L,V,State),
    {{var,L,Name},{LI,Vs,UV,A,Sg,State},PVs};
nos_pattern(T,S0,PVs0)
    when is_tuple(T)->
    {TL,S,PVs} = nos_pattern(tuple_to_list(T),S0,PVs0),
    {list_to_tuple(TL),S,PVs};
nos_pattern(T,S,PVs) ->
    {T,S,PVs}.

nos_var(Anno,Name,State) ->
    NodeInfo = State#state.node_info,
    Location = erl_anno:location(Anno),
    case ets:lookup(NodeInfo,Location) of
        [{Location,#{name:=_}}]->
            true;
        [{Location,Data}]->
            true = ets:insert(NodeInfo,{Location,Data#{name=>Name}});
        []->
            true
    end.

used_var(V,Vs,UV) ->
    case maps:find(V,Vs) of
        {ok,Value}->
            VN = qlc:name_suffix(V,Value),
            _ = ets:update_counter(UV,VN,1),
            {true,VN};
        error->
            false
    end.

next_var(V,Vs,AllVars,LI,UV) ->
    NValue = case ets:lookup(LI,V) of
        [{V,Value}]->
            Value + 1;
        []->
            1
    end,
    true = ets:insert(LI,{V,NValue}),
    VN = qlc:name_suffix(V,NValue),
    case gb_sets:is_member(VN,AllVars) of
        true->
            next_var(V,Vs,AllVars,LI,UV);
        false->
            true = ets:insert(UV,{VN,0}),
            NVs = maps:put(V,NValue,Vs),
            {VN,NVs}
    end.

undo_no_shadows(E,State) ->
    var_map(fun (Anno)->
        undo_no_shadows1(Anno,State) end,E).

undo_no_shadows1({var,Anno,_} = Var,State) ->
    Location = erl_anno:location(Anno),
    NodeInfo = State#state.node_info,
    case ets:lookup(NodeInfo,Location) of
        [{Location,#{name:=Name}}]->
            {var,Anno,Name};
        _->
            Var
    end.

make_lcid(Anno,No)
    when is_integer(No),
    No > 0->
    {No,erl_anno:line(Anno)}.

get_lcid_no({No,_Line}) ->
    No.

get_lcid_line({_No,Line}) ->
    Line.

qid(LCId,No) ->
    #qid{no = No,lcid = LCId}.

abst_vars([V| Vs],L) ->
    [abst_vars(V,L)| abst_vars(Vs,L)];
abst_vars([],_L) ->
    [];
abst_vars(nil,L) ->
    {nil,L};
abst_vars(V,L) ->
    {var,L,V}.

embed_vars(Vars,L) ->
    embed_expr({tuple,L,Vars},L).

embed_expr(Expr,L) ->
    {lc,L,Expr,[{generate,L,{var,L,_},{nil,L}}]}.

var2const(E) ->
    var_map(fun ({var,L,V})->
        {atom,L,V} end,E).

var_map(F,{var,_,_} = V) ->
    F(V);
var_map(F,{named_fun,NLoc,NName,Cs}) ->
    {var,Loc,Name} = F({var,NLoc,NName}),
    {named_fun,Loc,Name,var_map(F,Cs)};
var_map(F,T)
    when is_tuple(T)->
    list_to_tuple(var_map(F,tuple_to_list(T)));
var_map(F,[E| Es]) ->
    [var_map(F,E)| var_map(F,Es)];
var_map(_F,E) ->
    E.

var_mapfold(F,A,{var,_,_} = V) ->
    F(V,A);
var_mapfold(F,A0,T)
    when is_tuple(T)->
    {L,A} = var_mapfold(F,A0,tuple_to_list(T)),
    {list_to_tuple(L),A};
var_mapfold(F,A0,[E0| Es0]) ->
    {E,A1} = var_mapfold(F,A0,E0),
    {Es,A} = var_mapfold(F,A1,Es0),
    {[E| Es],A};
var_mapfold(_F,A,E) ->
    {E,A}.

map_anno(F,AbstrList)
    when is_list(AbstrList)->
    [(map_anno1(F,Abstr)) || Abstr <- AbstrList];
map_anno(F,Abstr) ->
    map_anno1(F,Abstr).

map_anno1(F,Abstr) ->
    erl_parse:map_anno(F,Abstr).

family_list(L) ->
    sofs:to_external(family(L)).

family(L) ->
    sofs:relation_to_family(sofs:relation(L)).

is_guard_test(E,#state{records = RDs,overridden = IsOverridden}) ->
    erl_lint:is_guard_test(E,RDs,IsOverridden).

set_up_overridden(Forms) ->
    Locals = [{Name,Arity} || {function,_,Name,Arity,_} <- Forms],
    Imports0 = [Fs || {attribute,_,import,Fs} <- Forms],
    Imports1 = lists:flatten(Imports0),
    Imports2 = [Fs || {_,Fs} <- Imports1],
    Imports = lists:flatten(Imports2),
    Overridden = gb_sets:from_list(Imports ++ Locals),
    fun (FA)->
        gb_sets:is_element(FA,Overridden) end.

display_forms(_) ->
    ok.
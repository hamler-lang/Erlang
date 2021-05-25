-file("dialyzer_dep.erl", 1).

-module(dialyzer_dep).

-export([analyze/1]).

-file("dialyzer.hrl", 1).

-type(dial_ret()::0|1|2).

-type(dial_warn_tag()::warn_return_no_exit|warn_return_only_exit|warn_not_called|warn_non_proper_list|warn_matching|warn_opaque|warn_fun_app|warn_failing_call|warn_bin_construction|warn_contract_types|warn_contract_syntax|warn_contract_not_equal|warn_contract_subtype|warn_contract_supertype|warn_callgraph|warn_umatched_return|warn_race_condition|warn_behaviour|warn_contract_range|warn_undefined_callbacks|warn_unknown|warn_map_construction).

-type(file_line()::{file:filename(),non_neg_integer()}).

-type(dial_warning()::{dial_warn_tag(),file_line(),{atom(),[term()]}}).

-type(m_or_mfa()::module()|mfa()).

-type(warning_info()::{file:filename(),non_neg_integer(),m_or_mfa()}).

-type(raw_warning()::{dial_warn_tag(),warning_info(),{atom(),[term()]}}).

-type(dial_error()::any()).

-type(anal_type()::succ_typings|plt_build).

-type(anal_type1()::anal_type()|plt_add|plt_check|plt_remove).

-type(contr_constr()::{subtype,erl_types:erl_type(),erl_types:erl_type()}).

-type(contract_pair()::{erl_types:erl_type(),[contr_constr()]}).

-type(dial_define()::{atom(),term()}).

-type(dial_option()::{atom(),term()}).

-type(dial_options()::[dial_option()]).

-type(fopt()::basename|fullpath).

-type(format()::formatted|raw).

-type(iopt()::boolean()).

-type(label()::non_neg_integer()).

-type(dial_warn_tags()::ordsets:ordset(dial_warn_tag())).

-type(rep_mode()::quiet|normal|verbose).

-type(start_from()::byte_code|src_code).

-type(mfa_or_funlbl()::label()|mfa()).

-type(solver()::v1|v2).

-type(doc_plt()::undefined|dialyzer_plt:plt()).

-record(analysis,{analysis_pid::pid()|undefined,type = succ_typings::anal_type(),defines = []::[dial_define()],doc_plt::doc_plt(),files = []::[file:filename()],include_dirs = []::[file:filename()],start_from = byte_code::start_from(),plt::dialyzer_plt:plt(),use_contracts = true::boolean(),race_detection = false::boolean(),behaviours_chk = false::boolean(),timing = false::boolean()|debug,timing_server = none::dialyzer_timing:timing_server(),callgraph_file = ""::file:filename(),solvers::[solver()]}).

-record(options,{files = []::[file:filename()],files_rec = []::[file:filename()],analysis_type = succ_typings::anal_type1(),timing = false::boolean()|debug,defines = []::[dial_define()],from = byte_code::start_from(),get_warnings = maybe::boolean()|maybe,init_plts = []::[file:filename()],include_dirs = []::[file:filename()],output_plt = none::none|file:filename(),legal_warnings = ordsets:new()::dial_warn_tags(),report_mode = normal::rep_mode(),erlang_mode = false::boolean(),use_contracts = true::boolean(),output_file = none::none|file:filename(),output_format = formatted::format(),filename_opt = basename::fopt(),indent_opt = true::iopt(),callgraph_file = ""::file:filename(),check_plt = true::boolean(),solvers = []::[solver()],native = maybe::boolean()|maybe,native_cache = true::boolean()}).

-record(contract,{contracts = []::[contract_pair()],args = []::[erl_types:erl_type()],forms = []::[{_,_}]}).

-file("dialyzer_dep.erl", 33).

-type(dep_ordset()::ordsets:ordset(label()|external)).

-type(deps()::dict:dict(label()|external|top,dep_ordset())).

-type(esc()::dep_ordset()).

-type(calls()::dict:dict(label(),ordsets:ordset(label()))).

-type(letrecs()::dict:dict(label(),label())).

-spec(analyze(cerl:c_module()) -> {deps(),esc(),calls(),letrecs()}).

analyze(Tree) ->
    {_,State} = traverse(Tree,map__new(),state__new(Tree),top),
    Esc = state__esc(State),
    State1 = state__add_deps(external,output(Esc),State),
    Deps = state__deps(State1),
    Calls = state__calls(State1),
    Letrecs = state__letrecs(State1),
    {map__finalize(Deps),set__to_ordsets(Esc),map__finalize(Calls),Letrecs}.

traverse(Tree,Out,State,CurrentFun) ->
    case cerl:type(Tree) of
        apply->
            Op = cerl:apply_op(Tree),
            Args = cerl:apply_args(Tree),
            case var =:= cerl:type(Op) of
                false->
                    {output(none),State};
                true->
                    OpLabel = cerl_trees:get_label(Op),
                    OpFuns = case map__lookup(OpLabel,Out) of
                        none->
                            output(none);
                        {value,OF}->
                            OF
                    end,
                    {ArgFuns,State2} = traverse_list(Args,Out,State,CurrentFun),
                    State3 = state__add_esc(merge_outs(ArgFuns),State2),
                    State4 = state__add_deps(CurrentFun,OpFuns,State3),
                    State5 = state__store_callsite(cerl_trees:get_label(Tree),OpFuns,length(Args),State4),
                    case state__get_rvals(OpLabel,State5) of
                        1->
                            {output(set__singleton(external)),State5};
                        NumRvals->
                            List = lists:duplicate(NumRvals,output(set__singleton(external))),
                            {output(List),State5}
                    end
            end;
        binary->
            {output(none),State};
        'case'->
            Arg = cerl:case_arg(Tree),
            {Funs,NewState} = traverse(Arg,Out,State,CurrentFun),
            Clauses = cerl:case_clauses(Tree),
            traverse_clauses(Clauses,Funs,Out,NewState,CurrentFun);
        call->
            Args = cerl:call_args(Tree),
            {ArgFuns,State1} = traverse_list(Args,Out,State,CurrentFun),
            remote_call(Tree,merge_outs(ArgFuns),State1);
        'catch'->
            traverse(cerl:catch_body(Tree),Out,State,CurrentFun);
        cons->
            {HdFuns,State1} = traverse(cerl:cons_hd(Tree),Out,State,CurrentFun),
            {TlFuns,State2} = traverse(cerl:cons_tl(Tree),Out,State1,CurrentFun),
            {merge_outs([HdFuns, TlFuns]),State2};
        'fun'->
            Body = cerl:fun_body(Tree),
            Label = cerl_trees:get_label(Tree),
            State1 = if CurrentFun =:= top ->
                state__add_deps(top,output(set__singleton(Label)),State);true ->
                O1 = output(set__singleton(CurrentFun)),
                O2 = output(set__singleton(Label)),
                TmpState = state__add_deps(Label,O1,State),
                state__add_deps(CurrentFun,O2,TmpState) end,
            Vars = cerl:fun_vars(Tree),
            Out1 = bind_single(Vars,output(set__singleton(external)),Out),
            {BodyFuns,State2} = traverse(Body,Out1,State1,cerl_trees:get_label(Tree)),
            {output(set__singleton(Label)),state__add_esc(BodyFuns,State2)};
        let->
            Vars = cerl:let_vars(Tree),
            Arg = cerl:let_arg(Tree),
            Body = cerl:let_body(Tree),
            OldNumRvals = state__num_rvals(State),
            State1 = state__store_num_rvals(length(Vars),State),
            {ArgFuns,State2} = traverse(Arg,Out,State1,CurrentFun),
            Out1 = bind_list(Vars,ArgFuns,Out),
            State3 = state__store_num_rvals(OldNumRvals,State2),
            traverse(Body,Out1,State3,CurrentFun);
        letrec->
            Defs = cerl:letrec_defs(Tree),
            Body = cerl:letrec_body(Tree),
            State1 = lists:foldl(fun ({Var,Fun},Acc)->
                state__add_letrecs(cerl_trees:get_label(Var),cerl_trees:get_label(Fun),Acc) end,State,Defs),
            Out1 = bind_defs(Defs,Out),
            NumRvals = state__num_rvals(State1),
            State2 = traverse_defs(Defs,Out1,State1,CurrentFun,NumRvals),
            traverse(Body,Out1,State2,CurrentFun);
        literal->
            {output(none),State};
        module->
            Defs = cerl:module_defs(Tree),
            Out1 = bind_defs(Defs,Out),
            State1 = traverse_defs(Defs,Out1,State,CurrentFun,1),
            {output(none),State1};
        primop->
            Args = cerl:primop_args(Tree),
            {ArgFuns,State1} = traverse_list(Args,Out,State,CurrentFun),
            primop(Tree,merge_outs(ArgFuns),State1);
        'receive'->
            Clauses = cerl:receive_clauses(Tree),
            TimeOut = cerl:receive_timeout(Tree),
            Action = cerl:receive_action(Tree),
            {ClauseFuns,State1} = traverse_clauses(Clauses,output(none),Out,State,CurrentFun),
            {_,State2} = traverse(TimeOut,Out,State1,CurrentFun),
            {ActionFuns,State3} = traverse(Action,Out,State2,CurrentFun),
            {merge_outs([ClauseFuns, ActionFuns]),State3};
        seq->
            {_,State1} = traverse(cerl:seq_arg(Tree),Out,State,CurrentFun),
            traverse(cerl:seq_body(Tree),Out,State1,CurrentFun);
        'try'->
            Arg = cerl:try_arg(Tree),
            Body = cerl:try_body(Tree),
            Vars = cerl:try_vars(Tree),
            EVars = cerl:try_evars(Tree),
            Handler = cerl:try_handler(Tree),
            {ArgFuns,State1} = traverse(Arg,Out,State,CurrentFun),
            Out1 = bind_list(Vars,ArgFuns,Out),
            {BodyFuns,State2} = traverse(Body,Out1,State1,CurrentFun),
            Out2 = bind_single(EVars,output(set__singleton(external)),Out),
            {HandlerFuns,State3} = traverse(Handler,Out2,State2,CurrentFun),
            {merge_outs([BodyFuns, HandlerFuns]),State3};
        tuple->
            Args = cerl:tuple_es(Tree),
            {List,State1} = traverse_list(Args,Out,State,CurrentFun),
            {merge_outs(List),State1};
        map->
            Args = cerl:map_es(Tree),
            {List,State1} = traverse_list(Args,Out,State,CurrentFun),
            {merge_outs(List),State1};
        map_pair->
            Key = cerl:map_pair_key(Tree),
            Val = cerl:map_pair_val(Tree),
            {List,State1} = traverse_list([Key, Val],Out,State,CurrentFun),
            {merge_outs(List),State1};
        values->
            OldNumRvals = state__num_rvals(State),
            State1 = state__store_num_rvals(1,State),
            {List,State2} = traverse_list(cerl:values_es(Tree),Out,State1,CurrentFun),
            State3 = state__store_num_rvals(OldNumRvals,State2),
            {List,State3};
        var->
            case map__lookup(cerl_trees:get_label(Tree),Out) of
                none->
                    {output(none),State};
                {value,Val}->
                    case is_only_external(Val) of
                        true->
                            {Val,State};
                        false->
                            {Val,state__add_deps(CurrentFun,Val,State)}
                    end
            end
    end.

traverse_list(Trees,Out,State,CurrentFun) ->
    traverse_list(Trees,Out,State,CurrentFun,[]).

traverse_list([Tree| Left],Out,State,CurrentFun,Acc) ->
    {X,State1} = traverse(Tree,Out,State,CurrentFun),
    traverse_list(Left,Out,State1,CurrentFun,[X| Acc]);
traverse_list([],_Out,State,_CurrentFun,Acc) ->
    {output(lists:reverse(Acc)),State}.

traverse_defs([{_,Fun}| Left],Out,State,CurrentFun,NumRvals) ->
    State1 = state__store_num_rvals(NumRvals,State),
    {_,State2} = traverse(Fun,Out,State1,CurrentFun),
    traverse_defs(Left,Out,State2,CurrentFun,NumRvals);
traverse_defs([],_Out,State,_CurrentFun,_NumRvals) ->
    State.

traverse_clauses(Clauses,ArgFuns,Out,State,CurrentFun) ->
    case Clauses of
        []->
            {output(none),State};
        Clauses1->
            traverse_clauses(Clauses1,ArgFuns,Out,State,CurrentFun,[])
    end.

traverse_clauses([Clause| Left],ArgFuns,Out,State,CurrentFun,Acc) ->
    Pats = cerl:clause_pats(Clause),
    Guard = cerl:clause_guard(Clause),
    Body = cerl:clause_body(Clause),
    Out1 = bind_pats_list(Pats,ArgFuns,Out),
    {_,State2} = traverse(Guard,Out1,State,CurrentFun),
    {BodyFuns,State3} = traverse(Body,Out1,State2,CurrentFun),
    traverse_clauses(Left,ArgFuns,Out,State3,CurrentFun,[BodyFuns| Acc]);
traverse_clauses([],_ArgFuns,_Out,State,_CurrentFun,Acc) ->
    {merge_outs(Acc),State}.

remote_call(Tree,ArgFuns,State) ->
    M = cerl:call_module(Tree),
    F = cerl:call_name(Tree),
    A = length(cerl:call_args(Tree)),
    case cerl:is_c_atom(M) andalso cerl:is_c_atom(F) of
        false->
            {output(set__singleton(external)),state__add_esc(ArgFuns,State)};
        true->
            M1 = cerl:atom_val(M),
            F1 = cerl:atom_val(F),
            Literal = cerl_closurean:is_literal_op(M1,F1,A),
            case erl_bifs:is_pure(M1,F1,A) of
                true->
                    case Literal of
                        true->
                            {output(none),State};
                        false->
                            {output(set__singleton(external)),state__add_esc(ArgFuns,State)}
                    end;
                false->
                    State1 = case cerl_closurean:is_escape_op(M1,F1,A) of
                        true->
                            state__add_esc(ArgFuns,State);
                        false->
                            State
                    end,
                    case Literal of
                        true->
                            {output(none),State1};
                        false->
                            {add_external(ArgFuns),State1}
                    end
            end
    end.

primop(Tree,ArgFuns,State) ->
    F = cerl:atom_val(cerl:primop_name(Tree)),
    A = length(cerl:primop_args(Tree)),
    State1 = case cerl_closurean:is_escape_op(F,A) of
        true->
            state__add_esc(ArgFuns,State);
        false->
            State
    end,
    case cerl_closurean:is_literal_op(F,A) of
        true->
            {output(none),State1};
        false->
            {ArgFuns,State1}
    end.

-record(set,{set::sets:set()}).

set__singleton(Val) ->
    #set{set = sets:add_element(Val,sets:new())}.

set__from_list(List) ->
    #set{set = sets:from_list(List)}.

set__is_element(_El,none) ->
    false;
set__is_element(El,#set{set = Set}) ->
    sets:is_element(El,Set).

set__union(none,Set) ->
    Set;
set__union(Set,none) ->
    Set;
set__union(#set{set = S1},#set{set = S2}) ->
    #set{set = sets:union(S1,S2)}.

set__to_ordsets(none) ->
    [];
set__to_ordsets(#set{set = Set}) ->
    ordsets:from_list(sets:to_list(Set)).

set__size(none) ->
    0;
set__size(#set{set = Set}) ->
    sets:size(Set).

set__filter(#set{set = Set},Fun) ->
    NewSet = sets:filter(Fun,Set),
    case sets:size(NewSet) =:= 0 of
        true->
            none;
        false->
            #set{set = NewSet}
    end.

-record(output,{type::single|list,content::none|#set{}|[#output{}]}).

output(none) ->
    #output{type = single,content = none};
output(S = #set{}) ->
    #output{type = single,content = S};
output(List)
    when is_list(List)->
    #output{type = list,content = List}.

merge_outs([H| T]) ->
    merge_outs(T,H);
merge_outs(#output{type = list,content = [H| T]}) ->
    merge_outs(T,H);
merge_outs(#output{type = list,content = []}) ->
    output(none).

merge_outs([#output{content = none}| Left],O) ->
    merge_outs(Left,O);
merge_outs([O| Left],#output{content = none}) ->
    merge_outs(Left,O);
merge_outs([#output{type = single,content = S1}| Left],#output{type = single,content = S2}) ->
    merge_outs(Left,output(set__union(S1,S2)));
merge_outs([#output{type = list,content = L1}| Left],#output{type = list,content = L2}) ->
    NewList = [(merge_outs([X, Y])) || {X,Y} <- lists:zip(L1,L2)],
    merge_outs(Left,output(NewList));
merge_outs([],Res) ->
    Res.

filter_outs(#output{type = single,content = S},Fun) ->
    output(set__filter(S,Fun)).

add_external(#output{type = single,content = Set}) ->
    output(set__union(Set,set__singleton(external)));
add_external(#output{type = list,content = List}) ->
    output([(add_external(O)) || O <- List]).

is_only_external(#output{type = single,content = Set}) ->
    set__is_element(external,Set) andalso set__size(Set) =:= 1.

map__new() ->
    dict:new().

map__add(_Label,none,Map) ->
    Map;
map__add(Label,Set,Map) ->
    case map__lookup(Label,Map) of
        {value,OldSet}->
            NewSet = set__union(OldSet,Set),
            map__store(Label,NewSet,Map);
        none->
            map__store(Label,Set,Map)
    end.

map__store(Label,Val,Map) ->
    dict:store(Label,Val,Map).

map__lookup(Label,Map) ->
    case dict:find(Label,Map) of
        {ok,Val}->
            {value,Val};
        error->
            none
    end.

map__finalize(Map) ->
    dict:map(fun (_Key,#set{} = Set)->
        set__to_ordsets(Set);(_Key,#output{type = single,content = Set})->
        set__to_ordsets(Set) end,Map).

bind_pats_list(_Pats,#output{content = none},Map) ->
    Map;
bind_pats_list([Pat],#output{type = single} = O,Map) ->
    bind_single(all_vars(Pat),O,Map);
bind_pats_list(Pats,#output{type = list,content = List},Map) ->
    bind_pats_list(Pats,List,Map);
bind_pats_list([Pat| PatLeft],[#output{type = single} = O| SetLeft],Map) ->
    Map1 = bind_single(all_vars(Pat),O,Map),
    bind_pats_list(PatLeft,SetLeft,Map1);
bind_pats_list([Pat| PatLeft],[#output{type = list,content = List}| SetLeft],Map) ->
    Map1 = case cerl:is_c_values(Pat) of
        true->
            bind_pats_list(cerl:values_es(Pat),List,Map);
        false->
            bind_single(all_vars(Pat),merge_outs(List),Map)
    end,
    bind_pats_list(PatLeft,SetLeft,Map1);
bind_pats_list([],[],Map) ->
    Map.

bind_single([Var| Left],O,Map) ->
    bind_single(Left,O,map__store(cerl_trees:get_label(Var),O,Map));
bind_single([],_O,Map) ->
    Map.

bind_list(List,#output{type = single} = O,Map) ->
    bind_single(List,O,Map);
bind_list(List1,#output{type = list,content = List2},Map) ->
    bind_list1(List1,List2,Map).

bind_list1([Var| VarLeft],[O| OLeft],Map) ->
    bind_list1(VarLeft,OLeft,map__store(cerl_trees:get_label(Var),O,Map));
bind_list1([],[],Map) ->
    Map.

bind_defs([{Var,Fun}| Left],Map) ->
    O = output(set__singleton(cerl_trees:get_label(Fun))),
    Map1 = map__store(cerl_trees:get_label(Var),O,Map),
    bind_defs(Left,Map1);
bind_defs([],Map) ->
    Map.

all_vars(Tree) ->
    all_vars(Tree,[]).

all_vars(Tree,AccIn) ->
    cerl_trees:fold(fun (SubTree,Acc)->
        case cerl:is_c_var(SubTree) of
            true->
                [SubTree| Acc];
            false->
                Acc
        end end,AccIn,Tree).

-type(local_set()::none|#set{}).

-type(rvals()::#{label() => non_neg_integer()}).

-record(state,{deps::deps(),esc::local_set(),calls::calls(),arities::dict:dict(label()|top,arity()),letrecs::letrecs(),num_rvals = 1::non_neg_integer(),rvals = #{}::rvals()}).

state__new(Tree) ->
    Exports = set__from_list([X || X <- cerl:module_exports(Tree)]),
    ExpLs = [(cerl_trees:get_label(Fun)) || {Var,Fun} <- cerl:module_defs(Tree),set__is_element(Var,Exports)],
    OnLoadFAs = lists:flatten([(cerl:atom_val(Args)) || {Attr,Args} <- cerl:module_attrs(Tree),cerl:atom_val(Attr) =:= on_load]),
    OnLoadLs = [(cerl_trees:get_label(Fun)) || {Var,Fun} <- cerl:module_defs(Tree),lists:member(cerl:var_name(Var),OnLoadFAs)],
    InitEsc = set__from_list(OnLoadLs ++ ExpLs),
    Arities = cerl_trees:fold(fun find_arities/2,dict:new(),Tree),
    #state{deps = map__new(),esc = InitEsc,calls = map__new(),arities = Arities,letrecs = map__new()}.

find_arities(Tree,AccMap) ->
    case cerl:is_c_fun(Tree) of
        true->
            Label = cerl_trees:get_label(Tree),
            Arity = cerl:fun_arity(Tree),
            dict:store(Label,Arity,AccMap);
        false->
            AccMap
    end.

state__add_deps(_From,#output{content = none},State) ->
    State;
state__add_deps(From,#output{type = single,content = To},#state{deps = Map} = State) ->
    State#state{deps = map__add(From,To,Map)}.

state__add_letrecs(Var,Fun,#state{letrecs = Map,num_rvals = NumRvals,rvals = Rvals} = State) ->
    State#state{letrecs = map__store(Var,Fun,Map),rvals = Rvals#{Var=>NumRvals}}.

state__deps(#state{deps = Deps}) ->
    Deps.

state__letrecs(#state{letrecs = Letrecs}) ->
    Letrecs.

state__add_esc(#output{content = none},State) ->
    State;
state__add_esc(#output{type = single,content = Set},#state{esc = Esc} = State) ->
    State#state{esc = set__union(Set,Esc)};
state__add_esc(#output{type = list,content = [H| T]},#state{esc = Esc} = State) ->
    #output{type = single,content = Set} = merge_outs(T,H),
    State#state{esc = set__union(Set,Esc)}.

state__esc(#state{esc = Esc}) ->
    Esc.

state__store_callsite(_From,#output{content = none},_CallArity,State) ->
    State;
state__store_callsite(From,To,CallArity,#state{calls = Calls,arities = Arities} = State) ->
    Filter = fun (external)->
        true;(Fun)->
        CallArity =:= dict:fetch(Fun,Arities) end,
    case filter_outs(To,Filter) of
        #output{content = none}->
            State;
        To1->
            State#state{calls = map__store(From,To1,Calls)}
    end.

state__calls(#state{calls = Calls}) ->
    Calls.

state__store_num_rvals(NumRval,State) ->
    State#state{num_rvals = NumRval}.

state__num_rvals(#state{num_rvals = NumRvals}) ->
    NumRvals.

state__get_rvals(FunLabel,#state{rvals = Rvals}) ->
    case Rvals of
        #{FunLabel:=NumRvals}->
            NumRvals;
        #{}->
            1
    end.
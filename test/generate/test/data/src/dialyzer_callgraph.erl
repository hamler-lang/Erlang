-file("dialyzer_callgraph.erl", 1).

-module(dialyzer_callgraph).

-export([add_edges/2, add_edges/3, all_nodes/1, delete/1, finalize/1, is_escaping/2, is_self_rec/2, non_local_calls/1, lookup_letrec/2, lookup_rec_var/2, lookup_call_site/2, lookup_label/2, lookup_name/2, modules/1, module_deps/1, module_postorder_from_funs/2, new/0, get_depends_on/2, in_neighbours/2, renew_race_info/4, renew_race_code/2, renew_race_public_tables/2, reset_from_funs/2, scan_core_tree/2, strip_module_deps/2, remove_external/1, to_dot/2, to_ps/3]).

-export([cleanup/1, get_digraph/1, get_named_tables/1, get_public_tables/1, get_race_code/1, get_race_detection/1, race_code_new/1, put_digraph/2, put_race_code/2, put_race_detection/2, put_named_tables/2, put_public_tables/2, put_behaviour_api_calls/2, get_behaviour_api_calls/1, dispose_race_server/1, duplicate/1]).

-export_type([callgraph/0, mfa_or_funlbl/0, callgraph_edge/0, mod_deps/0]).

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

-file("dialyzer_callgraph.erl", 64).

-type(scc()::[mfa_or_funlbl()]).

-type(mfa_call()::{mfa_or_funlbl(),mfa_or_funlbl()}).

-type(mfa_calls()::[mfa_call()]).

-type(mod_deps()::dict:dict(module(),[module()])).

-record(callgraph,{digraph = digraph:new()::digraph:graph(),active_digraph::active_digraph()|undefined,esc::ets:tid()|undefined,letrec_map::ets:tid()|undefined,name_map::ets:tid(),rev_name_map::ets:tid(),rec_var_map::ets:tid()|undefined,self_rec::ets:tid()|undefined,calls::ets:tid()|undefined,race_detection = false::boolean(),race_data_server = dialyzer_race_data_server:new()::pid()}).

-opaque(callgraph()::#callgraph{}).

-type(active_digraph()::{d,digraph:graph()}|{e,Out::ets:tid(),In::ets:tid(),Map::ets:tid()}).

-spec(new() -> callgraph()).

new() ->
    [ETSEsc, ETSNameMap, ETSRevNameMap, ETSRecVarMap, ETSLetrecMap, ETSSelfRec, ETSCalls] = [(ets:new(N,[public, {read_concurrency,true}])) || N <- [callgraph_esc, callgraph_name_map, callgraph_rev_name_map, callgraph_rec_var_map, callgraph_letrec_map, callgraph_self_rec, callgraph_calls]],
    #callgraph{esc = ETSEsc,letrec_map = ETSLetrecMap,name_map = ETSNameMap,rev_name_map = ETSRevNameMap,rec_var_map = ETSRecVarMap,self_rec = ETSSelfRec,calls = ETSCalls}.

-spec(delete(callgraph()) -> true).

delete(#callgraph{digraph = Digraph}) ->
    digraph_delete(Digraph).

-spec(all_nodes(callgraph()) -> [mfa()]).

all_nodes(#callgraph{digraph = DG}) ->
    digraph_vertices(DG).

-spec(lookup_rec_var(label(),callgraph()) -> error|{ok,mfa()}).

lookup_rec_var(Label,#callgraph{rec_var_map = RecVarMap})
    when is_integer(Label)->
    ets_lookup_dict(Label,RecVarMap).

-spec(lookup_letrec(label(),callgraph()) -> error|{ok,label()}).

lookup_letrec(Label,#callgraph{letrec_map = LetrecMap})
    when is_integer(Label)->
    ets_lookup_dict(Label,LetrecMap).

-spec(lookup_call_site(label(),callgraph()) -> error|{ok,[_]}).

lookup_call_site(Label,#callgraph{calls = Calls})
    when is_integer(Label)->
    ets_lookup_dict(Label,Calls).

-spec(lookup_name(label(),callgraph()) -> error|{ok,mfa()}).

lookup_name(Label,#callgraph{name_map = NameMap})
    when is_integer(Label)->
    ets_lookup_dict(Label,NameMap).

-spec(lookup_label(mfa_or_funlbl(),callgraph()) -> error|{ok,integer()}).

lookup_label({_,_,_} = MFA,#callgraph{rev_name_map = RevNameMap}) ->
    ets_lookup_dict(MFA,RevNameMap);
lookup_label(Label,#callgraph{})
    when is_integer(Label)->
    {ok,Label}.

-spec(in_neighbours(mfa_or_funlbl(),callgraph()) -> none|[mfa_or_funlbl(), ...]).

in_neighbours(Label,#callgraph{digraph = Digraph} = CG)
    when is_integer(Label)->
    Name = case lookup_name(Label,CG) of
        {ok,Val}->
            Val;
        error->
            Label
    end,
    digraph_in_neighbours(Name,Digraph);
in_neighbours({_,_,_} = MFA,#callgraph{digraph = Digraph}) ->
    digraph_in_neighbours(MFA,Digraph).

-spec(is_self_rec(mfa_or_funlbl(),callgraph()) -> boolean()).

is_self_rec(MfaOrLabel,#callgraph{self_rec = SelfRecs}) ->
    ets_lookup_set(MfaOrLabel,SelfRecs).

-spec(is_escaping(label(),callgraph()) -> boolean()).

is_escaping(Label,#callgraph{esc = Esc})
    when is_integer(Label)->
    ets_lookup_set(Label,Esc).

-type(callgraph_edge()::{mfa_or_funlbl(),mfa_or_funlbl()}).

-spec(add_edges([callgraph_edge()],callgraph()) -> ok).

add_edges([],_CG) ->
    ok;
add_edges(Edges,#callgraph{digraph = Digraph}) ->
    digraph_add_edges(Edges,Digraph).

-spec(add_edges([callgraph_edge()],[mfa_or_funlbl()],callgraph()) -> ok).

add_edges(Edges,MFAs,#callgraph{digraph = DG} = CG) ->
    digraph_confirm_vertices(MFAs,DG),
    add_edges(Edges,CG).

-spec(remove_external(callgraph()) -> {callgraph(),[tuple()]}).

remove_external(#callgraph{digraph = DG} = CG) ->
    {DG,External} = digraph_remove_external(DG),
    {CG,External}.

-spec(non_local_calls(callgraph()) -> mfa_calls()).

non_local_calls(#callgraph{digraph = DG}) ->
    Edges = digraph_edges(DG),
    find_non_local_calls(Edges,sets:new()).

-type(call_tab()::sets:set(mfa_call())).

-spec(find_non_local_calls([{mfa_or_funlbl(),mfa_or_funlbl()}],call_tab()) -> mfa_calls()).

find_non_local_calls([{{M,_,_},{M,_,_}}| Left],Set) ->
    find_non_local_calls(Left,Set);
find_non_local_calls([{{M1,_,_},{M2,_,_}} = Edge| Left],Set)
    when M1 =/= M2->
    find_non_local_calls(Left,sets:add_element(Edge,Set));
find_non_local_calls([{{_,_,_},Label}| Left],Set)
    when is_integer(Label)->
    find_non_local_calls(Left,Set);
find_non_local_calls([{Label,{_,_,_}}| Left],Set)
    when is_integer(Label)->
    find_non_local_calls(Left,Set);
find_non_local_calls([{Label1,Label2}| Left],Set)
    when is_integer(Label1),
    is_integer(Label2)->
    find_non_local_calls(Left,Set);
find_non_local_calls([],Set) ->
    sets:to_list(Set).

-spec(get_depends_on(scc()|module(),callgraph()) -> [scc()]).

get_depends_on(SCC,#callgraph{active_digraph = {e,Out,_In,Maps}}) ->
    lookup_scc(SCC,Out,Maps);
get_depends_on(SCC,#callgraph{active_digraph = {d,DG}}) ->
    digraph:out_neighbours(DG,SCC).

lookup_scc(SCC,Table,Maps) ->
    case ets_lookup_dict({scc,SCC},Maps) of
        {ok,SCCInt}->
            case ets_lookup_dict(SCCInt,Table) of
                {ok,Ints}->
                    [(ets:lookup_element(Maps,Int,2)) || Int <- Ints];
                error->
                    []
            end;
        error->
            []
    end.

-spec(modules(callgraph()) -> [module()]).

modules(#callgraph{digraph = DG}) ->
    ordsets:from_list([M || {M,_F,_A} <- digraph_vertices(DG)]).

-spec(module_postorder(callgraph()) -> {[module()],{d,digraph:graph()}}).

module_postorder(#callgraph{digraph = DG}) ->
    Edges = lists:foldl(fun edge_fold/2,sets:new(),digraph_edges(DG)),
    Nodes = sets:from_list([M || {M,_F,_A} <- digraph_vertices(DG)]),
    MDG = digraph:new([acyclic]),
    digraph_confirm_vertices(sets:to_list(Nodes),MDG),
    Foreach = fun ({M1,M2})->
        _ = digraph:add_edge(MDG,M1,M2) end,
    lists:foreach(Foreach,sets:to_list(Edges)),
    {lists:reverse(digraph_utils:topsort(MDG)),{d,MDG}}.

edge_fold({{M1,_,_},{M2,_,_}},Set) ->
    case M1 =/= M2 of
        true->
            sets:add_element({M1,M2},Set);
        false->
            Set
    end;
edge_fold(_,Set) ->
    Set.

-spec(module_deps(callgraph()) -> mod_deps()).

module_deps(#callgraph{digraph = DG}) ->
    Edges = lists:foldl(fun edge_fold/2,sets:new(),digraph_edges(DG)),
    Nodes = sets:from_list([M || {M,_F,_A} <- digraph_vertices(DG)]),
    MDG = digraph:new(),
    digraph_confirm_vertices(sets:to_list(Nodes),MDG),
    Foreach = fun ({M1,M2})->
        check_add_edge(MDG,M1,M2) end,
    lists:foreach(Foreach,sets:to_list(Edges)),
    Deps = [{N,ordsets:from_list(digraph:in_neighbours(MDG,N))} || N <- sets:to_list(Nodes)],
    digraph_delete(MDG),
    dict:from_list(Deps).

-spec(strip_module_deps(mod_deps(),sets:set(module())) -> mod_deps()).

strip_module_deps(ModDeps,StripSet) ->
    FilterFun1 = fun (Val)->
         not sets:is_element(Val,StripSet) end,
    MapFun = fun (_Key,ValSet)->
        ordsets:filter(FilterFun1,ValSet) end,
    ModDeps1 = dict:map(MapFun,ModDeps),
    FilterFun2 = fun (_Key,ValSet)->
        ValSet =/= [] end,
    dict:filter(FilterFun2,ModDeps1).

-spec(finalize(callgraph()) -> {[scc()],callgraph()}).

finalize(#callgraph{digraph = DG} = CG) ->
    {ActiveDG,Postorder} = condensation(DG),
    {Postorder,CG#callgraph{active_digraph = ActiveDG}}.

-spec(reset_from_funs([mfa_or_funlbl()],callgraph()) -> {[scc()],callgraph()}).

reset_from_funs(Funs,#callgraph{digraph = DG,active_digraph = ADG} = CG) ->
    active_digraph_delete(ADG),
    SubGraph = digraph_reaching_subgraph(Funs,DG),
    {NewActiveDG,Postorder} = condensation(SubGraph),
    digraph_delete(SubGraph),
    {Postorder,CG#callgraph{active_digraph = NewActiveDG}}.

-spec(module_postorder_from_funs([mfa_or_funlbl()],callgraph()) -> {[module()],callgraph()}).

module_postorder_from_funs(Funs,#callgraph{digraph = DG,active_digraph = ADG} = CG) ->
    active_digraph_delete(ADG),
    SubGraph = digraph_reaching_subgraph(Funs,DG),
    {PO,Active} = module_postorder(CG#callgraph{digraph = SubGraph}),
    digraph_delete(SubGraph),
    {PO,CG#callgraph{active_digraph = Active}}.

ets_lookup_dict(Key,Table) ->
    try ets:lookup_element(Table,Key,2) of 
        Val->
            {ok,Val}
        catch
            _:_->
                error end.

ets_lookup_set(Key,Table) ->
    ets:lookup(Table,Key) =/= [].

-spec(scan_core_tree(cerl:c_module(),callgraph()) -> {[mfa_or_funlbl()],[callgraph_edge()]}).

scan_core_tree(Tree,#callgraph{calls = ETSCalls,esc = ETSEsc,letrec_map = ETSLetrecMap,name_map = ETSNameMap,rec_var_map = ETSRecVarMap,rev_name_map = ETSRevNameMap,self_rec = ETSSelfRec}) ->
    build_maps(Tree,ETSRecVarMap,ETSNameMap,ETSRevNameMap,ETSLetrecMap),
    {Deps0,EscapingFuns,Calls,Letrecs} = dialyzer_dep:analyze(Tree),
    true = ets:insert(ETSCalls,dict:to_list(Calls)),
    true = ets:insert(ETSLetrecMap,dict:to_list(Letrecs)),
    true = ets:insert(ETSEsc,[{E} || E <- EscapingFuns]),
    LabelEdges = get_edges_from_deps(Deps0),
    SelfRecs0 = lists:foldl(fun ({Key,Key},Acc)->
        case ets_lookup_dict(Key,ETSNameMap) of
            error->
                [Key| Acc];
            {ok,Name}->
                [Key, Name| Acc]
        end;(_,Acc)->
        Acc end,[],LabelEdges),
    true = ets:insert(ETSSelfRec,[{S} || S <- SelfRecs0]),
    NamedEdges1 = name_edges(LabelEdges,ETSNameMap),
    NamedEdges2 = scan_core_funs(Tree),
    Names1 = lists:append([[X, Y] || {X,Y} <- NamedEdges1]),
    Names2 = ordsets:from_list(Names1),
    Names3 = ordsets:del_element(top,Names2),
    NewNamedEdges2 = [E || {From,To} = E <- NamedEdges2,From =/= top,To =/= top],
    NewNamedEdges1 = [E || {From,To} = E <- NamedEdges1,From =/= top,To =/= top],
    NamedEdges3 = NewNamedEdges1 ++ NewNamedEdges2,
    {Names3,NamedEdges3}.

build_maps(Tree,ETSRecVarMap,ETSNameMap,ETSRevNameMap,ETSLetrecMap) ->
    Defs = cerl:module_defs(Tree),
    Mod = cerl:atom_val(cerl:module_name(Tree)),
    Fun = fun ({Var,Function})->
        FunName = cerl:fname_id(Var),
        Arity = cerl:fname_arity(Var),
        MFA = {Mod,FunName,Arity},
        FunLabel = get_label(Function),
        VarLabel = get_label(Var),
        true = ets:insert(ETSLetrecMap,{VarLabel,FunLabel}),
        true = ets:insert(ETSNameMap,{FunLabel,MFA}),
        true = ets:insert(ETSRevNameMap,{MFA,FunLabel}),
        true = ets:insert(ETSRecVarMap,{VarLabel,MFA}) end,
    lists:foreach(Fun,Defs).

get_edges_from_deps(Deps) ->
    Edges = dict:fold(fun (external,_Set,Acc)->
        Acc;(Caller,Set,Acc)->
        [[{Caller,Callee} || Callee <- Set,Callee =/= external]| Acc] end,[],Deps),
    lists:flatten(Edges).

name_edges(Edges,ETSNameMap) ->
    MapFun = fun (X)->
        case ets_lookup_dict(X,ETSNameMap) of
            error->
                X;
            {ok,MFA}->
                MFA
        end end,
    name_edges(Edges,MapFun,[]).

name_edges([{From,To}| Left],MapFun,Acc) ->
    NewFrom = MapFun(From),
    NewTo = MapFun(To),
    name_edges(Left,MapFun,[{NewFrom,NewTo}| Acc]);
name_edges([],_MapFun,Acc) ->
    Acc.

scan_core_funs(Tree) ->
    Defs = cerl:module_defs(Tree),
    Mod = cerl:atom_val(cerl:module_name(Tree)),
    DeepEdges = lists:foldl(fun ({Var,Function},Edges)->
        FunName = cerl:fname_id(Var),
        Arity = cerl:fname_arity(Var),
        MFA = {Mod,FunName,Arity},
        [scan_one_core_fun(Function,MFA)| Edges] end,[],Defs),
    lists:flatten(DeepEdges).

scan_one_core_fun(TopTree,FunName) ->
    FoldFun = fun (Tree,Acc)->
        case cerl:type(Tree) of
            call->
                CalleeM = cerl:call_module(Tree),
                CalleeF = cerl:call_name(Tree),
                CalleeArgs = cerl:call_args(Tree),
                A = length(CalleeArgs),
                case cerl:is_c_atom(CalleeM) andalso cerl:is_c_atom(CalleeF) of
                    true->
                        M = cerl:atom_val(CalleeM),
                        F = cerl:atom_val(CalleeF),
                        case erl_bif_types:is_known(M,F,A) of
                            true->
                                case {M,F,A} of
                                    {erlang,make_fun,3}->
                                        [CA1, CA2, CA3] = CalleeArgs,
                                        case cerl:is_c_atom(CA1) andalso cerl:is_c_atom(CA2) andalso cerl:is_c_int(CA3) of
                                            true->
                                                MM = cerl:atom_val(CA1),
                                                FF = cerl:atom_val(CA2),
                                                AA = cerl:int_val(CA3),
                                                case erl_bif_types:is_known(MM,FF,AA) of
                                                    true->
                                                        Acc;
                                                    false->
                                                        [{FunName,{MM,FF,AA}}| Acc]
                                                end;
                                            false->
                                                Acc
                                        end;
                                    _->
                                        Acc
                                end;
                            false->
                                [{FunName,{M,F,A}}| Acc]
                        end;
                    false->
                        Acc
                end;
            _->
                Acc
        end end,
    cerl_trees:fold(FoldFun,[],TopTree).

get_label(T) ->
    case cerl:get_ann(T) of
        [{label,L}| _]
            when is_integer(L)->
            L;
        _->
            error({missing_label,T})
    end.

digraph_add_edges([{From,To}| Left],DG) ->
    digraph_add_edge(From,To,DG),
    digraph_add_edges(Left,DG);
digraph_add_edges([],_DG) ->
    ok.

digraph_add_edge(From,To,DG) ->
    case digraph:vertex(DG,From) of
        false->
            digraph:add_vertex(DG,From);
        {From,_}->
            ok
    end,
    case digraph:vertex(DG,To) of
        false->
            digraph:add_vertex(DG,To);
        {To,_}->
            ok
    end,
    check_add_edge(DG,{From,To},From,To,[]),
    ok.

check_add_edge(G,V1,V2) ->
    case digraph:add_edge(G,V1,V2) of
        {error,Error}->
            exit({add_edge,V1,V2,Error});
        _Edge->
            ok
    end.

check_add_edge(G,E,V1,V2,L) ->
    case digraph:add_edge(G,E,V1,V2,L) of
        {error,Error}->
            exit({add_edge,E,V1,V2,L,Error});
        _Edge->
            ok
    end.

digraph_confirm_vertices([MFA| Left],DG) ->
    digraph:add_vertex(DG,MFA,confirmed),
    digraph_confirm_vertices(Left,DG);
digraph_confirm_vertices([],_DG) ->
    ok.

digraph_remove_external(DG) ->
    Vertices = digraph:vertices(DG),
    Unconfirmed = remove_unconfirmed(Vertices,DG),
    {DG,Unconfirmed}.

remove_unconfirmed(Vertexes,DG) ->
    remove_unconfirmed(Vertexes,DG,[]).

remove_unconfirmed([V| Left],DG,Unconfirmed) ->
    case digraph:vertex(DG,V) of
        {V,confirmed}->
            remove_unconfirmed(Left,DG,Unconfirmed);
        {V,[]}->
            remove_unconfirmed(Left,DG,[V| Unconfirmed])
    end;
remove_unconfirmed([],DG,Unconfirmed) ->
    BadCalls = lists:append([(digraph:in_edges(DG,V)) || V <- Unconfirmed]),
    BadCallsSorted = lists:keysort(1,BadCalls),
    digraph:del_vertices(DG,Unconfirmed),
    BadCallsSorted.

digraph_delete(DG) ->
    digraph:delete(DG).

active_digraph_delete({d,DG}) ->
    digraph:delete(DG);
active_digraph_delete({e,Out,In,Maps}) ->
    ets:delete(Out),
    ets:delete(In),
    ets:delete(Maps).

digraph_edges(DG) ->
    digraph:edges(DG).

digraph_vertices(DG) ->
    digraph:vertices(DG).

digraph_in_neighbours(V,DG) ->
    case digraph:in_neighbours(DG,V) of
        []->
            none;
        List->
            List
    end.

digraph_reaching_subgraph(Funs,DG) ->
    Vertices = digraph_utils:reaching(Funs,DG),
    digraph_utils:subgraph(DG,Vertices).

-spec(renew_race_info(callgraph(),dict:dict(),[label()],[string()]) -> callgraph()).

renew_race_info(#callgraph{race_data_server = RaceDataServer} = CG,RaceCode,PublicTables,NamedTables) ->
    ok = dialyzer_race_data_server:cast({renew_race_info,{RaceCode,PublicTables,NamedTables}},RaceDataServer),
    CG.

-spec(renew_race_code(dialyzer_races:races(),callgraph()) -> callgraph()).

renew_race_code(Races,#callgraph{race_data_server = RaceDataServer} = CG) ->
    Fun = dialyzer_races:get_curr_fun(Races),
    FunArgs = dialyzer_races:get_curr_fun_args(Races),
    Code = lists:reverse(dialyzer_races:get_race_list(Races)),
    ok = dialyzer_race_data_server:cast({renew_race_code,{Fun,FunArgs,Code}},RaceDataServer),
    CG.

-spec(renew_race_public_tables(label(),callgraph()) -> callgraph()).

renew_race_public_tables(VarLabel,#callgraph{race_data_server = RaceDataServer} = CG) ->
    ok = dialyzer_race_data_server:cast({renew_race_public_tables,VarLabel},RaceDataServer),
    CG.

-spec(cleanup(callgraph()) -> callgraph()).

cleanup(#callgraph{digraph = Digraph,name_map = NameMap,rev_name_map = RevNameMap,race_data_server = RaceDataServer}) ->
    #callgraph{digraph = Digraph,name_map = NameMap,rev_name_map = RevNameMap,race_data_server = dialyzer_race_data_server:duplicate(RaceDataServer)}.

-spec(duplicate(callgraph()) -> callgraph()).

duplicate(#callgraph{race_data_server = RaceDataServer} = Callgraph) ->
    Callgraph#callgraph{race_data_server = dialyzer_race_data_server:duplicate(RaceDataServer)}.

-spec(dispose_race_server(callgraph()) -> ok).

dispose_race_server(#callgraph{race_data_server = RaceDataServer}) ->
    dialyzer_race_data_server:stop(RaceDataServer).

-spec(get_digraph(callgraph()) -> digraph:graph()).

get_digraph(#callgraph{digraph = Digraph}) ->
    Digraph.

-spec(get_named_tables(callgraph()) -> [string()]).

get_named_tables(#callgraph{race_data_server = RaceDataServer}) ->
    dialyzer_race_data_server:call(get_named_tables,RaceDataServer).

-spec(get_public_tables(callgraph()) -> [label()]).

get_public_tables(#callgraph{race_data_server = RaceDataServer}) ->
    dialyzer_race_data_server:call(get_public_tables,RaceDataServer).

-spec(get_race_code(callgraph()) -> dict:dict()).

get_race_code(#callgraph{race_data_server = RaceDataServer}) ->
    dialyzer_race_data_server:call(get_race_code,RaceDataServer).

-spec(get_race_detection(callgraph()) -> boolean()).

get_race_detection(#callgraph{race_detection = RD}) ->
    RD.

-spec(get_behaviour_api_calls(callgraph()) -> [{mfa(),mfa()}]).

get_behaviour_api_calls(#callgraph{race_data_server = RaceDataServer}) ->
    dialyzer_race_data_server:call(get_behaviour_api_calls,RaceDataServer).

-spec(race_code_new(callgraph()) -> callgraph()).

race_code_new(#callgraph{race_data_server = RaceDataServer} = CG) ->
    ok = dialyzer_race_data_server:cast(race_code_new,RaceDataServer),
    CG.

-spec(put_digraph(digraph:graph(),callgraph()) -> callgraph()).

put_digraph(Digraph,Callgraph) ->
    Callgraph#callgraph{digraph = Digraph}.

-spec(put_race_code(dict:dict(),callgraph()) -> callgraph()).

put_race_code(RaceCode,#callgraph{race_data_server = RaceDataServer} = CG) ->
    ok = dialyzer_race_data_server:cast({put_race_code,RaceCode},RaceDataServer),
    CG.

-spec(put_race_detection(boolean(),callgraph()) -> callgraph()).

put_race_detection(RaceDetection,Callgraph) ->
    Callgraph#callgraph{race_detection = RaceDetection}.

-spec(put_named_tables([string()],callgraph()) -> callgraph()).

put_named_tables(NamedTables,#callgraph{race_data_server = RaceDataServer} = CG) ->
    ok = dialyzer_race_data_server:cast({put_named_tables,NamedTables},RaceDataServer),
    CG.

-spec(put_public_tables([label()],callgraph()) -> callgraph()).

put_public_tables(PublicTables,#callgraph{race_data_server = RaceDataServer} = CG) ->
    ok = dialyzer_race_data_server:cast({put_public_tables,PublicTables},RaceDataServer),
    CG.

-spec(put_behaviour_api_calls([{mfa(),mfa()}],callgraph()) -> callgraph()).

put_behaviour_api_calls(Calls,#callgraph{race_data_server = RaceDataServer} = CG) ->
    ok = dialyzer_race_data_server:cast({put_behaviour_api_calls,Calls},RaceDataServer),
    CG.

-spec(to_dot(callgraph(),file:filename()) -> ok).

to_dot(#callgraph{digraph = DG,esc = Esc} = CG,File) ->
    Fun = fun (L)->
        case lookup_name(L,CG) of
            error->
                L;
            {ok,Name}->
                Name
        end end,
    Escaping = [{Fun(L),{color,red}} || L <- [E || {E} <- ets:tab2list(Esc)],L =/= external],
    Vertices = digraph_edges(DG),
    hipe_dot:translate_list(Vertices,File,"CG",Escaping).

-spec(to_ps(callgraph(),file:filename(),string()) -> ok).

to_ps(#callgraph{} = CG,File,Args) ->
    Dot_File = filename:rootname(File) ++ ".dot",
    to_dot(CG,Dot_File),
    Command = io_lib:format("dot -Tps ~ts -o ~ts ~ts",[Args, File, Dot_File]),
    _ = os:cmd(Command),
    ok.

condensation(G) ->
    {Pid,Ref} = spawn_monitor(do_condensation(G,self())),
    receive {'DOWN',Ref,process,Pid,Result}->
        {SCCInts,OutETS,InETS,MapsETS} = Result,
        NewSCCs = [(ets:lookup_element(MapsETS,SCCInt,2)) || SCCInt <- SCCInts],
        {{e,OutETS,InETS,MapsETS},NewSCCs} end.

-spec(do_condensation(digraph:graph(),pid()) -> fun(() -> no_return())).

do_condensation(G,Parent) ->
    fun ()->
        [OutETS, InETS, MapsETS] = [(ets:new(Name,[{read_concurrency,true}])) || Name <- [callgraph_deps_out, callgraph_deps_in, callgraph_scc_map]],
        SCCs = digraph_utils:strong_components(G),
        Ints = lists:seq(1,length(SCCs)),
        IntToSCC = lists:zip(Ints,SCCs),
        IntScc = sofs:relation(IntToSCC,[{int,scc}]),
        ets:insert(MapsETS,IntToSCC),
        C2V = sofs:relation([{SC,V} || SC <- SCCs,V <- SC],[{scc,v}]),
        I2V = sofs:relative_product(IntScc,C2V),
        Es = sofs:relation(digraph:edges(G),[{v,v}]),
        R1 = sofs:relative_product(I2V,Es),
        R2 = sofs:relative_product(I2V,sofs:converse(R1)),
        R2Strict = sofs:strict_relation(R2),
        Out = sofs:relation_to_family(sofs:converse(R2Strict)),
        ets:insert(OutETS,sofs:to_external(Out)),
        DG = sofs:family_to_digraph(Out),
        lists:foreach(fun (I)->
            digraph:add_vertex(DG,I) end,Ints),
        SCCInts0 = digraph_utils:topsort(DG),
        digraph:delete(DG),
        SCCInts = lists:reverse(SCCInts0),
        In = sofs:relation_to_family(R2Strict),
        ets:insert(InETS,sofs:to_external(In)),
        ets:insert(MapsETS,lists:zip([{scc,SCC} || SCC <- SCCs],Ints)),
        lists:foreach(fun (E)->
            true = ets:give_away(E,Parent,any) end,[OutETS, InETS, MapsETS]),
        exit({SCCInts,OutETS,InETS,MapsETS}) end.
-file("dialyzer_contracts.erl", 1).

-module(dialyzer_contracts).

-export([check_contract/2, check_contracts/4, contracts_without_fun/3, contract_to_string/1, get_invalid_contract_warnings/3, get_contract_args/1, get_contract_return/1, get_contract_return/2, is_overloaded/1, process_contract_remote_types/1, store_tmp_contract/6]).

-export_type([file_contract/0, plt_contracts/0]).

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

-file("dialyzer_contracts.erl", 35).

-type(file_contract()::{file_line(),#contract{},Extra::[_]}).

-type(plt_contracts()::orddict:orddict(mfa(),#contract{})).

-type(cache()::ets:tid()).

-type(tmp_contract_fun()::fun((sets:set(mfa()),types(),cache()) -> contract_pair())).

-record(tmp_contract,{contract_funs = []::[tmp_contract_fun()],forms = []::[{_,_}]}).

-spec(get_contract_return(#contract{}) -> erl_types:erl_type()).

get_contract_return(#contract{contracts = Cs,args = GenArgs}) ->
    process_contracts(Cs,GenArgs).

-spec(get_contract_return(#contract{},[erl_types:erl_type()]) -> erl_types:erl_type()).

get_contract_return(#contract{contracts = Cs},Args) ->
    process_contracts(Cs,Args).

-spec(get_contract_args(#contract{}) -> [erl_types:erl_type()]).

get_contract_args(#contract{args = Args}) ->
    Args.

-spec(get_contract_signature(#contract{}) -> erl_types:erl_type()).

get_contract_signature(#contract{contracts = Cs,args = GeneralDomain}) ->
    Range = process_contracts(Cs,GeneralDomain),
    erl_types:t_fun(GeneralDomain,Range).

-spec(is_overloaded(#contract{}) -> boolean()).

is_overloaded(#contract{contracts = Cs}) ->
    case Cs of
        [_]->
            true;
        [_, _| _]->
            false
    end.

-spec(contract_to_string(#contract{}) -> string()).

contract_to_string(#contract{forms = Forms}) ->
    contract_to_string_1(Forms).

contract_to_string_1([{Contract,[]}]) ->
    strip_fun(erl_types:t_form_to_string(Contract));
contract_to_string_1([{Contract,[]}| Rest]) ->
    strip_fun(erl_types:t_form_to_string(Contract)) ++ "\n    ; " ++ contract_to_string_1(Rest);
contract_to_string_1([{Contract,Constraints}]) ->
    strip_fun(erl_types:t_form_to_string(Contract)) ++ " when " ++ constraints_to_string(Constraints);
contract_to_string_1([{Contract,Constraints}| Rest]) ->
    strip_fun(erl_types:t_form_to_string(Contract)) ++ " when " ++ constraints_to_string(Constraints) ++ ";" ++ contract_to_string_1(Rest).

strip_fun("fun(" ++ String) ->
    butlast(String).

butlast([]) ->
    [];
butlast([_]) ->
    [];
butlast([H| T]) ->
    [H| butlast(T)].

constraints_to_string([]) ->
    "";
constraints_to_string([{type,_,constraint,[{atom,_,What}, Types]}| Rest]) ->
    S = constraint_to_string(What,Types),
    case Rest of
        []->
            S;
        _->
            S ++ ", " ++ constraints_to_string(Rest)
    end.

constraint_to_string(is_subtype,[{var,_,Var}, T]) ->
    atom_to_list(Var) ++ " :: " ++ erl_types:t_form_to_string(T);
constraint_to_string(What,Types) ->
    atom_to_list(What) ++ "(" ++ sequence([(erl_types:t_form_to_string(T)) || T <- Types],",") ++ ")".

sequence([],_Delimiter) ->
    "";
sequence([H],_Delimiter) ->
    H;
sequence([H| T],Delimiter) ->
    H ++ Delimiter ++ sequence(T,Delimiter).

-spec(process_contract_remote_types(dialyzer_codeserver:codeserver()) -> dialyzer_codeserver:codeserver()).

process_contract_remote_types(CodeServer) ->
    Mods = dialyzer_codeserver:all_temp_modules(CodeServer),
    RecordTable = dialyzer_codeserver:get_records_table(CodeServer),
    ExpTypes = dialyzer_codeserver:get_exported_types(CodeServer),
    ModuleFun = fun (ModuleName)->
        ContractFun = fun ({MFA,{File,TmpContract,Xtra}},C0)->
            #tmp_contract{contract_funs = CFuns,forms = Forms} = TmpContract,
            {NewCs,C2} = lists:mapfoldl(fun (CFun,C1)->
                CFun(ExpTypes,RecordTable,C1) end,C0,CFuns),
            Args = general_domain(NewCs),
            Contract = #contract{contracts = NewCs,args = Args,forms = Forms},
            {{MFA,{File,Contract,Xtra}},C2} end,
        Cache = erl_types:cache__new(),
        {ContractMap,CallbackMap} = dialyzer_codeserver:get_temp_contracts(ModuleName,CodeServer),
        {NewContractList,Cache1} = lists:mapfoldl(ContractFun,Cache,maps:to_list(ContractMap)),
        {NewCallbackList,_NewCache} = lists:mapfoldl(ContractFun,Cache1,maps:to_list(CallbackMap)),
        dialyzer_codeserver:store_contracts(ModuleName,maps:from_list(NewContractList),maps:from_list(NewCallbackList),CodeServer) end,
    lists:foreach(ModuleFun,Mods),
    dialyzer_codeserver:finalize_contracts(CodeServer).

-type(fun_types()::orddict:orddict(label(),erl_types:type_table())).

-spec(check_contracts(orddict:orddict(mfa(),#contract{}),dialyzer_callgraph:callgraph(),fun_types(),erl_types:opaques()) -> plt_contracts()).

check_contracts(Contracts,Callgraph,FunTypes,ModOpaques) ->
    FoldFun = fun ({Label,Type},NewContracts)->
        case dialyzer_callgraph:lookup_name(Label,Callgraph) of
            {ok,{M,F,A} = MFA}->
                case orddict:find(MFA,Contracts) of
                    {ok,Contract}->
                        {M,Opaques} = lists:keyfind(M,1,ModOpaques),
                        case check_contract(Contract,Type,Opaques) of
                            ok->
                                case erl_bif_types:is_known(M,F,A) of
                                    true->
                                        NewContracts;
                                    false->
                                        [{MFA,Contract}| NewContracts]
                                end;
                            {range_warnings,_}->
                                [{MFA,Contract}| NewContracts];
                            {error,_Error}->
                                NewContracts
                        end;
                    error->
                        NewContracts
                end;
            error->
                NewContracts
        end end,
    orddict:from_list(lists:foldl(FoldFun,[],orddict:to_list(FunTypes))).

-type(check_contract_return()::ok|{error,invalid_contract|{opaque_mismatch,erl_types:erl_type()}|{overlapping_contract,[module()|atom()|byte()]}|string()}|{range_warnings,[{error,{extra_range|missing_range,erl_types:erl_type(),erl_types:erl_type()}}]}).

-spec(check_contract(#contract{},erl_types:erl_type()) -> check_contract_return()).

check_contract(Contract,SuccType) ->
    check_contract(Contract,SuccType,universe).

-spec(check_contract(#contract{},erl_types:erl_type(),erl_types:opaques()) -> check_contract_return()).

check_contract(#contract{contracts = Contracts},SuccType,Opaques) ->
    try Contracts1 = [{Contract,insert_constraints(Constraints)} || {Contract,Constraints} <- Contracts],
    Contracts2 = [(erl_types:t_subst(Contract,Map)) || {Contract,Map} <- Contracts1],
    GenDomains = [(erl_types:t_fun_args(C)) || C <- Contracts2],
    case check_domains(GenDomains) of
        error->
            {error,{overlapping_contract,[]}};
        ok->
            InfList = [{Contract,erl_types:t_inf(Contract,SuccType,Opaques)} || Contract <- Contracts2],
            case check_contract_inf_list(InfList,SuccType,Opaques) of
                {error,_} = Invalid->
                    Invalid;
                ok->
                    case check_extraneous(Contracts2,SuccType) of
                        {error,invalid_contract} = Err->
                            Err;
                        {error,{extra_range,_,_}} = Err->
                            MissingError = check_missing(Contracts2,SuccType),
                            {range_warnings,[Err| MissingError]};
                        ok->
                            case check_missing(Contracts2,SuccType) of
                                []->
                                    ok;
                                ErrorL->
                                    {range_warnings,ErrorL}
                            end
                    end
            end
    end
        catch
            throw:{error,_} = Error->
                Error end.

check_domains([_]) ->
    ok;
check_domains([Dom| Doms]) ->
    Fun = fun (D)->
        erl_types:any_none_or_unit(erl_types:t_inf_lists(Dom,D)) end,
    case lists:all(Fun,Doms) of
        true->
            check_domains(Doms);
        false->
            error
    end.

check_contract_inf_list(List,SuccType,Opaques) ->
    case check_contract_inf_list(List,SuccType,Opaques,[]) of
        ok->
            ok;
        {error,[]}->
            {error,invalid_contract};
        {error,[{SigRange,ContrRange}| _]}->
            case erl_types:t_find_opaque_mismatch(SigRange,ContrRange,Opaques) of
                error->
                    {error,invalid_contract};
                {ok,_T1,T2}->
                    {error,{opaque_mismatch,T2}}
            end
    end.

check_contract_inf_list([{Contract,FunType}| Left],SuccType,Opaques,OM) ->
    FunArgs = erl_types:t_fun_args(FunType),
    case lists:any(fun erl_types:t_is_none_or_unit/1,FunArgs) of
        true->
            check_contract_inf_list(Left,SuccType,Opaques,OM);
        false->
            STRange = erl_types:t_fun_range(SuccType),
            case erl_types:t_is_none_or_unit(STRange) of
                true->
                    ok;
                false->
                    Range = erl_types:t_fun_range(FunType),
                    case erl_types:t_is_none(erl_types:t_inf(STRange,Range)) of
                        true->
                            CR = erl_types:t_fun_range(Contract),
                            NewOM = [{STRange,CR}| OM],
                            check_contract_inf_list(Left,SuccType,Opaques,NewOM);
                        false->
                            ok
                    end
            end
    end;
check_contract_inf_list([],_SuccType,_Opaques,OM) ->
    {error,OM}.

check_extraneous([],_SuccType) ->
    ok;
check_extraneous([C| Cs],SuccType) ->
    case check_extraneous_1(C,SuccType) of
        {error,_} = Error->
            Error;
        ok->
            check_extraneous(Cs,SuccType)
    end.

check_extraneous_1(Contract,SuccType) ->
    CRng = erl_types:t_fun_range(Contract),
    CRngs = erl_types:t_elements(CRng),
    STRng = erl_types:t_fun_range(SuccType),
    ok,
    case [CR || CR <- CRngs,erl_types:t_is_none(erl_types:t_inf(CR,STRng))] of
        []->
            case bad_extraneous_list(CRng,STRng) orelse bad_extraneous_map(CRng,STRng) of
                true->
                    {error,invalid_contract};
                false->
                    ok
            end;
        CRs->
            {error,{extra_range,erl_types:t_sup(CRs),STRng}}
    end.

bad_extraneous_list(CRng,STRng) ->
    CRngList = list_part(CRng),
    STRngList = list_part(STRng),
    case is_not_nil_list(CRngList) andalso is_not_nil_list(STRngList) of
        false->
            false;
        true->
            CRngElements = erl_types:t_list_elements(CRngList),
            STRngElements = erl_types:t_list_elements(STRngList),
            Inf = erl_types:t_inf(CRngElements,STRngElements),
            erl_types:t_is_none(Inf)
    end.

list_part(Type) ->
    erl_types:t_inf(erl_types:t_list(),Type).

is_not_nil_list(Type) ->
    erl_types:t_is_list(Type) andalso  not erl_types:t_is_nil(Type).

bad_extraneous_map(CRng,STRng) ->
    CRngMap = map_part(CRng),
    STRngMap = map_part(STRng),
     not is_empty_map(CRngMap) andalso  not is_empty_map(STRngMap) andalso is_empty_map(erl_types:t_inf(CRngMap,STRngMap)).

map_part(Type) ->
    erl_types:t_inf(erl_types:t_map(),Type).

is_empty_map(Type) ->
    erl_types:t_is_equal(Type,erl_types:t_from_term(#{})).

check_missing(Contracts,SuccType) ->
    CRanges = [(erl_types:t_fun_range(C)) || C <- Contracts],
    AllCRange = erl_types:t_sup(CRanges),
    STRng = erl_types:t_fun_range(SuccType),
    STRngs = erl_types:t_elements(STRng),
    case [STR || STR <- STRngs,erl_types:t_is_none(erl_types:t_inf(STR,AllCRange))] of
        []->
            [];
        STRs->
            [{error,{missing_range,erl_types:t_sup(STRs),AllCRange}}]
    end.

-spec(process_contracts([contract_pair()],[erl_types:erl_type()]) -> erl_types:erl_type()).

process_contracts(OverContracts,Args) ->
    process_contracts(OverContracts,Args,erl_types:t_none()).

process_contracts([OverContract| Left],Args,AccRange) ->
    NewAccRange = case process_contract(OverContract,Args) of
        error->
            AccRange;
        {ok,Range}->
            erl_types:t_sup(AccRange,Range)
    end,
    process_contracts(Left,Args,NewAccRange);
process_contracts([],_Args,AccRange) ->
    AccRange.

-spec(process_contract(contract_pair(),[erl_types:erl_type()]) -> error|{ok,erl_types:erl_type()}).

process_contract({Contract,Constraints},CallTypes0) ->
    CallTypesFun = erl_types:t_fun(CallTypes0,erl_types:t_any()),
    ContArgsFun = erl_types:t_fun(erl_types:t_fun_args(Contract),erl_types:t_any()),
    ok,
    case solve_constraints(ContArgsFun,CallTypesFun,Constraints) of
        {ok,VarMap}->
            {ok,erl_types:t_subst(erl_types:t_fun_range(Contract),VarMap)};
        error->
            error
    end.

solve_constraints(Contract,Call,Constraints) ->
    CMap = insert_constraints(Constraints),
    Contract1 = erl_types:t_subst(Contract,CMap),
    ContrArgs = erl_types:t_fun_args(Contract1),
    CallArgs = erl_types:t_fun_args(Call),
    InfList = erl_types:t_inf_lists(ContrArgs,CallArgs),
    case erl_types:any_none_or_unit(InfList) of
        true->
            error;
        false->
            {ok,CMap}
    end.

-type(contracts()::dialyzer_codeserver:contracts()).

-spec(contracts_without_fun(contracts(),[_],dialyzer_callgraph:callgraph()) -> [raw_warning()]).

contracts_without_fun(Contracts,AllFuns0,Callgraph) ->
    AllFuns1 = [{dialyzer_callgraph:lookup_name(Label,Callgraph),Arity} || {Label,Arity} <- AllFuns0],
    AllFuns2 = [{M,F,A} || {{ok,{M,F,_}},A} <- AllFuns1],
    AllContractMFAs = maps:keys(Contracts),
    ErrorContractMFAs = AllContractMFAs -- AllFuns2,
    [(warn_spec_missing_fun(MFA,Contracts)) || MFA <- ErrorContractMFAs].

warn_spec_missing_fun({M,F,A} = MFA,Contracts) ->
    {{File,Line},_Contract,_Xtra} = maps:get(MFA,Contracts),
    WarningInfo = {File,Line,MFA},
    {warn_contract_syntax,WarningInfo,{spec_missing_fun,[M, F, A]}}.

insert_constraints(Constraints) ->
    insert_constraints(Constraints,maps:new()).

insert_constraints([{subtype,Type1,Type2}| Left],Map) ->
    case erl_types:t_is_var(Type1) of
        true->
            Name = erl_types:t_var_name(Type1),
            Map1 = case maps:find(Name,Map) of
                error->
                    maps:put(Name,Type2,Map);
                {ok,VarType}->
                    maps:put(Name,erl_types:t_inf(VarType,Type2),Map)
            end,
            insert_constraints(Left,Map1);
        false->
            throw({error,io_lib:format("First argument of is_subtype constrai" "nt must be a type variable: ~tp\n",[Type1])})
    end;
insert_constraints([],Map) ->
    Map.

-type(types()::erl_types:type_table()).

-type(spec_data()::{TypeSpec::[_],Xtra::[_]}).

-spec(store_tmp_contract(module(),mfa(),file_line(),spec_data(),contracts(),types()) -> contracts()).

store_tmp_contract(Module,MFA,FileLine,{TypeSpec,Xtra},SpecMap,RecordsDict) ->
    TmpContract = contract_from_form(TypeSpec,Module,MFA,RecordsDict,FileLine),
    maps:put(MFA,{FileLine,TmpContract,Xtra},SpecMap).

contract_from_form(Forms,Module,MFA,RecDict,FileLine) ->
    {CFuns,Forms1} = contract_from_form(Forms,Module,MFA,RecDict,FileLine,[],[]),
    #tmp_contract{contract_funs = CFuns,forms = Forms1}.

contract_from_form([{type,_,'fun',[_, _]} = Form| Left],Module,MFA,RecDict,FileLine,TypeAcc,FormAcc) ->
    TypeFun = fun (ExpTypes,RecordTable,Cache)->
        {NewType,NewCache} = try from_form_with_check(Form,ExpTypes,Module,MFA,RecordTable,Cache)
            catch
                throw:{error,Msg}->
                    {File,Line} = FileLine,
                    NewMsg = io_lib:format("~ts:~p: ~ts",[filename:basename(File), Line, Msg]),
                    throw({error,NewMsg}) end,
        NewTypeNoVars = erl_types:subst_all_vars_to_any(NewType),
        {{NewTypeNoVars,[]},NewCache} end,
    NewTypeAcc = [TypeFun| TypeAcc],
    NewFormAcc = [{Form,[]}| FormAcc],
    contract_from_form(Left,Module,MFA,RecDict,FileLine,NewTypeAcc,NewFormAcc);
contract_from_form([{type,_L1,bounded_fun,[{type,_L2,'fun',[_, _]} = Form, Constr]}| Left],Module,MFA,RecDict,FileLine,TypeAcc,FormAcc) ->
    TypeFun = fun (ExpTypes,RecordTable,Cache)->
        {Constr1,VarTable,Cache1} = process_constraints(Constr,Module,MFA,RecDict,ExpTypes,RecordTable,Cache),
        {NewType,NewCache} = from_form_with_check(Form,ExpTypes,Module,MFA,RecordTable,VarTable,Cache1),
        NewTypeNoVars = erl_types:subst_all_vars_to_any(NewType),
        {{NewTypeNoVars,Constr1},NewCache} end,
    NewTypeAcc = [TypeFun| TypeAcc],
    NewFormAcc = [{Form,Constr}| FormAcc],
    contract_from_form(Left,Module,MFA,RecDict,FileLine,NewTypeAcc,NewFormAcc);
contract_from_form([],_Mod,_MFA,_RecDict,_FileLine,TypeAcc,FormAcc) ->
    {lists:reverse(TypeAcc),lists:reverse(FormAcc)}.

process_constraints(Constrs,Module,MFA,RecDict,ExpTypes,RecordTable,Cache) ->
    {Init0,NewCache} = initialize_constraints(Constrs,Module,MFA,RecDict,ExpTypes,RecordTable,Cache),
    Init = remove_cycles(Init0),
    constraints_fixpoint(Init,Module,MFA,RecDict,ExpTypes,RecordTable,NewCache).

initialize_constraints(Constrs,Module,MFA,RecDict,ExpTypes,RecordTable,Cache) ->
    initialize_constraints(Constrs,Module,MFA,RecDict,ExpTypes,RecordTable,Cache,[]).

initialize_constraints([],_Module,_MFA,_RecDict,_ExpTypes,_RecordTable,Cache,Acc) ->
    {Acc,Cache};
initialize_constraints([Constr| Rest],Module,MFA,RecDict,ExpTypes,RecordTable,Cache,Acc) ->
    case Constr of
        {type,_,constraint,[{atom,_,is_subtype}, [Type1, Type2]]}->
            VarTable = erl_types:var_table__new(),
            {T1,NewCache} = final_form(Type1,ExpTypes,Module,MFA,RecordTable,VarTable,Cache),
            Entry = {T1,Type2},
            initialize_constraints(Rest,Module,MFA,RecDict,ExpTypes,RecordTable,NewCache,[Entry| Acc]);
        {type,_,constraint,[{atom,_,Name}, List]}->
            N = length(List),
            throw({error,io_lib:format("Unsupported type guard ~tw/~w\n",[Name, N])})
    end.

constraints_fixpoint(Constrs,Module,MFA,RecDict,ExpTypes,RecordTable,Cache) ->
    VarTable = erl_types:var_table__new(),
    {VarTab,NewCache} = constraints_to_dict(Constrs,Module,MFA,RecDict,ExpTypes,RecordTable,VarTable,Cache),
    constraints_fixpoint(VarTab,Module,MFA,Constrs,RecDict,ExpTypes,RecordTable,NewCache).

constraints_fixpoint(OldVarTab,Module,MFA,Constrs,RecDict,ExpTypes,RecordTable,Cache) ->
    {NewVarTab,NewCache} = constraints_to_dict(Constrs,Module,MFA,RecDict,ExpTypes,RecordTable,OldVarTab,Cache),
    case NewVarTab of
        OldVarTab->
            Fun = fun (Key,Value,Acc)->
                [{subtype,erl_types:t_var(Key),Value}| Acc] end,
            FinalConstrs = maps:fold(Fun,[],NewVarTab),
            {FinalConstrs,NewVarTab,NewCache};
        _Other->
            constraints_fixpoint(NewVarTab,Module,MFA,Constrs,RecDict,ExpTypes,RecordTable,NewCache)
    end.

final_form(Form,ExpTypes,Module,MFA,RecordTable,VarTable,Cache) ->
    from_form_with_check(Form,ExpTypes,Module,MFA,RecordTable,VarTable,Cache).

from_form_with_check(Form,ExpTypes,Module,MFA,RecordTable,Cache) ->
    VarTable = erl_types:var_table__new(),
    from_form_with_check(Form,ExpTypes,Module,MFA,RecordTable,VarTable,Cache).

from_form_with_check(Form,ExpTypes,Module,MFA,RecordTable,VarTable,Cache) ->
    {_,F,A} = MFA,
    Site = {spec,{Module,F,A}},
    C1 = erl_types:t_check_record_fields(Form,ExpTypes,Site,RecordTable,VarTable,Cache),
    erl_types:t_from_form(Form,ExpTypes,Site,RecordTable,VarTable,C1).

constraints_to_dict(Constrs,Module,MFA,RecDict,ExpTypes,RecordTable,VarTab,Cache) ->
    {Subtypes,NewCache} = constraints_to_subs(Constrs,Module,MFA,RecDict,ExpTypes,RecordTable,VarTab,Cache,[]),
    {insert_constraints(Subtypes),NewCache}.

constraints_to_subs([],_Module,_MFA,_RecDict,_ExpTypes,_RecordTable,_VarTab,Cache,Acc) ->
    {Acc,Cache};
constraints_to_subs([{T1,Form2}| Rest],Module,MFA,RecDict,ExpTypes,RecordTable,VarTab,Cache,Acc) ->
    {T2,NewCache} = final_form(Form2,ExpTypes,Module,MFA,RecordTable,VarTab,Cache),
    NewAcc = [{subtype,T1,T2}| Acc],
    constraints_to_subs(Rest,Module,MFA,RecDict,ExpTypes,RecordTable,VarTab,NewCache,NewAcc).

remove_cycles(Constrs0) ->
    Uses = find_uses(Constrs0),
    G = digraph:new(),
    Vs0 = [V || {V,_} <- Uses] ++ [V || {_,V} <- Uses],
    Vs = lists:usort(Vs0),
    lists:foreach(fun (V)->
        _ = digraph:add_vertex(G,V) end,Vs),
    lists:foreach(fun ({From,To})->
        _ = digraph:add_edge(G,{From,To},From,To,[]) end,Uses),
    ok = remove_cycles(G,Vs),
    ToRemove = ordsets:subtract(ordsets:from_list(Uses),ordsets:from_list(digraph:edges(G))),
    Constrs = remove_uses(ToRemove,Constrs0),
    digraph:delete(G),
    Constrs.

find_uses([{Var,Form}| Constrs]) ->
    UsedVars = form_vars(Form,[]),
    VarName = erl_types:t_var_name(Var),
    [{VarName,UsedVar} || UsedVar <- UsedVars] ++ find_uses(Constrs);
find_uses([]) ->
    [].

form_vars({var,_,_},Vs) ->
    Vs;
form_vars({var,_,V},Vs) ->
    [V| Vs];
form_vars(T,Vs)
    when is_tuple(T)->
    form_vars(tuple_to_list(T),Vs);
form_vars([E| Es],Vs) ->
    form_vars(Es,form_vars(E,Vs));
form_vars(_,Vs) ->
    Vs.

remove_cycles(G,Vs) ->
    NumberOfEdges = digraph:no_edges(G),
    lists:foreach(fun (V)->
        case digraph:get_cycle(G,V) of
            false->
                true;
            [V]->
                digraph:del_edge(G,{V,V});
            [V, V1| _]->
                digraph:del_edge(G,{V,V1})
        end end,Vs),
    case digraph:no_edges(G) =:= NumberOfEdges of
        true->
            ok;
        false->
            remove_cycles(G,Vs)
    end.

remove_uses([],Constrs) ->
    Constrs;
remove_uses([{Var,Use}| ToRemove],Constrs0) ->
    Constrs = remove_uses(Var,Use,Constrs0),
    remove_uses(ToRemove,Constrs).

remove_uses(_Var,_Use,[]) ->
    [];
remove_uses(Var,Use,[Constr| Constrs]) ->
    {V,Form} = Constr,
    NewConstr = case erl_types:t_var_name(V) =:= Var of
        true->
            {V,remove_use(Form,Use)};
        false->
            Constr
    end,
    [NewConstr| remove_uses(Var,Use,Constrs)].

remove_use({var,L,V},V) ->
    {var,L,_};
remove_use(T,V)
    when is_tuple(T)->
    list_to_tuple(remove_use(tuple_to_list(T),V));
remove_use([E| Es],V) ->
    [remove_use(E,V)| remove_use(Es,V)];
remove_use(T,_V) ->
    T.

general_domain(List) ->
    general_domain(List,erl_types:t_none()).

general_domain([{Sig,Constraints}| Left],AccSig) ->
    Map = insert_constraints(Constraints),
    Sig1 = erl_types:t_subst(Sig,Map),
    general_domain(Left,erl_types:t_sup(AccSig,Sig1));
general_domain([],AccSig) ->
    AccSig1 = erl_types:subst_all_vars_to_any(AccSig),
    erl_types:t_fun_args(AccSig1).

-spec(get_invalid_contract_warnings([module()],dialyzer_codeserver:codeserver(),dialyzer_plt:plt()) -> [raw_warning()]).

get_invalid_contract_warnings(Modules,CodeServer,Plt) ->
    get_invalid_contract_warnings_modules(Modules,CodeServer,Plt,[]).

get_invalid_contract_warnings_modules([Mod| Mods],CodeServer,Plt,Acc) ->
    Contracts1 = dialyzer_codeserver:lookup_mod_contracts(Mod,CodeServer),
    NewAcc = case maps:size(Contracts1) =:= 0 of
        true->
            Acc;
        false->
            Contracts2 = maps:to_list(Contracts1),
            Records = dialyzer_codeserver:lookup_mod_records(Mod,CodeServer),
            Opaques = erl_types:t_opaque_from_records(Records),
            get_invalid_contract_warnings_funs(Contracts2,Plt,Records,Opaques,Acc)
    end,
    get_invalid_contract_warnings_modules(Mods,CodeServer,Plt,NewAcc);
get_invalid_contract_warnings_modules([],_CodeServer,_Plt,Acc) ->
    Acc.

get_invalid_contract_warnings_funs([{MFA,{FileLine,Contract,_Xtra}}| Left],Plt,RecDict,Opaques,Acc) ->
    case dialyzer_plt:lookup(Plt,MFA) of
        none->
            get_invalid_contract_warnings_funs(Left,Plt,RecDict,Opaques,Acc);
        {value,{Ret,Args}}->
            Sig = erl_types:t_fun(Args,Ret),
            {M,_F,_A} = MFA,
            {File,Line} = FileLine,
            WarningInfo = {File,Line,MFA},
            NewAcc = case check_contract(Contract,Sig,Opaques) of
                {error,invalid_contract}->
                    [invalid_contract_warning(MFA,WarningInfo,Sig,RecDict)| Acc];
                {error,{opaque_mismatch,T2}}->
                    W = contract_opaque_warning(MFA,WarningInfo,T2,Sig,RecDict),
                    [W| Acc];
                {error,{overlapping_contract,[]}}->
                    [overlapping_contract_warning(MFA,WarningInfo)| Acc];
                {range_warnings,Errors}->
                    Fun = fun ({error,{extra_range,ExtraRanges,STRange}},Acc0)->
                        Warn = case t_from_forms_without_remote(Contract#contract.forms,MFA,RecDict) of
                            {ok,NoRemoteType}->
                                CRet = erl_types:t_fun_range(NoRemoteType),
                                erl_types:t_is_subtype(ExtraRanges,CRet);
                            unsupported->
                                true
                        end,
                        case Warn of
                            true->
                                [extra_range_warning(MFA,WarningInfo,ExtraRanges,STRange)| Acc0];
                            false->
                                Acc0
                        end;({error,{missing_range,ExtraRanges,CRange}},Acc0)->
                        [missing_range_warning(MFA,WarningInfo,ExtraRanges,CRange)| Acc0] end,
                    lists:foldl(Fun,Acc,Errors);
                {error,Msg}->
                    [{warn_contract_syntax,WarningInfo,Msg}| Acc];
                ok->
                    {M,F,A} = MFA,
                    CSig0 = get_contract_signature(Contract),
                    CSig = erl_types:subst_all_vars_to_any(CSig0),
                    case erl_bif_types:is_known(M,F,A) of
                        true->
                            BifArgs = erl_bif_types:arg_types(M,F,A),
                            BifRet = erl_bif_types:type(M,F,A),
                            BifSig = erl_types:t_fun(BifArgs,BifRet),
                            case check_contract(Contract,BifSig,Opaques) of
                                {error,_}->
                                    [invalid_contract_warning(MFA,WarningInfo,BifSig,RecDict)| Acc];
                                {range_warnings,_}->
                                    picky_contract_check(CSig,BifSig,MFA,WarningInfo,Contract,RecDict,Acc);
                                ok->
                                    picky_contract_check(CSig,BifSig,MFA,WarningInfo,Contract,RecDict,Acc)
                            end;
                        false->
                            picky_contract_check(CSig,Sig,MFA,WarningInfo,Contract,RecDict,Acc)
                    end
            end,
            get_invalid_contract_warnings_funs(Left,Plt,RecDict,Opaques,NewAcc)
    end;
get_invalid_contract_warnings_funs([],_Plt,_RecDict,_Opaques,Acc) ->
    Acc.

invalid_contract_warning({M,F,A},WarningInfo,SuccType,RecDict) ->
    SuccTypeStr = dialyzer_utils:format_sig(SuccType,RecDict),
    {warn_contract_types,WarningInfo,{invalid_contract,[M, F, A, SuccTypeStr]}}.

contract_opaque_warning({M,F,A},WarningInfo,OpType,SuccType,RecDict) ->
    OpaqueStr = erl_types:t_to_string(OpType),
    SuccTypeStr = dialyzer_utils:format_sig(SuccType,RecDict),
    {warn_contract_types,WarningInfo,{contract_with_opaque,[M, F, A, OpaqueStr, SuccTypeStr]}}.

overlapping_contract_warning({M,F,A},WarningInfo) ->
    {warn_contract_types,WarningInfo,{overlapping_contract,[M, F, A]}}.

extra_range_warning({M,F,A},WarningInfo,ExtraRanges,STRange) ->
    ERangesStr = erl_types:t_to_string(ExtraRanges),
    STRangeStr = erl_types:t_to_string(STRange),
    {warn_contract_supertype,WarningInfo,{extra_range,[M, F, A, ERangesStr, STRangeStr]}}.

missing_range_warning({M,F,A},WarningInfo,ExtraRanges,CRange) ->
    ERangesStr = erl_types:t_to_string(ExtraRanges),
    CRangeStr = erl_types:t_to_string(CRange),
    {warn_contract_subtype,WarningInfo,{missing_range,[M, F, A, ERangesStr, CRangeStr]}}.

picky_contract_check(CSig0,Sig0,MFA,WarningInfo,Contract,RecDict,Acc) ->
    CSig = erl_types:t_abstract_records(CSig0,RecDict),
    Sig = erl_types:t_abstract_records(Sig0,RecDict),
    case erl_types:t_is_equal(CSig,Sig) of
        true->
            Acc;
        false->
            case erl_types:t_is_none(erl_types:t_fun_range(Sig)) andalso erl_types:t_is_unit(erl_types:t_fun_range(CSig)) of
                true->
                    Acc;
                false->
                    case extra_contract_warning(MFA,WarningInfo,Contract,CSig0,Sig0,RecDict) of
                        no_warning->
                            Acc;
                        {warning,Warning}->
                            [Warning| Acc]
                    end
            end
    end.

extra_contract_warning(MFA,WarningInfo,Contract,CSig,Sig,RecDict) ->
    {IsRemoteTypesRelated,SubtypeRelation} = is_remote_types_related(Contract,CSig,Sig,MFA,RecDict),
    case IsRemoteTypesRelated of
        true->
            no_warning;
        false->
            {M,F,A} = MFA,
            SigString = lists:flatten(dialyzer_utils:format_sig(Sig,RecDict)),
            ContractString = contract_to_string(Contract),
            {Tag,Msg} = case SubtypeRelation of
                contract_is_subtype->
                    {warn_contract_subtype,{contract_subtype,[M, F, A, ContractString, SigString]}};
                contract_is_supertype->
                    {warn_contract_supertype,{contract_supertype,[M, F, A, ContractString, SigString]}};
                neither->
                    {warn_contract_not_equal,{contract_diff,[M, F, A, ContractString, SigString]}}
            end,
            {warning,{Tag,WarningInfo,Msg}}
    end.

is_remote_types_related(Contract,CSig,Sig,MFA,RecDict) ->
    case erl_types:t_is_subtype(CSig,Sig) of
        true->
            {false,contract_is_subtype};
        false->
            case erl_types:t_is_subtype(Sig,CSig) of
                true->
                    case t_from_forms_without_remote(Contract#contract.forms,MFA,RecDict) of
                        {ok,NoRemoteTypeSig}->
                            case blame_remote(CSig,NoRemoteTypeSig,Sig) of
                                true->
                                    {true,neither};
                                false->
                                    {false,contract_is_supertype}
                            end;
                        unsupported->
                            {false,contract_is_supertype}
                    end;
                false->
                    {false,neither}
            end
    end.

t_from_forms_without_remote([{FType,[]}],MFA,RecDict) ->
    Site = {spec,MFA},
    Type1 = erl_types:t_from_form_without_remote(FType,Site,RecDict),
    {ok,erl_types:subst_all_vars_to_any(Type1)};
t_from_forms_without_remote([{_FType,_Constrs}],_MFA,_RecDict) ->
    unsupported;
t_from_forms_without_remote(_Forms,_MFA,_RecDict) ->
    unsupported.

blame_remote(ContractSig,NoRemoteContractSig,Sig) ->
    CArgs = erl_types:t_fun_args(ContractSig),
    CRange = erl_types:t_fun_range(ContractSig),
    NRArgs = erl_types:t_fun_args(NoRemoteContractSig),
    NRRange = erl_types:t_fun_range(NoRemoteContractSig),
    SArgs = erl_types:t_fun_args(Sig),
    SRange = erl_types:t_fun_range(Sig),
    blame_remote_list([CRange| CArgs],[NRRange| NRArgs],[SRange| SArgs]).

blame_remote_list([],[],[]) ->
    true;
blame_remote_list([CArg| CArgs],[NRArg| NRArgs],[SArg| SArgs]) ->
    case erl_types:t_is_equal(CArg,NRArg) of
        true->
            case  not erl_types:t_is_equal(CArg,SArg) of
                true->
                    false;
                false->
                    blame_remote_list(CArgs,NRArgs,SArgs)
            end;
        false->
            case erl_types:t_is_subtype(SArg,NRArg) andalso  not erl_types:t_is_subtype(NRArg,SArg) of
                true->
                    false;
                false->
                    blame_remote_list(CArgs,NRArgs,SArgs)
            end
    end.
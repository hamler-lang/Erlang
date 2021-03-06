-file("dialyzer_worker.erl", 1).

-module(dialyzer_worker).

-export([launch/4]).

-export_type([worker/0]).

-opaque(worker()::pid()).

-type(mode()::dialyzer_coordinator:mode()).

-type(coordinator()::dialyzer_coordinator:coordinator()).

-type(init_data()::dialyzer_coordinator:init_data()).

-type(job()::dialyzer_coordinator:job()).

-record(state,{mode::mode(),job::job(),coordinator::coordinator(),init_data::init_data(),depends_on = []::list()}).

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

-file("dialyzer_worker.erl", 37).

-spec(launch(mode(),job(),init_data(),coordinator()) -> worker()).

launch(Mode,Job,InitData,Coordinator) ->
    State = #state{mode = Mode,job = Job,init_data = InitData,coordinator = Coordinator},
    spawn_link(fun ()->
        init(State) end).

init(#state{job = SCC,mode = Mode,init_data = InitData,coordinator = Coordinator} = State)
    when Mode =:= typesig;
    Mode =:= dataflow->
    DependsOnSCCs = dialyzer_succ_typings:find_depends_on(SCC,InitData),
    ok,
    Pids = dialyzer_coordinator:sccs_to_pids(DependsOnSCCs,Coordinator),
    ok,
    DependsOn = [{Pid,monitor(process,Pid)} || Pid <- Pids],
    loop(updating,State#state{depends_on = DependsOn});
init(#state{mode = Mode} = State)
    when Mode =:= compile;
    Mode =:= warnings->
    loop(running,State).

loop(updating,#state{mode = Mode} = State)
    when Mode =:= typesig;
    Mode =:= dataflow->
    ok,
    NextStatus = case waits_more_success_typings(State) of
        true->
            waiting;
        false->
            running
    end,
    loop(NextStatus,State);
loop(waiting,#state{mode = Mode} = State)
    when Mode =:= typesig;
    Mode =:= dataflow->
    ok,
    NewState = wait_for_success_typings(State),
    loop(updating,NewState);
loop(running,#state{mode = compile} = State) ->
    request_activation(State),
    ok,
    Result = case start_compilation(State) of
        {ok,EstimatedSize,Data}->
            Label = ask_coordinator_for_label(EstimatedSize,State),
            continue_compilation(Label,Data);
        {error,_Reason} = Error->
            Error
    end,
    report_to_coordinator(Result,State);
loop(running,#state{mode = warnings} = State) ->
    request_activation(State),
    ok,
    Result = collect_warnings(State),
    report_to_coordinator(Result,State);
loop(running,#state{mode = Mode} = State)
    when Mode =:= typesig;
    Mode =:= dataflow->
    request_activation(State),
    ok,
    NotFixpoint = do_work(State),
    report_to_coordinator(NotFixpoint,State).

waits_more_success_typings(#state{depends_on = Depends}) ->
    Depends =/= [].

wait_for_success_typings(#state{depends_on = DependsOn} = State) ->
    receive {'DOWN',Ref,process,Pid,_Info}->
        ok,
        State#state{depends_on = DependsOn -- [{Pid,Ref}]} after 5000->
        ok,
        State end.

request_activation(#state{coordinator = Coordinator}) ->
    dialyzer_coordinator:request_activation(Coordinator).

do_work(#state{mode = Mode,job = Job,init_data = InitData}) ->
    case Mode of
        typesig->
            dialyzer_succ_typings:find_succ_types_for_scc(Job,InitData);
        dataflow->
            dialyzer_succ_typings:refine_one_module(Job,InitData)
    end.

report_to_coordinator(Result,#state{job = Job,coordinator = Coordinator}) ->
    ok,
    dialyzer_coordinator:job_done(Job,Result,Coordinator).

start_compilation(#state{job = Job,init_data = InitData}) ->
    dialyzer_analysis_callgraph:start_compilation(Job,InitData).

ask_coordinator_for_label(EstimatedSize,#state{coordinator = Coordinator}) ->
    dialyzer_coordinator:get_next_label(EstimatedSize,Coordinator).

continue_compilation(Label,Data) ->
    dialyzer_analysis_callgraph:continue_compilation(Label,Data).

collect_warnings(#state{job = Job,init_data = InitData}) ->
    dialyzer_succ_typings:collect_warnings(Job,InitData).
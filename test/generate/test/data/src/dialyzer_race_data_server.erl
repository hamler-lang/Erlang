-file("dialyzer_race_data_server.erl", 1).

-module(dialyzer_race_data_server).

-export([new/0, duplicate/1, stop/1, call/2, cast/2]).

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

-file("dialyzer_race_data_server.erl", 31).

-record(state,{race_code = dict:new()::dict:dict(),public_tables = []::[label()],named_tables = []::[string()],beh_api_calls = []::[{mfa(),mfa()}]}).

-spec(new() -> pid()).

new() ->
    spawn_link(fun ()->
        loop(#state{}) end).

-spec(duplicate(pid()) -> pid()).

duplicate(Server) ->
    call(dup,Server).

-spec(stop(pid()) -> ok).

stop(Server) ->
    cast(stop,Server).

-spec(call(atom(),pid()) -> term()).

call(Query,Server) ->
    Ref = make_ref(),
    Server ! {call,self(),Ref,Query},
    receive {Ref,Reply}->
        Reply end.

-spec(cast(atom()|{atom(),term()},pid()) -> ok).

cast(Message,Server) ->
    Server ! {cast,Message},
    ok.

loop(State) ->
    receive {call,From,Ref,Query}->
        Reply = handle_call(Query,State),
        From ! {Ref,Reply},
        loop(State);
    {cast,stop}->
        ok;
    {cast,Message}->
        NewState = handle_cast(Message,State),
        loop(NewState) end.

handle_cast(race_code_new,State) ->
    State#state{race_code = dict:new()};
handle_cast({Tag,Data},State) ->
    case Tag of
        renew_race_info->
            renew_race_info_handler(Data,State);
        renew_race_code->
            renew_race_code_handler(Data,State);
        renew_race_public_tables->
            renew_race_public_tables_handler(Data,State);
        put_race_code->
            State#state{race_code = Data};
        put_public_tables->
            State#state{public_tables = Data};
        put_named_tables->
            State#state{named_tables = Data};
        put_behaviour_api_calls->
            State#state{beh_api_calls = Data}
    end.

handle_call(Query,#state{race_code = RaceCode,public_tables = PublicTables,named_tables = NamedTables,beh_api_calls = BehApiCalls} = State) ->
    case Query of
        dup->
            spawn_link(fun ()->
                loop(State) end);
        get_race_code->
            RaceCode;
        get_public_tables->
            PublicTables;
        get_named_tables->
            NamedTables;
        get_behaviour_api_calls->
            BehApiCalls
    end.

renew_race_info_handler({RaceCode,PublicTables,NamedTables},#state{} = State) ->
    State#state{race_code = RaceCode,public_tables = PublicTables,named_tables = NamedTables}.

renew_race_code_handler({Fun,FunArgs,Code},#state{race_code = RaceCode} = State) ->
    State#state{race_code = dict:store(Fun,[FunArgs, Code],RaceCode)}.

renew_race_public_tables_handler(VarLabel,#state{public_tables = PT} = State) ->
    State#state{public_tables = ordsets:add_element(VarLabel,PT)}.
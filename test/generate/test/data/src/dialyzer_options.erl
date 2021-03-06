-file("dialyzer_options.erl", 1).

-module(dialyzer_options).

-export([build/1, build_warnings/2]).

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

-file("dialyzer_options.erl", 24).

-spec(build(dial_options()) -> #options{}|{error,string()}).

build(Opts) ->
    DefaultWarns = [warn_return_no_exit, warn_not_called, warn_non_proper_list, warn_fun_app, warn_matching, warn_opaque, warn_callgraph, warn_failing_call, warn_bin_construction, warn_map_construction, warn_contract_range, warn_contract_types, warn_contract_syntax, warn_behaviour, warn_undefined_callbacks],
    DefaultWarns1 = ordsets:from_list(DefaultWarns),
    InitPlt = dialyzer_plt:get_default_plt(),
    DefaultOpts = #options{},
    DefaultOpts1 = DefaultOpts#options{legal_warnings = DefaultWarns1,init_plts = [InitPlt]},
    try Opts1 = preprocess_opts(Opts),
    NewOpts = build_options(Opts1,DefaultOpts1),
    postprocess_opts(NewOpts)
        catch
            throw:{dialyzer_options_error,Msg}->
                {error,Msg} end.

preprocess_opts([]) ->
    [];
preprocess_opts([{init_plt,File}| Opts]) ->
    [{plts,[File]}| preprocess_opts(Opts)];
preprocess_opts([Opt| Opts]) ->
    [Opt| preprocess_opts(Opts)].

postprocess_opts(Opts = #options{}) ->
    check_file_existence(Opts),
    Opts1 = check_output_plt(Opts),
    adapt_get_warnings(Opts1).

check_file_existence(#options{analysis_type = plt_remove}) ->
    ok;
check_file_existence(#options{files = Files,files_rec = FilesRec}) ->
    assert_filenames_exist(Files),
    assert_filenames_exist(FilesRec).

check_output_plt(Opts = #options{analysis_type = Mode,from = From,output_plt = OutPLT}) ->
    case is_plt_mode(Mode) of
        true->
            case From =:= byte_code of
                true->
                    Opts;
                false->
                    Msg = "Byte code compiled with debug_info is needed t" "o build the PLT",
                    throw({dialyzer_error,Msg})
            end;
        false->
            case OutPLT =:= none of
                true->
                    Opts;
                false->
                    Msg = io_lib:format("Output PLT cannot be specified i" "n analysis mode ~w",[Mode]),
                    throw({dialyzer_error,lists:flatten(Msg)})
            end
    end.

adapt_get_warnings(Opts = #options{analysis_type = Mode,get_warnings = Warns}) ->
    case is_plt_mode(Mode) of
        true->
            case Warns =:= maybe of
                true->
                    Opts#options{get_warnings = false};
                false->
                    Opts
            end;
        false->
            case Warns =:= maybe of
                true->
                    Opts#options{get_warnings = true};
                false->
                    Opts
            end
    end.

-spec(bad_option(string(),term()) -> no_return()).

bad_option(String,Term) ->
    Msg = io_lib:format("~ts: ~tP",[String, Term, 25]),
    throw({dialyzer_options_error,lists:flatten(Msg)}).

build_options([{OptName,undefined}| Rest],Options)
    when is_atom(OptName)->
    build_options(Rest,Options);
build_options([{OptionName,Value} = Term| Rest],Options) ->
    case OptionName of
        apps->
            OldValues = Options#options.files_rec,
            AppDirs = get_app_dirs(Value),
            assert_filenames_form(Term,AppDirs),
            build_options(Rest,Options#options{files_rec = AppDirs ++ OldValues});
        files->
            assert_filenames_form(Term,Value),
            build_options(Rest,Options#options{files = Value});
        files_rec->
            OldValues = Options#options.files_rec,
            assert_filenames_form(Term,Value),
            build_options(Rest,Options#options{files_rec = Value ++ OldValues});
        analysis_type->
            NewOptions = case Value of
                succ_typings->
                    Options#options{analysis_type = Value};
                plt_add->
                    Options#options{analysis_type = Value};
                plt_build->
                    Options#options{analysis_type = Value};
                plt_check->
                    Options#options{analysis_type = Value};
                plt_remove->
                    Options#options{analysis_type = Value};
                dataflow->
                    bad_option("Analysis type is no longer supporte" "d",Term);
                old_style->
                    bad_option("Analysis type is no longer supporte" "d",Term);
                Other->
                    bad_option("Unknown analysis type",Other)
            end,
            assert_plt_op(Options,NewOptions),
            build_options(Rest,NewOptions);
        check_plt
            when is_boolean(Value)->
            build_options(Rest,Options#options{check_plt = Value});
        defines->
            assert_defines(Term,Value),
            OldVal = Options#options.defines,
            NewVal = ordsets:union(ordsets:from_list(Value),OldVal),
            build_options(Rest,Options#options{defines = NewVal});
        from
            when Value =:= byte_code;
            Value =:= src_code->
            build_options(Rest,Options#options{from = Value});
        get_warnings->
            build_options(Rest,Options#options{get_warnings = Value});
        plts->
            assert_filenames(Term,Value),
            build_options(Rest,Options#options{init_plts = Value});
        include_dirs->
            assert_filenames(Term,Value),
            OldVal = Options#options.include_dirs,
            NewVal = ordsets:union(ordsets:from_list(Value),OldVal),
            build_options(Rest,Options#options{include_dirs = NewVal});
        use_spec->
            build_options(Rest,Options#options{use_contracts = Value});
        old_style->
            bad_option("Analysis type is no longer supported",old_style);
        output_file->
            assert_filename(Value),
            build_options(Rest,Options#options{output_file = Value});
        output_format->
            assert_output_format(Value),
            build_options(Rest,Options#options{output_format = Value});
        filename_opt->
            assert_filename_opt(Value),
            build_options(Rest,Options#options{filename_opt = Value});
        indent_opt->
            build_options(Rest,Options#options{indent_opt = Value});
        output_plt->
            assert_filename(Value),
            build_options(Rest,Options#options{output_plt = Value});
        report_mode->
            build_options(Rest,Options#options{report_mode = Value});
        erlang_mode->
            build_options(Rest,Options#options{erlang_mode = true});
        warnings->
            NewWarnings = build_warnings(Value,Options#options.legal_warnings),
            build_options(Rest,Options#options{legal_warnings = NewWarnings});
        callgraph_file->
            assert_filename(Value),
            build_options(Rest,Options#options{callgraph_file = Value});
        timing->
            build_options(Rest,Options#options{timing = Value});
        solvers->
            assert_solvers(Value),
            build_options(Rest,Options#options{solvers = Value});
        native->
            build_options(Rest,Options#options{native = Value});
        native_cache->
            build_options(Rest,Options#options{native_cache = Value});
        _->
            bad_option("Unknown dialyzer command line option",Term)
    end;
build_options([],Options) ->
    Options.

get_app_dirs(Apps)
    when is_list(Apps)->
    dialyzer_cl_parse:get_lib_dir([(atom_to_list(A)) || A <- Apps]);
get_app_dirs(Apps) ->
    bad_option("Use a list of otp applications",Apps).

assert_filenames(Term,Files) ->
    assert_filenames_form(Term,Files),
    assert_filenames_exist(Files).

assert_filenames_form(Term,[FileName| Left])
    when length(FileName) >= 0->
    assert_filenames_form(Term,Left);
assert_filenames_form(_Term,[]) ->
    ok;
assert_filenames_form(Term,[_| _]) ->
    bad_option("Malformed or non-existing filename",Term).

assert_filenames_exist([FileName| Left]) ->
    case filelib:is_file(FileName) orelse filelib:is_dir(FileName) of
        true->
            ok;
        false->
            bad_option("No such file, directory or application",FileName)
    end,
    assert_filenames_exist(Left);
assert_filenames_exist([]) ->
    ok.

assert_filename(FileName)
    when length(FileName) >= 0->
    ok;
assert_filename(FileName) ->
    bad_option("Malformed or non-existing filename",FileName).

assert_defines(Term,[{Macro,_Value}| Defs])
    when is_atom(Macro)->
    assert_defines(Term,Defs);
assert_defines(_Term,[]) ->
    ok;
assert_defines(Term,[_| _]) ->
    bad_option("Malformed define",Term).

assert_output_format(raw) ->
    ok;
assert_output_format(formatted) ->
    ok;
assert_output_format(Term) ->
    bad_option("Illegal value for output_format",Term).

assert_filename_opt(basename) ->
    ok;
assert_filename_opt(fullpath) ->
    ok;
assert_filename_opt(Term) ->
    bad_option("Illegal value for filename_opt",Term).

assert_plt_op(#options{analysis_type = OldVal},#options{analysis_type = NewVal}) ->
    case is_plt_mode(OldVal) andalso is_plt_mode(NewVal) of
        true->
            bad_option("Options cannot be combined",[OldVal, NewVal]);
        false->
            ok
    end.

is_plt_mode(plt_add) ->
    true;
is_plt_mode(plt_build) ->
    true;
is_plt_mode(plt_remove) ->
    true;
is_plt_mode(plt_check) ->
    true;
is_plt_mode(succ_typings) ->
    false.

assert_solvers([]) ->
    ok;
assert_solvers([v1| Terms]) ->
    assert_solvers(Terms);
assert_solvers([v2| Terms]) ->
    assert_solvers(Terms);
assert_solvers([Term| _]) ->
    bad_option("Illegal value for solver",Term).

-spec(build_warnings([atom()],dial_warn_tags()) -> dial_warn_tags()).

build_warnings([Opt| Opts],Warnings) ->
    NewWarnings = case Opt of
        no_return->
            ordsets:del_element(warn_return_no_exit,Warnings);
        no_unused->
            ordsets:del_element(warn_not_called,Warnings);
        no_improper_lists->
            ordsets:del_element(warn_non_proper_list,Warnings);
        no_fun_app->
            ordsets:del_element(warn_fun_app,Warnings);
        no_match->
            ordsets:del_element(warn_matching,Warnings);
        no_opaque->
            ordsets:del_element(warn_opaque,Warnings);
        no_fail_call->
            ordsets:del_element(warn_failing_call,Warnings);
        no_contracts->
            Warnings1 = ordsets:del_element(warn_contract_syntax,Warnings),
            ordsets:del_element(warn_contract_types,Warnings1);
        no_behaviours->
            ordsets:del_element(warn_behaviour,Warnings);
        no_undefined_callbacks->
            ordsets:del_element(warn_undefined_callbacks,Warnings);
        unmatched_returns->
            ordsets:add_element(warn_umatched_return,Warnings);
        error_handling->
            ordsets:add_element(warn_return_only_exit,Warnings);
        race_conditions->
            ordsets:add_element(warn_race_condition,Warnings);
        no_missing_calls->
            ordsets:del_element(warn_callgraph,Warnings);
        specdiffs->
            S = ordsets:from_list([warn_contract_subtype, warn_contract_supertype, warn_contract_not_equal]),
            ordsets:union(S,Warnings);
        overspecs->
            ordsets:add_element(warn_contract_subtype,Warnings);
        underspecs->
            ordsets:add_element(warn_contract_supertype,Warnings);
        unknown->
            ordsets:add_element(warn_unknown,Warnings);
        OtherAtom->
            bad_option("Unknown dialyzer warning option",OtherAtom)
    end,
    build_warnings(Opts,NewWarnings);
build_warnings([],Warnings) ->
    Warnings.
-file("dialyzer.erl", 1).

-module(dialyzer).

-export([plain_cl/0, run/1, gui/0, gui/1, plt_info/1, format_warning/1, format_warning/2]).

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

-file("dialyzer.erl", 39).

-spec(plain_cl() -> no_return()).

plain_cl() ->
    case dialyzer_cl_parse:start() of
        {check_init,Opts}->
            cl_halt(cl_check_init(Opts),Opts);
        {plt_info,Opts}->
            cl_halt(cl_print_plt_info(Opts),Opts);
        {gui,Opts}->
            try check_gui_options(Opts)
                catch
                    throw:{dialyzer_error,Msg}->
                        cl_error(Msg) end,
            case Opts#options.check_plt of
                true->
                    case cl_check_init(Opts#options{get_warnings = false}) of
                        {ok,_}->
                            gui_halt(internal_gui(Opts),Opts);
                        {error,_} = Error->
                            cl_halt(Error,Opts)
                    end;
                false->
                    gui_halt(internal_gui(Opts),Opts)
            end;
        {cl,Opts}->
            case Opts#options.check_plt of
                true->
                    case cl_check_init(Opts#options{get_warnings = false}) of
                        {error,_} = Error->
                            cl_halt(Error,Opts);
                        {ok,_}->
                            cl_halt(cl(Opts),Opts)
                    end;
                false->
                    cl_halt(cl(Opts),Opts)
            end;
        {error,Msg}->
            cl_error(Msg)
    end.

cl_check_init(#options{analysis_type = AnalType} = Opts) ->
    case AnalType of
        plt_build->
            {ok,0};
        plt_add->
            {ok,0};
        plt_remove->
            {ok,0};
        Other
            when Other =:= succ_typings;
            Other =:= plt_check->
            F = fun ()->
                NewOpts = Opts#options{analysis_type = plt_check},
                {Ret,_Warnings} = dialyzer_cl:start(NewOpts),
                Ret end,
            doit(F)
    end.

cl_print_plt_info(Opts) ->
    F = fun ()->
        print_plt_info(Opts) end,
    doit(F).

print_plt_info(#options{init_plts = PLTs,output_file = OutputFile}) ->
    PLTInfo = get_plt_info(PLTs),
    do_print_plt_info(PLTInfo,OutputFile).

get_plt_info([PLT| PLTs]) ->
    String = case dialyzer_plt:included_files(PLT) of
        {ok,Files}->
            io_lib:format("The PLT ~ts includes the following files" ":\n~tp\n\n",[PLT, Files]);
        {error,read_error}->
            Msg = io_lib:format("Could not read the PLT file ~tp\n\n",[PLT]),
            throw({dialyzer_error,Msg});
        {error,no_such_file}->
            Msg = io_lib:format("The PLT file ~tp does not exist\n\n",[PLT]),
            throw({dialyzer_error,Msg})
    end,
    String ++ get_plt_info(PLTs);
get_plt_info([]) ->
    "".

do_print_plt_info(PLTInfo,OutputFile) ->
    case OutputFile =:= none of
        true->
            io:format("~ts",[PLTInfo]),
            0;
        false->
            case file:open(OutputFile,[write]) of
                {ok,FileDesc}->
                    io:format(FileDesc,"~ts",[PLTInfo]),
                    ok = file:close(FileDesc),
                    0;
                {error,Reason}->
                    Msg1 = io_lib:format("Could not open output file ~tp, " "Reason: ~p\n",[OutputFile, Reason]),
                    throw({dialyzer_error,Msg1})
            end
    end.

cl(Opts) ->
    F = fun ()->
        {Ret,_Warnings} = dialyzer_cl:start(Opts),
        Ret end,
    doit(F).

-spec(run(dial_options()) -> [dial_warning()]).

run(Opts) ->
    try dialyzer_options:build([{report_mode,quiet}, {erlang_mode,true}| Opts]) of 
        {error,Msg}->
            throw({dialyzer_error,Msg});
        OptsRecord->
            ok = check_init(OptsRecord),
            case dialyzer_cl:start(OptsRecord) of
                {2,Warnings}->
                    Warnings;
                {0,_}->
                    []
            end
        catch
            throw:{dialyzer_error,ErrorMsg}->
                error({dialyzer_error,lists:flatten(ErrorMsg)}) end.

check_init(#options{analysis_type = plt_check}) ->
    ok;
check_init(#options{check_plt = true} = OptsRecord) ->
    case cl_check_init(OptsRecord) of
        {ok,_}->
            ok;
        {error,Msg}->
            throw({dialyzer_error,Msg})
    end;
check_init(#options{check_plt = false}) ->
    ok.

internal_gui(OptsRecord) ->
    F = fun ()->
        dialyzer_gui_wx:start(OptsRecord),
        0 end,
    doit(F).

-spec(gui() -> ok).

gui() ->
    gui([]).

-spec(gui(dial_options()) -> ok).

gui(Opts) ->
    try dialyzer_options:build([{report_mode,quiet}| Opts]) of 
        {error,Msg}->
            throw({dialyzer_error,Msg});
        OptsRecord->
            ok = check_gui_options(OptsRecord),
            ok = check_init(OptsRecord),
            F = fun ()->
                dialyzer_gui_wx:start(OptsRecord) end,
            case doit(F) of
                {ok,_}->
                    ok;
                {error,Msg}->
                    throw({dialyzer_error,Msg})
            end
        catch
            throw:{dialyzer_error,ErrorMsg}->
                error({dialyzer_error,lists:flatten(ErrorMsg)}) end.

check_gui_options(#options{analysis_type = succ_typings}) ->
    ok;
check_gui_options(#options{analysis_type = Mode}) ->
    Msg = io_lib:format("Analysis mode ~w is illegal in GUI mode",[Mode]),
    throw({dialyzer_error,Msg}).

-spec(plt_info(file:filename()) -> {ok,[{files,[file:filename()]}]}|{error,atom()}).

plt_info(Plt) ->
    case dialyzer_plt:included_files(Plt) of
        {ok,Files}->
            {ok,[{files,Files}]};
        Error->
            Error
    end.

-type(doit_ret()::{ok,dial_ret()}|{error,string()}).

doit(F) ->
    try {ok,F()}
        catch
            throw:{dialyzer_error,Msg}->
                {error,lists:flatten(Msg)} end.

-spec(cl_error(string()) -> no_return()).

cl_error(Msg) ->
    cl_halt({error,Msg},#options{}).

-spec(gui_halt(doit_ret(),#options{}) -> no_return()).

gui_halt(R,Opts) ->
    cl_halt(R,Opts#options{report_mode = quiet}).

-spec(cl_halt(doit_ret(),#options{}) -> no_return()).

cl_halt({ok,R = 0},#options{report_mode = quiet}) ->
    halt(R);
cl_halt({ok,R = 2},#options{report_mode = quiet}) ->
    halt(R);
cl_halt({ok,R = 0},#options{}) ->
    io:put_chars("done (passed successfully)\n"),
    halt(R);
cl_halt({ok,R = 2},#options{output_file = Output}) ->
    io:put_chars("done (warnings were emitted)\n"),
    cl_check_log(Output),
    halt(R);
cl_halt({error,Msg1},#options{output_file = Output}) ->
    io:format("\ndialyzer: ~ts\n",[Msg1]),
    cl_check_log(Output),
    halt(1).

-spec(cl_check_log(none|file:filename()) -> ok).

cl_check_log(none) ->
    ok;
cl_check_log(Output) ->
    io:format("  Check output file `~ts' for details\n",[Output]).

-spec(format_warning(raw_warning()|dial_warning()) -> string()).

format_warning(W) ->
    format_warning(W,basename).

-spec(format_warning(raw_warning()|dial_warning(),fopt()|proplists:proplist()) -> string()).

format_warning(RawWarning,FOpt)
    when is_atom(FOpt)->
    format_warning(RawWarning,[{filename_opt,FOpt}]);
format_warning({Tag,{File,Line,_MFA},Msg},Opts) ->
    format_warning({Tag,{File,Line},Msg},Opts);
format_warning({_Tag,{File,Line},Msg},Opts)
    when is_list(File),
    is_integer(Line)->
    F = case proplists:get_value(filename_opt,Opts,basename) of
        fullpath->
            File;
        basename->
            filename:basename(File)
    end,
    Indent = proplists:get_value(indent_opt,Opts,true),
    String = message_to_string(Msg,Indent),
    lists:flatten(io_lib:format("~ts:~w: ~ts",[F, Line, String])).

message_to_string({apply,[Args, ArgNs, FailReason, SigArgs, SigRet, Contract]},I) ->
    io_lib:format("Fun application with arguments ~ts ",[a(Args,I)]) ++ call_or_apply_to_string(ArgNs,FailReason,SigArgs,SigRet,Contract,I);
message_to_string({app_call,[M, F, Args, Culprit, ExpectedType, FoundType]},I) ->
    io_lib:format("The call ~s:~ts~ts requires that ~ts is of type ~ts " "not ~ts\n",[M, F, a(Args,I), c(Culprit,I), t(ExpectedType,I), t(FoundType,I)]);
message_to_string({bin_construction,[Culprit, Size, Seg, Type]},I) ->
    io_lib:format("Binary construction will fail since the ~s field ~s " "in segment ~s has type ~s\n",[Culprit, c(Size,I), c(Seg,I), t(Type,I)]);
message_to_string({call,[M, F, Args, ArgNs, FailReason, SigArgs, SigRet, Contract]},I) ->
    io_lib:format("The call ~w:~tw~ts ",[M, F, a(Args,I)]) ++ call_or_apply_to_string(ArgNs,FailReason,SigArgs,SigRet,Contract,I);
message_to_string({call_to_missing,[M, F, A]},_I) ->
    io_lib:format("Call to missing or unexported function ~w:~tw/~w\n",[M, F, A]);
message_to_string({exact_eq,[Type1, Op, Type2]},I) ->
    io_lib:format("The test ~ts ~s ~ts can never evaluate to 'true'\n",[t(Type1,I), Op, t(Type2,I)]);
message_to_string({fun_app_args,[ArgNs, Args, Type]},I) ->
    PositionString = form_position_string(ArgNs),
    io_lib:format("Fun application with arguments ~ts will fail since t" "he function has type ~ts, which differs in the ~s ar" "gument\n",[a(Args,I), t(Type,I), PositionString]);
message_to_string({fun_app_no_fun,[Op, Type, Arity]},I) ->
    io_lib:format("Fun application will fail since ~ts :: ~ts is not a " "function of arity ~w\n",[Op, t(Type,I), Arity]);
message_to_string({guard_fail,[]},_I) ->
    "Clause guard cannot succeed.\n";
message_to_string({guard_fail,[Arg1, Infix, Arg2]},I) ->
    io_lib:format("Guard test ~ts ~s ~ts can never succeed\n",[a(Arg1,I), Infix, a(Arg2,I)]);
message_to_string({map_update,[Type, Key]},I) ->
    io_lib:format("A key of type ~ts cannot exist in a map of type ~ts" "\n",[t(Key,I), t(Type,I)]);
message_to_string({neg_guard_fail,[Arg1, Infix, Arg2]},I) ->
    io_lib:format("Guard test not(~ts ~s ~ts) can never succeed\n",[a(Arg1,I), Infix, a(Arg2,I)]);
message_to_string({guard_fail,[Guard, Args]},I) ->
    io_lib:format("Guard test ~s~ts can never succeed\n",[Guard, a(Args,I)]);
message_to_string({neg_guard_fail,[Guard, Args]},I) ->
    io_lib:format("Guard test not(~s~ts) can never succeed\n",[Guard, a(Args,I)]);
message_to_string({guard_fail_pat,[Pat, Type]},I) ->
    io_lib:format("Clause guard cannot succeed. The ~ts was matched aga" "inst the type ~ts\n",[ps(Pat,I), t(Type,I)]);
message_to_string({improper_list_constr,[TlType]},I) ->
    io_lib:format("Cons will produce an improper list since its 2nd arg" "ument is ~ts\n",[t(TlType,I)]);
message_to_string({no_return,[Type| Name]},_I) ->
    NameString = case Name of
        []->
            "The created fun ";
        [F, A]->
            io_lib:format("Function ~tw/~w ",[F, A])
    end,
    case Type of
        no_match->
            NameString ++ "has no clauses that will ever match\n";
        only_explicit->
            NameString ++ "only terminates with explicit exception\n";
        only_normal->
            NameString ++ "has no local return\n";
        both->
            NameString ++ "has no local return\n"
    end;
message_to_string({record_constr,[RecConstr, FieldDiffs]},I) ->
    io_lib:format("Record construction ~ts violates the declared type o" "f field ~ts\n",[t(RecConstr,I), field_diffs(FieldDiffs,I)]);
message_to_string({record_constr,[Name, Field, Type]},I) ->
    io_lib:format("Record construction violates the declared type for #" "~tw{} since ~ts cannot be of type ~ts\n",[Name, ps(Field,I), t(Type,I)]);
message_to_string({record_matching,[String, Name]},I) ->
    io_lib:format("The ~ts violates the declared type for #~tw{}\n",[rec_type(String,I), Name]);
message_to_string({record_match,[Pat, Type]},I) ->
    io_lib:format("Matching of ~ts tagged with a record name violates t" "he declared type of ~ts\n",[ps(Pat,I), t(Type,I)]);
message_to_string({pattern_match,[Pat, Type]},I) ->
    io_lib:format("The ~ts can never match the type ~ts\n",[ps(Pat,I), t(Type,I)]);
message_to_string({pattern_match_cov,[Pat, Type]},I) ->
    io_lib:format("The ~ts can never match since previous clauses compl" "etely covered the type ~ts\n",[ps(Pat,I), t(Type,I)]);
message_to_string({unmatched_return,[Type]},I) ->
    io_lib:format("Expression produces a value of type ~ts, but this va" "lue is unmatched\n",[t(Type,I)]);
message_to_string({unused_fun,[F, A]},_I) ->
    io_lib:format("Function ~tw/~w will never be called\n",[F, A]);
message_to_string({contract_diff,[M, F, _A, Contract, Sig]},I) ->
    io_lib:format("Type specification ~ts is not equal to the success t" "yping: ~ts\n",[con(M,F,Contract,I), con(M,F,Sig,I)]);
message_to_string({contract_subtype,[M, F, _A, Contract, Sig]},I) ->
    io_lib:format("Type specification ~ts is a subtype of the success t" "yping: ~ts\n",[con(M,F,Contract,I), con(M,F,Sig,I)]);
message_to_string({contract_supertype,[M, F, _A, Contract, Sig]},I) ->
    io_lib:format("Type specification ~ts is a supertype of the success" " typing: ~ts\n",[con(M,F,Contract,I), con(M,F,Sig,I)]);
message_to_string({contract_range,[Contract, M, F, ArgStrings, Line, CRet]},I) ->
    io_lib:format("The contract ~ts cannot be right because the inferre" "d return for ~tw~ts on line ~w is ~ts\n",[con(M,F,Contract,I), F, a(ArgStrings,I), Line, t(CRet,I)]);
message_to_string({invalid_contract,[M, F, A, Sig]},I) ->
    io_lib:format("Invalid type specification for function ~w:~tw/~w. T" "he success typing is ~ts\n",[M, F, A, sig(Sig,I)]);
message_to_string({contract_with_opaque,[M, F, A, OpaqueType, SigType]},I) ->
    io_lib:format("The specification for ~w:~tw/~w has an opaque subtyp" "e ~ts which is violated by the success typing ~ts\n",[M, F, A, t(OpaqueType,I), sig(SigType,I)]);
message_to_string({extra_range,[M, F, A, ExtraRanges, SigRange]},I) ->
    io_lib:format("The specification for ~w:~tw/~w states that the func" "tion might also return ~ts but the inferred return i" "s ~ts\n",[M, F, A, t(ExtraRanges,I), t(SigRange,I)]);
message_to_string({missing_range,[M, F, A, ExtraRanges, ContrRange]},I) ->
    io_lib:format("The success typing for ~w:~tw/~w implies that the fu" "nction might also return ~ts but the specification r" "eturn is ~ts\n",[M, F, A, t(ExtraRanges,I), t(ContrRange,I)]);
message_to_string({overlapping_contract,[M, F, A]},_I) ->
    io_lib:format("Overloaded contract for ~w:~tw/~w has overlapping do" "mains; such contracts are currently unsupported and " "are simply ignored\n",[M, F, A]);
message_to_string({spec_missing_fun,[M, F, A]},_I) ->
    io_lib:format("Contract for function that does not exist: ~w:~tw/~w" "\n",[M, F, A]);
message_to_string({call_with_opaque,[M, F, Args, ArgNs, ExpArgs]},I) ->
    io_lib:format("The call ~w:~tw~ts contains ~ts when ~ts\n",[M, F, a(Args,I), form_positions(ArgNs), form_expected(ExpArgs,I)]);
message_to_string({call_without_opaque,[M, F, Args, ExpectedTriples]},I) ->
    io_lib:format("The call ~w:~tw~ts does not have ~ts\n",[M, F, a(Args,I), form_expected_without_opaque(ExpectedTriples,I)]);
message_to_string({opaque_eq,[Type, _Op, OpaqueType]},I) ->
    io_lib:format("Attempt to test for equality between a term of type " "~ts and a term of opaque type ~ts\n",[t(Type,I), t(OpaqueType,I)]);
message_to_string({opaque_guard,[Arg1, Infix, Arg2, ArgNs]},I) ->
    io_lib:format("Guard test ~ts ~s ~ts contains ~s\n",[a(Arg1,I), Infix, a(Arg2,I), form_positions(ArgNs)]);
message_to_string({opaque_guard,[Guard, Args]},I) ->
    io_lib:format("Guard test ~w~ts breaks the opacity of its argument" "\n",[Guard, a(Args,I)]);
message_to_string({opaque_match,[Pat, OpaqueType, OpaqueTerm]},I) ->
    Term = if OpaqueType =:= OpaqueTerm ->
        "the term";true ->
        t(OpaqueTerm,I) end,
    io_lib:format("The attempt to match a term of type ~ts against the " "~ts breaks the opacity of ~ts\n",[t(OpaqueType,I), ps(Pat,I), Term]);
message_to_string({opaque_neq,[Type, _Op, OpaqueType]},I) ->
    io_lib:format("Attempt to test for inequality between a term of typ" "e ~ts and a term of opaque type ~ts\n",[t(Type,I), t(OpaqueType,I)]);
message_to_string({opaque_type_test,[Fun, Args, Arg, ArgType]},I) ->
    io_lib:format("The type test ~ts~ts breaks the opacity of the term " "~ts~ts\n",[Fun, a(Args,I), Arg, t(ArgType,I)]);
message_to_string({opaque_size,[SizeType, Size]},I) ->
    io_lib:format("The size ~ts breaks the opacity of ~ts\n",[t(SizeType,I), c(Size,I)]);
message_to_string({opaque_call,[M, F, Args, Culprit, OpaqueType]},I) ->
    io_lib:format("The call ~s:~ts~ts breaks the opacity of the term ~t" "s :: ~ts\n",[M, F, a(Args,I), c(Culprit,I), t(OpaqueType,I)]);
message_to_string({race_condition,[M, F, Args, Reason]},I) ->
    io_lib:format("The call ~w:~tw~ts ~ts\n",[M, F, a(Args,I), Reason]);
message_to_string({callback_type_mismatch,[B, F, A, ST, CT]},I) ->
    io_lib:format("The inferred return type of ~tw/~w ~ts has nothing i" "n common with ~ts, which is the expected return type" " for the callback of the ~w behaviour\n",[F, A, t("(" ++ ST ++ ")",I), t(CT,I), B]);
message_to_string({callback_arg_type_mismatch,[B, F, A, N, ST, CT]},I) ->
    io_lib:format("The inferred type for the ~s argument of ~tw/~w (~ts" ") is not a supertype of ~ts, which is expected type " "for this argument in the callback of the ~w behaviou" "r\n",[ordinal(N), F, A, t(ST,I), t(CT,I), B]);
message_to_string({callback_spec_type_mismatch,[B, F, A, ST, CT]},I) ->
    io_lib:format("The return type ~ts in the specification of ~tw/~w i" "s not a subtype of ~ts, which is the expected return" " type for the callback of the ~w behaviour\n",[t(ST,I), F, A, t(CT,I), B]);
message_to_string({callback_spec_arg_type_mismatch,[B, F, A, N, ST, CT]},I) ->
    io_lib:format("The specified type for the ~ts argument of ~tw/~w (~" "ts) is not a supertype of ~ts, which is expected typ" "e for this argument in the callback of the ~w behavi" "our\n",[ordinal(N), F, A, t(ST,I), t(CT,I), B]);
message_to_string({callback_missing,[B, F, A]},_I) ->
    io_lib:format("Undefined callback function ~tw/~w (behaviour ~w)\n",[F, A, B]);
message_to_string({callback_info_missing,[B]},_I) ->
    io_lib:format("Callback info about the ~w behaviour is not availabl" "e\n",[B]);
message_to_string({unknown_type,{M,F,A}},_I) ->
    io_lib:format("Unknown type ~w:~tw/~w",[M, F, A]);
message_to_string({unknown_function,{M,F,A}},_I) ->
    io_lib:format("Unknown function ~w:~tw/~w",[M, F, A]);
message_to_string({unknown_behaviour,B},_I) ->
    io_lib:format("Unknown behaviour ~w",[B]).

call_or_apply_to_string(ArgNs,FailReason,SigArgs,SigRet,{IsOverloaded,Contract},I) ->
    PositionString = form_position_string(ArgNs),
    case FailReason of
        only_sig->
            case ArgNs =:= [] of
                true->
                    io_lib:format("will never return since the success " "typing arguments are ~ts\n",[t(SigArgs,I)]);
                false->
                    io_lib:format("will never return since it differs i" "n the ~s argument from the success t" "yping arguments: ~ts\n",[PositionString, t(SigArgs,I)])
            end;
        only_contract->
            case ArgNs =:= [] orelse IsOverloaded of
                true->
                    io_lib:format("breaks the contract ~ts\n",[sig(Contract,I)]);
                false->
                    io_lib:format("breaks the contract ~ts in the ~s ar" "gument\n",[sig(Contract,I), PositionString])
            end;
        both->
            io_lib:format("will never return since the success typing i" "s ~ts -> ~ts and the contract is ~ts\n",[t(SigArgs,I), t(SigRet,I), sig(Contract,I)])
    end.

form_positions(ArgNs) ->
    case ArgNs of
        [_]->
            "an opaque term as ";
        [_, _| _]->
            "opaque terms as "
    end ++ form_position_string(ArgNs) ++ case ArgNs of
        [_]->
            " argument";
        [_, _| _]->
            " arguments"
    end.

form_expected_without_opaque([{N,T,TStr}],I) ->
    case erl_types:t_is_opaque(T) of
        true->
            io_lib:format("an opaque term of type ~ts as ",[t(TStr,I)]);
        false->
            io_lib:format("a term of type ~ts (with opaque subterms) as" " ",[t(TStr,I)])
    end ++ form_position_string([N]) ++ " argument";
form_expected_without_opaque(ExpectedTriples,_I) ->
    {ArgNs,_Ts,_TStrs} = lists:unzip3(ExpectedTriples),
    "opaque terms as " ++ form_position_string(ArgNs) ++ " arguments".

form_expected(ExpectedArgs,I) ->
    case ExpectedArgs of
        [T]->
            TS = erl_types:t_to_string(T),
            case erl_types:t_is_opaque(T) of
                true->
                    io_lib:format("an opaque term of type ~ts is expect" "ed",[t(TS,I)]);
                false->
                    io_lib:format("a structured term of type ~ts is exp" "ected",[t(TS,I)])
            end;
        [_, _| _]->
            "terms of different types are expected in these positions"
    end.

form_position_string(ArgNs) ->
    case ArgNs of
        []->
            "";
        [N1]->
            ordinal(N1);
        [_, _| _]->
            [Last| Prevs] = lists:reverse(ArgNs),
            ", " ++ Head = lists:flatten([(io_lib:format(", ~s",[ordinal(N)])) || N <- lists:reverse(Prevs)]),
            Head ++ " and " ++ ordinal(Last)
    end.

ordinal(1) ->
    "1st";
ordinal(2) ->
    "2nd";
ordinal(3) ->
    "3rd";
ordinal(N)
    when is_integer(N)->
    io_lib:format("~wth",[N]).

con(M,F,Src,I) ->
    S = sig(Src,I),
    io_lib:format("~w:~tw~ts",[M, F, S]).

sig(Src,false) ->
    Src;
sig(Src,true) ->
    try Str = lists:flatten(io_lib:format("-spec ~w:~tw~ts.",[a, b, Src])),
    {ok,Tokens,_EndLocation} = erl_scan:string(Str),
    {ok,{attribute,_,spec,{_MFA,Types}}} = erl_parse:parse_form(Tokens),
    indentation(10) ++ pp_spec(Types)
        catch
            _:_->
                Src end.

a("" = Args,_I) ->
    Args;
a(Args,I) ->
    t(Args,I).

c(Cerl,_I) ->
    Cerl.

field_diffs(Src,false) ->
    Src;
field_diffs(Src,true) ->
    Fields = string:split(Src," and ",all),
    lists:join(" and ",[(field_diff(Field)) || Field <- Fields]).

field_diff(Field) ->
    [F| Ts] = string:split(Field,"::",all),
    F ++ " ::" ++ t(lists:flatten(lists:join("::",Ts)),true).

rec_type("record " ++ Src,I) ->
    "record " ++ t(Src,I).

ps("pattern " ++ Src,I) ->
    "pattern " ++ t(Src,I);
ps("variable " ++ _ = Src,_I) ->
    Src;
ps("record field" ++ Rest,I) ->
    [S, TypeStr] = string:split(Rest,"of type ",all),
    "record field" ++ S ++ "of type " ++ t(TypeStr,I).

t(Src,false) ->
    Src;
t("(" ++ _ = Src,true) ->
    ts(Src);
t(Src,true) ->
    try parse_type_or_literal(Src) of 
        TypeOrLiteral->
            indentation(10) ++ pp_type(TypeOrLiteral)
        catch
            _:_->
                ts(Src) end.

ts(Src) ->
    Ind = indentation(10),
    [C1| Src1] = Src,
    [C2| RevSrc2] = lists:reverse(Src1),
    Src2 = lists:reverse(RevSrc2),
    try Types = parse_types_and_literals(Src2),
    CommaInd = [$,| Ind],
    indentation(10 - 1) ++ [C1| lists:join(CommaInd,[(pp_type(Type)) || Type <- Types])] ++ [C2]
        catch
            _:_->
                Src end.

indentation(I) ->
    [$\n| lists:duplicate(I,$ )].

pp_type(Type) ->
    Form = {attribute,erl_anno:new(0),type,{t,Type,[]}},
    TypeDef = erl_pp:form(Form,[{quote_singleton_atom_types,true}]),
    {match,[S]} = re:run(TypeDef,<<"::\\s*(.*)\\.\\n*">>,[{capture,all_but_first,list}, dotall]),
    S.

pp_spec(Spec) ->
    Form = {attribute,erl_anno:new(0),spec,{{a,b,0},Spec}},
    Sig = erl_pp:form(Form,[{quote_singleton_atom_types,true}]),
    {match,[S]} = re:run(Sig,<<"-spec a:b\\s*(.*)\\.\\n*">>,[{capture,all_but_first,list}, dotall]),
    S.

parse_types_and_literals(Src) ->
    {ok,Tokens,_EndLocation} = erl_scan:string(Src),
    [(parse_a_type_or_literal(Ts)) || Ts <- types(Tokens)].

parse_type_or_literal(Src) ->
    {ok,Tokens,_EndLocation} = erl_scan:string(Src),
    parse_a_type_or_literal(Tokens).

parse_a_type_or_literal(Ts0) ->
    L = erl_anno:new(1),
    Ts = Ts0 ++ [{dot,L}],
    Tokens = [{'-',L}, {atom,L,type}, {atom,L,t}, {'(',L}, {')',L}, {'::',L}] ++ Ts,
    case erl_parse:parse_form(Tokens) of
        {ok,{attribute,_,type,{t,Type,[]}}}->
            Type;
        {error,_}->
            {ok,[T]} = erl_parse:parse_exprs(Ts),
            T
    end.

types([]) ->
    [];
types(Ts) ->
    {Ts0,Ts1} = one_type(Ts,[],[]),
    [Ts0| types(Ts1)].

one_type([],[],Ts) ->
    {lists:reverse(Ts),[]};
one_type([{',',_Lc}| Toks],[],Ts0) ->
    {lists:reverse(Ts0),Toks};
one_type([{')',Lrp}| Toks],[],Ts0) ->
    {lists:reverse(Ts0),[{')',Lrp}| Toks]};
one_type([{'(',Llp}| Toks],E,Ts0) ->
    one_type(Toks,[')'| E],[{'(',Llp}| Ts0]);
one_type([{'<<',Lls}| Toks],E,Ts0) ->
    one_type(Toks,['>>'| E],[{'<<',Lls}| Ts0]);
one_type([{'[',Lls}| Toks],E,Ts0) ->
    one_type(Toks,[']'| E],[{'[',Lls}| Ts0]);
one_type([{'{',Llc}| Toks],E,Ts0) ->
    one_type(Toks,['}'| E],[{'{',Llc}| Ts0]);
one_type([{Rb,Lrb}| Toks],[Rb| E],Ts0) ->
    one_type(Toks,E,[{Rb,Lrb}| Ts0]);
one_type([T| Toks],E,Ts0) ->
    one_type(Toks,E,[T| Ts0]).
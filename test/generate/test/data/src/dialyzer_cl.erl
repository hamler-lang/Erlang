-file("dialyzer_cl.erl", 1).

-module(dialyzer_cl).

-export([start/1]).

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

-file("dialyzer_cl.erl", 29).

-file("/usr/lib/erlang/lib/kernel-7.2/include/file.hrl", 1).

-record(file_info,{size::non_neg_integer()|undefined,type::device|directory|other|regular|symlink|undefined,access::read|write|read_write|none|undefined,atime::file:date_time()|non_neg_integer()|undefined,mtime::file:date_time()|non_neg_integer()|undefined,ctime::file:date_time()|non_neg_integer()|undefined,mode::non_neg_integer()|undefined,links::non_neg_integer()|undefined,major_device::non_neg_integer()|undefined,minor_device::non_neg_integer()|undefined,inode::non_neg_integer()|undefined,uid::non_neg_integer()|undefined,gid::non_neg_integer()|undefined}).

-record(file_descriptor,{module::module(),data::term()}).

-file("dialyzer_cl.erl", 29).

-record(cl_state,{backend_pid::pid()|undefined,code_server = none::none|dialyzer_codeserver:codeserver(),erlang_mode = false::boolean(),external_calls = []::[mfa()],external_types = []::[mfa()],legal_warnings = ordsets:new()::[dial_warn_tag()],mod_deps = dict:new()::dialyzer_callgraph:mod_deps(),output = standard_io::io:device(),output_format = formatted::format(),filename_opt = basename::fopt(),indent_opt = true::iopt(),output_plt = none::none|file:filename(),plt_info = none::none|dialyzer_plt:plt_info(),report_mode = normal::rep_mode(),return_status = 0::dial_ret(),stored_warnings = []::[raw_warning()]}).

-spec(start(#options{}) -> {dial_ret(),[dial_warning()]}).

start(#options{analysis_type = AnalysisType} = Options) ->
    process_flag(trap_exit,true),
    case AnalysisType of
        plt_check->
            check_plt(Options);
        plt_build->
            build_plt(Options);
        plt_add->
            add_to_plt(Options);
        plt_remove->
            remove_from_plt(Options);
        succ_typings->
            do_analysis(Options)
    end.

build_plt(Opts) ->
    Opts1 = init_opts_for_build(Opts),
    Files = get_files_from_opts(Opts1),
    Md5 = dialyzer_plt:compute_md5_from_files(Files),
    PltInfo = {Md5,dict:new()},
    do_analysis(Files,Opts1,dialyzer_plt:new(),PltInfo).

init_opts_for_build(Opts) ->
    case Opts#options.output_plt =:= none of
        true->
            case Opts#options.init_plts of
                []->
                    Opts#options{output_plt = get_default_output_plt()};
                [Plt]->
                    Opts#options{init_plts = [],output_plt = Plt};
                Plts->
                    Msg = io_lib:format("Could not build multiple PLT fil" "es: ~ts\n",[format_plts(Plts)]),
                    cl_error(Msg)
            end;
        false->
            Opts#options{init_plts = []}
    end.

add_to_plt(Opts) ->
    Opts1 = init_opts_for_add(Opts),
    AddFiles = get_files_from_opts(Opts1),
    plt_common(Opts1,[],AddFiles).

init_opts_for_add(Opts) ->
    case Opts#options.output_plt =:= none of
        true->
            case Opts#options.init_plts of
                []->
                    Opts#options{output_plt = get_default_output_plt(),init_plts = get_default_init_plt()};
                [Plt]->
                    Opts#options{output_plt = Plt};
                Plts->
                    Msg = io_lib:format("Could not add to multiple PLT fi" "les: ~ts\n",[format_plts(Plts)]),
                    cl_error(Msg)
            end;
        false->
            case Opts#options.init_plts =:= [] of
                true->
                    Opts#options{init_plts = get_default_init_plt()};
                false->
                    Opts
            end
    end.

check_plt(#options{init_plts = []} = Opts) ->
    Opts1 = init_opts_for_check(Opts),
    report_check(Opts1),
    plt_common(Opts1,[],[]);
check_plt(#options{init_plts = Plts} = Opts) ->
    check_plt_aux(Plts,Opts).

check_plt_aux([_] = Plt,Opts) ->
    Opts1 = Opts#options{init_plts = Plt},
    Opts2 = init_opts_for_check(Opts1),
    report_check(Opts2),
    plt_common(Opts2,[],[]);
check_plt_aux([Plt| Plts],Opts) ->
    case check_plt_aux([Plt],Opts) of
        {0,[]}->
            check_plt_aux(Plts,Opts);
        {2,Warns}->
            {_RET,MoreWarns} = check_plt_aux(Plts,Opts),
            {2,Warns ++ MoreWarns}
    end.

init_opts_for_check(Opts) ->
    InitPlt = case Opts#options.init_plts of
        []->
            get_default_init_plt();
        Plt->
            Plt
    end,
    [OutputPlt] = InitPlt,
    Opts#options{files = [],files_rec = [],analysis_type = plt_check,defines = [],from = byte_code,init_plts = InitPlt,include_dirs = [],output_plt = OutputPlt,use_contracts = true}.

remove_from_plt(Opts) ->
    Opts1 = init_opts_for_remove(Opts),
    Files = get_files_from_opts(Opts1),
    plt_common(Opts1,Files,[]).

init_opts_for_remove(Opts) ->
    case Opts#options.output_plt =:= none of
        true->
            case Opts#options.init_plts of
                []->
                    Opts#options{output_plt = get_default_output_plt(),init_plts = get_default_init_plt()};
                [Plt]->
                    Opts#options{output_plt = Plt};
                Plts->
                    Msg = io_lib:format("Could not remove from multiple P" "LT files: ~ts\n",[format_plts(Plts)]),
                    cl_error(Msg)
            end;
        false->
            case Opts#options.init_plts =:= [] of
                true->
                    Opts#options{init_plts = get_default_init_plt()};
                false->
                    Opts
            end
    end.

plt_common(#options{init_plts = [InitPlt]} = Opts,RemoveFiles,AddFiles) ->
    case check_plt(Opts,RemoveFiles,AddFiles) of
        ok->
            case Opts#options.output_plt of
                none->
                    ok;
                InitPlt->
                    ok;
                OutPlt->
                    {ok,Binary} = file:read_file(InitPlt),
                    ok = file:write_file(OutPlt,Binary)
            end,
            case Opts#options.report_mode of
                quiet->
                    ok;
                _->
                    io:put_chars(" yes\n")
            end,
            {0,[]};
        {old_version,Md5}->
            PltInfo = {Md5,dict:new()},
            Files = [F || {F,_} <- Md5],
            do_analysis(Files,Opts,dialyzer_plt:new(),PltInfo);
        {differ,Md5,DiffMd5,ModDeps}->
            report_failed_plt_check(Opts,DiffMd5),
            {AnalFiles,RemovedMods,ModDeps1} = expand_dependent_modules(Md5,DiffMd5,ModDeps),
            Plt = clean_plt(InitPlt,RemovedMods),
            case AnalFiles =:= [] of
                true->
                    dialyzer_plt:to_file(Opts#options.output_plt,Plt,ModDeps,{Md5,ModDeps}),
                    {0,[]};
                false->
                    do_analysis(AnalFiles,Opts,Plt,{Md5,ModDeps1})
            end;
        {error,no_such_file}->
            Msg = io_lib:format("Could not find the PLT: ~ts\n~s",[InitPlt, default_plt_error_msg()]),
            cl_error(Msg);
        {error,not_valid}->
            Msg = io_lib:format("The file: ~ts is not a valid PLT file\n~" "s",[InitPlt, default_plt_error_msg()]),
            cl_error(Msg);
        {error,read_error}->
            Msg = io_lib:format("Could not read the PLT: ~ts\n~s",[InitPlt, default_plt_error_msg()]),
            cl_error(Msg);
        {error,{no_file_to_remove,F}}->
            Msg = io_lib:format("Could not remove the file ~ts from the P" "LT: ~ts\n",[F, InitPlt]),
            cl_error(Msg)
    end.

default_plt_error_msg() ->
    "Use the options:\n   --build_plt   to build a new PLT; or\n   --ad" "d_to_plt  to add to an existing PLT\n\nFor example, use a command " "like the following:\n   dialyzer --build_plt --apps erts kernel st" "dlib mnesia\nNote that building a PLT such as the above may take 2" "0 mins or so\n\nIf you later need information about other applicat" "ions, say crypto,\nyou can extend the PLT by the command:\n  dialy" "zer --add_to_plt --apps crypto\nFor applications that are not in E" "rlang/OTP use an absolute file name.\n".

check_plt(#options{init_plts = [Plt]} = Opts,RemoveFiles,AddFiles) ->
    case dialyzer_plt:check_plt(Plt,RemoveFiles,AddFiles) of
        {old_version,_MD5} = OldVersion->
            report_old_version(Opts),
            OldVersion;
        {differ,_MD5,_DiffMd5,_ModDeps} = Differ->
            Differ;
        ok->
            ok;
        {error,_Reason} = Error->
            Error
    end.

report_check(#options{report_mode = ReportMode,init_plts = [InitPlt]}) ->
    case ReportMode of
        quiet->
            ok;
        _->
            io:format("  Checking whether the PLT ~ts is up-to-date...",[InitPlt])
    end.

report_old_version(#options{report_mode = ReportMode,init_plts = [InitPlt]}) ->
    case ReportMode of
        quiet->
            ok;
        _->
            io:put_chars(" no\n"),
            io:format("    (the PLT ~ts was built with an old version o" "f Dialyzer)\n",[InitPlt])
    end.

report_failed_plt_check(#options{analysis_type = AnalType,report_mode = ReportMode},DiffMd5) ->
    case AnalType =:= plt_check of
        true->
            case ReportMode of
                quiet->
                    ok;
                normal->
                    io:format(" no\n",[]);
                verbose->
                    report_md5_diff(DiffMd5)
            end;
        false->
            ok
    end.

report_analysis_start(#options{analysis_type = Type,report_mode = ReportMode,init_plts = InitPlts,output_plt = OutputPlt}) ->
    case ReportMode of
        quiet->
            ok;
        _->
            io:format("  "),
            case Type of
                plt_add->
                    [InitPlt] = InitPlts,
                    case InitPlt =:= OutputPlt of
                        true->
                            io:format("Adding information to ~ts...",[OutputPlt]);
                        false->
                            io:format("Adding information from ~ts to ~" "ts...",[InitPlt, OutputPlt])
                    end;
                plt_build->
                    io:format("Creating PLT ~ts ...",[OutputPlt]);
                plt_check->
                    io:format("Rebuilding the information in ~ts...",[OutputPlt]);
                plt_remove->
                    [InitPlt] = InitPlts,
                    case InitPlt =:= OutputPlt of
                        true->
                            io:format("Removing information from ~ts...",[OutputPlt]);
                        false->
                            io:format("Removing information from ~ts to" " ~ts...",[InitPlt, OutputPlt])
                    end;
                succ_typings->
                    io:format("Proceeding with analysis...")
            end
    end.

report_native_comp(#options{report_mode = ReportMode}) ->
    case ReportMode of
        quiet->
            ok;
        _->
            io:format("  Compiling some key modules to native code...")
    end.

report_elapsed_time(T1,T2,#options{report_mode = ReportMode}) ->
    case ReportMode of
        quiet->
            ok;
        _->
            ElapsedTime = T2 - T1,
            Mins = ElapsedTime div 60000,
            Secs = ElapsedTime rem 60000/1000,
            io:format(" done in ~wm~.2fs\n",[Mins, Secs])
    end.

report_md5_diff(List) ->
    io:format("    The PLT information is not up to date:\n",[]),
    case [Mod || {removed,Mod} <- List] of
        []->
            ok;
        RemovedMods->
            io:format("    Removed modules: ~p\n",[RemovedMods])
    end,
    case [Mod || {differ,Mod} <- List] of
        []->
            ok;
        ChangedMods->
            io:format("    Changed modules: ~p\n",[ChangedMods])
    end.

get_default_init_plt() ->
    [dialyzer_plt:get_default_plt()].

get_default_output_plt() ->
    dialyzer_plt:get_default_plt().

format_plts([Plt]) ->
    Plt;
format_plts([Plt| Plts]) ->
    Plt ++ ", " ++ format_plts(Plts).

do_analysis(Options) ->
    Files = get_files_from_opts(Options),
    case Options#options.init_plts of
        []->
            do_analysis(Files,Options,dialyzer_plt:new(),none);
        PltFiles->
            Plts = [(dialyzer_plt:from_file(F)) || F <- PltFiles],
            Plt = dialyzer_plt:merge_plts_or_report_conflicts(PltFiles,Plts),
            do_analysis(Files,Options,Plt,none)
    end.

do_analysis(Files,Options,Plt,PltInfo) ->
    assert_writable(Options#options.output_plt),
    hipe_compile(Files,Options),
    report_analysis_start(Options),
    State0 = new_state(),
    State1 = init_output(State0,Options),
    State2 = State1#cl_state{legal_warnings = Options#options.legal_warnings,output_plt = Options#options.output_plt,plt_info = PltInfo,erlang_mode = Options#options.erlang_mode,report_mode = Options#options.report_mode},
    AnalysisType = convert_analysis_type(Options#options.analysis_type,Options#options.get_warnings),
    InitAnalysis = #analysis{type = AnalysisType,defines = Options#options.defines,include_dirs = Options#options.include_dirs,files = Files,start_from = Options#options.from,timing = Options#options.timing,plt = Plt,use_contracts = Options#options.use_contracts,callgraph_file = Options#options.callgraph_file,solvers = Options#options.solvers},
    State3 = start_analysis(State2,InitAnalysis),
    {T1,_} = statistics(wall_clock),
    Return = cl_loop(State3),
    {T2,_} = statistics(wall_clock),
    report_elapsed_time(T1,T2,Options),
    Return.

convert_analysis_type(plt_check,true) ->
    succ_typings;
convert_analysis_type(plt_check,false) ->
    plt_build;
convert_analysis_type(plt_add,true) ->
    succ_typings;
convert_analysis_type(plt_add,false) ->
    plt_build;
convert_analysis_type(plt_build,true) ->
    succ_typings;
convert_analysis_type(plt_build,false) ->
    plt_build;
convert_analysis_type(plt_remove,true) ->
    succ_typings;
convert_analysis_type(plt_remove,false) ->
    plt_build;
convert_analysis_type(succ_typings,_) ->
    succ_typings.

assert_writable(none) ->
    ok;
assert_writable(PltFile) ->
    case check_if_writable(PltFile) of
        true->
            ok;
        false->
            Msg = io_lib:format("    The PLT file ~ts is not writable",[PltFile]),
            cl_error(Msg)
    end.

check_if_writable(PltFile) ->
    case filelib:is_regular(PltFile) of
        true->
            is_writable_file_or_dir(PltFile);
        false->
            case filelib:is_dir(PltFile) of
                true->
                    false;
                false->
                    DirName = filename:dirname(PltFile),
                    filelib:is_dir(DirName) andalso is_writable_file_or_dir(DirName)
            end
    end.

is_writable_file_or_dir(PltFile) ->
    case file:read_file_info(PltFile) of
        {ok,#file_info{access = A}}->
            A =:= write orelse A =:= read_write;
        {error,_}->
            false
    end.

clean_plt(PltFile,RemovedMods) ->
    Plt = dialyzer_plt:from_file(PltFile),
    sets:fold(fun (M,AccPlt)->
        dialyzer_plt:delete_module(AccPlt,M) end,Plt,RemovedMods).

expand_dependent_modules(Md5,DiffMd5,ModDeps) ->
    ChangedMods = sets:from_list([M || {differ,M} <- DiffMd5]),
    RemovedMods = sets:from_list([M || {removed,M} <- DiffMd5]),
    BigSet = sets:union(ChangedMods,RemovedMods),
    BigList = sets:to_list(BigSet),
    ExpandedSet = expand_dependent_modules_1(BigList,BigSet,ModDeps),
    NewModDeps = dialyzer_callgraph:strip_module_deps(ModDeps,BigSet),
    AnalyzeMods = sets:subtract(ExpandedSet,RemovedMods),
    FilterFun = fun (File)->
        Mod = list_to_atom(filename:basename(File,".beam")),
        sets:is_element(Mod,AnalyzeMods) end,
    {[F || {F,_} <- Md5,FilterFun(F)],BigSet,NewModDeps}.

expand_dependent_modules_1([Mod| Mods],Included,ModDeps) ->
    case dict:find(Mod,ModDeps) of
        {ok,Deps}->
            NewDeps = sets:subtract(sets:from_list(Deps),Included),
            case sets:size(NewDeps) =:= 0 of
                true->
                    expand_dependent_modules_1(Mods,Included,ModDeps);
                false->
                    NewIncluded = sets:union(Included,NewDeps),
                    expand_dependent_modules_1(sets:to_list(NewDeps) ++ Mods,NewIncluded,ModDeps)
            end;
        error->
            expand_dependent_modules_1(Mods,Included,ModDeps)
    end;
expand_dependent_modules_1([],Included,_ModDeps) ->
    Included.

-spec(hipe_compile([file:filename()],#options{}) -> ok).

hipe_compile(Files,#options{erlang_mode = ErlangMode} = Options) ->
    NoNative = get(dialyzer_options_native) =:= false,
    FewFiles = length(Files) < 20,
    case NoNative orelse FewFiles orelse ErlangMode of
        true->
            ok;
        false->
            case erlang:system_info(hipe_architecture) of
                undefined->
                    ok;
                _->
                    Mods = [lists, dict, digraph, digraph_utils, ets, gb_sets, gb_trees, ordsets, sets, sofs, cerl, erl_types, cerl_trees, erl_bif_types, dialyzer_analysis_callgraph, dialyzer, dialyzer_behaviours, dialyzer_codeserver, dialyzer_contracts, dialyzer_coordinator, dialyzer_dataflow, dialyzer_dep, dialyzer_plt, dialyzer_succ_typings, dialyzer_typesig, dialyzer_worker],
                    report_native_comp(Options),
                    {T1,_} = statistics(wall_clock),
                    Cache = get(dialyzer_options_native_cache) =/= false,
                    native_compile(Mods,Cache),
                    {T2,_} = statistics(wall_clock),
                    report_elapsed_time(T1,T2,Options)
            end
    end.

native_compile(Mods,Cache) ->
    case dialyzer_utils:parallelism() > 7 of
        true->
            Parent = self(),
            Pids = [(spawn(fun ()->
                Parent ! {self(),hc(M,Cache)} end)) || M <- Mods],
            lists:foreach(fun (Pid)->
                receive {Pid,Res}->
                    Res end end,Pids);
        false->
            lists:foreach(fun (Mod)->
                hc(Mod,Cache) end,Mods)
    end.

hc(Mod,Cache) ->
    {module,Mod} = code:ensure_loaded(Mod),
    case code:is_module_native(Mod) of
        true->
            ok;
        false->
            case Cache of
                false->
                    {ok,Mod} = hipe:c(Mod),
                    ok;
                true->
                    hc_cache(Mod)
            end
    end.

hc_cache(Mod) ->
    CacheBase = cache_base_dir(),
    HipeArchVersion = lists:concat([erlang:system_info(hipe_architecture), "-", hipe:version(), "-", hipe:erts_checksum()]),
    CacheDir = filename:join(CacheBase,HipeArchVersion),
    OrigBeamFile = code:which(Mod),
    {ok,{Mod,<<Checksum:128>>}} = beam_lib:md5(OrigBeamFile),
    CachedBeamFile = filename:join(CacheDir,lists:concat([Mod, "-", Checksum, ".beam"])),
    ok = filelib:ensure_dir(CachedBeamFile),
    ModBin = case filelib:is_file(CachedBeamFile) of
        true->
            {ok,BinFromFile} = file:read_file(CachedBeamFile),
            BinFromFile;
        false->
            {ok,Mod,CompiledBin} = compile:file(OrigBeamFile,[from_beam, native, binary]),
            ok = file:write_file(CachedBeamFile,CompiledBin),
            CompiledBin
    end,
    code:unstick_dir(filename:dirname(OrigBeamFile)),
    {module,Mod} = code:load_binary(Mod,CachedBeamFile,ModBin),
    true = code:is_module_native(Mod),
    ok.

cache_base_dir() ->
    XdgCacheHome = os:getenv("XDG_CACHE_HOME"),
    CacheHome = case is_list(XdgCacheHome) andalso filename:pathtype(XdgCacheHome) =:= absolute of
        true->
            XdgCacheHome;
        false->
            {ok,[[Home]]} = init:get_argument(home),
            filename:join(Home,".cache")
    end,
    filename:join([CacheHome, "dialyzer_hipe_cache"]).

new_state() ->
    #cl_state{}.

init_output(State0,#options{output_file = OutFile,output_format = OutFormat,filename_opt = FOpt,indent_opt = IOpt}) ->
    State = State0#cl_state{output_format = OutFormat,filename_opt = FOpt,indent_opt = IOpt},
    case OutFile =:= none of
        true->
            State;
        false->
            case file:open(OutFile,[write]) of
                {ok,File}->
                    ok = io:setopts(File,[{encoding,unicode}]),
                    State#cl_state{output = File};
                {error,Reason}->
                    Msg = io_lib:format("Could not open output file ~tp, " "Reason: ~p\n",[OutFile, Reason]),
                    cl_error(State,lists:flatten(Msg))
            end
    end.

-spec(maybe_close_output_file(#cl_state{}) -> ok).

maybe_close_output_file(State) ->
    case State#cl_state.output of
        standard_io->
            ok;
        File->
            ok = file:close(File)
    end.

cl_loop(State) ->
    cl_loop(State,[]).

cl_loop(State,LogCache) ->
    BackendPid = State#cl_state.backend_pid,
    receive {BackendPid,log,LogMsg}->
        cl_loop(State,lists:sublist([LogMsg| LogCache],10));
    {BackendPid,warnings,Warnings}->
        NewState = store_warnings(State,Warnings),
        cl_loop(NewState,LogCache);
    {BackendPid,cserver,CodeServer,_Plt}->
        NewState = State#cl_state{code_server = CodeServer},
        cl_loop(NewState,LogCache);
    {BackendPid,done,NewPlt,_NewDocPlt}->
        return_value(State,NewPlt);
    {BackendPid,ext_calls,ExtCalls}->
        cl_loop(State#cl_state{external_calls = ExtCalls},LogCache);
    {BackendPid,ext_types,ExtTypes}->
        cl_loop(State#cl_state{external_types = ExtTypes},LogCache);
    {BackendPid,mod_deps,ModDeps}->
        NewState = State#cl_state{mod_deps = ModDeps},
        cl_loop(NewState,LogCache);
    {'EXIT',BackendPid,{error,Reason}}->
        Msg = failed_anal_msg(Reason,LogCache),
        cl_error(State,Msg);
    {'EXIT',BackendPid,Reason}
        when Reason =/= normal->
        Msg = failed_anal_msg(io_lib:format("~p",[Reason]),LogCache),
        cl_error(State,Msg);
    _Other->
        cl_loop(State,LogCache) end.

-spec(failed_anal_msg(string(),[_]) -> nonempty_string()).

failed_anal_msg(Reason,LogCache) ->
    Msg = "Analysis failed with error:\n" ++ lists:flatten(Reason) ++ "\n",
    case LogCache =:= [] of
        true->
            Msg;
        false->
            Msg ++ "Last messages in the log cache:\n  " ++ format_log_cache(LogCache)
    end.

format_log_cache(LogCache) ->
    Str = lists:append(lists:reverse(LogCache)),
    lists:join("\n  ",string:lexemes(Str,"\n")).

-spec(store_warnings(#cl_state{},[raw_warning()]) -> #cl_state{}).

store_warnings(#cl_state{stored_warnings = StoredWarnings} = St,Warnings) ->
    St#cl_state{stored_warnings = StoredWarnings ++ Warnings}.

-spec(cl_error(string()) -> no_return()).

cl_error(Msg) ->
    throw({dialyzer_error,lists:flatten(Msg)}).

-spec(cl_error(#cl_state{},string()) -> no_return()).

cl_error(State,Msg) ->
    case State#cl_state.output of
        standard_io->
            ok;
        Outfile->
            io:format(Outfile,"\n~ts\n",[Msg])
    end,
    maybe_close_output_file(State),
    throw({dialyzer_error,lists:flatten(Msg)}).

return_value(State = #cl_state{code_server = CodeServer,erlang_mode = ErlangMode,mod_deps = ModDeps,output_plt = OutputPlt,plt_info = PltInfo,stored_warnings = StoredWarnings},Plt) ->
    case CodeServer =:= none of
        true->
            ok;
        false->
            dialyzer_codeserver:delete(CodeServer)
    end,
    case OutputPlt =:= none of
        true->
            dialyzer_plt:delete(Plt);
        false->
            dialyzer_plt:to_file(OutputPlt,Plt,ModDeps,PltInfo)
    end,
    UnknownWarnings = unknown_warnings(State),
    RetValue = case StoredWarnings =:= [] andalso UnknownWarnings =:= [] of
        true->
            0;
        false->
            2
    end,
    case ErlangMode of
        false->
            print_warnings(State),
            print_ext_calls(State),
            print_ext_types(State),
            maybe_close_output_file(State),
            {RetValue,[]};
        true->
            AllWarnings = UnknownWarnings ++ process_warnings(StoredWarnings),
            {RetValue,set_warning_id(AllWarnings)}
    end.

unknown_warnings(State = #cl_state{legal_warnings = LegalWarnings}) ->
    Unknown = case ordsets:is_element(warn_unknown,LegalWarnings) of
        true->
            unknown_functions(State) ++ unknown_types(State);
        false->
            []
    end,
    WarningInfo = {_Filename = "",_Line = 0,_MorMFA = },
    [{warn_unknown,WarningInfo,W} || W <- Unknown].

unknown_functions(#cl_state{external_calls = Calls}) ->
    [{unknown_function,MFA} || MFA <- Calls].

set_warning_id(Warnings) ->
    lists:map(fun ({Tag,{File,Line,_MorMFA},Msg})->
        {Tag,{File,Line},Msg} end,Warnings).

print_ext_calls(#cl_state{report_mode = quiet}) ->
    ok;
print_ext_calls(#cl_state{output = Output,external_calls = Calls,stored_warnings = Warnings,output_format = Format}) ->
    case Calls =:= [] of
        true->
            ok;
        false->
            case Warnings =:= [] of
                true->
                    io:nl(Output);
                false->
                    ok
            end,
            case Format of
                formatted->
                    io:put_chars(Output,"Unknown functions:\n"),
                    do_print_ext_calls(Output,Calls,"  ");
                raw->
                    io:put_chars(Output,"%% Unknown functions:\n"),
                    do_print_ext_calls(Output,Calls,"%%  ")
            end
    end.

do_print_ext_calls(Output,[{M,F,A}| T],Before) ->
    io:format(Output,"~s~tp:~tp/~p\n",[Before, M, F, A]),
    do_print_ext_calls(Output,T,Before);
do_print_ext_calls(_,[],_) ->
    ok.

unknown_types(#cl_state{external_types = Types}) ->
    [{unknown_type,MFA} || MFA <- Types].

print_ext_types(#cl_state{report_mode = quiet}) ->
    ok;
print_ext_types(#cl_state{output = Output,external_calls = Calls,external_types = Types,stored_warnings = Warnings,output_format = Format}) ->
    case Types =:= [] of
        true->
            ok;
        false->
            case Warnings =:= [] andalso Calls =:= [] of
                true->
                    io:nl(Output);
                false->
                    ok
            end,
            case Format of
                formatted->
                    io:put_chars(Output,"Unknown types:\n"),
                    do_print_ext_types(Output,Types,"  ");
                raw->
                    io:put_chars(Output,"%% Unknown types:\n"),
                    do_print_ext_types(Output,Types,"%%  ")
            end
    end.

do_print_ext_types(Output,[{M,F,A}| T],Before) ->
    io:format(Output,"~s~tp:~tp/~p\n",[Before, M, F, A]),
    do_print_ext_types(Output,T,Before);
do_print_ext_types(_,[],_) ->
    ok.

print_warnings(#cl_state{stored_warnings = []}) ->
    ok;
print_warnings(#cl_state{output = Output,output_format = Format,filename_opt = FOpt,indent_opt = IOpt,stored_warnings = Warnings}) ->
    PrWarnings = process_warnings(Warnings),
    case PrWarnings of
        []->
            ok;
        [_| _]->
            S = case Format of
                formatted->
                    Opts = [{filename_opt,FOpt}, {indent_opt,IOpt}],
                    [(dialyzer:format_warning(W,Opts)) || W <- PrWarnings];
                raw->
                    [(io_lib:format("~tp. \n",[W])) || W <- set_warning_id(PrWarnings)]
            end,
            io:format(Output,"\n~ts",[S])
    end.

-spec(process_warnings([raw_warning()]) -> [raw_warning()]).

process_warnings(Warnings) ->
    Warnings1 = lists:keysort(2,Warnings),
    remove_duplicate_warnings(Warnings1,[]).

remove_duplicate_warnings([Duplicate, Duplicate| Left],Acc) ->
    remove_duplicate_warnings([Duplicate| Left],Acc);
remove_duplicate_warnings([NotDuplicate| Left],Acc) ->
    remove_duplicate_warnings(Left,[NotDuplicate| Acc]);
remove_duplicate_warnings([],Acc) ->
    lists:reverse(Acc).

get_files_from_opts(Options) ->
    From = Options#options.from,
    Files1 = add_files(Options#options.files,From),
    Files2 = add_files_rec(Options#options.files_rec,From),
    ordsets:union(Files1,Files2).

add_files_rec(Files,From) ->
    add_files(Files,From,true).

add_files(Files,From) ->
    add_files(Files,From,false).

add_files(Files,From,Rec) ->
    Files1 = [(filename:absname(F)) || F <- Files],
    Files2 = ordsets:from_list(Files1),
    Dirs = ordsets:filter(fun (X)->
        filelib:is_dir(X) end,Files2),
    Files3 = ordsets:subtract(Files2,Dirs),
    Extension = case From of
        byte_code->
            ".beam";
        src_code->
            ".erl"
    end,
    Fun = add_file_fun(Extension),
    lists:foldl(fun (Dir,Acc)->
        filelib:fold_files(Dir,Extension,Rec,Fun,Acc) end,Files3,Dirs).

add_file_fun(Extension) ->
    fun (File,AccFiles)->
        case filename:extension(File) =:= Extension of
            true->
                AbsName = filename:absname(File),
                ordsets:add_element(AbsName,AccFiles);
            false->
                AccFiles
        end end.

-spec(start_analysis(#cl_state{},#analysis{}) -> #cl_state{}).

start_analysis(State,Analysis) ->
    Self = self(),
    LegalWarnings = State#cl_state.legal_warnings,
    Fun = fun ()->
        dialyzer_analysis_callgraph:start(Self,LegalWarnings,Analysis) end,
    BackendPid = spawn_link(Fun),
    State#cl_state{backend_pid = BackendPid}.
-file("escript.erl", 1).

-module(escript).

-export([script_name/0, create/2, extract/2]).

-export([start/0, start/1, parse_file/1]).

-type(mode()::native|compile|debug|interpret|run).

-type(source()::archive|beam|text).

-record(state,{file::file:filename(),module::module(),forms_or_bin,source::source()|undefined,n_errors::non_neg_integer(),mode::mode(),exports_main::boolean(),has_records::boolean()}).

-type(shebang()::string()).

-type(comment()::string()).

-type(emu_args()::string()).

-record(sections,{type,shebang::shebang()|undefined,comment::comment()|undefined,emu_args::emu_args()|undefined,body}).

-record(extract_options, {compile_source}).

-type(zip_file()::file:filename()|{file:filename(),binary()}|{file:filename(),binary(),file:file_info()}).

-type(section()::shebang|{shebang,shebang()|default|undefined}|comment|{comment,comment()|default|undefined}|{emu_args,emu_args()|undefined}|{source,file:filename()|binary()}|{beam,file:filename()|binary()}|{archive,zip:filename()|binary()}|{archive,[zip_file()],[zip:create_option()]}).

-spec(create(file:filename()|binary,[section()]) -> ok|{ok,binary()}|{error,term()}).

create(File,Options)
    when is_list(Options)->
    try S = prepare(Options,#sections{}),
    BinList = [Section || Section <- [S#sections.shebang, S#sections.comment, S#sections.emu_args, S#sections.body],Section =/= undefined],
    case File of
        binary->
            {ok,list_to_binary(BinList)};
        _->
            case file:write_file(File,BinList) of
                ok->
                    ok;
                {error,Reason}->
                    {error,{Reason,File}}
            end
    end
        catch
            throw:PrepareReason->
                {error,PrepareReason} end.

prepare([H| T],S) ->
    case H of
        {shebang,undefined}->
            prepare(T,S);
        shebang->
            prepare(T,S#sections{shebang = "#!" ++ "/usr/bin/env escript" ++ "\n"});
        {shebang,default}->
            prepare(T,S#sections{shebang = "#!" ++ "/usr/bin/env escript" ++ "\n"});
        {shebang,Shebang}
            when is_list(Shebang)->
            prepare(T,S#sections{shebang = "#!" ++ Shebang ++ "\n"});
        {comment,undefined}->
            prepare(T,S);
        comment->
            prepare(T,S#sections{comment = "%% " ++ "This is an -*- erlang -*- file" ++ "\n"});
        {comment,default}->
            prepare(T,S#sections{comment = "%% " ++ "This is an -*- erlang -*- file" ++ "\n"});
        {comment,Comment}
            when is_list(Comment)->
            prepare(T,S#sections{comment = "%% " ++ Comment ++ "\n"});
        {emu_args,undefined}->
            prepare(T,S);
        {emu_args,Args}
            when is_list(Args)->
            prepare(T,S#sections{emu_args = "%%!" ++ Args ++ "\n"});
        {Type,File}
            when is_list(File)->
            case file:read_file(File) of
                {ok,Bin}->
                    prepare(T,S#sections{type = Type,body = Bin});
                {error,Reason}->
                    throw({Reason,H})
            end;
        {Type,Bin}
            when is_binary(Bin)->
            prepare(T,S#sections{type = Type,body = Bin});
        {archive = Type,ZipFiles,ZipOptions}
            when is_list(ZipFiles),
            is_list(ZipOptions)->
            File = "dummy.zip",
            case zip:create(File,ZipFiles,ZipOptions ++ [memory]) of
                {ok,{File,ZipBin}}->
                    prepare(T,S#sections{type = Type,body = ZipBin});
                {error,Reason}->
                    throw({Reason,H})
            end;
        _->
            throw({badarg,H})
    end;
prepare([],#sections{body = undefined}) ->
    throw(missing_body);
prepare([],#sections{type = Type} = S)
    when Type =:= source;
    Type =:= beam;
    Type =:= archive->
    S;
prepare([],#sections{type = Type}) ->
    throw({illegal_type,Type});
prepare(BadOptions,_) ->
    throw({badarg,BadOptions}).

-type(section_name()::shebang|comment|emu_args|body).

-type(extract_option()::compile_source|{section,[section_name()]}).

-spec(extract(file:filename(),[extract_option()]) -> {ok,[section()]}|{error,term()}).

extract(File,Options)
    when is_list(File),
    is_list(Options)->
    try EO = parse_extract_options(Options,#extract_options{compile_source = false}),
    {HeaderSz,NextLineNo,Fd,Sections} = parse_header(File, not EO#extract_options.compile_source),
    Type = Sections#sections.type,
    case {Type,EO#extract_options.compile_source} of
        {source,true}->
            Bin = compile_source(Type,File,Fd,NextLineNo,HeaderSz);
        {_,_}->
            ok = file:close(Fd),
            case file:read_file(File) of
                {ok,<<_Header:HeaderSz/binary,Bin/binary>>}->
                    ok;
                {error,ReadReason}->
                    Bin = get_rid_of_compiler_warning,
                    throw(ReadReason)
            end
    end,
    return_sections(Sections,Bin)
        catch
            throw:Reason->
                {error,Reason} end.

parse_extract_options([H| T],EO) ->
    case H of
        compile_source->
            EO2 = EO#extract_options{compile_source = true},
            parse_extract_options(T,EO2);
        _->
            throw({badarg,H})
    end;
parse_extract_options([],EO) ->
    EO.

compile_source(Type,File,Fd,NextLineNo,HeaderSz) ->
    {text,_Module,Forms,_HasRecs,_Mode} = do_parse_file(Type,File,Fd,NextLineNo,HeaderSz,false),
    ok = file:close(Fd),
    case compile:forms(Forms,[return_errors, debug_info]) of
        {ok,_,BeamBin}->
            BeamBin;
        {error,Errors,Warnings}->
            throw({compile,[{errors,format_errors(Errors)}, {warnings,format_errors(Warnings)}]})
    end.

format_errors(CompileErrors) ->
    [(lists:flatten([File, ":", integer_to_list(LineNo), ": ", Mod:format_error(Error)])) || {File,FileErrors} <- CompileErrors,{LineNo,Mod,Error} <- FileErrors].

return_sections(S,Bin) ->
    {ok,[normalize_section(shebang,S#sections.shebang), normalize_section(comment,S#sections.comment), normalize_section(emu_args,S#sections.emu_args), normalize_section(S#sections.type,Bin)]}.

normalize_section(Name,undefined) ->
    {Name,undefined};
normalize_section(shebang,"#!" ++ Chars) ->
    Chopped = string:trim(Chars,trailing,"$\n"),
    Stripped = string:trim(Chopped,both),
    if Stripped =:= "/usr/bin/env escript" ->
        {shebang,default};true ->
        {shebang,Stripped} end;
normalize_section(comment,Chars) ->
    Chopped = string:trim(Chars,trailing,"$\n"),
    Stripped = string:trim(string:trim(Chopped,leading,"$%"),both),
    if Stripped =:= "This is an -*- erlang -*- file" ->
        {comment,default};true ->
        {comment,Stripped} end;
normalize_section(emu_args,"%%!" ++ Chars) ->
    Chopped = string:trim(Chars,trailing,"$\n"),
    Stripped = string:trim(Chopped,both),
    {emu_args,Stripped};
normalize_section(Name,Chars) ->
    {Name,Chars}.

-spec(script_name() -> string()).

script_name() ->
    [ScriptName| _] = init:get_plain_arguments(),
    ScriptName.

-spec(start() -> no_return()).

start() ->
    start([]).

-spec(start([string()]) -> no_return()).

start(EscriptOptions) ->
    try process_flag(trap_exit,false),
    case init:get_plain_arguments() of
        [File| Args]->
            parse_and_run(File,Args,EscriptOptions);
        []->
            io:format("escript: Missing filename\n",[]),
            my_halt(127)
    end
        catch
            throw:Str->
                put_chars(io_lib:format("escript: ~ts\n",[Str])),
                my_halt(127);
            _:Reason:Stk->
                put_chars(io_lib:format("escript: Internal error: ~tp\n",[Reason])),
                put_chars(io_lib:format("~tp\n",[Stk])),
                my_halt(127) end.

-spec(parse_and_run(_,_,_) -> no_return()).

parse_and_run(File,Args,Options) ->
    CheckOnly = lists:member("s",Options),
    {Source,Module,FormsOrBin,HasRecs,Mode} = parse_file(File,CheckOnly),
    Mode2 = case lists:member("d",Options) of
        true->
            debug;
        false->
            case lists:member("c",Options) of
                true->
                    compile;
                false->
                    case lists:member("i",Options) of
                        true->
                            interpret;
                        false->
                            case lists:member("n",Options) of
                                true->
                                    native;
                                false->
                                    Mode
                            end
                    end
            end
    end,
    if is_list(FormsOrBin) ->
        case Mode2 of
            interpret->
                interpret(FormsOrBin,HasRecs,File,Args);
            compile->
                case compile:forms(FormsOrBin,[report]) of
                    {ok,Module,BeamBin}->
                        {module,Module} = code:load_binary(Module,File,BeamBin),
                        run(Module,Args);
                    _Other->
                        fatal("There were compilation errors.")
                end;
            native->
                case compile:forms(FormsOrBin,[report, native]) of
                    {ok,Module,BeamBin}->
                        {module,Module} = code:load_binary(Module,File,BeamBin),
                        run(Module,Args);
                    _Other->
                        fatal("There were compilation errors.")
                end;
            debug->
                case compile:forms(FormsOrBin,[report, debug_info]) of
                    {ok,Module,BeamBin}->
                        {module,Module} = code:load_binary(Module,File,BeamBin),
                        debug(Module,{Module,File,File,BeamBin},Args);
                    _Other->
                        fatal("There were compilation errors.")
                end
        end;is_binary(FormsOrBin) ->
        case Source of
            archive->
                {ok,FileInfo} = file:read_file_info(File),
                case code:set_primary_archive(File,FormsOrBin,FileInfo,fun escript:parse_file/1) of
                    ok
                        when CheckOnly->
                        case code:load_file(Module) of
                            {module,_}->
                                case erlang:function_exported(Module,main,1) of
                                    true->
                                        my_halt(0);
                                    false->
                                        Text = lists:concat(["Function" " ", Module, ":main/1 " "is not e" "xported"]),
                                        fatal(Text)
                                end;
                            _->
                                Text = lists:concat(["Cannot load modu" "le ", Module, " from archive"]),
                                fatal(Text)
                        end;
                    ok->
                        case Mode2 of
                            run->
                                run(Module,Args);
                            debug->
                                debug(Module,Module,Args)
                        end;
                    {error,bad_eocd}->
                        fatal("Not an archive file");
                    {error,Reason}->
                        fatal(Reason)
                end;
            beam->
                case Mode2 of
                    run->
                        {module,Module} = code:load_binary(Module,File,FormsOrBin),
                        run(Module,Args);
                    debug->
                        [Base| Rest] = lists:reverse(filename:split(File)),
                        Base2 = filename:basename(Base,code:objfile_extension()),
                        Rest2 = case Rest of
                            ["ebin"| Top]->
                                ["src"| Top];
                            _->
                                Rest
                        end,
                        SrcFile = filename:join(lists:reverse([Base2 ++ ".erl"| Rest2])),
                        debug(Module,{Module,SrcFile,File,FormsOrBin},Args)
                end
        end end.

parse_file(File) ->
    try parse_file(File,false) of 
        {_Source,_Module,FormsOrBin,_HasRecs,_Mode}
            when is_binary(FormsOrBin)->
            {ok,FormsOrBin};
        _->
            {error,no_archive_bin}
        catch
            throw:Reason->
                {error,Reason} end.

parse_file(File,CheckOnly) ->
    {HeaderSz,NextLineNo,Fd,Sections} = parse_header(File,false),
    do_parse_file(Sections#sections.type,File,Fd,NextLineNo,HeaderSz,CheckOnly).

do_parse_file(Type,File,Fd,NextLineNo,HeaderSz,CheckOnly) ->
    S = initial_state(File),
    #state{mode = Mode,source = Source,module = Module,forms_or_bin = FormsOrBin,has_records = HasRecs} = case Type of
        archive->
            ok = file:close(Fd),
            parse_archive(S,File,HeaderSz);
        beam->
            ok = file:close(Fd),
            parse_beam(S,File,HeaderSz,CheckOnly);
        source->
            parse_source(S,File,Fd,NextLineNo,HeaderSz,CheckOnly)
    end,
    {Source,Module,FormsOrBin,HasRecs,Mode}.

initial_state(File) ->
    #state{file = File,n_errors = 0,mode = interpret,exports_main = false,has_records = false}.

parse_header(File,KeepFirst) ->
    LineNo = 1,
    {ok,Fd} = case file:open(File,[read]) of
        {ok,Fd0}->
            {ok,Fd0};
        {error,R}->
            fatal(lists:concat([file:format_error(R), ": '", File, "'"]))
    end,
    {ok,HeaderSz0} = file:position(Fd,cur),
    Line1 = get_line(Fd),
    case classify_line(Line1) of
        shebang->
            find_first_body_line(Fd,HeaderSz0,LineNo,KeepFirst,#sections{shebang = Line1});
        archive->
            {HeaderSz0,LineNo,Fd,#sections{type = archive}};
        beam->
            {HeaderSz0,LineNo,Fd,#sections{type = beam}};
        _->
            find_first_body_line(Fd,HeaderSz0,LineNo,KeepFirst,#sections{})
    end.

find_first_body_line(Fd,HeaderSz0,LineNo,KeepFirst,Sections) ->
    {ok,HeaderSz1} = file:position(Fd,cur),
    Line2 = get_line(Fd),
    {ok,HeaderSz2} = file:position(Fd,cur),
    if Sections#sections.shebang =:= undefined,
    KeepFirst =:= true ->
        {HeaderSz0,LineNo,Fd,Sections#sections{type = guess_type(Line2)}};Sections#sections.shebang =:= undefined ->
        {HeaderSz1,LineNo,Fd,Sections#sections{type = guess_type(Line2)}};true ->
        case classify_line(Line2) of
            emu_args->
                Line3 = get_line(Fd),
                {HeaderSz2,LineNo + 2,Fd,Sections#sections{type = guess_type(Line3),comment = undefined,emu_args = Line2}};
            comment->
                Line3 = get_line(Fd),
                {ok,HeaderSz3} = file:position(Fd,cur),
                Line3Type = classify_line(Line3),
                if Line3Type =:= emu_args ->
                    Line4 = get_line(Fd),
                    {HeaderSz3,LineNo + 3,Fd,Sections#sections{type = guess_type(Line4),comment = Line2,emu_args = Line3}};true ->
                    {HeaderSz2,LineNo + 2,Fd,Sections#sections{type = guess_type(Line3),comment = Line2}} end;
            _->
                {HeaderSz1,LineNo + 1,Fd,Sections#sections{type = guess_type(Line2)}}
        end end.

classify_line(Line) ->
    case Line of
        "#!" ++ _->
            shebang;
        "PK" ++ _->
            archive;
        "FOR1" ++ _->
            beam;
        "%%!" ++ _->
            emu_args;
        "%" ++ _->
            comment;
        _->
            undefined
    end.

guess_type(Line) ->
    case classify_line(Line) of
        archive->
            archive;
        beam->
            beam;
        _->
            source
    end.

get_line(P) ->
    case io:get_line(P,) of
        eof->
            fatal("Premature end of file reached");
        Line->
            Line
    end.

parse_archive(S,File,HeaderSz) ->
    case file:read_file(File) of
        {ok,<<_Header:HeaderSz/binary,Bin/binary>>}->
            Mod = case init:get_argument(escript) of
                {ok,[["main", M]]}->
                    list_to_atom(M);
                _->
                    RevBase = lists:reverse(filename:basename(File)),
                    RevBase2 = case lists:dropwhile(fun (X)->
                        X =/= $. end,RevBase) of
                        [$.| Rest]->
                            Rest;
                        []->
                            RevBase
                    end,
                    list_to_atom(lists:reverse(RevBase2))
            end,
            S#state{source = archive,mode = run,module = Mod,forms_or_bin = Bin};
        {ok,_}->
            fatal("Illegal archive format");
        {error,Reason}->
            fatal(file:format_error(Reason))
    end.

parse_beam(S,File,HeaderSz,CheckOnly) ->
    {ok,<<_Header:HeaderSz/binary,Bin/binary>>} = file:read_file(File),
    case beam_lib:chunks(Bin,[exports]) of
        {ok,{Module,[{exports,Exports}]}}->
            case CheckOnly of
                true->
                    case lists:member({main,1},Exports) of
                        true->
                            my_halt(0);
                        false->
                            Text = lists:concat(["Function ", Module, ":main/1 is not exported"]),
                            fatal(Text)
                    end;
                false->
                    S#state{source = beam,mode = run,module = Module,forms_or_bin = Bin}
            end;
        {error,beam_lib,Reason}
            when is_tuple(Reason)->
            fatal(element(1,Reason))
    end.

parse_source(S,File,Fd,StartLine,HeaderSz,CheckOnly) ->
    {PreDefMacros,Module} = pre_def_macros(File),
    IncludePath = [],
    {ok,_} = file:position(Fd,0),
    _ = io:get_line(Fd,),
    Encoding = epp:set_encoding(Fd),
    {ok,_} = file:position(Fd,HeaderSz),
    case epp:open(File,Fd,StartLine,IncludePath,PreDefMacros) of
        {ok,Epp}->
            _ = [(io:setopts(Fd,[{encoding,Encoding}])) || Encoding =/= none],
            {ok,FileForm} = epp:parse_erl_form(Epp),
            OptModRes = epp:parse_erl_form(Epp),
            S2 = S#state{source = text,module = Module},
            S3 = case OptModRes of
                {ok,{attribute,_,module,M} = Form}->
                    epp_parse_file(Epp,S2#state{module = M},[Form, FileForm]);
                {ok,_}->
                    ModForm = {attribute,a1(),module,Module},
                    epp_parse_file2(Epp,S2,[ModForm, FileForm],OptModRes);
                {error,_}->
                    epp_parse_file2(Epp,S2,[FileForm],OptModRes);
                {eof,LastLine}->
                    S#state{forms_or_bin = [FileForm, {eof,LastLine}]}
            end,
            ok = epp:close(Epp),
            ok = file:close(Fd),
            check_source(S3,CheckOnly);
        {error,Reason}->
            io:format("escript: ~tp\n",[Reason]),
            fatal("Preprocessor error")
    end.

check_source(S,CheckOnly) ->
    case S of
        #state{n_errors = Nerrs}
            when Nerrs =/= 0->
            fatal("There were compilation errors.");
        #state{exports_main = ExpMain,forms_or_bin = [FileForm2, ModForm2| Forms]}->
            Forms2 = case ExpMain of
                false->
                    [{attribute,a0(),export,[{main,1}]}| Forms];
                true->
                    Forms
            end,
            Forms3 = [FileForm2, ModForm2| Forms2],
            case CheckOnly of
                true->
                    case compile:forms(Forms3,[report, strong_validation]) of
                        {ok,_}->
                            my_halt(0);
                        _Other->
                            fatal("There were compilation errors.")
                    end;
                false->
                    S#state{forms_or_bin = Forms3}
            end
    end.

pre_def_macros(File) ->
    {MegaSecs,Secs,MicroSecs} = erlang:timestamp(),
    Unique = erlang:unique_integer([positive]),
    Replace = fun (Char)->
        case Char of
            $.->
                $_;
            _->
                Char
        end end,
    CleanBase = lists:map(Replace,filename:basename(File)),
    ModuleStr = CleanBase ++ "__" ++ "escript__" ++ integer_to_list(MegaSecs) ++ "__" ++ integer_to_list(Secs) ++ "__" ++ integer_to_list(MicroSecs) ++ "__" ++ integer_to_list(Unique),
    Module = list_to_atom(ModuleStr),
    PreDefMacros = [{'MODULE',Module,redefine}, {'MODULE_STRING',ModuleStr,redefine}],
    {PreDefMacros,Module}.

epp_parse_file(Epp,S,Forms) ->
    Parsed = epp:parse_erl_form(Epp),
    epp_parse_file2(Epp,S,Forms,Parsed).

epp_parse_file2(Epp,S,Forms,Parsed) ->
    case Parsed of
        {ok,Form}->
            case Form of
                {attribute,_,record,_}->
                    S2 = S#state{has_records = true},
                    epp_parse_file(Epp,S2,[Form| Forms]);
                {attribute,Ln,mode,NewMode}->
                    S2 = S#state{mode = NewMode},
                    if NewMode =:= compile;
                    NewMode =:= interpret;
                    NewMode =:= debug;
                    NewMode =:= native ->
                        epp_parse_file(Epp,S2,[Form| Forms]);true ->
                        Args = lists:flatten(io_lib:format("illegal mo" "de attribu" "te: ~p",[NewMode])),
                        io:format("~ts:~w ~s\n",[S#state.file, Ln, Args]),
                        Error = {error,{Ln,erl_parse,Args}},
                        Nerrs = S#state.n_errors + 1,
                        epp_parse_file(Epp,S2#state{n_errors = Nerrs},[Error| Forms]) end;
                {attribute,_,export,Fs}->
                    case lists:member({main,1},Fs) of
                        false->
                            epp_parse_file(Epp,S,[Form| Forms]);
                        true->
                            epp_parse_file(Epp,S#state{exports_main = true},[Form| Forms])
                    end;
                _->
                    epp_parse_file(Epp,S,[Form| Forms])
            end;
        {error,{Ln,Mod,Args}} = Form->
            io:format("~ts:~w: ~ts\n",[S#state.file, Ln, Mod:format_error(Args)]),
            epp_parse_file(Epp,S#state{n_errors = S#state.n_errors + 1},[Form| Forms]);
        {eof,LastLine}->
            S#state{forms_or_bin = lists:reverse([{eof,LastLine}| Forms])}
    end.

-spec(debug(_,_,_) -> no_return()).

debug(Module,AbsMod,Args) ->
    case hidden_apply(debugger,debugger,start,[]) of
        {ok,_}->
            case hidden_apply(debugger,int,i,[AbsMod]) of
                {module,_}->
                    hidden_apply(debugger,debugger,auto_attach,[[init]]),
                    run(Module,Args);
                error->
                    Text = lists:concat(["Cannot load the code for ", Module, " into the debugger"]),
                    fatal(Text)
            end;
        _->
            fatal("Cannot start the debugger")
    end.

-spec(run(_,_) -> no_return()).

run(Module,Args) ->
    try Module:main(Args),
    my_halt(0)
        catch
            Class:Reason:StackTrace->
                fatal(format_exception(Class,Reason,StackTrace)) end.

-spec(interpret(_,_,_,_) -> no_return()).

interpret(Forms,HasRecs,File,Args) ->
    case erl_lint:module(Forms) of
        {ok,Ws}->
            report_warnings(Ws);
        {error,Es,Ws}->
            report_errors(Es),
            report_warnings(Ws),
            fatal("There were compilation errors.")
    end,
    Forms2 = case HasRecs of
        false->
            Forms;
        true->
            erl_expand_records:module(Forms,[])
    end,
    Dict = parse_to_map(Forms2),
    ArgsA = erl_parse:abstract(Args,0),
    Anno = a0(),
    Call = {call,Anno,{atom,Anno,main},[ArgsA]},
    try _ = erl_eval:expr(Call,erl_eval:new_bindings(),{value,fun (I,J)->
        code_handler(I,J,Dict,File) end}),
    my_halt(0)
        catch
            Class:Reason:StackTrace->
                fatal(format_exception(Class,Reason,StackTrace)) end.

report_errors(Errors) ->
    lists:foreach(fun ({{F,_L},Eds})->
        list_errors(F,Eds);({F,Eds})->
        list_errors(F,Eds) end,Errors).

list_errors(F,[{Line,Mod,E}| Es]) ->
    io:fwrite("~ts:~w: ~ts\n",[F, Line, Mod:format_error(E)]),
    list_errors(F,Es);
list_errors(F,[{Mod,E}| Es]) ->
    io:fwrite("~ts: ~ts\n",[F, Mod:format_error(E)]),
    list_errors(F,Es);
list_errors(_F,[]) ->
    ok.

report_warnings(Ws0) ->
    Ws1 = lists:flatmap(fun ({{F,_L},Eds})->
        format_message(F,Eds);({F,Eds})->
        format_message(F,Eds) end,Ws0),
    Ws = ordsets:from_list(Ws1),
    lists:foreach(fun ({_,Str})->
        io:put_chars(Str) end,Ws).

format_message(F,[{Line,Mod,E}| Es]) ->
    M = {{F,Line},io_lib:format("~ts:~w: Warning: ~ts\n",[F, Line, Mod:format_error(E)])},
    [M| format_message(F,Es)];
format_message(F,[{Mod,E}| Es]) ->
    M = {none,io_lib:format("~ts: Warning: ~ts\n",[F, Mod:format_error(E)])},
    [M| format_message(F,Es)];
format_message(_,[]) ->
    [].

parse_to_map(L) ->
    parse_to_map(L,maps:new()).

parse_to_map([{function,_,Name,Arity,Clauses}| T],Map0) ->
    Map = maps:put({local,Name,Arity},Clauses,Map0),
    parse_to_map(T,Map);
parse_to_map([{attribute,_,import,{Mod,Funcs}}| T],Map0) ->
    Map = lists:foldl(fun (I,D)->
        maps:put({remote,I},Mod,D) end,Map0,Funcs),
    parse_to_map(T,Map);
parse_to_map([_| T],Map) ->
    parse_to_map(T,Map);
parse_to_map([],Map) ->
    Map.

code_handler(local,[file],_,File) ->
    File;
code_handler(Name,Args,Map,File) ->
    Arity = length(Args),
    case maps:find({local,Name,Arity},Map) of
        {ok,Cs}->
            LF = {value,fun (I,J)->
                code_handler(I,J,Map,File) end},
            case erl_eval:match_clause(Cs,Args,erl_eval:new_bindings(),LF) of
                {Body,Bs}->
                    eval_exprs(Body,Bs,LF,none,none);
                nomatch->
                    error({function_clause,[{local,Name,Args}]})
            end;
        error->
            case maps:find({remote,{Name,Arity}},Map) of
                {ok,Mod}->
                    apply(Mod,Name,Args);
                error->
                    io:format("Script does not export ~tw/~w\n",[Name, Arity]),
                    my_halt(127)
            end
    end.

eval_exprs([E],Bs0,Lf,Ef,_RBs) ->
    RBs1 = value,
    erl_eval:expr(E,Bs0,Lf,Ef,RBs1);
eval_exprs([E| Es],Bs0,Lf,Ef,RBs) ->
    RBs1 = none,
    {value,_V,Bs} = erl_eval:expr(E,Bs0,Lf,Ef,RBs1),
    eval_exprs(Es,Bs,Lf,Ef,RBs).

format_exception(Class,Reason,StackTrace) ->
    Enc = encoding(),
    P = case Enc of
        latin1->
            "P";
        _->
            "tP"
    end,
    PF = fun (Term,I)->
        io_lib:format("~." ++ integer_to_list(I) ++ P,[Term, 50]) end,
    StackFun = fun (M,_F,_A)->
        (M =:= erl_eval) or (M =:= escript) end,
    erl_error:format_exception(1,Class,Reason,StackTrace,StackFun,PF,Enc).

encoding() ->
    case io:getopts() of
        {error,_} = _Err->
            latin1;
        Opts->
            case lists:keyfind(encoding,1,Opts) of
                false->
                    latin1;
                {encoding,Encoding}->
                    Encoding
            end
    end.

put_chars(String) ->
    try io:put_chars(String)
        catch
            _:_->
                erlang:display(lists:flatten(String)) end.

a0() ->
    anno(0).

a1() ->
    anno(1).

anno(L) ->
    erl_anno:new(L).

fatal(Str) ->
    throw(Str).

-spec(my_halt(_) -> no_return()).

my_halt(Reason) ->
    halt(Reason).

hidden_apply(App,M,F,Args) ->
    try apply(fun ()->
        M end(),F,Args)
        catch
            error:undef:StackTrace->
                case StackTrace of
                    [{M,F,Args,_}| _]->
                        Arity = length(Args),
                        Text = io_lib:format("Call to ~w:~w/~w in application " "~w failed.\n",[M, F, Arity, App]),
                        fatal(Text);
                    Stk->
                        erlang:raise(error,undef,Stk)
                end end.
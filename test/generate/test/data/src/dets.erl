-file("dets.erl", 1).

-module(dets).

-export([all/0, bchunk/2, close/1, delete/2, delete_all_objects/1, delete_object/2, first/1, foldl/3, foldr/3, from_ets/2, info/1, info/2, init_table/2, init_table/3, insert/2, insert_new/2, is_compatible_bchunk_format/2, is_dets_file/1, lookup/2, match/1, match/2, match/3, match_delete/2, match_object/1, match_object/2, match_object/3, member/2, next/2, open_file/1, open_file/2, pid2name/1, repair_continuation/2, safe_fixtable/2, select/1, select/2, select/3, select_delete/2, slot/2, sync/1, table/1, table/2, to_ets/2, traverse/2, update_counter/3]).

-export([start/0, stop/0]).

-export([istart_link/1, init/2, internal_open/3, add_user/3, internal_close/1, remove_user/2, system_continue/3, system_terminate/4, system_code_change/4]).

-export([file_info/1, fsck/1, fsck/2, get_head_field/2, view/1, where/2, verbose/0, verbose/1]).

-export([lookup_keys/2]).

-export_type([bindings_cont/0, cont/0, object_cont/0, select_cont/0, tab_name/0]).

-compile({inline,[{einval,2}, {badarg,2}, {undefined,1}, {badarg_exit,2}, {lookup_reply,2}]}).

-file("/usr/lib/erlang/lib/kernel-7.2/include/file.hrl", 1).

-record(file_info,{size::non_neg_integer()|undefined,type::device|directory|other|regular|symlink|undefined,access::read|write|read_write|none|undefined,atime::file:date_time()|non_neg_integer()|undefined,mtime::file:date_time()|non_neg_integer()|undefined,ctime::file:date_time()|non_neg_integer()|undefined,mode::non_neg_integer()|undefined,links::non_neg_integer()|undefined,major_device::non_neg_integer()|undefined,minor_device::non_neg_integer()|undefined,inode::non_neg_integer()|undefined,uid::non_neg_integer()|undefined,gid::non_neg_integer()|undefined}).

-record(file_descriptor,{module::module(),data::term()}).

-file("dets.erl", 99).

-file("dets.hrl", 1).

-type(access()::read|read_write).

-type(auto_save()::infinity|non_neg_integer()).

-type(hash_bif()::phash|phash2).

-type(keypos()::pos_integer()).

-type(no_colls()::[{LogSize::non_neg_integer(),NoCollections::non_neg_integer()}]).

-type(no_slots()::default|non_neg_integer()).

-type(tab_name()::term()).

-type(type()::bag|duplicate_bag|set).

-type(update_mode()::dirty|new_dirty|saved|{error,Reason::term()}).

-record(head,{m::non_neg_integer(),m2::non_neg_integer(),next::non_neg_integer(),fptr::file:fd(),no_objects::non_neg_integer(),no_keys::non_neg_integer(),maxobjsize::undefined|non_neg_integer(),n,type::type(),keypos::keypos(),freelists::undefined|tuple(),freelists_p::undefined|non_neg_integer(),no_collections::undefined|no_colls(),auto_save::auto_save(),update_mode::update_mode(),fixed = false::false|{{integer(),integer()},[{pid(),non_neg_integer()}]},hash_bif::hash_bif(),has_md5::boolean(),min_no_slots::no_slots(),max_no_slots::no_slots(),cache::undefined|cache(),filename::file:name(),access = read_write::access(),ram_file = false::boolean(),name::tab_name(),parent::undefined|pid(),server::undefined|pid(),bump::non_neg_integer(),base::non_neg_integer()}).

-record(fileheader,{freelist::non_neg_integer(),fl_base::non_neg_integer(),cookie::non_neg_integer(),closed_properly::non_neg_integer(),type::badtype|type(),version::non_neg_integer(),m::non_neg_integer(),next::non_neg_integer(),keypos::keypos(),no_objects::non_neg_integer(),no_keys::non_neg_integer(),min_no_slots::non_neg_integer(),max_no_slots::non_neg_integer(),no_colls::undefined|no_colls(),hash_method::non_neg_integer(),read_md5::binary(),has_md5::boolean(),md5::binary(),trailer::non_neg_integer(),eof::non_neg_integer(),n}).

-type(delay()::non_neg_integer()).

-type(threshold()::non_neg_integer()).

-type(cache_parms()::{Delay::delay(),Size::threshold()}).

-record(cache,{cache::[{Key::term(),{Seq::non_neg_integer(),Item::term()}}],csize::non_neg_integer(),inserts::non_neg_integer(),wrtime::undefined|integer(),tsize::threshold(),delay::delay()}).

-type(cache()::#cache{}).

-file("dets.erl", 101).

-record(dets_cont,{what::undefined|bchunk|bindings|object|select,no_objs::default|pos_integer(),bin::eof|binary(),alloc::binary()|{From::non_neg_integer(),To::non_neg_integer,binary()},tab::tab_name(),proc::undefined|pid(),match_program::true|undefined|{match_spec,ets:comp_match_spec()}}).

-record(open_args,{file::list(),type::type(),keypos::keypos(),repair::force|boolean(),min_no_slots::no_slots(),max_no_slots::no_slots(),ram_file::boolean(),delayed_write::cache_parms(),auto_save::auto_save(),access::access(),debug::boolean()}).

-opaque(bindings_cont()::#dets_cont{}).

-opaque(cont()::#dets_cont{}).

-type(match_spec()::ets:match_spec()).

-type(object()::tuple()).

-opaque(object_cont()::#dets_cont{}).

-type(pattern()::atom()|tuple()).

-opaque(select_cont()::#dets_cont{}).

add_user(Pid,Tab,Args) ->
    req(Pid,{add_user,Tab,Args}).

-spec(all() -> [tab_name()]).

all() ->
    dets_server:all().

-spec(bchunk(Name,Continuation) -> {Continuation2,Data}|'$end_of_table'|{error,Reason} when Name::tab_name(),Continuation::start|cont(),Continuation2::cont(),Data::binary()|tuple(),Reason::term()).

bchunk(Tab,start) ->
    badarg(treq(Tab,{bchunk_init,Tab}),[Tab, start]);
bchunk(Tab,#dets_cont{what = bchunk,tab = Tab} = State) ->
    badarg(treq(Tab,{bchunk,State}),[Tab, State]);
bchunk(Tab,Term) ->
    error(badarg,[Tab, Term]).

-spec(close(Name) -> ok|{error,Reason} when Name::tab_name(),Reason::term()).

close(Tab) ->
    case dets_server:close(Tab) of
        badarg->
            {error,not_owner};
        Reply->
            Reply
    end.

-spec(delete(Name,Key) -> ok|{error,Reason} when Name::tab_name(),Key::term(),Reason::term()).

delete(Tab,Key) ->
    badarg(treq(Tab,{delete_key,[Key]}),[Tab, Key]).

-spec(delete_all_objects(Name) -> ok|{error,Reason} when Name::tab_name(),Reason::term()).

delete_all_objects(Tab) ->
    case treq(Tab,delete_all_objects) of
        badarg->
            error(badarg,[Tab]);
        fixed->
            match_delete(Tab,_);
        Reply->
            Reply
    end.

-spec(delete_object(Name,Object) -> ok|{error,Reason} when Name::tab_name(),Object::object(),Reason::term()).

delete_object(Tab,O) ->
    badarg(treq(Tab,{delete_object,[O]}),[Tab, O]).

fsck(Fname,_Version) ->
    fsck(Fname).

fsck(Fname) ->
     catch begin {ok,Fd,FH} = read_file_header(Fname,read,false),
    void,
    case dets_v9:check_file_header(FH,Fd) of
        {error,not_closed}->
            fsck(Fd,make_ref(),Fname,FH,default,default);
        {ok,_Head}->
            fsck(Fd,make_ref(),Fname,FH,default,default);
        Error->
            Error
    end end.

-spec(first(Name) -> Key|'$end_of_table' when Name::tab_name(),Key::term()).

first(Tab) ->
    badarg_exit(treq(Tab,first),[Tab]).

-spec(foldr(Function,Acc0,Name) -> Acc|{error,Reason} when Name::tab_name(),Function::fun((Object::object(),AccIn) -> AccOut),Acc0::term(),Acc::term(),AccIn::term(),AccOut::term(),Reason::term()).

foldr(Fun,Acc,Tab) ->
    foldl(Fun,Acc,Tab).

-spec(foldl(Function,Acc0,Name) -> Acc|{error,Reason} when Name::tab_name(),Function::fun((Object::object(),AccIn) -> AccOut),Acc0::term(),Acc::term(),AccIn::term(),AccOut::term(),Reason::term()).

foldl(Fun,Acc,Tab) ->
    Ref = make_ref(),
    badarg(do_traverse(Fun,Acc,Tab,Ref),[Fun, Acc, Tab]).

-spec(from_ets(Name,EtsTab) -> ok|{error,Reason} when Name::tab_name(),EtsTab::ets:tab(),Reason::term()).

from_ets(DTab,ETab) ->
    ets:safe_fixtable(ETab,true),
    Spec = [{_,[],['$_']}],
    LC = ets:select(ETab,Spec,100),
    InitFun = from_ets_fun(LC,ETab),
    Reply = treq(DTab,{initialize,InitFun,term,default}),
    ets:safe_fixtable(ETab,false),
    case Reply of
        {thrown,Thrown}->
            throw(Thrown);
        Else->
            badarg(Else,[DTab, ETab])
    end.

from_ets_fun(LC,ETab) ->
    fun (close)->
        ok;(read)
        when LC =:= '$end_of_table'->
        end_of_input;(read)->
        {L,C} = LC,
        {L,from_ets_fun(ets:select(C),ETab)} end.

-spec(info(Name) -> InfoList|undefined when Name::tab_name(),InfoList::[InfoTuple],InfoTuple::{file_size,non_neg_integer()}|{filename,file:name()}|{keypos,keypos()}|{size,non_neg_integer()}|{type,type()}).

info(Tab) ->
    case  catch dets_server:get_pid(Tab) of
        {'EXIT',_Reason}->
            undefined;
        Pid->
            undefined(req(Pid,info))
    end.

-spec(info(Name,Item) -> Value|undefined when Name::tab_name(),Item::access|auto_save|bchunk_format|hash|file_size|filename|keypos|memory|no_keys|no_objects|no_slots|owner|ram_file|safe_fixed|safe_fixed_monotonic_time|size|type,Value::term()).

info(Tab,owner) ->
    case  catch dets_server:get_pid(Tab) of
        Pid
            when is_pid(Pid)->
            Pid;
        _->
            undefined
    end;
info(Tab,users) ->
    case dets_server:users(Tab) of
        []->
            undefined;
        Users->
            Users
    end;
info(Tab,Tag) ->
    case  catch dets_server:get_pid(Tab) of
        {'EXIT',_Reason}->
            undefined;
        Pid->
            undefined(req(Pid,{info,Tag}))
    end.

-spec(init_table(Name,InitFun) -> ok|{error,Reason} when Name::tab_name(),InitFun::fun((Arg) -> Res),Arg::read|close,Res::end_of_input|{[object()],InitFun}|{Data,InitFun}|term(),Reason::term(),Data::binary()|tuple()).

init_table(Tab,InitFun) ->
    init_table(Tab,InitFun,[]).

-spec(init_table(Name,InitFun,Options) -> ok|{error,Reason} when Name::tab_name(),InitFun::fun((Arg) -> Res),Arg::read|close,Res::end_of_input|{[object()],InitFun}|{Data,InitFun}|term(),Options::Option|[Option],Option::{min_no_slots,no_slots()}|{format,term|bchunk},Reason::term(),Data::binary()|tuple()).

init_table(Tab,InitFun,Options)
    when is_function(InitFun)->
    case options(Options,[format, min_no_slots]) of
        {badarg,_}->
            error(badarg,[Tab, InitFun, Options]);
        [Format, MinNoSlots]->
            case treq(Tab,{initialize,InitFun,Format,MinNoSlots}) of
                {thrown,Thrown}->
                    throw(Thrown);
                Else->
                    badarg(Else,[Tab, InitFun, Options])
            end
    end;
init_table(Tab,InitFun,Options) ->
    error(badarg,[Tab, InitFun, Options]).

-spec(insert(Name,Objects) -> ok|{error,Reason} when Name::tab_name(),Objects::object()|[object()],Reason::term()).

insert(Tab,Objs)
    when is_list(Objs)->
    badarg(treq(Tab,{insert,Objs}),[Tab, Objs]);
insert(Tab,Obj) ->
    badarg(treq(Tab,{insert,[Obj]}),[Tab, Obj]).

-spec(insert_new(Name,Objects) -> boolean()|{error,Reason} when Name::tab_name(),Objects::object()|[object()],Reason::term()).

insert_new(Tab,Objs)
    when is_list(Objs)->
    badarg(treq(Tab,{insert_new,Objs}),[Tab, Objs]);
insert_new(Tab,Obj) ->
    badarg(treq(Tab,{insert_new,[Obj]}),[Tab, Obj]).

internal_close(Pid) ->
    req(Pid,close).

internal_open(Pid,Ref,Args) ->
    req(Pid,{internal_open,Ref,Args}).

-spec(is_compatible_bchunk_format(Name,BchunkFormat) -> boolean() when Name::tab_name(),BchunkFormat::binary()).

is_compatible_bchunk_format(Tab,Term) ->
    badarg(treq(Tab,{is_compatible_bchunk_format,Term}),[Tab, Term]).

-spec(is_dets_file(Filename) -> boolean()|{error,Reason} when Filename::file:name(),Reason::term()).

is_dets_file(FileName) ->
    case  catch read_file_header(FileName,read,false) of
        {ok,Fd,FH}->
            _ = file:close(Fd),
            FH#fileheader.cookie =:= 11259375;
        {error,{tooshort,_}}->
            false;
        {error,{not_a_dets_file,_}}->
            false;
        Other->
            Other
    end.

-spec(lookup(Name,Key) -> Objects|{error,Reason} when Name::tab_name(),Key::term(),Objects::[object()],Reason::term()).

lookup(Tab,Key) ->
    badarg(treq(Tab,{lookup_keys,[Key]}),[Tab, Key]).

lookup_keys(Tab,Keys) ->
    case  catch lists:usort(Keys) of
        UKeys
            when is_list(UKeys),
            UKeys =/= []->
            badarg(treq(Tab,{lookup_keys,UKeys}),[Tab, Keys]);
        _Else->
            error(badarg,[Tab, Keys])
    end.

-spec(match(Name,Pattern) -> [Match]|{error,Reason} when Name::tab_name(),Pattern::pattern(),Match::[term()],Reason::term()).

match(Tab,Pat) ->
    badarg(safe_match(Tab,Pat,bindings),[Tab, Pat]).

-spec(match(Name,Pattern,N) -> {[Match],Continuation}|'$end_of_table'|{error,Reason} when Name::tab_name(),Pattern::pattern(),N::default|non_neg_integer(),Continuation::bindings_cont(),Match::[term()],Reason::term()).

match(Tab,Pat,N) ->
    badarg(init_chunk_match(Tab,Pat,bindings,N,no_safe),[Tab, Pat, N]).

-spec(match(Continuation) -> {[Match],Continuation2}|'$end_of_table'|{error,Reason} when Continuation::bindings_cont(),Continuation2::bindings_cont(),Match::[term()],Reason::term()).

match(State)
    when State#dets_cont.what =:= bindings->
    badarg(chunk_match(State,no_safe),[State]);
match(Term) ->
    error(badarg,[Term]).

-spec(match_delete(Name,Pattern) -> ok|{error,Reason} when Name::tab_name(),Pattern::pattern(),Reason::term()).

match_delete(Tab,Pat) ->
    badarg(match_delete(Tab,Pat,delete),[Tab, Pat]).

match_delete(Tab,Pat,What) ->
    case compile_match_spec(What,Pat) of
        {Spec,MP}->
            case  catch dets_server:get_pid(Tab) of
                {'EXIT',_Reason}->
                    badarg;
                Proc->
                    R = req(Proc,{match_delete_init,MP,Spec}),
                    do_match_delete(Proc,R,What,0)
            end;
        badarg->
            badarg
    end.

do_match_delete(_Proc,{done,N1},select,N) ->
    N + N1;
do_match_delete(_Proc,{done,_N1},_What,_N) ->
    ok;
do_match_delete(Proc,{cont,State,N1},What,N) ->
    do_match_delete(Proc,req(Proc,{match_delete,State}),What,N + N1);
do_match_delete(_Proc,Error,_What,_N) ->
    Error.

-spec(match_object(Name,Pattern) -> Objects|{error,Reason} when Name::tab_name(),Pattern::pattern(),Objects::[object()],Reason::term()).

match_object(Tab,Pat) ->
    badarg(safe_match(Tab,Pat,object),[Tab, Pat]).

-spec(match_object(Name,Pattern,N) -> {Objects,Continuation}|'$end_of_table'|{error,Reason} when Name::tab_name(),Pattern::pattern(),N::default|non_neg_integer(),Continuation::object_cont(),Objects::[object()],Reason::term()).

match_object(Tab,Pat,N) ->
    badarg(init_chunk_match(Tab,Pat,object,N,no_safe),[Tab, Pat, N]).

-spec(match_object(Continuation) -> {Objects,Continuation2}|'$end_of_table'|{error,Reason} when Continuation::object_cont(),Continuation2::object_cont(),Objects::[object()],Reason::term()).

match_object(State)
    when State#dets_cont.what =:= object->
    badarg(chunk_match(State,no_safe),[State]);
match_object(Term) ->
    error(badarg,[Term]).

-spec(member(Name,Key) -> boolean()|{error,Reason} when Name::tab_name(),Key::term(),Reason::term()).

member(Tab,Key) ->
    badarg(treq(Tab,{member,Key}),[Tab, Key]).

-spec(next(Name,Key1) -> Key2|'$end_of_table' when Name::tab_name(),Key1::term(),Key2::term()).

next(Tab,Key) ->
    badarg_exit(treq(Tab,{next,Key}),[Tab, Key]).

-spec(open_file(Filename) -> {ok,Reference}|{error,Reason} when Filename::file:name(),Reference::reference(),Reason::term()).

open_file(File0) ->
    File = to_list(File0),
    case is_list(File) of
        true->
            case dets_server:open_file(File) of
                badarg->
                    error(dets_process_died,[File]);
                Reply->
                    einval(Reply,[File])
            end;
        false->
            error(badarg,[File0])
    end.

-spec(open_file(Name,Args) -> {ok,Name}|{error,Reason} when Name::tab_name(),Args::[OpenArg],OpenArg::{access,access()}|{auto_save,auto_save()}|{estimated_no_objects,non_neg_integer()}|{file,file:name()}|{max_no_slots,no_slots()}|{min_no_slots,no_slots()}|{keypos,keypos()}|{ram_file,boolean()}|{repair,boolean()|force}|{type,type()},Reason::term()).

open_file(Tab,Args)
    when is_list(Args)->
    case  catch defaults(Tab,Args) of
        OpenArgs
            when is_record(OpenArgs,open_args)->
            case dets_server:open_file(Tab,OpenArgs) of
                badarg->
                    error(dets_process_died,[Tab, Args]);
                Reply->
                    einval(Reply,[Tab, Args])
            end;
        _->
            error(badarg,[Tab, Args])
    end;
open_file(Tab,Arg) ->
    open_file(Tab,[Arg]).

-spec(pid2name(Pid) -> {ok,Name}|undefined when Pid::pid(),Name::tab_name()).

pid2name(Pid) ->
    dets_server:pid2name(Pid).

remove_user(Pid,From) ->
    req(Pid,{close,From}).

-spec(repair_continuation(Continuation,MatchSpec) -> Continuation2 when Continuation::select_cont(),Continuation2::select_cont(),MatchSpec::match_spec()).

repair_continuation(#dets_cont{match_program = {match_spec,B}} = Cont,MS) ->
    case ets:is_compiled_ms(B) of
        true->
            Cont;
        false->
            Cont#dets_cont{match_program = {match_spec,ets:match_spec_compile(MS)}}
    end;
repair_continuation(#dets_cont{} = Cont,_MS) ->
    Cont;
repair_continuation(T,MS) ->
    error(badarg,[T, MS]).

-spec(safe_fixtable(Name,Fix) -> ok when Name::tab_name(),Fix::boolean()).

safe_fixtable(Tab,Bool)
    when Bool;
     not Bool->
    badarg(treq(Tab,{safe_fixtable,Bool}),[Tab, Bool]);
safe_fixtable(Tab,Term) ->
    error(badarg,[Tab, Term]).

-spec(select(Name,MatchSpec) -> Selection|{error,Reason} when Name::tab_name(),MatchSpec::match_spec(),Selection::[term()],Reason::term()).

select(Tab,Pat) ->
    badarg(safe_match(Tab,Pat,select),[Tab, Pat]).

-spec(select(Name,MatchSpec,N) -> {Selection,Continuation}|'$end_of_table'|{error,Reason} when Name::tab_name(),MatchSpec::match_spec(),N::default|non_neg_integer(),Continuation::select_cont(),Selection::[term()],Reason::term()).

select(Tab,Pat,N) ->
    badarg(init_chunk_match(Tab,Pat,select,N,no_safe),[Tab, Pat, N]).

-spec(select(Continuation) -> {Selection,Continuation2}|'$end_of_table'|{error,Reason} when Continuation::select_cont(),Continuation2::select_cont(),Selection::[term()],Reason::term()).

select(State)
    when State#dets_cont.what =:= select->
    badarg(chunk_match(State,no_safe),[State]);
select(Term) ->
    error(badarg,[Term]).

-spec(select_delete(Name,MatchSpec) -> N|{error,Reason} when Name::tab_name(),MatchSpec::match_spec(),N::non_neg_integer(),Reason::term()).

select_delete(Tab,Pat) ->
    badarg(match_delete(Tab,Pat,select),[Tab, Pat]).

-spec(slot(Name,I) -> '$end_of_table'|Objects|{error,Reason} when Name::tab_name(),I::non_neg_integer(),Objects::[object()],Reason::term()).

slot(Tab,Slot)
    when is_integer(Slot),
    Slot >= 0->
    badarg(treq(Tab,{slot,Slot}),[Tab, Slot]);
slot(Tab,Term) ->
    error(badarg,[Tab, Term]).

start() ->
    dets_server:start().

stop() ->
    dets_server:stop().

istart_link(Server) ->
    {ok,proc_lib:spawn_link(dets,init,[self(), Server])}.

-spec(sync(Name) -> ok|{error,Reason} when Name::tab_name(),Reason::term()).

sync(Tab) ->
    badarg(treq(Tab,sync),[Tab]).

-spec(table(Name) -> QueryHandle when Name::tab_name(),QueryHandle::qlc:query_handle()).

table(Tab) ->
    table(Tab,[]).

-spec(table(Name,Options) -> QueryHandle when Name::tab_name(),Options::Option|[Option],Option::{n_objects,Limit}|{traverse,TraverseMethod},Limit::default|pos_integer(),TraverseMethod::first_next|select|{select,match_spec()},QueryHandle::qlc:query_handle()).

table(Tab,Opts) ->
    case options(Opts,[traverse, n_objects]) of
        {badarg,_}->
            error(badarg,[Tab, Opts]);
        [Traverse, NObjs]->
            TF = case Traverse of
                first_next->
                    fun ()->
                        qlc_next(Tab,first(Tab)) end;
                select->
                    fun (MS)->
                        qlc_select(select(Tab,MS,NObjs)) end;
                {select,MS}->
                    fun ()->
                        qlc_select(select(Tab,MS,NObjs)) end
            end,
            PreFun = fun (_)->
                safe_fixtable(Tab,true) end,
            PostFun = fun ()->
                safe_fixtable(Tab,false) end,
            InfoFun = fun (Tag)->
                table_info(Tab,Tag) end,
            LookupFun = case Traverse of
                {select,_MS}->
                    undefined;
                _->
                    fun (_KeyPos,[K])->
                        lookup(Tab,K);(_KeyPos,Ks)->
                        lookup_keys(Tab,Ks) end
            end,
            FormatFun = fun ({all,_NElements,_ElementFun})->
                As = [Tab| [Opts || _ <- [[]],Opts =/= []]],
                {dets,table,As};({match_spec,MS})->
                {dets,table,[Tab, [{traverse,{select,MS}}| listify(Opts)]]};({lookup,_KeyPos,[Value],_NElements,ElementFun})->
                io_lib:format("~w:lookup(~w, ~w)",[dets, Tab, ElementFun(Value)]);({lookup,_KeyPos,Values,_NElements,ElementFun})->
                Vals = [(ElementFun(V)) || V <- Values],
                io_lib:format("lists:flatmap(fun(V) -> ~w:lookup" "(~w, V) end, ~w)",[dets, Tab, Vals]) end,
            qlc:table(TF,[{pre_fun,PreFun}, {post_fun,PostFun}, {info_fun,InfoFun}, {format_fun,FormatFun}, {key_equality,'=:='}, {lookup_fun,LookupFun}])
    end.

qlc_next(_Tab,'$end_of_table') ->
    [];
qlc_next(Tab,Key) ->
    case lookup(Tab,Key) of
        Objects
            when is_list(Objects)->
            Objects ++ fun ()->
                qlc_next(Tab,next(Tab,Key)) end;
        Error->
            exit(Error)
    end.

qlc_select('$end_of_table') ->
    [];
qlc_select({Objects,Cont})
    when is_list(Objects)->
    Objects ++ fun ()->
        qlc_select(select(Cont)) end;
qlc_select(Error) ->
    Error.

table_info(Tab,num_of_objects) ->
    info(Tab,size);
table_info(Tab,keypos) ->
    info(Tab,keypos);
table_info(Tab,is_unique_objects) ->
    info(Tab,type) =/= duplicate_bag;
table_info(_Tab,_) ->
    undefined.

-spec(to_ets(Name,EtsTab) -> EtsTab|{error,Reason} when Name::tab_name(),EtsTab::ets:tab(),Reason::term()).

to_ets(DTab,ETab) ->
    case ets:info(ETab,protection) of
        undefined->
            error(badarg,[DTab, ETab]);
        _->
            Fun = fun (X,T)->
                true = ets:insert(T,X),
                T end,
            foldl(Fun,ETab,DTab)
    end.

-spec(traverse(Name,Fun) -> Return|{error,Reason} when Name::tab_name(),Fun::fun((Object) -> FunReturn),Object::object(),FunReturn::continue|{continue,Val}|{done,Value}|OtherValue,Return::[term()]|OtherValue,Val::term(),Value::term(),OtherValue::term(),Reason::term()).

traverse(Tab,Fun) ->
    Ref = make_ref(),
    TFun = fun (O,Acc)->
        case Fun(O) of
            continue->
                Acc;
            {continue,Val}->
                [Val| Acc];
            {done,Value}->
                throw({Ref,[Value| Acc]});
            Other->
                throw({Ref,Other})
        end end,
    badarg(do_traverse(TFun,[],Tab,Ref),[Tab, Fun]).

-spec(update_counter(Name,Key,Increment) -> Result when Name::tab_name(),Key::term(),Increment::{Pos,Incr}|Incr,Pos::integer(),Incr::integer(),Result::integer()).

update_counter(Tab,Key,C) ->
    badarg(treq(Tab,{update_counter,Key,C}),[Tab, Key, C]).

verbose() ->
    verbose(true).

verbose(What) ->
    ok = dets_server:verbose(What),
    All = dets_server:all(),
    Fun = fun (Tab)->
        treq(Tab,{set_verbose,What}) end,
    lists:foreach(Fun,All),
    All.

where(Tab,Object) ->
    badarg(treq(Tab,{where,Object}),[Tab, Object]).

do_traverse(Fun,Acc,Tab,Ref) ->
    case  catch dets_server:get_pid(Tab) of
        {'EXIT',_Reason}->
            badarg;
        Proc->
            try do_trav(Proc,Acc,Fun)
                catch
                    throw:{Ref,Result}->
                        Result end
    end.

do_trav(Proc,Acc,Fun) ->
    {Spec,MP} = compile_match_spec(object,_),
    case req(Proc,{match,MP,Spec,default,safe}) of
        {cont,State}->
            do_trav(State,Proc,Acc,Fun);
        Error->
            Error
    end.

do_trav(State,Proc,Acc,Fun) ->
    case req(Proc,{match_init,State,safe}) of
        '$end_of_table'->
            Acc;
        {cont,{Bins,NewState}}->
            do_trav_bins(NewState,Proc,Acc,Fun,lists:reverse(Bins));
        Error->
            Error
    end.

do_trav_bins(State,Proc,Acc,Fun,[]) ->
    do_trav(State,Proc,Acc,Fun);
do_trav_bins(State,Proc,Acc,Fun,[Bin| Bins]) ->
    case  catch binary_to_term(Bin) of
        {'EXIT',_}->
            req(Proc,{corrupt,dets_utils:bad_object(do_trav_bins,Bin)});
        Term->
            NewAcc = Fun(Term,Acc),
            do_trav_bins(State,Proc,NewAcc,Fun,Bins)
    end.

safe_match(Tab,Pat,What) ->
    do_safe_match(init_chunk_match(Tab,Pat,What,default,safe),[]).

do_safe_match({error,Error},_L) ->
    {error,Error};
do_safe_match({L,C},LL) ->
    do_safe_match(chunk_match(C,safe),L ++ LL);
do_safe_match('$end_of_table',L) ->
    L;
do_safe_match(badarg,_L) ->
    badarg.

init_chunk_match(Tab,Pat,What,N,Safe)
    when is_integer(N),
    N >= 0;
    N =:= default->
    case compile_match_spec(What,Pat) of
        {Spec,MP}->
            case  catch dets_server:get_pid(Tab) of
                {'EXIT',_Reason}->
                    badarg;
                Proc->
                    case req(Proc,{match,MP,Spec,N,Safe}) of
                        {done,L}->
                            {L,#dets_cont{tab = Tab,proc = Proc,what = What,bin = eof,no_objs = default,alloc = <<>>}};
                        {cont,State}->
                            chunk_match(State#dets_cont{what = What,tab = Tab,proc = Proc},Safe);
                        Error->
                            Error
                    end
            end;
        badarg->
            badarg
    end;
init_chunk_match(_Tab,_Pat,_What,_N,_Safe) ->
    badarg.

chunk_match(#dets_cont{proc = Proc} = State,Safe) ->
    case req(Proc,{match_init,State,Safe}) of
        '$end_of_table' = Reply->
            Reply;
        {cont,{Bins,NewState}}->
            MP = NewState#dets_cont.match_program,
            case  catch do_foldl_bins(Bins,MP) of
                {'EXIT',_}->
                    case ets:is_compiled_ms(MP) of
                        true->
                            Bad = dets_utils:bad_object(chunk_match,Bins),
                            req(Proc,{corrupt,Bad});
                        false->
                            badarg
                    end;
                []->
                    chunk_match(NewState,Safe);
                Terms->
                    {Terms,NewState}
            end;
        Error->
            Error
    end.

do_foldl_bins(Bins,true) ->
    foldl_bins(Bins,[]);
do_foldl_bins(Bins,{match_spec,MP}) ->
    foldl_bins(Bins,MP,[]).

foldl_bins([],Terms) ->
    Terms;
foldl_bins([Bin| Bins],Terms) ->
    foldl_bins(Bins,[binary_to_term(Bin)| Terms]).

foldl_bins([],_MP,Terms) ->
    Terms;
foldl_bins([Bin| Bins],MP,Terms) ->
    Term = binary_to_term(Bin),
    case ets:match_spec_run([Term],MP) of
        []->
            foldl_bins(Bins,MP,Terms);
        [Result]->
            foldl_bins(Bins,MP,[Result| Terms])
    end.

compile_match_spec(select,[{_,[],['$_']}] = Spec) ->
    {Spec,true};
compile_match_spec(select,Spec) ->
    try {Spec,{match_spec,ets:match_spec_compile(Spec)}}
        catch
            error:_->
                badarg end;
compile_match_spec(object,Pat) ->
    compile_match_spec(select,[{Pat,[],['$_']}]);
compile_match_spec(bindings,Pat) ->
    compile_match_spec(select,[{Pat,[],['$$']}]);
compile_match_spec(delete,Pat) ->
    compile_match_spec(select,[{Pat,[],[true]}]).

defaults(Tab,Args) ->
    Defaults0 = #open_args{file = to_list(Tab),type = set,keypos = 1,repair = true,min_no_slots = default,max_no_slots = default,ram_file = false,delayed_write = {3000,14000},auto_save = timer:minutes(3),access = read_write,debug = false},
    Fun = fun repl/2,
    Defaults = lists:foldl(Fun,Defaults0,Args),
    true = is_list(Defaults#open_args.file),
    is_comp_min_max(Defaults).

to_list(T)
    when is_atom(T)->
    atom_to_list(T);
to_list(T) ->
    T.

repl({access,A},Defs) ->
    mem(A,[read, read_write]),
    Defs#open_args{access = A};
repl({auto_save,Int},Defs)
    when is_integer(Int),
    Int >= 0->
    Defs#open_args{auto_save = Int};
repl({auto_save,infinity},Defs) ->
    Defs#open_args{auto_save = infinity};
repl({cache_size,Int},Defs)
    when is_integer(Int),
    Int >= 0->
    Defs;
repl({cache_size,infinity},Defs) ->
    Defs;
repl({delayed_write,default},Defs) ->
    Defs#open_args{delayed_write = {3000,14000}};
repl({delayed_write,{Delay,Size} = C},Defs)
    when is_integer(Delay),
    Delay >= 0,
    is_integer(Size),
    Size >= 0->
    Defs#open_args{delayed_write = C};
repl({estimated_no_objects,I},Defs) ->
    repl({min_no_slots,I},Defs);
repl({file,File},Defs) ->
    Defs#open_args{file = to_list(File)};
repl({keypos,P},Defs)
    when is_integer(P),
    P > 0->
    Defs#open_args{keypos = P};
repl({max_no_slots,I},Defs) ->
    MaxSlots = is_max_no_slots(I),
    Defs#open_args{max_no_slots = MaxSlots};
repl({min_no_slots,I},Defs) ->
    MinSlots = is_min_no_slots(I),
    Defs#open_args{min_no_slots = MinSlots};
repl({ram_file,Bool},Defs) ->
    mem(Bool,[true, false]),
    Defs#open_args{ram_file = Bool};
repl({repair,T},Defs) ->
    mem(T,[true, false, force]),
    Defs#open_args{repair = T};
repl({type,T},Defs) ->
    mem(T,[set, bag, duplicate_bag]),
    Defs#open_args{type = T};
repl({version,Version},Defs) ->
    is_version(Version),
    Defs;
repl({debug,Bool},Defs) ->
    mem(Bool,[true, false]),
    Defs#open_args{debug = Bool};
repl({_,_},_) ->
    exit(badarg).

is_min_no_slots(default) ->
    default;
is_min_no_slots(I)
    when is_integer(I),
    I >= 256->
    I;
is_min_no_slots(I)
    when is_integer(I),
    I >= 0->
    256.

is_max_no_slots(default) ->
    default;
is_max_no_slots(I)
    when is_integer(I),
    I > 0,
    I < 1 bsl 31->
    I.

is_comp_min_max(Defs) ->
    #open_args{max_no_slots = Max,min_no_slots = Min} = Defs,
    if Min =:= default ->
        Defs;Max =:= default ->
        Defs;true ->
        true = Min =< Max,
        Defs end.

is_version(default) ->
    true;
is_version(9) ->
    true.

mem(X,L) ->
    case lists:member(X,L) of
        true->
            true;
        false->
            exit(badarg)
    end.

options(Options,Keys)
    when is_list(Options)->
    options(Options,Keys,[]);
options(Option,Keys) ->
    options([Option],Keys,[]).

options(Options,[Key| Keys],L)
    when is_list(Options)->
    V = case lists:keysearch(Key,1,Options) of
        {value,{format,Format}}
            when Format =:= term;
            Format =:= bchunk->
            {ok,Format};
        {value,{min_no_slots,I}}->
            case  catch is_min_no_slots(I) of
                {'EXIT',_}->
                    badarg;
                MinNoSlots->
                    {ok,MinNoSlots}
            end;
        {value,{n_objects,default}}->
            {ok,default_option(Key)};
        {value,{n_objects,NObjs}}
            when is_integer(NObjs),
            NObjs >= 1->
            {ok,NObjs};
        {value,{traverse,select}}->
            {ok,select};
        {value,{traverse,{select,MS}}}->
            {ok,{select,MS}};
        {value,{traverse,first_next}}->
            {ok,first_next};
        {value,{Key,_}}->
            badarg;
        false->
            Default = default_option(Key),
            {ok,Default}
    end,
    case V of
        badarg->
            {badarg,Key};
        {ok,Value}->
            NewOptions = lists:keydelete(Key,1,Options),
            options(NewOptions,Keys,[Value| L])
    end;
options([],[],L) ->
    lists:reverse(L);
options(Options,_,_L) ->
    {badarg,Options}.

default_option(format) ->
    term;
default_option(min_no_slots) ->
    default;
default_option(traverse) ->
    select;
default_option(n_objects) ->
    default.

listify(L)
    when is_list(L)->
    L;
listify(T) ->
    [T].

treq(Tab,R) ->
    case  catch dets_server:get_pid(Tab) of
        Pid
            when is_pid(Pid)->
            req(Pid,R);
        _->
            badarg
    end.

req(Proc,R) ->
    Ref = monitor(process,Proc),
    Proc ! {'$dets_call',self(),R},
    receive {'DOWN',Ref,process,Proc,_Info}->
        badarg;
    {Proc,Reply}->
        demonitor(Ref,[flush]),
        Reply end.

einval({error,{file_error,_,einval}},A) ->
    error(badarg,A);
einval({error,{file_error,_,badarg}},A) ->
    error(badarg,A);
einval(Reply,_A) ->
    Reply.

badarg(badarg,A) ->
    error(badarg,A);
badarg(Reply,_A) ->
    Reply.

undefined(badarg) ->
    undefined;
undefined(Reply) ->
    Reply.

badarg_exit(badarg,A) ->
    error(badarg,A);
badarg_exit({ok,Reply},_A) ->
    Reply;
badarg_exit(Reply,_A) ->
    exit(Reply).

init(Parent,Server) ->
    process_flag(trap_exit,true),
    receive {'$dets_call',From,{internal_open,Ref,Args} = Op}->
        try do_internal_open(Parent,Server,From,Ref,Args) of 
            Head->
                open_file_loop(Head,0)
            catch
                exit:normal->
                    exit(normal);
                _:Bad:Stacktrace->
                    bug_found(no_name,Op,Bad,Stacktrace,From),
                    exit(Bad) end end.

open_file_loop(Head,N)
    when element(1,Head#head.update_mode) =:= error->
    open_file_loop2(Head,N);
open_file_loop(Head,N) ->
    receive {'$dets_call',From,{match_init,_State,_Safe} = Op}->
        do_apply_op(Op,From,Head,N);
    {'$dets_call',From,{bchunk,_State} = Op}->
        do_apply_op(Op,From,Head,N);
    {'$dets_call',From,{next,_Key} = Op}->
        do_apply_op(Op,From,Head,N);
    {'$dets_call',From,{match_delete_init,_MP,_Spec} = Op}->
        do_apply_op(Op,From,Head,N);
    {'EXIT',Pid,Reason}
        when Pid =:= Head#head.parent->
        _NewHead = do_stop(Head),
        exit(Reason);
    {'EXIT',Pid,Reason}
        when Pid =:= Head#head.server->
        _NewHead = do_stop(Head),
        exit(Reason);
    {'EXIT',Pid,_Reason}->
        H2 = remove_fix(Head,Pid,close),
        open_file_loop(H2,N);
    {system,From,Req}->
        sys:handle_system_msg(Req,From,Head#head.parent,dets,[],Head) after 0->
        open_file_loop2(Head,N) end.

open_file_loop2(Head,N) ->
    receive {'$dets_call',From,Op}->
        do_apply_op(Op,From,Head,N);
    {'EXIT',Pid,Reason}
        when Pid =:= Head#head.parent->
        _NewHead = do_stop(Head),
        exit(Reason);
    {'EXIT',Pid,Reason}
        when Pid =:= Head#head.server->
        _NewHead = do_stop(Head),
        exit(Reason);
    {'EXIT',Pid,_Reason}->
        H2 = remove_fix(Head,Pid,close),
        open_file_loop(H2,N);
    {system,From,Req}->
        sys:handle_system_msg(Req,From,Head#head.parent,dets,[],Head);
    Message->
        error_logger:format("** dets: unexpected message(ignored): " "~tw~n",[Message]),
        open_file_loop(Head,N) end.

do_apply_op(Op,From,Head,N) ->
    try apply_op(Op,From,Head,N) of 
        ok->
            open_file_loop(Head,N);
        {N2,H2}
            when is_record(H2,head),
            is_integer(N2)->
            open_file_loop(H2,N2);
        H2
            when is_record(H2,head)->
            open_file_loop(H2,N);
        {{more,From1,Op1,N1},NewHead}->
            do_apply_op(Op1,From1,NewHead,N1)
        catch
            exit:normal->
                exit(normal);
            _:Bad:Stacktrace->
                bug_found(Head#head.name,Op,Bad,Stacktrace,From),
                open_file_loop(Head,N) end.

apply_op(Op,From,Head,N) ->
    case Op of
        {add_user,Tab,OpenArgs}->
            #open_args{file = Fname,type = Type,keypos = Keypos,ram_file = Ram,access = Access} = OpenArgs,
            Res = if Tab =:= Head#head.name,
            Head#head.keypos =:= Keypos,
            Head#head.type =:= Type,
            Head#head.ram_file =:= Ram,
            Head#head.access =:= Access,
            Fname =:= Head#head.filename ->
                ok;true ->
                err({error,incompatible_arguments}) end,
            From ! {self(),Res},
            ok;
        auto_save->
            case Head#head.update_mode of
                saved->
                    Head;
                {error,_Reason}->
                    Head;
                _Dirty
                    when N =:= 0->
                    dets_utils:vformat("** dets: Auto save of ~tp\n",[Head#head.name]),
                    {NewHead,_Res} = perform_save(Head,true),
                    garbage_collect(),
                    {0,NewHead};
                dirty->
                    start_auto_save_timer(Head),
                    {0,Head}
            end;
        close->
            From ! {self(),fclose(Head)},
            _NewHead = unlink_fixing_procs(Head),
            void,
            exit(normal);
        {close,Pid}->
            NewHead = remove_fix(Head,Pid,close),
            From ! {self(),status(NewHead)},
            NewHead;
        {corrupt,Reason}->
            {H2,Error} = dets_utils:corrupt_reason(Head,Reason),
            From ! {self(),Error},
            H2;
        {delayed_write,WrTime}->
            delayed_write(Head,WrTime);
        info->
            {H2,Res} = finfo(Head),
            From ! {self(),Res},
            H2;
        {info,Tag}->
            {H2,Res} = finfo(Head,Tag),
            From ! {self(),Res},
            H2;
        {is_compatible_bchunk_format,Term}->
            Res = test_bchunk_format(Head,Term),
            From ! {self(),Res},
            ok;
        {internal_open,Ref,Args}->
            do_internal_open(Head#head.parent,Head#head.server,From,Ref,Args);
        may_grow
            when Head#head.update_mode =/= saved->
            if Head#head.update_mode =:= dirty ->
                {H2,_Res} = dets_v9:may_grow(Head,0,many_times),
                {N + 1,H2};true ->
                ok end;
        {set_verbose,What}->
            set_verbose(What),
            From ! {self(),ok},
            ok;
        {where,Object}->
            {H2,Res} = where_is_object(Head,Object),
            From ! {self(),Res},
            H2;
        _Message
            when element(1,Head#head.update_mode) =:= error->
            From ! {self(),status(Head)},
            ok;
        {bchunk_init,Tab}->
            {H2,Res} = do_bchunk_init(Head,Tab),
            From ! {self(),Res},
            H2;
        {bchunk,State}->
            {H2,Res} = do_bchunk(Head,State),
            From ! {self(),Res},
            H2;
        delete_all_objects->
            {H2,Res} = fdelete_all_objects(Head),
            From ! {self(),Res},
            garbage_collect(),
            {0,H2};
        {delete_key,_Keys}
            when Head#head.update_mode =:= dirty->
            stream_op(Op,From,[],Head,N);
        {delete_object,Objs}
            when Head#head.update_mode =:= dirty->
            case check_objects(Objs,Head#head.keypos) of
                true->
                    stream_op(Op,From,[],Head,N);
                false->
                    From ! {self(),badarg},
                    ok
            end;
        first->
            {H2,Res} = ffirst(Head),
            From ! {self(),Res},
            H2;
        {initialize,InitFun,Format,MinNoSlots}->
            {H2,Res} = finit(Head,InitFun,Format,MinNoSlots),
            From ! {self(),Res},
            garbage_collect(),
            H2;
        {insert,Objs}
            when Head#head.update_mode =:= dirty->
            case check_objects(Objs,Head#head.keypos) of
                true->
                    stream_op(Op,From,[],Head,N);
                false->
                    From ! {self(),badarg},
                    ok
            end;
        {insert_new,Objs}
            when Head#head.update_mode =:= dirty->
            {H2,Res} = finsert_new(Head,Objs),
            From ! {self(),Res},
            {N + 1,H2};
        {lookup_keys,_Keys}->
            stream_op(Op,From,[],Head,N);
        {match_init,State,Safe}->
            {H1,Res} = fmatch_init(Head,State),
            H2 = case Res of
                {cont,_}->
                    H1;
                _
                    when Safe =:= no_safe->
                    H1;
                _
                    when Safe =:= safe->
                    do_safe_fixtable(H1,From,false)
            end,
            From ! {self(),Res},
            H2;
        {match,MP,Spec,NObjs,Safe}->
            {H2,Res} = fmatch(Head,MP,Spec,NObjs,Safe,From),
            From ! {self(),Res},
            H2;
        {member,_Key} = Op->
            stream_op(Op,From,[],Head,N);
        {next,Key}->
            {H2,Res} = fnext(Head,Key),
            From ! {self(),Res},
            H2;
        {match_delete,State}
            when Head#head.update_mode =:= dirty->
            {H1,Res} = fmatch_delete(Head,State),
            H2 = case Res of
                {cont,_S,_N}->
                    H1;
                _->
                    do_safe_fixtable(H1,From,false)
            end,
            From ! {self(),Res},
            {N + 1,H2};
        {match_delete_init,MP,Spec}
            when Head#head.update_mode =:= dirty->
            {H2,Res} = fmatch_delete_init(Head,MP,Spec,From),
            From ! {self(),Res},
            {N + 1,H2};
        {safe_fixtable,Bool}->
            NewHead = do_safe_fixtable(Head,From,Bool),
            From ! {self(),ok},
            NewHead;
        {slot,Slot}->
            {H2,Res} = fslot(Head,Slot),
            From ! {self(),Res},
            H2;
        sync->
            {NewHead,Res} = perform_save(Head,true),
            From ! {self(),Res},
            garbage_collect(),
            {0,NewHead};
        {update_counter,Key,Incr}
            when Head#head.update_mode =:= dirty->
            {NewHead,Res} = do_update_counter(Head,Key,Incr),
            From ! {self(),Res},
            {N + 1,NewHead};
        WriteOp
            when Head#head.update_mode =:= new_dirty->
            H2 = Head#head{update_mode = dirty},
            apply_op(WriteOp,From,H2,0);
        WriteOp
            when Head#head.access =:= read_write,
            Head#head.update_mode =:= saved->
            case  catch dets_v9:mark_dirty(Head) of
                ok->
                    start_auto_save_timer(Head),
                    H2 = Head#head{update_mode = dirty},
                    apply_op(WriteOp,From,H2,0);
                {NewHead,Error}
                    when is_record(NewHead,head)->
                    From ! {self(),Error},
                    NewHead
            end;
        WriteOp
            when is_tuple(WriteOp),
            Head#head.access =:= read->
            Reason = {access_mode,Head#head.filename},
            From ! {self(),err({error,Reason})},
            ok
    end.

bug_found(Name,Op,Bad,Stacktrace,From) ->
    case dets_utils:debug_mode() of
        true->
            error_logger:format("** dets: Bug was found when accessing " "table ~tw,~n** dets: operation was ~tp" " and reply was ~tw.~n** dets: Stacktra" "ce: ~tw~n",[Name, Op, Bad, Stacktrace]);
        false->
            error_logger:format("** dets: Bug was found when accessing " "table ~tw~n",[Name])
    end,
    if From =/= self() ->
        From ! {self(),{error,{dets_bug,Name,Op,Bad}}},
        ok;true ->
        ok end.

do_internal_open(Parent,Server,From,Ref,Args) ->
    void,
    case do_open_file(Args,Parent,Server,Ref) of
        {ok,Head}->
            From ! {self(),ok},
            Head;
        Error->
            From ! {self(),Error},
            exit(normal)
    end.

start_auto_save_timer(Head)
    when Head#head.auto_save =:= infinity->
    ok;
start_auto_save_timer(Head) ->
    Millis = Head#head.auto_save,
    _Ref = erlang:send_after(Millis,self(),{'$dets_call',self(),auto_save}),
    ok.

stream_op(Op,Pid,Pids,Head,N) ->
    #head{fixed = Fxd,update_mode = M} = Head,
    stream_op(Head,Pids,[],N,Pid,Op,Fxd,M).

stream_loop(Head,Pids,C,N,false = Fxd,M) ->
    receive {'$dets_call',From,Message}->
        stream_op(Head,Pids,C,N,From,Message,Fxd,M) after 0->
        stream_end(Head,Pids,C,N,no_more) end;
stream_loop(Head,Pids,C,N,_Fxd,_M) ->
    stream_end(Head,Pids,C,N,no_more).

stream_op(Head,Pids,C,N,Pid,{lookup_keys,Keys},Fxd,M) ->
    NC = [{{lookup,Pid},Keys}| C],
    stream_loop(Head,Pids,NC,N,Fxd,M);
stream_op(Head,Pids,C,N,Pid,{insert,_Objects} = Op,Fxd,dirty = M) ->
    NC = [Op| C],
    stream_loop(Head,[Pid| Pids],NC,N,Fxd,M);
stream_op(Head,Pids,C,N,Pid,{delete_key,_Keys} = Op,Fxd,dirty = M) ->
    NC = [Op| C],
    stream_loop(Head,[Pid| Pids],NC,N,Fxd,M);
stream_op(Head,Pids,C,N,Pid,{delete_object,_Os} = Op,Fxd,dirty = M) ->
    NC = [Op| C],
    stream_loop(Head,[Pid| Pids],NC,N,Fxd,M);
stream_op(Head,Pids,C,N,Pid,{member,Key},Fxd,M) ->
    NC = [{{lookup,[Pid]},[Key]}| C],
    stream_loop(Head,Pids,NC,N,Fxd,M);
stream_op(Head,Pids,C,N,Pid,Op,_Fxd,_M) ->
    stream_end(Head,Pids,C,N,{Pid,Op}).

stream_end(Head,Pids0,C,N,Next) ->
    case  catch update_cache(Head,lists:reverse(C)) of
        {Head1,[],PwriteList}->
            stream_end1(Pids0,Next,N,C,Head1,PwriteList);
        {Head1,Found,PwriteList}->
            _ = lookup_replies(Found),
            stream_end1(Pids0,Next,N,C,Head1,PwriteList);
        Head1
            when is_record(Head1,head)->
            stream_end2(Pids0,Pids0,Next,N,C,Head1,ok);
        {Head1,Error}
            when is_record(Head1,head)->
            Fun = fun ({{lookup,[Pid]},_Keys},L)->
                [Pid| L];({{lookup,Pid},_Keys},L)->
                [Pid| L];(_,L)->
                L end,
            LPs0 = lists:foldl(Fun,[],C),
            LPs = lists:usort(lists:flatten(LPs0)),
            stream_end2(Pids0 ++ LPs,Pids0,Next,N,C,Head1,Error);
        DetsError->
            throw(DetsError)
    end.

stream_end1(Pids,Next,N,C,Head,[]) ->
    stream_end2(Pids,Pids,Next,N,C,Head,ok);
stream_end1(Pids,Next,N,C,Head,PwriteList) ->
    {Head1,PR} = ( catch dets_utils:pwrite(Head,PwriteList)),
    stream_end2(Pids,Pids,Next,N,C,Head1,PR).

stream_end2([Pid| Pids],Ps,Next,N,C,Head,Reply) ->
    Pid ! {self(),Reply},
    stream_end2(Pids,Ps,Next,N + 1,C,Head,Reply);
stream_end2([],Ps,no_more,N,C,Head,_Reply) ->
    penalty(Head,Ps,C),
    {N,Head};
stream_end2([],_Ps,{From,Op},N,_C,Head,_Reply) ->
    {{more,From,Op,N},Head}.

penalty(H,_Ps,_C)
    when H#head.fixed =:= false->
    ok;
penalty(_H,_Ps,[{{lookup,_Pids},_Keys}]) ->
    ok;
penalty(#head{fixed = {_,[{Pid,_}]}},[Pid],_C) ->
    ok;
penalty(_H,_Ps,_C) ->
    timer:sleep(1).

lookup_replies([{P,O}]) ->
    lookup_reply(P,O);
lookup_replies(Q) ->
    [{P,O}| L] = dets_utils:family(Q),
    lookup_replies(P,lists:append(O),L).

lookup_replies(P,O,[]) ->
    lookup_reply(P,O);
lookup_replies(P,O,[{P2,O2}| L]) ->
    _ = lookup_reply(P,O),
    lookup_replies(P2,lists:append(O2),L).

lookup_reply([P],O) ->
    P ! {self(),O =/= []};
lookup_reply(P,O) ->
    P ! {self(),O}.

system_continue(_Parent,_,Head) ->
    open_file_loop(Head,0).

system_terminate(Reason,_Parent,_,Head) ->
    _NewHead = do_stop(Head),
    exit(Reason).

system_code_change(State,_Module,_OldVsn,_Extra) ->
    {ok,State}.

read_file_header(FileName,Access,RamFile) ->
    BF = if RamFile ->
        case file:read_file(FileName) of
            {ok,B}->
                B;
            Err->
                dets_utils:file_error(FileName,Err)
        end;true ->
        FileName end,
    {ok,Fd} = dets_utils:open(BF,open_args(Access,RamFile)),
    {ok,<<Version:32>>} = dets_utils:pread_close(Fd,FileName,16,4),
    if Version =< 8 ->
        _ = file:close(Fd),
        throw({error,{format_8_no_longer_supported,FileName}});Version =:= 9 ->
        dets_v9:read_file_header(Fd,FileName);true ->
        _ = file:close(Fd),
        throw({error,{not_a_dets_file,FileName}}) end.

fclose(Head) ->
    {Head1,Res} = perform_save(Head,false),
    case Head1#head.ram_file of
        true->
            Res;
        false->
            dets_utils:stop_disk_map(),
            Res2 = file:close(Head1#head.fptr),
            if Res2 =:= ok ->
                Res;true ->
                Res2 end
    end.

perform_save(Head,DoSync)
    when Head#head.update_mode =:= dirty;
    Head#head.update_mode =:= new_dirty->
    case  catch begin {Head1,[]} = write_cache(Head),
    {Head2,ok} = dets_v9:do_perform_save(Head1),
    ok = ensure_written(Head2,DoSync),
    {Head2#head{update_mode = saved},ok} end of
        {NewHead,_} = Reply
            when is_record(NewHead,head)->
            Reply
    end;
perform_save(Head,_DoSync) ->
    {Head,status(Head)}.

ensure_written(Head,DoSync)
    when Head#head.ram_file->
    {ok,EOF} = dets_utils:position(Head,eof),
    {ok,Bin} = dets_utils:pread(Head,0,EOF,0),
    if DoSync ->
        dets_utils:write_file(Head,Bin); not DoSync ->
        case file:write_file(Head#head.filename,Bin) of
            ok->
                ok;
            Error->
                dets_utils:corrupt_file(Head,Error)
        end end;
ensure_written(Head,true)
    when  not Head#head.ram_file->
    dets_utils:sync(Head);
ensure_written(Head,false)
    when  not Head#head.ram_file->
    ok.

do_bchunk_init(Head,Tab) ->
    case  catch write_cache(Head) of
        {H2,[]}->
            case dets_v9:table_parameters(H2) of
                undefined->
                    {H2,{error,old_version}};
                Parms->
                    L = dets_utils:all_allocated(H2),
                    Bin = if L =:= <<>> ->
                        eof;true ->
                        <<>> end,
                    BinParms = term_to_binary(Parms),
                    {H2,{#dets_cont{no_objs = default,bin = Bin,alloc = L,tab = Tab,proc = self(),what = bchunk},[BinParms]}}
            end;
        {NewHead,_} = HeadError
            when is_record(NewHead,head)->
            HeadError
    end.

do_bchunk(Head,#dets_cont{proc = Proc})
    when Proc =/= self()->
    {Head,badarg};
do_bchunk(Head,#dets_cont{bin = eof}) ->
    {Head,'$end_of_table'};
do_bchunk(Head,State) ->
    case dets_v9:read_bchunks(Head,State#dets_cont.alloc) of
        {error,Reason}->
            dets_utils:corrupt_reason(Head,Reason);
        {finished,Bins}->
            {Head,{State#dets_cont{bin = eof},Bins}};
        {Bins,NewL}->
            {Head,{State#dets_cont{alloc = NewL},Bins}}
    end.

fdelete_all_objects(Head)
    when Head#head.fixed =:= false->
    case  catch do_delete_all_objects(Head) of
        {ok,NewHead}->
            start_auto_save_timer(NewHead),
            {NewHead,ok};
        {error,Reason}->
            dets_utils:corrupt_reason(Head,Reason)
    end;
fdelete_all_objects(Head) ->
    {Head,fixed}.

do_delete_all_objects(Head) ->
    #head{fptr = Fd,name = Tab,filename = Fname,type = Type,keypos = Kp,ram_file = Ram,auto_save = Auto,min_no_slots = MinSlots,max_no_slots = MaxSlots,cache = Cache} = Head,
    CacheSz = dets_utils:cache_size(Cache),
    ok = dets_utils:truncate(Fd,Fname,bof),
    dets_v9:initiate_file(Fd,Tab,Fname,Type,Kp,MinSlots,MaxSlots,Ram,CacheSz,Auto,true).

ffirst(H) ->
    Ref = make_ref(),
    case  catch {Ref,ffirst1(H)} of
        {Ref,{NH,R}}->
            {NH,{ok,R}};
        {NH,R}
            when is_record(NH,head)->
            {NH,{error,R}}
    end.

ffirst1(H) ->
    check_safe_fixtable(H),
    {NH,[]} = write_cache(H),
    ffirst(NH,0).

ffirst(H,Slot) ->
    case dets_v9:slot_objs(H,Slot) of
        '$end_of_table'->
            {H,'$end_of_table'};
        []->
            ffirst(H,Slot + 1);
        [X| _]->
            {H,element(H#head.keypos,X)}
    end.

finsert(Head,Objects) ->
    case  catch update_cache(Head,Objects,insert) of
        {NewHead,[]}->
            {NewHead,ok};
        {NewHead,_} = HeadError
            when is_record(NewHead,head)->
            HeadError
    end.

finsert_new(Head,Objects) ->
    KeyPos = Head#head.keypos,
    case  catch lists:map(fun (Obj)->
        element(KeyPos,Obj) end,Objects) of
        Keys
            when is_list(Keys)->
            case  catch update_cache(Head,Keys,{lookup,nopid}) of
                {Head1,PidObjs}
                    when is_list(PidObjs)->
                    case lists:all(fun ({_P,OL})->
                        OL =:= [] end,PidObjs) of
                        true->
                            case  catch update_cache(Head1,Objects,insert) of
                                {NewHead,[]}->
                                    {NewHead,true};
                                {NewHead,Error}
                                    when is_record(NewHead,head)->
                                    {NewHead,Error}
                            end;
                        false = Reply->
                            {Head1,Reply}
                    end;
                {NewHead,_} = HeadError
                    when is_record(NewHead,head)->
                    HeadError
            end;
        _->
            {Head,badarg}
    end.

do_safe_fixtable(Head,Pid,true) ->
    case Head#head.fixed of
        false->
            link(Pid),
            MonTime = erlang:monotonic_time(),
            TimeOffset = erlang:time_offset(),
            Fixed = {{MonTime,TimeOffset},[{Pid,1}]},
            Ftab = dets_utils:get_freelists(Head),
            Head#head{fixed = Fixed,freelists = {Ftab,Ftab}};
        {TimeStamp,Counters}->
            case lists:keysearch(Pid,1,Counters) of
                {value,{Pid,Counter}}->
                    NewCounters = lists:keyreplace(Pid,1,Counters,{Pid,Counter + 1}),
                    Head#head{fixed = {TimeStamp,NewCounters}};
                false->
                    link(Pid),
                    Fixed = {TimeStamp,[{Pid,1}| Counters]},
                    Head#head{fixed = Fixed}
            end
    end;
do_safe_fixtable(Head,Pid,false) ->
    remove_fix(Head,Pid,false).

remove_fix(Head,Pid,How) ->
    case Head#head.fixed of
        false->
            Head;
        {TimeStamp,Counters}->
            case lists:keysearch(Pid,1,Counters) of
                {value,{Pid,Counter}}
                    when Counter =:= 1;
                    How =:= close->
                    unlink(Pid),
                    case lists:keydelete(Pid,1,Counters) of
                        []->
                            check_growth(Head),
                            garbage_collect(),
                            Head#head{fixed = false,freelists = dets_utils:get_freelists(Head)};
                        NewCounters->
                            Head#head{fixed = {TimeStamp,NewCounters}}
                    end;
                {value,{Pid,Counter}}->
                    NewCounters = lists:keyreplace(Pid,1,Counters,{Pid,Counter - 1}),
                    Head#head{fixed = {TimeStamp,NewCounters}};
                false->
                    Head
            end
    end.

do_stop(Head) ->
    _NewHead = unlink_fixing_procs(Head),
    fclose(Head).

unlink_fixing_procs(Head) ->
    case Head#head.fixed of
        false->
            Head;
        {_,Counters}->
            lists:foreach(fun ({Pid,_Counter})->
                unlink(Pid) end,Counters),
            Head#head{fixed = false,freelists = dets_utils:get_freelists(Head)}
    end.

check_growth(#head{access = read}) ->
    ok;
check_growth(Head) ->
    NoThings = no_things(Head),
    if NoThings > Head#head.next ->
        _Ref = erlang:send_after(200,self(),{'$dets_call',self(),may_grow}),
        ok;true ->
        ok end.

finfo(H) ->
    case  catch write_cache(H) of
        {H2,[]}->
            Info = ( catch [{type,H2#head.type}, {keypos,H2#head.keypos}, {size,H2#head.no_objects}, {file_size,file_size(H2#head.fptr,H2#head.filename)}, {filename,H2#head.filename}]),
            {H2,Info};
        {H2,_} = HeadError
            when is_record(H2,head)->
            HeadError
    end.

finfo(H,access) ->
    {H,H#head.access};
finfo(H,auto_save) ->
    {H,H#head.auto_save};
finfo(H,bchunk_format) ->
    case  catch write_cache(H) of
        {H2,[]}->
            case dets_v9:table_parameters(H2) of
                undefined = Undef->
                    {H2,Undef};
                Parms->
                    {H2,term_to_binary(Parms)}
            end;
        {H2,_} = HeadError
            when is_record(H2,head)->
            HeadError
    end;
finfo(H,delayed_write) ->
    {H,dets_utils:cache_size(H#head.cache)};
finfo(H,filename) ->
    {H,H#head.filename};
finfo(H,file_size) ->
    case  catch write_cache(H) of
        {H2,[]}->
            {H2, catch file_size(H#head.fptr,H#head.filename)};
        {H2,_} = HeadError
            when is_record(H2,head)->
            HeadError
    end;
finfo(H,fixed) ->
    {H, not (H#head.fixed =:= false)};
finfo(H,hash) ->
    {H,H#head.hash_bif};
finfo(H,keypos) ->
    {H,H#head.keypos};
finfo(H,memory) ->
    finfo(H,file_size);
finfo(H,no_objects) ->
    finfo(H,size);
finfo(H,no_keys) ->
    case  catch write_cache(H) of
        {H2,[]}->
            {H2,H2#head.no_keys};
        {H2,_} = HeadError
            when is_record(H2,head)->
            HeadError
    end;
finfo(H,no_slots) ->
    {H,dets_v9:no_slots(H)};
finfo(H,pid) ->
    {H,self()};
finfo(H,ram_file) ->
    {H,H#head.ram_file};
finfo(H,safe_fixed) ->
    {H,case H#head.fixed of
        false->
            false;
        {{FixMonTime,TimeOffset},RefList}->
            {make_timestamp(FixMonTime,TimeOffset),RefList}
    end};
finfo(H,safe_fixed_monotonic_time) ->
    {H,case H#head.fixed of
        false->
            false;
        {{FixMonTime,_TimeOffset},RefList}->
            {FixMonTime,RefList}
    end};
finfo(H,size) ->
    case  catch write_cache(H) of
        {H2,[]}->
            {H2,H2#head.no_objects};
        {H2,_} = HeadError
            when is_record(H2,head)->
            HeadError
    end;
finfo(H,type) ->
    {H,H#head.type};
finfo(H,version) ->
    {H,9};
finfo(H,_) ->
    {H,undefined}.

file_size(Fd,FileName) ->
    {ok,Pos} = dets_utils:position(Fd,FileName,eof),
    Pos.

test_bchunk_format(_Head,undefined) ->
    false;
test_bchunk_format(Head,Term) ->
    dets_v9:try_bchunk_header(Term,Head) =/= not_ok.

do_open_file([Fname, Verbose],Parent,Server,Ref) ->
    case  catch fopen2(Fname,Ref) of
        {error,{tooshort,_}}->
            err({error,{not_a_dets_file,Fname}});
        {error,_Reason} = Error->
            err(Error);
        {ok,Head}->
            maybe_put(verbose,Verbose),
            {ok,Head#head{parent = Parent,server = Server}};
        {'EXIT',_Reason} = Error->
            Error;
        Bad->
            error_logger:format("** dets: Bug was found in open_file/1," " reply was ~tw.~n",[Bad]),
            {error,{dets_bug,Fname,Bad}}
    end;
do_open_file([Tab, OpenArgs, Verb],Parent,Server,_Ref) ->
    case  catch fopen3(Tab,OpenArgs) of
        {error,{tooshort,_}}->
            err({error,{not_a_dets_file,OpenArgs#open_args.file}});
        {error,_Reason} = Error->
            err(Error);
        {ok,Head}->
            maybe_put(verbose,Verb),
            {ok,Head#head{parent = Parent,server = Server}};
        {'EXIT',_Reason} = Error->
            Error;
        Bad->
            error_logger:format("** dets: Bug was found in open_file/2," " arguments were~n** dets: ~tw and repl" "y was ~tw.~n",[OpenArgs, Bad]),
            {error,{dets_bug,Tab,{open_file,OpenArgs},Bad}}
    end.

maybe_put(_,undefined) ->
    ignore;
maybe_put(K,V) ->
    put(K,V).

finit(Head,InitFun,_Format,_NoSlots)
    when Head#head.access =:= read->
    _ = ( catch InitFun(close)),
    {Head,{error,{access_mode,Head#head.filename}}};
finit(Head,InitFun,_Format,_NoSlots)
    when Head#head.fixed =/= false->
    _ = ( catch InitFun(close)),
    {Head,{error,{fixed_table,Head#head.name}}};
finit(Head,InitFun,Format,NoSlots) ->
    case  catch do_finit(Head,InitFun,Format,NoSlots) of
        {ok,NewHead}->
            check_growth(NewHead),
            start_auto_save_timer(NewHead),
            {NewHead,ok};
        badarg->
            {Head,badarg};
        Error->
            dets_utils:corrupt(Head,Error)
    end.

do_finit(Head,Init,Format,NoSlots) ->
    #head{fptr = Fd,type = Type,keypos = Kp,auto_save = Auto,cache = Cache,filename = Fname,ram_file = Ram,min_no_slots = MinSlots0,max_no_slots = MaxSlots,name = Tab,update_mode = UpdateMode} = Head,
    CacheSz = dets_utils:cache_size(Cache),
    {How,Head1} = case Format of
        term
            when is_integer(NoSlots),
            NoSlots > MaxSlots->
            throw(badarg);
        term->
            MinSlots = choose_no_slots(NoSlots,MinSlots0),
            if UpdateMode =:= new_dirty,
            MinSlots =:= MinSlots0 ->
                {general_init,Head};true ->
                ok = dets_utils:truncate(Fd,Fname,bof),
                {ok,H} = dets_v9:initiate_file(Fd,Tab,Fname,Type,Kp,MinSlots,MaxSlots,Ram,CacheSz,Auto,false),
                {general_init,H} end;
        bchunk->
            ok = dets_utils:truncate(Fd,Fname,bof),
            {bchunk_init,Head}
    end,
    case How of
        bchunk_init->
            case dets_v9:bchunk_init(Head1,Init) of
                {ok,NewHead}->
                    {ok,NewHead#head{update_mode = dirty}};
                Error->
                    Error
            end;
        general_init->
            Cntrs = ets:new(dets_init,[]),
            Input = dets_v9:bulk_input(Head1,Init,Cntrs),
            SlotNumbers = {Head1#head.min_no_slots,bulk_init,MaxSlots},
            {Reply,SizeData} = do_sort(Head1,SlotNumbers,Input,Cntrs,Fname),
            Bulk = true,
            case Reply of
                {ok,NoDups,H1}->
                    fsck_copy(SizeData,H1,Bulk,NoDups);
                Else->
                    close_files(Bulk,SizeData,Head1),
                    Else
            end
    end.

flookup_keys(Head,Keys) ->
    case  catch update_cache(Head,Keys,{lookup,nopid}) of
        {NewHead,[{_NoPid,Objs}]}->
            {NewHead,Objs};
        {NewHead,L}
            when is_list(L)->
            {NewHead,lists:flatmap(fun ({_Pid,OL})->
                OL end,L)};
        {NewHead,_} = HeadError
            when is_record(NewHead,head)->
            HeadError
    end.

fmatch_init(Head,#dets_cont{bin = eof}) ->
    {Head,'$end_of_table'};
fmatch_init(Head,C) ->
    case scan(Head,C) of
        {scan_error,Reason}->
            dets_utils:corrupt_reason(Head,Reason);
        {Ts,NC}->
            {Head,{cont,{Ts,NC}}}
    end.

fmatch(Head,MP,Spec,N,Safe,From) ->
    KeyPos = Head#head.keypos,
    case find_all_keys(Spec,KeyPos,[]) of
        []->
            case  catch write_cache(Head) of
                {Head1,[]}->
                    NewHead = case Safe of
                        safe->
                            do_safe_fixtable(Head1,From,true);
                        no_safe->
                            Head1
                    end,
                    C0 = init_scan(NewHead,N),
                    {NewHead,{cont,C0#dets_cont{match_program = MP}}};
                {NewHead,_} = HeadError
                    when is_record(NewHead,head)->
                    HeadError
            end;
        List->
            Keys = lists:usort(List),
            {NewHead,Reply} = flookup_keys(Head,Keys),
            case Reply of
                Objs
                    when is_list(Objs)->
                    {match_spec,MS} = MP,
                    MatchingObjs = ets:match_spec_run(Objs,MS),
                    {NewHead,{done,MatchingObjs}};
                Error->
                    {NewHead,Error}
            end
    end.

find_all_keys([],_,Ks) ->
    Ks;
find_all_keys([{H,_,_}| T],KeyPos,Ks)
    when is_tuple(H)->
    case tuple_size(H) of
        Enough
            when Enough >= KeyPos->
            Key = element(KeyPos,H),
            case contains_variable(Key) of
                true->
                    [];
                false->
                    find_all_keys(T,KeyPos,[Key| Ks])
            end;
        _->
            find_all_keys(T,KeyPos,Ks)
    end;
find_all_keys(_,_,_) ->
    [].

contains_variable(_) ->
    true;
contains_variable(A)
    when is_atom(A)->
    case atom_to_list(A) of
        [$$| T]->
            case  catch list_to_integer(T) of
                {'EXIT',_}->
                    false;
                _->
                    true
            end;
        _->
            false
    end;
contains_variable(T)
    when is_tuple(T)->
    contains_variable(tuple_to_list(T));
contains_variable([]) ->
    false;
contains_variable([H| T]) ->
    case contains_variable(H) of
        true->
            true;
        false->
            contains_variable(T)
    end;
contains_variable(_) ->
    false.

fmatch_delete_init(Head,MP,Spec,From) ->
    KeyPos = Head#head.keypos,
    case  catch case find_all_keys(Spec,KeyPos,[]) of
        []->
            do_fmatch_delete_var_keys(Head,MP,Spec,From);
        List->
            Keys = lists:usort(List),
            do_fmatch_constant_keys(Head,Keys,MP)
    end of
        {NewHead,_} = Reply
            when is_record(NewHead,head)->
            Reply
    end.

fmatch_delete(Head,C) ->
    case scan(Head,C) of
        {scan_error,Reason}->
            dets_utils:corrupt_reason(Head,Reason);
        {[],_}->
            {Head,{done,0}};
        {RTs,NC}->
            {match_spec,MP} = C#dets_cont.match_program,
            case  catch filter_binary_terms(RTs,MP,[]) of
                {'EXIT',_}->
                    Bad = dets_utils:bad_object(fmatch_delete,RTs),
                    dets_utils:corrupt_reason(Head,Bad);
                Terms->
                    do_fmatch_delete(Head,Terms,NC)
            end
    end.

do_fmatch_delete_var_keys(Head,_MP,[{_,[],[true]}],_From)
    when Head#head.fixed =:= false->
    {Head1,[]} = write_cache(Head),
    N = Head1#head.no_objects,
    case fdelete_all_objects(Head1) of
        {NewHead,ok}->
            {NewHead,{done,N}};
        Reply->
            Reply
    end;
do_fmatch_delete_var_keys(Head,MP,_Spec,From) ->
    Head1 = do_safe_fixtable(Head,From,true),
    {NewHead,[]} = write_cache(Head1),
    C0 = init_scan(NewHead,default),
    {NewHead,{cont,C0#dets_cont{match_program = MP},0}}.

do_fmatch_constant_keys(Head,Keys,{match_spec,MP}) ->
    case flookup_keys(Head,Keys) of
        {NewHead,ReadTerms}
            when is_list(ReadTerms)->
            Terms = filter_terms(ReadTerms,MP,[]),
            do_fmatch_delete(NewHead,Terms,fixed);
        Reply->
            Reply
    end.

filter_binary_terms([Bin| Bins],MP,L) ->
    Term = binary_to_term(Bin),
    case ets:match_spec_run([Term],MP) of
        [true]->
            filter_binary_terms(Bins,MP,[Term| L]);
        _->
            filter_binary_terms(Bins,MP,L)
    end;
filter_binary_terms([],_MP,L) ->
    L.

filter_terms([Term| Terms],MP,L) ->
    case ets:match_spec_run([Term],MP) of
        [true]->
            filter_terms(Terms,MP,[Term| L]);
        _->
            filter_terms(Terms,MP,L)
    end;
filter_terms([],_MP,L) ->
    L.

do_fmatch_delete(Head,Terms,What) ->
    N = length(Terms),
    case do_delete(Head,Terms,delete_object) of
        {NewHead,ok}
            when What =:= fixed->
            {NewHead,{done,N}};
        {NewHead,ok}->
            {NewHead,{cont,What,N}};
        Reply->
            Reply
    end.

do_delete(Head,Things,What) ->
    case  catch update_cache(Head,Things,What) of
        {NewHead,[]}->
            {NewHead,ok};
        {NewHead,_} = HeadError
            when is_record(NewHead,head)->
            HeadError
    end.

fnext(Head,Key) ->
    Slot = dets_v9:db_hash(Key,Head),
    Ref = make_ref(),
    case  catch {Ref,fnext(Head,Key,Slot)} of
        {Ref,{H,R}}->
            {H,{ok,R}};
        {NewHead,_} = HeadError
            when is_record(NewHead,head)->
            HeadError
    end.

fnext(H,Key,Slot) ->
    {NH,[]} = write_cache(H),
    case dets_v9:slot_objs(NH,Slot) of
        '$end_of_table'->
            {NH,'$end_of_table'};
        L->
            fnext_search(NH,Key,Slot,L)
    end.

fnext_search(H,K,Slot,L) ->
    Kp = H#head.keypos,
    case beyond_key(K,Kp,L) of
        []->
            fnext_slot(H,K,Slot + 1);
        L2->
            {H,element(H#head.keypos,hd(L2))}
    end.

fnext_slot(H,K,Slot) ->
    case dets_v9:slot_objs(H,Slot) of
        '$end_of_table'->
            {H,'$end_of_table'};
        []->
            fnext_slot(H,K,Slot + 1);
        L->
            {H,element(H#head.keypos,hd(L))}
    end.

beyond_key(_K,_Kp,[]) ->
    [];
beyond_key(K,Kp,[H| T]) ->
    case dets_utils:cmp(element(Kp,H),K) of
        0->
            beyond_key2(K,Kp,T);
        _->
            beyond_key(K,Kp,T)
    end.

beyond_key2(_K,_Kp,[]) ->
    [];
beyond_key2(K,Kp,[H| T] = L) ->
    case dets_utils:cmp(element(Kp,H),K) of
        0->
            beyond_key2(K,Kp,T);
        _->
            L
    end.

fopen2(Fname,Tab) ->
    case file:read_file_info(Fname) of
        {ok,_}->
            Acc = read_write,
            Ram = false,
            {ok,Fd,FH} = read_file_header(Fname,Acc,Ram),
            Do = case dets_v9:check_file_header(FH,Fd) of
                {ok,Head1}->
                    Head2 = Head1#head{filename = Fname},
                    try {ok,dets_v9:init_freelist(Head2)}
                        catch
                            throw:_->
                                {repair," has bad free lists, repairing ..."} end;
                {error,not_closed}->
                    M = " not properly closed, repairing ...",
                    {repair,M};
                Else->
                    Else
            end,
            case Do of
                {repair,Mess}->
                    io:format(user,"dets: file ~tp~s~n",[Fname, Mess]),
                    case fsck(Fd,Tab,Fname,FH,default,default) of
                        ok->
                            fopen2(Fname,Tab);
                        Error->
                            throw(Error)
                    end;
                {ok,Head}->
                    open_final(Head,Fname,Acc,Ram,{3000,14000},Tab,false);
                {error,Reason}->
                    throw({error,{Reason,Fname}})
            end;
        Error->
            dets_utils:file_error(Fname,Error)
    end.

fopen3(Tab,OpenArgs) ->
    FileName = OpenArgs#open_args.file,
    case file:read_file_info(FileName) of
        {ok,_}->
            fopen_existing_file(Tab,OpenArgs);
        Error
            when OpenArgs#open_args.access =:= read->
            dets_utils:file_error(FileName,Error);
        _Error->
            fopen_init_file(Tab,OpenArgs)
    end.

fopen_existing_file(Tab,OpenArgs) ->
    #open_args{file = Fname,type = Type,keypos = Kp,repair = Rep,min_no_slots = MinSlots,max_no_slots = MaxSlots,ram_file = Ram,delayed_write = CacheSz,auto_save = Auto,access = Acc,debug = Debug} = OpenArgs,
    {ok,Fd,FH} = read_file_header(Fname,Acc,Ram),
    MinF = (MinSlots =:= default) or (MinSlots =:= FH#fileheader.min_no_slots),
    MaxF = (MaxSlots =:= default) or (MaxSlots =:= FH#fileheader.max_no_slots),
    Wh = case dets_v9:check_file_header(FH,Fd) of
        {ok,Head}
            when Rep =:= force,
            Acc =:= read_write,
            FH#fileheader.no_colls =/= undefined,
            MinF,
            MaxF->
            {compact,Head};
        {ok,_Head}
            when Rep =:= force,
            Acc =:= read->
            throw({error,{access_mode,Fname}});
        {ok,_Head}
            when Rep =:= force->
            M = ", repair forced.",
            {repair,M};
        {ok,Head}->
            {final,Head};
        {error,not_closed}
            when Rep =:= force,
            Acc =:= read_write->
            M = ", repair forced.",
            {repair,M};
        {error,not_closed}
            when Rep =:= true,
            Acc =:= read_write->
            M = " not properly closed, repairing ...",
            {repair,M};
        {error,not_closed}
            when Rep =:= false->
            throw({error,{needs_repair,Fname}});
        {error,Reason}->
            throw({error,{Reason,Fname}})
    end,
    Do = case Wh of
        {Tag,Hd}
            when Tag =:= final;
            Tag =:= compact->
            Hd1 = Hd#head{filename = Fname},
            try {Tag,dets_v9:init_freelist(Hd1)}
                catch
                    throw:_->
                        {repair," has bad free lists, repairing ..."} end;
        Else->
            Else
    end,
    case Do of
        _
            when FH#fileheader.type =/= Type->
            throw({error,{type_mismatch,Fname}});
        _
            when FH#fileheader.keypos =/= Kp->
            throw({error,{keypos_mismatch,Fname}});
        {compact,SourceHead}->
            io:format(user,"dets: file ~tp is now compacted ...~n",[Fname]),
            {ok,NewSourceHead} = open_final(SourceHead,Fname,read,false,{3000,14000},Tab,Debug),
            case  catch compact(NewSourceHead) of
                ok->
                    garbage_collect(),
                    fopen3(Tab,OpenArgs#open_args{repair = false});
                _Err->
                    _ = file:close(Fd),
                    dets_utils:stop_disk_map(),
                    io:format(user,"dets: compaction of file ~tp failed, now" " repairing ...~n",[Fname]),
                    {ok,Fd2,_FH} = read_file_header(Fname,Acc,Ram),
                    do_repair(Fd2,Tab,Fname,FH,MinSlots,MaxSlots,OpenArgs)
            end;
        {repair,Mess}->
            io:format(user,"dets: file ~tp~s~n",[Fname, Mess]),
            do_repair(Fd,Tab,Fname,FH,MinSlots,MaxSlots,OpenArgs);
        {final,H}->
            H1 = H#head{auto_save = Auto},
            open_final(H1,Fname,Acc,Ram,CacheSz,Tab,Debug)
    end.

do_repair(Fd,Tab,Fname,FH,MinSlots,MaxSlots,OpenArgs) ->
    case fsck(Fd,Tab,Fname,FH,MinSlots,MaxSlots) of
        ok->
            garbage_collect(),
            fopen3(Tab,OpenArgs#open_args{repair = false});
        Error->
            throw(Error)
    end.

open_final(Head,Fname,Acc,Ram,CacheSz,Tab,Debug) ->
    Head1 = Head#head{access = Acc,ram_file = Ram,filename = Fname,name = Tab,cache = dets_utils:new_cache(CacheSz)},
    init_disk_map(Tab,Debug),
    dets_v9:cache_segps(Head1#head.fptr,Fname,Head1#head.next),
    check_growth(Head1),
    {ok,Head1}.

fopen_init_file(Tab,OpenArgs) ->
    #open_args{file = Fname,type = Type,keypos = Kp,min_no_slots = MinSlotsArg,max_no_slots = MaxSlotsArg,ram_file = Ram,delayed_write = CacheSz,auto_save = Auto,debug = Debug} = OpenArgs,
    MinSlots = choose_no_slots(MinSlotsArg,256),
    MaxSlots = choose_no_slots(MaxSlotsArg,32 * 1024 * 1024),
    FileSpec = if Ram ->
        [];true ->
        Fname end,
    {ok,Fd} = dets_utils:open(FileSpec,open_args(read_write,Ram)),
    init_disk_map(Tab,Debug),
    case  catch dets_v9:initiate_file(Fd,Tab,Fname,Type,Kp,MinSlots,MaxSlots,Ram,CacheSz,Auto,true) of
        {error,Reason}
            when Ram->
            _ = file:close(Fd),
            throw({error,Reason});
        {error,Reason}->
            _ = file:close(Fd),
            _ = file:delete(Fname),
            throw({error,Reason});
        {ok,Head}->
            start_auto_save_timer(Head),
            {ok,Head#head{update_mode = new_dirty}}
    end.

init_disk_map(Name,Debug) ->
    case Debug orelse dets_utils:debug_mode() of
        true->
            dets_utils:init_disk_map(Name);
        false->
            ok
    end.

open_args(Access,RamFile) ->
    A1 = case Access of
        read->
            [];
        read_write->
            [write]
    end,
    A2 = case RamFile of
        true->
            [ram];
        false->
            [raw]
    end,
    A1 ++ A2 ++ [binary, read].

compact(SourceHead) ->
    #head{name = Tab,filename = Fname,fptr = SFd,type = Type,keypos = Kp,ram_file = Ram,auto_save = Auto} = SourceHead,
    Tmp = tempfile(Fname),
    TblParms = dets_v9:table_parameters(SourceHead),
    {ok,Fd} = dets_utils:open(Tmp,open_args(read_write,false)),
    CacheSz = {3000,14000},
    Head = case  catch dets_v9:prep_table_copy(Fd,Tab,Tmp,Type,Kp,Ram,CacheSz,Auto,TblParms) of
        {ok,H}->
            H;
        Error->
            _ = file:close(Fd),
            _ = file:delete(Tmp),
            throw(Error)
    end,
    case dets_v9:compact_init(SourceHead,Head,TblParms) of
        {ok,NewHead}->
            R = case fclose(NewHead) of
                ok->
                    ok = file:close(SFd),
                    dets_utils:rename(Tmp,Fname);
                E->
                    E
            end,
            if R =:= ok ->
                ok;true ->
                _ = file:delete(Tmp),
                throw(R) end;
        Err->
            _ = file:close(Fd),
            _ = file:delete(Tmp),
            throw(Err)
    end.

fsck(Fd,Tab,Fname,FH,MinSlotsArg,MaxSlotsArg) ->
    #fileheader{min_no_slots = MinSlotsFile,max_no_slots = MaxSlotsFile} = FH,
    EstNoSlots0 = file_no_things(FH),
    MinSlots = choose_no_slots(MinSlotsArg,MinSlotsFile),
    MaxSlots = choose_no_slots(MaxSlotsArg,MaxSlotsFile),
    EstNoSlots = min(MaxSlots,max(MinSlots,EstNoSlots0)),
    SlotNumbers = {MinSlots,EstNoSlots,MaxSlots},
    case fsck_try(Fd,Tab,FH,Fname,SlotNumbers) of
        {try_again,BetterNoSlots}->
            BetterSlotNumbers = {MinSlots,BetterNoSlots,MaxSlots},
            case fsck_try(Fd,Tab,FH,Fname,BetterSlotNumbers) of
                {try_again,_}->
                    _ = file:close(Fd),
                    {error,{cannot_repair,Fname}};
                Else->
                    Else
            end;
        Else->
            Else
    end.

choose_no_slots(default,NoSlots) ->
    NoSlots;
choose_no_slots(NoSlots,_) ->
    NoSlots.

fsck_try(Fd,Tab,FH,Fname,SlotNumbers) ->
    Tmp = tempfile(Fname),
    #fileheader{type = Type,keypos = KeyPos} = FH,
    {_MinSlots,EstNoSlots,MaxSlots} = SlotNumbers,
    OpenArgs = #open_args{file = Tmp,type = Type,keypos = KeyPos,repair = false,min_no_slots = EstNoSlots,max_no_slots = MaxSlots,ram_file = false,delayed_write = {3000,14000},auto_save = infinity,access = read_write,debug = false},
    case  catch fopen3(Tab,OpenArgs) of
        {ok,Head}->
            case fsck_try_est(Head,Fd,Fname,SlotNumbers,FH) of
                {ok,NewHead}->
                    R = case fclose(NewHead) of
                        ok->
                            dets_utils:rename(Tmp,Fname);
                        Error->
                            Error
                    end,
                    if R =:= ok ->
                        ok;true ->
                        _ = file:delete(Tmp),
                        R end;
                TryAgainOrError->
                    _ = file:delete(Tmp),
                    TryAgainOrError
            end;
        Error->
            _ = file:close(Fd),
            Error
    end.

tempfile(Fname) ->
    Tmp = lists:concat([Fname, ".TMP"]),
    case file:delete(Tmp) of
        {error,_Reason}->
            ok;
        ok->
            assure_no_file(Tmp)
    end,
    Tmp.

assure_no_file(File) ->
    case file:read_file_info(File) of
        {ok,_FileInfo}->
            timer:sleep(100),
            assure_no_file(File);
        {error,_}->
            ok
    end.

fsck_try_est(Head,Fd,Fname,SlotNumbers,FH) ->
    Cntrs = ets:new(dets_repair,[]),
    Input = dets_v9:fsck_input(Head,Fd,Cntrs,FH),
    {Reply,SizeData} = do_sort(Head,SlotNumbers,Input,Cntrs,Fname),
    Bulk = false,
    case Reply of
        {ok,NoDups,H1}->
            _ = file:close(Fd),
            fsck_copy(SizeData,H1,Bulk,NoDups);
        {try_again,_} = Return->
            close_files(Bulk,SizeData,Head),
            Return;
        Else->
            _ = file:close(Fd),
            close_files(Bulk,SizeData,Head),
            Else
    end.

do_sort(Head,SlotNumbers,Input,Cntrs,Fname) ->
    Output = dets_v9:output_objs(Head,SlotNumbers,Cntrs),
    TmpDir = filename:dirname(Fname),
    Reply = ( catch file_sorter:sort(Input,Output,[{format,binary}, {tmpdir,TmpDir}])),
    L = ets:tab2list(Cntrs),
    ets:delete(Cntrs),
    {Reply,lists:reverse(lists:keysort(1,L))}.

fsck_copy([{_LogSz,Pos,Bins,_NoObjects}| SizeData],Head,_Bulk,NoDups)
    when is_list(Bins)->
    true = NoDups =:= 0,
    PWs = [{Pos,Bins}| lists:map(fun ({_,P,B,_})->
        {P,B} end,SizeData)],
    #head{fptr = Fd,filename = FileName} = Head,
    dets_utils:pwrite(Fd,FileName,PWs),
    {ok,Head#head{update_mode = dirty}};
fsck_copy(SizeData,Head,Bulk,NoDups) ->
     catch fsck_copy1(SizeData,Head,Bulk,NoDups).

fsck_copy1([SzData| L],Head,Bulk,NoDups) ->
    Out = Head#head.fptr,
    {LogSz,Pos,{FileName,Fd},NoObjects} = SzData,
    Size = if NoObjects =:= 0 ->
        0;true ->
        1 bsl (LogSz - 1) end,
    ExpectedSize = Size * NoObjects,
    case close_tmp(Fd) of
        ok->
            ok;
        Err->
            close_files(Bulk,L,Head),
            dets_utils:file_error(FileName,Err)
    end,
    case file:position(Out,Pos) of
        {ok,Pos}->
            ok;
        Err2->
            close_files(Bulk,L,Head),
            dets_utils:file_error(Head#head.filename,Err2)
    end,
    CR = file:copy({FileName,[raw, binary]},Out),
    _ = file:delete(FileName),
    case CR of
        {ok,Copied}
            when Copied =:= ExpectedSize;
            NoObjects =:= 0->
            fsck_copy1(L,Head,Bulk,NoDups);
        {ok,_Copied}->
            close_files(Bulk,L,Head),
            Reason = if Bulk ->
                initialization_failed;true ->
                repair_failed end,
            {error,{Reason,Head#head.filename}};
        FError->
            close_files(Bulk,L,Head),
            dets_utils:file_error(FileName,FError)
    end;
fsck_copy1([],Head,_Bulk,NoDups)
    when NoDups =/= 0->
    {error,{initialization_failed,Head#head.filename}};
fsck_copy1([],Head,_Bulk,_NoDups) ->
    {ok,Head#head{update_mode = dirty}}.

close_files(false,SizeData,Head) ->
    _ = file:close(Head#head.fptr),
    close_files(true,SizeData,Head);
close_files(true,SizeData,_Head) ->
    Fun = fun ({_Size,_Pos,{FileName,Fd},_No})->
        _ = close_tmp(Fd),
        file:delete(FileName);(_)->
        ok end,
    lists:foreach(Fun,SizeData).

close_tmp(Fd) ->
    file:close(Fd).

fslot(H,Slot) ->
    case  catch begin {NH,[]} = write_cache(H),
    Objs = dets_v9:slot_objs(NH,Slot),
    {NH,Objs} end of
        {NewHead,_Objects} = Reply
            when is_record(NewHead,head)->
            Reply
    end.

do_update_counter(Head,_Key,_Incr)
    when Head#head.type =/= set->
    {Head,badarg};
do_update_counter(Head,Key,Incr) ->
    case flookup_keys(Head,[Key]) of
        {H1,[O]}->
            Kp = H1#head.keypos,
            case  catch try_update_tuple(O,Kp,Incr) of
                {'EXIT',_}->
                    {H1,badarg};
                {New,Term}->
                    case finsert(H1,[Term]) of
                        {H2,ok}->
                            {H2,New};
                        Reply->
                            Reply
                    end
            end;
        {H1,[]}->
            {H1,badarg};
        HeadError->
            HeadError
    end.

try_update_tuple(O,_Kp,{Pos,Incr}) ->
    try_update_tuple2(O,Pos,Incr);
try_update_tuple(O,Kp,Incr) ->
    try_update_tuple2(O,Kp + 1,Incr).

try_update_tuple2(O,Pos,Incr) ->
    New = element(Pos,O) + Incr,
    {New,setelement(Pos,O,New)}.

set_verbose(true) ->
    put(verbose,yes);
set_verbose(_) ->
    erase(verbose).

where_is_object(Head,Object) ->
    Keypos = Head#head.keypos,
    case check_objects([Object],Keypos) of
        true->
            case  catch write_cache(Head) of
                {NewHead,[]}->
                    {NewHead,dets_v9:find_object(NewHead,Object)};
                {NewHead,_} = HeadError
                    when is_record(NewHead,head)->
                    HeadError
            end;
        false->
            {Head,badarg}
    end.

check_objects([T| Ts],Kp)
    when tuple_size(T) >= Kp->
    check_objects(Ts,Kp);
check_objects(L,_Kp) ->
    L =:= [].

no_things(Head) ->
    Head#head.no_keys.

file_no_things(FH) ->
    FH#fileheader.no_keys.

update_cache(Head,KeysOrObjects,What) ->
    {Head1,LU,PwriteList} = update_cache(Head,[{What,KeysOrObjects}]),
    {NewHead,ok} = dets_utils:pwrite(Head1,PwriteList),
    {NewHead,LU}.

update_cache(Head,ToAdd) ->
    Cache = Head#head.cache,
    #cache{cache = C,csize = Size0,inserts = Ins} = Cache,
    NewSize = Size0 + erlang:external_size(ToAdd),
    {NewC,NewIns,Lookup,Found} = cache_binary(Head,ToAdd,C,Size0,Ins,false,[]),
    NewCache = Cache#cache{cache = NewC,csize = NewSize,inserts = NewIns},
    Head1 = Head#head{cache = NewCache},
    if Lookup;
    NewSize >= Cache#cache.tsize ->
        {NewHead,LU,PwriteList} = dets_v9:write_cache(Head1),
        {NewHead,Found ++ LU,PwriteList};NewC =:= [] ->
        {Head1,Found,[]};Cache#cache.wrtime =:= undefined ->
        Now = time_now(),
        Me = self(),
        Call = {'$dets_call',Me,{delayed_write,Now}},
        erlang:send_after(Cache#cache.delay,Me,Call),
        {Head1#head{cache = NewCache#cache{wrtime = Now}},Found,[]};Size0 =:= 0 ->
        {Head1#head{cache = NewCache#cache{wrtime = time_now()}},Found,[]};true ->
        {Head1,Found,[]} end.

cache_binary(Head,[{Q,Os}| L],C,Seq,Ins,Lu,F)
    when Q =:= delete_object->
    cache_obj_op(Head,L,C,Seq,Ins,Lu,F,Os,Head#head.keypos,Q);
cache_binary(Head,[{Q,Os}| L],C,Seq,Ins,Lu,F)
    when Q =:= insert->
    NewIns = Ins + length(Os),
    cache_obj_op(Head,L,C,Seq,NewIns,Lu,F,Os,Head#head.keypos,Q);
cache_binary(Head,[{Q,Ks}| L],C,Seq,Ins,Lu,F)
    when Q =:= delete_key->
    cache_key_op(Head,L,C,Seq,Ins,Lu,F,Ks,Q);
cache_binary(Head,[{Q,Ks}| L],C,Seq,Ins,_Lu,F)
    when C =:= []->
    cache_key_op(Head,L,C,Seq,Ins,true,F,Ks,Q);
cache_binary(Head,[{Q,Ks}| L],C,Seq,Ins,Lu,F) ->
    case dets_utils:cache_lookup(Head#head.type,Ks,C,[]) of
        false->
            cache_key_op(Head,L,C,Seq,Ins,true,F,Ks,Q);
        Found->
            {lookup,Pid} = Q,
            cache_binary(Head,L,C,Seq,Ins,Lu,[{Pid,Found}| F])
    end;
cache_binary(_Head,[],C,_Seq,Ins,Lu,F) ->
    {C,Ins,Lu,F}.

cache_key_op(Head,L,C,Seq,Ins,Lu,F,[K| Ks],Q) ->
    E = {K,{Seq,Q}},
    cache_key_op(Head,L,[E| C],Seq + 1,Ins,Lu,F,Ks,Q);
cache_key_op(Head,L,C,Seq,Ins,Lu,F,[],_Q) ->
    cache_binary(Head,L,C,Seq,Ins,Lu,F).

cache_obj_op(Head,L,C,Seq,Ins,Lu,F,[O| Os],Kp,Q) ->
    E = {element(Kp,O),{Seq,{Q,O}}},
    cache_obj_op(Head,L,[E| C],Seq + 1,Ins,Lu,F,Os,Kp,Q);
cache_obj_op(Head,L,C,Seq,Ins,Lu,F,[],_Kp,_Q) ->
    cache_binary(Head,L,C,Seq,Ins,Lu,F).

delayed_write(Head,WrTime) ->
    Cache = Head#head.cache,
    LastWrTime = Cache#cache.wrtime,
    if LastWrTime =:= WrTime ->
        case  catch write_cache(Head) of
            {Head2,[]}->
                NewCache = (Head2#head.cache)#cache{wrtime = undefined},
                Head2#head{cache = NewCache};
            {NewHead,_Error}->
                NewHead
        end;true ->
        if Cache#cache.csize =:= 0 ->
            NewCache = Cache#cache{wrtime = undefined},
            Head#head{cache = NewCache};true ->
            When = round((LastWrTime - WrTime)/1000),
            Me = self(),
            Call = {'$dets_call',Me,{delayed_write,LastWrTime}},
            erlang:send_after(When,Me,Call),
            Head end end.

write_cache(Head) ->
    {Head1,LU,PwriteList} = dets_v9:write_cache(Head),
    {NewHead,ok} = dets_utils:pwrite(Head1,PwriteList),
    {NewHead,LU}.

status(Head) ->
    case Head#head.update_mode of
        saved->
            ok;
        dirty->
            ok;
        new_dirty->
            ok;
        Error->
            Error
    end.

init_scan(Head,NoObjs) ->
    check_safe_fixtable(Head),
    FreeLists = dets_utils:get_freelists(Head),
    Base = Head#head.base,
    case dets_utils:find_next_allocated(FreeLists,Base,Base) of
        {From,To}->
            #dets_cont{no_objs = NoObjs,bin = <<>>,alloc = {From,To,<<>>}};
        none->
            #dets_cont{no_objs = NoObjs,bin = eof,alloc = <<>>}
    end.

check_safe_fixtable(Head) ->
    case Head#head.fixed =:= false andalso (get(verbose) =:= yes orelse dets_utils:debug_mode()) of
        true->
            error_logger:format("** dets: traversal of ~tp needs safe_f" "ixtable~n",[Head#head.name]);
        false->
            ok
    end.

scan(_Head,#dets_cont{alloc = <<>>} = C) ->
    {[],C};
scan(Head,C) ->
    #dets_cont{no_objs = No,alloc = L0,bin = Bin} = C,
    {From,To,L} = L0,
    R = case No of
        default->
            0;
        _
            when is_integer(No)->
            -No - 1
    end,
    scan(Bin,Head,From,To,L,[],R,{C,Head#head.type}).

scan(Bin,H,From,To,L,Ts,R,{C0,Type} = C) ->
    case dets_v9:scan_objs(H,Bin,From,To,L,Ts,R,Type) of
        {more,NFrom,NTo,NL,NTs,NR,Sz}->
            scan_read(H,NFrom,NTo,Sz,NL,NTs,NR,C);
        {stop,<<>> = B,NFrom,NTo,<<>> = NL,NTs}->
            Ftab = dets_utils:get_freelists(H),
            case dets_utils:find_next_allocated(Ftab,NFrom,H#head.base) of
                none->
                    {NTs,C0#dets_cont{bin = eof,alloc = B}};
                _->
                    {NTs,C0#dets_cont{bin = B,alloc = {NFrom,NTo,NL}}}
            end;
        {stop,B,NFrom,NTo,NL,NTs}->
            {NTs,C0#dets_cont{bin = B,alloc = {NFrom,NTo,NL}}};
        bad_object->
            {scan_error,dets_utils:bad_object(scan,{From,To,Bin})}
    end.

scan_read(_H,From,To,_Min,L0,Ts,R,{C,_Type})
    when R >= 8192->
    L = {From,To,L0},
    {Ts,C#dets_cont{bin = <<>>,alloc = L}};
scan_read(H,From,_To,Min,_L,Ts,R,C) ->
    Max = if Min < 8192 ->
        8192;true ->
        Min end,
    FreeLists = dets_utils:get_freelists(H),
    case dets_utils:find_allocated(FreeLists,From,Max,H#head.base) of
        <<>> = Bin0->
            {Cont,_} = C,
            {Ts,Cont#dets_cont{bin = eof,alloc = Bin0}};
        <<From1:32,To1:32,L1/binary>>->
            case dets_utils:pread_n(H#head.fptr,From1,Max) of
                eof->
                    {scan_error,premature_eof};
                NewBin->
                    scan(NewBin,H,From1,To1,L1,Ts,R,C)
            end
    end.

err(Error) ->
    case get(verbose) of
        yes->
            error_logger:format("** dets: failed with ~tw~n",[Error]),
            Error;
        undefined->
            Error
    end.

-compile({inline,[{time_now,0}]}).

time_now() ->
    erlang:monotonic_time(1000000).

make_timestamp(MonTime,TimeOffset) ->
    ErlangSystemTime = erlang:convert_time_unit(MonTime + TimeOffset,native,microsecond),
    MegaSecs = ErlangSystemTime div 1000000000000,
    Secs = ErlangSystemTime div 1000000 - MegaSecs * 1000000,
    MicroSecs = ErlangSystemTime rem 1000000,
    {MegaSecs,Secs,MicroSecs}.

file_info(FileName) ->
    case  catch read_file_header(FileName,read,false) of
        {ok,Fd,FH}->
            _ = file:close(Fd),
            dets_v9:file_info(FH);
        Other->
            Other
    end.

get_head_field(Fd,Field) ->
    dets_utils:read_4(Fd,Field).

view(FileName) ->
    case  catch read_file_header(FileName,read,false) of
        {ok,Fd,FH}->
            try dets_v9:check_file_header(FH,Fd) of 
                {ok,H0}->
                    case dets_v9:check_file_header(FH,Fd) of
                        {ok,H0}->
                            H = dets_v9:init_freelist(H0),
                            v_free_list(H),
                            dets_v9:v_segments(H),
                            ok;
                        X->
                            X
                    end
                after _ = file:close(Fd) end;
        X->
            X
    end.

v_free_list(Head) ->
    io:format("FREE LIST ...... \n",[]),
    io:format("~p~n",[dets_utils:all_free(Head)]),
    io:format("END OF FREE LIST \n",[]).
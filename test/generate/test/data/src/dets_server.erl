-file("dets_server.erl", 1).

-module(dets_server).

-behaviour(gen_server).

-export([all/0, close/1, get_pid/1, open_file/1, open_file/2, pid2name/1, users/1, verbose/1]).

-export([start_link/0, start/0, stop/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(pending, {tab,ref,pid,from,reqtype,clients}).

-record(state, {store,parent,pending}).

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

-file("dets_server.erl", 44).

-compile({inline,[{pid2name_1,1}]}).

start_link() ->
    gen_server:start_link({local,dets},dets_server,[self()],[]).

start() ->
    ensure_started().

stop() ->
    case whereis(dets) of
        undefined->
            stopped;
        _Pid->
            gen_server:call(dets,stop,infinity)
    end.

all() ->
    call(all).

close(Tab) ->
    call({close,Tab}).

get_pid(Tab) ->
    ets:lookup_element(dets_registry,Tab,3).

open_file(File) ->
    call({open,File}).

open_file(Tab,OpenArgs) ->
    call({open,Tab,OpenArgs}).

pid2name(Pid) ->
    ensure_started(),
    pid2name_1(Pid).

users(Tab) ->
    call({users,Tab}).

verbose(What) ->
    call({set_verbose,What}).

call(Message) ->
    ensure_started(),
    gen_server:call(dets,Message,infinity).

init(Parent) ->
    Store = init(),
    {ok,#state{store = Store,parent = Parent,pending = []}}.

handle_call(all,_From,State) ->
    F = fun (X,A)->
        [element(1,X)| A] end,
    {reply,ets:foldl(F,[],dets_registry),State};
handle_call({close,Tab},From,State) ->
    request([{{close,Tab},From}],State);
handle_call({open,File},From,State) ->
    request([{{open,File},From}],State);
handle_call({open,Tab,OpenArgs},From,State) ->
    request([{{open,Tab,OpenArgs},From}],State);
handle_call(stop,_From,State) ->
    {stop,normal,stopped,State};
handle_call({set_verbose,What},_From,State) ->
    set_verbose(What),
    {reply,ok,State};
handle_call({users,Tab},_From,State) ->
    Users = ets:select(State#state.store,[{{'$1',Tab},[],['$1']}]),
    {reply,Users,State}.

handle_cast(_Msg,State) ->
    {noreply,State}.

handle_info({pending_reply,{Ref,Result0}},State) ->
    {value,#pending{tab = Tab,pid = Pid,from = {FromPid,_Tag} = From,reqtype = ReqT,clients = Clients}} = lists:keysearch(Ref,#pending.ref,State#state.pending),
    Store = State#state.store,
    Result = case {Result0,ReqT} of
        {ok,add_user}->
            do_link(Store,FromPid),
            true = ets:insert(Store,{FromPid,Tab}),
            ets:update_counter(dets_registry,Tab,1),
            {ok,Tab};
        {ok,internal_open}->
            link(Pid),
            do_link(Store,FromPid),
            true = ets:insert(Store,{FromPid,Tab}),
            {ok,Tab};
        {Reply,internal_open}->
            true = ets:delete(dets_registry,Tab),
            true = ets:delete(dets_owners,Pid),
            Reply;
        {Reply,_}->
            Reply
    end,
    gen_server:reply(From,Result),
    NP = lists:keydelete(Pid,#pending.pid,State#state.pending),
    State1 = State#state{pending = NP},
    request(Clients,State1);
handle_info({'EXIT',Pid,_Reason},State) ->
    Store = State#state.store,
    case pid2name_1(Pid) of
        {ok,Tab}->
            true = ets:delete(dets_registry,Tab),
            true = ets:delete(dets_owners,Pid),
            Users = ets:select(State#state.store,[{{'$1',Tab},[],['$1']}]),
            true = ets:match_delete(Store,{_,Tab}),
            lists:foreach(fun (User)->
                do_unlink(Store,User) end,Users),
            {noreply,State};
        undefined->
            F = fun ({FromPid,Tab},S)->
                {_,S1} = handle_close(S,{close,Tab},{FromPid,notag},Tab),
                S1 end,
            State1 = lists:foldl(F,State,ets:lookup(Store,Pid)),
            {noreply,State1}
    end;
handle_info(_Message,State) ->
    {noreply,State}.

terminate(_Reason,_State) ->
    ok.

code_change(_OldVsn,State,_Extra) ->
    {ok,State}.

ensure_started() ->
    case whereis(dets) of
        undefined->
            DetsSup = {dets_sup,{dets_sup,start_link,[]},permanent,1000,supervisor,[dets_sup]},
            _ = supervisor:start_child(kernel_safe_sup,DetsSup),
            DetsServer = {dets,{dets_server,start_link,[]},permanent,2000,worker,[dets_server]},
            _ = supervisor:start_child(kernel_safe_sup,DetsServer),
            ok;
        _->
            ok
    end.

init() ->
    set_verbose(verbose_flag()),
    process_flag(trap_exit,true),
    dets_registry = ets:new(dets_registry,[set, named_table]),
    dets_owners = ets:new(dets_owners,[set, named_table]),
    ets:new(dets,[duplicate_bag]).

verbose_flag() ->
    case init:get_argument(dets) of
        {ok,Args}->
            lists:member(["verbose"],Args);
        _->
            false
    end.

set_verbose(true) ->
    put(verbose,yes);
set_verbose(_) ->
    erase(verbose).

pid2name_1(Pid) ->
    case ets:lookup(dets_owners,Pid) of
        []->
            undefined;
        [{_Pid,Tab}]->
            {ok,Tab}
    end.

request([{Req,From}| L],State) ->
    Res = case Req of
        {close,Tab}->
            handle_close(State,Req,From,Tab);
        {open,File}->
            do_internal_open(State,From,[File, get(verbose)]);
        {open,Tab,OpenArgs}->
            do_open(State,Req,From,OpenArgs,Tab)
    end,
    State2 = case Res of
        {pending,State1}->
            State1;
        {Reply,State1}->
            gen_server:reply(From,Reply),
            State1
    end,
    request(L,State2);
request([],State) ->
    {noreply,State}.

do_open(State,Req,From,Args,Tab) ->
    case check_pending(Tab,From,State,Req) of
        {pending,NewState}->
            {pending,NewState};
        false->
            case ets:lookup(dets_registry,Tab) of
                []->
                    A = [Tab, Args, get(verbose)],
                    do_internal_open(State,From,A);
                [{Tab,_Counter,Pid}]->
                    pending_call(Tab,Pid,make_ref(),From,Args,add_user,State)
            end
    end.

do_internal_open(State,From,Args) ->
    case supervisor:start_child(dets_sup,[self()]) of
        {ok,Pid}->
            Ref = make_ref(),
            Tab = case Args of
                [T, _, _]->
                    T;
                [_, _]->
                    Ref
            end,
            true = ets:insert(dets_registry,{Tab,1,Pid}),
            true = ets:insert(dets_owners,{Pid,Tab}),
            pending_call(Tab,Pid,Ref,From,Args,internal_open,State);
        Error->
            {Error,State}
    end.

handle_close(State,Req,{FromPid,_Tag} = From,Tab) ->
    case check_pending(Tab,From,State,Req) of
        {pending,NewState}->
            {pending,NewState};
        false->
            Store = State#state.store,
            case ets:match_object(Store,{FromPid,Tab}) of
                []->
                    void,
                    {{error,not_owner},State};
                [_| Keep]->
                    case ets:lookup(dets_registry,Tab) of
                        [{Tab,1,Pid}]->
                            do_unlink(Store,FromPid),
                            true = ets:delete(dets_registry,Tab),
                            true = ets:delete(dets_owners,Pid),
                            true = ets:match_delete(Store,{FromPid,Tab}),
                            unlink(Pid),
                            pending_call(Tab,Pid,make_ref(),From,[],internal_close,State);
                        [{Tab,_Counter,Pid}]->
                            do_unlink(Store,FromPid),
                            true = ets:match_delete(Store,{FromPid,Tab}),
                            true = ets:insert(Store,Keep),
                            ets:update_counter(dets_registry,Tab,-1),
                            pending_call(Tab,Pid,make_ref(),From,[],remove_user,State)
                    end
            end
    end.

do_link(Store,Pid) ->
    Key = {links,Pid},
    case ets:lookup(Store,Key) of
        []->
            true = ets:insert(Store,{Key,1}),
            link(Pid);
        [{_,C}]->
            true = ets:delete(Store,Key),
            true = ets:insert(Store,{Key,C + 1})
    end.

do_unlink(Store,Pid) ->
    Key = {links,Pid},
    case ets:lookup(Store,Key) of
        [{_,C}]
            when C > 1->
            true = ets:delete(Store,Key),
            true = ets:insert(Store,{Key,C - 1});
        _->
            true = ets:delete(Store,Key),
            unlink(Pid)
    end.

pending_call(Tab,Pid,Ref,{FromPid,_Tag} = From,Args,ReqT,State) ->
    Server = self(),
    F = fun ()->
        Res = case ReqT of
            add_user->
                dets:add_user(Pid,Tab,Args);
            internal_open->
                dets:internal_open(Pid,Ref,Args);
            internal_close->
                dets:internal_close(Pid);
            remove_user->
                dets:remove_user(Pid,FromPid)
        end,
        Server ! {pending_reply,{Ref,Res}} end,
    _ = spawn(F),
    PD = #pending{tab = Tab,ref = Ref,pid = Pid,reqtype = ReqT,from = From,clients = []},
    P = [PD| State#state.pending],
    {pending,State#state{pending = P}}.

check_pending(Tab,From,State,Req) ->
    case lists:keysearch(Tab,#pending.tab,State#state.pending) of
        {value,#pending{tab = Tab,clients = Clients} = P}->
            NP = lists:keyreplace(Tab,#pending.tab,State#state.pending,P#pending{clients = Clients ++ [{Req,From}]}),
            {pending,State#state{pending = NP}};
        false->
            false
    end.
-file("ssh_info.erl", 1).

-module(ssh_info).

-export([print/0, print/1, string/0, collect_pids/0]).

-file("ssh_connect.hrl", 1).

-record(ssh_msg_global_request, {name,want_reply,data}).

-record(ssh_msg_request_success, {data}).

-record(ssh_msg_request_failure, {}).

-record(ssh_msg_channel_open, {channel_type,sender_channel,initial_window_size,maximum_packet_size,data}).

-record(ssh_msg_channel_open_confirmation, {recipient_channel,sender_channel,initial_window_size,maximum_packet_size,data}).

-record(ssh_msg_channel_open_failure, {recipient_channel,reason,description,lang}).

-record(ssh_msg_channel_window_adjust, {recipient_channel,bytes_to_add}).

-record(ssh_msg_channel_data, {recipient_channel,data}).

-record(ssh_msg_channel_extended_data, {recipient_channel,data_type_code,data}).

-record(ssh_msg_channel_eof, {recipient_channel}).

-record(ssh_msg_channel_close, {recipient_channel}).

-record(ssh_msg_channel_request, {recipient_channel,request_type,want_reply,data}).

-record(ssh_msg_channel_success, {recipient_channel}).

-record(ssh_msg_channel_failure, {recipient_channel}).

-record(channel, {type,sys,user,flow_control,local_id,recv_window_size,recv_window_pending = 0,recv_packet_size,recv_close = false,remote_id,send_window_size,send_packet_size,sent_close = false,send_buf = []}).

-record(connection, {requests = [],channel_cache,channel_id_seed,cli_spec,options,exec,system_supervisor,sub_system_supervisor,connection_supervisor}).

-file("ssh_info.erl", 35).

print() ->
    io:format("~s",[string()]).

print(File)
    when is_list(File)->
    {ok,D} = file:open(File,[write]),
    print(D),
    file:close(D);
print(D) ->
    io:format(D,"~s",[string()]).

string() ->
    try supervisor:which_children(ssh_sup) of 
        _->
            [io_lib:nl(), print_general(), io_lib:nl(), underline("Client part",$=), print_clients(), io_lib:nl(), underline("Server part",$=), print_servers(), io_lib:nl(), underline("Supervisors",$=), walk_sups(ssh_sup), io_lib:nl()]
        catch
            _:_->
                io_lib:format("Ssh not found~n",[]) end.

print_general() ->
    {_Name,Slogan,Ver} = lists:keyfind(ssh,1,application:which_applications()),
    [underline(io_lib:format("~s  ~s",[Slogan, Ver]),$=), io_lib:format('This printout is generated ~s. ~n',[datetime()])].

print_clients() ->
    try lists:map(fun print_client/1,supervisor:which_children(sshc_sup))
        catch
            C:E:S->
                io_lib:format('***print_clients FAILED: ~p:~p,~n ~p~n',[C, E, S]) end.

print_client({undefined,Pid,supervisor,[ssh_connection_handler]}) ->
    {{Local,Remote},_Str} = ssh_connection_handler:get_print_info(Pid),
    [io_lib:format("    Local: ~s  Remote: ~s  ConnectionRef = ~p~n",[fmt_host_port(Local), fmt_host_port(Remote), Pid]), case channels(Pid) of
        {ok,Channels = [_| _]}->
            [(print_ch(ChPid)) || #channel{user = ChPid} <- Channels];
        _->
            io_lib:format("            No channels~n",[])
    end];
print_client({{client,ssh_system_sup,_,_,_},Pid,supervisor,[ssh_system_sup]})
    when is_pid(Pid)->
    lists:map(fun print_system_sup/1,supervisor:which_children(Pid)).

print_servers() ->
    try lists:map(fun print_server/1,supervisor:which_children(sshd_sup))
        catch
            C:E:S->
                io_lib:format('***print_servers FAILED: ~p:~p,~n ~p~n',[C, E, S]) end.

print_server({{server,ssh_system_sup,LocalHost,LocalPort,Profile},Pid,supervisor,[ssh_system_sup]})
    when is_pid(Pid)->
    Children = supervisor:which_children(Pid),
    [io_lib:format("    Listen: ~s (~p children) Profile ~p",[fmt_host_port({LocalHost,LocalPort}), ssh_acceptor:number_of_connections(Pid), Profile]), case [AccPid || {{ssh_acceptor_sup,_LocalHost,_LocalPort,_Profile},AccPid,supervisor,[ssh_acceptor_sup]} <- Children] of
        AcceptorPids = [_| _]->
            [io_lib:format("  [Acceptor Pid",[]), [(io_lib:format(" ~p",[AccPid])) || AccPid <- AcceptorPids], io_lib:format("]~n",[])];
        []->
            io_lib:nl()
    end, lists:map(fun print_system_sup/1,supervisor:which_children(Pid))].

print_system_sup({Ref,Pid,supervisor,[ssh_subsystem_sup]})
    when is_reference(Ref),
    is_pid(Pid)->
    lists:map(fun print_channels/1,supervisor:which_children(Pid));
print_system_sup({{ssh_acceptor_sup,_LocalHost,_LocalPort,_Profile},Pid,supervisor,[ssh_acceptor_sup]})
    when is_pid(Pid)->
    [].

print_channels({{Role,ssh_channel_sup,_,_},Pid,supervisor,[ssh_channel_sup]})
    when is_pid(Pid)->
    ChanBehaviour = case Role of
        server->
            ssh_server_channel;
        client->
            ssh_client_channel
    end,
    Children = supervisor:which_children(Pid),
    ChannelPids = [P || {R,P,worker,[Mod]} <- Children,ChanBehaviour == Mod,is_pid(P),is_reference(R)],
    case ChannelPids of
        []->
            io_lib:format("        No channels~n",[]);
        [Ch1Pid| _]->
            {{ConnManager,_},_Str} = ChanBehaviour:get_print_info(Ch1Pid),
            {{_,Remote},_} = ssh_connection_handler:get_print_info(ConnManager),
            [io_lib:format("        Remote: ~s ConnectionRef = ~p~n",[fmt_host_port(Remote), ConnManager]), lists:map(fun print_ch/1,ChannelPids)]
    end;
print_channels({{_Role,ssh_connection_sup,_,_},Pid,supervisor,[ssh_connection_sup]})
    when is_pid(Pid)->
    [];
print_channels({Ref,Pid,supervisor,[ssh_tcpip_forward_acceptor_sup]})
    when is_pid(Pid),
    is_reference(Ref)->
    [].

print_ch(Pid) ->
    try {{ConnManager,ChannelID},Str} = ssh_server_channel:get_print_info(Pid),
    {_LocalRemote,StrM} = ssh_connection_handler:get_print_info(ConnManager),
    io_lib:format("            ch ~p ~p: ~s ~s~n",[ChannelID, Pid, StrM, Str])
        catch
            C:E->
                io_lib:format('****print_ch FAILED for ChanPid ~p: ~p:~p~n',[Pid, C, E]) end.

walk_sups(StartPid) ->
    io_lib:format("Start at ~p, ~s.~n",[StartPid, dead_or_alive(StartPid)]),
    walk_sups(children(StartPid),_Indent = 0 + 4).

walk_sups([H = {_,Pid,_,_}| T],Indent) ->
    [indent(Indent), io_lib:format('~200p  ~p is ~s~n',[H, Pid, dead_or_alive(Pid)]), case H of
        {_,_,supervisor,[ssh_connection_handler]}->
            "";
        {_,Pid,supervisor,_}->
            walk_sups(children(Pid),Indent + 4);
        _->
            ""
    end, walk_sups(T,Indent)];
walk_sups([],_) ->
    "".

dead_or_alive(Name)
    when is_atom(Name)->
    case whereis(Name) of
        undefined->
            "**UNDEFINED**";
        Pid->
            dead_or_alive(Pid)
    end;
dead_or_alive(Pid)
    when is_pid(Pid)->
    case process_info(Pid) of
        undefined->
            "**DEAD**";
        _->
            "alive"
    end.

indent(I) ->
    io_lib:format('~*c',[I, $ ]).

children(Pid) ->
    Parent = self(),
    Helper = spawn(fun ()->
        Parent ! {self(),supervisor:which_children(Pid)} end),
    receive {Helper,L}
        when is_list(L)->
        L after 2000->
         catch exit(Helper,kill),
        [] end.

is_connection_handler(Pid) ->
    try {ssh_connection_handler,init,_} = proplists:get_value('$initial_call',proplists:get_value(dictionary,process_info(Pid,[dictionary]))) of 
        _->
            true
        catch
            _:_->
                false end.

channels(Pid) ->
    case is_connection_handler(Pid) of
        true->
            ssh_connection_handler:info(Pid,all);
        false->
            false
    end.

underline(Str,LineChar) ->
    io_lib:format('~s~n~*c~n',[Str, lists:flatlength(Str), LineChar]).

datetime() ->
    {{YYYY,MM,DD},{H,M,S}} = calendar:now_to_universal_time(erlang:timestamp()),
    lists:flatten(io_lib:format('~4w-~2..0w-~2..0w ~2..0w:~2..0w:~2..0w UTC',[YYYY, MM, DD, H, M, S])).

fmt_host_port({{A,B,C,D},Port}) ->
    io_lib:format('~p.~p.~p.~p:~p',[A, B, C, D, Port]);
fmt_host_port({Host,Port}) ->
    io_lib:format('~s:~p',[Host, Port]).

collect_pids() ->
    collect_pids(ssh_sup).

collect_pids(P) ->
    Collector = pcollect_pids(P,spawn(fun init_collector/0)),
    Collector ! {get_values,self()},
    receive {values,Values}->
        Values end.

pcollect_pids(undefined,Collector) ->
    Collector;
pcollect_pids(A,Collector)
    when is_atom(A)->
    pcollect_pids(whereis(A),Collector);
pcollect_pids(Pid,Collector)
    when is_pid(Pid)->
    Collector ! {expect,Pid},
    spawn(fun ()->
        lists:foreach(fun (P2)->
            pcollect_pids(P2,Collector) end,children(Pid)),
        Collector ! {value,Pid,Pid} end),
    Collector;
pcollect_pids({Ref,Pid,supervisor,_},Collector)
    when is_pid(Pid),
    is_reference(Ref)->
    pcollect_pids(Pid,Collector);
pcollect_pids({sshc_sup,Pid,supervisor,_},Collector)
    when is_pid(Pid)->
    pcollect_pids(Pid,Collector);
pcollect_pids({sshd_sup,Pid,supervisor,_},Collector)
    when is_pid(Pid)->
    pcollect_pids(Pid,Collector);
pcollect_pids({{ssh_acceptor_sup,_,_,_},Pid,supervisor,_},Collector)
    when is_pid(Pid)->
    pcollect_pids(Pid,Collector);
pcollect_pids({{server,_,_,_},Pid,supervisor,_},Collector)
    when is_pid(Pid)->
    pcollect_pids(Pid,Collector);
pcollect_pids({{server,_,_,_,_},Pid,supervisor,_},Collector)
    when is_pid(Pid)->
    pcollect_pids(Pid,Collector);
pcollect_pids({undefined,Pid,supervisor,[ssh_connection_handler]},Collector) ->
    Collector ! {value,Pid,Pid},
    case channels(Pid) of
        {ok,L}->
            [(Collector ! {value,P,P}) || #channel{user = P} <- L];
        _->
            ok
    end,
    Collector;
pcollect_pids({_,Pid,_,_},Collector)
    when is_pid(Pid)->
    Collector ! {value,Pid,Pid},
    Collector;
pcollect_pids(_,Collector) ->
    Collector.

init_collector() ->
    loop_collector([],[]).

loop_collector(Expects,Values) ->
    receive {expect,Ref}->
        loop_collector([Ref| Expects],Values);
    {value,Ref,Val}->
        loop_collector(Expects -- [Ref],[Val| Values]);
    {get_values,From}
        when Expects == []->
        From ! {values,Values} end.
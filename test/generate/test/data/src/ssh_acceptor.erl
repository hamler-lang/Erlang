-file("ssh_acceptor.erl", 1).

-module(ssh_acceptor).

-file("ssh.hrl", 1).

-type(role()::client|server).

-type(host()::string()|inet:ip_address()|loopback).

-type(open_socket()::gen_tcp:socket()).

-type(subsystem_spec()::{Name::string(),mod_args()}).

-type(algs_list()::[alg_entry()]).

-type(alg_entry()::{kex,[kex_alg()]}|{public_key,[pubkey_alg()]}|{cipher,double_algs(cipher_alg())}|{mac,double_algs(mac_alg())}|{compression,double_algs(compression_alg())}).

-type(kex_alg()::diffie-hellman-group-exchange-sha1|diffie-hellman-group-exchange-sha256|diffie-hellman-group1-sha1|diffie-hellman-group14-sha1|diffie-hellman-group14-sha256|diffie-hellman-group16-sha512|diffie-hellman-group18-sha512|curve25519-sha256|curve25519-sha256@libssh.org|curve448-sha512|ecdh-sha2-nistp256|ecdh-sha2-nistp384|ecdh-sha2-nistp521).

-type(pubkey_alg()::ecdsa-sha2-nistp256|ecdsa-sha2-nistp384|ecdsa-sha2-nistp521|ssh-ed25519|ssh-ed448|rsa-sha2-256|rsa-sha2-512|ssh-dss|ssh-rsa).

-type(cipher_alg()::'3des-cbc'|'AEAD_AES_128_GCM'|'AEAD_AES_256_GCM'|aes128-cbc|aes128-ctr|aes128-gcm@openssh.com|aes192-ctr|aes192-cbc|aes256-cbc|aes256-ctr|aes256-gcm@openssh.com|chacha20-poly1305@openssh.com).

-type(mac_alg()::'AEAD_AES_128_GCM'|'AEAD_AES_256_GCM'|hmac-sha1|hmac-sha1-etm@openssh.com|hmac-sha1-96|hmac-sha2-256|hmac-sha2-512|hmac-sha2-256-etm@openssh.com|hmac-sha2-512-etm@openssh.com).

-type(compression_alg()::none|zlib|zlib@openssh.com).

-type(double_algs(AlgType)::[{client2server,[AlgType]}|{server2client,[AlgType]}]|[AlgType]).

-type(modify_algs_list()::[{append,algs_list()}|{prepend,algs_list()}|{rm,algs_list()}]).

-type(internal_options()::ssh_options:private_options()).

-type(socket_options()::[gen_tcp:connect_option()|gen_tcp:listen_option()]).

-type(client_options()::[client_option()]).

-type(daemon_options()::[daemon_option()]).

-type(common_options()::[common_option()]).

-type(common_option()::ssh_file:user_dir_common_option()|profile_common_option()|max_idle_time_common_option()|key_cb_common_option()|disconnectfun_common_option()|unexpectedfun_common_option()|ssh_msg_debug_fun_common_option()|rekey_limit_common_option()|id_string_common_option()|pref_public_key_algs_common_option()|preferred_algorithms_common_option()|modify_algorithms_common_option()|auth_methods_common_option()|inet_common_option()|fd_common_option()).

-type(profile_common_option()::{profile,atom()}).

-type(max_idle_time_common_option()::{idle_time,timeout()}).

-type(rekey_limit_common_option()::{rekey_limit,Bytes::limit_bytes()|{Minutes::limit_time(),Bytes::limit_bytes()}}).

-type(limit_bytes()::non_neg_integer()|infinity).

-type(limit_time()::pos_integer()|infinity).

-type(key_cb_common_option()::{key_cb,Module::atom()|{Module::atom(),Opts::[term()]}}).

-type(disconnectfun_common_option()::{disconnectfun,fun((Reason::term()) -> void|any())}).

-type(unexpectedfun_common_option()::{unexpectedfun,fun((Message::term(),{Host::term(),Port::term()}) -> report|skip)}).

-type(ssh_msg_debug_fun_common_option()::{ssh_msg_debug_fun,fun((ssh:connection_ref(),AlwaysDisplay::boolean(),Msg::binary(),LanguageTag::binary()) -> any())}).

-type(id_string_common_option()::{id_string,string()|random|{random,Nmin::pos_integer(),Nmax::pos_integer()}}).

-type(pref_public_key_algs_common_option()::{pref_public_key_algs,[pubkey_alg()]}).

-type(preferred_algorithms_common_option()::{preferred_algorithms,algs_list()}).

-type(modify_algorithms_common_option()::{modify_algorithms,modify_algs_list()}).

-type(auth_methods_common_option()::{auth_methods,string()}).

-type(inet_common_option()::{inet,inet|inet6}).

-type(fd_common_option()::{fd,gen_tcp:socket()}).

-type(opaque_common_options()::{transport,{atom(),atom(),atom()}}|{vsn,{non_neg_integer(),non_neg_integer()}}|{tstflg,[term()]}|ssh_file:user_dir_fun_common_option()|{max_random_length_padding,non_neg_integer()}).

-type(client_option()::ssh_file:pubkey_passphrase_client_options()|host_accepting_client_options()|authentication_client_options()|diffie_hellman_group_exchange_client_option()|connect_timeout_client_option()|recv_ext_info_client_option()|opaque_client_options()|gen_tcp:connect_option()|common_option()).

-type(opaque_client_options()::{keyboard_interact_fun,fun((Name::iodata(),Instruction::iodata(),Prompts::[{Prompt::iodata(),Echo::boolean()}]) -> [Response::iodata()])}|opaque_common_options()).

-type(host_accepting_client_options()::{silently_accept_hosts,accept_hosts()}|{user_interaction,boolean()}|{save_accepted_host,boolean()}|{quiet_mode,boolean()}).

-type(accept_hosts()::boolean()|accept_callback()|{HashAlgoSpec::fp_digest_alg(),accept_callback()}).

-type(fp_digest_alg()::md5|crypto:sha1()|crypto:sha2()).

-type(accept_callback()::fun((PeerName::string(),fingerprint()) -> boolean())|fun((PeerName::string(),Port::inet:port_number(),fingerprint()) -> boolean())).

-type(fingerprint()::string()|[string()]).

-type(authentication_client_options()::{user,string()}|{password,string()}).

-type(diffie_hellman_group_exchange_client_option()::{dh_gex_limits,{Min::pos_integer(),I::pos_integer(),Max::pos_integer()}}).

-type(connect_timeout_client_option()::{connect_timeout,timeout()}).

-type(recv_ext_info_client_option()::{recv_ext_info,boolean()}).

-type(daemon_option()::subsystem_daemon_option()|shell_daemon_option()|exec_daemon_option()|ssh_cli_daemon_option()|tcpip_tunnel_out_daemon_option()|tcpip_tunnel_in_daemon_option()|authentication_daemon_options()|diffie_hellman_group_exchange_daemon_option()|negotiation_timeout_daemon_option()|hello_timeout_daemon_option()|hardening_daemon_options()|callbacks_daemon_options()|send_ext_info_daemon_option()|opaque_daemon_options()|gen_tcp:listen_option()|common_option()).

-type(subsystem_daemon_option()::{subsystems,subsystem_specs()}).

-type(subsystem_specs()::[subsystem_spec()]).

-type(shell_daemon_option()::{shell,shell_spec()}).

-type(shell_spec()::mod_fun_args()|shell_fun()|disabled).

-type(shell_fun()::shell_fun/1()|shell_fun/2()).

-type(shell_fun/1()::fun((User::string()) -> pid())).

-type(shell_fun/2()::fun((User::string(),PeerAddr::inet:ip_address()) -> pid())).

-type(exec_daemon_option()::{exec,exec_spec()}).

-type(exec_spec()::{direct,exec_fun()}|disabled|deprecated_exec_opt()).

-type(exec_fun()::exec_fun/1()|exec_fun/2()|exec_fun/3()).

-type(exec_fun/1()::fun((Cmd::string()) -> exec_result())).

-type(exec_fun/2()::fun((Cmd::string(),User::string()) -> exec_result())).

-type(exec_fun/3()::fun((Cmd::string(),User::string(),ClientAddr::ip_port()) -> exec_result())).

-type(exec_result()::{ok,Result::term()}|{error,Reason::term()}).

-type(deprecated_exec_opt()::fun()|mod_fun_args()).

-type(ssh_cli_daemon_option()::{ssh_cli,mod_args()|no_cli}).

-type(tcpip_tunnel_out_daemon_option()::{tcpip_tunnel_out,boolean()}).

-type(tcpip_tunnel_in_daemon_option()::{tcpip_tunnel_in,boolean()}).

-type(send_ext_info_daemon_option()::{send_ext_info,boolean()}).

-type(authentication_daemon_options()::ssh_file:system_dir_daemon_option()|{auth_method_kb_interactive_data,prompt_texts()}|{user_passwords,[{UserName::string(),Pwd::string()}]}|{pk_check_user,boolean()}|{password,string()}|{pwdfun,pwdfun_2()|pwdfun_4()}).

-type(prompt_texts()::kb_int_tuple()|kb_int_fun_3()|kb_int_fun_4()).

-type(kb_int_fun_3()::fun((Peer::ip_port(),User::string(),Service::string()) -> kb_int_tuple())).

-type(kb_int_fun_4()::fun((Peer::ip_port(),User::string(),Service::string(),State::any()) -> kb_int_tuple())).

-type(kb_int_tuple()::{Name::string(),Instruction::string(),Prompt::string(),Echo::boolean()}).

-type(pwdfun_2()::fun((User::string(),Password::string()|pubkey) -> boolean())).

-type(pwdfun_4()::fun((User::string(),Password::string()|pubkey,PeerAddress::ip_port(),State::any()) -> boolean()|disconnect|{boolean(),NewState::any()})).

-type(diffie_hellman_group_exchange_daemon_option()::{dh_gex_groups,[explicit_group()]|explicit_group_file()|ssh_moduli_file()}|{dh_gex_limits,{Min::pos_integer(),Max::pos_integer()}}).

-type(explicit_group()::{Size::pos_integer(),G::pos_integer(),P::pos_integer()}).

-type(explicit_group_file()::{file,string()}).

-type(ssh_moduli_file()::{ssh_moduli_file,string()}).

-type(negotiation_timeout_daemon_option()::{negotiation_timeout,timeout()}).

-type(hello_timeout_daemon_option()::{hello_timeout,timeout()}).

-type(hardening_daemon_options()::{max_sessions,pos_integer()}|{max_channels,pos_integer()}|{parallel_login,boolean()}|{minimal_remote_max_packet_size,pos_integer()}).

-type(callbacks_daemon_options()::{failfun,fun((User::string(),PeerAddress::inet:ip_address(),Reason::term()) -> _)}|{connectfun,fun((User::string(),PeerAddress::inet:ip_address(),Method::string()) -> _)}).

-type(opaque_daemon_options()::{infofun,fun()}|opaque_common_options()).

-type(ip_port()::{inet:ip_address(),inet:port_number()}).

-type(mod_args()::{Module::atom(),Args::list()}).

-type(mod_fun_args()::{Module::atom(),Function::atom(),Args::list()}).

-record(ssh,{role::client|role(),peer::undefined|{inet:hostname(),ip_port()},local,
c_vsn,
s_vsn,
c_version,
s_version,
c_keyinit,
s_keyinit,
send_ext_info,
recv_ext_info,
algorithms,
send_mac = none,
send_mac_key,
send_mac_size = 0,
recv_mac = none,
recv_mac_key,
recv_mac_size = 0,
encrypt = none,
encrypt_cipher,
encrypt_keys,
encrypt_block_size = 8,
encrypt_ctx,
decrypt = none,
decrypt_cipher,
decrypt_keys,
decrypt_block_size = 8,
decrypt_ctx,
compress = none,
compress_ctx,
decompress = none,
decompress_ctx,
c_lng = none,
s_lng = none,
user_ack = true,
timeout = infinity,
shared_secret,
exchanged_hash,
session_id,
opts = [],
send_sequence = 0,
recv_sequence = 0,
keyex_key,
keyex_info,
random_length_padding = 15,
user,
service,
userauth_quiet_mode,
userauth_methods,
userauth_supported_methods,
userauth_pubkeys,
kb_tries_left = 0,
userauth_preference,
available_host_keys,
pwdfun_user_state,
authenticated = false}).

-record(alg, {kex,hkey,send_mac,recv_mac,encrypt,decrypt,compress,decompress,c_lng,s_lng,send_ext_info,recv_ext_info}).

-record(ssh_pty, {c_version = "",term = "",width = 80,height = 25,pixel_width = 1024,pixel_height = 768,modes = <<>>}).

-record(circ_buf_entry, {module,line,function,pid = self(),value}).

-file("ssh_acceptor.erl", 26).

-export([start_link/4, number_of_connections/1, listen/2, handle_established_connection/4]).

-export([acceptor_init/5, acceptor_loop/6]).

-behaviour(ssh_dbg).

-export([ssh_dbg_trace_points/0, ssh_dbg_flags/1, ssh_dbg_on/1, ssh_dbg_off/1, ssh_dbg_format/2]).

start_link(Port,Address,Options,AcceptTimeout) ->
    Args = [self(), Port, Address, Options, AcceptTimeout],
    proc_lib:start_link(ssh_acceptor,acceptor_init,Args).

number_of_connections(SysSup) ->
    length([S || S <- supervisor:which_children(SysSup),has_worker(SysSup,S)]).

has_worker(SysSup,{R,SubSysSup,supervisor,[ssh_subsystem_sup]})
    when is_reference(R),
    is_pid(SubSysSup)->
    try {{server,ssh_connection_sup,_,_},Pid,supervisor,[ssh_connection_sup]} = lists:keyfind([ssh_connection_sup],4,supervisor:which_children(SubSysSup)),
    {Pid,supervisor:which_children(Pid)} of 
        {ConnSup,[]}->
            spawn(fun ()->
                timer:sleep(10),
                try supervisor:which_children(ConnSup) of 
                    []->
                        ssh_system_sup:stop_subsystem(SysSup,SubSysSup);
                    [_]->
                        ok;
                    _->
                        error
                    catch
                        _:_->
                            error end end),
            false;
        {_ConnSup,[_]}->
            true;
        _->
            false
        catch
            _:_->
                false end;
has_worker(_,_) ->
    false.

listen(Port,Options) ->
    {_,Callback,_} = ssh_options:get_value(user_options,transport,Options,ssh_acceptor,102),
    SockOpts = [{active,false}, {reuseaddr,true}| ssh_options:get_value(user_options,socket_options,Options,ssh_acceptor,103)],
    case Callback:listen(Port,SockOpts) of
        {error,nxdomain}->
            Callback:listen(Port,lists:delete(inet6,SockOpts));
        {error,enetunreach}->
            Callback:listen(Port,lists:delete(inet6,SockOpts));
        {error,eafnosupport}->
            Callback:listen(Port,lists:delete(inet6,SockOpts));
        Other->
            Other
    end.

handle_established_connection(Address,Port,Options,Socket) ->
    {_,Callback,_} = ssh_options:get_value(user_options,transport,Options,ssh_acceptor,117),
    handle_connection(Callback,Address,Port,Options,Socket).

acceptor_init(Parent,Port,Address,Opts,AcceptTimeout) ->
    try ssh_options:get_value(internal_options,lsocket,Opts,ssh_acceptor,125) of 
        {LSock,SockOwner}->
            case inet:sockname(LSock) of
                {ok,{_,Port}}->
                    proc_lib:init_ack(Parent,{ok,self()}),
                    request_ownership(LSock,SockOwner),
                    {_,Callback,_} = ssh_options:get_value(user_options,transport,Opts,ssh_acceptor,132),
                    acceptor_loop(Callback,Port,Address,Opts,LSock,AcceptTimeout);
                {error,_}->
                    {ok,NewLSock} = try_listen(Port,Opts,4),
                    proc_lib:init_ack(Parent,{ok,self()}),
                    Opts1 = ssh_options:delete_key(internal_options,lsocket,Opts,ssh_acceptor,139),
                    {_,Callback,_} = ssh_options:get_value(user_options,transport,Opts1,ssh_acceptor,140),
                    acceptor_loop(Callback,Port,Address,Opts1,NewLSock,AcceptTimeout)
            end
        catch
            _:_->
                {error,use_existing_socket_failed} end.

try_listen(Port,Opts,NtriesLeft) ->
    try_listen(Port,Opts,1,NtriesLeft).

try_listen(Port,Opts,N,Nmax) ->
    case listen(Port,Opts) of
        {error,eaddrinuse}
            when N < Nmax->
            timer:sleep(10 * N),
            try_listen(Port,Opts,N + 1,Nmax);
        Other->
            Other
    end.

request_ownership(LSock,SockOwner) ->
    SockOwner ! {request_control,LSock,self()},
    receive {its_yours,LSock}->
        ok end.

acceptor_loop(Callback,Port,Address,Opts,ListenSocket,AcceptTimeout) ->
    case  catch Callback:accept(ListenSocket,AcceptTimeout) of
        {ok,Socket}->
            handle_connection(Callback,Address,Port,Opts,Socket),
            ssh_acceptor:acceptor_loop(Callback,Port,Address,Opts,ListenSocket,AcceptTimeout);
        {error,Reason}->
            handle_error(Reason),
            ssh_acceptor:acceptor_loop(Callback,Port,Address,Opts,ListenSocket,AcceptTimeout);
        {'EXIT',Reason}->
            handle_error(Reason),
            ssh_acceptor:acceptor_loop(Callback,Port,Address,Opts,ListenSocket,AcceptTimeout)
    end.

handle_connection(Callback,Address,Port,Options,Socket) ->
    Profile = ssh_options:get_value(user_options,profile,Options,ssh_acceptor,187),
    SystemSup = ssh_system_sup:system_supervisor(Address,Port,Profile),
    MaxSessions = ssh_options:get_value(user_options,max_sessions,Options,ssh_acceptor,190),
    case number_of_connections(SystemSup) < MaxSessions of
        true->
            {ok,SubSysSup} = ssh_system_sup:start_subsystem(SystemSup,server,Address,Port,Profile,Options),
            ConnectionSup = ssh_subsystem_sup:connection_supervisor(SubSysSup),
            NegTimeout = ssh_options:get_value(user_options,negotiation_timeout,Options,ssh_acceptor,196),
            ssh_connection_handler:start_connection(server,Socket,ssh_options:put_value(internal_options,{supervisors,[{system_sup,SystemSup}, {subsystem_sup,SubSysSup}, {connection_sup,ConnectionSup}]},Options,ssh_acceptor,202),NegTimeout);
        false->
            Callback:close(Socket),
            IPstr = if is_tuple(Address) ->
                inet:ntoa(Address);true ->
                Address end,
            Str = try io_lib:format('~s:~p',[IPstr, Port])
                catch
                    _:_->
                        "port " ++ integer_to_list(Port) end,
            error_logger:info_report("Ssh login attempt to " ++ Str ++ " denied due to option max_session" "s limits to " ++ io_lib:write(MaxSessions) ++ " sessions."),
            {error,max_sessions}
    end.

handle_error(timeout) ->
    ok;
handle_error(enfile) ->
    timer:sleep(200);
handle_error(emfile) ->
    timer:sleep(200);
handle_error(closed) ->
    error_logger:info_report("The ssh accept socket was closed by a thi" "rd party. This will not have an impact on" " ssh that will open a new accept socket a" "nd go on as nothing happened. It does how" "ever indicate that some other software is" " behaving badly."),
    exit(normal);
handle_error(Reason) ->
    String = lists:flatten(io_lib:format("Accept error: ~p",[Reason])),
    error_logger:error_report(String),
    exit({accept_failed,String}).

ssh_dbg_trace_points() ->
    [connections].

ssh_dbg_flags(connections) ->
    [c].

ssh_dbg_on(connections) ->
    dbg:tp(ssh_acceptor,acceptor_init,5,x),
    dbg:tpl(ssh_acceptor,handle_connection,5,x).

ssh_dbg_off(connections) ->
    dbg:ctp(ssh_acceptor,acceptor_init,5),
    dbg:ctp(ssh_acceptor,handle_connection,5).

ssh_dbg_format(connections,{call,{ssh_acceptor,acceptor_init,[_Parent, Port, Address, _Opts, _AcceptTimeout]}}) ->
    [io_lib:format("Starting LISTENER on ~s:~p\n",[ntoa(Address), Port])];
ssh_dbg_format(connections,{return_from,{ssh_acceptor,acceptor_init,5},_Ret}) ->
    skip;
ssh_dbg_format(connections,{call,{ssh_acceptor,handle_connection,[_, _, _, _, _]}}) ->
    skip;
ssh_dbg_format(connections,{return_from,{ssh_acceptor,handle_connection,5},{error,Error}}) ->
    ["Starting connection to server failed:\n", io_lib:format("Error = ~p",[Error])].

ntoa(A) ->
    try inet:ntoa(A)
        catch
            _:_
                when is_list(A)->
                A;
            _:_->
                io_lib:format('~p',[A]) end.
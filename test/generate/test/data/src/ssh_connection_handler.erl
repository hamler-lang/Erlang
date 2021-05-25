-file("ssh_connection_handler.erl", 1).

-module(ssh_connection_handler).

-behaviour(gen_statem).

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

-file("ssh_connection_handler.erl", 34).

-file("ssh_transport.hrl", 1).

-record(ssh_msg_disconnect, {code,description,language}).

-record(ssh_msg_ignore, {data}).

-record(ssh_msg_unimplemented, {sequence}).

-record(ssh_msg_debug, {always_display,message,language}).

-record(ssh_msg_service_request, {name}).

-record(ssh_msg_service_accept, {name}).

-record(ssh_msg_ext_info, {nr_extensions,data}).

-record(ssh_msg_kexinit, {cookie,kex_algorithms,server_host_key_algorithms,encryption_algorithms_client_to_server,encryption_algorithms_server_to_client,mac_algorithms_client_to_server,mac_algorithms_server_to_client,compression_algorithms_client_to_server,compression_algorithms_server_to_client,languages_client_to_server,languages_server_to_client,first_kex_packet_follows = false,reserved = 0}).

-record(ssh_msg_kexdh_init, {e}).

-record(ssh_msg_kexdh_reply, {public_host_key,f,h_sig}).

-record(ssh_msg_newkeys, {}).

-record(ssh_msg_kex_dh_gex_request, {min,n,max}).

-record(ssh_msg_kex_dh_gex_request_old, {n}).

-record(ssh_msg_kex_dh_gex_group, {p,g}).

-record(ssh_msg_kex_dh_gex_init, {e}).

-record(ssh_msg_kex_dh_gex_reply, {public_host_key,f,h_sig}).

-record(ssh_msg_kex_ecdh_init, {q_c}).

-record(ssh_msg_kex_ecdh_reply, {public_host_key,q_s,h_sig}).

-file("ssh_connection_handler.erl", 35).

-file("ssh_auth.hrl", 1).

-record(ssh_msg_userauth_request, {user,service,method,data}).

-record(ssh_msg_userauth_failure, {authentications,partial_success}).

-record(ssh_msg_userauth_success, {}).

-record(ssh_msg_userauth_banner, {message,language}).

-record(ssh_msg_userauth_passwd_changereq, {prompt,languge}).

-record(ssh_msg_userauth_pk_ok, {algorithm_name,key_blob}).

-record(ssh_msg_userauth_info_request, {name,instruction,language_tag,num_prompts,data}).

-record(ssh_msg_userauth_info_response, {num_responses,data}).

-file("ssh_connection_handler.erl", 36).

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

-file("ssh_connection_handler.erl", 37).

-export([start_link/3, stop/1]).

-export([start_connection/4, available_hkey_algorithms/2, open_channel/6, start_channel/5, handle_direct_tcpip/6, request/6, request/7, reply_request/3, global_request/5, send/5, send_eof/2, store/3, retrieve/2, info/1, info/2, connection_info/2, channel_info/3, adjust_window/3, close/2, disconnect/4, get_print_info/1, set_sock_opts/2, get_sock_opts/2, prohibited_sock_option/1]).

-type(connection_ref()::ssh:connection_ref()).

-type(channel_id()::ssh:channel_id()).

-export([init/1, callback_mode/0, handle_event/4, terminate/3, format_status/2, code_change/4]).

-export([init_connection_handler/3, init_ssh_record/3, renegotiate/1, alg/1]).

-behaviour(ssh_dbg).

-export([ssh_dbg_trace_points/0, ssh_dbg_flags/1, ssh_dbg_on/1, ssh_dbg_off/1, ssh_dbg_format/2]).

-spec(start_link(role(),gen_tcp:socket(),internal_options()) -> {ok,pid()}).

start_link(Role,Socket,Options) ->
    {ok,proc_lib:spawn_opt(ssh_connection_handler,init_connection_handler,[Role, Socket, Options],[link, {message_queue_data,off_heap}])}.

-spec(stop(connection_ref()) -> ok|{error,term()}).

stop(ConnectionHandler) ->
    case call(ConnectionHandler,stop) of
        {error,closed}->
            ok;
        Other->
            Other
    end.

-spec(start_connection(role(),gen_tcp:socket(),internal_options(),timeout()) -> {ok,connection_ref()}|{error,term()}).

start_connection(Role,Socket,Options,Timeout) ->
    try case Role of
        client->
            ChildPid = start_the_connection_child(self(),Role,Socket,Options),
            handshake(ChildPid,monitor(process,ChildPid),Timeout);
        server->
            case ssh_options:get_value(user_options,parallel_login,Options,ssh_connection_handler,144) of
                true->
                    HandshakerPid = spawn_link(fun ()->
                        receive {do_handshake,Pid}->
                            handshake(Pid,monitor(process,Pid),Timeout) end end),
                    ChildPid = start_the_connection_child(HandshakerPid,Role,Socket,Options),
                    HandshakerPid ! {do_handshake,ChildPid};
                false->
                    ChildPid = start_the_connection_child(self(),Role,Socket,Options),
                    handshake(ChildPid,monitor(process,ChildPid),Timeout)
            end
    end
        catch
            exit:{noproc,_}->
                {error,ssh_not_started};
            _:Error->
                {error,Error} end.

-spec(disconnect(Code::integer(),Details::iodata(),Module::atom(),Line::integer()) -> no_return()).

disconnect(Code,DetailedText,Module,Line) ->
    throw({keep_state_and_data,[{next_event,internal,{send_disconnect,Code,DetailedText,Module,Line}}]}).

-spec(open_channel(connection_ref(),string(),iodata(),pos_integer(),pos_integer(),timeout()) -> {open,channel_id()}|{error,term()}).

open_channel(ConnectionHandler,ChannelType,ChannelSpecificData,InitialWindowSize,MaxPacketSize,Timeout) ->
    call(ConnectionHandler,{open,self(),ChannelType,InitialWindowSize,MaxPacketSize,ChannelSpecificData,Timeout}).

-spec(start_channel(connection_ref(),atom(),channel_id(),list(),term()) -> {ok,pid()}|{error,term()}).

start_channel(ConnectionHandler,CallbackModule,ChannelId,Args,Exec) ->
    {ok,{SubSysSup,Role,Opts}} = call(ConnectionHandler,get_misc),
    ssh_subsystem_sup:start_channel(Role,SubSysSup,ConnectionHandler,CallbackModule,ChannelId,Args,Exec,Opts).

handle_direct_tcpip(ConnectionHandler,ListenHost,ListenPort,ConnectToHost,ConnectToPort,Timeout) ->
    call(ConnectionHandler,{handle_direct_tcpip,ListenHost,ListenPort,ConnectToHost,ConnectToPort,Timeout}).

-spec(request(connection_ref(),pid(),channel_id(),string(),boolean(),iodata(),timeout()) -> success|failure|ok|{error,timeout}).

-spec(request(connection_ref(),channel_id(),string(),boolean(),iodata(),timeout()) -> success|failure|ok|{error,timeout}).

request(ConnectionHandler,ChannelPid,ChannelId,Type,true,Data,Timeout) ->
    call(ConnectionHandler,{request,ChannelPid,ChannelId,Type,Data,Timeout});
request(ConnectionHandler,ChannelPid,ChannelId,Type,false,Data,_) ->
    cast(ConnectionHandler,{request,ChannelPid,ChannelId,Type,Data}).

request(ConnectionHandler,ChannelId,Type,true,Data,Timeout) ->
    call(ConnectionHandler,{request,ChannelId,Type,Data,Timeout});
request(ConnectionHandler,ChannelId,Type,false,Data,_) ->
    cast(ConnectionHandler,{request,ChannelId,Type,Data}).

-spec(reply_request(connection_ref(),success|failure,channel_id()) -> ok).

reply_request(ConnectionHandler,Status,ChannelId) ->
    cast(ConnectionHandler,{reply_request,Status,ChannelId}).

global_request(ConnectionHandler,Type,true,Data,Timeout) ->
    call(ConnectionHandler,{global_request,Type,Data,Timeout});
global_request(ConnectionHandler,Type,false,Data,_) ->
    cast(ConnectionHandler,{global_request,Type,Data}).

-spec(send(connection_ref(),channel_id(),non_neg_integer(),iodata(),timeout()) -> ok|{error,timeout|closed}).

send(ConnectionHandler,ChannelId,Type,Data,Timeout) ->
    call(ConnectionHandler,{data,ChannelId,Type,Data,Timeout}).

-spec(send_eof(connection_ref(),channel_id()) -> ok|{error,closed}).

send_eof(ConnectionHandler,ChannelId) ->
    call(ConnectionHandler,{eof,ChannelId}).

-spec(info(connection_ref()) -> {ok,[#channel{}]}).

-spec(info(connection_ref(),pid()|all) -> {ok,[#channel{}]}).

info(ConnectionHandler) ->
    info(ConnectionHandler,all).

info(ConnectionHandler,ChannelProcess) ->
    call(ConnectionHandler,{info,ChannelProcess}).

-type(local_sock_info()::{inet:ip_address(),non_neg_integer()}|string()).

-type(peer_sock_info()::{inet:ip_address(),non_neg_integer()}|string()).

-type(state_info()::iolist()).

-spec(get_print_info(connection_ref()) -> {{local_sock_info(),peer_sock_info()},state_info()}).

get_print_info(ConnectionHandler) ->
    call(ConnectionHandler,get_print_info,1000).

connection_info(ConnectionHandler,[]) ->
    connection_info(ConnectionHandler,conn_info_keys());
connection_info(ConnectionHandler,Key)
    when is_atom(Key)->
    case connection_info(ConnectionHandler,[Key]) of
        [{Key,Val}]->
            {Key,Val};
        Other->
            Other
    end;
connection_info(ConnectionHandler,Options) ->
    call(ConnectionHandler,{connection_info,Options}).

-spec(channel_info(connection_ref(),channel_id(),[atom()]) -> proplists:proplist()).

channel_info(ConnectionHandler,ChannelId,Options) ->
    call(ConnectionHandler,{channel_info,ChannelId,Options}).

-spec(adjust_window(connection_ref(),channel_id(),integer()) -> ok).

adjust_window(ConnectionHandler,Channel,Bytes) ->
    cast(ConnectionHandler,{adjust_window,Channel,Bytes}).

-spec(close(connection_ref(),channel_id()) -> ok).

close(ConnectionHandler,ChannelId) ->
    case call(ConnectionHandler,{close,ChannelId}) of
        ok->
            ok;
        {error,closed}->
            ok
    end.

store(ConnectionHandler,Key,Value) ->
    cast(ConnectionHandler,{store,Key,Value}).

retrieve(#connection{options = Opts},Key) ->
    try ssh_options:get_value(internal_options,Key,Opts,ssh_connection_handler,355) of 
        Value->
            {ok,Value}
        catch
            error:{badkey,Key}->
                undefined end;
retrieve(ConnectionHandler,Key) ->
    call(ConnectionHandler,{retrieve,Key}).

set_sock_opts(ConnectionRef,SocketOptions) ->
    try lists:foldr(fun ({Name,_Val},Acc)->
        case prohibited_sock_option(Name) of
            true->
                [Name| Acc];
            false->
                Acc
        end end,[],SocketOptions) of 
        []->
            call(ConnectionRef,{set_sock_opts,SocketOptions});
        Bad->
            {error,{not_allowed,Bad}}
        catch
            _:_->
                {error,badarg} end.

prohibited_sock_option(active) ->
    true;
prohibited_sock_option(deliver) ->
    true;
prohibited_sock_option(mode) ->
    true;
prohibited_sock_option(packet) ->
    true;
prohibited_sock_option(_) ->
    false.

get_sock_opts(ConnectionRef,SocketGetOptions) ->
    call(ConnectionRef,{get_sock_opts,SocketGetOptions}).

-spec(renegotiate(connection_ref()) -> ok).

renegotiate(ConnectionHandler) ->
    cast(ConnectionHandler,force_renegotiate).

alg(ConnectionHandler) ->
    call(ConnectionHandler,get_alg).

-record(data,{starter::pid()|undefined,auth_user::string()|undefined,connection_state::#connection{}|undefined,latest_channel_id = 0::non_neg_integer()|undefined,transport_protocol::atom()|undefined,transport_cb::atom()|undefined,transport_close_tag::atom()|undefined,ssh_params::#ssh{}|undefined,socket::gen_tcp:socket()|undefined,decrypted_data_buffer = <<>>::binary()|undefined,encrypted_data_buffer = <<>>::binary()|undefined,aead_data = <<>>::binary()|undefined,undecrypted_packet_length::undefined|non_neg_integer(),key_exchange_init_msg::#ssh_msg_kexinit{}|undefined,last_size_rekey = 0::non_neg_integer(),event_queue = []::list(),inet_initial_recbuf_size::pos_integer()|undefined}).

-spec(init_connection_handler(role(),gen_tcp:socket(),internal_options()) -> no_return()).

init_connection_handler(Role,Socket,Opts) ->
    case init([Role, Socket, Opts]) of
        {ok,StartState,D}
            when Role == server->
            process_flag(trap_exit,true),
            gen_statem:enter_loop(ssh_connection_handler,[],StartState,D);
        {ok,StartState,D0 = #data{connection_state = C}}
            when Role == client->
            process_flag(trap_exit,true),
            Sups = ssh_options:get_value(internal_options,supervisors,Opts,ssh_connection_handler,466),
            D = D0#data{connection_state = C#connection{system_supervisor = proplists:get_value(system_sup,Sups),sub_system_supervisor = proplists:get_value(subsystem_sup,Sups),connection_supervisor = proplists:get_value(connection_sup,Sups)}},
            gen_statem:enter_loop(ssh_connection_handler,[],StartState,D);
        {stop,Error}->
            D = try Sups = ssh_options:get_value(internal_options,supervisors,Opts,ssh_connection_handler,480),
            #connection{system_supervisor = proplists:get_value(system_sup,Sups),sub_system_supervisor = proplists:get_value(subsystem_sup,Sups),connection_supervisor = proplists:get_value(connection_sup,Sups)} of 
                C->
                    #data{connection_state = C}
                catch
                    _:_->
                        #data{connection_state = #connection{}} end,
            gen_statem:enter_loop(ssh_connection_handler,[],{init_error,Error},D#data{socket = Socket})
    end.

init([Role, Socket, Opts]) ->
    case inet:peername(Socket) of
        {ok,PeerAddr}->
            {Protocol,Callback,CloseTag} = ssh_options:get_value(user_options,transport,Opts,ssh_connection_handler,503),
            C = #connection{channel_cache = ssh_client_channel:cache_create(),channel_id_seed = 0,requests = [],options = Opts},
            D0 = #data{starter = ssh_options:get_value(internal_options,user_pid,Opts,ssh_connection_handler,508),connection_state = C,socket = Socket,transport_protocol = Protocol,transport_cb = Callback,transport_close_tag = CloseTag,ssh_params = init_ssh_record(Role,Socket,PeerAddr,Opts)},
            D = case Role of
                client->
                    D0;
                server->
                    Sups = ssh_options:get_value(internal_options,supervisors,Opts,ssh_connection_handler,520),
                    D0#data{connection_state = C#connection{cli_spec = ssh_options:get_value(user_options,ssh_cli,Opts,fun ()->
                        {ssh_cli,[ssh_options:get_value(user_options,shell,Opts,ssh_connection_handler,522)]} end,ssh_connection_handler,522),exec = ssh_options:get_value(user_options,exec,Opts,ssh_connection_handler,523),system_supervisor = proplists:get_value(system_sup,Sups),sub_system_supervisor = proplists:get_value(subsystem_sup,Sups),connection_supervisor = proplists:get_value(connection_sup,Sups)}}
            end,
            {ok,{hello,Role},D};
        {error,Error}->
            {stop,Error}
    end.

init_ssh_record(Role,Socket,Opts) ->
    {ok,PeerAddr} = inet:peername(Socket),
    init_ssh_record(Role,Socket,PeerAddr,Opts).

init_ssh_record(Role,Socket,PeerAddr,Opts) ->
    AuthMethods = ssh_options:get_value(user_options,auth_methods,Opts,ssh_connection_handler,544),
    S0 = #ssh{role = Role,opts = Opts,userauth_supported_methods = AuthMethods,available_host_keys = available_hkey_algorithms(Role,Opts),random_length_padding = ssh_options:get_value(user_options,max_random_length_padding,Opts,ssh_connection_handler,549)},
    {Vsn,Version} = ssh_transport:versions(Role,Opts),
    LocalName = case inet:sockname(Socket) of
        {ok,Local}->
            Local;
        _->
            undefined
    end,
    case Role of
        client->
            PeerName = case ssh_options:get_value(internal_options,host,Opts,fun ()->
                element(1,PeerAddr) end,ssh_connection_handler,559) of
                PeerIP
                    when is_tuple(PeerIP)->
                    inet_parse:ntoa(PeerIP);
                PeerName0
                    when is_atom(PeerName0)->
                    atom_to_list(PeerName0);
                PeerName0
                    when is_list(PeerName0)->
                    PeerName0
            end,
            S1 = S0#ssh{c_vsn = Vsn,c_version = Version,opts = ssh_options:put_value(internal_options,{io_cb,case ssh_options:get_value(user_options,user_interaction,Opts,ssh_connection_handler,570) of
                true->
                    ssh_io;
                false->
                    ssh_no_io
            end},Opts,ssh_connection_handler,574),userauth_quiet_mode = ssh_options:get_value(user_options,quiet_mode,Opts,ssh_connection_handler,575),peer = {PeerName,PeerAddr},local = LocalName},
            S1#ssh{userauth_pubkeys = [K || K <- ssh_options:get_value(user_options,pref_public_key_algs,Opts,ssh_connection_handler,579),is_usable_user_pubkey(K,S1)]};
        server->
            S0#ssh{s_vsn = Vsn,s_version = Version,userauth_methods = string:tokens(AuthMethods,","),kb_tries_left = 3,peer = {undefined,PeerAddr},local = LocalName}
    end.

-type(event_content()::any()).

-type(renegotiate_flag()::init|renegotiate).

-type(state_name()::{hello,role()}|{kexinit,role(),renegotiate_flag()}|{key_exchange,role(),renegotiate_flag()}|{key_exchange_dh_gex_init,server,renegotiate_flag()}|{key_exchange_dh_gex_reply,client,renegotiate_flag()}|{new_keys,role(),renegotiate_flag()}|{ext_info,role(),renegotiate_flag()}|{service_request,role()}|{userauth,role()}|{userauth_keyboard_interactive,role()}|{userauth_keyboard_interactive_extra,server}|{userauth_keyboard_interactive_info_response,client}|{connected,role()}).

-spec(role(state_name()) -> role()).

role({_,Role}) ->
    Role;
role({_,Role,_}) ->
    Role.

-spec(renegotiation(state_name()) -> boolean()).

renegotiation({_,_,ReNeg}) ->
    ReNeg == renegotiate;
renegotiation(_) ->
    false.

-spec(handle_event(gen_statem:event_type(),event_content(),state_name(),#data{}) -> gen_statem:event_handler_result(state_name())).

callback_mode() ->
    [handle_event_function, state_enter].

handle_event(_,_Event,{init_error,Error} = StateName,D) ->
    case Error of
        enotconn->
            call_disconnectfun_and_log_cond("Protocol Error","TCP connenction to server " "was prematurely closed by " "the client",ssh_connection_handler,662,StateName,D),
            {stop,{shutdown,"TCP connenction to server was prematurely closed by the " "client"}};
        OtherError->
            {stop,{shutdown,{init,OtherError}}}
    end;
handle_event(_,socket_control,{hello,_} = StateName,#data{ssh_params = Ssh0} = D) ->
    VsnMsg = ssh_transport:hello_version_msg(string_version(Ssh0)),
    send_bytes(VsnMsg,D),
    case inet:getopts(Socket = D#data.socket,[recbuf]) of
        {ok,[{recbuf,Size}]}->
            inet:setopts(Socket,[{packet,line}, {active,once}, {recbuf,255}, {nodelay,true}]),
            Time = ssh_options:get_value(user_options,hello_timeout,Ssh0#ssh.opts,fun ()->
                infinity end,ssh_connection_handler,684),
            {keep_state,D#data{inet_initial_recbuf_size = Size},[{state_timeout,Time,no_hello_received}]};
        Other->
            call_disconnectfun_and_log_cond("Option return",io_lib:format("Unexpected g" "etopts retur" "n:~n  ~p",[Other]),ssh_connection_handler,689,StateName,D),
            {stop,{shutdown,{unexpected_getopts_return,Other}}}
    end;
handle_event(_,{info_line,Line},{hello,Role} = StateName,D) ->
    case Role of
        client->
            inet:setopts(D#data.socket,[{active,once}]),
            keep_state_and_data;
        server->
            send_bytes("Protocol mismatch.",D),
            Msg = io_lib:format("Protocol mismatch in version exchange. C" "lient sent info lines.~n~s",[ssh_dbg:hex_dump(Line,64)]),
            call_disconnectfun_and_log_cond("Protocol mismatch.",Msg,ssh_connection_handler,707,StateName,D),
            {stop,{shutdown,"Protocol mismatch in version exchange. Client sent info " "lines."}}
    end;
handle_event(_,{version_exchange,Version},{hello,Role},D0) ->
    {NumVsn,StrVsn} = ssh_transport:handle_hello_version(Version),
    case handle_version(NumVsn,StrVsn,D0#data.ssh_params) of
        {ok,Ssh1}->
            inet:setopts(D0#data.socket,[{packet,0}, {mode,binary}, {active,once}, {recbuf,D0#data.inet_initial_recbuf_size}]),
            {KeyInitMsg,SshPacket,Ssh} = ssh_transport:key_exchange_init_msg(Ssh1),
            send_bytes(SshPacket,D0),
            {next_state,{kexinit,Role,init},D0#data{ssh_params = Ssh,key_exchange_init_msg = KeyInitMsg}};
        not_supported->
            {Shutdown,D} = send_disconnect(8,io_lib:format("Offending version is ~p",[string:chomp(Version)]),ssh_connection_handler,728,{hello,Role},D0),
            {stop,Shutdown,D}
    end;
handle_event(_,no_hello_received,{hello,_Role} = StateName,D0) ->
    {Shutdown,D} = send_disconnect(2,"No HELLO recieved",ssh_connection_handler,736,StateName,D0),
    {stop,Shutdown,D};
handle_event(_,{#ssh_msg_kexinit{} = Kex,Payload},{kexinit,Role,ReNeg},D = #data{key_exchange_init_msg = OwnKex}) ->
    Ssh1 = ssh_transport:key_init(peer_role(Role),D#data.ssh_params,Payload),
    Ssh = case ssh_transport:handle_kexinit_msg(Kex,OwnKex,Ssh1) of
        {ok,NextKexMsg,Ssh2}
            when Role == client->
            send_bytes(NextKexMsg,D),
            Ssh2;
        {ok,Ssh2}
            when Role == server->
            Ssh2
    end,
    {next_state,{key_exchange,Role,ReNeg},D#data{ssh_params = Ssh}};
handle_event(_,#ssh_msg_kexdh_init{} = Msg,{key_exchange,server,ReNeg},D) ->
    {ok,KexdhReply,Ssh1} = ssh_transport:handle_kexdh_init(Msg,D#data.ssh_params),
    send_bytes(KexdhReply,D),
    {ok,NewKeys,Ssh2} = ssh_transport:new_keys_message(Ssh1),
    send_bytes(NewKeys,D),
    {ok,ExtInfo,Ssh} = ssh_transport:ext_info_message(Ssh2),
    send_bytes(ExtInfo,D),
    {next_state,{new_keys,server,ReNeg},D#data{ssh_params = Ssh}};
handle_event(_,#ssh_msg_kexdh_reply{} = Msg,{key_exchange,client,ReNeg},D) ->
    {ok,NewKeys,Ssh1} = ssh_transport:handle_kexdh_reply(Msg,D#data.ssh_params),
    send_bytes(NewKeys,D),
    {ok,ExtInfo,Ssh} = ssh_transport:ext_info_message(Ssh1),
    send_bytes(ExtInfo,D),
    {next_state,{new_keys,client,ReNeg},D#data{ssh_params = Ssh}};
handle_event(_,#ssh_msg_kex_dh_gex_request{} = Msg,{key_exchange,server,ReNeg},D) ->
    {ok,GexGroup,Ssh1} = ssh_transport:handle_kex_dh_gex_request(Msg,D#data.ssh_params),
    send_bytes(GexGroup,D),
    Ssh = ssh_transport:parallell_gen_key(Ssh1),
    {next_state,{key_exchange_dh_gex_init,server,ReNeg},D#data{ssh_params = Ssh}};
handle_event(_,#ssh_msg_kex_dh_gex_request_old{} = Msg,{key_exchange,server,ReNeg},D) ->
    {ok,GexGroup,Ssh1} = ssh_transport:handle_kex_dh_gex_request(Msg,D#data.ssh_params),
    send_bytes(GexGroup,D),
    Ssh = ssh_transport:parallell_gen_key(Ssh1),
    {next_state,{key_exchange_dh_gex_init,server,ReNeg},D#data{ssh_params = Ssh}};
handle_event(_,#ssh_msg_kex_dh_gex_group{} = Msg,{key_exchange,client,ReNeg},D) ->
    {ok,KexGexInit,Ssh} = ssh_transport:handle_kex_dh_gex_group(Msg,D#data.ssh_params),
    send_bytes(KexGexInit,D),
    {next_state,{key_exchange_dh_gex_reply,client,ReNeg},D#data{ssh_params = Ssh}};
handle_event(_,#ssh_msg_kex_ecdh_init{} = Msg,{key_exchange,server,ReNeg},D) ->
    {ok,KexEcdhReply,Ssh1} = ssh_transport:handle_kex_ecdh_init(Msg,D#data.ssh_params),
    send_bytes(KexEcdhReply,D),
    {ok,NewKeys,Ssh2} = ssh_transport:new_keys_message(Ssh1),
    send_bytes(NewKeys,D),
    {ok,ExtInfo,Ssh} = ssh_transport:ext_info_message(Ssh2),
    send_bytes(ExtInfo,D),
    {next_state,{new_keys,server,ReNeg},D#data{ssh_params = Ssh}};
handle_event(_,#ssh_msg_kex_ecdh_reply{} = Msg,{key_exchange,client,ReNeg},D) ->
    {ok,NewKeys,Ssh1} = ssh_transport:handle_kex_ecdh_reply(Msg,D#data.ssh_params),
    send_bytes(NewKeys,D),
    {ok,ExtInfo,Ssh} = ssh_transport:ext_info_message(Ssh1),
    send_bytes(ExtInfo,D),
    {next_state,{new_keys,client,ReNeg},D#data{ssh_params = Ssh}};
handle_event(_,#ssh_msg_kex_dh_gex_init{} = Msg,{key_exchange_dh_gex_init,server,ReNeg},D) ->
    {ok,KexGexReply,Ssh1} = ssh_transport:handle_kex_dh_gex_init(Msg,D#data.ssh_params),
    send_bytes(KexGexReply,D),
    {ok,NewKeys,Ssh2} = ssh_transport:new_keys_message(Ssh1),
    send_bytes(NewKeys,D),
    {ok,ExtInfo,Ssh} = ssh_transport:ext_info_message(Ssh2),
    send_bytes(ExtInfo,D),
    {next_state,{new_keys,server,ReNeg},D#data{ssh_params = Ssh}};
handle_event(_,#ssh_msg_kex_dh_gex_reply{} = Msg,{key_exchange_dh_gex_reply,client,ReNeg},D) ->
    {ok,NewKeys,Ssh1} = ssh_transport:handle_kex_dh_gex_reply(Msg,D#data.ssh_params),
    send_bytes(NewKeys,D),
    {ok,ExtInfo,Ssh} = ssh_transport:ext_info_message(Ssh1),
    send_bytes(ExtInfo,D),
    {next_state,{new_keys,client,ReNeg},D#data{ssh_params = Ssh}};
handle_event(_,#ssh_msg_newkeys{} = Msg,{new_keys,client,init},D0) ->
    {ok,Ssh1} = ssh_transport:handle_new_keys(Msg,D0#data.ssh_params),
    {MsgReq,Ssh} = ssh_auth:service_request_msg(Ssh1),
    D = send_msg(MsgReq,D0#data{ssh_params = Ssh}),
    {next_state,{ext_info,client,init},D};
handle_event(_,#ssh_msg_newkeys{} = Msg,{new_keys,server,init},D) ->
    {ok,Ssh} = ssh_transport:handle_new_keys(Msg,D#data.ssh_params),
    {next_state,{ext_info,server,init},D#data{ssh_params = Ssh}};
handle_event(_,#ssh_msg_newkeys{} = Msg,{new_keys,Role,renegotiate},D) ->
    {ok,Ssh} = ssh_transport:handle_new_keys(Msg,D#data.ssh_params),
    {next_state,{ext_info,Role,renegotiate},D#data{ssh_params = Ssh}};
handle_event(_,#ssh_msg_ext_info{} = Msg,{ext_info,Role,init},D0) ->
    D = handle_ssh_msg_ext_info(Msg,D0),
    {next_state,{service_request,Role},D};
handle_event(_,#ssh_msg_ext_info{} = Msg,{ext_info,Role,renegotiate},D0) ->
    D = handle_ssh_msg_ext_info(Msg,D0),
    {next_state,{connected,Role},D};
handle_event(_,#ssh_msg_newkeys{} = Msg,{ext_info,_Role,renegotiate},D) ->
    {ok,Ssh} = ssh_transport:handle_new_keys(Msg,D#data.ssh_params),
    {keep_state,D#data{ssh_params = Ssh}};
handle_event(internal,Msg,{ext_info,Role,init},D)
    when is_tuple(Msg)->
    {next_state,{service_request,Role},D,[postpone]};
handle_event(internal,Msg,{ext_info,Role,_ReNegFlag},D)
    when is_tuple(Msg)->
    {next_state,{connected,Role},D,[postpone]};
handle_event(_,Msg = #ssh_msg_service_request{name = ServiceName},StateName = {service_request,server},D0) ->
    case ServiceName of
        "ssh-userauth"->
            Ssh0 = #ssh{session_id = SessionId} = D0#data.ssh_params,
            {ok,{Reply,Ssh}} = ssh_auth:handle_userauth_request(Msg,SessionId,Ssh0),
            D = send_msg(Reply,D0#data{ssh_params = Ssh}),
            {next_state,{userauth,server},D};
        _->
            {Shutdown,D} = send_disconnect(7,io_lib:format("Unknown service: ~p",[ServiceName]),ssh_connection_handler,892,StateName,D0),
            {stop,Shutdown,D}
    end;
handle_event(_,#ssh_msg_service_accept{name = "ssh-userauth"},{service_request,client},#data{ssh_params = #ssh{service = "ssh-userauth"} = Ssh0} = D0) ->
    {Msg,Ssh} = ssh_auth:init_userauth_request_msg(Ssh0),
    D = send_msg(Msg,D0#data{ssh_params = Ssh,auth_user = Ssh#ssh.user}),
    {next_state,{userauth,client},D};
handle_event(_,Msg = #ssh_msg_userauth_request{service = ServiceName,method = Method},StateName = {userauth,server},D0 = #data{ssh_params = Ssh0}) ->
    case {ServiceName,Ssh0#ssh.service,Method} of
        {"ssh-connection","ssh-connection","none"}->
            {not_authorized,_,{Reply,Ssh}} = ssh_auth:handle_userauth_request(Msg,Ssh0#ssh.session_id,Ssh0),
            D = send_msg(Reply,D0#data{ssh_params = Ssh}),
            {keep_state,D};
        {"ssh-connection","ssh-connection",Method}->
            case lists:member(Method,Ssh0#ssh.userauth_methods) of
                true->
                    case ssh_auth:handle_userauth_request(Msg,Ssh0#ssh.session_id,Ssh0) of
                        {authorized,User,{Reply,Ssh1}}->
                            D = #data{ssh_params = Ssh} = send_msg(Reply,D0#data{ssh_params = Ssh1}),
                            D#data.starter ! ssh_connected,
                            connected_fun(User,Method,D),
                            {next_state,{connected,server},D#data{auth_user = User,ssh_params = Ssh#ssh{authenticated = true}}};
                        {not_authorized,{User,Reason},{Reply,Ssh}}
                            when Method == "keyboard-interactive"->
                            retry_fun(User,Reason,D0),
                            D = send_msg(Reply,D0#data{ssh_params = Ssh}),
                            {next_state,{userauth_keyboard_interactive,server},D};
                        {not_authorized,{User,Reason},{Reply,Ssh}}->
                            retry_fun(User,Reason,D0),
                            D = send_msg(Reply,D0#data{ssh_params = Ssh}),
                            {keep_state,D}
                    end;
                false->
                    {keep_state_and_data,[{next_event,internal,Msg#ssh_msg_userauth_request{method = "none"}}]}
            end;
        {ServiceName,_,_}
            when ServiceName =/= "ssh-connection"->
            {Shutdown,D} = send_disconnect(7,io_lib:format("Unknown service: ~p",[ServiceName]),ssh_connection_handler,961,StateName,D0),
            {stop,Shutdown,D}
    end;
handle_event(_,#ssh_msg_ext_info{} = Msg,{userauth,client},D0) ->
    D = handle_ssh_msg_ext_info(Msg,D0),
    {keep_state,D};
handle_event(_,#ssh_msg_userauth_success{},{userauth,client},D = #data{ssh_params = Ssh}) ->
    ssh_auth:ssh_msg_userauth_result(success),
    D#data.starter ! ssh_connected,
    {next_state,{connected,client},D#data{ssh_params = Ssh#ssh{authenticated = true}}};
handle_event(_,#ssh_msg_userauth_failure{},{userauth,client} = StateName,#data{ssh_params = #ssh{userauth_methods = []}} = D0) ->
    {Shutdown,D} = send_disconnect(14,io_lib:format("User auth failed for: ~p",[D0#data.auth_user]),ssh_connection_handler,983,StateName,D0),
    {stop,Shutdown,D};
handle_event(_,#ssh_msg_userauth_failure{authentications = Methods},StateName = {userauth,client},D0 = #data{ssh_params = Ssh0}) ->
    Ssh1 = case Ssh0#ssh.userauth_methods of
        none->
            Ssh0#ssh{userauth_methods = string:tokens(Methods,",")};
        _->
            Ssh0
    end,
    case ssh_auth:userauth_request_msg(Ssh1) of
        {send_disconnect,Code,Ssh}->
            {Shutdown,D} = send_disconnect(Code,io_lib:format("User auth failed for: ~p",[D0#data.auth_user]),ssh_connection_handler,1001,StateName,D0#data{ssh_params = Ssh}),
            {stop,Shutdown,D};
        {"keyboard-interactive",{Msg,Ssh}}->
            D = send_msg(Msg,D0#data{ssh_params = Ssh}),
            {next_state,{userauth_keyboard_interactive,client},D};
        {_Method,{Msg,Ssh}}->
            D = send_msg(Msg,D0#data{ssh_params = Ssh}),
            {keep_state,D}
    end;
handle_event(_,#ssh_msg_userauth_banner{message = Msg},{userauth,client},D) ->
    case (D#data.ssh_params)#ssh.userauth_quiet_mode of
        false->
            io:format("~s",[Msg]);
        true->
            ok
    end,
    keep_state_and_data;
handle_event(_,#ssh_msg_userauth_info_request{} = Msg,{userauth_keyboard_interactive,client},#data{ssh_params = Ssh0} = D0) ->
    case ssh_auth:handle_userauth_info_request(Msg,Ssh0) of
        {ok,{Reply,Ssh}}->
            D = send_msg(Reply,D0#data{ssh_params = Ssh}),
            {next_state,{userauth_keyboard_interactive_info_response,client},D};
        not_ok->
            {next_state,{userauth,client},D0,[postpone]}
    end;
handle_event(_,#ssh_msg_userauth_info_response{} = Msg,{userauth_keyboard_interactive,server},D0) ->
    case ssh_auth:handle_userauth_info_response(Msg,D0#data.ssh_params) of
        {authorized,User,{Reply,Ssh1}}->
            D = #data{ssh_params = Ssh} = send_msg(Reply,D0#data{ssh_params = Ssh1}),
            D#data.starter ! ssh_connected,
            connected_fun(User,"keyboard-interactive",D),
            {next_state,{connected,server},D#data{auth_user = User,ssh_params = Ssh#ssh{authenticated = true}}};
        {not_authorized,{User,Reason},{Reply,Ssh}}->
            retry_fun(User,Reason,D0),
            D = send_msg(Reply,D0#data{ssh_params = Ssh}),
            {next_state,{userauth,server},D};
        {authorized_but_one_more,_User,{Reply,Ssh}}->
            D = send_msg(Reply,D0#data{ssh_params = Ssh}),
            {next_state,{userauth_keyboard_interactive_extra,server},D}
    end;
handle_event(_,#ssh_msg_userauth_info_response{} = Msg,{userauth_keyboard_interactive_extra,server},D0) ->
    {authorized,User,{Reply,Ssh1}} = ssh_auth:handle_userauth_info_response({extra,Msg},D0#data.ssh_params),
    D = #data{ssh_params = Ssh} = send_msg(Reply,D0#data{ssh_params = Ssh1}),
    D#data.starter ! ssh_connected,
    connected_fun(User,"keyboard-interactive",D),
    {next_state,{connected,server},D#data{auth_user = User,ssh_params = Ssh#ssh{authenticated = true}}};
handle_event(_,#ssh_msg_userauth_failure{},{userauth_keyboard_interactive,client},#data{ssh_params = Ssh0} = D0) ->
    Prefs = [{Method,M,F,A} || {Method,M,F,A} <- Ssh0#ssh.userauth_preference,Method =/= "keyboard-interactive"],
    D = D0#data{ssh_params = Ssh0#ssh{userauth_preference = Prefs}},
    {next_state,{userauth,client},D,[postpone]};
handle_event(_,#ssh_msg_userauth_failure{},{userauth_keyboard_interactive_info_response,client},#data{ssh_params = Ssh0} = D0) ->
    Opts = Ssh0#ssh.opts,
    D = case ssh_options:get_value(user_options,password,Opts,ssh_connection_handler,1076) of
        undefined->
            D0;
        _->
            D0#data{ssh_params = Ssh0#ssh{opts = ssh_options:put_value(user_options,{password,not_ok},Opts,ssh_connection_handler,1081)}}
    end,
    {next_state,{userauth,client},D,[postpone]};
handle_event(_,#ssh_msg_ext_info{} = Msg,{userauth_keyboard_interactive_info_response,client},D0) ->
    D = handle_ssh_msg_ext_info(Msg,D0),
    {keep_state,D};
handle_event(_,#ssh_msg_userauth_success{},{userauth_keyboard_interactive_info_response,client},D) ->
    {next_state,{userauth,client},D,[postpone]};
handle_event(_,#ssh_msg_userauth_info_request{},{userauth_keyboard_interactive_info_response,client},D) ->
    {next_state,{userauth_keyboard_interactive,client},D,[postpone]};
handle_event(_,#ssh_msg_ext_info{},{connected,_Role},D) ->
    {keep_state,D};
handle_event(_,{#ssh_msg_kexinit{},_},{connected,Role},D0) ->
    {KeyInitMsg,SshPacket,Ssh} = ssh_transport:key_exchange_init_msg(D0#data.ssh_params),
    D = D0#data{ssh_params = Ssh,key_exchange_init_msg = KeyInitMsg},
    send_bytes(SshPacket,D),
    {next_state,{kexinit,Role,renegotiate},D,[postpone]};
handle_event(_,#ssh_msg_disconnect{description = Desc} = Msg,StateName,D0) ->
    {disconnect,_,RepliesCon} = ssh_connection:handle_msg(Msg,D0#data.connection_state,role(StateName),D0#data.ssh_params),
    {Actions,D} = send_replies(RepliesCon,D0),
    disconnect_fun("Received disconnect: " ++ Desc,D),
    {stop_and_reply,{shutdown,Desc},Actions,D};
handle_event(_,#ssh_msg_ignore{},_,_) ->
    keep_state_and_data;
handle_event(_,#ssh_msg_unimplemented{},_,_) ->
    keep_state_and_data;
handle_event(_,#ssh_msg_debug{} = Msg,_,D) ->
    debug_fun(Msg,D),
    keep_state_and_data;
handle_event(internal,{conn_msg,Msg},StateName,#data{starter = User,connection_state = Connection0,event_queue = Qev0} = D0) ->
    Role = role(StateName),
    Rengotation = renegotiation(StateName),
    try ssh_connection:handle_msg(Msg,Connection0,Role,D0#data.ssh_params) of 
        {disconnect,Reason0,RepliesConn}->
            {Repls,D} = send_replies(RepliesConn,D0),
            case {Reason0,Role} of
                {{_,Reason},client}
                    when (StateName =/= {connected,client}) and  not Rengotation->
                    User ! {self(),not_connected,Reason};
                _->
                    ok
            end,
            {stop_and_reply,{shutdown,normal},Repls,D};
        {Replies,Connection}
            when is_list(Replies)->
            {Repls,D} = case StateName of
                {connected,_}->
                    send_replies(Replies,D0#data{connection_state = Connection});
                _->
                    {ConnReplies,NonConnReplies} = lists:splitwith(fun not_connected_filter/1,Replies),
                    send_replies(NonConnReplies,D0#data{event_queue = Qev0 ++ ConnReplies})
            end,
            case {Msg,StateName} of
                {#ssh_msg_channel_close{},{connected,_}}->
                    {keep_state,D,[cond_set_idle_timer(D)| Repls]};
                {#ssh_msg_channel_success{},_}->
                    update_inet_buffers(D#data.socket),
                    {keep_state,D,Repls};
                _->
                    {keep_state,D,Repls}
            end
        catch
            Class:Error->
                {Repls,D1} = send_replies(ssh_connection:handle_stop(Connection0),D0),
                {Shutdown,D} = send_disconnect(11,io_lib:format("Internal error: ~p:~p",[Class, Error]),ssh_connection_handler,1167,StateName,D1),
                {stop_and_reply,Shutdown,Repls,D} end;
handle_event(enter,OldState,{connected,_} = NewState,D) ->
    init_renegotiate_timers(OldState,NewState,D);
handle_event(enter,OldState,{ext_info,_,renegotiate} = NewState,D) ->
    init_renegotiate_timers(OldState,NewState,D);
handle_event(enter,{connected,_} = OldState,NewState,D) ->
    pause_renegotiate_timers(OldState,NewState,D);
handle_event(cast,force_renegotiate,StateName,D) ->
    handle_event({timeout,renegotiate},undefined,StateName,D);
handle_event({timeout,renegotiate},_,StateName,D0) ->
    case StateName of
        {connected,Role}->
            start_rekeying(Role,D0);
        {ext_info,Role,renegotiate}->
            start_rekeying(Role,D0);
        _->
            keep_state_and_data
    end;
handle_event({timeout,check_data_size},_,StateName,D0) ->
    case StateName of
        {connected,Role}->
            check_data_rekeying(Role,D0);
        _->
            keep_state_and_data
    end;
handle_event({call,From},get_alg,_,D) ->
    #ssh{algorithms = Algs} = D#data.ssh_params,
    {keep_state_and_data,[{reply,From,Algs}]};
handle_event(cast,_,StateName,_)
    when  not (element(1,StateName) == connected orelse element(1,StateName) == ext_info)->
    {keep_state_and_data,[postpone]};
handle_event(cast,{adjust_window,ChannelId,Bytes},StateName,D)
    when element(1,StateName) == connected orelse element(1,StateName) == ext_info->
    case ssh_client_channel:cache_lookup(cache(D),ChannelId) of
        #channel{recv_window_size = WinSize,recv_window_pending = Pending,recv_packet_size = PktSize} = Channel
            when WinSize - Bytes >= 2 * PktSize->
            ssh_client_channel:cache_update(cache(D),Channel#channel{recv_window_pending = Pending + Bytes}),
            keep_state_and_data;
        #channel{recv_window_size = WinSize,recv_window_pending = Pending,remote_id = Id} = Channel->
            ssh_client_channel:cache_update(cache(D),Channel#channel{recv_window_size = WinSize + Bytes + Pending,recv_window_pending = 0}),
            Msg = ssh_connection:channel_adjust_window_msg(Id,Bytes + Pending),
            {keep_state,send_msg(Msg,D)};
        undefined->
            keep_state_and_data
    end;
handle_event(cast,{reply_request,Resp,ChannelId},StateName,D)
    when element(1,StateName) == connected orelse element(1,StateName) == ext_info->
    case ssh_client_channel:cache_lookup(cache(D),ChannelId) of
        #channel{remote_id = RemoteId}
            when Resp == success;
            Resp == failure->
            Msg = case Resp of
                success->
                    ssh_connection:channel_success_msg(RemoteId);
                failure->
                    ssh_connection:channel_failure_msg(RemoteId)
            end,
            update_inet_buffers(D#data.socket),
            {keep_state,send_msg(Msg,D)};
        #channel{}->
            Details = io_lib:format("Unhandled reply in state ~p:~n~p",[StateName, Resp]),
            send_disconnect(2,Details,ssh_connection_handler,1255,StateName,D);
        undefined->
            keep_state_and_data
    end;
handle_event(cast,{request,ChannelPid,ChannelId,Type,Data},StateName,D)
    when element(1,StateName) == connected orelse element(1,StateName) == ext_info->
    {keep_state,handle_request(ChannelPid,ChannelId,Type,Data,false,none,D)};
handle_event(cast,{request,ChannelId,Type,Data},StateName,D)
    when element(1,StateName) == connected orelse element(1,StateName) == ext_info->
    {keep_state,handle_request(ChannelId,Type,Data,false,none,D)};
handle_event(cast,{unknown,Data},StateName,D)
    when element(1,StateName) == connected orelse element(1,StateName) == ext_info->
    Msg = #ssh_msg_unimplemented{sequence = Data},
    {keep_state,send_msg(Msg,D)};
handle_event(cast,{global_request,Type,Data},StateName,D)
    when element(1,StateName) == connected orelse element(1,StateName) == ext_info->
    {keep_state,send_msg(ssh_connection:request_global_msg(Type,false,Data),D)};
handle_event({call,From},get_print_info,StateName,D) ->
    Reply = try {inet:sockname(D#data.socket),inet:peername(D#data.socket)} of 
        {{ok,Local},{ok,Remote}}->
            {{Local,Remote},io_lib:format("statename=~p",[StateName])};
        _->
            {{"-",0},"-"}
        catch
            _:_->
                {{"?",0},"?"} end,
    {keep_state_and_data,[{reply,From,Reply}]};
handle_event({call,From},{connection_info,Options},_,D) ->
    Info = fold_keys(Options,fun conn_info/2,D),
    {keep_state_and_data,[{reply,From,Info}]};
handle_event({call,From},{channel_info,ChannelId,Options},_,D) ->
    case ssh_client_channel:cache_lookup(cache(D),ChannelId) of
        #channel{} = Channel->
            Info = fold_keys(Options,fun chann_info/2,Channel),
            {keep_state_and_data,[{reply,From,Info}]};
        undefined->
            {keep_state_and_data,[{reply,From,[]}]}
    end;
handle_event({call,From},{info,all},_,D) ->
    Result = ssh_client_channel:cache_foldl(fun (Channel,Acc)->
        [Channel| Acc] end,[],cache(D)),
    {keep_state_and_data,[{reply,From,{ok,Result}}]};
handle_event({call,From},{info,ChannelPid},_,D) ->
    Result = ssh_client_channel:cache_foldl(fun (Channel,Acc)
        when Channel#channel.user == ChannelPid->
        [Channel| Acc];(_,Acc)->
        Acc end,[],cache(D)),
    {keep_state_and_data,[{reply,From,{ok,Result}}]};
handle_event({call,From},{set_sock_opts,SocketOptions},_StateName,D) ->
    Result = try inet:setopts(D#data.socket,SocketOptions)
        catch
            _:_->
                {error,badarg} end,
    {keep_state_and_data,[{reply,From,Result}]};
handle_event({call,From},{get_sock_opts,SocketGetOptions},_StateName,D) ->
    Result = try inet:getopts(D#data.socket,SocketGetOptions)
        catch
            _:_->
                {error,badarg} end,
    {keep_state_and_data,[{reply,From,Result}]};
handle_event({call,From},stop,_StateName,D0) ->
    {Repls,D} = send_replies(ssh_connection:handle_stop(D0#data.connection_state),D0),
    {stop_and_reply,normal,[{reply,From,ok}| Repls],D};
handle_event({call,_},_,StateName,_)
    when  not (element(1,StateName) == connected orelse element(1,StateName) == ext_info)->
    {keep_state_and_data,[postpone]};
handle_event({call,From},{request,ChannelPid,ChannelId,Type,Data,Timeout},StateName,D0)
    when element(1,StateName) == connected orelse element(1,StateName) == ext_info->
    case handle_request(ChannelPid,ChannelId,Type,Data,true,From,D0) of
        {error,Error}->
            {keep_state,D0,{reply,From,{error,Error}}};
        D->
            start_channel_request_timer(ChannelId,From,Timeout),
            {keep_state,D,cond_set_idle_timer(D)}
    end;
handle_event({call,From},{request,ChannelId,Type,Data,Timeout},StateName,D0)
    when element(1,StateName) == connected orelse element(1,StateName) == ext_info->
    case handle_request(ChannelId,Type,Data,true,From,D0) of
        {error,Error}->
            {keep_state,D0,{reply,From,{error,Error}}};
        D->
            start_channel_request_timer(ChannelId,From,Timeout),
            {keep_state,D,cond_set_idle_timer(D)}
    end;
handle_event({call,From},{global_request,"tcpip-forward" = Type,{ListenHost,ListenPort,ConnectToHost,ConnectToPort},Timeout},StateName,D0)
    when element(1,StateName) == connected orelse element(1,StateName) == ext_info->
    Id = make_ref(),
    Data = <<(size(ListenHost)):32/unsigned-big-integer,ListenHost/binary,ListenPort:32/unsigned-big-integer>>,
    Fun = fun ({success,<<Port:32/unsigned-integer>>},C)->
        Key = {tcpip_forward,ListenHost,Port},
        Value = {ConnectToHost,ConnectToPort},
        C#connection{options = ssh_options:put_value(internal_options,{Key,Value},C#connection.options,ssh_connection_handler,1374)};({success,<<>>},C)->
        Key = {tcpip_forward,ListenHost,ListenPort},
        Value = {ConnectToHost,ConnectToPort},
        C#connection{options = ssh_options:put_value(internal_options,{Key,Value},C#connection.options,ssh_connection_handler,1378)};(_,C)->
        C end,
    D = send_msg(ssh_connection:request_global_msg(Type,true,Data),add_request(Fun,Id,From,D0)),
    start_channel_request_timer(Id,From,Timeout),
    {keep_state,D,cond_set_idle_timer(D)};
handle_event({call,From},{global_request,Type,Data,Timeout},StateName,D0)
    when element(1,StateName) == connected orelse element(1,StateName) == ext_info->
    Id = make_ref(),
    D = send_msg(ssh_connection:request_global_msg(Type,true,Data),add_request(true,Id,From,D0)),
    start_channel_request_timer(Id,From,Timeout),
    {keep_state,D,cond_set_idle_timer(D)};
handle_event({call,From},{data,ChannelId,Type,Data,Timeout},StateName,D0)
    when element(1,StateName) == connected orelse element(1,StateName) == ext_info->
    {Repls,D} = send_replies(ssh_connection:channel_data(ChannelId,Type,Data,D0#data.connection_state,From),D0),
    start_channel_request_timer(ChannelId,From,Timeout),
    {keep_state,D,Repls};
handle_event({call,From},{eof,ChannelId},StateName,D0)
    when element(1,StateName) == connected orelse element(1,StateName) == ext_info->
    case ssh_client_channel:cache_lookup(cache(D0),ChannelId) of
        #channel{remote_id = Id,sent_close = false}->
            D = send_msg(ssh_connection:channel_eof_msg(Id),D0),
            {keep_state,D,[{reply,From,ok}]};
        _->
            {keep_state,D0,[{reply,From,{error,closed}}]}
    end;
handle_event({call,From},get_misc,StateName,#data{connection_state = #connection{options = Opts}} = D)
    when element(1,StateName) == connected orelse element(1,StateName) == ext_info->
    Sups = ssh_options:get_value(internal_options,supervisors,Opts,ssh_connection_handler,1413),
    SubSysSup = proplists:get_value(subsystem_sup,Sups),
    Reply = {ok,{SubSysSup,role(StateName),Opts}},
    {keep_state,D,[{reply,From,Reply}]};
handle_event({call,From},{open,ChannelPid,Type,InitialWindowSize,MaxPacketSize,Data,Timeout},StateName,D0)
    when element(1,StateName) == connected orelse element(1,StateName) == ext_info->
    monitor(process,ChannelPid),
    {ChannelId,D1} = new_channel_id(D0),
    D2 = send_msg(ssh_connection:channel_open_msg(Type,ChannelId,InitialWindowSize,MaxPacketSize,Data),D1),
    ssh_client_channel:cache_update(cache(D2),#channel{type = Type,sys = "none",user = ChannelPid,local_id = ChannelId,recv_window_size = InitialWindowSize,recv_packet_size = MaxPacketSize,send_buf = queue:new()}),
    D = add_request(true,ChannelId,From,D2),
    start_channel_request_timer(ChannelId,From,Timeout),
    {keep_state,D,cond_set_idle_timer(D)};
handle_event({call,From},{send_window,ChannelId},StateName,D)
    when element(1,StateName) == connected orelse element(1,StateName) == ext_info->
    Reply = case ssh_client_channel:cache_lookup(cache(D),ChannelId) of
        #channel{send_window_size = WinSize,send_packet_size = Packsize}->
            {ok,{WinSize,Packsize}};
        undefined->
            {error,einval}
    end,
    {keep_state_and_data,[{reply,From,Reply}]};
handle_event({call,From},{recv_window,ChannelId},StateName,D)
    when element(1,StateName) == connected orelse element(1,StateName) == ext_info->
    Reply = case ssh_client_channel:cache_lookup(cache(D),ChannelId) of
        #channel{recv_window_size = WinSize,recv_packet_size = Packsize}->
            {ok,{WinSize,Packsize}};
        undefined->
            {error,einval}
    end,
    {keep_state_and_data,[{reply,From,Reply}]};
handle_event({call,From},{close,ChannelId},StateName,D0)
    when element(1,StateName) == connected orelse element(1,StateName) == ext_info->
    case ssh_client_channel:cache_lookup(cache(D0),ChannelId) of
        #channel{remote_id = Id} = Channel->
            D1 = send_msg(ssh_connection:channel_close_msg(Id),D0),
            ssh_client_channel:cache_update(cache(D1),Channel#channel{sent_close = true}),
            {keep_state,D1,[cond_set_idle_timer(D1), {reply,From,ok}]};
        undefined->
            {keep_state_and_data,[{reply,From,ok}]}
    end;
handle_event(cast,{store,Key,Value},_StateName,#data{connection_state = C0} = D) ->
    C = C0#connection{options = ssh_options:put_value(internal_options,{Key,Value},C0#connection.options,ssh_connection_handler,1475)},
    {keep_state,D#data{connection_state = C}};
handle_event({call,From},{retrieve,Key},_StateName,#data{connection_state = C}) ->
    case retrieve(C,Key) of
        {ok,Value}->
            {keep_state_and_data,[{reply,From,{ok,Value}}]};
        _->
            {keep_state_and_data,[{reply,From,undefined}]}
    end;
handle_event(info,{Proto,Sock,Info},{hello,_},#data{socket = Sock,transport_protocol = Proto}) ->
    case Info of
        "SSH-" ++ _->
            {keep_state_and_data,[{next_event,internal,{version_exchange,Info}}]};
        _->
            {keep_state_and_data,[{next_event,internal,{info_line,Info}}]}
    end;
handle_event(info,{Proto,Sock,NewData},StateName,D0 = #data{socket = Sock,transport_protocol = Proto}) ->
    try ssh_transport:handle_packet_part(D0#data.decrypted_data_buffer,<<(D0#data.encrypted_data_buffer)/binary,NewData/binary>>,D0#data.aead_data,D0#data.undecrypted_packet_length,D0#data.ssh_params) of 
        {packet_decrypted,DecryptedBytes,EncryptedDataRest,Ssh1}->
            D1 = D0#data{ssh_params = Ssh1#ssh{recv_sequence = ssh_transport:next_seqnum(Ssh1#ssh.recv_sequence)},decrypted_data_buffer = <<>>,undecrypted_packet_length = undefined,aead_data = <<>>,encrypted_data_buffer = EncryptedDataRest},
            try ssh_message:decode(set_kex_overload_prefix(DecryptedBytes,D1)) of 
                #ssh_msg_kexinit{} = Msg->
                    {keep_state,D1,[{next_event,internal,prepare_next_packet}, {next_event,internal,{Msg,DecryptedBytes}}]};
                #ssh_msg_global_request{} = Msg->
                    {keep_state,D1,[{next_event,internal,prepare_next_packet}, {next_event,internal,{conn_msg,Msg}}]};
                #ssh_msg_request_success{} = Msg->
                    {keep_state,D1,[{next_event,internal,prepare_next_packet}, {next_event,internal,{conn_msg,Msg}}]};
                #ssh_msg_request_failure{} = Msg->
                    {keep_state,D1,[{next_event,internal,prepare_next_packet}, {next_event,internal,{conn_msg,Msg}}]};
                #ssh_msg_channel_open{} = Msg->
                    {keep_state,D1,[{next_event,internal,prepare_next_packet}, {next_event,internal,{conn_msg,Msg}}]};
                #ssh_msg_channel_open_confirmation{} = Msg->
                    {keep_state,D1,[{next_event,internal,prepare_next_packet}, {next_event,internal,{conn_msg,Msg}}]};
                #ssh_msg_channel_open_failure{} = Msg->
                    {keep_state,D1,[{next_event,internal,prepare_next_packet}, {next_event,internal,{conn_msg,Msg}}]};
                #ssh_msg_channel_window_adjust{} = Msg->
                    {keep_state,D1,[{next_event,internal,prepare_next_packet}, {next_event,internal,{conn_msg,Msg}}]};
                #ssh_msg_channel_data{} = Msg->
                    {keep_state,D1,[{next_event,internal,prepare_next_packet}, {next_event,internal,{conn_msg,Msg}}]};
                #ssh_msg_channel_extended_data{} = Msg->
                    {keep_state,D1,[{next_event,internal,prepare_next_packet}, {next_event,internal,{conn_msg,Msg}}]};
                #ssh_msg_channel_eof{} = Msg->
                    {keep_state,D1,[{next_event,internal,prepare_next_packet}, {next_event,internal,{conn_msg,Msg}}]};
                #ssh_msg_channel_close{} = Msg->
                    {keep_state,D1,[{next_event,internal,prepare_next_packet}, {next_event,internal,{conn_msg,Msg}}]};
                #ssh_msg_channel_request{} = Msg->
                    {keep_state,D1,[{next_event,internal,prepare_next_packet}, {next_event,internal,{conn_msg,Msg}}]};
                #ssh_msg_channel_failure{} = Msg->
                    {keep_state,D1,[{next_event,internal,prepare_next_packet}, {next_event,internal,{conn_msg,Msg}}]};
                #ssh_msg_channel_success{} = Msg->
                    {keep_state,D1,[{next_event,internal,prepare_next_packet}, {next_event,internal,{conn_msg,Msg}}]};
                Msg->
                    {keep_state,D1,[{next_event,internal,prepare_next_packet}, {next_event,internal,Msg}]}
                catch
                    C:E:ST->
                        {Shutdown,D} = send_disconnect(2,io_lib:format("Bad packet: Decr" "ypted, but can't" " decode~n~p:~p~n" "~p",[C, E, ST]),ssh_connection_handler,1545,StateName,D1),
                        {stop,Shutdown,D} end;
        {get_more,DecryptedBytes,EncryptedDataRest,AeadData,RemainingSshPacketLen,Ssh1}->
            inet:setopts(Sock,[{active,once}]),
            {keep_state,D0#data{encrypted_data_buffer = EncryptedDataRest,decrypted_data_buffer = DecryptedBytes,undecrypted_packet_length = RemainingSshPacketLen,aead_data = AeadData,ssh_params = Ssh1}};
        {bad_mac,Ssh1}->
            {Shutdown,D} = send_disconnect(2,"Bad packet: bad mac",ssh_connection_handler,1563,StateName,D0#data{ssh_params = Ssh1}),
            {stop,Shutdown,D};
        {error,{exceeds_max_size,PacketLen}}->
            {Shutdown,D} = send_disconnect(2,io_lib:format("Bad packet: Size (~p byt" "es) exceeds max size",[PacketLen]),ssh_connection_handler,1571,StateName,D0),
            {stop,Shutdown,D}
        catch
            C:E:ST->
                {Shutdown,D} = send_disconnect(2,io_lib:format("Bad packet: Couldn't dec" "rypt~n~p:~p~n~p",[C, E, ST]),ssh_connection_handler,1578,StateName,D0),
                {stop,Shutdown,D} end;
handle_event(internal,prepare_next_packet,_,D) ->
    Enough = max(8,(D#data.ssh_params)#ssh.decrypt_block_size),
    case size(D#data.encrypted_data_buffer) of
        Sz
            when Sz >= Enough->
            self() ! {D#data.transport_protocol,D#data.socket,<<>>};
        _->
            ok
    end,
    inet:setopts(D#data.socket,[{active,once}]),
    keep_state_and_data;
handle_event(info,{CloseTag,Socket},_StateName,D0 = #data{socket = Socket,transport_close_tag = CloseTag,connection_state = C0}) ->
    {Repls,D} = send_replies(ssh_connection:handle_stop(C0),D0),
    disconnect_fun("Received a transport close",D),
    {stop_and_reply,{shutdown,"Connection closed"},Repls,D};
handle_event(info,{timeout,{_,From} = Request},_,#data{connection_state = #connection{requests = Requests} = C0} = D) ->
    case lists:member(Request,Requests) of
        true->
            C = C0#connection{requests = lists:delete(Request,Requests)},
            {keep_state,D#data{connection_state = C},[{reply,From,{error,timeout}}]};
        false->
            keep_state_and_data
    end;
handle_event(info,{'DOWN',_Ref,process,ChannelPid,_Reason},_,D) ->
    Cache = cache(D),
    ssh_client_channel:cache_foldl(fun (#channel{user = U,local_id = Id},Acc)
        when U == ChannelPid->
        ssh_client_channel:cache_delete(Cache,Id),
        Acc;(_,Acc)->
        Acc end,[],Cache),
    {keep_state,D,cond_set_idle_timer(D)};
handle_event({timeout,idle_time},_Data,_StateName,_D) ->
    {stop,{shutdown,"Timeout"}};
handle_event(info,{'EXIT',_Sup,Reason},StateName,_) ->
    Role = role(StateName),
    if Role == client ->
        {stop,{shutdown,Reason}};Reason == normal ->
        keep_state_and_data;true ->
        {stop,{shutdown,Reason}} end;
handle_event(info,check_cache,_,D) ->
    {keep_state,D,cond_set_idle_timer(D)};
handle_event(info,{fwd_connect_received,Sock,ChId,ChanCB},StateName,#data{connection_state = Connection}) ->
    #connection{options = Options,channel_cache = Cache,sub_system_supervisor = SubSysSup} = Connection,
    Channel = ssh_client_channel:cache_lookup(Cache,ChId),
    {ok,Pid} = ssh_subsystem_sup:start_channel(role(StateName),SubSysSup,self(),ChanCB,ChId,[Sock],undefined,Options),
    ssh_client_channel:cache_update(Cache,Channel#channel{user = Pid}),
    gen_tcp:controlling_process(Sock,Pid),
    inet:setopts(Sock,[{active,once}]),
    keep_state_and_data;
handle_event({call,From},{handle_direct_tcpip,ListenHost,ListenPort,ConnectToHost,ConnectToPort,_Timeout},_StateName,#data{connection_state = #connection{sub_system_supervisor = SubSysSup}}) ->
    case ssh_tcpip_forward_acceptor:supervised_start(ssh_subsystem_sup:tcpip_fwd_supervisor(SubSysSup),{ListenHost,ListenPort},{ConnectToHost,ConnectToPort},"direct-tcpip",ssh_tcpip_forward_client,self()) of
        {ok,LPort}->
            {keep_state_and_data,[{reply,From,{ok,LPort}}]};
        {error,Error}->
            {keep_state_and_data,[{reply,From,{error,Error}}]}
    end;
handle_event(info,UnexpectedMessage,StateName,D = #data{ssh_params = Ssh}) ->
    case unexpected_fun(UnexpectedMessage,D) of
        report->
            Msg = lists:flatten(io_lib:format("*** SSH: Unexpected messag" "e '~p' received in state '" "~p'\nRole: ~p\nPeer: ~p\nL" "ocal Address: ~p\n",[UnexpectedMessage, StateName, Ssh#ssh.role, Ssh#ssh.peer, ssh_options:get_value(internal_options,address,Ssh#ssh.opts,fun ()->
                undefined end,ssh_connection_handler,1693)])),
            error_logger:info_report(Msg),
            keep_state_and_data;
        skip->
            keep_state_and_data;
        Other->
            Msg = lists:flatten(io_lib:format("*** SSH: Call to fun in 'u" "nexpectedfun' failed:~nRet" "urn: ~p\nMessage: ~p\nRole" ": ~p\nPeer: ~p\nLocal Addr" "ess: ~p\n",[Other, UnexpectedMessage, Ssh#ssh.role, Ssh#ssh.peer, ssh_options:get_value(internal_options,address,Ssh#ssh.opts,fun ()->
                undefined end,ssh_connection_handler,1713)])),
            error_logger:error_report(Msg),
            keep_state_and_data
    end;
handle_event(internal,{send_disconnect,Code,DetailedText,Module,Line},StateName,D0) ->
    {Shutdown,D} = send_disconnect(Code,DetailedText,Module,Line,StateName,D0),
    {stop,Shutdown,D};
handle_event(enter,_OldState,State,D) ->
    {next_state,State,D};
handle_event(_Type,_Msg,{ext_info,Role,_ReNegFlag},D) ->
    {next_state,{connected,Role},D,[postpone]};
handle_event(Type,Ev,StateName,D0) ->
    Details = case  catch atom_to_list(element(1,Ev)) of
        "ssh_msg_" ++ _
            when Type == internal->
            lists:flatten(io_lib:format("Message ~p in wrong state " "(~p)",[element(1,Ev), StateName]));
        _->
            io_lib:format("Unhandled event in state ~p:~n~p",[StateName, Ev])
    end,
    {Shutdown,D} = send_disconnect(2,Details,ssh_connection_handler,1742,StateName,D0),
    {stop,Shutdown,D}.

-spec(terminate(any(),state_name(),#data{}) -> term()).

terminate(normal,_StateName,D) ->
    stop_subsystem(D),
    close_transport(D);
terminate({shutdown,"Connection closed"},_StateName,D) ->
    stop_subsystem(D),
    close_transport(D);
terminate({shutdown,{init,Reason}},StateName,D) ->
    log(error,D,"Shutdown in init (StateName=~p): ~p~n",[StateName, Reason]),
    stop_subsystem(D),
    close_transport(D);
terminate({shutdown,_R},_StateName,D) ->
    stop_subsystem(D),
    close_transport(D);
terminate(shutdown,_StateName,D0) ->
    D = send_msg(#ssh_msg_disconnect{code = 11,description = "Terminated (shutdown) by supe" "rvisor"},D0),
    close_transport(D);
terminate(killed,_StateName,D) ->
    stop_subsystem(D),
    close_transport(D);
terminate(Reason,StateName,D0) ->
    log(error,D0,Reason),
    {_ShutdownReason,D} = send_disconnect(11,"Internal error",io_lib:format("Reason: ~p",[Reason]),ssh_connection_handler,1792,StateName,D0),
    stop_subsystem(D),
    close_transport(D).

format_status(normal,[_, _StateName, D]) ->
    [{data,[{"State",D}]}];
format_status(terminate,[_, _StateName, D]) ->
    [{data,[{"State",state_data2proplist(D)}]}].

state_data2proplist(D) ->
    DataPropList0 = fmt_stat_rec(record_info(fields,data),D,[decrypted_data_buffer, encrypted_data_buffer, key_exchange_init_msg, user_passwords, opts, inet_initial_recbuf_size]),
    SshPropList = fmt_stat_rec(record_info(fields,ssh),D#data.ssh_params,[c_keyinit, s_keyinit, send_mac_key, send_mac_size, recv_mac_key, recv_mac_size, encrypt_keys, encrypt_ctx, decrypt_keys, decrypt_ctx, compress_ctx, decompress_ctx, shared_secret, exchanged_hash, session_id, keyex_key, keyex_info, available_host_keys]),
    lists:keyreplace(ssh_params,1,DataPropList0,{ssh_params,SshPropList}).

fmt_stat_rec(FieldNames,Rec,Exclude) ->
    Values = tl(tuple_to_list(Rec)),
    [P || {K,_} = P <- lists:zip(FieldNames,Values), not lists:member(K,Exclude)].

-spec(code_change(term()|{down,term()},state_name(),#data{},term()) -> {ok,state_name(),#data{}}).

code_change(_OldVsn,StateName,State,_Extra) ->
    {ok,StateName,State}.

start_the_connection_child(UserPid,Role,Socket,Options0) ->
    Sups = ssh_options:get_value(internal_options,supervisors,Options0,ssh_connection_handler,1866),
    ConnectionSup = proplists:get_value(connection_sup,Sups),
    Options = ssh_options:put_value(internal_options,{user_pid,UserPid},Options0,ssh_connection_handler,1868),
    InitArgs = [Role, Socket, Options],
    {ok,Pid} = ssh_connection_sup:start_child(ConnectionSup,InitArgs),
    ok = socket_control(Socket,Pid,Options),
    Pid.

stop_subsystem(#data{ssh_params = #ssh{role = Role},connection_state = #connection{system_supervisor = SysSup,sub_system_supervisor = SubSysSup,options = Opts}})
    when is_pid(SysSup) andalso is_pid(SubSysSup)->
    C = self(),
    spawn(fun ()->
        wait_until_dead(C,10000),
        case {Role,ssh_options:get_value(internal_options,connected_socket,Opts,fun ()->
            non_socket_started end,ssh_connection_handler,1887)} of
            {server,non_socket_started}->
                ssh_system_sup:stop_subsystem(SysSup,SubSysSup);
            {client,non_socket_started}->
                ssh_system_sup:stop_system(Role,SysSup);
            {server,_Socket}->
                ssh_system_sup:stop_system(Role,SysSup);
            {client,_Socket}->
                ssh_system_sup:stop_subsystem(SysSup,SubSysSup),
                wait_until_dead(SubSysSup,1000),
                sshc_sup:stop_system(SysSup)
        end end);
stop_subsystem(_) ->
    ok.

wait_until_dead(Pid,Timeout) ->
    Mref = monitor(process,Pid),
    receive {'DOWN',Mref,process,Pid,_Info}->
        ok after Timeout->
        ok end.

close_transport(#data{transport_cb = Transport,socket = Socket}) ->
    try Transport:close(Socket) of 
        _->
            ok
        catch
            _:_->
                ok end.

peer_role(client) ->
    server;
peer_role(server) ->
    client.

available_hkey_algorithms(client,Options) ->
    case available_hkey_algos(Options) of
        []->
            error({shutdown,"No public key algs"});
        Algs->
            [(atom_to_list(A)) || A <- Algs]
    end;
available_hkey_algorithms(server,Options) ->
    case [A || A <- available_hkey_algos(Options),is_usable_host_key(A,Options)] of
        []->
            error({shutdown,"No host key available"});
        Algs->
            [(atom_to_list(A)) || A <- Algs]
    end.

available_hkey_algos(Options) ->
    SupAlgos = ssh_transport:supported_algorithms(public_key),
    HKeys = proplists:get_value(public_key,ssh_options:get_value(user_options,preferred_algorithms,Options,ssh_connection_handler,1950)),
    NonSupported = HKeys -- SupAlgos,
    AvailableAndSupported = HKeys -- NonSupported,
    AvailableAndSupported.

send_msg(Msg,State = #data{ssh_params = Ssh0})
    when is_tuple(Msg)->
    {Bytes,Ssh} = ssh_transport:ssh_packet(Msg,Ssh0),
    send_bytes(Bytes,State),
    State#data{ssh_params = Ssh}.

send_bytes("",_D) ->
    ok;
send_bytes(Bytes,#data{socket = Socket,transport_cb = Transport}) ->
    _ = Transport:send(Socket,Bytes),
    ok.

handle_version({2,0} = NumVsn,StrVsn,Ssh0) ->
    Ssh = counterpart_versions(NumVsn,StrVsn,Ssh0),
    {ok,Ssh};
handle_version(_,_,_) ->
    not_supported.

string_version(#ssh{role = client,c_version = Vsn}) ->
    Vsn;
string_version(#ssh{role = server,s_version = Vsn}) ->
    Vsn.

cast(FsmPid,Event) ->
    gen_statem:cast(FsmPid,Event).

call(FsmPid,Event) ->
    call(FsmPid,Event,infinity).

call(FsmPid,Event,Timeout) ->
    try gen_statem:call(FsmPid,Event,Timeout) of 
        {closed,_R}->
            {error,closed};
        {killed,_R}->
            {error,closed};
        Result->
            Result
        catch
            exit:{noproc,_R}->
                {error,closed};
            exit:{normal,_R}->
                {error,closed};
            exit:{{shutdown,_R},_}->
                {error,closed};
            exit:{shutdown,_R}->
                {error,closed} end.

set_kex_overload_prefix(Msg = <<Op:8/unsigned-big-integer,_/binary>>,#data{ssh_params = SshParams})
    when Op == 30;
    Op == 31->
    case  catch atom_to_list(kex(SshParams)) of
        "ecdh-sha2-" ++ _->
            <<"ecdh",Msg/binary>>;
        "curve25519-" ++ _->
            <<"ecdh",Msg/binary>>;
        "curve448-" ++ _->
            <<"ecdh",Msg/binary>>;
        "diffie-hellman-group-exchange-" ++ _->
            <<"dh_gex",Msg/binary>>;
        "diffie-hellman-group" ++ _->
            <<"dh",Msg/binary>>;
        _->
            Msg
    end;
set_kex_overload_prefix(Msg,_) ->
    Msg.

kex(#ssh{algorithms = #alg{kex = Kex}}) ->
    Kex;
kex(_) ->
    undefined.

cache(#data{connection_state = C}) ->
    C#connection.channel_cache.

handle_ssh_msg_ext_info(#ssh_msg_ext_info{},D = #data{ssh_params = #ssh{recv_ext_info = false}}) ->
    D;
handle_ssh_msg_ext_info(#ssh_msg_ext_info{data = Data},D0) ->
    lists:foldl(fun ext_info/2,D0,Data).

ext_info({"server-sig-algs",SigAlgsStr},D0 = #data{ssh_params = #ssh{role = client,userauth_pubkeys = ClientSigAlgs} = Ssh0}) ->
    SigAlgs = [A || Astr <- string:tokens(SigAlgsStr,","),A <- try [list_to_existing_atom(Astr)]
        catch
            _:_->
                [] end],
    CommonAlgs = [A || A <- SigAlgs,lists:member(A,ClientSigAlgs)],
    D0#data{ssh_params = Ssh0#ssh{userauth_pubkeys = CommonAlgs ++ ClientSigAlgs -- CommonAlgs}};
ext_info(_,D0) ->
    D0.

is_usable_user_pubkey(Alg,Ssh) ->
    try ssh_auth:get_public_key(Alg,Ssh) of 
        {ok,_}->
            true;
        _->
            false
        catch
            _:_->
                false end.

is_usable_host_key(Alg,Opts) ->
    try ssh_transport:get_host_key(Alg,Opts) of 
        _PrivHostKey->
            true
        catch
            _:_->
                false end.

handle_request(ChannelPid,ChannelId,Type,Data,WantReply,From,D) ->
    case ssh_client_channel:cache_lookup(cache(D),ChannelId) of
        #channel{remote_id = Id,sent_close = false} = Channel->
            update_sys(cache(D),Channel,Type,ChannelPid),
            send_msg(ssh_connection:channel_request_msg(Id,Type,WantReply,Data),add_request(WantReply,ChannelId,From,D));
        _
            when WantReply == true->
            {error,closed};
        _->
            D
    end.

handle_request(ChannelId,Type,Data,WantReply,From,D) ->
    case ssh_client_channel:cache_lookup(cache(D),ChannelId) of
        #channel{remote_id = Id,sent_close = false}->
            send_msg(ssh_connection:channel_request_msg(Id,Type,WantReply,Data),add_request(WantReply,ChannelId,From,D));
        _
            when WantReply == true->
            {error,closed};
        _->
            D
    end.

update_sys(Cache,Channel,Type,ChannelPid) ->
    ssh_client_channel:cache_update(Cache,Channel#channel{sys = Type,user = ChannelPid}).

add_request(false,_ChannelId,_From,State) ->
    State;
add_request(true,ChannelId,From,#data{connection_state = #connection{requests = Requests0} = Connection} = State) ->
    Requests = [{ChannelId,From}| Requests0],
    State#data{connection_state = Connection#connection{requests = Requests}};
add_request(Fun,ChannelId,From,#data{connection_state = #connection{requests = Requests0} = Connection} = State)
    when is_function(Fun)->
    Requests = [{ChannelId,From,Fun}| Requests0],
    State#data{connection_state = Connection#connection{requests = Requests}}.

new_channel_id(#data{connection_state = #connection{channel_id_seed = Id} = Connection} = State) ->
    {Id,State#data{connection_state = Connection#connection{channel_id_seed = Id + 1}}}.

start_rekeying(Role,D0) ->
    {KeyInitMsg,SshPacket,Ssh} = ssh_transport:key_exchange_init_msg(D0#data.ssh_params),
    send_bytes(SshPacket,D0),
    D = D0#data{ssh_params = Ssh,key_exchange_init_msg = KeyInitMsg},
    {next_state,{kexinit,Role,renegotiate},D}.

init_renegotiate_timers(_OldState,NewState,D) ->
    {RekeyTimeout,_MaxSent} = ssh_options:get_value(user_options,rekey_limit,(D#data.ssh_params)#ssh.opts,ssh_connection_handler,2160),
    {next_state,NewState,D,[{{timeout,renegotiate},RekeyTimeout,none}, {{timeout,check_data_size},60000,none}]}.

pause_renegotiate_timers(_OldState,NewState,D) ->
    {next_state,NewState,D,[{{timeout,renegotiate},infinity,none}, {{timeout,check_data_size},infinity,none}]}.

check_data_rekeying(Role,D) ->
    case inet:getstat(D#data.socket,[send_oct]) of
        {ok,[{send_oct,SocketSentTotal}]}->
            SentSinceRekey = SocketSentTotal - D#data.last_size_rekey,
            {_RekeyTimeout,MaxSent} = ssh_options:get_value(user_options,rekey_limit,(D#data.ssh_params)#ssh.opts,ssh_connection_handler,2173),
            case check_data_rekeying_dbg(SentSinceRekey,MaxSent) of
                true->
                    start_rekeying(Role,D#data{last_size_rekey = SocketSentTotal});
                _->
                    {keep_state,D,{{timeout,check_data_size},60000,none}}
            end;
        {error,_}->
            {keep_state,D,{{timeout,check_data_size},60000,none}}
    end.

check_data_rekeying_dbg(SentSinceRekey,MaxSent) ->
    SentSinceRekey >= MaxSent.

send_disconnect(Code,DetailedText,Module,Line,StateName,D) ->
    send_disconnect(Code,default_text(Code),DetailedText,Module,Line,StateName,D).

send_disconnect(Code,Reason,DetailedText,Module,Line,StateName,D0) ->
    Msg = #ssh_msg_disconnect{code = Code,description = Reason},
    D = send_msg(Msg,D0),
    LogMsg = io_lib:format("Disconnects with code = ~p [RFC4253 11.1]: ~s",[Code, Reason]),
    call_disconnectfun_and_log_cond(LogMsg,DetailedText,Module,Line,StateName,D),
    {{shutdown,Reason},D}.

call_disconnectfun_and_log_cond(LogMsg,DetailedText,Module,Line,StateName,D) ->
    case disconnect_fun(LogMsg,D) of
        void->
            log(info,D,"~s~nState = ~p~nModule = ~p, Line = ~p.~nDetails:~n  ~" "s~n",[LogMsg, StateName, Module, Line, DetailedText]);
        _->
            ok
    end.

default_text(1) ->
    "Host not allowed to connect";
default_text(2) ->
    "Protocol error";
default_text(3) ->
    "Key exchange failed";
default_text(4) ->
    "Reserved";
default_text(5) ->
    "Mac error";
default_text(6) ->
    "Compression error";
default_text(7) ->
    "Service not available";
default_text(8) ->
    "Protocol version not supported";
default_text(9) ->
    "Host key not verifiable";
default_text(10) ->
    "Connection lost";
default_text(11) ->
    "By application";
default_text(12) ->
    "Too many connections";
default_text(13) ->
    "Auth cancelled by user";
default_text(14) ->
    "Unable to connect using the available authentication methods";
default_text(15) ->
    "Illegal user name".

counterpart_versions(NumVsn,StrVsn,#ssh{role = server} = Ssh) ->
    Ssh#ssh{c_vsn = NumVsn,c_version = StrVsn};
counterpart_versions(NumVsn,StrVsn,#ssh{role = client} = Ssh) ->
    Ssh#ssh{s_vsn = NumVsn,s_version = StrVsn}.

conn_info_keys() ->
    [client_version, server_version, peer, user, sockname, options, algorithms, channels].

conn_info(client_version,#data{ssh_params = S}) ->
    {S#ssh.c_vsn,S#ssh.c_version};
conn_info(server_version,#data{ssh_params = S}) ->
    {S#ssh.s_vsn,S#ssh.s_version};
conn_info(peer,#data{ssh_params = S}) ->
    S#ssh.peer;
conn_info(user,D) ->
    D#data.auth_user;
conn_info(sockname,#data{ssh_params = S}) ->
    S#ssh.local;
conn_info(options,#data{ssh_params = #ssh{opts = Opts}}) ->
    lists:sort(maps:to_list(ssh_options:keep_set_options(client,ssh_options:keep_user_options(client,Opts))));
conn_info(algorithms,#data{ssh_params = #ssh{algorithms = A}}) ->
    conn_info_alg(A);
conn_info(channels,D) ->
    try conn_info_chans(ets:tab2list(cache(D)))
        catch
            _:_->
                undefined end;
conn_info(socket,D) ->
    D#data.socket;
conn_info(chan_ids,D) ->
    ssh_client_channel:cache_foldl(fun (#channel{local_id = Id},Acc)->
        [Id| Acc] end,[],cache(D)).

conn_info_chans(Chs) ->
    Fs = record_info(fields,channel),
    [(lists:zip(Fs,tl(tuple_to_list(Ch)))) || Ch = #channel{} <- Chs].

conn_info_alg(AlgTup) ->
    [alg| Vs] = tuple_to_list(AlgTup),
    Fs = record_info(fields,alg),
    [{K,V} || {K,V} <- lists:zip(Fs,Vs),lists:member(K,[kex, hkey, encrypt, decrypt, send_mac, recv_mac, compress, decompress, send_ext_info, recv_ext_info])].

chann_info(recv_window,C) ->
    {{win_size,C#channel.recv_window_size},{packet_size,C#channel.recv_packet_size}};
chann_info(send_window,C) ->
    {{win_size,C#channel.send_window_size},{packet_size,C#channel.send_packet_size}};
chann_info(pid,C) ->
    C#channel.user.

fold_keys(Keys,Fun,Extra) ->
    lists:foldr(fun (Key,Acc)->
        try Fun(Key,Extra) of 
            Value->
                [{Key,Value}| Acc]
            catch
                _:_->
                    Acc end end,[],Keys).

log(Tag,D,Format,Args) ->
    log(Tag,D,io_lib:format(Format,Args)).

log(Tag,D,Reason) ->
    case atom_to_list(Tag) of
        "error"->
            do_log(error_msg,Reason,D);
        "warning"->
            do_log(warning_msg,Reason,D);
        "info"->
            do_log(info_msg,Reason,D)
    end.

do_log(F,Reason0,#data{ssh_params = S}) ->
    Reason = try io_lib:format("~s",[Reason0]) of 
        _->
            Reason0
        catch
            _:_->
                io_lib:format("~p",[Reason0]) end,
    case S of
        #ssh{role = Role}
            when Role == server;
            Role == client->
            {PeerRole,PeerVersion} = case Role of
                server->
                    {"Client",S#ssh.c_version};
                client->
                    {"Server",S#ssh.s_version}
            end,
            error_logger:F("Erlang SSH ~p ~s ~s.~n~s: ~p~n~s~n",[Role, ssh_log_version(), crypto_log_info(), PeerRole, PeerVersion, Reason]);
        _->
            error_logger:F("Erlang SSH ~s ~s.~n~s~n",[ssh_log_version(), crypto_log_info(), Reason])
    end.

crypto_log_info() ->
    try [{_,_,CI}] = crypto:info_lib(),
    case crypto:info_fips() of
        enabled->
            <<"(",CI/binary,". FIPS enabled)">>;
        not_enabled->
            <<"(",CI/binary,". FIPS available but not enabled)">>;
        _->
            <<"(",CI/binary,")">>
    end
        catch
            _:_->
                "" end.

ssh_log_version() ->
    case application:get_key(ssh,vsn) of
        {ok,Vsn}->
            Vsn;
        undefined->
            ""
    end.

not_connected_filter({connection_reply,_Data}) ->
    true;
not_connected_filter(_) ->
    false.

send_replies({Repls,C = #connection{}},D)
    when is_list(Repls)->
    send_replies(Repls,D#data{connection_state = C});
send_replies(Repls,State) ->
    lists:foldl(fun get_repl/2,{[],State},Repls).

get_repl({connection_reply,Msg},{CallRepls,S}) ->
    if is_record(Msg,ssh_msg_channel_success) ->
        update_inet_buffers(S#data.socket);true ->
        ok end,
    {CallRepls,send_msg(Msg,S)};
get_repl({channel_data,undefined,_Data},Acc) ->
    Acc;
get_repl({channel_data,Pid,Data},Acc) ->
    Pid ! {ssh_cm,self(),Data},
    Acc;
get_repl({channel_request_reply,From,Data},{CallRepls,S}) ->
    {[{reply,From,Data}| CallRepls],S};
get_repl({flow_control,Cache,Channel,From,Msg},{CallRepls,S}) ->
    ssh_client_channel:cache_update(Cache,Channel#channel{flow_control = undefined}),
    {[{reply,From,Msg}| CallRepls],S};
get_repl({flow_control,From,Msg},{CallRepls,S}) ->
    {[{reply,From,Msg}| CallRepls],S};
get_repl(X,Acc) ->
    exit({get_repl,X,Acc}).

disconnect_fun(Reason,D) ->
     catch (ssh_options:get_value(user_options,disconnectfun,(D#data.ssh_params)#ssh.opts,ssh_connection_handler,2420))(Reason).

unexpected_fun(UnexpectedMessage,#data{ssh_params = #ssh{peer = {_,Peer}}} = D) ->
     catch (ssh_options:get_value(user_options,unexpectedfun,(D#data.ssh_params)#ssh.opts,ssh_connection_handler,2423))(UnexpectedMessage,Peer).

debug_fun(#ssh_msg_debug{always_display = Display,message = DbgMsg,language = Lang},D) ->
     catch (ssh_options:get_value(user_options,ssh_msg_debug_fun,(D#data.ssh_params)#ssh.opts,ssh_connection_handler,2429))(self(),Display,DbgMsg,Lang).

connected_fun(User,Method,#data{ssh_params = #ssh{peer = {_,Peer}}} = D) ->
     catch (ssh_options:get_value(user_options,connectfun,(D#data.ssh_params)#ssh.opts,ssh_connection_handler,2433))(User,Peer,Method).

retry_fun(_,undefined,_) ->
    ok;
retry_fun(User,Reason,#data{ssh_params = #ssh{opts = Opts,peer = {_,Peer}}}) ->
    {Tag,Info} = case Reason of
        {error,Error}->
            {failfun,Error};
        _->
            {infofun,Reason}
    end,
    Fun = ssh_options:get_value(user_options,Tag,Opts,ssh_connection_handler,2448),
    try erlang:fun_info(Fun,arity) of 
        {arity,2}->
             catch Fun(User,Info);
        {arity,3}->
             catch Fun(User,Peer,Info);
        _->
            ok
        catch
            _:_->
                ok end.

cond_set_idle_timer(D) ->
    case ssh_client_channel:cache_info(num_entries,cache(D)) of
        0->
            {{timeout,idle_time},ssh_options:get_value(user_options,idle_time,(D#data.ssh_params)#ssh.opts,ssh_connection_handler,2468),none};
        _->
            {{timeout,idle_time},infinity,none}
    end.

start_channel_request_timer(_,_,infinity) ->
    ok;
start_channel_request_timer(Channel,From,Time) ->
    erlang:send_after(Time,self(),{timeout,{Channel,From}}).

socket_control(Socket,Pid,Options) ->
    {_,Callback,_} = ssh_options:get_value(user_options,transport,Options,ssh_connection_handler,2482),
    case Callback:controlling_process(Socket,Pid) of
        ok->
            gen_statem:cast(Pid,socket_control);
        {error,Reason}->
            {error,Reason}
    end.

handshake(Pid,Ref,Timeout) ->
    receive ssh_connected->
        demonitor(Ref),
        {ok,Pid};
    {Pid,not_connected,Reason}->
        {error,Reason};
    {Pid,user_password}->
        Pass = io:get_password(),
        Pid ! Pass,
        handshake(Pid,Ref,Timeout);
    {Pid,question}->
        Answer = io:get_line(""),
        Pid ! Answer,
        handshake(Pid,Ref,Timeout);
    {'DOWN',_,process,Pid,{shutdown,Reason}}->
        {error,Reason};
    {'DOWN',_,process,Pid,Reason}->
        {error,Reason} after Timeout->
        stop(Pid),
        {error,timeout} end.

update_inet_buffers(Socket) ->
    try {ok,BufSzs0} = inet:getopts(Socket,[sndbuf, recbuf]),
    MinVal = 655360,
    [{Tag,MinVal} || {Tag,Val} <- BufSzs0,Val < MinVal] of 
        []->
            ok;
        NewOpts->
            inet:setopts(Socket,NewOpts)
        catch
            _:_->
                ok end.

ssh_dbg_trace_points() ->
    [terminate, disconnect, connections, connection_events, renegotiation].

ssh_dbg_flags(connections) ->
    [c| ssh_dbg_flags(terminate)];
ssh_dbg_flags(renegotiation) ->
    [c];
ssh_dbg_flags(connection_events) ->
    [c];
ssh_dbg_flags(terminate) ->
    [c];
ssh_dbg_flags(disconnect) ->
    [c].

ssh_dbg_on(connections) ->
    dbg:tp(ssh_connection_handler,init_connection_handler,3,x),
    ssh_dbg_on(terminate);
ssh_dbg_on(connection_events) ->
    dbg:tp(ssh_connection_handler,handle_event,4,x);
ssh_dbg_on(renegotiation) ->
    dbg:tpl(ssh_connection_handler,init_renegotiate_timers,3,x),
    dbg:tpl(ssh_connection_handler,pause_renegotiate_timers,3,x),
    dbg:tpl(ssh_connection_handler,check_data_rekeying_dbg,2,x),
    dbg:tpl(ssh_connection_handler,start_rekeying,2,x),
    dbg:tp(ssh_connection_handler,renegotiate,1,x);
ssh_dbg_on(terminate) ->
    dbg:tp(ssh_connection_handler,terminate,3,x);
ssh_dbg_on(disconnect) ->
    dbg:tpl(ssh_connection_handler,send_disconnect,7,x).

ssh_dbg_off(disconnect) ->
    dbg:ctpl(ssh_connection_handler,send_disconnect,7);
ssh_dbg_off(terminate) ->
    dbg:ctpg(ssh_connection_handler,terminate,3);
ssh_dbg_off(renegotiation) ->
    dbg:ctpl(ssh_connection_handler,init_renegotiate_timers,3),
    dbg:ctpl(ssh_connection_handler,pause_renegotiate_timers,3),
    dbg:ctpl(ssh_connection_handler,check_data_rekeying_dbg,2),
    dbg:ctpl(ssh_connection_handler,start_rekeying,2),
    dbg:ctpg(ssh_connection_handler,renegotiate,1);
ssh_dbg_off(connection_events) ->
    dbg:ctpg(ssh_connection_handler,handle_event,4);
ssh_dbg_off(connections) ->
    dbg:ctpg(ssh_connection_handler,init_connection_handler,3),
    ssh_dbg_off(terminate).

ssh_dbg_format(connections,{call,{ssh_connection_handler,init_connection_handler,[Role, Sock, Opts]}}) ->
    DefaultOpts = ssh_options:handle_options(Role,[]),
    ExcludedKeys = [internal_options, user_options],
    NonDefaultOpts = maps:filter(fun (K,V)->
        case lists:member(K,ExcludedKeys) of
            true->
                false;
            false->
                V =/= ( catch maps:get(K,DefaultOpts))
        end end,Opts),
    {ok,{IPp,Portp}} = inet:peername(Sock),
    {ok,{IPs,Ports}} = inet:sockname(Sock),
    [io_lib:format("Starting ~p connection:\n",[Role]), io_lib:format("Socket = ~p, Peer = ~s:~p, Local = ~s:~p,~nNon-defa" "ult options:~n~p",[Sock, inet:ntoa(IPp), Portp, inet:ntoa(IPs), Ports, NonDefaultOpts])];
ssh_dbg_format(connections,F) ->
    ssh_dbg_format(terminate,F);
ssh_dbg_format(connection_events,{call,{ssh_connection_handler,handle_event,[EventType, EventContent, State, _Data]}}) ->
    ["Connection event\n", io_lib:format("EventType: ~p~nEventContent: ~p~nState: ~p~n",[EventType, EventContent, State])];
ssh_dbg_format(connection_events,{return_from,{ssh_connection_handler,handle_event,4},Ret}) ->
    ["Connection event result\n", io_lib:format("~p~n",[ssh_dbg:reduce_state(Ret,#data{})])];
ssh_dbg_format(renegotiation,{call,{ssh_connection_handler,init_renegotiate_timers,[OldState, NewState, D]}}) ->
    ["Renegotiation: start timer (init_renegotiate_timers)\n", io_lib:format("State: ~p  -->  ~p~nrekey_limit: ~p ({ms,bytes})~nc" "heck_data_size: ~p (ms)~n",[OldState, NewState, ssh_options:get_value(user_options,rekey_limit,(D#data.ssh_params)#ssh.opts,ssh_connection_handler,2603), 60000])];
ssh_dbg_format(renegotiation,{return_from,{ssh_connection_handler,init_renegotiate_timers,3},_Ret}) ->
    skip;
ssh_dbg_format(renegotiation,{call,{ssh_connection_handler,renegotiate,[ConnectionHandler]}}) ->
    ["Renegotiation: renegotiation forced\n", io_lib:format("~p:renegotiate(~p) called~n",[ssh_connection_handler, ConnectionHandler])];
ssh_dbg_format(renegotiation,{return_from,{ssh_connection_handler,renegotiate,1},_Ret}) ->
    skip;
ssh_dbg_format(renegotiation,{call,{ssh_connection_handler,pause_renegotiate_timers,[OldState, NewState, _D]}}) ->
    ["Renegotiation: pause timers\n", io_lib:format("State: ~p  -->  ~p~n",[OldState, NewState])];
ssh_dbg_format(renegotiation,{return_from,{ssh_connection_handler,pause_renegotiate_timers,3},_Ret}) ->
    skip;
ssh_dbg_format(renegotiation,{call,{ssh_connection_handler,start_rekeying,[_Role, _D]}}) ->
    ["Renegotiation: start rekeying\n"];
ssh_dbg_format(renegotiation,{return_from,{ssh_connection_handler,start_rekeying,2},_Ret}) ->
    skip;
ssh_dbg_format(renegotiation,{call,{ssh_connection_handler,check_data_rekeying_dbg,[SentSinceRekey, MaxSent]}}) ->
    ["Renegotiation: check size of data sent\n", io_lib:format("TotalSentSinceRekey: ~p~nMaxBeforeRekey: ~p~nStartR" "ekey: ~p~n",[SentSinceRekey, MaxSent, SentSinceRekey >= MaxSent])];
ssh_dbg_format(renegotiation,{return_from,{ssh_connection_handler,check_data_rekeying_dbg,2},_Ret}) ->
    skip;
ssh_dbg_format(terminate,{call,{ssh_connection_handler,terminate,[Reason, StateName, D]}}) ->
    ExtraInfo = try {conn_info(peer,D),conn_info(user,D),conn_info(sockname,D)} of 
        {{_,{IPp,Portp}},Usr,{IPs,Ports}}
            when is_tuple(IPp),
            is_tuple(IPs),
            is_integer(Portp),
            is_integer(Ports)->
            io_lib:format("Peer=~s:~p, Local=~s:~p, User=~p",[inet:ntoa(IPp), Portp, inet:ntoa(IPs), Ports, Usr]);
        {Peer,Usr,Sockname}->
            io_lib:format("Peer=~p, Local=~p, User=~p",[Peer, Sockname, Usr])
        catch
            _:_->
                "" end,
    if Reason == normal;
    Reason == shutdown;
    element(1,Reason) == shutdown ->
        ["Connection Terminating:\n", io_lib:format("Reason: ~p, StateName: ~p~n~s",[Reason, StateName, ExtraInfo])];true ->
        ["Connection Terminating:\n", io_lib:format("Reason: ~p, StateName: ~p~n~s~nStateData = " "~p",[Reason, StateName, ExtraInfo, state_data2proplist(D)])] end;
ssh_dbg_format(renegotiation,{return_from,{ssh_connection_handler,terminate,3},_Ret}) ->
    skip;
ssh_dbg_format(disconnect,{call,{ssh_connection_handler,send_disconnect,[Code, Reason, DetailedText, Module, Line, StateName, _D]}}) ->
    ["Disconnecting:\n", io_lib:format(" Module = ~p, Line = ~p, StateName = ~p,~n Code = ~" "p, Reason = ~p,~n DetailedText =~n ~p",[Module, Line, StateName, Code, Reason, lists:flatten(DetailedText)])];
ssh_dbg_format(renegotiation,{return_from,{ssh_connection_handler,send_disconnect,7},_Ret}) ->
    skip.
-file("ssh_connection.erl", 1).

-module(ssh_connection).

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

-file("ssh_connection.erl", 30).

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

-file("ssh_connection.erl", 31).

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

-file("ssh_connection.erl", 32).

-export([session_channel/2, session_channel/4, exec/4, shell/2, subsystem/4, send/3, send/4, send/5, send_eof/2, adjust_window/3, setenv/5, close/2, reply_request/4, ptty_alloc/3, ptty_alloc/4]).

-export([window_change/4, window_change/6, signal/3, exit_status/3]).

-export([channel_data/5, handle_msg/4, handle_stop/1, open_channel/4, channel_adjust_window_msg/2, channel_close_msg/1, channel_open_failure_msg/4, channel_open_msg/5, channel_status_msg/1, channel_data_msg/3, channel_eof_msg/1, channel_failure_msg/1, channel_open_confirmation_msg/4, channel_request_msg/4, channel_success_msg/1, request_global_msg/3, request_failure_msg/0, request_success_msg/1, send_environment_vars/3, encode_ip/1]).

-export([encode_pty_opts/1, decode_pty_opts/1]).

-type(connection_ref()::ssh:connection_ref()).

-type(channel_id()::ssh:channel_id()).

-type(req_status()::success|failure).

-type(reason()::closed|timeout).

-type(result()::req_status()|{error,reason()}).

-type(ssh_data_type_code()::non_neg_integer()).

-export_type([event/0, channel_msg/0, want_reply/0, data_ch_msg/0, eof_ch_msg/0, signal_ch_msg/0, exit_signal_ch_msg/0, exit_status_ch_msg/0, closed_ch_msg/0, env_ch_msg/0, pty_ch_msg/0, shell_ch_msg/0, window_change_ch_msg/0, exec_ch_msg/0]).

-type(event()::{ssh_cm,ssh:connection_ref(),channel_msg()}).

-type(channel_msg()::data_ch_msg()|eof_ch_msg()|closed_ch_msg()|pty_ch_msg()|env_ch_msg()|shell_ch_msg()|exec_ch_msg()|signal_ch_msg()|window_change_ch_msg()|exit_status_ch_msg()|exit_signal_ch_msg()).

-type(want_reply()::boolean()).

-type(data_ch_msg()::{data,ssh:channel_id(),ssh_data_type_code(),Data::binary()}).

-type(eof_ch_msg()::{eof,ssh:channel_id()}).

-type(signal_ch_msg()::{signal,ssh:channel_id(),SignalName::string()}).

-type(exit_signal_ch_msg()::{exit_signal,ssh:channel_id(),ExitSignal::string(),ErrorMsg::string(),LanguageString::string()}).

-type(exit_status_ch_msg()::{exit_status,ssh:channel_id(),ExitStatus::non_neg_integer()}).

-type(closed_ch_msg()::{closed,ssh:channel_id()}).

-type(env_ch_msg()::{env,ssh:channel_id(),want_reply(),Var::string(),Value::string()}).

-type(pty_ch_msg()::{pty,ssh:channel_id(),want_reply(),{Terminal::string(),CharWidth::non_neg_integer(),RowHeight::non_neg_integer(),PixelWidth::non_neg_integer(),PixelHeight::non_neg_integer(),TerminalModes::[term_mode()]}}).

-type(term_mode()::{Opcode::atom()|byte(),Value::non_neg_integer()}).

-type(shell_ch_msg()::{shell,ssh:channel_id(),want_reply()}).

-type(window_change_ch_msg()::{window_change,ssh:channel_id(),CharWidth::non_neg_integer(),RowHeight::non_neg_integer(),PixelWidth::non_neg_integer(),PixelHeight::non_neg_integer()}).

-type(exec_ch_msg()::{exec,ssh:channel_id(),want_reply(),Command::string()}).

-export([dummy/1]).

-spec(dummy(event()) -> false).

dummy(_) ->
    false.

-spec(session_channel(ConnectionRef,Timeout) -> Result when ConnectionRef::ssh:connection_ref(),Timeout::timeout(),Result::{ok,ssh:channel_id()}|{error,reason()}).

session_channel(ConnectionHandler,Timeout) ->
    session_channel(ConnectionHandler,10 * 65536,65536,Timeout).

-spec(session_channel(ConnectionRef,InitialWindowSize,MaxPacketSize,Timeout) -> Result when ConnectionRef::ssh:connection_ref(),InitialWindowSize::pos_integer(),MaxPacketSize::pos_integer(),Timeout::timeout(),Result::{ok,ssh:channel_id()}|{error,reason()}).

session_channel(ConnectionHandler,InitialWindowSize,MaxPacketSize,Timeout) ->
    open_channel(ConnectionHandler,"session",<<>>,InitialWindowSize,MaxPacketSize,Timeout).

open_channel(ConnectionHandler,Type,ChanData,Timeout) ->
    open_channel(ConnectionHandler,Type,ChanData,10 * 65536,65536,Timeout).

open_channel(ConnectionHandler,Type,ChanData,InitialWindowSize,MaxPacketSize,Timeout) ->
    case ssh_connection_handler:open_channel(ConnectionHandler,Type,ChanData,InitialWindowSize,MaxPacketSize,Timeout) of
        {open,Channel}->
            {ok,Channel};
        Error->
            Error
    end.

-spec(exec(ConnectionRef,ChannelId,Command,Timeout) -> result() when ConnectionRef::ssh:connection_ref(),ChannelId::ssh:channel_id(),Command::string(),Timeout::timeout()).

exec(ConnectionHandler,ChannelId,Command,TimeOut) ->
    ssh_connection_handler:request(ConnectionHandler,self(),ChannelId,"exec",true,[<<(size(unicode:characters_to_binary(Command))):32/unsigned-big-integer,(unicode:characters_to_binary(Command))/binary>>],TimeOut).

-spec(shell(ConnectionRef,ChannelId) -> Result when ConnectionRef::ssh:connection_ref(),ChannelId::ssh:channel_id(),Result::ok|success|failure|{error,timeout}).

shell(ConnectionHandler,ChannelId) ->
    ssh_connection_handler:request(ConnectionHandler,self(),ChannelId,"shell",false,<<>>,0).

-spec(subsystem(ConnectionRef,ChannelId,Subsystem,Timeout) -> result() when ConnectionRef::ssh:connection_ref(),ChannelId::ssh:channel_id(),Subsystem::string(),Timeout::timeout()).

subsystem(ConnectionHandler,ChannelId,SubSystem,TimeOut) ->
    ssh_connection_handler:request(ConnectionHandler,self(),ChannelId,"subsystem",true,[<<(size(unicode:characters_to_binary(SubSystem))):32/unsigned-big-integer,(unicode:characters_to_binary(SubSystem))/binary>>],TimeOut).

-spec(send(connection_ref(),channel_id(),iodata()) -> ok|{error,timeout|closed}).

send(ConnectionHandler,ChannelId,Data) ->
    send(ConnectionHandler,ChannelId,0,Data,infinity).

-spec(send(connection_ref(),channel_id(),iodata(),timeout()) -> ok|{error,reason()};(connection_ref(),channel_id(),ssh_data_type_code(),iodata()) -> ok|{error,reason()}).

send(ConnectionHandler,ChannelId,Data,TimeOut)
    when is_integer(TimeOut)->
    send(ConnectionHandler,ChannelId,0,Data,TimeOut);
send(ConnectionHandler,ChannelId,Data,infinity) ->
    send(ConnectionHandler,ChannelId,0,Data,infinity);
send(ConnectionHandler,ChannelId,Type,Data) ->
    send(ConnectionHandler,ChannelId,Type,Data,infinity).

-spec(send(connection_ref(),channel_id(),ssh_data_type_code(),iodata(),timeout()) -> ok|{error,reason()}).

send(ConnectionHandler,ChannelId,Type,Data,TimeOut) ->
    ssh_connection_handler:send(ConnectionHandler,ChannelId,Type,Data,TimeOut).

-spec(send_eof(ConnectionRef,ChannelId) -> ok|{error,closed} when ConnectionRef::ssh:connection_ref(),ChannelId::ssh:channel_id()).

send_eof(ConnectionHandler,Channel) ->
    ssh_connection_handler:send_eof(ConnectionHandler,Channel).

-spec(adjust_window(ConnectionRef,ChannelId,NumOfBytes) -> ok when ConnectionRef::ssh:connection_ref(),ChannelId::ssh:channel_id(),NumOfBytes::integer()).

adjust_window(ConnectionHandler,Channel,Bytes) ->
    ssh_connection_handler:adjust_window(ConnectionHandler,Channel,Bytes).

-spec(setenv(ConnectionRef,ChannelId,Var,Value,Timeout) -> success when ConnectionRef::ssh:connection_ref(),ChannelId::ssh:channel_id(),Var::string(),Value::string(),Timeout::timeout()).

setenv(ConnectionHandler,ChannelId,Var,Value,TimeOut) ->
    setenv(ConnectionHandler,ChannelId,true,Var,Value,TimeOut).

setenv(ConnectionHandler,ChannelId,WantReply,Var,Value,TimeOut) ->
    case ssh_connection_handler:request(ConnectionHandler,ChannelId,"env",WantReply,[<<(size(unicode:characters_to_binary(Var))):32/unsigned-big-integer,(unicode:characters_to_binary(Var))/binary>>, <<(size(unicode:characters_to_binary(Value))):32/unsigned-big-integer,(unicode:characters_to_binary(Value))/binary>>],TimeOut) of
        ok
            when WantReply == false->
            success;
        Reply->
            Reply
    end.

-spec(close(ConnectionRef,ChannelId) -> ok when ConnectionRef::ssh:connection_ref(),ChannelId::ssh:channel_id()).

close(ConnectionHandler,ChannelId) ->
    ssh_connection_handler:close(ConnectionHandler,ChannelId).

-spec(reply_request(ConnectionRef,WantReply,Status,ChannelId) -> ok when ConnectionRef::ssh:connection_ref(),WantReply::boolean(),Status::req_status(),ChannelId::ssh:channel_id()).

reply_request(ConnectionHandler,true,Status,ChannelId) ->
    ssh_connection_handler:reply_request(ConnectionHandler,Status,ChannelId);
reply_request(_,false,_,_) ->
    ok.

-spec(ptty_alloc(ConnectionRef,ChannelId,Options) -> result() when ConnectionRef::ssh:connection_ref(),ChannelId::ssh:channel_id(),Options::proplists:proplist()).

ptty_alloc(ConnectionHandler,Channel,Options) ->
    ptty_alloc(ConnectionHandler,Channel,Options,infinity).

-spec(ptty_alloc(ConnectionRef,ChannelId,Options,Timeout) -> result() when ConnectionRef::ssh:connection_ref(),ChannelId::ssh:channel_id(),Options::proplists:proplist(),Timeout::timeout()).

ptty_alloc(ConnectionHandler,Channel,Options0,TimeOut) ->
    TermData = backwards_compatible(Options0,[]),
    {Width,PixWidth} = pty_default_dimensions(width,TermData),
    {Height,PixHeight} = pty_default_dimensions(height,TermData),
    pty_req(ConnectionHandler,Channel,proplists:get_value(term,TermData,os:getenv("TERM","vt100")),proplists:get_value(width,TermData,Width),proplists:get_value(height,TermData,Height),proplists:get_value(pixel_widh,TermData,PixWidth),proplists:get_value(pixel_height,TermData,PixHeight),proplists:get_value(pty_opts,TermData,[]),TimeOut).

window_change(ConnectionHandler,Channel,Width,Height) ->
    window_change(ConnectionHandler,Channel,Width,Height,0,0).

window_change(ConnectionHandler,Channel,Width,Height,PixWidth,PixHeight) ->
    ssh_connection_handler:request(ConnectionHandler,Channel,"window-change",false,[<<Width:32/unsigned-big-integer>>, <<Height:32/unsigned-big-integer>>, <<PixWidth:32/unsigned-big-integer>>, <<PixHeight:32/unsigned-big-integer>>],0).

signal(ConnectionHandler,Channel,Sig) ->
    ssh_connection_handler:request(ConnectionHandler,Channel,"signal",false,[<<(size(unicode:characters_to_binary(Sig))):32/unsigned-big-integer,(unicode:characters_to_binary(Sig))/binary>>],0).

-spec(exit_status(ConnectionRef,ChannelId,Status) -> ok when ConnectionRef::ssh:connection_ref(),ChannelId::ssh:channel_id(),Status::integer()).

exit_status(ConnectionHandler,Channel,Status) ->
    ssh_connection_handler:request(ConnectionHandler,Channel,"exit-status",false,[<<Status:32/unsigned-big-integer>>],0).

channel_data(ChannelId,DataType,Data0,#connection{channel_cache = Cache} = Connection,From) ->
    case ssh_client_channel:cache_lookup(Cache,ChannelId) of
        #channel{remote_id = Id,sent_close = false} = Channel0->
            Data = try iolist_to_binary(Data0)
                catch
                    _:_->
                        unicode:characters_to_binary(Data0) end,
            {SendList,Channel} = update_send_window(Channel0#channel{flow_control = From},DataType,Data,Connection),
            Replies = lists:map(fun ({SendDataType,SendData})->
                {connection_reply,channel_data_msg(Id,SendDataType,SendData)} end,SendList),
            FlowCtrlMsgs = flow_control(Replies,Channel,Cache),
            {Replies ++ FlowCtrlMsgs,Connection};
        _->
            {[{channel_request_reply,From,{error,closed}}],Connection}
    end.

handle_msg(#ssh_msg_channel_open_confirmation{recipient_channel = ChannelId,sender_channel = RemoteId,initial_window_size = WindowSz,maximum_packet_size = PacketSz},#connection{channel_cache = Cache} = Connection0,_,_SSH) ->
    #channel{remote_id = undefined} = Channel = ssh_client_channel:cache_lookup(Cache,ChannelId),
    ssh_client_channel:cache_update(Cache,Channel#channel{remote_id = RemoteId,recv_packet_size = max(32768,min(PacketSz,Channel#channel.recv_packet_size)),send_window_size = WindowSz,send_packet_size = PacketSz}),
    reply_msg(Channel,Connection0,{open,ChannelId});
handle_msg(#ssh_msg_channel_open_failure{recipient_channel = ChannelId,reason = Reason,description = Descr,lang = Lang},#connection{channel_cache = Cache} = Connection0,_,_SSH) ->
    Channel = ssh_client_channel:cache_lookup(Cache,ChannelId),
    ssh_client_channel:cache_delete(Cache,ChannelId),
    reply_msg(Channel,Connection0,{open_error,Reason,Descr,Lang});
handle_msg(#ssh_msg_channel_success{recipient_channel = ChannelId},Connection,_,_SSH) ->
    reply_msg(ChannelId,Connection,success);
handle_msg(#ssh_msg_channel_failure{recipient_channel = ChannelId},Connection,_,_SSH) ->
    reply_msg(ChannelId,Connection,failure);
handle_msg(#ssh_msg_channel_eof{recipient_channel = ChannelId},Connection,_,_SSH) ->
    reply_msg(ChannelId,Connection,{eof,ChannelId});
handle_msg(#ssh_msg_channel_close{recipient_channel = ChannelId},#connection{channel_cache = Cache} = Connection0,_,_SSH) ->
    case ssh_client_channel:cache_lookup(Cache,ChannelId) of
        #channel{sent_close = Closed,remote_id = RemoteId,flow_control = FlowControl} = Channel->
            ssh_client_channel:cache_delete(Cache,ChannelId),
            {CloseMsg,Connection} = reply_msg(Channel,Connection0,{closed,ChannelId}),
            ConnReplyMsgs = case Closed of
                true->
                    [];
                false->
                    RemoteCloseMsg = channel_close_msg(RemoteId),
                    [{connection_reply,RemoteCloseMsg}]
            end,
            SendReplyMsgs = case FlowControl of
                undefined->
                    [];
                From->
                    [{flow_control,From,{error,closed}}]
            end,
            Replies = ConnReplyMsgs ++ CloseMsg ++ SendReplyMsgs,
            {Replies,Connection};
        undefined->
            {[],Connection0}
    end;
handle_msg(#ssh_msg_channel_data{recipient_channel = ChannelId,data = Data},Connection,_,_SSH) ->
    channel_data_reply_msg(ChannelId,Connection,0,Data);
handle_msg(#ssh_msg_channel_extended_data{recipient_channel = ChannelId,data_type_code = DataType,data = Data},Connection,_,_SSH) ->
    channel_data_reply_msg(ChannelId,Connection,DataType,Data);
handle_msg(#ssh_msg_channel_window_adjust{recipient_channel = ChannelId,bytes_to_add = Add},#connection{channel_cache = Cache} = Connection,_,_SSH) ->
    #channel{send_window_size = Size,remote_id = RemoteId} = Channel0 = ssh_client_channel:cache_lookup(Cache,ChannelId),
    {SendList,Channel} = update_send_window(Channel0#channel{send_window_size = Size + Add},0,undefined,Connection),
    Replies = lists:map(fun ({Type,Data})->
        {connection_reply,channel_data_msg(RemoteId,Type,Data)} end,SendList),
    FlowCtrlMsgs = flow_control(Channel,Cache),
    {Replies ++ FlowCtrlMsgs,Connection};
handle_msg(#ssh_msg_channel_open{channel_type = "session" = Type,sender_channel = RemoteId,initial_window_size = WindowSz,maximum_packet_size = PacketSz},#connection{options = SSHopts} = Connection0,server,_SSH) ->
    MinAcceptedPackSz = ssh_options:get_value(user_options,minimal_remote_max_packet_size,SSHopts,ssh_connection,573),
    if MinAcceptedPackSz =< PacketSz ->
        try setup_session(Connection0,RemoteId,Type,WindowSz,PacketSz) of 
            Result->
                Result
            catch
                _:_->
                    FailMsg = channel_open_failure_msg(RemoteId,2,"Connection refused","en"),
                    {[{connection_reply,FailMsg}],Connection0} end;MinAcceptedPackSz > PacketSz ->
        FailMsg = channel_open_failure_msg(RemoteId,1,lists:concat(["Maximum packet " "size below ", MinAcceptedPackSz, " not supported"]),"en"),
        {[{connection_reply,FailMsg}],Connection0} end;
handle_msg(#ssh_msg_channel_open{channel_type = "forwarded-tcpip",sender_channel = RemoteId,initial_window_size = WindowSize,maximum_packet_size = PacketSize,data = <<_L1:32/unsigned-big-integer,ConnectedHost:_L1/binary,ConnectedPort:32/unsigned-big-integer,_L2:32/unsigned-big-integer,_OriginHost:_L2/binary,_OriginPort:32/unsigned-big-integer>>},#connection{channel_cache = Cache,channel_id_seed = ChId,options = Options,sub_system_supervisor = SubSysSup} = C,client,_SSH) ->
    {ReplyMsg,NextChId} = case ssh_connection_handler:retrieve(C,{tcpip_forward,ConnectedHost,ConnectedPort}) of
        {ok,{ConnectToHost,ConnectToPort}}->
            case gen_tcp:connect(ConnectToHost,ConnectToPort,[{active,false}, binary]) of
                {ok,Sock}->
                    {ok,Pid} = ssh_subsystem_sup:start_channel(client,SubSysSup,self(),ssh_tcpip_forward_client,ChId,[Sock],undefined,Options),
                    ssh_client_channel:cache_update(Cache,#channel{type = "forwa" "rded-" "tcpip",sys = "none",local_id = ChId,remote_id = RemoteId,user = Pid,recv_window_size = 10 * 65536,recv_packet_size = 65536,send_window_size = WindowSize,send_packet_size = PacketSize,send_buf = queue:new()}),
                    gen_tcp:controlling_process(Sock,Pid),
                    inet:setopts(Sock,[{active,once}]),
                    {channel_open_confirmation_msg(RemoteId,ChId,10 * 65536,65536),ChId + 1};
                {error,Error}->
                    {channel_open_failure_msg(RemoteId,2,io_lib:format("Forwar" "ded co" "nnecti" "on ref" "used: " "~p",[Error]),"en"),ChId}
            end;
        undefined->
            {channel_open_failure_msg(RemoteId,2,io_lib:format("No forwarding " "ordered",[]),"en"),ChId}
    end,
    {[{connection_reply,ReplyMsg}],C#connection{channel_id_seed = NextChId}};
handle_msg(#ssh_msg_channel_open{channel_type = "direct-tcpip",sender_channel = RemoteId,initial_window_size = WindowSize,maximum_packet_size = PacketSize,data = <<_L1:32/unsigned-big-integer,HostToConnect:_L1/binary,PortToConnect:32/unsigned-big-integer,_L2:32/unsigned-big-integer,_OriginatorIPaddress:_L2/binary,_OrignatorPort:32/unsigned-big-integer>>},#connection{channel_cache = Cache,channel_id_seed = ChId,options = Options,sub_system_supervisor = SubSysSup} = C,server,_SSH) ->
    {ReplyMsg,NextChId} = case ssh_options:get_value(user_options,tcpip_tunnel_in,Options,ssh_connection,669) of
        false->
            {channel_open_failure_msg(RemoteId,2,"Forwarding disabled","en"),ChId};
        true->
            case gen_tcp:connect(binary_to_list(HostToConnect),PortToConnect,[{active,false}, binary]) of
                {ok,Sock}->
                    {ok,Pid} = ssh_subsystem_sup:start_channel(server,SubSysSup,self(),ssh_tcpip_forward_srv,ChId,[Sock],undefined,Options),
                    ssh_client_channel:cache_update(Cache,#channel{type = "direc" "t-tcp" "ip",sys = "none",local_id = ChId,remote_id = RemoteId,user = Pid,recv_window_size = 10 * 65536,recv_packet_size = 65536,send_window_size = WindowSize,send_packet_size = PacketSize,send_buf = queue:new()}),
                    gen_tcp:controlling_process(Sock,Pid),
                    inet:setopts(Sock,[{active,once}]),
                    {channel_open_confirmation_msg(RemoteId,ChId,10 * 65536,65536),ChId + 1};
                {error,Error}->
                    {channel_open_failure_msg(RemoteId,2,io_lib:format("Forwar" "ded co" "nnecti" "on ref" "used: " "~p",[Error]),"en"),ChId}
            end
    end,
    {[{connection_reply,ReplyMsg}],C#connection{channel_id_seed = NextChId}};
handle_msg(#ssh_msg_channel_open{channel_type = "session",sender_channel = RemoteId},Connection,client,_SSH) ->
    FailMsg = channel_open_failure_msg(RemoteId,2,"Connection refused","en"),
    {[{connection_reply,FailMsg}],Connection};
handle_msg(#ssh_msg_channel_open{sender_channel = RemoteId},Connection,_,_SSH) ->
    FailMsg = channel_open_failure_msg(RemoteId,1,"Not allowed","en"),
    {[{connection_reply,FailMsg}],Connection};
handle_msg(#ssh_msg_channel_request{recipient_channel = ChannelId,request_type = "exit-status",data = Data},Connection,_,_SSH) ->
    <<Status:32/unsigned-big-integer>> = Data,
    reply_msg(ChannelId,Connection,{exit_status,ChannelId,Status});
handle_msg(#ssh_msg_channel_request{recipient_channel = ChannelId,request_type = "exit-signal",want_reply = false,data = Data},#connection{channel_cache = Cache} = Connection0,_,_SSH) ->
    <<_SigLen:32/unsigned-big-integer,SigName:_SigLen/binary,_Core:8/unsigned-big-integer,_ErrLen:32/unsigned-big-integer,Err:_ErrLen/binary,_LangLen:32/unsigned-big-integer,Lang:_LangLen/binary>> = Data,
    Channel = ssh_client_channel:cache_lookup(Cache,ChannelId),
    RemoteId = Channel#channel.remote_id,
    {Reply,Connection} = reply_msg(Channel,Connection0,{exit_signal,ChannelId,binary_to_list(SigName),binary_to_list(Err),binary_to_list(Lang)}),
    CloseMsg = channel_close_msg(RemoteId),
    {[{connection_reply,CloseMsg}| Reply],Connection};
handle_msg(#ssh_msg_channel_request{recipient_channel = ChannelId,request_type = "xon-xoff",want_reply = false,data = Data},Connection,_,_SSH) ->
    <<CDo:8/unsigned-big-integer>> = Data,
    reply_msg(ChannelId,Connection,{xon_xoff,ChannelId,CDo =/= 0});
handle_msg(#ssh_msg_channel_request{recipient_channel = ChannelId,request_type = "window-change",want_reply = false,data = Data},Connection0,_,_SSH) ->
    <<Width:32/unsigned-big-integer,Height:32/unsigned-big-integer,PixWidth:32/unsigned-big-integer,PixHeight:32/unsigned-big-integer>> = Data,
    reply_msg(ChannelId,Connection0,{window_change,ChannelId,Width,Height,PixWidth,PixHeight});
handle_msg(#ssh_msg_channel_request{recipient_channel = ChannelId,request_type = "signal",data = Data},Connection0,_,_SSH) ->
    <<_SigLen:32/unsigned-big-integer,SigName:_SigLen/binary>> = Data,
    reply_msg(ChannelId,Connection0,{signal,ChannelId,binary_to_list(SigName)});
handle_msg(#ssh_msg_channel_request{recipient_channel = ChannelId,request_type = "subsystem",want_reply = WantReply,data = Data},#connection{channel_cache = Cache} = Connection,server,_SSH) ->
    <<_SsLen:32/unsigned-big-integer,SsName:_SsLen/binary>> = Data,
    #channel{remote_id = RemoteId} = Channel = ssh_client_channel:cache_lookup(Cache,ChannelId),
    Reply = case start_subsystem(SsName,Connection,Channel,{subsystem,ChannelId,WantReply,binary_to_list(SsName)}) of
        {ok,Pid}->
            monitor(process,Pid),
            ssh_client_channel:cache_update(Cache,Channel#channel{user = Pid}),
            channel_success_msg(RemoteId);
        {error,_Error}->
            channel_failure_msg(RemoteId)
    end,
    {[{connection_reply,Reply}],Connection};
handle_msg(#ssh_msg_channel_request{request_type = "subsystem"},Connection,client,_SSH) ->
    {[],Connection};
handle_msg(#ssh_msg_channel_request{recipient_channel = ChannelId,request_type = "pty-req",want_reply = WantReply,data = Data},Connection,server,SSH) ->
    <<_TermLen:32/unsigned-big-integer,BTermName:_TermLen/binary,Width:32/unsigned-big-integer,Height:32/unsigned-big-integer,PixWidth:32/unsigned-big-integer,PixHeight:32/unsigned-big-integer,Modes/binary>> = Data,
    TermName = binary_to_list(BTermName),
    PtyOpts0 = decode_pty_opts(Modes),
    PtyOpts = case SSH#ssh.c_version of
        "SSH-2.0-PuTTY" ++ _->
            case proplists:get_value(onlcr,PtyOpts0,undefined) of
                undefined->
                    [{onlcr,1}| PtyOpts0];
                _->
                    PtyOpts0
            end;
        _->
            PtyOpts0
    end,
    PtyRequest = {TermName,Width,Height,PixWidth,PixHeight,PtyOpts},
    handle_cli_msg(Connection,ChannelId,{pty,ChannelId,WantReply,PtyRequest});
handle_msg(#ssh_msg_channel_request{request_type = "pty-req"},Connection,client,_SSH) ->
    {[],Connection};
handle_msg(#ssh_msg_channel_request{recipient_channel = ChannelId,request_type = "shell",want_reply = WantReply},Connection,server,_SSH) ->
    handle_cli_msg(Connection,ChannelId,{shell,ChannelId,WantReply});
handle_msg(#ssh_msg_channel_request{request_type = "shell"},Connection,client,_SSH) ->
    {[],Connection};
handle_msg(#ssh_msg_channel_request{recipient_channel = ChannelId,request_type = "exec",want_reply = WantReply,data = Data},Connection,server,_SSH) ->
    <<_Len:32/unsigned-big-integer,Command:_Len/binary>> = Data,
    handle_cli_msg(Connection,ChannelId,{exec,ChannelId,WantReply,binary_to_list(Command)});
handle_msg(#ssh_msg_channel_request{request_type = "exec"},Connection,client,_SSH) ->
    {[],Connection};
handle_msg(#ssh_msg_channel_request{recipient_channel = ChannelId,request_type = "env",want_reply = WantReply,data = Data},Connection,server,_SSH) ->
    <<_VarLen:32/unsigned-big-integer,Var:_VarLen/binary,_ValLen:32/unsigned-big-integer,Value:_ValLen/binary>> = Data,
    handle_cli_msg(Connection,ChannelId,{env,ChannelId,WantReply,Var,Value});
handle_msg(#ssh_msg_channel_request{request_type = "env"},Connection,client,_SSH) ->
    {[],Connection};
handle_msg(#ssh_msg_channel_request{recipient_channel = ChannelId,want_reply = WantReply},#connection{channel_cache = Cache} = Connection,_,_SSH) ->
    case ssh_client_channel:cache_lookup(Cache,ChannelId) of
        #channel{remote_id = RemoteId}
            when WantReply == true->
            FailMsg = channel_failure_msg(RemoteId),
            {[{connection_reply,FailMsg}],Connection};
        _->
            {[],Connection}
    end;
handle_msg(#ssh_msg_global_request{name = <<"tcpip-forward">>,want_reply = WantReply,data = <<_Len:32/unsigned-big-integer,ListenAddrStr:_Len/binary,ListenPort:32/unsigned-big-integer>>},#connection{options = Opts} = Connection,server,_SSH) ->
    case ssh_options:get_value(user_options,tcpip_tunnel_out,Opts,ssh_connection,915) of
        false->
            {[{connection_reply,request_failure_msg()}],Connection};
        true->
            Sups = ssh_options:get_value(internal_options,supervisors,Opts,ssh_connection,921),
            SubSysSup = proplists:get_value(subsystem_sup,Sups),
            FwdSup = ssh_subsystem_sup:tcpip_fwd_supervisor(SubSysSup),
            ConnPid = self(),
            case ssh_tcpip_forward_acceptor:supervised_start(FwdSup,{ListenAddrStr,ListenPort},undefined,"forwarded-" "tcpip",ssh_tcpip_forward_srv,ConnPid) of
                {ok,ListenPort}
                    when WantReply == true->
                    {[{connection_reply,request_success_msg(<<>>)}],Connection};
                {ok,LPort}
                    when WantReply == true->
                    {[{connection_reply,request_success_msg(<<LPort:32/unsigned-big-integer>>)}],Connection};
                {error,_}
                    when WantReply == true->
                    {[{connection_reply,request_failure_msg()}],Connection};
                _
                    when WantReply == true->
                    {[{connection_reply,request_failure_msg()}],Connection};
                _->
                    {[],Connection}
            end
    end;
handle_msg(#ssh_msg_global_request{name = _Type,want_reply = WantReply,data = _Data},Connection,_Role,_SSH) ->
    if WantReply == true ->
        FailMsg = request_failure_msg(),
        {[{connection_reply,FailMsg}],Connection};true ->
        {[],Connection} end;
handle_msg(#ssh_msg_request_failure{},#connection{requests = [{_,From}| Rest]} = Connection,_,_SSH) ->
    {[{channel_request_reply,From,{failure,<<>>}}],Connection#connection{requests = Rest}};
handle_msg(#ssh_msg_request_failure{},#connection{requests = [{_,From,_}| Rest]} = Connection,_,_SSH) ->
    {[{channel_request_reply,From,{failure,<<>>}}],Connection#connection{requests = Rest}};
handle_msg(#ssh_msg_request_success{data = Data},#connection{requests = [{_,From}| Rest]} = Connection,_,_SSH) ->
    {[{channel_request_reply,From,{success,Data}}],Connection#connection{requests = Rest}};
handle_msg(#ssh_msg_request_success{data = Data},#connection{requests = [{_,From,Fun}| Rest]} = Connection0,_,_SSH) ->
    Connection = Fun({success,Data},Connection0),
    {[{channel_request_reply,From,{success,Data}}],Connection#connection{requests = Rest}};
handle_msg(#ssh_msg_disconnect{code = Code,description = Description},Connection,_,_SSH) ->
    {disconnect,{Code,Description},handle_stop(Connection)}.

handle_stop(#connection{channel_cache = Cache} = Connection0) ->
    {Connection,Replies} = ssh_client_channel:cache_foldl(fun (Channel,{Connection1,Acc})->
        {Reply,Connection2} = reply_msg(Channel,Connection1,{closed,Channel#channel.local_id}),
        {Connection2,Reply ++ Acc} end,{Connection0,[]},Cache),
    ssh_client_channel:cache_delete(Cache),
    {Replies,Connection}.

channel_adjust_window_msg(ChannelId,Bytes) ->
    #ssh_msg_channel_window_adjust{recipient_channel = ChannelId,bytes_to_add = Bytes}.

channel_close_msg(ChannelId) ->
    #ssh_msg_channel_close{recipient_channel = ChannelId}.

channel_data_msg(ChannelId,0,Data) ->
    #ssh_msg_channel_data{recipient_channel = ChannelId,data = Data};
channel_data_msg(ChannelId,Type,Data) ->
    #ssh_msg_channel_extended_data{recipient_channel = ChannelId,data_type_code = Type,data = Data}.

channel_eof_msg(ChannelId) ->
    #ssh_msg_channel_eof{recipient_channel = ChannelId}.

channel_failure_msg(ChannelId) ->
    #ssh_msg_channel_failure{recipient_channel = ChannelId}.

channel_open_msg(Type,ChannelId,WindowSize,MaxPacketSize,Data) ->
    #ssh_msg_channel_open{channel_type = Type,sender_channel = ChannelId,initial_window_size = WindowSize,maximum_packet_size = MaxPacketSize,data = Data}.

channel_open_confirmation_msg(RemoteId,LID,WindowSize,PacketSize) ->
    #ssh_msg_channel_open_confirmation{recipient_channel = RemoteId,sender_channel = LID,initial_window_size = WindowSize,maximum_packet_size = PacketSize}.

channel_open_failure_msg(RemoteId,Reason,Description,Lang) ->
    #ssh_msg_channel_open_failure{recipient_channel = RemoteId,reason = Reason,description = Description,lang = Lang}.

channel_status_msg({success,ChannelId}) ->
    channel_success_msg(ChannelId);
channel_status_msg({failure,ChannelId}) ->
    channel_failure_msg(ChannelId).

channel_request_msg(ChannelId,Type,WantReply,Data) ->
    #ssh_msg_channel_request{recipient_channel = ChannelId,request_type = Type,want_reply = WantReply,data = Data}.

channel_success_msg(ChannelId) ->
    #ssh_msg_channel_success{recipient_channel = ChannelId}.

request_global_msg(Name,WantReply,Data) ->
    #ssh_msg_global_request{name = Name,want_reply = WantReply,data = Data}.

request_failure_msg() ->
    #ssh_msg_request_failure{}.

request_success_msg(Data) ->
    #ssh_msg_request_success{data = Data}.

encode_ip(Addr)
    when is_tuple(Addr)->
    case  catch inet_parse:ntoa(Addr) of
        {'EXIT',_}->
            false;
        A->
            A
    end;
encode_ip(Addr)
    when is_list(Addr)->
    case inet_parse:address(Addr) of
        {ok,_}->
            Addr;
        Error->
            case inet:getaddr(Addr,inet) of
                {ok,A}->
                    inet_parse:ntoa(A);
                Error->
                    false
            end
    end.

setup_session(#connection{channel_cache = Cache,channel_id_seed = NewChannelID} = C,RemoteId,Type,WindowSize,PacketSize) ->
    NextChannelID = NewChannelID + 1,
    Channel = #channel{type = Type,sys = "ssh",local_id = NewChannelID,recv_window_size = 10 * 65536,recv_packet_size = 65536,send_window_size = WindowSize,send_packet_size = PacketSize,send_buf = queue:new(),remote_id = RemoteId},
    ssh_client_channel:cache_update(Cache,Channel),
    OpenConfMsg = channel_open_confirmation_msg(RemoteId,NewChannelID,10 * 65536,65536),
    Reply = {connection_reply,OpenConfMsg},
    {[Reply],C#connection{channel_id_seed = NextChannelID}}.

start_cli(#connection{options = Options,cli_spec = CliSpec,exec = Exec,sub_system_supervisor = SubSysSup},ChannelId) ->
    case CliSpec of
        no_cli->
            {error,cli_disabled};
        {CbModule,Args}->
            ssh_subsystem_sup:start_channel(server,SubSysSup,self(),CbModule,ChannelId,Args,Exec,Options)
    end.

start_subsystem(BinName,#connection{options = Options,sub_system_supervisor = SubSysSup},#channel{local_id = ChannelId},_ReplyMsg) ->
    Name = binary_to_list(BinName),
    case check_subsystem(Name,Options) of
        {Callback,Opts}
            when is_atom(Callback),
            Callback =/= none->
            ssh_subsystem_sup:start_channel(server,SubSysSup,self(),Callback,ChannelId,Opts,undefined,Options);
        {none,_}->
            {error,bad_subsystem};
        {_,_}->
            {error,legacy_option_not_supported}
    end.

check_subsystem("sftp" = SsName,Options) ->
    case ssh_options:get_value(user_options,subsystems,Options,ssh_connection,1159) of
        no_subsys->
            {SsName,{Cb,Opts}} = ssh_sftpd:subsystem_spec([]),
            {Cb,Opts};
        SubSystems->
            proplists:get_value(SsName,SubSystems,{none,[]})
    end;
check_subsystem(SsName,Options) ->
    Subsystems = ssh_options:get_value(user_options,subsystems,Options,ssh_connection,1168),
    case proplists:get_value(SsName,Subsystems,{none,[]}) of
        Fun
            when is_function(Fun)->
            {Fun,[]};
        {_,_} = Value->
            Value
    end.

update_send_window(Channel,_,undefined,#connection{channel_cache = Cache}) ->
    do_update_send_window(Channel,Cache);
update_send_window(#channel{send_buf = SendBuffer} = Channel,DataType,Data,#connection{channel_cache = Cache}) ->
    do_update_send_window(Channel#channel{send_buf = queue:in({DataType,Data},SendBuffer)},Cache).

do_update_send_window(Channel0,Cache) ->
    {SendMsgs,Channel} = get_window(Channel0,[]),
    ssh_client_channel:cache_update(Cache,Channel),
    {SendMsgs,Channel}.

get_window(#channel{send_window_size = 0} = Channel,Acc) ->
    {lists:reverse(Acc),Channel};
get_window(#channel{send_packet_size = 0} = Channel,Acc) ->
    {lists:reverse(Acc),Channel};
get_window(#channel{send_buf = Buffer,send_packet_size = PacketSize,send_window_size = WindowSize0} = Channel,Acc0) ->
    case queue:out(Buffer) of
        {{value,{_,Data} = Msg},NewBuffer}->
            case handle_send_window(Msg,size(Data),PacketSize,WindowSize0,Acc0) of
                {WindowSize,Acc,{_,<<>>}}->
                    {lists:reverse(Acc),Channel#channel{send_window_size = WindowSize,send_buf = NewBuffer}};
                {WindowSize,Acc,Rest}->
                    get_window(Channel#channel{send_window_size = WindowSize,send_buf = queue:in_r(Rest,NewBuffer)},Acc)
            end;
        {empty,NewBuffer}->
            {[],Channel#channel{send_buf = NewBuffer}}
    end.

handle_send_window(Msg = {Type,Data},Size,PacketSize,WindowSize,Acc)
    when Size =< WindowSize->
    case Size =< PacketSize of
        true->
            {WindowSize - Size,[Msg| Acc],{Type,<<>>}};
        false->
            <<Msg1:PacketSize/binary,Msg2/binary>> = Data,
            {WindowSize - PacketSize,[{Type,Msg1}| Acc],{Type,Msg2}}
    end;
handle_send_window({Type,Data},_,PacketSize,WindowSize,Acc)
    when WindowSize =< PacketSize->
    <<Msg1:WindowSize/binary,Msg2/binary>> = Data,
    {WindowSize - WindowSize,[{Type,Msg1}| Acc],{Type,Msg2}};
handle_send_window({Type,Data},_,PacketSize,WindowSize,Acc) ->
    <<Msg1:PacketSize/binary,Msg2/binary>> = Data,
    {WindowSize - PacketSize,[{Type,Msg1}| Acc],{Type,Msg2}}.

flow_control(Channel,Cache) ->
    flow_control([window_adjusted],Channel,Cache).

flow_control([],Channel,Cache) ->
    ssh_client_channel:cache_update(Cache,Channel),
    [];
flow_control([_| _],#channel{flow_control = From,send_buf = Buffer} = Channel,Cache)
    when From =/= undefined->
    case queue:is_empty(Buffer) of
        true->
            ssh_client_channel:cache_update(Cache,Channel#channel{flow_control = undefined}),
            [{flow_control,Cache,Channel,From,ok}];
        false->
            []
    end;
flow_control(_,_,_) ->
    [].

pty_req(ConnectionHandler,Channel,Term,Width,Height,PixWidth,PixHeight,PtyOpts,TimeOut) ->
    ssh_connection_handler:request(ConnectionHandler,Channel,"pty-req",true,[<<(size(unicode:characters_to_binary(Term))):32/unsigned-big-integer,(unicode:characters_to_binary(Term))/binary>>, <<Width:32/unsigned-big-integer>>, <<Height:32/unsigned-big-integer>>, <<PixWidth:32/unsigned-big-integer>>, <<PixHeight:32/unsigned-big-integer>>, encode_pty_opts(PtyOpts)],TimeOut).

pty_default_dimensions(Dimension,TermData) ->
    case proplists:get_value(Dimension,TermData,0) of
        N
            when is_integer(N),
            N > 0->
            {N,0};
        _->
            PixelDim = list_to_atom("pixel_" ++ atom_to_list(Dimension)),
            case proplists:get_value(PixelDim,TermData,0) of
                N
                    when is_integer(N),
                    N > 0->
                    {0,N};
                _->
                    {80,0}
            end
    end.

encode_pty_opts(Opts) ->
    Bin = list_to_binary(encode_pty_opts2(Opts)),
    <<(size(Bin)):32/unsigned-big-integer,Bin/binary>>.

encode_pty_opts2([]) ->
    [0];
encode_pty_opts2([{vintr,Value}| Opts]) ->
    [1, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{vquit,Value}| Opts]) ->
    [2, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{verase,Value}| Opts]) ->
    [3, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{vkill,Value}| Opts]) ->
    [4, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{veof,Value}| Opts]) ->
    [5, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{veol,Value}| Opts]) ->
    [6, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{veol2,Value}| Opts]) ->
    [7, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{vstart,Value}| Opts]) ->
    [8, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{vstop,Value}| Opts]) ->
    [9, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{vsusp,Value}| Opts]) ->
    [10, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{vdsusp,Value}| Opts]) ->
    [11, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{vreprint,Value}| Opts]) ->
    [12, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{vwerase,Value}| Opts]) ->
    [13, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{vlnext,Value}| Opts]) ->
    [14, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{vflush,Value}| Opts]) ->
    [15, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{vswtch,Value}| Opts]) ->
    [16, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{vstatus,Value}| Opts]) ->
    [17, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{vdiscard,Value}| Opts]) ->
    [18, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{ignpar,Value}| Opts]) ->
    [30, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{parmrk,Value}| Opts]) ->
    [31, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{inpck,Value}| Opts]) ->
    [32, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{istrip,Value}| Opts]) ->
    [33, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{inlcr,Value}| Opts]) ->
    [34, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{igncr,Value}| Opts]) ->
    [35, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{icrnl,Value}| Opts]) ->
    [36, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{iuclc,Value}| Opts]) ->
    [37, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{ixon,Value}| Opts]) ->
    [38, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{ixany,Value}| Opts]) ->
    [39, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{ixoff,Value}| Opts]) ->
    [40, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{imaxbel,Value}| Opts]) ->
    [41, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{iutf8,Value}| Opts]) ->
    [42, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{isig,Value}| Opts]) ->
    [50, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{icanon,Value}| Opts]) ->
    [51, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{xcase,Value}| Opts]) ->
    [52, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{echo,Value}| Opts]) ->
    [53, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{echoe,Value}| Opts]) ->
    [54, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{echok,Value}| Opts]) ->
    [55, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{echonl,Value}| Opts]) ->
    [56, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{noflsh,Value}| Opts]) ->
    [57, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{tostop,Value}| Opts]) ->
    [58, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{iexten,Value}| Opts]) ->
    [59, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{echoctl,Value}| Opts]) ->
    [60, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{echoke,Value}| Opts]) ->
    [61, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{pendin,Value}| Opts]) ->
    [62, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{opost,Value}| Opts]) ->
    [70, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{olcuc,Value}| Opts]) ->
    [71, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{onlcr,Value}| Opts]) ->
    [72, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{ocrnl,Value}| Opts]) ->
    [73, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{onocr,Value}| Opts]) ->
    [74, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{onlret,Value}| Opts]) ->
    [75, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{cs7,Value}| Opts]) ->
    [90, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{cs8,Value}| Opts]) ->
    [91, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{parenb,Value}| Opts]) ->
    [92, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{parodd,Value}| Opts]) ->
    [93, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{tty_op_ispeed,Value}| Opts]) ->
    [128, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)];
encode_pty_opts2([{tty_op_ospeed,Value}| Opts]) ->
    [129, <<Value:32/unsigned-big-integer>>| encode_pty_opts2(Opts)].

decode_pty_opts(<<>>) ->
    [];
decode_pty_opts(<<0,0,0,0>>) ->
    [];
decode_pty_opts(<<_Len:32/unsigned-big-integer,Modes:_Len/binary>>) ->
    decode_pty_opts2(Modes);
decode_pty_opts(Binary) ->
    decode_pty_opts2(Binary).

decode_pty_opts2(<<0>>) ->
    [];
decode_pty_opts2(<<Code,Value:32/unsigned-big-integer,Tail/binary>>) ->
    Op = case Code of
        1->
            vintr;
        2->
            vquit;
        3->
            verase;
        4->
            vkill;
        5->
            veof;
        6->
            veol;
        7->
            veol2;
        8->
            vstart;
        9->
            vstop;
        10->
            vsusp;
        11->
            vdsusp;
        12->
            vreprint;
        13->
            vwerase;
        14->
            vlnext;
        15->
            vflush;
        16->
            vswtch;
        17->
            vstatus;
        18->
            vdiscard;
        30->
            ignpar;
        31->
            parmrk;
        32->
            inpck;
        33->
            istrip;
        34->
            inlcr;
        35->
            igncr;
        36->
            icrnl;
        37->
            iuclc;
        38->
            ixon;
        39->
            ixany;
        40->
            ixoff;
        41->
            imaxbel;
        42->
            iutf8;
        50->
            isig;
        51->
            icanon;
        52->
            xcase;
        53->
            echo;
        54->
            echoe;
        55->
            echok;
        56->
            echonl;
        57->
            noflsh;
        58->
            tostop;
        59->
            iexten;
        60->
            echoctl;
        61->
            echoke;
        62->
            pendin;
        70->
            opost;
        71->
            olcuc;
        72->
            onlcr;
        73->
            ocrnl;
        74->
            onocr;
        75->
            onlret;
        90->
            cs7;
        91->
            cs8;
        92->
            parenb;
        93->
            parodd;
        128->
            tty_op_ispeed;
        129->
            tty_op_ospeed;
        _->
            Code
    end,
    [{Op,Value}| decode_pty_opts2(Tail)].

backwards_compatible([],Acc) ->
    Acc;
backwards_compatible([{hight,Value}| Rest],Acc) ->
    backwards_compatible(Rest,[{height,Value}| Acc]);
backwards_compatible([{pixel_hight,Value}| Rest],Acc) ->
    backwards_compatible(Rest,[{height,Value}| Acc]);
backwards_compatible([Value| Rest],Acc) ->
    backwards_compatible(Rest,[Value| Acc]).

handle_cli_msg(C0,ChId,Reply0) ->
    Cache = C0#connection.channel_cache,
    Ch0 = ssh_client_channel:cache_lookup(Cache,ChId),
    case Ch0#channel.user of
        undefined->
            case start_cli(C0,ChId) of
                {ok,Pid}->
                    monitor(process,Pid),
                    Ch = Ch0#channel{user = Pid},
                    ssh_client_channel:cache_update(Cache,Ch),
                    reply_msg(Ch,C0,Reply0);
                {error,_Error}->
                    Reply = {connection_reply,channel_failure_msg(Ch0#channel.remote_id)},
                    {[Reply],C0}
            end;
        _->
            reply_msg(Ch0,C0,Reply0)
    end.

channel_data_reply_msg(ChannelId,Connection,DataType,Data) ->
    case ssh_client_channel:cache_lookup(Connection#connection.channel_cache,ChannelId) of
        #channel{recv_window_size = Size} = Channel->
            WantedSize = Size - size(Data),
            ssh_client_channel:cache_update(Connection#connection.channel_cache,Channel#channel{recv_window_size = WantedSize}),
            reply_msg(Channel,Connection,{data,ChannelId,DataType,Data});
        undefined->
            {[],Connection}
    end.

reply_msg(ChId,C,Reply)
    when is_integer(ChId)->
    reply_msg(ssh_client_channel:cache_lookup(C#connection.channel_cache,ChId),C,Reply);
reply_msg(Channel,Connection,{open,_} = Reply) ->
    request_reply_or_data(Channel,Connection,Reply);
reply_msg(Channel,Connection,{open_error,_,_,_} = Reply) ->
    request_reply_or_data(Channel,Connection,Reply);
reply_msg(Channel,Connection,success = Reply) ->
    request_reply_or_data(Channel,Connection,Reply);
reply_msg(Channel,Connection,failure = Reply) ->
    request_reply_or_data(Channel,Connection,Reply);
reply_msg(Channel,Connection,{closed,_} = Reply) ->
    request_reply_or_data(Channel,Connection,Reply);
reply_msg(undefined,Connection,_Reply) ->
    {[],Connection};
reply_msg(#channel{user = ChannelPid},Connection,Reply) ->
    {[{channel_data,ChannelPid,Reply}],Connection}.

request_reply_or_data(#channel{local_id = ChannelId,user = ChannelPid},#connection{requests = Requests} = Connection,Reply) ->
    case lists:keysearch(ChannelId,1,Requests) of
        {value,{ChannelId,From}}->
            {[{channel_request_reply,From,Reply}],Connection#connection{requests = lists:keydelete(ChannelId,1,Requests)}};
        false
            when (Reply == success) or (Reply == failure)->
            {[],Connection};
        false->
            {[{channel_data,ChannelPid,Reply}],Connection}
    end.

send_environment_vars(ConnectionHandler,Channel,VarNames) ->
    lists:foldl(fun (Var,success)->
        case os:getenv(Var) of
            false->
                success;
            Value->
                setenv(ConnectionHandler,Channel,false,Var,Value,infinity)
        end end,success,VarNames).
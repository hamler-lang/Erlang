-file("ssh_sftpd.erl", 1).

-module(ssh_sftpd).

-behaviour(ssh_server_channel).

-file("/usr/lib/erlang/lib/kernel-7.2/include/file.hrl", 1).

-record(file_info,{size::non_neg_integer()|undefined,type::device|directory|other|regular|symlink|undefined,access::read|write|read_write|none|undefined,atime::file:date_time()|non_neg_integer()|undefined,mtime::file:date_time()|non_neg_integer()|undefined,ctime::file:date_time()|non_neg_integer()|undefined,mode::non_neg_integer()|undefined,links::non_neg_integer()|undefined,major_device::non_neg_integer()|undefined,minor_device::non_neg_integer()|undefined,inode::non_neg_integer()|undefined,uid::non_neg_integer()|undefined,gid::non_neg_integer()|undefined}).

-record(file_descriptor,{module::module(),data::term()}).

-file("ssh_sftpd.erl", 30).

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

-file("ssh_sftpd.erl", 32).

-file("ssh_xfer.hrl", 1).

-record(ssh_xfer_attr, {type,size,owner,group,permissions,atime,atime_nseconds,createtime,createtime_nseconds,mtime,mtime_nseconds,acl,attrib_bits,extensions}).

-record(ssh_xfer_ace, {type,flag,mask,who}).

-record(ssh_xfer, {vsn,ext,cm,channel}).

-file("ssh_sftpd.erl", 33).

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

-file("ssh_sftpd.erl", 33).

-export([subsystem_spec/1]).

-export([init/1, handle_ssh_msg/2, handle_msg/2, terminate/2]).

-behaviour(ssh_dbg).

-export([ssh_dbg_trace_points/0, ssh_dbg_flags/1, ssh_dbg_on/1, ssh_dbg_off/1, ssh_dbg_format/2]).

-record(state, {xf,cwd,root,remote_channel,pending,file_handler,file_state,max_files,options,handles}).

-spec(subsystem_spec(Options) -> Spec when Options::[{cwd,string()}|{file_handler,CbMod|{CbMod,FileState}}|{max_files,integer()}|{root,string()}|{sftpd_vsn,integer()}],Spec::{Name,{CbMod,Options}},Name::string(),CbMod::atom(),FileState::term()).

subsystem_spec(Options) ->
    {"sftp",{ssh_sftpd,Options}}.

init(Options) ->
    {FileMod,FS0} = case proplists:get_value(file_handler,Options,{ssh_sftpd_file,[]}) of
        {F,S}->
            {F,S};
        F->
            {F,[]}
    end,
    {{ok,Default},FS1} = FileMod:get_cwd(FS0),
    CWD = proplists:get_value(cwd,Options,Default),
    Root0 = proplists:get_value(root,Options,""),
    {Root,State} = case resolve_symlinks(Root0,#state{root = Root0,file_handler = FileMod,file_state = FS1}) of
        {{ok,Root1},State0}->
            {Root1,State0};
        {{error,_},State0}->
            {Root0,State0}
    end,
    MaxLength = proplists:get_value(max_files,Options,0),
    Vsn = proplists:get_value(sftpd_vsn,Options,5),
    {ok,State#state{cwd = CWD,root = Root,max_files = MaxLength,options = Options,handles = [],pending = <<>>,xf = #ssh_xfer{vsn = Vsn,ext = []}}}.

handle_ssh_msg({ssh_cm,_ConnectionManager,{data,_ChannelId,Type,Data}},State) ->
    State1 = handle_data(Type,Data,State),
    {ok,State1};
handle_ssh_msg({ssh_cm,_,{eof,ChannelId}},State) ->
    {stop,ChannelId,State};
handle_ssh_msg({ssh_cm,_,{signal,_,_}},State) ->
    {ok,State};
handle_ssh_msg({ssh_cm,_,{exit_signal,ChannelId,Signal,Error,_}},State) ->
    Report = io_lib:format("Connection closed by peer signal ~p~n Error ~p~n",[Signal, Error]),
    error_logger:error_report(Report),
    {stop,ChannelId,State};
handle_ssh_msg({ssh_cm,_,{exit_status,ChannelId,0}},State) ->
    {stop,ChannelId,State};
handle_ssh_msg({ssh_cm,_,{exit_status,ChannelId,Status}},State) ->
    Report = io_lib:format("Connection closed by peer ~n Status ~p~n",[Status]),
    error_logger:error_report(Report),
    {stop,ChannelId,State}.

handle_msg({ssh_channel_up,ChannelId,ConnectionManager},#state{xf = Xf,options = Options} = State) ->
    maybe_increase_recv_window(ConnectionManager,ChannelId,Options),
    {ok,State#state{xf = Xf#ssh_xfer{cm = ConnectionManager,channel = ChannelId}}}.

terminate(_,#state{handles = Handles,file_handler = FileMod,file_state = FS}) ->
    CloseFun = fun ({_,file,{_,Fd}},FS0)->
        {_Res,FS1} = FileMod:close(Fd,FS0),
        FS1;(_,FS0)->
        FS0 end,
    lists:foldl(CloseFun,FS,Handles),
    ok.

handle_data(0,<<Len:32/unsigned-big-integer,Msg:Len/binary,Rest/binary>>,State = #state{pending = <<>>}) ->
    <<Op,ReqId:32/unsigned-big-integer,Data/binary>> = Msg,
    NewState = handle_op(Op,ReqId,Data,State),
    case Rest of
        <<>>->
            NewState;
        _->
            handle_data(0,Rest,NewState)
    end;
handle_data(0,Data,State = #state{pending = <<>>}) ->
    State#state{pending = Data};
handle_data(Type,Data,State = #state{pending = Pending}) ->
    handle_data(Type,<<Pending/binary,Data/binary>>,State#state{pending = <<>>}).

handle_op(1,Version,B,State)
    when is_binary(B)->
    XF = State#state.xf,
    Vsn = lists:min([XF#ssh_xfer.vsn, Version]),
    XF1 = XF#ssh_xfer{vsn = Vsn},
    ssh_xfer:xf_send_reply(XF1,2,<<Vsn:32/unsigned-big-integer>>),
    State#state{xf = XF1};
handle_op(16,ReqId,<<Rlen:32/unsigned-big-integer,RPath:Rlen/binary>>,State0) ->
    RelPath = relate_file_name(RPath,State0,_Canonicalize = false),
    {Res,State} = resolve_symlinks(RelPath,State0),
    case Res of
        {ok,AbsPath}->
            NewAbsPath = chroot_filename(AbsPath,State),
            XF = State#state.xf,
            Attr = #ssh_xfer_attr{type = directory},
            ssh_xfer:xf_send_name(XF,ReqId,NewAbsPath,Attr),
            State;
        {error,_} = Error->
            send_status(Error,ReqId,State)
    end;
handle_op(11,ReqId,<<RLen:32/unsigned-big-integer,RPath:RLen/binary>>,State0 = #state{xf = #ssh_xfer{vsn = Vsn},file_handler = FileMod,file_state = FS0}) ->
    RelPath = unicode:characters_to_list(RPath),
    AbsPath = relate_file_name(RelPath,State0),
    XF = State0#state.xf,
    {IsDir,FS1} = FileMod:is_dir(AbsPath,FS0),
    State1 = State0#state{file_state = FS1},
    case IsDir of
        false
            when Vsn > 5->
            ssh_xfer:xf_send_status(XF,ReqId,19,"Not a directory"),
            State1;
        false->
            ssh_xfer:xf_send_status(XF,ReqId,4,"Not a directory"),
            State1;
        true->
            add_handle(State1,XF,ReqId,directory,{RelPath,unread})
    end;
handle_op(12,ReqId,<<HLen:32/unsigned-big-integer,BinHandle:HLen/binary>>,State) ->
    XF = State#state.xf,
    case get_handle(State#state.handles,BinHandle) of
        {_Handle,directory,{_RelPath,eof}}->
            ssh_xfer:xf_send_status(XF,ReqId,1),
            State;
        {Handle,directory,{RelPath,Status}}->
            read_dir(State,XF,ReqId,Handle,RelPath,Status);
        _->
            ssh_xfer:xf_send_status(XF,ReqId,9),
            State
    end;
handle_op(4,ReqId,<<HLen:32/unsigned-big-integer,BinHandle:HLen/binary>>,State = #state{handles = Handles,xf = XF,file_handler = FileMod,file_state = FS0}) ->
    case get_handle(Handles,BinHandle) of
        {Handle,Type,T}->
            FS1 = case Type of
                file->
                    close_our_file(T,FileMod,FS0);
                _->
                    FS0
            end,
            ssh_xfer:xf_send_status(XF,ReqId,0),
            State#state{handles = lists:keydelete(Handle,1,Handles),file_state = FS1};
        _->
            ssh_xfer:xf_send_status(XF,ReqId,9),
            State
    end;
handle_op(7,ReqId,Data,State) ->
    stat((State#state.xf)#ssh_xfer.vsn,ReqId,Data,State,read_link_info);
handle_op(17,ReqId,Data,State) ->
    stat((State#state.xf)#ssh_xfer.vsn,ReqId,Data,State,read_file_info);
handle_op(8,ReqId,Data,State) ->
    fstat((State#state.xf)#ssh_xfer.vsn,ReqId,Data,State);
handle_op(3,ReqId,Data,State) ->
    open((State#state.xf)#ssh_xfer.vsn,ReqId,Data,State);
handle_op(5,ReqId,<<HLen:32/unsigned-big-integer,BinHandle:HLen/binary,Offset:64/unsigned-big-integer,Len:32/unsigned-big-integer>>,State) ->
    case get_handle(State#state.handles,BinHandle) of
        {_Handle,file,{_Path,IoDevice}}->
            read_file(ReqId,IoDevice,Offset,Len,State);
        _->
            ssh_xfer:xf_send_status(State#state.xf,ReqId,9),
            State
    end;
handle_op(6,ReqId,<<HLen:32/unsigned-big-integer,BinHandle:HLen/binary,Offset:64/unsigned-big-integer,Len:32/unsigned-big-integer,Data:Len/binary>>,State) ->
    case get_handle(State#state.handles,BinHandle) of
        {_Handle,file,{_Path,IoDevice}}->
            write_file(ReqId,IoDevice,Offset,Data,State);
        _->
            ssh_xfer:xf_send_status(State#state.xf,ReqId,9),
            State
    end;
handle_op(19,ReqId,<<PLen:32/unsigned-big-integer,RelPath:PLen/binary>>,State = #state{file_handler = FileMod,file_state = FS0}) ->
    AbsPath = relate_file_name(RelPath,State),
    {Res,FS1} = FileMod:read_link(AbsPath,FS0),
    case Res of
        {ok,NewPath}->
            ssh_xfer:xf_send_name(State#state.xf,ReqId,NewPath,#ssh_xfer_attr{type = regular});
        {error,Error}->
            ssh_xfer:xf_send_status(State#state.xf,ReqId,ssh_xfer:encode_erlang_status(Error))
    end,
    State#state{file_state = FS1};
handle_op(9,ReqId,<<PLen:32/unsigned-big-integer,BPath:PLen/binary,Attr/binary>>,State0) ->
    Path = relate_file_name(BPath,State0),
    {Status,State1} = set_stat(Attr,Path,State0),
    send_status(Status,ReqId,State1);
handle_op(14,ReqId,<<PLen:32/unsigned-big-integer,BPath:PLen/binary,Attr/binary>>,State0 = #state{file_handler = FileMod,file_state = FS0}) ->
    Path = relate_file_name(BPath,State0),
    {Res,FS1} = FileMod:make_dir(Path,FS0),
    State1 = State0#state{file_state = FS1},
    case Res of
        ok->
            {_,State2} = set_stat(Attr,Path,State1),
            send_status(ok,ReqId,State2);
        {error,Error}->
            send_status({error,Error},ReqId,State1)
    end;
handle_op(10,ReqId,<<HLen:32/unsigned-big-integer,BinHandle:HLen/binary,Attr/binary>>,State0 = #state{handles = Handles}) ->
    case get_handle(Handles,BinHandle) of
        {_Handle,_Type,{Path,_}}->
            {Status,State1} = set_stat(Attr,Path,State0),
            send_status(Status,ReqId,State1);
        _->
            ssh_xfer:xf_send_status(State0#state.xf,ReqId,9),
            State0
    end;
handle_op(13,ReqId,<<PLen:32/unsigned-big-integer,BPath:PLen/binary>>,State0 = #state{file_handler = FileMod,file_state = FS0,xf = #ssh_xfer{vsn = Vsn}}) ->
    Path = relate_file_name(BPath,State0),
    {IsDir,_FS1} = FileMod:is_dir(Path,FS0),
    case IsDir of
        true
            when Vsn > 5->
            ssh_xfer:xf_send_status(State0#state.xf,ReqId,24,"File is a directory"),
            State0;
        true->
            ssh_xfer:xf_send_status(State0#state.xf,ReqId,4,"File is a directory"),
            State0;
        false->
            {Status,FS1} = FileMod:delete(Path,FS0),
            State1 = State0#state{file_state = FS1},
            send_status(Status,ReqId,State1)
    end;
handle_op(15,ReqId,<<PLen:32/unsigned-big-integer,BPath:PLen/binary>>,State0 = #state{file_handler = FileMod,file_state = FS0}) ->
    Path = relate_file_name(BPath,State0),
    {Status,FS1} = FileMod:del_dir(Path,FS0),
    State1 = State0#state{file_state = FS1},
    send_status(Status,ReqId,State1);
handle_op(18,ReqId,Bin = <<PLen:32/unsigned-big-integer,_:PLen/binary,PLen2:32/unsigned-big-integer,_:PLen2/binary>>,State = #state{xf = #ssh_xfer{vsn = Vsn}})
    when Vsn == 3;
    Vsn == 4->
    handle_op(18,ReqId,<<Bin/binary,0:32>>,State);
handle_op(18,ReqId,<<PLen:32/unsigned-big-integer,BPath:PLen/binary,PLen2:32/unsigned-big-integer,BPath2:PLen2/binary,Flags:32/unsigned-big-integer>>,State0 = #state{file_handler = FileMod,file_state = FS0}) ->
    Path = relate_file_name(BPath,State0),
    Path2 = relate_file_name(BPath2,State0),
    case Flags band 2 of
        0->
            case Flags band 1 of
                0->
                    {Res,FS1} = FileMod:read_link_info(Path2,FS0),
                    State1 = State0#state{file_state = FS1},
                    case Res of
                        {ok,_Info}->
                            ssh_xfer:xf_send_status(State1#state.xf,ReqId,11),
                            State1;
                        _->
                            rename(Path,Path2,ReqId,State1)
                    end;
                _->
                    rename(Path,Path2,ReqId,State0)
            end;
        _->
            ssh_xfer:xf_send_status(State0#state.xf,ReqId,8),
            State0
    end;
handle_op(20,ReqId,<<PLen:32/unsigned-big-integer,Link:PLen/binary,PLen2:32/unsigned-big-integer,Target:PLen2/binary>>,State0 = #state{file_handler = FileMod,file_state = FS0}) ->
    LinkPath = relate_file_name(Link,State0),
    TargetPath = relate_file_name(Target,State0),
    {Status,FS1} = FileMod:make_symlink(TargetPath,LinkPath,FS0),
    State1 = State0#state{file_state = FS1},
    send_status(Status,ReqId,State1).

new_handle([],H) ->
    H;
new_handle([{N,_,_}| Rest],H)
    when N =< H->
    new_handle(Rest,N + 1);
new_handle([_| Rest],H) ->
    new_handle(Rest,H).

add_handle(State,XF,ReqId,Type,DirFileTuple) ->
    Handles = State#state.handles,
    Handle = new_handle(Handles,0),
    ssh_xfer:xf_send_handle(XF,ReqId,integer_to_list(Handle)),
    State#state{handles = [{Handle,Type,DirFileTuple}| Handles]}.

get_handle(Handles,BinHandle) ->
    case  catch list_to_integer(binary_to_list(BinHandle)) of
        I
            when is_integer(I)->
            case lists:keysearch(I,1,Handles) of
                {value,T}->
                    T;
                false->
                    error
            end;
        _->
            error
    end.

read_dir(State0 = #state{file_handler = FileMod,max_files = MaxLength,file_state = FS0},XF,ReqId,Handle,RelPath,{cache,Files}) ->
    AbsPath = relate_file_name(RelPath,State0),
    if length(Files) > MaxLength ->
        {ToSend,NewCache} = lists:split(MaxLength,Files),
        {NamesAndAttrs,FS1} = get_attrs(AbsPath,ToSend,FileMod,FS0),
        ssh_xfer:xf_send_names(XF,ReqId,NamesAndAttrs),
        Handles = lists:keyreplace(Handle,1,State0#state.handles,{Handle,directory,{RelPath,{cache,NewCache}}}),
        State0#state{handles = Handles,file_state = FS1};true ->
        {NamesAndAttrs,FS1} = get_attrs(AbsPath,Files,FileMod,FS0),
        ssh_xfer:xf_send_names(XF,ReqId,NamesAndAttrs),
        Handles = lists:keyreplace(Handle,1,State0#state.handles,{Handle,directory,{RelPath,eof}}),
        State0#state{handles = Handles,file_state = FS1} end;
read_dir(State0 = #state{file_handler = FileMod,max_files = MaxLength,file_state = FS0},XF,ReqId,Handle,RelPath,_Status) ->
    AbsPath = relate_file_name(RelPath,State0),
    {Res,FS1} = FileMod:list_dir(AbsPath,FS0),
    case Res of
        {ok,Files}
            when MaxLength == 0 orelse MaxLength > length(Files)->
            {NamesAndAttrs,FS2} = get_attrs(AbsPath,Files,FileMod,FS1),
            ssh_xfer:xf_send_names(XF,ReqId,NamesAndAttrs),
            Handles = lists:keyreplace(Handle,1,State0#state.handles,{Handle,directory,{RelPath,eof}}),
            State0#state{handles = Handles,file_state = FS2};
        {ok,Files}->
            {ToSend,Cache} = lists:split(MaxLength,Files),
            {NamesAndAttrs,FS2} = get_attrs(AbsPath,ToSend,FileMod,FS1),
            ssh_xfer:xf_send_names(XF,ReqId,NamesAndAttrs),
            Handles = lists:keyreplace(Handle,1,State0#state.handles,{Handle,directory,{RelPath,{cache,Cache}}}),
            State0#state{handles = Handles,file_state = FS2};
        {error,Error}->
            State1 = State0#state{file_state = FS1},
            send_status({error,Error},ReqId,State1)
    end.

get_attrs(RelPath,Files,FileMod,FS) ->
    get_attrs(RelPath,Files,FileMod,FS,[]).

get_attrs(_RelPath,[],_FileMod,FS,Acc) ->
    {lists:reverse(Acc),FS};
get_attrs(RelPath,[F| Rest],FileMod,FS0,Acc) ->
    Path = filename:absname(F,RelPath),
    case FileMod:read_link_info(Path,FS0) of
        {{ok,Info},FS1}->
            Attrs = ssh_sftp:info_to_attr(Info),
            get_attrs(RelPath,Rest,FileMod,FS1,[{F,Attrs}| Acc]);
        {{error,enoent},FS1}->
            get_attrs(RelPath,Rest,FileMod,FS1,Acc);
        {Error,FS1}->
            {Error,FS1}
    end.

close_our_file({_,Fd},FileMod,FS0) ->
    {_Res,FS1} = FileMod:close(Fd,FS0),
    FS1.

stat(_Vsn,ReqId,Data,State,F) ->
    <<BLen:32/unsigned-big-integer,BPath:BLen/binary,_/binary>> = Data,
    stat(ReqId,unicode:characters_to_list(BPath),State,F).

fstat(Vsn,ReqId,Data,State)
    when Vsn =< 3->
    <<HLen:32/unsigned-big-integer,Handle:HLen/binary>> = Data,
    fstat(ReqId,Handle,State);
fstat(Vsn,ReqId,Data,State)
    when Vsn >= 4->
    <<HLen:32/unsigned-big-integer,Handle:HLen/binary,_Flags:32/unsigned-big-integer>> = Data,
    fstat(ReqId,Handle,State).

fstat(ReqId,BinHandle,State) ->
    case get_handle(State#state.handles,BinHandle) of
        {_Handle,_Type,{Path,_}}->
            stat(ReqId,Path,State,read_file_info);
        _->
            ssh_xfer:xf_send_status(State#state.xf,ReqId,9),
            State
    end.

stat(ReqId,RelPath,State0 = #state{file_handler = FileMod,file_state = FS0},F) ->
    AbsPath = relate_file_name(RelPath,State0),
    XF = State0#state.xf,
    {Res,FS1} = FileMod:F(AbsPath,FS0),
    State1 = State0#state{file_state = FS1},
    case Res of
        {ok,FileInfo}->
            ssh_xfer:xf_send_attr(XF,ReqId,ssh_sftp:info_to_attr(FileInfo)),
            State1;
        {error,E}->
            send_status({error,E},ReqId,State1)
    end.

sftp_to_erlang_flag(read,Vsn)
    when Vsn == 3;
    Vsn == 4->
    read;
sftp_to_erlang_flag(write,Vsn)
    when Vsn == 3;
    Vsn == 4->
    write;
sftp_to_erlang_flag(append,Vsn)
    when Vsn == 3;
    Vsn == 4->
    append;
sftp_to_erlang_flag(creat,Vsn)
    when Vsn == 3;
    Vsn == 4->
    write;
sftp_to_erlang_flag(trunc,Vsn)
    when Vsn == 3;
    Vsn == 4->
    write;
sftp_to_erlang_flag(excl,Vsn)
    when Vsn == 3;
    Vsn == 4->
    read;
sftp_to_erlang_flag(create_new,Vsn)
    when Vsn > 4->
    write;
sftp_to_erlang_flag(create_truncate,Vsn)
    when Vsn > 4->
    write;
sftp_to_erlang_flag(open_existing,Vsn)
    when Vsn > 4->
    read;
sftp_to_erlang_flag(open_or_create,Vsn)
    when Vsn > 4->
    write;
sftp_to_erlang_flag(truncate_existing,Vsn)
    when Vsn > 4->
    write;
sftp_to_erlang_flag(append_data,Vsn)
    when Vsn > 4->
    append;
sftp_to_erlang_flag(append_data_atomic,Vsn)
    when Vsn > 4->
    append;
sftp_to_erlang_flag(_,_) ->
    read.

sftp_to_erlang_flags(Flags,Vsn) ->
    lists:map(fun (Flag)->
        sftp_to_erlang_flag(Flag,Vsn) end,Flags).

sftp_to_erlang_access_flag(read_data,_) ->
    read;
sftp_to_erlang_access_flag(list_directory,_) ->
    read;
sftp_to_erlang_access_flag(write_data,_) ->
    write;
sftp_to_erlang_access_flag(append_data,_) ->
    append;
sftp_to_erlang_access_flag(add_subdirectory,_) ->
    read;
sftp_to_erlang_access_flag(add_file,_) ->
    write;
sftp_to_erlang_access_flag(write_attributes,_) ->
    write;
sftp_to_erlang_access_flag(_,_) ->
    read.

sftp_to_erlang_access_flags(Flags,Vsn) ->
    lists:map(fun (Flag)->
        sftp_to_erlang_access_flag(Flag,Vsn) end,Flags).

open(Vsn,ReqId,Data,State)
    when Vsn =< 3->
    <<BLen:32/unsigned-big-integer,BPath:BLen/binary,PFlags:32/unsigned-big-integer,_Attrs/binary>> = Data,
    Path = unicode:characters_to_list(BPath),
    FlagBits = ssh_xfer:decode_open_flags(Vsn,PFlags),
    Flags = lists:usort(sftp_to_erlang_flags(FlagBits,Vsn)),
    do_open(ReqId,State,Path,Flags);
open(Vsn,ReqId,Data,State)
    when Vsn >= 4->
    <<BLen:32/unsigned-big-integer,BPath:BLen/binary,Access:32/unsigned-big-integer,PFlags:32/unsigned-big-integer,_Attrs/binary>> = Data,
    Path = unicode:characters_to_list(BPath),
    FlagBits = ssh_xfer:decode_open_flags(Vsn,PFlags),
    AcessBits = ssh_xfer:decode_ace_mask(Access),
    AcessFlags = sftp_to_erlang_access_flags(AcessBits,Vsn),
    Flags = lists:usort(sftp_to_erlang_flags(FlagBits,Vsn) ++ AcessFlags),
    do_open(ReqId,State,Path,Flags).

do_open(ReqId,State0,Path,Flags) ->
    #state{file_handler = FileMod,file_state = FS0,xf = #ssh_xfer{vsn = Vsn}} = State0,
    AbsPath = relate_file_name(Path,State0),
    {IsDir,_FS1} = FileMod:is_dir(AbsPath,FS0),
    case IsDir of
        true
            when Vsn > 5->
            ssh_xfer:xf_send_status(State0#state.xf,ReqId,24,"File is a directory"),
            State0;
        true->
            ssh_xfer:xf_send_status(State0#state.xf,ReqId,4,"File is a directory"),
            State0;
        false->
            OpenFlags = [binary| Flags],
            {Res,FS1} = FileMod:open(AbsPath,OpenFlags,FS0),
            State1 = State0#state{file_state = FS1},
            case Res of
                {ok,IoDevice}->
                    add_handle(State1,State0#state.xf,ReqId,file,{Path,IoDevice});
                {error,Error}->
                    ssh_xfer:xf_send_status(State1#state.xf,ReqId,ssh_xfer:encode_erlang_status(Error)),
                    State1
            end
    end.

resolve_symlinks(Path,State) ->
    resolve_symlinks(Path,_LinkCnt = 32,State).

resolve_symlinks(Path,LinkCnt,State0) ->
    resolve_symlinks_2(filename:split(Path),State0,LinkCnt,[]).

resolve_symlinks_2(_Path,State,LinkCnt,_AccPath)
    when LinkCnt =:= 0->
    {{error,emlink},State};
resolve_symlinks_2(["."| RestPath],State0,LinkCnt,AccPath) ->
    resolve_symlinks_2(RestPath,State0,LinkCnt,AccPath);
resolve_symlinks_2([".."| RestPath],State0,LinkCnt,AccPath) ->
    AccPathComps0 = filename:split(AccPath),
    Path = case lists:droplast(AccPathComps0) of
        []->
            "";
        AccPathComps->
            filename:join(AccPathComps)
    end,
    resolve_symlinks_2(RestPath,State0,LinkCnt,Path);
resolve_symlinks_2([PathComp| RestPath],State0,LinkCnt,AccPath0) ->
    #state{file_handler = FileMod,file_state = FS0} = State0,
    AccPath1 = filename:join(AccPath0,PathComp),
    {Res,FS1} = FileMod:read_link(AccPath1,FS0),
    State1 = State0#state{file_state = FS1},
    case Res of
        {ok,Target0}->
            Target1 = filename:absname(Target0,AccPath0),
            {FollowRes,State2} = resolve_symlinks(Target1,LinkCnt - 1,State1),
            case FollowRes of
                {ok,Target}->
                    resolve_symlinks_2(RestPath,State2,LinkCnt - 1,Target);
                {error,_} = Error->
                    {Error,State2}
            end;
        {error,einval}->
            resolve_symlinks_2(RestPath,State1,LinkCnt,AccPath1);
        {error,_} = Error->
            {Error,State1}
    end;
resolve_symlinks_2([],State,_LinkCnt,AccPath) ->
    {{ok,AccPath},State}.

relate_file_name(File,State) ->
    relate_file_name(File,State,_Canonicalize = true).

relate_file_name(File,State,Canonicalize)
    when is_binary(File)->
    relate_file_name(unicode:characters_to_list(File),State,Canonicalize);
relate_file_name(File,#state{cwd = CWD,root = ""},Canonicalize) ->
    relate_filename_to_path(File,CWD,Canonicalize);
relate_file_name(File,#state{cwd = CWD,root = Root},Canonicalize) ->
    CWD1 = case is_within_root(Root,CWD) of
        true->
            CWD;
        false->
            Root
    end,
    AbsFile = case make_relative_filename(File) of
        File->
            relate_filename_to_path(File,CWD1,Canonicalize);
        RelFile->
            relate_filename_to_path(RelFile,Root,Canonicalize)
    end,
    case is_within_root(Root,AbsFile) of
        true->
            AbsFile;
        false->
            Root
    end.

is_within_root(Root,File) ->
    lists:prefix(Root,File).

make_relative_filename("/") ->
    "./";
make_relative_filename("/" ++ File) ->
    File;
make_relative_filename(File) ->
    File.

relate_filename_to_path(File0,Path,Canonicalize) ->
    File1 = filename:absname(File0,Path),
    File2 = if Canonicalize ->
        canonicalize_filename(File1);true ->
        File1 end,
    ensure_trailing_slash_is_preserved(File0,File2).

ensure_trailing_slash_is_preserved(File0,File1) ->
    case {lists:suffix("/",File0),lists:suffix("/",File1)} of
        {true,false}->
            File1 ++ "/";
        _Other->
            File1
    end.

canonicalize_filename(File0) ->
    File = filename:join(canonicalize_filename_2(filename:split(File0),[])),
    ensure_trailing_slash_is_preserved(File0,File).

canonicalize_filename_2([".."| Rest],["/"] = Acc) ->
    canonicalize_filename_2(Rest,Acc);
canonicalize_filename_2([".."| Rest],[_Dir| Paths]) ->
    canonicalize_filename_2(Rest,Paths);
canonicalize_filename_2(["."| Rest],Acc) ->
    canonicalize_filename_2(Rest,Acc);
canonicalize_filename_2([A| Rest],Acc) ->
    canonicalize_filename_2(Rest,[A| Acc]);
canonicalize_filename_2([],Acc) ->
    lists:reverse(Acc).

chroot_filename(Filename,#state{root = Root}) ->
    FilenameComps0 = filename:split(Filename),
    RootComps = filename:split(Root),
    filename:join(chroot_filename_2(FilenameComps0,RootComps)).

chroot_filename_2([PathComp| FilenameRest],[PathComp| RootRest]) ->
    chroot_filename_2(FilenameRest,RootRest);
chroot_filename_2(FilenameComps,[])
    when length(FilenameComps) > 0->
    ["/"| FilenameComps];
chroot_filename_2(_FilenameComps,_RootComps) ->
    ["/"].

read_file(ReqId,IoDevice,Offset,Len,State0 = #state{file_handler = FileMod,file_state = FS0}) ->
    {Res1,FS1} = FileMod:position(IoDevice,{bof,Offset},FS0),
    case Res1 of
        {ok,_NewPos}->
            {Res2,FS2} = FileMod:read(IoDevice,Len,FS1),
            State1 = State0#state{file_state = FS2},
            case Res2 of
                {ok,Data}->
                    ssh_xfer:xf_send_data(State1#state.xf,ReqId,Data),
                    State1;
                {error,Error}->
                    send_status({error,Error},ReqId,State1);
                eof->
                    send_status(eof,ReqId,State1)
            end;
        {error,Error}->
            State1 = State0#state{file_state = FS1},
            send_status({error,Error},ReqId,State1)
    end.

write_file(ReqId,IoDevice,Offset,Data,State0 = #state{file_handler = FileMod,file_state = FS0}) ->
    {Res,FS1} = FileMod:position(IoDevice,{bof,Offset},FS0),
    case Res of
        {ok,_NewPos}->
            {Status,FS2} = FileMod:write(IoDevice,Data,FS1),
            State1 = State0#state{file_state = FS2},
            send_status(Status,ReqId,State1);
        {error,Error}->
            State1 = State0#state{file_state = FS1},
            send_status({error,Error},ReqId,State1)
    end.

get_status(ok) ->
    0;
get_status(eof) ->
    1;
get_status({error,Error}) ->
    ssh_xfer:encode_erlang_status(Error).

send_status(Status,ReqId,State) ->
    ssh_xfer:xf_send_status(State#state.xf,ReqId,get_status(Status)),
    State.

set_stat(<<>>,_Path,State) ->
    {ok,State};
set_stat(Attr,Path,State0 = #state{file_handler = FileMod,file_state = FS0}) ->
    {DecodedAttr,_Rest} = ssh_xfer:decode_ATTR((State0#state.xf)#ssh_xfer.vsn,Attr),
    Info = ssh_sftp:attr_to_info(DecodedAttr),
    {Res1,FS1} = FileMod:read_link_info(Path,FS0),
    case Res1 of
        {ok,OldInfo}->
            NewInfo = set_file_info(Info,OldInfo),
            {Res2,FS2} = FileMod:write_file_info(Path,NewInfo,FS1),
            State1 = State0#state{file_state = FS2},
            {Res2,State1};
        {error,Error}->
            State1 = State0#state{file_state = FS1},
            {{error,Error},State1}
    end.

set_file_info_sel(undefined,F) ->
    F;
set_file_info_sel(F,_) ->
    F.

set_file_info(#file_info{atime = Dst_atime,mtime = Dst_mtime,ctime = Dst_ctime,mode = Dst_mode,uid = Dst_uid,gid = Dst_gid},#file_info{atime = Src_atime,mtime = Src_mtime,ctime = Src_ctime,mode = Src_mode,uid = Src_uid,gid = Src_gid}) ->
    #file_info{atime = set_file_info_sel(Dst_atime,Src_atime),mtime = set_file_info_sel(Dst_mtime,Src_mtime),ctime = set_file_info_sel(Dst_ctime,Src_ctime),mode = set_file_info_sel(Dst_mode,Src_mode),uid = set_file_info_sel(Dst_uid,Src_uid),gid = set_file_info_sel(Dst_gid,Src_gid)}.

rename(Path,Path2,ReqId,State0) ->
    #state{file_handler = FileMod,file_state = FS0} = State0,
    {Status,FS1} = FileMod:rename(Path,Path2,FS0),
    State1 = State0#state{file_state = FS1},
    send_status(Status,ReqId,State1).

maybe_increase_recv_window(ConnectionManager,ChannelId,Options) ->
    WantedRecvWindowSize = proplists:get_value(recv_window_size,Options,1000000),
    NumPkts = WantedRecvWindowSize div 65536,
    Increment = NumPkts * 65536 - 10 * 65536,
    if Increment > 0 ->
        ssh_connection:adjust_window(ConnectionManager,ChannelId,Increment);Increment =< 0 ->
        do_nothing end.

ssh_dbg_trace_points() ->
    [terminate].

ssh_dbg_flags(terminate) ->
    [c].

ssh_dbg_on(terminate) ->
    dbg:tp(ssh_sftpd,terminate,2,x).

ssh_dbg_off(terminate) ->
    dbg:ctpg(ssh_sftpd,terminate,2).

ssh_dbg_format(terminate,{call,{ssh_sftpd,terminate,[Reason, State]}}) ->
    ["SftpD Terminating:\n", io_lib:format("Reason: ~p,~nState:~n~s",[Reason, wr_record(State)])];
ssh_dbg_format(terminate,{return_from,{ssh_sftpd,terminate,2},_Ret}) ->
    skip.

wr_record(R = #state{}) ->
    ssh_dbg:wr_record(R,record_info(fields,state),[]).
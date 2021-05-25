-file("ssh_cli.erl", 1).

-module(ssh_cli).

-behaviour(ssh_server_channel).

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

-file("ssh_cli.erl", 31).

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

-file("ssh_cli.erl", 32).

-export([init/1, handle_ssh_msg/2, handle_msg/2, terminate/2]).

-behaviour(ssh_dbg).

-export([ssh_dbg_trace_points/0, ssh_dbg_flags/1, ssh_dbg_on/1, ssh_dbg_off/1, ssh_dbg_format/2]).

-record(state, {cm,channel,pty,encoding,deduced_encoding,group,buf,shell,exec}).

init([Shell, Exec]) ->
    {ok,#state{shell = Shell,exec = Exec}};
init([Shell]) ->
    {ok,#state{shell = Shell}}.

handle_ssh_msg({ssh_cm,_ConnectionHandler,{data,_ChannelId,_Type,Data}},#state{group = Group} = State0) ->
    {Enc,State} = guess_encoding(Data,State0),
    List = unicode:characters_to_list(Data,Enc),
    to_group(List,Group),
    {ok,State};
handle_ssh_msg({ssh_cm,ConnectionHandler,{pty,ChannelId,WantReply,{TermName,Width,Height,PixWidth,PixHeight,Modes}}},State0) ->
    State = State0#state{pty = #ssh_pty{term = TermName,width = not_zero(Width,80),height = not_zero(Height,24),pixel_width = PixWidth,pixel_height = PixHeight,modes = Modes},buf = empty_buf()},
    set_echo(State),
    ssh_connection:reply_request(ConnectionHandler,WantReply,success,ChannelId),
    {ok,State};
handle_ssh_msg({ssh_cm,ConnectionHandler,{env,ChannelId,WantReply,Var,Value}},State = #state{encoding = Enc0}) ->
    ssh_connection:reply_request(ConnectionHandler,WantReply,failure,ChannelId),
    Enc = case Var of
        <<"LANG">>
            when Enc0 == undefined->
            case claim_encoding(Value) of
                {ok,Enc1}->
                    Enc1;
                _->
                    Enc0
            end;
        <<"LC_ALL">>->
            case claim_encoding(Value) of
                {ok,Enc1}->
                    Enc1;
                _->
                    Enc0
            end;
        _->
            Enc0
    end,
    {ok,State#state{encoding = Enc}};
handle_ssh_msg({ssh_cm,ConnectionHandler,{window_change,ChannelId,Width,Height,PixWidth,PixHeight}},#state{buf = Buf,pty = Pty0} = State) ->
    Pty = Pty0#ssh_pty{width = Width,height = Height,pixel_width = PixWidth,pixel_height = PixHeight},
    {Chars,NewBuf} = io_request({window_change,Pty0},Buf,Pty,undefined),
    write_chars(ConnectionHandler,ChannelId,Chars),
    {ok,State#state{pty = Pty,buf = NewBuf}};
handle_ssh_msg({ssh_cm,ConnectionHandler,{shell,ChannelId,WantReply}},#state{shell = disabled} = State) ->
    write_chars(ConnectionHandler,ChannelId,1,"Prohibited."),
    ssh_connection:reply_request(ConnectionHandler,WantReply,success,ChannelId),
    ssh_connection:exit_status(ConnectionHandler,ChannelId,255),
    ssh_connection:send_eof(ConnectionHandler,ChannelId),
    {stop,ChannelId,State#state{channel = ChannelId,cm = ConnectionHandler}};
handle_ssh_msg({ssh_cm,ConnectionHandler,{shell,ChannelId,WantReply}},State0) ->
    State = case State0#state.encoding of
        undefined->
            State0#state{encoding = utf8};
        _->
            State0
    end,
    NewState = start_shell(ConnectionHandler,State),
    ssh_connection:reply_request(ConnectionHandler,WantReply,success,ChannelId),
    {ok,NewState#state{channel = ChannelId,cm = ConnectionHandler}};
handle_ssh_msg({ssh_cm,ConnectionHandler,{exec,ChannelId,WantReply,Cmd0}},S0) ->
    {Enc,S1} = guess_encoding(Cmd0,S0),
    Cmd = unicode:characters_to_list(Cmd0,Enc),
    case case S1#state.exec of
        disabled->
            {"Prohibited.",255,1};
        {direct,F}->
            exec_direct(ConnectionHandler,ChannelId,Cmd,F,WantReply,S1);
        undefined
            when S0#state.shell == {shell,start,[]};
            S0#state.shell == disabled->
            exec_in_erlang_default_shell(ConnectionHandler,ChannelId,Cmd,WantReply,S1);
        undefined->
            {"Prohibited.",255,1};
        _->
            S2 = start_exec_shell(ConnectionHandler,Cmd,S1),
            ssh_connection:reply_request(ConnectionHandler,WantReply,success,ChannelId),
            {ok,S2}
    end of
        {Reply,Status,Type}->
            write_chars(ConnectionHandler,ChannelId,Type,unicode:characters_to_binary(Reply,utf8,out_enc(S1))),
            ssh_connection:reply_request(ConnectionHandler,WantReply,success,ChannelId),
            ssh_connection:exit_status(ConnectionHandler,ChannelId,Status),
            ssh_connection:send_eof(ConnectionHandler,ChannelId),
            {stop,ChannelId,S1#state{channel = ChannelId,cm = ConnectionHandler}};
        {ok,S}->
            {ok,S#state{channel = ChannelId,cm = ConnectionHandler}}
    end;
handle_ssh_msg({ssh_cm,_ConnectionHandler,{eof,_ChannelId}},State) ->
    {ok,State};
handle_ssh_msg({ssh_cm,_,{signal,_,_}},State) ->
    {ok,State};
handle_ssh_msg({ssh_cm,_,{exit_signal,ChannelId,_,Error,_}},State) ->
    Report = io_lib:format("Connection closed by peer ~n Error ~p~n",[Error]),
    error_logger:error_report(Report),
    {stop,ChannelId,State};
handle_ssh_msg({ssh_cm,_,{exit_status,ChannelId,0}},State) ->
    {stop,ChannelId,State};
handle_ssh_msg({ssh_cm,_,{exit_status,ChannelId,Status}},State) ->
    Report = io_lib:format("Connection closed by peer ~n Status ~p~n",[Status]),
    error_logger:error_report(Report),
    {stop,ChannelId,State}.

handle_msg({ssh_channel_up,ChannelId,ConnectionHandler},#state{channel = ChannelId,cm = ConnectionHandler} = State) ->
    {ok,State};
handle_msg({Group,set_unicode_state,_Arg},State) ->
    Group ! {self(),set_unicode_state,false},
    {ok,State};
handle_msg({Group,get_unicode_state},State) ->
    Group ! {self(),get_unicode_state,false},
    {ok,State};
handle_msg({Group,tty_geometry},#state{group = Group,pty = Pty} = State) ->
    case Pty of
        #ssh_pty{width = Width,height = Height}->
            Group ! {self(),tty_geometry,{Width,Height}};
        _->
            Group ! {self(),tty_geometry,{0,0}}
    end,
    {ok,State};
handle_msg({Group,Req},#state{group = Group,buf = Buf,pty = Pty,cm = ConnectionHandler,channel = ChannelId} = State) ->
    {Chars0,NewBuf} = io_request(Req,Buf,Pty,Group),
    Chars = unicode:characters_to_binary(Chars0,utf8,out_enc(State)),
    write_chars(ConnectionHandler,ChannelId,Chars),
    {ok,State#state{buf = NewBuf}};
handle_msg({'EXIT',Group,Reason},#state{group = Group,cm = ConnectionHandler,channel = ChannelId} = State) ->
    ssh_connection:send_eof(ConnectionHandler,ChannelId),
    ExitStatus = case Reason of
        normal->
            0;
        {exit_status,V}
            when is_integer(V)->
            V;
        _->
            255
    end,
    ssh_connection:exit_status(ConnectionHandler,ChannelId,ExitStatus),
    {stop,ChannelId,State};
handle_msg(_,State) ->
    {ok,State}.

terminate(_Reason,_State) ->
    ok.

claim_encoding(<<"/",_/binary>>) ->
    undefined;
claim_encoding(EnvValue) ->
    try string:tokens(binary_to_list(EnvValue),".") of 
        [_, "UTF-8"]->
            {ok,utf8};
        [_, "ISO-8859-1"]->
            {ok,latin1};
        _->
            undefined
        catch
            _:_->
                undefined end.

guess_encoding(Data0,#state{encoding = PeerEnc0,deduced_encoding = TestEnc0} = State) ->
    Enc = case {PeerEnc0,TestEnc0} of
        {latin1,_}->
            latin1;
        {_,latin1}->
            latin1;
        _->
            case unicode:characters_to_binary(Data0,utf8,utf8) of
                Data0->
                    utf8;
                _->
                    latin1
            end
    end,
    case TestEnc0 of
        Enc->
            {Enc,State};
        latin1->
            {Enc,State};
        utf8
            when Enc == latin1->
            {Enc,State#state{deduced_encoding = latin1}};
        undefined->
            {Enc,State#state{deduced_encoding = Enc}}
    end.

out_enc(#state{encoding = PeerEnc,deduced_encoding = DeducedEnc}) ->
    case DeducedEnc of
        undefined->
            PeerEnc;
        _->
            DeducedEnc
    end.

to_group([],_Group) ->
    ok;
to_group([$\\| Tail],Group) ->
    exit(Group,interrupt),
    to_group(Tail,Group);
to_group(Data,Group) ->
    Func = fun (C)->
        C /= $\\ end,
    Tail = case lists:splitwith(Func,Data) of
        {[],Right}->
            Right;
        {Left,Right}->
            Group ! {self(),{data,Left}},
            Right
    end,
    to_group(Tail,Group).

io_request({window_change,OldTty},Buf,Tty,_Group) ->
    window_change(Tty,OldTty,Buf);
io_request({put_chars,Cs},Buf,Tty,_Group) ->
    put_chars(bin_to_list(Cs),Buf,Tty);
io_request({put_chars,unicode,Cs},Buf,Tty,_Group) ->
    put_chars(unicode:characters_to_list(Cs,unicode),Buf,Tty);
io_request({insert_chars,Cs},Buf,Tty,_Group) ->
    insert_chars(bin_to_list(Cs),Buf,Tty);
io_request({insert_chars,unicode,Cs},Buf,Tty,_Group) ->
    insert_chars(unicode:characters_to_list(Cs,unicode),Buf,Tty);
io_request({move_rel,N},Buf,Tty,_Group) ->
    move_rel(N,Buf,Tty);
io_request({delete_chars,N},Buf,Tty,_Group) ->
    delete_chars(N,Buf,Tty);
io_request(beep,Buf,_Tty,_Group) ->
    {[7],Buf};
io_request({get_geometry,columns},Buf,Tty,_Group) ->
    {ok,Tty#ssh_pty.width,Buf};
io_request({get_geometry,rows},Buf,Tty,_Group) ->
    {ok,Tty#ssh_pty.height,Buf};
io_request({requests,Rs},Buf,Tty,Group) ->
    io_requests(Rs,Buf,Tty,[],Group);
io_request(tty_geometry,Buf,Tty,Group) ->
    io_requests([{move_rel,0}, {put_chars,unicode,[10]}],Buf,Tty,[],Group);
io_request({put_chars_sync,Class,Cs,Reply},Buf,Tty,Group) ->
    Group ! {reply,Reply},
    io_request({put_chars,Class,Cs},Buf,Tty,Group);
io_request(_R,Buf,_Tty,_Group) ->
    {[],Buf}.

io_requests([R| Rs],Buf,Tty,Acc,Group) ->
    {Chars,NewBuf} = io_request(R,Buf,Tty,Group),
    io_requests(Rs,NewBuf,Tty,[Acc| Chars],Group);
io_requests([],Buf,_Tty,Acc,_Group) ->
    {Acc,Buf}.

ansi_tty(N,L) ->
    ["\e[", integer_to_list(N), L].

get_tty_command(up,N,_TerminalType) ->
    ansi_tty(N,$A);
get_tty_command(down,N,_TerminalType) ->
    ansi_tty(N,$B);
get_tty_command(right,N,_TerminalType) ->
    ansi_tty(N,$C);
get_tty_command(left,N,_TerminalType) ->
    ansi_tty(N,$D).

conv_buf([],AccBuf,AccBufTail,AccWrite,Col,_Tty) ->
    {AccBuf,AccBufTail,lists:reverse(AccWrite),Col};
conv_buf([13, 10| Rest],_AccBuf,AccBufTail,AccWrite,_Col,Tty) ->
    conv_buf(Rest,[],tl2(AccBufTail),[10, 13| AccWrite],0,Tty);
conv_buf([13| Rest],_AccBuf,AccBufTail,AccWrite,_Col,Tty) ->
    conv_buf(Rest,[],tl1(AccBufTail),[13| AccWrite],0,Tty);
conv_buf([10| Rest],_AccBuf,AccBufTail,AccWrite0,_Col,Tty) ->
    AccWrite = case pty_opt(onlcr,Tty) of
        0->
            [10| AccWrite0];
        1->
            [10, 13| AccWrite0];
        undefined->
            [10| AccWrite0]
    end,
    conv_buf(Rest,[],tl1(AccBufTail),AccWrite,0,Tty);
conv_buf([C| Rest],AccBuf,AccBufTail,AccWrite,Col,Tty) ->
    conv_buf(Rest,[C| AccBuf],tl1(AccBufTail),[C| AccWrite],Col + 1,Tty).

put_chars(Chars,{Buf,BufTail,Col},Tty) ->
    {NewBuf,NewBufTail,WriteBuf,NewCol} = conv_buf(Chars,Buf,BufTail,[],Col,Tty),
    {WriteBuf,{NewBuf,NewBufTail,NewCol}}.

insert_chars([],{Buf,BufTail,Col},_Tty) ->
    {[],{Buf,BufTail,Col}};
insert_chars(Chars,{Buf,BufTail,Col},Tty) ->
    {NewBuf,_NewBufTail,WriteBuf,NewCol} = conv_buf(Chars,Buf,[],[],Col,Tty),
    M = move_cursor(special_at_width(NewCol + length(BufTail),Tty),NewCol,Tty),
    {[WriteBuf, BufTail| M],{NewBuf,BufTail,NewCol}}.

delete_chars(0,{Buf,BufTail,Col},_Tty) ->
    {[],{Buf,BufTail,Col}};
delete_chars(N,{Buf,BufTail,Col},Tty)
    when N > 0->
    NewBufTail = nthtail(N,BufTail),
    M = move_cursor(Col + length(NewBufTail) + N,Col,Tty),
    {[NewBufTail, lists:duplicate(N,$ )| M],{Buf,NewBufTail,Col}};
delete_chars(N,{Buf,BufTail,Col},Tty) ->
    NewBuf = nthtail(-N,Buf),
    NewCol = case Col + N of
        V
            when V >= 0->
            V;
        _->
            0
    end,
    M1 = move_cursor(Col,NewCol,Tty),
    M2 = move_cursor(special_at_width(NewCol + length(BufTail) - N,Tty),NewCol,Tty),
    {[M1, BufTail, lists:duplicate(-N,$ )| M2],{NewBuf,BufTail,NewCol}}.

window_change(Tty,OldTty,Buf)
    when OldTty#ssh_pty.width == Tty#ssh_pty.width->
    {[],Buf};
window_change(Tty,OldTty,{Buf,BufTail,Col}) ->
    case OldTty#ssh_pty.width - Tty#ssh_pty.width of
        0->
            {[],{Buf,BufTail,Col}};
        DeltaW0
            when DeltaW0 < 0,
            BufTail == []->
            {[],{Buf,BufTail,Col}};
        DeltaW0
            when DeltaW0 < 0,
            BufTail =/= []->
            {[],{Buf,BufTail,Col}};
        DeltaW0
            when DeltaW0 > 0->
            {[],{Buf,BufTail,Col}}
    end.

step_over(0,Buf,[10| BufTail],Col) ->
    {[10| Buf],BufTail,Col + 1};
step_over(0,Buf,BufTail,Col) ->
    {Buf,BufTail,Col};
step_over(N,[C| Buf],BufTail,Col)
    when N < 0->
    N1 = ifelse(C == 10,N,N + 1),
    step_over(N1,Buf,[C| BufTail],Col - 1);
step_over(N,Buf,[C| BufTail],Col)
    when N > 0->
    N1 = ifelse(C == 10,N,N - 1),
    step_over(N1,[C| Buf],BufTail,Col + 1).

empty_buf() ->
    {[],[],0}.

col(N,W) ->
    N rem W.

row(N,W) ->
    N div W.

move_rel(N,{Buf,BufTail,Col},Tty) ->
    {NewBuf,NewBufTail,NewCol} = step_over(N,Buf,BufTail,Col),
    M = move_cursor(Col,NewCol,Tty),
    {M,{NewBuf,NewBufTail,NewCol}}.

move_cursor(A,A,_Tty) ->
    [];
move_cursor(From,To,#ssh_pty{width = Width,term = Type}) ->
    Tcol = case col(To,Width) - col(From,Width) of
        0->
            "";
        I
            when I < 0->
            get_tty_command(left,-I,Type);
        I->
            get_tty_command(right,I,Type)
    end,
    Trow = case row(To,Width) - row(From,Width) of
        0->
            "";
        J
            when J < 0->
            get_tty_command(up,-J,Type);
        J->
            get_tty_command(down,J,Type)
    end,
    [Tcol| Trow].

special_at_width(From0,#ssh_pty{width = Width})
    when From0 rem Width == 0->
    From0 - 1;
special_at_width(From0,_) ->
    From0.

write_chars(ConnectionHandler,ChannelId,Chars) ->
    write_chars(ConnectionHandler,ChannelId,0,Chars).

write_chars(ConnectionHandler,ChannelId,Type,Chars) ->
    case has_chars(Chars) of
        false->
            ok;
        true->
            ssh_connection:send(ConnectionHandler,ChannelId,Type,Chars)
    end.

has_chars([C| _])
    when is_integer(C)->
    true;
has_chars([H| T])
    when is_list(H);
    is_binary(H)->
    has_chars(H) orelse has_chars(T);
has_chars(<<_:8,_/binary>>) ->
    true;
has_chars(_) ->
    false.

tl1([_| A]) ->
    A;
tl1(_) ->
    [].

tl2([_, _| A]) ->
    A;
tl2(_) ->
    [].

nthtail(0,A) ->
    A;
nthtail(N,[_| A])
    when N > 0->
    nthtail(N - 1,A);
nthtail(_,_) ->
    [].

ifelse(Cond,A,B) ->
    case Cond of
        true->
            A;
        _->
            B
    end.

bin_to_list(B)
    when is_binary(B)->
    binary_to_list(B);
bin_to_list(L)
    when is_list(L)->
    lists:flatten([(bin_to_list(A)) || A <- L]);
bin_to_list(I)
    when is_integer(I)->
    I.

start_shell(ConnectionHandler,State) ->
    ShellSpawner = case State#state.shell of
        Shell
            when is_function(Shell,1)->
            [{user,User}] = ssh_connection_handler:connection_info(ConnectionHandler,[user]),
            fun ()->
                Shell(User) end;
        Shell
            when is_function(Shell,2)->
            ConnectionInfo = ssh_connection_handler:connection_info(ConnectionHandler,[peer, user]),
            User = proplists:get_value(user,ConnectionInfo),
            {_,PeerAddr} = proplists:get_value(peer,ConnectionInfo),
            fun ()->
                Shell(User,PeerAddr) end;
        {_,_,_} = Shell->
            Shell
    end,
    State#state{group = group:start(self(),ShellSpawner,[{echo,get_echo(State#state.pty)}]),buf = empty_buf()}.

start_exec_shell(ConnectionHandler,Cmd,State) ->
    ExecShellSpawner = case State#state.exec of
        ExecShell
            when is_function(ExecShell,1)->
            fun ()->
                ExecShell(Cmd) end;
        ExecShell
            when is_function(ExecShell,2)->
            [{user,User}] = ssh_connection_handler:connection_info(ConnectionHandler,[user]),
            fun ()->
                ExecShell(Cmd,User) end;
        ExecShell
            when is_function(ExecShell,3)->
            ConnectionInfo = ssh_connection_handler:connection_info(ConnectionHandler,[peer, user]),
            User = proplists:get_value(user,ConnectionInfo),
            {_,PeerAddr} = proplists:get_value(peer,ConnectionInfo),
            fun ()->
                ExecShell(Cmd,User,PeerAddr) end;
        {M,F,A}->
            {M,F,A ++ [Cmd]}
    end,
    State#state{group = group:start(self(),ExecShellSpawner,[{echo,false}]),buf = empty_buf()}.

exec_in_erlang_default_shell(ConnectionHandler,ChannelId,Cmd,WantReply,State) ->
    exec_in_self_group(ConnectionHandler,ChannelId,WantReply,State,fun ()->
        eval(parse(scan(Cmd))) end).

scan(Cmd) ->
    erl_scan:string(Cmd).

parse({ok,Tokens,_}) ->
    erl_parse:parse_exprs(Tokens);
parse({error,{_,erl_scan,Cause},_}) ->
    {error,erl_scan:format_error(Cause)}.

eval({ok,Expr_list}) ->
    {value,Value,_NewBindings} = erl_eval:exprs(Expr_list,erl_eval:new_bindings()),
    {ok,Value};
eval({error,{_,erl_parse,Cause}}) ->
    {error,erl_parse:format_error(Cause)};
eval({error,Error}) ->
    {error,Error}.

exec_direct(ConnectionHandler,ChannelId,Cmd,ExecSpec,WantReply,State) ->
    Fun = fun ()->
        if is_function(ExecSpec,1) ->
            ExecSpec(Cmd);is_function(ExecSpec,2) ->
            [{user,User}] = ssh_connection_handler:connection_info(ConnectionHandler,[user]),
            ExecSpec(Cmd,User);is_function(ExecSpec,3) ->
            ConnectionInfo = ssh_connection_handler:connection_info(ConnectionHandler,[peer, user]),
            User = proplists:get_value(user,ConnectionInfo),
            {_,PeerAddr} = proplists:get_value(peer,ConnectionInfo),
            ExecSpec(Cmd,User,PeerAddr);true ->
            {error,"Bad exec fun in server"} end end,
    exec_in_self_group(ConnectionHandler,ChannelId,WantReply,State,Fun).

exec_in_self_group(ConnectionHandler,ChannelId,WantReply,State,Fun) ->
    Exec = fun ()->
        spawn(fun ()->
            case try ssh_connection:reply_request(ConnectionHandler,WantReply,success,ChannelId),
            Fun() of 
                {ok,Result}->
                    {ok,Result};
                {error,Error}->
                    {error,Error};
                X->
                    {error,"Bad exec fun in server. Inval" "id return value: " ++ t2str(X)}
                catch
                    error:Err->
                        {error,Err};
                    Cls:Exp->
                        {error,{Cls,Exp}} end of
                {ok,Str}->
                    write_chars(ConnectionHandler,ChannelId,t2str(Str));
                {error,Str}->
                    write_chars(ConnectionHandler,ChannelId,1,"**Error** " ++ t2str(Str)),
                    exit({exit_status,255})
            end end) end,
    {ok,State#state{group = group:start(self(),Exec,[{echo,false}]),buf = empty_buf()}}.

t2str(T) ->
    try io_lib:format("~s",[T])
        catch
            _:_->
                io_lib:format("~p",[T]) end.

get_echo(Tty) ->
    case pty_opt(echo,Tty) of
        0->
            false;
        1->
            true;
        undefined->
            true
    end.

set_echo(#state{group = undefined}) ->
    ok;
set_echo(#state{group = Group,pty = Pty}) ->
    Echo = get_echo(Pty),
    Group ! {self(),echo,Echo}.

not_zero(0,B) ->
    B;
not_zero(A,_) ->
    A.

pty_opt(Name,Tty) ->
    try proplists:get_value(Name,Tty#ssh_pty.modes,undefined)
        catch
            _:_->
                undefined end.

ssh_dbg_trace_points() ->
    [terminate, cli, cli_details].

ssh_dbg_flags(cli) ->
    [c];
ssh_dbg_flags(terminate) ->
    [c].

ssh_dbg_on(cli) ->
    dbg:tp(ssh_cli,handle_ssh_msg,2,x),
    dbg:tp(ssh_cli,write_chars,4,x);
ssh_dbg_on(cli_details) ->
    dbg:tp(ssh_cli,handle_msg,2,x);
ssh_dbg_on(terminate) ->
    dbg:tp(ssh_cli,terminate,2,x).

ssh_dbg_off(cli) ->
    dbg:ctpg(ssh_cli,handle_ssh_msg,2),
    dbg:ctpg(ssh_cli,write_chars,4);
ssh_dbg_off(cli_details) ->
    dbg:ctpg(ssh_cli,handle_msg,2);
ssh_dbg_off(terminate) ->
    dbg:ctpg(ssh_cli,terminate,2).

ssh_dbg_format(cli,{call,{ssh_cli,handle_ssh_msg,[{ssh_cm,_ConnectionHandler,Request}, S = #state{channel = Ch}]}})
    when is_tuple(Request)->
    [io_lib:format("CLI conn ~p chan ~p, req ~p",[self(), Ch, element(1,Request)]), case Request of
        {window_change,ChannelId,Width,Height,PixWidth,PixHeight}->
            fmt_kv([{channel_id,ChannelId}, {width,Width}, {height,Height}, {pix_width,PixWidth}, {pixel_hight,PixHeight}]);
        {env,ChannelId,WantReply,Var,Value}->
            fmt_kv([{channel_id,ChannelId}, {want_reply,WantReply}, {Var,Value}]);
        {exec,ChannelId,WantReply,Cmd}->
            fmt_kv([{channel_id,ChannelId}, {want_reply,WantReply}, {command,Cmd}]);
        {pty,ChannelId,WantReply,{TermName,Width,Height,PixWidth,PixHeight,Modes}}->
            fmt_kv([{channel_id,ChannelId}, {want_reply,WantReply}, {term,TermName}, {width,Width}, {height,Height}, {pix_width,PixWidth}, {pixel_hight,PixHeight}, {pty_opts,Modes}]);
        {data,ChannelId,Type,Data}->
            fmt_kv([{channel_id,ChannelId}, {type,type(Type)}, {data,us,ssh_dbg:shrink_bin(Data)}, {hex,h,Data}]);
        {shell,ChannelId,WantReply}->
            fmt_kv([{channel_id,ChannelId}, {want_reply,WantReply}, {encoding,S#state.encoding}, {pty,S#state.pty}]);
        _->
            io_lib:format("~nunder construction:~nRequest = ~p",[Request])
    end];
ssh_dbg_format(cli,{call,{ssh_cli,handle_ssh_msg,_}}) ->
    skip;
ssh_dbg_format(cli,{return_from,{ssh_cli,handle_ssh_msg,2},_Result}) ->
    skip;
ssh_dbg_format(cli,{call,{ssh_cli,write_chars,[C, Ch, Type, Chars]}}) ->
    [io_lib:format("CLI conn ~p chan ~p reply",[C, Ch]), fmt_kv([{channel_id,Ch}, {type,type(Type)}, {data,us,ssh_dbg:shrink_bin(Chars)}, {hex,h,Chars}])];
ssh_dbg_format(cli,{return_from,{ssh_cli,write_chars,4},_Result}) ->
    skip;
ssh_dbg_format(cli_details,{call,{ssh_cli,handle_msg,[{Group,Arg}, #state{channel = Ch}]}}) ->
    [io_lib:format("CLI detail conn ~p chan ~p group ~p",['?', Ch, Group]), case Arg of
        {put_chars_sync,Class,Cs,Reply}->
            fmt_kv([{op,put_chars_sync}, {class,Class}, {data,us,ssh_dbg:shrink_bin(Cs)}, {hex,h,Cs}, {reply,Reply}]);
        _->
            io_lib:format("~nunder construction:~nRequest = ~p",[Arg])
    end];
ssh_dbg_format(cli_details,{call,{ssh_cli,handle_msg,_}}) ->
    skip;
ssh_dbg_format(cli_details,{return_from,{ssh_cli,handle_msg,2},_Result}) ->
    skip;
ssh_dbg_format(terminate,{call,{ssh_cli,terminate,[Reason, State]}}) ->
    ["Cli Terminating:\n", io_lib:format("Reason: ~p,~nState:~n~s",[Reason, wr_record(State)])];
ssh_dbg_format(terminate,{return_from,{ssh_cli,terminate,2},_Ret}) ->
    skip.

wr_record(R = #state{}) ->
    ssh_dbg:wr_record(R,record_info(fields,state),[]).

fmt_kv(KVs) ->
    lists:map(fun fmt_kv1/1,KVs).

fmt_kv1({K,V}) ->
    io_lib:format("~n~p: ~p",[K, V]);
fmt_kv1({K,s,V}) ->
    io_lib:format("~n~p: ~s",[K, V]);
fmt_kv1({K,us,V}) ->
    io_lib:format("~n~p: ~ts",[K, V]);
fmt_kv1({K,h,V}) ->
    io_lib:format("~n~p: ~s",[K, [$\n| ssh_dbg:hex_dump(V)]]).

type(0) ->
    "0 (normal data)";
type(1) ->
    "1 (extended data, i.e. errors)";
type(T) ->
    T.
-file("ssh_client_channel.erl", 1).

-module(ssh_client_channel).

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

-file("ssh_client_channel.erl", 26).

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

-file("ssh_client_channel.erl", 27).

-callback(init(Args::term()) -> {ok,State::term()}|{ok,State::term(),timeout()|hibernate}|{stop,Reason::term()}|ignore).

-callback(handle_call(Request::term(),From::{pid(),Tag::term()},State::term()) -> {reply,Reply::term(),NewState::term()}|{reply,Reply::term(),NewState::term(),timeout()|hibernate}|{noreply,NewState::term()}|{noreply,NewState::term(),timeout()|hibernate}|{stop,Reason::term(),Reply::term(),NewState::term()}|{stop,Reason::term(),NewState::term()}).

-callback(handle_cast(Request::term(),State::term()) -> {noreply,NewState::term()}|{noreply,NewState::term(),timeout()|hibernate}|{stop,Reason::term(),NewState::term()}).

-callback(terminate(Reason::normal|shutdown|{shutdown,term()}|term(),State::term()) -> term()).

-callback(code_change(OldVsn::term()|{down,term()},State::term(),Extra::term()) -> {ok,NewState::term()}|{error,Reason::term()}).

-callback(handle_msg(Msg::term(),State::term()) -> {ok,State::term()}|{stop,ChannelId::ssh:channel_id(),State::term()}).

-callback(handle_ssh_msg(ssh_connection:event(),State::term()) -> {ok,State::term()}|{stop,ChannelId::ssh:channel_id(),State::term()}).

-behaviour(gen_server).

-export([start/4, start/5, start_link/4, start_link/5, call/2, call/3, cast/2, reply/2, enter_loop/1]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([cache_create/0, cache_lookup/2, cache_update/2, cache_delete/1, cache_delete/2, cache_foldl/3, cache_info/2, cache_find/2, get_print_info/1]).

-behaviour(ssh_dbg).

-export([ssh_dbg_trace_points/0, ssh_dbg_flags/1, ssh_dbg_on/1, ssh_dbg_off/1, ssh_dbg_format/2]).

-record(state, {cm,channel_cb,channel_state,channel_id,close_sent = false}).

call(ChannelPid,Msg) ->
    call(ChannelPid,Msg,infinity).

call(ChannelPid,Msg,TimeOute) ->
    try gen_server:call(ChannelPid,Msg,TimeOute) of 
        Result->
            Result
        catch
            exit:{noproc,_}->
                {error,closed};
            exit:{normal,_}->
                {error,closed};
            exit:{shutdown,_}->
                {error,closed};
            exit:{{shutdown,_},_}->
                {error,closed};
            exit:{timeout,_}->
                {error,timeout} end.

cast(ChannelPid,Msg) ->
    gen_server:cast(ChannelPid,Msg).

reply(From,Msg) ->
    gen_server:reply(From,Msg).

start(ConnectionManager,ChannelId,CallBack,CbInitArgs) ->
    start(ConnectionManager,ChannelId,CallBack,CbInitArgs,undefined).

start(ConnectionManager,ChannelId,CallBack,CbInitArgs,Exec) ->
    Options = [{channel_cb,CallBack}, {channel_id,ChannelId}, {init_args,CbInitArgs}, {cm,ConnectionManager}, {exec,Exec}],
    gen_server:start(ssh_client_channel,[Options],[]).

start_link(ConnectionManager,ChannelId,CallBack,CbInitArgs) ->
    start_link(ConnectionManager,ChannelId,CallBack,CbInitArgs,undefined).

start_link(ConnectionManager,ChannelId,CallBack,CbInitArgs,Exec) ->
    Options = [{channel_cb,CallBack}, {channel_id,ChannelId}, {init_args,CbInitArgs}, {cm,ConnectionManager}, {exec,Exec}],
    gen_server:start_link(ssh_client_channel,[Options],[]).

enter_loop(State) ->
    gen_server:enter_loop(ssh_client_channel,[],State).

init([Options]) ->
    Cb = proplists:get_value(channel_cb,Options),
    ConnectionManager = proplists:get_value(cm,Options),
    ChannelId = proplists:get_value(channel_id,Options),
    process_flag(trap_exit,true),
    try Cb:init(channel_cb_init_args(Options)) of 
        {ok,ChannelState}->
            State = #state{cm = ConnectionManager,channel_cb = Cb,channel_id = ChannelId,channel_state = ChannelState},
            self() ! {ssh_channel_up,ChannelId,ConnectionManager},
            {ok,State};
        {ok,ChannelState,Timeout}->
            State = #state{cm = ConnectionManager,channel_cb = Cb,channel_id = ChannelId,channel_state = ChannelState},
            self() ! {ssh_channel_up,ChannelId,ConnectionManager},
            {ok,State,Timeout};
        {stop,Why}->
            {stop,Why}
        catch
            _:undef->
                {stop,{bad_channel_callback_module,Cb}};
            _:Reason->
                {stop,Reason} end.

channel_cb_init_args(Options) ->
    case proplists:get_value(exec,Options) of
        undefined->
            proplists:get_value(init_args,Options);
        Exec->
            proplists:get_value(init_args,Options) ++ [Exec]
    end.

handle_call(get_print_info,_From,State) ->
    Reply = {{State#state.cm,State#state.channel_id},io_lib:format('CB=~p',[State#state.channel_cb])},
    {reply,Reply,State};
handle_call(Request,From,#state{channel_cb = Module,channel_state = ChannelState} = State) ->
    try Module:handle_call(Request,From,ChannelState) of 
        Result->
            handle_cb_result(Result,State)
        catch
            error:{undef,_}->
                {noreply,State} end.

handle_cast(Msg,#state{channel_cb = Module,channel_state = ChannelState} = State) ->
    try Module:handle_cast(Msg,ChannelState) of 
        Result->
            handle_cb_result(Result,State)
        catch
            error:{undef,_}->
                {noreply,State} end.

handle_info({ssh_cm,ConnectionManager,{closed,_ChannelId}},#state{cm = ConnectionManager,close_sent = true} = State) ->
    {stop,normal,State};
handle_info({ssh_cm,ConnectionManager,{closed,ChannelId}},#state{cm = ConnectionManager,close_sent = false} = State) ->
     catch ssh_connection:close(ConnectionManager,ChannelId),
    {stop,normal,State#state{close_sent = true}};
handle_info({ssh_cm,_,_} = Msg,#state{cm = ConnectionManager,channel_cb = Module,channel_state = ChannelState0} = State) ->
    case Module:handle_ssh_msg(Msg,ChannelState0) of
        {ok,ChannelState}->
            adjust_window(Msg),
            {noreply,State#state{channel_state = ChannelState}};
        {ok,ChannelState,Timeout}->
            adjust_window(Msg),
            {noreply,State#state{channel_state = ChannelState},Timeout};
        {stop,ChannelId,ChannelState}->
             catch ssh_connection:close(ConnectionManager,ChannelId),
            {stop,normal,State#state{close_sent = true,channel_state = ChannelState}}
    end;
handle_info(Msg,#state{cm = ConnectionManager,channel_cb = Module,channel_state = ChannelState0} = State) ->
    case Module:handle_msg(Msg,ChannelState0) of
        {ok,ChannelState}->
            {noreply,State#state{channel_state = ChannelState}};
        {ok,ChannelState,Timeout}->
            {noreply,State#state{channel_state = ChannelState},Timeout};
        {stop,Reason,ChannelState}
            when is_atom(Reason)->
            {stop,Reason,State#state{close_sent = true,channel_state = ChannelState}};
        {stop,ChannelId,ChannelState}->
            Reason = case Msg of
                {'EXIT',_Pid,shutdown}->
                    shutdown;
                _->
                    normal
            end,
             catch ssh_connection:close(ConnectionManager,ChannelId),
            {stop,Reason,State#state{close_sent = true,channel_state = ChannelState}}
    end.

terminate(Reason,#state{cm = ConnectionManager,channel_id = ChannelId,close_sent = false} = State) ->
     catch ssh_connection:close(ConnectionManager,ChannelId),
    terminate(Reason,State#state{close_sent = true});
terminate(Reason,#state{channel_cb = Cb,channel_state = ChannelState}) ->
     catch Cb:terminate(Reason,ChannelState),
    ok.

code_change(OldVsn,#state{channel_cb = Module,channel_state = ChannelState0} = State,Extra) ->
    {ok,ChannelState} = Module:code_change(OldVsn,ChannelState0,Extra),
    {ok,State#state{channel_state = ChannelState}}.

cache_create() ->
    ets:new(cm_tab,[set, {keypos,#channel.local_id}]).

cache_lookup(Cache,Key) ->
    case ets:lookup(Cache,Key) of
        [Channel]->
            Channel;
        []->
            undefined
    end.

cache_update(Cache,#channel{local_id = Id} = Entry)
    when Id =/= undefined->
    ets:insert(Cache,Entry).

cache_delete(Cache,Key) ->
    ets:delete(Cache,Key).

cache_delete(Cache) ->
    ets:delete(Cache).

cache_foldl(Fun,Acc,Cache) ->
    ets:foldl(Fun,Acc,Cache).

cache_info(num_entries,Cache) ->
    proplists:get_value(size,ets:info(Cache)).

cache_find(ChannelPid,Cache) ->
    case ets:match_object(Cache,#channel{user = ChannelPid}) of
        []->
            undefined;
        [Channel]->
            Channel
    end.

get_print_info(Pid) ->
    call(Pid,get_print_info,1000).

handle_cb_result({reply,Reply,ChannelState},State) ->
    {reply,Reply,State#state{channel_state = ChannelState}};
handle_cb_result({reply,Reply,ChannelState,Timeout},State) ->
    {reply,Reply,State#state{channel_state = ChannelState},Timeout};
handle_cb_result({noreply,ChannelState},State) ->
    {noreply,State#state{channel_state = ChannelState}};
handle_cb_result({noreply,ChannelState,Timeout},State) ->
    {noreply,State#state{channel_state = ChannelState},Timeout};
handle_cb_result({stop,Reason,Reply,ChannelState},State) ->
    {stop,Reason,Reply,State#state{channel_state = ChannelState}};
handle_cb_result({stop,Reason,ChannelState},State) ->
    {stop,Reason,State#state{channel_state = ChannelState}}.

adjust_window({ssh_cm,ConnectionManager,{data,ChannelId,_,Data}}) ->
    ssh_connection:adjust_window(ConnectionManager,ChannelId,size(Data));
adjust_window(_) ->
    ok.

ssh_dbg_trace_points() ->
    [terminate, channels, channel_events].

ssh_dbg_flags(channels) ->
    [c];
ssh_dbg_flags(terminate) ->
    [c];
ssh_dbg_flags(channel_events) ->
    [c].

ssh_dbg_on(terminate) ->
    dbg:tp(ssh_client_channel,terminate,2,x);
ssh_dbg_on(channels) ->
    dbg:tp(ssh_client_channel,init,1,x),
    ssh_dbg_on(terminate);
ssh_dbg_on(channel_events) ->
    dbg:tp(ssh_client_channel,handle_call,3,x),
    dbg:tp(ssh_client_channel,handle_cast,2,x),
    dbg:tp(ssh_client_channel,handle_info,2,x).

ssh_dbg_off(terminate) ->
    dbg:ctpg(ssh_client_channel,terminate,2);
ssh_dbg_off(channels) ->
    dbg:ctpg(ssh_client_channel,init,1),
    ssh_dbg_off(terminate);
ssh_dbg_off(channel_events) ->
    dbg:ctpg(ssh_client_channel,handle_call,3),
    dbg:ctpg(ssh_client_channel,handle_cast,2),
    dbg:ctpg(ssh_client_channel,handle_info,2).

ssh_dbg_format(channels,{call,{ssh_client_channel,init,[[KVs]]}}) ->
    ["Server Channel Starting:\n", io_lib:format("Connection: ~p, ChannelId: ~p, CallBack: ~p\nCallBa" "ck init args = ~p",[(proplists:get_value(K,KVs)) || K <- [cm, channel_id, channel_cb]] ++ [channel_cb_init_args(KVs)])];
ssh_dbg_format(channels,{return_from,{ssh_client_channel,init,1},{stop,Reason}}) ->
    ["Server Channel Start FAILED!\n", io_lib:format("Reason = ~p",[Reason])];
ssh_dbg_format(channels,F) ->
    ssh_dbg_format(terminate,F);
ssh_dbg_format(terminate,{call,{ssh_client_channel,terminate,[Reason, State]}}) ->
    ["Server Channel Terminating:\n", io_lib:format("Reason: ~p,~nState:~n~s",[Reason, wr_record(State)])];
ssh_dbg_format(terminate,{return_from,{ssh_client_channel,terminate,2},_Ret}) ->
    skip;
ssh_dbg_format(channel_events,{call,{ssh_client_channel,handle_call,[Call, From, State]}}) ->
    [hdr("is called",State), io_lib:format("From: ~p~nCall: ~p~n",[From, Call])];
ssh_dbg_format(channel_events,{return_from,{ssh_client_channel,handle_call,3},Ret}) ->
    ["Server Channel call returned:\n", io_lib:format("~p~n",[ssh_dbg:reduce_state(Ret,#state{})])];
ssh_dbg_format(channel_events,{call,{ssh_client_channel,handle_cast,[Cast, State]}}) ->
    [hdr("got cast",State), io_lib:format("Cast: ~p~n",[Cast])];
ssh_dbg_format(channel_events,{return_from,{ssh_client_channel,handle_cast,2},Ret}) ->
    ["Server Channel cast returned:\n", io_lib:format("~p~n",[ssh_dbg:reduce_state(Ret,#state{})])];
ssh_dbg_format(channel_events,{call,{ssh_client_channel,handle_info,[Info, State]}}) ->
    [hdr("got info",State), io_lib:format("Info: ~p~n",[Info])];
ssh_dbg_format(channel_events,{return_from,{ssh_client_channel,handle_info,2},Ret}) ->
    ["Server Channel info returned:\n", io_lib:format("~p~n",[ssh_dbg:reduce_state(Ret,#state{})])].

hdr(Title,S) ->
    io_lib:format("Server Channel (Id=~p, CB=~p) ~s:\n",[S#state.channel_id, S#state.channel_cb, Title]).

wr_record(R = #state{}) ->
    ssh_dbg:wr_record(R,record_info(fields,state),[]).
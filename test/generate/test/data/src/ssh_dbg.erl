-file("ssh_dbg.erl", 1).

-module(ssh_dbg).

-export([start/0, start/1, stop/0, start_server/0, start_tracer/0, start_tracer/1, on/1, on/0, off/1, off/0, is_on/0, is_off/0, go_on/0, cbuf_start/0, cbuf_start/1, cbuf_stop_clear/0, cbuf_in/1, cbuf_list/0, hex_dump/1, hex_dump/2, fmt_cbuf_items/0, fmt_cbuf_item/1]).

-export([shrink_bin/1, reduce_state/2, reduce_state/3, wr_record/3]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).

-export([ets_delete/2]).

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

-file("ssh_dbg.erl", 79).

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

-file("ssh_dbg.erl", 80).

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

-file("ssh_dbg.erl", 81).

-file("ssh_auth.hrl", 1).

-record(ssh_msg_userauth_request, {user,service,method,data}).

-record(ssh_msg_userauth_failure, {authentications,partial_success}).

-record(ssh_msg_userauth_success, {}).

-record(ssh_msg_userauth_banner, {message,language}).

-record(ssh_msg_userauth_passwd_changereq, {prompt,languge}).

-record(ssh_msg_userauth_pk_ok, {algorithm_name,key_blob}).

-record(ssh_msg_userauth_info_request, {name,instruction,language_tag,num_prompts,data}).

-record(ssh_msg_userauth_info_response, {num_responses,data}).

-file("ssh_dbg.erl", 82).

-behaviour(gen_server).

-type(trace_point()::atom()).

-type(trace_points()::[trace_point()]).

-type(stack()::[term()]).

-callback(ssh_dbg_trace_points() -> trace_points()).

-callback(ssh_dbg_flags(trace_point()) -> [atom()]).

-callback(ssh_dbg_on(trace_point()|trace_points()) -> term()).

-callback(ssh_dbg_off(trace_point()|trace_points()) -> term()).

-callback(ssh_dbg_format(trace_point(),term()) -> iolist()|skip).

-callback(ssh_dbg_format(trace_point(),term(),stack()) -> {iolist()|skip,stack()}).

-optional_callbacks([ssh_dbg_format/2, ssh_dbg_format/3]).

start() ->
    start(fun io:format/2).

start(IoFmtFun)
    when is_function(IoFmtFun,2);
    is_function(IoFmtFun,3)->
    start_server(),
     catch dbg:start(),
    start_tracer(IoFmtFun),
    dbg:p(all,get_all_trace_flags()),
    get_all_dbg_types().

stop() ->
    try dbg:stop_clear(),
    gen_server:stop(ssh_dbg)
        catch
            _:_->
                ok end.

start_server() ->
    gen_server:start({local,ssh_dbg},ssh_dbg,[],[]).

start_tracer() ->
    start_tracer(fun io:format/2).

start_tracer(WriteFun)
    when is_function(WriteFun,2)->
    start_tracer(fun (F,A,S)->
        WriteFun(F,A),
        S end);
start_tracer(WriteFun)
    when is_function(WriteFun,3)->
    start_tracer(WriteFun,undefined).

start_tracer(WriteFun,InitAcc)
    when is_function(WriteFun,3)->
    Handler = fun (Arg,Acc0)->
        try_all_types_in_all_modules(gen_server:call(ssh_dbg,get_on,15000),Arg,WriteFun,Acc0) end,
    dbg:tracer(process,{Handler,InitAcc}).

on() ->
    on(get_all_dbg_types()).

on(Type) ->
    switch(on,Type).

is_on() ->
    gen_server:call(ssh_dbg,get_on,15000).

off() ->
    off(get_all_dbg_types()).

off(Type) ->
    switch(off,Type).

is_off() ->
    get_all_dbg_types() -- is_on().

go_on() ->
    IsOn = gen_server:call(ssh_dbg,get_on,15000),
    on(IsOn).

shrink_bin(B)
    when is_binary(B),
    size(B) > 256->
    {'*** SHRINKED BIN',size(B),element(1,split_binary(B,64)),'...',element(2,split_binary(B,size(B) - 64))};
shrink_bin(L)
    when is_list(L)->
    lists:map(fun shrink_bin/1,L);
shrink_bin(T)
    when is_tuple(T)->
    list_to_tuple(shrink_bin(tuple_to_list(T)));
shrink_bin(X) ->
    X.

reduce_state(T,RecordExample) ->
    Name = element(1,RecordExample),
    Arity = size(RecordExample),
    reduce_state(T,Name,Arity).

reduce_state(T,Name,Arity)
    when element(1,T) == Name,
    size(T) == Arity->
    lists:concat(['#', Name, '{}']);
reduce_state(L,Name,Arity)
    when is_list(L)->
    [(reduce_state(E,Name,Arity)) || E <- L];
reduce_state(T,Name,Arity)
    when is_tuple(T)->
    list_to_tuple(reduce_state(tuple_to_list(T),Name,Arity));
reduce_state(X,_,_) ->
    X.

-record(data, {types_on = []}).

init(_) ->
    new_table(),
    {ok,#data{}}.

new_table() ->
    try ets:new(ssh_dbg,[public, named_table]),
    ok
        catch
            exit:badarg->
                ok end.

get_proc_stack(Pid)
    when is_pid(Pid)->
    try ets:lookup_element(ssh_dbg,Pid,2)
        catch
            error:badarg->
                new_proc(Pid),
                ets:insert(ssh_dbg,{Pid,[]}),
                [] end.

put_proc_stack(Pid,Data)
    when is_pid(Pid),
    is_list(Data)->
    ets:insert(ssh_dbg,{Pid,Data}).

new_proc(Pid)
    when is_pid(Pid)->
    gen_server:cast(ssh_dbg,{new_proc,Pid}).

ets_delete(Tab,Key) ->
     catch ets:delete(Tab,Key).

handle_call({switch,on,Types},_From,D) ->
    NowOn = lists:usort(Types ++ D#data.types_on),
    call_modules(on,Types),
    {reply,{ok,NowOn},D#data{types_on = NowOn}};
handle_call({switch,off,Types},_From,D) ->
    StillOn = D#data.types_on -- Types,
    call_modules(off,Types),
    call_modules(on,StillOn),
    {reply,{ok,StillOn},D#data{types_on = StillOn}};
handle_call(get_on,_From,D) ->
    {reply,D#data.types_on,D};
handle_call(C,_From,D) ->
    io:format('*** Unknown call: ~p~n',[C]),
    {reply,{error,{unknown_call,C}},D}.

handle_cast({new_proc,Pid},D) ->
    monitor(process,Pid),
    {noreply,D};
handle_cast(C,D) ->
    io:format('*** Unknown cast: ~p~n',[C]),
    {noreply,D}.

handle_info({'DOWN',_MonitorRef,process,Pid,_Info},D) ->
    timer:apply_after(20000,ssh_dbg,ets_delete,[ssh_dbg, Pid]),
    {noreply,D};
handle_info(C,D) ->
    io:format('*** Unknown info: ~p~n',[C]),
    {noreply,D}.

ssh_modules_with_trace() ->
    {ok,AllSshModules} = application:get_key(ssh,modules),
    [M || M <- AllSshModules,{behaviour,Bs} <- M:module_info(attributes),lists:member(ssh_dbg,Bs)].

get_all_trace_flags() ->
    lists:usort(lists:flatten([timestamp| call_modules(flags,get_all_dbg_types())])).

get_all_dbg_types() ->
    lists:usort(lists:flatten(call_modules(points))).

call_modules(points) ->
    F = fun (Mod)->
        Mod:ssh_dbg_trace_points() end,
    fold_modules(F,[],ssh_modules_with_trace()).

call_modules(Cmnd,Types)
    when is_list(Types)->
    F = case Cmnd of
        flags->
            fun (Type)->
                fun (Mod)->
                    Mod:ssh_dbg_flags(Type) end end;
        on->
            fun (Type)->
                fun (Mod)->
                    Mod:ssh_dbg_on(Type) end end;
        off->
            fun (Type)->
                fun (Mod)->
                    Mod:ssh_dbg_off(Type) end end
    end,
    lists:foldl(fun (T,Acc)->
        fold_modules(F(T),Acc,ssh_modules_with_trace()) end,[],Types).

fold_modules(F,Acc0,Modules) ->
    lists:foldl(fun (Mod,Acc)->
        try F(Mod) of 
            Result->
                [Result| Acc]
            catch
                _:_->
                    Acc end end,Acc0,Modules).

switch(X,Type)
    when is_atom(Type)->
    switch(X,[Type]);
switch(X,Types)
    when is_list(Types)->
    case whereis(ssh_dbg) of
        undefined->
            start();
        _->
            ok
    end,
    case lists:usort(Types) -- get_all_dbg_types() of
        []->
            gen_server:call(ssh_dbg,{switch,X,Types},15000);
        L->
            {error,{unknown,L}}
    end.

trace_pid(T)
    when element(1,T) == trace;
    element(1,T) == trace_ts->
    element(2,T).

trace_ts(T)
    when element(1,T) == trace_ts->
    ts(element(size(T),T)).

trace_info(T) ->
    case tuple_to_list(T) of
        [trace, _Pid| Info]->
            list_to_tuple(Info);
        [trace_ts, _Pid| InfoTS]->
            list_to_tuple(lists:droplast(InfoTS))
    end.

try_all_types_in_all_modules(TypesOn,Arg,WriteFun,Acc0) ->
    SshModules = ssh_modules_with_trace(),
    TS = trace_ts(Arg),
    PID = trace_pid(Arg),
    INFO = trace_info(Arg),
    Acc = lists:foldl(fun (Type,Acc1)->
        lists:foldl(fun (SshMod,Acc)->
            try SshMod:ssh_dbg_format(Type,INFO) of 
                skip->
                    written;
                Txt
                    when is_list(Txt)->
                    write_txt(WriteFun,TS,PID,Txt)
                catch
                    error:E
                        when E == undef;
                        E == function_clause;
                        element(1,E) == case_clause->
                        try STACK = get_proc_stack(PID),
                        SshMod:ssh_dbg_format(Type,INFO,STACK) of 
                            {skip,NewStack}->
                                put_proc_stack(PID,NewStack),
                                written;
                            {Txt,NewStack}
                                when is_list(Txt)->
                                put_proc_stack(PID,NewStack),
                                write_txt(WriteFun,TS,PID,Txt)
                            catch
                                _:_->
                                    Acc end end end,Acc1,SshModules) end,Acc0,TypesOn),
    case Acc of
        Acc0->
            WriteFun("~n~s ~p DEBUG~n~p~n",[lists:flatten(TS), PID, INFO],Acc0);
        written->
            Acc0
    end.

write_txt(WriteFun,TS,PID,Txt)
    when is_list(Txt)->
    WriteFun("~n~s ~p ~ts~n",[lists:flatten(TS), PID, lists:flatten(Txt)],written).

wr_record(T,Fs,BL)
    when is_tuple(T)->
    wr_record(tuple_to_list(T),Fs,BL);
wr_record([_Name| Values],Fields,BlackL) ->
    W = case Fields of
        []->
            0;
        _->
            lists:max([(length(atom_to_list(F))) || F <- Fields])
    end,
    [(io_lib:format("  ~*p: ~p~n",[W, Tag, Value])) || {Tag,Value} <- lists:zip(Fields,Values), not lists:member(Tag,BlackL)].

ts({_,_,Usec} = Now)
    when is_integer(Usec)->
    {_Date,{HH,MM,SS}} = calendar:now_to_local_time(Now),
    io_lib:format("~.2.0w:~.2.0w:~.2.0w.~.6.0w",[HH, MM, SS, Usec]);
ts(_) ->
    "-".

cbuf_start() ->
    cbuf_start(20).

cbuf_start(CbufMaxLen) ->
    put(circ_buf,{CbufMaxLen,queue:new()}),
    ok.

cbuf_stop_clear() ->
    case erase(circ_buf) of
        undefined->
            [];
        {_CbufMaxLen,Queue}->
            queue:to_list(Queue)
    end.

cbuf_in(Value) ->
    case get(circ_buf) of
        undefined->
            disabled;
        {CbufMaxLen,Queue}->
            UpdatedQueue = try queue:head(Queue) of 
                {Value,TS0,Cnt0}->
                    queue:in_r({Value,TS0,Cnt0 + 1},queue:drop(Queue));
                _->
                    queue:in_r({Value,erlang:timestamp(),1},truncate_cbuf(Queue,CbufMaxLen))
                catch
                    error:empty->
                        queue:in_r({Value,erlang:timestamp(),1},Queue) end,
            put(circ_buf,{CbufMaxLen,UpdatedQueue}),
            ok
    end.

cbuf_list() ->
    case get(circ_buf) of
        undefined->
            [];
        {_CbufMaxLen,Queue}->
            queue:to_list(Queue)
    end.

truncate_cbuf(Q,CbufMaxLen) ->
    case queue:len(Q) of
        N
            when N >= CbufMaxLen->
            truncate_cbuf(element(2,queue:out_r(Q)),CbufMaxLen);
        _->
            Q
    end.

fmt_cbuf_items() ->
    lists:flatten(io_lib:format("Circular trace buffer. Latest item fir" "st.~n~s~n",[case get(circ_buf) of
        {Max,_}->
            L = cbuf_list(),
            [(io_lib:format("==== ~.*w: ~s" "~n",[num_digits(Max), N, fmt_cbuf_item(X)])) || {N,X} <- lists:zip(lists:seq(1,length(L)),L)];
        _->
            io_lib:format("Not started.~n",[])
    end])).

num_digits(0) ->
    1;
num_digits(N)
    when N > 0->
    1 + trunc(math:log10(N)).

fmt_cbuf_item({Value,TimeStamp,N}) ->
    io_lib:format("~s~s~n~s~n",[fmt_ts(TimeStamp), [(io_lib:format(" (Repeated ~p times)",[N])) || N > 1], fmt_value(Value)]).

fmt_ts(TS = {_,_,Us}) ->
    {{YY,MM,DD},{H,M,S}} = calendar:now_to_universal_time(TS),
    io_lib:format("~w-~.2.0w-~.2.0w ~.2.0w:~.2.0w:~.2.0w.~.6.0w UTC",[YY, MM, DD, H, M, S, Us]).

fmt_value(#circ_buf_entry{module = M,line = L,function = {F,A},pid = Pid,value = V}) ->
    io_lib:format("~p:~p  ~p/~p ~p~n~s",[M, L, F, A, Pid, fmt_value(V)]);
fmt_value(Value) ->
    io_lib:format("~p",[Value]).

-record(h, {max_bytes = 65536,bytes_per_line = 16,address_len = 4}).

hex_dump(Data) ->
    hex_dump1(Data,hd_opts([])).

hex_dump(X,Max)
    when is_integer(Max)->
    hex_dump(X,[{max_bytes,Max}]);
hex_dump(X,OptList)
    when is_list(OptList)->
    hex_dump1(X,hd_opts(OptList)).

hex_dump1(B,Opts)
    when is_binary(B)->
    hex_dump1(binary_to_list(B),Opts);
hex_dump1(L,Opts)
    when is_list(L),
    length(L) > Opts#h.max_bytes->
    io_lib:format("~s---- skip ~w bytes----~n",[hex_dump1(lists:sublist(L,Opts#h.max_bytes),Opts), length(L) - Opts#h.max_bytes]);
hex_dump1(L,Opts0)
    when is_list(L)->
    Opts = Opts0#h{address_len = num_hex_digits(Opts0#h.max_bytes)},
    Result = hex_dump(L,[{0,[],[]}],Opts),
    [io_lib:format("~*.s | ~*s | ~s~n~*.c-+-~*c-+-~*c~n",[Opts#h.address_len, lists:sublist("Address",Opts#h.address_len), -3 * Opts#h.bytes_per_line, lists:sublist("Hexdump",3 * Opts#h.bytes_per_line), "ASCII", Opts#h.address_len, $-, 3 * Opts#h.bytes_per_line, $-, Opts#h.bytes_per_line, $-])| [(io_lib:format("~*.16.0b | ~s~*c | ~s~n",[Opts#h.address_len, N * Opts#h.bytes_per_line, lists:reverse(Hexs), 3 * (Opts#h.bytes_per_line - length(Hexs)), $ , lists:reverse(Chars)])) || {N,Hexs,Chars} <- lists:reverse(Result)]].

hd_opts(L) ->
    lists:foldl(fun hd_opt/2,#h{},L).

hd_opt({max_bytes,M},O) ->
    O#h{max_bytes = M};
hd_opt({bytes_per_line,M},O) ->
    O#h{bytes_per_line = M}.

num_hex_digits(N)
    when N < 16->
    1;
num_hex_digits(N) ->
    trunc(math:ceil(math:log2(N)/4)).

hex_dump([L| Cs],Result0,Opts)
    when is_list(L)->
    Result = hex_dump(L,Result0,Opts),
    hex_dump(Cs,Result,Opts);
hex_dump(Cs,[{N0,_,Chars}| _] = Lines,Opts)
    when length(Chars) == Opts#h.bytes_per_line->
    hex_dump(Cs,[{N0 + 1,[],[]}| Lines],Opts);
hex_dump([C| Cs],[{N,Hexs,Chars}| Lines],Opts) ->
    Asc = if 32 =< C,
    C =< 126 ->
        C;true ->
        $. end,
    Hex = io_lib:format("~2.16.0b ",[C]),
    hex_dump(Cs,[{N,[Hex| Hexs],[Asc| Chars]}| Lines],Opts);
hex_dump([],Result,_) ->
    Result.
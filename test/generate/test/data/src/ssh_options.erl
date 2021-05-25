-file("ssh_options.erl", 1).

-module(ssh_options).

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

-file("ssh_options.erl", 26).

-file("/usr/lib/erlang/lib/kernel-7.2/include/file.hrl", 1).

-record(file_info,{size::non_neg_integer()|undefined,type::device|directory|other|regular|symlink|undefined,access::read|write|read_write|none|undefined,atime::file:date_time()|non_neg_integer()|undefined,mtime::file:date_time()|non_neg_integer()|undefined,ctime::file:date_time()|non_neg_integer()|undefined,mode::non_neg_integer()|undefined,links::non_neg_integer()|undefined,major_device::non_neg_integer()|undefined,minor_device::non_neg_integer()|undefined,inode::non_neg_integer()|undefined,uid::non_neg_integer()|undefined,gid::non_neg_integer()|undefined}).

-record(file_descriptor,{module::module(),data::term()}).

-file("ssh_options.erl", 27).

-export([default/1, get_value/5, get_value/6, put_value/5, delete_key/5, handle_options/2, keep_user_options/2, keep_set_options/2, initial_default_algorithms/2, check_preferred_algorithms/1]).

-export_type([private_options/0]).

-type(option_in()::proplists:property()|proplists:proplist()).

-type(option_class()::internal_options|socket_options|user_options).

-type(option_declaration()::#{class := user_option|undoc_user_option,chk := fun((any()) -> boolean()|{true,any()}),default => any()}).

-type(option_key()::atom()).

-type(option_declarations()::#{option_key() := option_declaration()}).

-type(error()::{error,{eoptions,any()}}).

-type(private_options()::#{socket_options := socket_options(),internal_options := internal_options(),option_key() => any()}).

-spec(get_value(option_class(),option_key(),private_options(),atom(),non_neg_integer()) -> any()|no_return()).

get_value(Class,Key,Opts,_CallerMod,_CallerLine)
    when is_map(Opts)->
    case Class of
        internal_options->
            maps:get(Key,maps:get(internal_options,Opts));
        socket_options->
            proplists:get_value(Key,maps:get(socket_options,Opts));
        user_options->
            maps:get(Key,Opts)
    end;
get_value(Class,Key,Opts,_CallerMod,_CallerLine) ->
    error({bad_options,Class,Key,Opts,_CallerMod,_CallerLine}).

-spec(get_value(option_class(),option_key(),private_options(),fun(() -> any()),atom(),non_neg_integer()) -> any()|no_return()).

get_value(socket_options,Key,Opts,DefFun,_CallerMod,_CallerLine)
    when is_map(Opts)->
    proplists:get_value(Key,maps:get(socket_options,Opts),DefFun);
get_value(Class,Key,Opts,DefFun,CallerMod,CallerLine)
    when is_map(Opts)->
    try get_value(Class,Key,Opts,CallerMod,CallerLine) of 
        undefined->
            DefFun();
        Value->
            Value
        catch
            error:{badkey,Key}->
                DefFun() end;
get_value(Class,Key,Opts,_DefFun,_CallerMod,_CallerLine) ->
    error({bad_options,Class,Key,Opts,_CallerMod,_CallerLine}).

-spec(put_value(option_class(),option_in(),private_options(),atom(),non_neg_integer()) -> private_options()).

put_value(user_options,KeyVal,Opts,_CallerMod,_CallerLine)
    when is_map(Opts)->
    put_user_value(KeyVal,Opts);
put_value(internal_options,KeyVal,Opts,_CallerMod,_CallerLine)
    when is_map(Opts)->
    InternalOpts = maps:get(internal_options,Opts),
    Opts#{internal_options:=put_internal_value(KeyVal,InternalOpts)};
put_value(socket_options,KeyVal,Opts,_CallerMod,_CallerLine)
    when is_map(Opts)->
    SocketOpts = maps:get(socket_options,Opts),
    Opts#{socket_options:=put_socket_value(KeyVal,SocketOpts)}.

put_user_value(L,Opts)
    when is_list(L)->
    lists:foldl(fun put_user_value/2,Opts,L);
put_user_value({Key,Value},Opts) ->
    Opts#{Key:=Value}.

put_internal_value(L,IntOpts)
    when is_list(L)->
    lists:foldl(fun put_internal_value/2,IntOpts,L);
put_internal_value({Key,Value},IntOpts) ->
    IntOpts#{Key=>Value}.

put_socket_value(L,SockOpts)
    when is_list(L)->
    L ++ SockOpts;
put_socket_value({Key,Value},SockOpts) ->
    [{Key,Value}| SockOpts];
put_socket_value(A,SockOpts)
    when is_atom(A)->
    [A| SockOpts].

-spec(delete_key(option_class(),option_key(),private_options(),atom(),non_neg_integer()) -> private_options()).

delete_key(internal_options,Key,Opts,_CallerMod,_CallerLine)
    when is_map(Opts)->
    InternalOpts = maps:get(internal_options,Opts),
    Opts#{internal_options:=maps:remove(Key,InternalOpts)}.

-spec(handle_options(role(),client_options()|daemon_options()) -> private_options()|error()).

handle_options(Role,PropList0) ->
    handle_options(Role,PropList0,#{socket_options=>[],internal_options=>#{},key_cb_options=>[]}).

handle_options(Role,OptsList0,Opts0)
    when is_map(Opts0),
    is_list(OptsList0)->
    OptsList1 = proplists:unfold(lists:foldr(fun (T,Acc)
        when is_tuple(T),
        size(T) =/= 2->
        [{special_trpt_args,T}| Acc];(X,Acc)->
        [X| Acc] end,[],OptsList0)),
    try OptionDefinitions = default(Role),
    RoleCnfs = application:get_env(ssh,cnf_key(Role),[]),
    {InitialMap,OptsList2} = maps:fold(fun (K,#{default:=Vd},{M,PL})->
        case config_val(K,RoleCnfs,OptsList1) of
            {ok,V1}->
                {M#{K=>V1,key_cb_options=>[{K,V1}| maps:get(key_cb_options,M)]},[{K,V1}| PL]};
            {append,V1}->
                NewVal = maps:get(K,M,[]) ++ V1,
                {M#{K=>NewVal,key_cb_options=>[{K,NewVal}| lists:keydelete(K,1,maps:get(key_cb_options,M))]},[{K,NewVal}| lists:keydelete(K,1,PL)]};
            undefined->
                {M#{K=>Vd},PL}
        end end,{Opts0#{key_cb_options=>maps:get(key_cb_options,Opts0)},[{K,V} || {K,V} <- OptsList1, not maps:is_key(K,Opts0)]},OptionDefinitions),
    final_preferred_algorithms(lists:foldl(fun (KV,Vals)->
        save(KV,OptionDefinitions,Vals) end,InitialMap,OptsList2))
        catch
            error:{EO,KV,Reason}
                when EO == eoptions;
                EO == eerl_env->
                if Reason == undefined ->
                    {error,{EO,KV}};is_list(Reason) ->
                    {error,{EO,{KV,lists:flatten(Reason)}}};true ->
                    {error,{EO,{KV,Reason}}} end end.

cnf_key(server) ->
    server_options;
cnf_key(client) ->
    client_options.

config_val(modify_algorithms = Key,RoleCnfs,Opts) ->
    V = case application:get_env(ssh,Key) of
        {ok,V0}->
            V0;
        _->
            []
    end ++ proplists:get_value(Key,RoleCnfs,[]) ++ proplists:get_value(Key,Opts,[]),
    case V of
        []->
            undefined;
        _->
            {append,V}
    end;
config_val(Key,RoleCnfs,Opts) ->
    case lists:keysearch(Key,1,Opts) of
        {value,{_,V}}->
            {ok,V};
        false->
            case lists:keysearch(Key,1,RoleCnfs) of
                {value,{_,V}}->
                    {ok,V};
                false->
                    application:get_env(ssh,Key)
            end
    end.

check_fun(Key,Defs) ->
    case ssh_connection_handler:prohibited_sock_option(Key) of
        false->
            #{chk:=Fun} = maps:get(Key,Defs),
            Fun;
        true->
            fun (_,_)->
                forbidden end
    end.

save({allow_user_interaction,V},Opts,Vals) ->
    save({user_interaction,V},Opts,Vals);
save(Inet,Defs,OptMap)
    when Inet == inet;
    Inet == inet6->
    save({inet,Inet},Defs,OptMap);
save({Inet,true},Defs,OptMap)
    when Inet == inet;
    Inet == inet6->
    save({inet,Inet},Defs,OptMap);
save({Inet,false},_Defs,OptMap)
    when Inet == inet;
    Inet == inet6->
    OptMap;
save({special_trpt_args,T},_Defs,OptMap)
    when is_map(OptMap)->
    OptMap#{socket_options:=[T| maps:get(socket_options,OptMap)]};
save({Key,Value},Defs,OptMap)
    when is_map(OptMap)->
    try (check_fun(Key,Defs))(Value) of 
        true->
            OptMap#{Key:=Value};
        {true,ModifiedValue}->
            OptMap#{Key:=ModifiedValue};
        false->
            error({eoptions,{Key,Value},"Bad value"});
        forbidden->
            error({eoptions,{Key,Value},io_lib:format("The option '~s' is used internally. T" "he user is not allowed to specify thi" "s option.",[Key])})
        catch
            error:{badkey,inet}->
                OptMap#{socket_options:=[Value| maps:get(socket_options,OptMap)]};
            error:{badkey,Key}->
                OptMap#{socket_options:=[{Key,Value}| maps:get(socket_options,OptMap)]};
            error:{check,{BadValue,Extra}}->
                error({eoptions,{Key,BadValue},Extra}) end;
save(Opt,_Defs,OptMap)
    when is_map(OptMap)->
    OptMap#{socket_options:=[Opt| maps:get(socket_options,OptMap)]}.

-spec(keep_user_options(client|server,#{}) -> #{}).

keep_user_options(Type,Opts) ->
    Defs = default(Type),
    maps:filter(fun (Key,_Value)->
        try #{class:=Class} = maps:get(Key,Defs),
        Class == user_option
            catch
                _:_->
                    false end end,Opts).

-spec(keep_set_options(client|server,#{}) -> #{}).

keep_set_options(Type,Opts) ->
    Defs = default(Type),
    maps:filter(fun (Key,Value)->
        try #{default:=DefVal} = maps:get(Key,Defs),
        DefVal =/= Value
            catch
                _:_->
                    false end end,Opts).

-spec(default(role()|common) -> option_declarations()).

default(server) ->
    (default(common))#{subsystems=>#{default=>[ssh_sftpd:subsystem_spec([])],chk=>fun (L)->
        is_list(L) andalso lists:all(fun ({Name,{CB,Args}})->
            check_string(Name) andalso is_atom(CB) andalso is_list(Args);(_)->
            false end,L) end,class=>user_option},shell=>#{default=>{shell,start,[]},chk=>fun ({M,F,A})->
        is_atom(M) andalso is_atom(F) andalso is_list(A);(disabled)->
        true;(V)->
        check_function1(V) orelse check_function2(V) end,class=>user_option},exec=>#{default=>undefined,chk=>fun ({direct,V})->
        check_function1(V) orelse check_function2(V) orelse check_function3(V);(disabled)->
        true;({M,F,A})->
        is_atom(M) andalso is_atom(F) andalso is_list(A);(V)->
        check_function1(V) orelse check_function2(V) orelse check_function3(V) end,class=>user_option},ssh_cli=>#{default=>undefined,chk=>fun ({Cb,As})->
        is_atom(Cb) andalso is_list(As);(V)->
        V == no_cli end,class=>user_option},tcpip_tunnel_out=>#{default=>false,chk=>fun (V)->
        is_boolean(V) end,class=>user_option},tcpip_tunnel_in=>#{default=>false,chk=>fun (V)->
        is_boolean(V) end,class=>user_option},system_dir=>#{default=>"/etc/ssh",chk=>fun (V)->
        check_string(V) andalso check_dir(V) end,class=>user_option},auth_method_kb_interactive_data=>#{default=>undefined,chk=>fun ({S1,S2,S3,B})->
        check_string(S1) andalso check_string(S2) andalso check_string(S3) andalso is_boolean(B);(F)->
        check_function3(F) orelse check_function4(F) end,class=>user_option},user_passwords=>#{default=>[],chk=>fun (V)->
        is_list(V) andalso lists:all(fun ({S1,S2})->
            check_string(S1) andalso check_string(S2) end,V) end,class=>user_option},pk_check_user=>#{default=>false,chk=>fun (V)->
        is_boolean(V) end,class=>user_option},password=>#{default=>undefined,chk=>fun (V)->
        check_string(V) end,class=>user_option},dh_gex_groups=>#{default=>undefined,chk=>fun (V)->
        check_dh_gex_groups(V) end,class=>user_option},dh_gex_limits=>#{default=>{0,infinity},chk=>fun ({I1,I2})->
        check_pos_integer(I1) andalso check_pos_integer(I2) andalso I1 < I2;(_)->
        false end,class=>user_option},pwdfun=>#{default=>undefined,chk=>fun (V)->
        check_function4(V) orelse check_function2(V) end,class=>user_option},negotiation_timeout=>#{default=>2 * 60 * 1000,chk=>fun (V)->
        check_timeout(V) end,class=>user_option},hello_timeout=>#{default=>30 * 1000,chk=>fun check_timeout/1,class=>user_option},max_sessions=>#{default=>infinity,chk=>fun (V)->
        check_pos_integer(V) end,class=>user_option},max_channels=>#{default=>infinity,chk=>fun (V)->
        check_pos_integer(V) end,class=>user_option},parallel_login=>#{default=>false,chk=>fun (V)->
        is_boolean(V) end,class=>user_option},minimal_remote_max_packet_size=>#{default=>0,chk=>fun (V)->
        check_pos_integer(V) end,class=>user_option},failfun=>#{default=>fun (_,_,_)->
        void end,chk=>fun (V)->
        check_function3(V) orelse check_function2(V) end,class=>user_option},connectfun=>#{default=>fun (_,_,_)->
        void end,chk=>fun (V)->
        check_function3(V) end,class=>user_option},infofun=>#{default=>fun (_,_,_)->
        void end,chk=>fun (V)->
        check_function3(V) orelse check_function2(V) end,class=>undoc_user_option}};
default(client) ->
    (default(common))#{dsa_pass_phrase=>#{default=>undefined,chk=>fun (V)->
        check_string(V) end,class=>user_option},rsa_pass_phrase=>#{default=>undefined,chk=>fun (V)->
        check_string(V) end,class=>user_option},ecdsa_pass_phrase=>#{default=>undefined,chk=>fun (V)->
        check_string(V) end,class=>user_option},silently_accept_hosts=>#{default=>false,chk=>fun (V)->
        check_silently_accept_hosts(V) end,class=>user_option},user_interaction=>#{default=>true,chk=>fun (V)->
        is_boolean(V) end,class=>user_option},save_accepted_host=>#{default=>true,chk=>fun (V)->
        is_boolean(V) end,class=>user_option},dh_gex_limits=>#{default=>{1024,6144,8192},chk=>fun ({Min,I,Max})->
        lists:all(fun check_pos_integer/1,[Min, I, Max]);(_)->
        false end,class=>user_option},connect_timeout=>#{default=>infinity,chk=>fun (V)->
        check_timeout(V) end,class=>user_option},user=>#{default=>begin Env = case os:type() of
        {win32,_}->
            "USERNAME";
        {unix,_}->
            "LOGNAME"
    end,
    case os:getenv(Env) of
        false->
            case os:getenv("USER") of
                false->
                    undefined;
                User->
                    User
            end;
        User->
            User
    end end,chk=>fun (V)->
        check_string(V) end,class=>user_option},password=>#{default=>undefined,chk=>fun (V)->
        check_string(V) end,class=>user_option},quiet_mode=>#{default=>false,chk=>fun (V)->
        is_boolean(V) end,class=>user_option},keyboard_interact_fun=>#{default=>undefined,chk=>fun (V)->
        check_function3(V) end,class=>undoc_user_option}};
default(common) ->
    #{user_dir=>#{default=>false,chk=>fun (V)->
        check_string(V) andalso check_dir(V) end,class=>user_option},pref_public_key_algs=>#{default=>undefined,chk=>fun (V)->
        check_pref_public_key_algs(V) end,class=>user_option},preferred_algorithms=>#{default=>ssh:default_algorithms(),chk=>fun (V)->
        check_preferred_algorithms(V) end,class=>user_option},modify_algorithms=>#{default=>undefined,chk=>fun (V)->
        check_modify_algorithms(V) end,class=>user_option},id_string=>#{default=>try {ok,[_| _] = VSN} = application:get_key(ssh,vsn),
    "Erlang/" ++ VSN
        catch
            _:_->
                "" end,chk=>fun (random)->
        {true,{random,2,5}};({random,I1,I2})->
        check_pos_integer(I1) andalso check_pos_integer(I2) andalso I1 =< I2;(V)->
        check_string(V) end,class=>user_option},key_cb=>#{default=>{ssh_file,[]},chk=>fun ({Mod,Opts})->
        is_atom(Mod) andalso is_list(Opts);(Mod)
        when is_atom(Mod)->
        {true,{Mod,[]}};(_)->
        false end,class=>user_option},profile=>#{default=>default,chk=>fun (V)->
        is_atom(V) end,class=>user_option},idle_time=>#{default=>infinity,chk=>fun (V)->
        check_timeout(V) end,class=>user_option},disconnectfun=>#{default=>fun (_)->
        void end,chk=>fun (V)->
        check_function1(V) end,class=>user_option},unexpectedfun=>#{default=>fun (_,_)->
        report end,chk=>fun (V)->
        check_function2(V) end,class=>user_option},ssh_msg_debug_fun=>#{default=>fun (_,_,_,_)->
        void end,chk=>fun (V)->
        check_function4(V) end,class=>user_option},rekey_limit=>#{default=>{3600000,1024000000},chk=>fun ({infinity,infinity})->
        true;({Mins,infinity})
        when is_integer(Mins),
        Mins > 0->
        {true,{Mins * 60 * 1000,infinity}};({infinity,Bytes})
        when is_integer(Bytes),
        Bytes >= 0->
        true;({Mins,Bytes})
        when is_integer(Mins),
        Mins > 0,
        is_integer(Bytes),
        Bytes >= 0->
        {true,{Mins * 60 * 1000,Bytes}};(infinity)->
        {true,{3600000,infinity}};(Bytes)
        when is_integer(Bytes),
        Bytes >= 0->
        {true,{3600000,Bytes}};(_)->
        false end,class=>user_option},auth_methods=>#{default=>"publickey,keyboard-interactive,password",chk=>fun (As)->
        try Sup = string:tokens("publickey,keyboard-intera" "ctive,password",","),
        New = string:tokens(As,","),
        [] == [X || X <- New, not lists:member(X,Sup)]
            catch
                _:_->
                    false end end,class=>user_option},send_ext_info=>#{default=>true,chk=>fun erlang:is_boolean/1,class=>user_option},recv_ext_info=>#{default=>true,chk=>fun erlang:is_boolean/1,class=>user_option},transport=>#{default=>{tcp,gen_tcp,tcp_closed},chk=>fun ({A,B,C})->
        is_atom(A) andalso is_atom(B) andalso is_atom(C) end,class=>undoc_user_option},vsn=>#{default=>{2,0},chk=>fun ({Maj,Min})->
        check_non_neg_integer(Maj) andalso check_non_neg_integer(Min);(_)->
        false end,class=>undoc_user_option},tstflg=>#{default=>[],chk=>fun (V)->
        is_list(V) end,class=>undoc_user_option},user_dir_fun=>#{default=>undefined,chk=>fun (V)->
        check_function1(V) end,class=>undoc_user_option},max_random_length_padding=>#{default=>15,chk=>fun (V)->
        check_non_neg_integer(V) end,class=>undoc_user_option}}.

error_in_check(BadValue,Extra) ->
    error({check,{BadValue,Extra}}).

check_timeout(infinity) ->
    true;
check_timeout(I) ->
    check_pos_integer(I).

check_pos_integer(I) ->
    is_integer(I) andalso I > 0.

check_non_neg_integer(I) ->
    is_integer(I) andalso I >= 0.

check_function1(F) ->
    is_function(F,1).

check_function2(F) ->
    is_function(F,2).

check_function3(F) ->
    is_function(F,3).

check_function4(F) ->
    is_function(F,4).

check_pref_public_key_algs(V) ->
    PKs = ssh_transport:supported_algorithms(public_key),
    CHK = fun (A,Ack)->
        case lists:member(A,PKs) of
            true->
                case lists:member(A,Ack) of
                    false->
                        [A| Ack];
                    true->
                        Ack
                end;
            false->
                error_in_check(A,"Not supported public key")
        end end,
    case lists:foldr(fun (ssh_dsa,Ack)->
        CHK(ssh-dss,Ack);(ssh_rsa,Ack)->
        CHK(ssh-rsa,Ack);(X,Ack)->
        CHK(X,Ack) end,[],V) of
        V->
            true;
        []->
            false;
        V1->
            {true,V1}
    end.

check_dir(Dir) ->
    case file:read_file_info(Dir) of
        {ok,#file_info{type = directory,access = Access}}->
            case Access of
                read->
                    true;
                read_write->
                    true;
                _->
                    error_in_check(Dir,eacces)
            end;
        {ok,#file_info{}}->
            error_in_check(Dir,enotdir);
        {error,Error}->
            error_in_check(Dir,Error)
    end.

check_string(S) ->
    is_list(S).

check_dh_gex_groups({file,File})
    when is_list(File)->
    case file:consult(File) of
        {ok,GroupDefs}->
            check_dh_gex_groups(GroupDefs);
        {error,Error}->
            error_in_check({file,File},Error)
    end;
check_dh_gex_groups({ssh_moduli_file,File})
    when is_list(File)->
    case file:open(File,[read]) of
        {ok,D}->
            try read_moduli_file(D,1,[]) of 
                {ok,Moduli}->
                    check_dh_gex_groups(Moduli);
                {error,Error}->
                    error_in_check({ssh_moduli_file,File},Error)
                catch
                    _:_->
                        error_in_check({ssh_moduli_file,File},"Bad format in file " ++ File) after file:close(D) end;
        {error,Error}->
            error_in_check({ssh_moduli_file,File},Error)
    end;
check_dh_gex_groups(L0)
    when is_list(L0),
    is_tuple(hd(L0))->
    {true,collect_per_size(lists:foldl(fun ({N,G,P},Acc)
        when is_integer(N),
        N > 0,
        is_integer(G),
        G > 0,
        is_integer(P),
        P > 0->
        [{N,{G,P}}| Acc];({N,{G,P}},Acc)
        when is_integer(N),
        N > 0,
        is_integer(G),
        G > 0,
        is_integer(P),
        P > 0->
        [{N,{G,P}}| Acc];({N,GPs},Acc)
        when is_list(GPs)->
        lists:foldr(fun ({Gi,Pi},Acci)
            when is_integer(Gi),
            Gi > 0,
            is_integer(Pi),
            Pi > 0->
            [{N,{Gi,Pi}}| Acci] end,Acc,GPs) end,[],L0))};
check_dh_gex_groups(_) ->
    false.

collect_per_size(L) ->
    lists:foldr(fun ({Sz,GP},[{Sz,GPs}| Acc])->
        [{Sz,[GP| GPs]}| Acc];({Sz,GP},Acc)->
        [{Sz,[GP]}| Acc] end,[],lists:sort(L)).

read_moduli_file(D,I,Acc) ->
    case io:get_line(D,"") of
        {error,Error}->
            {error,Error};
        eof->
            {ok,Acc};
        "#" ++ _->
            read_moduli_file(D,I + 1,Acc);
        <<"#",_/binary>>->
            read_moduli_file(D,I + 1,Acc);
        Data->
            Line = if is_binary(Data) ->
                binary_to_list(Data);is_list(Data) ->
                Data end,
            try [_Time, _Class, _Tests, _Tries, Size, G, P] = string:tokens(Line," \r\n"),
            M = {list_to_integer(Size),{list_to_integer(G),list_to_integer(P,16)}},
            read_moduli_file(D,I + 1,[M| Acc])
                catch
                    _:_->
                        read_moduli_file(D,I + 1,Acc) end
    end.

check_silently_accept_hosts(B)
    when is_boolean(B)->
    true;
check_silently_accept_hosts(F)
    when is_function(F,2)->
    true;
check_silently_accept_hosts({false,S})
    when is_atom(S)->
    valid_hash(S);
check_silently_accept_hosts({S,F})
    when is_function(F,2)->
    valid_hash(S);
check_silently_accept_hosts(_) ->
    false.

valid_hash(S) ->
    valid_hash(S,proplists:get_value(hashs,crypto:supports())).

valid_hash(S,Ss)
    when is_atom(S)->
    lists:member(S,[md5, sha, sha224, sha256, sha384, sha512]) andalso lists:member(S,Ss);
valid_hash(L,Ss)
    when is_list(L)->
    lists:all(fun (S)->
        valid_hash(S,Ss) end,L);
valid_hash(X,_) ->
    error_in_check(X,"Expect atom or list in fingerprint spec").

initial_default_algorithms(DefList,ModList) ->
    {true,L0} = check_modify_algorithms(ModList),
    rm_non_supported(false,eval_ops(DefList,L0)).

check_modify_algorithms(M)
    when is_list(M)->
    [(error_in_check(Op_KVs,"Bad modify_algorithms")) || Op_KVs <- M, not is_tuple(Op_KVs) orelse size(Op_KVs) =/= 2 orelse  not lists:member(element(1,Op_KVs),[append, prepend, rm])],
    {true,[{Op,normalize_mod_algs(KVs,false)} || {Op,KVs} <- M]};
check_modify_algorithms(_) ->
    error_in_check(modify_algorithms,"Bad option value. List expected.").

normalize_mod_algs(KVs,UseDefaultAlgs) ->
    normalize_mod_algs(ssh_transport:algo_classes(),KVs,[],UseDefaultAlgs).

normalize_mod_algs([K| Ks],KVs0,Acc,UseDefaultAlgs) ->
    {Vs1,KVs} = case lists:keytake(K,1,KVs0) of
        {value,{K,Vs0},KVs1}->
            {Vs0,KVs1};
        false->
            {[],KVs0}
    end,
    Vs = normalize_mod_alg_list(K,Vs1,UseDefaultAlgs),
    normalize_mod_algs(Ks,KVs,[{K,Vs}| Acc],UseDefaultAlgs);
normalize_mod_algs([],[],Acc,_) ->
    lists:reverse(Acc);
normalize_mod_algs([],[{K,_}| _],_,_) ->
    case ssh_transport:algo_class(K) of
        true->
            error_in_check(K,"Duplicate key");
        false->
            error_in_check(K,"Unknown key")
    end;
normalize_mod_algs([],[X| _],_,_) ->
    error_in_check(X,"Bad list element").

normalize_mod_alg_list(K,Vs,UseDefaultAlgs) ->
    normalize_mod_alg_list(K,ssh_transport:algo_two_spec_class(K),Vs,def_alg(K,UseDefaultAlgs)).

normalize_mod_alg_list(_K,_,[],Default) ->
    Default;
normalize_mod_alg_list(K,true,[{client2server,L1}],[_, {server2client,L2}]) ->
    [nml1(K,{client2server,L1}), {server2client,L2}];
normalize_mod_alg_list(K,true,[{server2client,L2}],[{client2server,L1}, _]) ->
    [{client2server,L1}, nml1(K,{server2client,L2})];
normalize_mod_alg_list(K,true,[{server2client,L2}, {client2server,L1}],_) ->
    [nml1(K,{client2server,L1}), nml1(K,{server2client,L2})];
normalize_mod_alg_list(K,true,[{client2server,L1}, {server2client,L2}],_) ->
    [nml1(K,{client2server,L1}), nml1(K,{server2client,L2})];
normalize_mod_alg_list(K,true,L0,_) ->
    L = nml(K,L0),
    [{client2server,L}, {server2client,L}];
normalize_mod_alg_list(K,false,L,_) ->
    nml(K,L).

nml1(K,{T,V})
    when T == client2server;
    T == server2client->
    {T,nml({K,T},V)}.

nml(K,L) ->
    [(error_in_check(K,"Bad value for this key")) || V <- L, not is_atom(V)],
    case L -- lists:usort(L) of
        []->
            ok;
        Dups->
            error_in_check({K,Dups},"Duplicates")
    end,
    L.

def_alg(K,false) ->
    case ssh_transport:algo_two_spec_class(K) of
        false->
            [];
        true->
            [{client2server,[]}, {server2client,[]}]
    end;
def_alg(K,true) ->
    ssh_transport:default_algorithms(K).

check_preferred_algorithms(Algs)
    when is_list(Algs)->
    check_input_ok(Algs),
    {true,normalize_mod_algs(Algs,true)};
check_preferred_algorithms(_) ->
    error_in_check(modify_algorithms,"Bad option value. List expected.").

check_input_ok(Algs) ->
    [(error_in_check(KVs,"Bad preferred_algorithms")) || KVs <- Algs, not is_tuple(KVs) orelse size(KVs) =/= 2].

final_preferred_algorithms(Options0) ->
    Result = case ssh_options:get_value(user_options,modify_algorithms,Options0,ssh_options,1143) of
        undefined->
            rm_non_supported(true,ssh_options:get_value(user_options,preferred_algorithms,Options0,ssh_options,1146));
        ModAlgs->
            rm_non_supported(false,eval_ops(ssh_options:get_value(user_options,preferred_algorithms,Options0,ssh_options,1149),ModAlgs))
    end,
    error_if_empty(Result),
    Options1 = ssh_options:put_value(user_options,{preferred_algorithms,Result},Options0,ssh_options,1153),
    case ssh_options:get_value(user_options,pref_public_key_algs,Options1,ssh_options,1154) of
        undefined->
            ssh_options:put_value(user_options,{pref_public_key_algs,proplists:get_value(public_key,Result)},Options1,ssh_options,1156);
        _->
            Options1
    end.

eval_ops(PrefAlgs,ModAlgs) ->
    lists:foldl(fun eval_op/2,PrefAlgs,ModAlgs).

eval_op({Op,AlgKVs},PrefAlgs) ->
    eval_op(Op,AlgKVs,PrefAlgs,[]).

eval_op(Op,[{C,L1}| T1],[{C,L2}| T2],Acc) ->
    eval_op(Op,T1,T2,[{C,eval_op(Op,L1,L2,[])}| Acc]);
eval_op(_,[],[],Acc) ->
    lists:reverse(Acc);
eval_op(rm,Opt,Pref,[])
    when is_list(Opt),
    is_list(Pref)->
    Pref -- Opt;
eval_op(append,Opt,Pref,[])
    when is_list(Opt),
    is_list(Pref)->
    (Pref -- Opt) ++ Opt;
eval_op(prepend,Opt,Pref,[])
    when is_list(Opt),
    is_list(Pref)->
    Opt ++ Pref -- Opt.

rm_non_supported(UnsupIsErrorFlg,KVs) ->
    [{K,rmns(K,Vs,UnsupIsErrorFlg)} || {K,Vs} <- KVs].

rmns(K,Vs,UnsupIsErrorFlg) ->
    case ssh_transport:algo_two_spec_class(K) of
        false->
            rm_unsup(Vs,ssh_transport:supported_algorithms(K),UnsupIsErrorFlg,K);
        true->
            [{C,rm_unsup(Vsx,Sup,UnsupIsErrorFlg,{K,C})} || {{C,Vsx},{C,Sup}} <- lists:zip(Vs,ssh_transport:supported_algorithms(K))]
    end.

rm_unsup(A,B,Flg,ErrInf) ->
    case A -- B of
        Unsup = [_| _]
            when Flg == true->
            error({eoptions,{preferred_algorithms,{ErrInf,Unsup}},"Unsupported value(s) found"});
        Unsup->
            A -- Unsup
    end.

error_if_empty([{K,[]}| _]) ->
    error({eoptions,K,"Empty resulting algorithm list"});
error_if_empty([{K,[{client2server,[]}, {server2client,[]}]}]) ->
    error({eoptions,K,"Empty resulting algorithm list"});
error_if_empty([{K,[{client2server,[]}| _]}| _]) ->
    error({eoptions,{K,client2server},"Empty resulting algorithm list"});
error_if_empty([{K,[_, {server2client,[]}| _]}| _]) ->
    error({eoptions,{K,server2client},"Empty resulting algorithm list"});
error_if_empty([_| T]) ->
    error_if_empty(T);
error_if_empty([]) ->
    ok.
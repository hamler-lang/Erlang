-file("ssh_agent.erl", 1).

-module(ssh_agent).

-behaviour(ssh_client_key_api).

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

-file("ssh_agent.erl", 28).

-file("ssh_agent.hrl", 1).

-record(ssh_agent_success, {}).

-record(ssh_agent_failure, {}).

-record(ssh_agent_identities_request, {}).

-record(ssh_agent_key, {blob,comment}).

-record(ssh_agent_identities_response, {keys}).

-record(ssh_agent_sign_request, {key_blob,data,flags}).

-record(ssh_agent_signature, {format,blob}).

-record(ssh_agent_sign_response, {signature}).

-file("ssh_agent.erl", 29).

-export([send/2]).

-export([add_host_key/3, add_host_key/4, is_host_key/4, is_host_key/5, user_key/2, sign/3]).

-type(socket_path_option()::{socket_path,string()}).

-type(timeout_option()::{timeout,integer()}).

-type(call_ssh_file_option()::{call_ssh_file,atom()}).

-spec(add_host_key(string(),public_key:public_key(),Options) -> ok|{error,Error::term()} when Options::ssh_client_key_api:client_key_cb_options(call_ssh_file_option())).

add_host_key(Host,PublicKey,Options) ->
    KeyCbOpts = proplists:get_value(key_cb_private,Options,[]),
    SshFileCb = proplists:get_value(call_ssh_file,KeyCbOpts,ssh_file),
    SshFileCb:add_host_key(Host,PublicKey,Options).

-spec(is_host_key(Key::public_key:public_key(),Host::string(),Algorithm::ssh:pubkey_alg(),Options) -> boolean() when Options::ssh_client_key_api:client_key_cb_options(call_ssh_file_option())).

is_host_key(Key,PeerName,Algorithm,Opts) ->
    KeyCbOpts = proplists:get_value(key_cb_private,Opts,[]),
    SshFileCb = proplists:get_value(call_ssh_file,KeyCbOpts,ssh_file),
    SshFileCb:is_host_key(Key,PeerName,Algorithm,Opts).

-spec(add_host_key(Host,inet:port_number(),public_key:public_key(),Options) -> Result when Host::inet:ip_address()|inet:hostname()|[inet:ip_address()|inet:hostname()],Options::ssh_client_key_api:client_key_cb_options(call_ssh_file_option()),Result::ok|{error,Error::term()}).

add_host_key(Host,Port,PublicKey,Options) ->
    KeyCbOpts = proplists:get_value(key_cb_private,Options,[]),
    SshFileCb = proplists:get_value(call_ssh_file,KeyCbOpts,ssh_file),
    SshFileCb:add_host_key(Host,Port,PublicKey,Options).

-spec(is_host_key(public_key:public_key(),Host,inet:port_number(),ssh:pubkey_alg(),Options) -> boolean() when Host::inet:ip_address()|inet:hostname()|[inet:ip_address()|inet:hostname()],Options::ssh_client_key_api:client_key_cb_options(call_ssh_file_option())).

is_host_key(Key,PeerName,Port,Algorithm,Opts) ->
    KeyCbOpts = proplists:get_value(key_cb_private,Opts,[]),
    SshFileCb = proplists:get_value(call_ssh_file,KeyCbOpts,ssh_file),
    SshFileCb:is_host_key(Key,PeerName,Port,Algorithm,Opts).

-spec(user_key(Algorithm::ssh:pubkey_alg(),Options) -> Result when Result::{ok,public_key:private_key()}|{ok,{ssh2_pubkey,PubKeyBlob::binary()}}|{error,string()},Options::ssh_client_key_api:client_key_cb_options(socket_path_option()|timeout_option())).

user_key(Algorithm,Opts) ->
    KeyCbOpts = proplists:get_value(key_cb_private,Opts,[]),
    Request = #ssh_agent_identities_request{},
    Response = ssh_agent:send(Request,KeyCbOpts),
    #ssh_agent_identities_response{keys = Keys} = Response,
    AlgorithmStr = atom_to_list(Algorithm),
    MatchingKeys = lists:filter(fun (Key)->
        has_key_type(Key,AlgorithmStr) end,Keys),
    case MatchingKeys of
        [#ssh_agent_key{blob = PubKeyBlob}| _OtherKeys]->
            {ok,{ssh2_pubkey,PubKeyBlob}};
        _->
            {error,enoent}
    end.

-spec(sign(binary(),binary(),Options) -> Blob::binary() when Options::ssh_client_key_api:client_key_cb_options(socket_path_option()|timeout_option())).

sign(PubKeyBlob,SigData,Opts) ->
    KeyCbOpts = proplists:get_value(key_cb_private,Opts,[]),
    SignFlags = 2 bor 4,
    SignRequest = #ssh_agent_sign_request{key_blob = PubKeyBlob,data = SigData,flags = SignFlags},
    SignResponse = ssh_agent:send(SignRequest,KeyCbOpts),
    #ssh_agent_sign_response{signature = #ssh_agent_signature{blob = Blob}} = SignResponse,
    Blob.

has_key_type(#ssh_agent_key{blob = KeyBlob},Type) ->
    <<_KeyTypeLen:32/unsigned-big-integer,KeyType:_KeyTypeLen/binary,_KeyBlobRest/binary>> = KeyBlob,
    binary_to_list(KeyType) == Type.

send(Request,Opts) ->
    SocketPath = proplists:get_value(socket_path,Opts,os:getenv("SSH_AUTH_SOCK")),
    Timeout = proplists:get_value(timeout,Opts,1000),
    ConnectOpts = [binary, {packet,0}, {active,false}],
    {ok,Socket} = gen_tcp:connect({local,SocketPath},0,ConnectOpts,Timeout),
    BinRequest = pack(encode(Request)),
    ok = gen_tcp:send(Socket,BinRequest),
    {ok,<<Len:32/unsigned-big-integer>>} = gen_tcp:recv(Socket,4,Timeout),
    {ok,BinResponse} = gen_tcp:recv(Socket,Len,Timeout),
    ok = gen_tcp:close(Socket),
    Response = decode(BinResponse),
    Response.

pack(Data) ->
    <<(size(Data)):32/unsigned-big-integer,Data/binary>>.

encode(#ssh_agent_identities_request{}) ->
    <<11:8/unsigned-big-integer>>;
encode(#ssh_agent_sign_request{key_blob = KeyBlob,data = Data,flags = Flags}) ->
    <<13:8/unsigned-big-integer,(size(if is_binary(KeyBlob) ->
        KeyBlob;is_list(KeyBlob) ->
        list_to_binary(KeyBlob);KeyBlob == undefined ->
        <<>> end)):32/unsigned-big-integer,if is_binary(KeyBlob) ->
        KeyBlob;is_list(KeyBlob) ->
        list_to_binary(KeyBlob);KeyBlob == undefined ->
        <<>> end/binary,(size(if is_binary(Data) ->
        Data;is_list(Data) ->
        list_to_binary(Data);Data == undefined ->
        <<>> end)):32/unsigned-big-integer,if is_binary(Data) ->
        Data;is_list(Data) ->
        list_to_binary(Data);Data == undefined ->
        <<>> end/binary,Flags:32/unsigned-big-integer>>.

decode_keys(<<>>,Acc,0) ->
    lists:reverse(Acc);
decode_keys(<<_KeyBlobLen:32/unsigned-big-integer,KeyBlob:_KeyBlobLen/binary,_CommentLen:32/unsigned-big-integer,Comment:_CommentLen/binary,Rest/binary>>,Acc,N) ->
    Key = #ssh_agent_key{blob = KeyBlob,comment = Comment},
    decode_keys(Rest,[Key| Acc],N - 1).

decode_signature(<<_FormatLen:32/unsigned-big-integer,Format:_FormatLen/binary,Blob/binary>>) ->
    <<_SignatureBlobLen:32/unsigned-big-integer,SignatureBlob:_SignatureBlobLen/binary>> = Blob,
    #ssh_agent_signature{format = Format,blob = SignatureBlob}.

decode(<<6:8/unsigned-big-integer>>) ->
    #ssh_agent_success{};
decode(<<5:8/unsigned-big-integer>>) ->
    #ssh_agent_failure{};
decode(<<12:8/unsigned-big-integer,NumKeys:32/unsigned-big-integer,KeyData/binary>>) ->
    #ssh_agent_identities_response{keys = decode_keys(KeyData,[],NumKeys)};
decode(<<14:8/unsigned-big-integer,_SignatureLen:32/unsigned-big-integer,Signature:_SignatureLen/binary>>) ->
    #ssh_agent_sign_response{signature = decode_signature(Signature)}.
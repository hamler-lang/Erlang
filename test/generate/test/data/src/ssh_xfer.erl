-file("ssh_xfer.erl", 1).

-module(ssh_xfer).

-export([open/6, opendir/3, readdir/3, close/3, read/5, write/5, rename/5, remove/3, mkdir/4, rmdir/3, realpath/3, extended/4, stat/4, fstat/4, lstat/4, setstat/4, readlink/3, fsetstat/4, symlink/4, protocol_version_request/2, xf_reply/2, xf_send_reply/3, xf_send_names/3, xf_send_name/4, xf_send_status/3, xf_send_status/4, xf_send_status/5, xf_send_handle/3, xf_send_attr/3, xf_send_data/3, encode_erlang_status/1, decode_open_flags/2, encode_open_flags/1, decode_ace_mask/1, decode_ext/1, decode_ATTR/2, encode_ATTR/2]).

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

-file("ssh_xfer.erl", 42).

-file("ssh_xfer.hrl", 1).

-record(ssh_xfer_attr, {type,size,owner,group,permissions,atime,atime_nseconds,createtime,createtime_nseconds,mtime,mtime_nseconds,acl,attrib_bits,extensions}).

-record(ssh_xfer_ace, {type,flag,mask,who}).

-record(ssh_xfer, {vsn,ext,cm,channel}).

-file("ssh_xfer.erl", 43).

-import(lists, [foldl/3, reverse/1]).

protocol_version_request(XF,Version) ->
    xf_request(XF,1,<<Version:32/unsigned-big-integer>>).

open(XF,ReqID,FileName,Access,Flags,Attrs) ->
    Vsn = XF#ssh_xfer.vsn,
    MBits = if Vsn >= 5 ->
        M = encode_ace_mask(Access),
        <<M:32/unsigned-big-integer>>;true ->
        <<>> end,
    F = encode_open_flags(Flags),
    xf_request(XF,3,[<<ReqID:32/unsigned-big-integer>>, <<(size(unicode:characters_to_binary(FileName))):32/unsigned-big-integer,(unicode:characters_to_binary(FileName))/binary>>, MBits, <<F:32/unsigned-big-integer>>, encode_ATTR(Vsn,Attrs)]).

opendir(XF,ReqID,DirName) ->
    xf_request(XF,11,[<<ReqID:32/unsigned-big-integer>>, <<(size(unicode:characters_to_binary(DirName))):32/unsigned-big-integer,(unicode:characters_to_binary(DirName))/binary>>]).

close(XF,ReqID,Handle) ->
    xf_request(XF,4,[<<ReqID:32/unsigned-big-integer>>, <<(size(Handle)):32/unsigned-big-integer,Handle/binary>>]).

read(XF,ReqID,Handle,Offset,Length) ->
    xf_request(XF,5,[<<ReqID:32/unsigned-big-integer>>, <<(size(Handle)):32/unsigned-big-integer,Handle/binary>>, <<Offset:64/unsigned-big-integer>>, <<Length:32/unsigned-big-integer>>]).

readdir(XF,ReqID,Handle) ->
    xf_request(XF,12,[<<ReqID:32/unsigned-big-integer>>, <<(size(Handle)):32/unsigned-big-integer,Handle/binary>>]).

write(XF,ReqID,Handle,Offset,Data) ->
    Data1 = if is_binary(Data) ->
        Data;is_list(Data) ->
        try iolist_to_binary(Data)
            catch
                _:_->
                    unicode:characters_to_binary(Data) end end,
    xf_request(XF,6,[<<ReqID:32/unsigned-big-integer>>, <<(size(Handle)):32/unsigned-big-integer,Handle/binary>>, <<Offset:64/unsigned-big-integer>>, <<(size(Data1)):32/unsigned-big-integer,Data1/binary>>]).

remove(XF,ReqID,File) ->
    xf_request(XF,13,[<<ReqID:32/unsigned-big-integer>>, <<(size(unicode:characters_to_binary(File))):32/unsigned-big-integer,(unicode:characters_to_binary(File))/binary>>]).

rename(XF,ReqID,OldPath,NewPath,Flags) ->
    Vsn = XF#ssh_xfer.vsn,
    FlagBits = if Vsn >= 5 ->
        F0 = encode_rename_flags(Flags),
        <<F0:32/unsigned-big-integer>>;true ->
        <<>> end,
    Ext = XF#ssh_xfer.ext,
    ExtRename = "posix-rename@openssh.com",
    case lists:member({ExtRename,"1"},Ext) of
        true->
            extended(XF,ReqID,ExtRename,[<<(size(unicode:characters_to_binary(OldPath))):32/unsigned-big-integer,(unicode:characters_to_binary(OldPath))/binary>>, <<(size(unicode:characters_to_binary(NewPath))):32/unsigned-big-integer,(unicode:characters_to_binary(NewPath))/binary>>]);
        false->
            xf_request(XF,18,[<<ReqID:32/unsigned-big-integer>>, <<(size(unicode:characters_to_binary(OldPath))):32/unsigned-big-integer,(unicode:characters_to_binary(OldPath))/binary>>, <<(size(unicode:characters_to_binary(NewPath))):32/unsigned-big-integer,(unicode:characters_to_binary(NewPath))/binary>>, FlagBits])
    end.

mkdir(XF,ReqID,Path,Attrs) ->
    xf_request(XF,14,[<<ReqID:32/unsigned-big-integer>>, <<(size(unicode:characters_to_binary(Path))):32/unsigned-big-integer,(unicode:characters_to_binary(Path))/binary>>, encode_ATTR(XF#ssh_xfer.vsn,Attrs)]).

rmdir(XF,ReqID,Dir) ->
    xf_request(XF,15,[<<ReqID:32/unsigned-big-integer>>, <<(size(unicode:characters_to_binary(Dir))):32/unsigned-big-integer,(unicode:characters_to_binary(Dir))/binary>>]).

stat(XF,ReqID,Path,Flags) ->
    Vsn = XF#ssh_xfer.vsn,
    AttrFlags = if Vsn >= 5 ->
        F = encode_attr_flags(Vsn,Flags),
        <<F:32/unsigned-big-integer>>;true ->
        [] end,
    xf_request(XF,17,[<<ReqID:32/unsigned-big-integer>>, <<(size(unicode:characters_to_binary(Path))):32/unsigned-big-integer,(unicode:characters_to_binary(Path))/binary>>, AttrFlags]).

lstat(XF,ReqID,Path,Flags) ->
    Vsn = XF#ssh_xfer.vsn,
    AttrFlags = if Vsn >= 5 ->
        F = encode_attr_flags(Vsn,Flags),
        <<F:32/unsigned-big-integer>>;true ->
        [] end,
    xf_request(XF,7,[<<ReqID:32/unsigned-big-integer>>, <<(size(unicode:characters_to_binary(Path))):32/unsigned-big-integer,(unicode:characters_to_binary(Path))/binary>>, AttrFlags]).

fstat(XF,ReqID,Handle,Flags) ->
    Vsn = XF#ssh_xfer.vsn,
    AttrFlags = if Vsn >= 5 ->
        F = encode_attr_flags(Vsn,Flags),
        <<F:32/unsigned-big-integer>>;true ->
        [] end,
    xf_request(XF,8,[<<ReqID:32/unsigned-big-integer>>, <<(size(Handle)):32/unsigned-big-integer,Handle/binary>>, AttrFlags]).

setstat(XF,ReqID,Path,Attrs) ->
    xf_request(XF,9,[<<ReqID:32/unsigned-big-integer>>, <<(size(unicode:characters_to_binary(Path))):32/unsigned-big-integer,(unicode:characters_to_binary(Path))/binary>>, encode_ATTR(XF#ssh_xfer.vsn,Attrs)]).

fsetstat(XF,ReqID,Handle,Attrs) ->
    xf_request(XF,10,[<<ReqID:32/unsigned-big-integer>>, <<(size(Handle)):32/unsigned-big-integer,Handle/binary>>, encode_ATTR(XF#ssh_xfer.vsn,Attrs)]).

readlink(XF,ReqID,Path) ->
    xf_request(XF,19,[<<ReqID:32/unsigned-big-integer>>, <<(size(unicode:characters_to_binary(Path))):32/unsigned-big-integer,(unicode:characters_to_binary(Path))/binary>>]).

symlink(XF,ReqID,LinkPath,TargetPath) ->
    LinkPath1 = unicode:characters_to_binary(LinkPath),
    TargetPath1 = unicode:characters_to_binary(TargetPath),
    xf_request(XF,20,[<<ReqID:32/unsigned-big-integer>>, <<(size(LinkPath1)):32/unsigned-big-integer,LinkPath1/binary>>, <<(size(TargetPath1)):32/unsigned-big-integer,TargetPath1/binary>>]).

realpath(XF,ReqID,Path) ->
    xf_request(XF,16,[<<ReqID:32/unsigned-big-integer>>, <<(size(unicode:characters_to_binary(Path))):32/unsigned-big-integer,(unicode:characters_to_binary(Path))/binary>>]).

extended(XF,ReqID,Request,Data) ->
    xf_request(XF,200,[<<ReqID:32/unsigned-big-integer>>, <<(size(unicode:characters_to_binary(Request))):32/unsigned-big-integer,(unicode:characters_to_binary(Request))/binary>>, Data]).

xf_request(XF,Op,Arg) ->
    CM = XF#ssh_xfer.cm,
    Channel = XF#ssh_xfer.channel,
    Data = if is_binary(Arg) ->
        Arg;is_list(Arg) ->
        try iolist_to_binary(Arg)
            catch
                _:_->
                    unicode:characters_to_binary(Arg) end end,
    Size = 1 + size(Data),
    ssh_connection:send(CM,Channel,[<<Size:32/unsigned-big-integer,Op,Data/binary>>]).

xf_send_reply(#ssh_xfer{cm = CM,channel = Channel},Op,Arg) ->
    Data = if is_binary(Arg) ->
        Arg;is_list(Arg) ->
        try iolist_to_binary(Arg)
            catch
                _:_->
                    unicode:characters_to_binary(Arg) end end,
    Size = 1 + size(Data),
    ssh_connection:send(CM,Channel,[<<Size:32/unsigned-big-integer,Op,Data/binary>>]).

xf_send_name(XF,ReqId,Name,Attr) ->
    xf_send_names(XF,ReqId,[{Name,Attr}]).

xf_send_handle(#ssh_xfer{cm = CM,channel = Channel},ReqId,Handle) ->
    HLen = length(Handle),
    Size = 1 + 4 + 4 + HLen,
    ToSend = [<<Size:32/unsigned-big-integer,102,ReqId:32/unsigned-big-integer,HLen:32/unsigned-big-integer>>, Handle],
    ssh_connection:send(CM,Channel,ToSend).

xf_send_names(#ssh_xfer{cm = CM,channel = Channel,vsn = Vsn},ReqId,NamesAndAttrs) ->
    Count = length(NamesAndAttrs),
    {Data,Len} = encode_names(Vsn,NamesAndAttrs),
    Size = 1 + 4 + 4 + Len,
    ToSend = [<<Size:32/unsigned-big-integer,104,ReqId:32/unsigned-big-integer,Count:32/unsigned-big-integer>>, Data],
    ssh_connection:send(CM,Channel,ToSend).

xf_send_status(XF,ReqId,ErrorCode) ->
    xf_send_status(XF,ReqId,ErrorCode,"").

xf_send_status(XF,ReqId,ErrorCode,ErrorMsg) ->
    xf_send_status(XF,ReqId,ErrorCode,ErrorMsg,<<>>).

xf_send_status(#ssh_xfer{cm = CM,channel = Channel},ReqId,ErrorCode,ErrorMsg,Data) ->
    LangTag = "en",
    ELen = length(ErrorMsg),
    TLen = 2,
    Size = 1 + 4 + 4 + 4 + ELen + 4 + TLen + size(Data),
    ToSend = [<<Size:32/unsigned-big-integer,101,ReqId:32/unsigned-big-integer,ErrorCode:32/unsigned-big-integer>>, <<ELen:32/unsigned-big-integer>>, ErrorMsg, <<TLen:32/unsigned-big-integer>>, LangTag, Data],
    ssh_connection:send(CM,Channel,ToSend).

xf_send_attr(#ssh_xfer{cm = CM,channel = Channel,vsn = Vsn},ReqId,Attr) ->
    EncAttr = encode_ATTR(Vsn,Attr),
    ALen = size(EncAttr),
    Size = 1 + 4 + ALen,
    ToSend = [<<Size:32/unsigned-big-integer,105,ReqId:32/unsigned-big-integer>>, EncAttr],
    ssh_connection:send(CM,Channel,ToSend).

xf_send_data(#ssh_xfer{cm = CM,channel = Channel},ReqId,Data) ->
    DLen = size(Data),
    Size = 1 + 4 + 4 + DLen,
    ToSend = [<<Size:32/unsigned-big-integer,103,ReqId:32/unsigned-big-integer,DLen:32/unsigned-big-integer>>, Data],
    ssh_connection:send(CM,Channel,ToSend).

xf_reply(_XF,<<101,ReqID:32/unsigned-big-integer,Status:32/unsigned-big-integer,ELen:32/unsigned-big-integer,Err:ELen/binary,LLen:32/unsigned-big-integer,Lang:LLen/binary,Reply/binary>>) ->
    Stat = decode_status(Status),
    {status,ReqID,{Stat,binary_to_list(Err),binary_to_list(Lang),Reply}};
xf_reply(_XF,<<101,ReqID:32/unsigned-big-integer,Status:32/unsigned-big-integer>>) ->
    Stat = decode_status(Status),
    {status,ReqID,{Stat,"","",<<>>}};
xf_reply(_XF,<<102,ReqID:32/unsigned-big-integer,HLen:32/unsigned-big-integer,Handle:HLen/binary>>) ->
    {handle,ReqID,Handle};
xf_reply(_XF,<<103,ReqID:32/unsigned-big-integer,DLen:32/unsigned-big-integer,Data:DLen/binary>>) ->
    {data,ReqID,Data};
xf_reply(XF,<<104,ReqID:32/unsigned-big-integer,Count:32/unsigned-big-integer,AData/binary>>) ->
    {name,ReqID,decode_names(XF#ssh_xfer.vsn,Count,AData)};
xf_reply(XF,<<105,ReqID:32/unsigned-big-integer,AData/binary>>) ->
    {A,_} = decode_ATTR(XF#ssh_xfer.vsn,AData),
    {attrs,ReqID,A};
xf_reply(_XF,<<201,ReqID:32/unsigned-big-integer,RData>>) ->
    {extended_reply,ReqID,RData}.

decode_status(Status) ->
    case Status of
        0->
            ok;
        1->
            eof;
        2->
            no_such_file;
        3->
            permission_denied;
        4->
            failure;
        5->
            bad_message;
        6->
            no_connection;
        7->
            connection_lost;
        8->
            op_unsupported;
        9->
            invalid_handle;
        10->
            no_such_path;
        11->
            file_already_exists;
        12->
            write_protect;
        13->
            no_media;
        14->
            no_space_on_filesystem;
        15->
            quota_exceeded;
        16->
            unknown_principle;
        17->
            lock_conflict;
        19->
            not_a_directory;
        24->
            file_is_a_directory;
        22->
            cannot_delete;
        _->
            {error,Status}
    end.

encode_erlang_status(Status) ->
    case Status of
        ok->
            0;
        eof->
            1;
        enoent->
            2;
        eacces->
            3;
        eisdir->
            24;
        eperm->
            22;
        eexist->
            11;
        _->
            4
    end.

decode_ext(<<NameLen:32/unsigned-big-integer,Name:NameLen/binary,DataLen:32/unsigned-big-integer,Data:DataLen/binary,Tail/binary>>) ->
    [{binary_to_list(Name),binary_to_list(Data)}| decode_ext(Tail)];
decode_ext(<<>>) ->
    [].

encode_rename_flags(Flags) ->
    encode_bits(fun (overwrite)->
        1;(atomic)->
        2;(native)->
        4 end,Flags).

encode_open_flags(Flags) ->
    encode_bits(fun (read)->
        1;(write)->
        2;(append)->
        4;(creat)->
        8;(trunc)->
        16;(excl)->
        32;(create_new)->
        0;(create_truncate)->
        1;(open_existing)->
        2;(open_or_create)->
        3;(truncate_existing)->
        4;(append_data)->
        8;(append_data_atomic)->
        16;(text_mode)->
        32;(read_lock)->
        64;(write_lock)->
        128;(delete_lock)->
        256 end,Flags).

encode_ace_mask(Access) ->
    encode_bits(fun (read_data)->
        1;(list_directory)->
        1;(write_data)->
        2;(add_file)->
        2;(append_data)->
        4;(add_subdirectory)->
        4;(read_named_attrs)->
        8;(write_named_attrs)->
        16;(execute)->
        32;(delete_child)->
        64;(read_attributes)->
        128;(write_attributes)->
        256;(delete)->
        65536;(read_acl)->
        131072;(write_acl)->
        262144;(write_owner)->
        524288;(synchronize)->
        1048576 end,Access).

decode_ace_mask(F) ->
    decode_bits(F,[{1,read_data}, {1,list_directory}, {2,write_data}, {2,add_file}, {4,append_data}, {4,add_subdirectory}, {8,read_named_attrs}, {16,write_named_attrs}, {32,execute}, {64,delete_child}, {128,read_attributes}, {256,write_attributes}, {65536,delete}, {131072,read_acl}, {262144,write_acl}, {524288,write_owner}, {1048576,synchronize}]).

decode_open_flags(Vsn,F)
    when Vsn =< 3->
    decode_bits(F,[{1,read}, {2,write}, {4,append}, {8,creat}, {16,trunc}, {32,excl}]);
decode_open_flags(Vsn,F)
    when Vsn >= 4->
    R = decode_bits(F,[{8,append_data}, {16,append_data_atomic}, {32,text_mode}, {64,read_lock}, {128,write_lock}, {256,delete_lock}]),
    AD = case F band 7 of
        0->
            create_new;
        1->
            create_truncate;
        2->
            open_existing;
        3->
            open_or_create;
        4->
            truncate_existing
    end,
    [AD| R].

encode_ace_type(Type) ->
    case Type of
        access_allowed->
            0;
        access_denied->
            1;
        system_audit->
            2;
        system_alarm->
            3
    end.

decode_ace_type(F) ->
    case F of
        0->
            access_allowed;
        1->
            access_denied;
        2->
            system_audit;
        3->
            system_alarm
    end.

encode_ace_flag(Flag) ->
    encode_bits(fun (file_inherit)->
        1;(directory_inherit)->
        2;(no_propagte_inherit)->
        4;(inherit_only)->
        8;(successful_access)->
        16;(failed_access)->
        32;(identifier_group)->
        64 end,Flag).

decode_ace_flag(F) ->
    decode_bits(F,[{1,file_inherit}, {2,directory_inherit}, {4,no_propagte_inherit}, {8,inherit_only}, {16,successful_access}, {32,failed_access}, {64,identifier_group}]).

encode_attr_flags(Vsn,all) ->
    encode_attr_flags(Vsn,[size, uidgid, permissions, acmodtime, accesstime, createtime, modifytime, acl, ownergroup, subsecond_times, bits, extended]);
encode_attr_flags(Vsn,Flags) ->
    encode_bits(fun (size)->
        1;(uidgid)
        when Vsn =< 3->
        2;(permissions)->
        4;(acmodtime)
        when Vsn =< 3->
        8;(accesstime)
        when Vsn >= 5->
        8;(createtime)
        when Vsn >= 5->
        16;(modifytime)
        when Vsn >= 5->
        32;(acl)
        when Vsn >= 5->
        64;(ownergroup)
        when Vsn >= 5->
        128;(subsecond_times)
        when Vsn >= 5->
        256;(bits)
        when Vsn >= 5->
        512;(extended)
        when Vsn >= 5->
        2147483648;(_)->
        0 end,Flags).

encode_file_type(Type) ->
    case Type of
        regular->
            1;
        directory->
            2;
        symlink->
            3;
        special->
            4;
        unknown->
            5;
        other->
            5;
        socket->
            6;
        char_device->
            7;
        block_device->
            8;
        fifo->
            9;
        undefined->
            5
    end.

decode_file_type(Type) ->
    case Type of
        1->
            regular;
        2->
            directory;
        3->
            symlink;
        4->
            special;
        5->
            other;
        6->
            socket;
        7->
            char_device;
        8->
            block_device;
        9->
            fifo
    end.

encode_attrib_bits(Bits) ->
    encode_bits(fun (readonly)->
        1;(system)->
        2;(hidden)->
        4;(case_insensitive)->
        8;(arcive)->
        16;(encrypted)->
        32;(compressed)->
        64;(sparse)->
        128;(append_only)->
        256;(immutable)->
        512;(sync)->
        1024 end,Bits).

decode_attrib_bits(F) ->
    decode_bits(F,[{1,readonly}, {2,system}, {4,hidden}, {8,case_insensitive}, {16,arcive}, {32,encrypted}, {64,compressed}, {128,sparse}, {256,append_only}, {512,immutable}, {1024,sync}]).

encode_ATTR(Vsn,A) ->
    {Flags,As} = encode_As(Vsn,[{size,A#ssh_xfer_attr.size}, {ownergroup,A#ssh_xfer_attr.owner}, {ownergroup,A#ssh_xfer_attr.group}, {permissions,A#ssh_xfer_attr.permissions}, {acmodtime,A#ssh_xfer_attr.atime}, {acmodtime,A#ssh_xfer_attr.mtime}, {accesstime,A#ssh_xfer_attr.atime}, {subsecond_times,A#ssh_xfer_attr.atime_nseconds}, {createtime,A#ssh_xfer_attr.createtime}, {subsecond_times,A#ssh_xfer_attr.createtime_nseconds}, {modifytime,A#ssh_xfer_attr.mtime}, {subsecond_times,A#ssh_xfer_attr.mtime_nseconds}, {acl,A#ssh_xfer_attr.acl}, {bits,A#ssh_xfer_attr.attrib_bits}, {extended,A#ssh_xfer_attr.extensions}],0,[]),
    Type = encode_file_type(A#ssh_xfer_attr.type),
    Result = list_to_binary([<<Flags:32/unsigned-big-integer>>, if Vsn >= 5 ->
        <<Type:8/unsigned-big-integer>>;true ->
        <<>> end, As]),
    Result.

encode_As(Vsn,[{_AName,undefined}| As],Flags,Acc) ->
    encode_As(Vsn,As,Flags,Acc);
encode_As(Vsn,[{AName,X}| As],Flags,Acc) ->
    case AName of
        size->
            encode_As(Vsn,As,Flags bor 1,[<<X:64/unsigned-big-integer>>| Acc]);
        ownergroup
            when Vsn =< 4->
            encode_As(Vsn,As,Flags bor 2,[<<X:32/unsigned-big-integer>>| Acc]);
        ownergroup
            when Vsn >= 5->
            X1 = list_to_binary(integer_to_list(X)),
            encode_As(Vsn,As,Flags bor 128,[<<(size(X1)):32/unsigned-big-integer,X1/binary>>| Acc]);
        permissions->
            encode_As(Vsn,As,Flags bor 4,[<<X:32/unsigned-big-integer>>| Acc]);
        acmodtime
            when Vsn =< 3->
            encode_As(Vsn,As,Flags bor 8,[<<X:32/unsigned-big-integer>>| Acc]);
        accesstime
            when Vsn >= 5->
            encode_As(Vsn,As,Flags bor 8,[<<X:64/unsigned-big-integer>>| Acc]);
        createtime
            when Vsn >= 5->
            encode_As(Vsn,As,Flags bor 16,[<<X:64/unsigned-big-integer>>| Acc]);
        modifytime
            when Vsn >= 5->
            encode_As(Vsn,As,Flags bor 32,[<<X:64/unsigned-big-integer>>| Acc]);
        subsecond_times
            when Vsn >= 5->
            encode_As(Vsn,As,Flags bor 256,[<<X:64/unsigned-big-integer>>| Acc]);
        acl
            when Vsn >= 5->
            encode_As(Vsn,As,Flags bor 64,[encode_acl(X)| Acc]);
        bits
            when Vsn >= 5->
            F = encode_attrib_bits(X),
            encode_As(Vsn,As,Flags bor 512,[<<F:32/unsigned-big-integer>>| Acc]);
        extended->
            encode_As(Vsn,As,Flags bor 2147483648,[encode_extensions(X)| Acc]);
        _->
            encode_As(Vsn,As,Flags,Acc)
    end;
encode_As(_Vsn,[],Flags,Acc) ->
    {Flags,reverse(Acc)}.

decode_ATTR(Vsn,<<Flags:32/unsigned-big-integer,Tail/binary>>) ->
    {Type,Tail2} = if Vsn =< 3 ->
        {5,Tail};true ->
        <<T:8/unsigned-big-integer,TL/binary>> = Tail,
        {T,TL} end,
    decode_As(Vsn,[{size,#ssh_xfer_attr.size}, {ownergroup,#ssh_xfer_attr.owner}, {ownergroup,#ssh_xfer_attr.group}, {permissions,#ssh_xfer_attr.permissions}, {acmodtime,#ssh_xfer_attr.atime}, {acmodtime,#ssh_xfer_attr.mtime}, {accesstime,#ssh_xfer_attr.atime}, {subsecond_times,#ssh_xfer_attr.atime_nseconds}, {createtime,#ssh_xfer_attr.createtime}, {subsecond_times,#ssh_xfer_attr.createtime_nseconds}, {modifytime,#ssh_xfer_attr.mtime}, {subsecond_times,#ssh_xfer_attr.mtime_nseconds}, {acl,#ssh_xfer_attr.acl}, {bits,#ssh_xfer_attr.attrib_bits}, {extended,#ssh_xfer_attr.extensions}],#ssh_xfer_attr{type = decode_file_type(Type)},Flags,Tail2).

decode_As(Vsn,[{AName,AField}| As],R,Flags,Tail) ->
    case AName of
        size
            when 1 band Flags == 1->
            <<X:64/unsigned-big-integer,Tail2/binary>> = Tail,
            decode_As(Vsn,As,setelement(AField,R,X),Flags,Tail2);
        ownergroup
            when 2 band Flags == 2,
            Vsn =< 3->
            <<X:32/unsigned-big-integer,Tail2/binary>> = Tail,
            decode_As(Vsn,As,setelement(AField,R,X),Flags,Tail2);
        ownergroup
            when 128 band Flags == 128,
            Vsn >= 5->
            <<Len:32/unsigned-big-integer,Bin:Len/binary,Tail2/binary>> = Tail,
            X = binary_to_list(Bin),
            decode_As(Vsn,As,setelement(AField,R,X),Flags,Tail2);
        permissions
            when 4 band Flags == 4,
            Vsn >= 5->
            <<X:32/unsigned-big-integer,Tail2/binary>> = Tail,
            decode_As(Vsn,As,setelement(AField,R,X),Flags,Tail2);
        permissions
            when 4 band Flags == 4,
            Vsn =< 3->
            <<X:32/unsigned-big-integer,Tail2/binary>> = Tail,
            R1 = setelement(AField,R,X),
            Type = case X band 61440 of
                16384->
                    directory;
                8192->
                    char_device;
                24576->
                    block_device;
                4096->
                    fifi;
                32768->
                    regular;
                49152->
                    socket;
                40960->
                    symlink;
                _->
                    unknown
            end,
            decode_As(Vsn,As,R1#ssh_xfer_attr{type = Type},Flags,Tail2);
        acmodtime
            when 8 band Flags == 8,
            Vsn =< 3->
            <<X:32/unsigned-big-integer,Tail2/binary>> = Tail,
            decode_As(Vsn,As,setelement(AField,R,X),Flags,Tail2);
        accesstime
            when 8 band Flags == 8,
            Vsn >= 5->
            <<X:64/unsigned-big-integer,Tail2/binary>> = Tail,
            decode_As(Vsn,As,setelement(AField,R,X),Flags,Tail2);
        modifytime
            when 32 band Flags == 32,
            Vsn >= 5->
            <<X:64/unsigned-big-integer,Tail2/binary>> = Tail,
            decode_As(Vsn,As,setelement(AField,R,X),Flags,Tail2);
        createtime
            when 16 band Flags == 16,
            Vsn >= 5->
            <<X:64/unsigned-big-integer,Tail2/binary>> = Tail,
            decode_As(Vsn,As,setelement(AField,R,X),Flags,Tail2);
        subsecond_times
            when 256 band Flags == 256,
            Vsn >= 5->
            <<X:32/unsigned-big-integer,Tail2/binary>> = Tail,
            decode_As(Vsn,As,setelement(AField,R,X),Flags,Tail2);
        acl
            when 64 band Flags == 64,
            Vsn >= 5->
            {X,Tail2} = decode_acl(Tail),
            decode_As(Vsn,As,setelement(AField,R,X),Flags,Tail2);
        bits
            when 512 band Flags == 512,
            Vsn >= 5->
            <<Y:32/unsigned-big-integer,Tail2/binary>> = Tail,
            X = decode_attrib_bits(Y),
            decode_As(Vsn,As,setelement(AField,R,X),Flags,Tail2);
        extended
            when 2147483648 band Flags == 2147483648->
            {X,Tail2} = decode_extended(Tail),
            decode_As(Vsn,As,setelement(AField,R,X),Flags,Tail2);
        _->
            decode_As(Vsn,As,R,Flags,Tail)
    end;
decode_As(_Vsn,[],R,_,Tail) ->
    {R,Tail}.

decode_names(_Vsn,0,_Data) ->
    [];
decode_names(Vsn,I,<<Len:32/unsigned-big-integer,FileName:Len/binary,LLen:32/unsigned-big-integer,_LongName:LLen/binary,Tail/binary>>)
    when Vsn =< 3->
    Name = unicode:characters_to_list(FileName),
    {A,Tail2} = decode_ATTR(Vsn,Tail),
    [{Name,A}| decode_names(Vsn,I - 1,Tail2)];
decode_names(Vsn,I,<<Len:32/unsigned-big-integer,FileName:Len/binary,Tail/binary>>)
    when Vsn >= 4->
    Name = unicode:characters_to_list(FileName),
    {A,Tail2} = decode_ATTR(Vsn,Tail),
    [{Name,A}| decode_names(Vsn,I - 1,Tail2)].

encode_names(Vsn,NamesAndAttrs) ->
    lists:mapfoldl(fun (N,L)->
        encode_name(Vsn,N,L) end,0,NamesAndAttrs).

encode_name(Vsn,{NameUC,Attr},Len)
    when Vsn =< 3->
    Name = binary_to_list(unicode:characters_to_binary(NameUC)),
    NLen = length(Name),
    EncAttr = encode_ATTR(Vsn,Attr),
    ALen = size(EncAttr),
    NewLen = Len + NLen * 2 + 4 + 4 + ALen,
    {[<<NLen:32/unsigned-big-integer>>, Name, <<NLen:32/unsigned-big-integer>>, Name, EncAttr],NewLen};
encode_name(Vsn,{NameUC,Attr},Len)
    when Vsn >= 4->
    Name = binary_to_list(unicode:characters_to_binary(NameUC)),
    NLen = length(Name),
    EncAttr = encode_ATTR(Vsn,Attr),
    ALen = size(EncAttr),
    {[<<NLen:32/unsigned-big-integer>>, Name, EncAttr],Len + 4 + NLen + ALen}.

encode_acl(ACLList) ->
    Count = length(ACLList),
    [<<Count:32/unsigned-big-integer>>| encode_acl_items(ACLList)].

encode_acl_items([ACE| As]) ->
    Type = encode_ace_type(ACE#ssh_xfer_ace.type),
    Flag = encode_ace_flag(ACE#ssh_xfer_ace.flag),
    Mask = encode_ace_mask(ACE#ssh_xfer_ace.mask),
    Who = ACE#ssh_xfer_ace.who,
    [<<Type:32/unsigned-big-integer>>, <<Flag:32/unsigned-big-integer>>, <<Mask:32/unsigned-big-integer>>, <<(size(unicode:characters_to_binary(Who))):32/unsigned-big-integer,(unicode:characters_to_binary(Who))/binary>>| encode_acl_items(As)];
encode_acl_items([]) ->
    [].

decode_acl(<<Count:32/unsigned-big-integer,Tail/binary>>) ->
    decode_acl_items(Count,Tail,[]).

decode_acl_items(0,Tail,Acc) ->
    {reverse(Acc),Tail};
decode_acl_items(I,<<Type:32/unsigned-big-integer,Flag:32/unsigned-big-integer,Mask:32/unsigned-big-integer,WLen:32/unsigned-big-integer,BWho:WLen/binary,Tail/binary>>,Acc) ->
    decode_acl_items(I - 1,Tail,[#ssh_xfer_ace{type = decode_ace_type(Type),flag = decode_ace_flag(Flag),mask = decode_ace_mask(Mask),who = unicode:characters_to_list(BWho)}| Acc]).

encode_extensions(Exts) ->
    Count = length(Exts),
    [<<Count:32/unsigned-big-integer>>| encode_ext(Exts)].

encode_ext([{Type,Data}| Exts]) ->
    [<<(size(unicode:characters_to_binary(Type))):32/unsigned-big-integer,(unicode:characters_to_binary(Type))/binary>>, <<(size(unicode:characters_to_binary(Data))):32/unsigned-big-integer,(unicode:characters_to_binary(Data))/binary>>| encode_ext(Exts)];
encode_ext([]) ->
    [].

decode_extended(<<Count:32/unsigned-big-integer,Tail/binary>>) ->
    decode_ext(Count,Tail,[]).

decode_ext(0,Tail,Acc) ->
    {reverse(Acc),Tail};
decode_ext(I,<<TLen:32/unsigned-big-integer,Type:TLen/binary,DLen:32/unsigned-big-integer,Data:DLen/binary,Tail/binary>>,Acc) ->
    decode_ext(I - 1,Tail,[{binary_to_list(Type),Data}| Acc]).

encode_bits(Fun,BitNames) ->
    encode_bits(Fun,0,BitNames).

encode_bits(Fun,F,[Bit| BitNames]) ->
    encode_bits(Fun,Fun(Bit) bor F,BitNames);
encode_bits(_Fun,F,[]) ->
    F.

decode_bits(F,[{Bit,BitName}| Bits]) ->
    if F band Bit == Bit ->
        [BitName| decode_bits(F,Bits)];true ->
        decode_bits(F,Bits) end;
decode_bits(_F,[]) ->
    [].
-file("ssh_sftp.erl", 1).

-module(ssh_sftp).

-behaviour(ssh_client_channel).

-file("/usr/lib/erlang/lib/kernel-7.2/include/file.hrl", 1).

-record(file_info,{size::non_neg_integer()|undefined,type::device|directory|other|regular|symlink|undefined,access::read|write|read_write|none|undefined,atime::file:date_time()|non_neg_integer()|undefined,mtime::file:date_time()|non_neg_integer()|undefined,ctime::file:date_time()|non_neg_integer()|undefined,mode::non_neg_integer()|undefined,links::non_neg_integer()|undefined,major_device::non_neg_integer()|undefined,minor_device::non_neg_integer()|undefined,inode::non_neg_integer()|undefined,uid::non_neg_integer()|undefined,gid::non_neg_integer()|undefined}).

-record(file_descriptor,{module::module(),data::term()}).

-file("ssh_sftp.erl", 30).

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

-file("ssh_sftp.erl", 31).

-file("ssh_xfer.hrl", 1).

-record(ssh_xfer_attr, {type,size,owner,group,permissions,atime,atime_nseconds,createtime,createtime_nseconds,mtime,mtime_nseconds,acl,attrib_bits,extensions}).

-record(ssh_xfer_ace, {type,flag,mask,who}).

-record(ssh_xfer, {vsn,ext,cm,channel}).

-file("ssh_sftp.erl", 32).

-export([start_channel/1, start_channel/2, start_channel/3, stop_channel/1]).

-export([open/3, open_tar/3, opendir/2, close/2, readdir/2, pread/4, read/3, open/4, open_tar/4, opendir/3, close/3, readdir/3, pread/5, read/4, apread/4, aread/3, pwrite/4, write/3, apwrite/4, awrite/3, pwrite/5, write/4, position/3, real_path/2, read_file_info/2, get_file_info/2, position/4, real_path/3, read_file_info/3, get_file_info/3, write_file_info/3, read_link_info/2, read_link/2, make_symlink/3, write_file_info/4, read_link_info/3, read_link/3, make_symlink/4, rename/3, delete/2, make_dir/2, del_dir/2, send_window/1, rename/4, delete/3, make_dir/3, del_dir/3, send_window/2, recv_window/1, list_dir/2, read_file/2, write_file/3, recv_window/2, list_dir/3, read_file/3, write_file/4]).

-export([init/1, handle_call/3, handle_cast/2, code_change/3, handle_msg/2, handle_ssh_msg/2, terminate/2]).

-export([info_to_attr/1, attr_to_info/1]).

-behaviour(ssh_dbg).

-export([ssh_dbg_trace_points/0, ssh_dbg_flags/1, ssh_dbg_on/1, ssh_dbg_off/1, ssh_dbg_format/2]).

-record(state, {xf,rep_buf = <<>>,req_id,req_list = [],inf,opts}).

-record(fileinf, {handle,offset,size,mode}).

-record(bufinf, {mode,crypto_state,crypto_fun,size = 0,chunksize,enc_text_buf = <<>>,plain_text_buf = <<>>}).

-type(sftp_option()::{timeout,timeout()}|{sftp_vsn,pos_integer()}|{window_size,pos_integer()}|{packet_size,pos_integer()}).

-type(reason()::atom()|string()|tuple()).

start_channel(Cm)
    when is_pid(Cm)->
    start_channel(Cm,[]);
start_channel(Socket)
    when is_port(Socket)->
    start_channel(Socket,[]);
start_channel(Host) ->
    start_channel(Host,[]).

-spec(start_channel(ssh:open_socket(),[ssh:client_options()|sftp_option()]) -> {ok,pid(),ssh:connection_ref()}|{error,reason()};(ssh:connection_ref(),[sftp_option()]) -> {ok,pid()}|{ok,pid(),ssh:connection_ref()}|{error,reason()};(ssh:host(),[ssh:client_options()|sftp_option()]) -> {ok,pid(),ssh:connection_ref()}|{error,reason()}).

start_channel(Socket,UserOptions)
    when is_port(Socket)->
    {SshOpts,ChanOpts,SftpOpts} = handle_options(UserOptions),
    Timeout = proplists:get_value(connect_timeout,SshOpts,proplists:get_value(timeout,SftpOpts,infinity)),
    case ssh:connect(Socket,SshOpts,Timeout) of
        {ok,Cm}->
            case start_channel(Cm,ChanOpts ++ SftpOpts) of
                {ok,Pid}->
                    {ok,Pid,Cm};
                Error->
                    Error
            end;
        Error->
            Error
    end;
start_channel(Cm,UserOptions)
    when is_pid(Cm)->
    Timeout = proplists:get_value(timeout,UserOptions,infinity),
    {_SshOpts,ChanOpts,SftpOpts} = handle_options(UserOptions),
    WindowSize = proplists:get_value(window_size,ChanOpts,20 * 65536),
    PacketSize = proplists:get_value(packet_size,ChanOpts,65536),
    case ssh_connection:session_channel(Cm,WindowSize,PacketSize,Timeout) of
        {ok,ChannelId}->
            case ssh_connection_handler:start_channel(Cm,ssh_sftp,ChannelId,[Cm, ChannelId, SftpOpts],undefined) of
                {ok,Pid}->
                    case wait_for_version_negotiation(Pid,Timeout) of
                        ok->
                            {ok,Pid};
                        TimeOut->
                            TimeOut
                    end;
                {error,Reason}->
                    {error,format_channel_start_error(Reason)}
            end;
        Error->
            Error
    end;
start_channel(Host,UserOptions) ->
    start_channel(Host,22,UserOptions).

-spec(start_channel(ssh:host(),inet:port_number(),[ssh:client_option()|sftp_option()]) -> {ok,pid(),ssh:connection_ref()}|{error,reason()}).

start_channel(Host,Port,UserOptions) ->
    {SshOpts,_ChanOpts,_SftpOpts} = handle_options(UserOptions),
    Timeout = case proplists:get_value(connect_timeout,UserOptions) of
        undefined->
            proplists:get_value(timeout,UserOptions,infinity);
        TO->
            TO
    end,
    case ssh:connect(Host,Port,SshOpts,Timeout) of
        {ok,Cm}->
            case start_channel(Cm,UserOptions) of
                {ok,Pid}->
                    {ok,Pid,Cm};
                Error->
                    Error
            end;
        {error,Timeout}->
            {error,timeout};
        Error->
            Error
    end.

wait_for_version_negotiation(Pid,Timeout) ->
    call(Pid,wait_for_version_negotiation,Timeout).

-spec(stop_channel(ChannelPid) -> ok when ChannelPid::pid()).

stop_channel(Pid) ->
    case is_process_alive(Pid) of
        true->
            MonRef = monitor(process,Pid),
            unlink(Pid),
            exit(Pid,ssh_sftp_stop_channel),
            receive {'DOWN',MonRef,_,_,_}->
                ok after 1000->
                exit(Pid,kill),
                demonitor(MonRef,[flush]),
                ok end;
        false->
            ok
    end.

-spec(open(ChannelPid,Name,Mode) -> {ok,Handle}|Error when ChannelPid::pid(),Name::string(),Mode::[read|write|append|binary|raw],Handle::term(),Error::{error,reason()}).

open(Pid,File,Mode) ->
    open(Pid,File,Mode,infinity).

-spec(open(ChannelPid,Name,Mode,Timeout) -> {ok,Handle}|Error when ChannelPid::pid(),Name::string(),Mode::[read|write|append|binary|raw],Timeout::timeout(),Handle::term(),Error::{error,reason()}).

open(Pid,File,Mode,FileOpTimeout) ->
    call(Pid,{open,false,File,Mode},FileOpTimeout).

-type(tar_crypto_spec()::encrypt_spec()|decrypt_spec()).

-type(encrypt_spec()::{init_fun(),crypto_fun(),final_fun()}).

-type(decrypt_spec()::{init_fun(),crypto_fun()}).

-type(init_fun()::fun(() -> {ok,crypto_state()})|fun(() -> {ok,crypto_state(),chunk_size()})).

-type(crypto_fun()::fun((TextIn::binary(),crypto_state()) -> crypto_result())).

-type(crypto_result()::{ok,TextOut::binary(),crypto_state()}|{ok,TextOut::binary(),crypto_state(),chunk_size()}).

-type(final_fun()::fun((FinalTextIn::binary(),crypto_state()) -> {ok,FinalTextOut::binary()})).

-type(chunk_size()::undefined|pos_integer()).

-type(crypto_state()::any()).

-spec(open_tar(ChannelPid,Path,Mode) -> {ok,Handle}|Error when ChannelPid::pid(),Path::string(),Mode::[read|write|{crypto,tar_crypto_spec()}],Handle::term(),Error::{error,reason()}).

open_tar(Pid,File,Mode) ->
    open_tar(Pid,File,Mode,infinity).

-spec(open_tar(ChannelPid,Path,Mode,Timeout) -> {ok,Handle}|Error when ChannelPid::pid(),Path::string(),Mode::[read|write|{crypto,tar_crypto_spec()}],Timeout::timeout(),Handle::term(),Error::{error,reason()}).

open_tar(Pid,File,Mode,FileOpTimeout) ->
    case {lists:member(write,Mode),lists:member(read,Mode),Mode -- [write, read]} of
        {true,false,[]}->
            {ok,Handle} = open(Pid,File,[write],FileOpTimeout),
            erl_tar:init(Pid,write,fun (write,{_,Data})->
                write_to_remote_tar(Pid,Handle,to_bin(Data),FileOpTimeout);(position,{_,Pos})->
                position(Pid,Handle,Pos,FileOpTimeout);(close,_)->
                close(Pid,Handle,FileOpTimeout) end);
        {true,false,[{crypto,{CryptoInitFun,CryptoEncryptFun,CryptoEndFun}}]}->
            {ok,SftpHandle} = open(Pid,File,[write],FileOpTimeout),
            BI = #bufinf{mode = write,crypto_fun = CryptoEncryptFun},
            {ok,BufHandle} = open_buf(Pid,CryptoInitFun,BI,FileOpTimeout),
            erl_tar:init(Pid,write,fun (write,{_,Data})->
                write_buf(Pid,SftpHandle,BufHandle,to_bin(Data),FileOpTimeout);(position,{_,Pos})->
                position_buf(Pid,SftpHandle,BufHandle,Pos,FileOpTimeout);(close,_)->
                {ok,#bufinf{plain_text_buf = PlainBuf0,enc_text_buf = EncBuf0,crypto_state = CState0}} = call(Pid,{get_bufinf,BufHandle},FileOpTimeout),
                {ok,EncTextTail} = CryptoEndFun(PlainBuf0,CState0),
                EncTextBuf = <<EncBuf0/binary,EncTextTail/binary>>,
                case write(Pid,SftpHandle,EncTextBuf,FileOpTimeout) of
                    ok->
                        call(Pid,{erase_bufinf,BufHandle},FileOpTimeout),
                        close(Pid,SftpHandle,FileOpTimeout);
                    Other->
                        Other
                end end);
        {false,true,[]}->
            {ok,Handle} = open(Pid,File,[read, binary],FileOpTimeout),
            erl_tar:init(Pid,read,fun (read2,{_,Len})->
                read_repeat(Pid,Handle,Len,FileOpTimeout);(position,{_,Pos})->
                position(Pid,Handle,Pos,FileOpTimeout);(close,_)->
                close(Pid,Handle,FileOpTimeout) end);
        {false,true,[{crypto,{CryptoInitFun,CryptoDecryptFun}}]}->
            {ok,SftpHandle} = open(Pid,File,[read, binary],FileOpTimeout),
            BI = #bufinf{mode = read,crypto_fun = CryptoDecryptFun},
            {ok,BufHandle} = open_buf(Pid,CryptoInitFun,BI,FileOpTimeout),
            erl_tar:init(Pid,read,fun (read2,{_,Len})->
                read_buf(Pid,SftpHandle,BufHandle,Len,FileOpTimeout);(position,{_,Pos})->
                position_buf(Pid,SftpHandle,BufHandle,Pos,FileOpTimeout);(close,_)->
                call(Pid,{erase_bufinf,BufHandle},FileOpTimeout),
                close(Pid,SftpHandle,FileOpTimeout) end);
        _->
            {error,{illegal_mode,Mode}}
    end.

-spec(opendir(ChannelPid,Path) -> {ok,Handle}|Error when ChannelPid::pid(),Path::string(),Handle::term(),Error::{error,reason()}).

opendir(Pid,Path) ->
    opendir(Pid,Path,infinity).

-spec(opendir(ChannelPid,Path,Timeout) -> {ok,Handle}|Error when ChannelPid::pid(),Path::string(),Timeout::timeout(),Handle::term(),Error::{error,reason()}).

opendir(Pid,Path,FileOpTimeout) ->
    call(Pid,{opendir,false,Path},FileOpTimeout).

-spec(close(ChannelPid,Handle) -> ok|Error when ChannelPid::pid(),Handle::term(),Error::{error,reason()}).

close(Pid,Handle) ->
    close(Pid,Handle,infinity).

-spec(close(ChannelPid,Handle,Timeout) -> ok|Error when ChannelPid::pid(),Handle::term(),Timeout::timeout(),Error::{error,reason()}).

close(Pid,Handle,FileOpTimeout) ->
    call(Pid,{close,false,Handle},FileOpTimeout).

readdir(Pid,Handle) ->
    readdir(Pid,Handle,infinity).

readdir(Pid,Handle,FileOpTimeout) ->
    call(Pid,{readdir,false,Handle},FileOpTimeout).

-spec(pread(ChannelPid,Handle,Position,Len) -> {ok,Data}|eof|Error when ChannelPid::pid(),Handle::term(),Position::integer(),Len::integer(),Data::string()|binary(),Error::{error,reason()}).

pread(Pid,Handle,Offset,Len) ->
    pread(Pid,Handle,Offset,Len,infinity).

-spec(pread(ChannelPid,Handle,Position,Len,Timeout) -> {ok,Data}|eof|Error when ChannelPid::pid(),Handle::term(),Position::integer(),Len::integer(),Timeout::timeout(),Data::string()|binary(),Error::{error,reason()}).

pread(Pid,Handle,Offset,Len,FileOpTimeout) ->
    call(Pid,{pread,false,Handle,Offset,Len},FileOpTimeout).

-spec(read(ChannelPid,Handle,Len) -> {ok,Data}|eof|Error when ChannelPid::pid(),Handle::term(),Len::integer(),Data::string()|binary(),Error::{error,reason()}).

read(Pid,Handle,Len) ->
    read(Pid,Handle,Len,infinity).

-spec(read(ChannelPid,Handle,Len,Timeout) -> {ok,Data}|eof|Error when ChannelPid::pid(),Handle::term(),Len::integer(),Timeout::timeout(),Data::string()|binary(),Error::{error,reason()}).

read(Pid,Handle,Len,FileOpTimeout) ->
    call(Pid,{read,false,Handle,Len},FileOpTimeout).

-spec(apread(ChannelPid,Handle,Position,Len) -> {async,N}|Error when ChannelPid::pid(),Handle::term(),Position::integer(),Len::integer(),Error::{error,reason()},N::term()).

apread(Pid,Handle,Offset,Len) ->
    call(Pid,{pread,true,Handle,Offset,Len},infinity).

-spec(aread(ChannelPid,Handle,Len) -> {async,N}|Error when ChannelPid::pid(),Handle::term(),Len::integer(),Error::{error,reason()},N::term()).

aread(Pid,Handle,Len) ->
    call(Pid,{read,true,Handle,Len},infinity).

-spec(pwrite(ChannelPid,Handle,Position,Data) -> ok|Error when ChannelPid::pid(),Handle::term(),Position::integer(),Data::iolist(),Error::{error,reason()}).

pwrite(Pid,Handle,Offset,Data) ->
    pwrite(Pid,Handle,Offset,Data,infinity).

-spec(pwrite(ChannelPid,Handle,Position,Data,Timeout) -> ok|Error when ChannelPid::pid(),Handle::term(),Position::integer(),Data::iolist(),Timeout::timeout(),Error::{error,reason()}).

pwrite(Pid,Handle,Offset,Data,FileOpTimeout) ->
    call(Pid,{pwrite,false,Handle,Offset,Data},FileOpTimeout).

-spec(write(ChannelPid,Handle,Data) -> ok|Error when ChannelPid::pid(),Handle::term(),Data::iodata(),Error::{error,reason()}).

write(Pid,Handle,Data) ->
    write(Pid,Handle,Data,infinity).

-spec(write(ChannelPid,Handle,Data,Timeout) -> ok|Error when ChannelPid::pid(),Handle::term(),Data::iodata(),Timeout::timeout(),Error::{error,reason()}).

write(Pid,Handle,Data,FileOpTimeout) ->
    call(Pid,{write,false,Handle,Data},FileOpTimeout).

-spec(apwrite(ChannelPid,Handle,Position,Data) -> {async,N}|Error when ChannelPid::pid(),Handle::term(),Position::integer(),Data::binary(),Error::{error,reason()},N::term()).

apwrite(Pid,Handle,Offset,Data) ->
    call(Pid,{pwrite,true,Handle,Offset,Data},infinity).

-spec(awrite(ChannelPid,Handle,Data) -> {async,N}|Error when ChannelPid::pid(),Handle::term(),Data::binary(),Error::{error,reason()},N::term()).

awrite(Pid,Handle,Data) ->
    call(Pid,{write,true,Handle,Data},infinity).

-spec(position(ChannelPid,Handle,Location) -> {ok,NewPosition}|Error when ChannelPid::pid(),Handle::term(),Location::Offset|{bof,Offset}|{cur,Offset}|{eof,Offset}|bof|cur|eof,Offset::integer(),NewPosition::integer(),Error::{error,reason()}).

position(Pid,Handle,Pos) ->
    position(Pid,Handle,Pos,infinity).

-spec(position(ChannelPid,Handle,Location,Timeout) -> {ok,NewPosition}|Error when ChannelPid::pid(),Handle::term(),Location::Offset|{bof,Offset}|{cur,Offset}|{eof,Offset}|bof|cur|eof,Timeout::timeout(),Offset::integer(),NewPosition::integer(),Error::{error,reason()}).

position(Pid,Handle,Pos,FileOpTimeout) ->
    call(Pid,{position,Handle,Pos},FileOpTimeout).

real_path(Pid,Path) ->
    real_path(Pid,Path,infinity).

real_path(Pid,Path,FileOpTimeout) ->
    call(Pid,{real_path,false,Path},FileOpTimeout).

-spec(read_file_info(ChannelPid,Name) -> {ok,FileInfo}|Error when ChannelPid::pid(),Name::string(),FileInfo::file:file_info(),Error::{error,reason()}).

read_file_info(Pid,Name) ->
    read_file_info(Pid,Name,infinity).

-spec(read_file_info(ChannelPid,Name,Timeout) -> {ok,FileInfo}|Error when ChannelPid::pid(),Name::string(),Timeout::timeout(),FileInfo::file:file_info(),Error::{error,reason()}).

read_file_info(Pid,Name,FileOpTimeout) ->
    call(Pid,{read_file_info,false,Name},FileOpTimeout).

get_file_info(Pid,Handle) ->
    get_file_info(Pid,Handle,infinity).

get_file_info(Pid,Handle,FileOpTimeout) ->
    call(Pid,{get_file_info,false,Handle},FileOpTimeout).

-spec(write_file_info(ChannelPid,Name,FileInfo) -> ok|Error when ChannelPid::pid(),Name::string(),FileInfo::file:file_info(),Error::{error,reason()}).

write_file_info(Pid,Name,Info) ->
    write_file_info(Pid,Name,Info,infinity).

-spec(write_file_info(ChannelPid,Name,FileInfo,Timeout) -> ok|Error when ChannelPid::pid(),Name::string(),FileInfo::file:file_info(),Timeout::timeout(),Error::{error,reason()}).

write_file_info(Pid,Name,Info,FileOpTimeout) ->
    call(Pid,{write_file_info,false,Name,Info},FileOpTimeout).

-spec(read_link_info(ChannelPid,Name) -> {ok,FileInfo}|Error when ChannelPid::pid(),Name::string(),FileInfo::file:file_info(),Error::{error,reason()}).

read_link_info(Pid,Name) ->
    read_link_info(Pid,Name,infinity).

-spec(read_link_info(ChannelPid,Name,Timeout) -> {ok,FileInfo}|Error when ChannelPid::pid(),Name::string(),FileInfo::file:file_info(),Timeout::timeout(),Error::{error,reason()}).

read_link_info(Pid,Name,FileOpTimeout) ->
    call(Pid,{read_link_info,false,Name},FileOpTimeout).

-spec(read_link(ChannelPid,Name) -> {ok,Target}|Error when ChannelPid::pid(),Name::string(),Target::string(),Error::{error,reason()}).

read_link(Pid,LinkName) ->
    read_link(Pid,LinkName,infinity).

-spec(read_link(ChannelPid,Name,Timeout) -> {ok,Target}|Error when ChannelPid::pid(),Name::string(),Target::string(),Timeout::timeout(),Error::{error,reason()}).

read_link(Pid,LinkName,FileOpTimeout) ->
    case call(Pid,{read_link,false,LinkName},FileOpTimeout) of
        {ok,[{Name,_Attrs}]}->
            {ok,Name};
        ErrMsg->
            ErrMsg
    end.

-spec(make_symlink(ChannelPid,Name,Target) -> ok|Error when ChannelPid::pid(),Name::string(),Target::string(),Error::{error,reason()}).

make_symlink(Pid,Name,Target) ->
    make_symlink(Pid,Name,Target,infinity).

-spec(make_symlink(ChannelPid,Name,Target,Timeout) -> ok|Error when ChannelPid::pid(),Name::string(),Target::string(),Timeout::timeout(),Error::{error,reason()}).

make_symlink(Pid,Name,Target,FileOpTimeout) ->
    call(Pid,{make_symlink,false,Name,Target},FileOpTimeout).

-spec(rename(ChannelPid,OldName,NewName) -> ok|Error when ChannelPid::pid(),OldName::string(),NewName::string(),Error::{error,reason()}).

rename(Pid,FromFile,ToFile) ->
    rename(Pid,FromFile,ToFile,infinity).

-spec(rename(ChannelPid,OldName,NewName,Timeout) -> ok|Error when ChannelPid::pid(),OldName::string(),NewName::string(),Timeout::timeout(),Error::{error,reason()}).

rename(Pid,FromFile,ToFile,FileOpTimeout) ->
    call(Pid,{rename,false,FromFile,ToFile},FileOpTimeout).

-spec(delete(ChannelPid,Name) -> ok|Error when ChannelPid::pid(),Name::string(),Error::{error,reason()}).

delete(Pid,Name) ->
    delete(Pid,Name,infinity).

-spec(delete(ChannelPid,Name,Timeout) -> ok|Error when ChannelPid::pid(),Name::string(),Timeout::timeout(),Error::{error,reason()}).

delete(Pid,Name,FileOpTimeout) ->
    call(Pid,{delete,false,Name},FileOpTimeout).

-spec(make_dir(ChannelPid,Name) -> ok|Error when ChannelPid::pid(),Name::string(),Error::{error,reason()}).

make_dir(Pid,Name) ->
    make_dir(Pid,Name,infinity).

-spec(make_dir(ChannelPid,Name,Timeout) -> ok|Error when ChannelPid::pid(),Name::string(),Timeout::timeout(),Error::{error,reason()}).

make_dir(Pid,Name,FileOpTimeout) ->
    call(Pid,{make_dir,false,Name},FileOpTimeout).

-spec(del_dir(ChannelPid,Name) -> ok|Error when ChannelPid::pid(),Name::string(),Error::{error,reason()}).

del_dir(Pid,Name) ->
    del_dir(Pid,Name,infinity).

-spec(del_dir(ChannelPid,Name,Timeout) -> ok|Error when ChannelPid::pid(),Name::string(),Timeout::timeout(),Error::{error,reason()}).

del_dir(Pid,Name,FileOpTimeout) ->
    call(Pid,{del_dir,false,Name},FileOpTimeout).

send_window(Pid) ->
    send_window(Pid,infinity).

send_window(Pid,FileOpTimeout) ->
    call(Pid,send_window,FileOpTimeout).

recv_window(Pid) ->
    recv_window(Pid,infinity).

recv_window(Pid,FileOpTimeout) ->
    call(Pid,recv_window,FileOpTimeout).

-spec(list_dir(ChannelPid,Path) -> {ok,FileNames}|Error when ChannelPid::pid(),Path::string(),FileNames::[FileName],FileName::string(),Error::{error,reason()}).

list_dir(Pid,Name) ->
    list_dir(Pid,Name,infinity).

-spec(list_dir(ChannelPid,Path,Timeout) -> {ok,FileNames}|Error when ChannelPid::pid(),Path::string(),Timeout::timeout(),FileNames::[FileName],FileName::string(),Error::{error,reason()}).

list_dir(Pid,Name,FileOpTimeout) ->
    case opendir(Pid,Name,FileOpTimeout) of
        {ok,Handle}->
            Res = do_list_dir(Pid,Handle,FileOpTimeout,[]),
            close(Pid,Handle,FileOpTimeout),
            case Res of
                {ok,List}->
                    NList = lists:foldl(fun ({Nm,_Info},Acc)->
                        [Nm| Acc] end,[],List),
                    {ok,NList};
                Error->
                    Error
            end;
        Error->
            Error
    end.

do_list_dir(Pid,Handle,FileOpTimeout,Acc) ->
    case readdir(Pid,Handle,FileOpTimeout) of
        {ok,[]}->
            {ok,Acc};
        {ok,Names}->
            do_list_dir(Pid,Handle,FileOpTimeout,Acc ++ Names);
        eof->
            {ok,Acc};
        Error->
            Error
    end.

-spec(read_file(ChannelPid,File) -> {ok,Data}|Error when ChannelPid::pid(),File::string(),Data::binary(),Error::{error,reason()}).

read_file(Pid,Name) ->
    read_file(Pid,Name,infinity).

-spec(read_file(ChannelPid,File,Timeout) -> {ok,Data}|Error when ChannelPid::pid(),File::string(),Data::binary(),Timeout::timeout(),Error::{error,reason()}).

read_file(Pid,Name,FileOpTimeout) ->
    case open(Pid,Name,[read, binary],FileOpTimeout) of
        {ok,Handle}->
            {ok,{_WindowSz,PacketSz}} = recv_window(Pid,FileOpTimeout),
            Res = read_file_loop(Pid,Handle,PacketSz,FileOpTimeout,[]),
            close(Pid,Handle),
            Res;
        Error->
            Error
    end.

read_file_loop(Pid,Handle,PacketSz,FileOpTimeout,Acc) ->
    case read(Pid,Handle,PacketSz,FileOpTimeout) of
        {ok,Data}->
            read_file_loop(Pid,Handle,PacketSz,FileOpTimeout,[Data| Acc]);
        eof->
            {ok,list_to_binary(lists:reverse(Acc))};
        Error->
            Error
    end.

-spec(write_file(ChannelPid,File,Data) -> ok|Error when ChannelPid::pid(),File::string(),Data::iodata(),Error::{error,reason()}).

write_file(Pid,Name,List) ->
    write_file(Pid,Name,List,infinity).

-spec(write_file(ChannelPid,File,Data,Timeout) -> ok|Error when ChannelPid::pid(),File::string(),Data::iodata(),Timeout::timeout(),Error::{error,reason()}).

write_file(Pid,Name,List,FileOpTimeout)
    when is_list(List)->
    write_file(Pid,Name,to_bin(List),FileOpTimeout);
write_file(Pid,Name,Bin,FileOpTimeout) ->
    case open(Pid,Name,[write, binary],FileOpTimeout) of
        {ok,Handle}->
            {ok,{_Window,Packet}} = send_window(Pid,FileOpTimeout),
            Res = write_file_loop(Pid,Handle,0,Bin,size(Bin),Packet,FileOpTimeout),
            close(Pid,Handle,FileOpTimeout),
            Res;
        Error->
            Error
    end.

write_file_loop(_Pid,_Handle,_Pos,_Bin,0,_PacketSz,_FileOpTimeout) ->
    ok;
write_file_loop(Pid,Handle,Pos,Bin,Remain,PacketSz,FileOpTimeout) ->
    if Remain >= PacketSz ->
        <<_:Pos/binary,Data:PacketSz/binary,_/binary>> = Bin,
        case write(Pid,Handle,Data,FileOpTimeout) of
            ok->
                write_file_loop(Pid,Handle,Pos + PacketSz,Bin,Remain - PacketSz,PacketSz,FileOpTimeout);
            Error->
                Error
        end;true ->
        <<_:Pos/binary,Data/binary>> = Bin,
        write(Pid,Handle,Data,FileOpTimeout) end.

init([Cm, ChannelId, Options]) ->
    Timeout = proplists:get_value(timeout,Options,infinity),
    monitor(process,Cm),
    case ssh_connection:subsystem(Cm,ChannelId,"sftp",Timeout) of
        success->
            Xf = #ssh_xfer{cm = Cm,channel = ChannelId},
            {ok,#state{xf = Xf,req_id = 0,rep_buf = <<>>,inf = new_inf(),opts = Options}};
        failure->
            {stop,{shutdown,"server failed to start sftp subsystem"}};
        Error->
            {stop,{shutdown,Error}}
    end.

handle_call({{timeout,infinity},wait_for_version_negotiation},From,#state{xf = #ssh_xfer{vsn = undefined} = Xf} = State) ->
    {noreply,State#state{xf = Xf#ssh_xfer{vsn = {wait,From,undefined}}}};
handle_call({{timeout,Timeout},wait_for_version_negotiation},From,#state{xf = #ssh_xfer{vsn = undefined} = Xf} = State) ->
    TRef = erlang:send_after(Timeout,self(),{timeout,undefined,From}),
    {noreply,State#state{xf = Xf#ssh_xfer{vsn = {wait,From,TRef}}}};
handle_call({_,wait_for_version_negotiation},_,State) ->
    {reply,ok,State};
handle_call({{timeout,infinity},Msg},From,State) ->
    do_handle_call(Msg,From,State);
handle_call({{timeout,Timeout},Msg},From,#state{req_id = Id} = State) ->
    timer:send_after(Timeout,{timeout,Id,From}),
    do_handle_call(Msg,From,State).

handle_cast(_,State) ->
    {noreply,State}.

code_change(_OldVsn,State,_Extra) ->
    {ok,State}.

do_handle_call({get_bufinf,BufHandle},_From,S = #state{inf = I0}) ->
    {reply,maps:find(BufHandle,I0),S};
do_handle_call({put_bufinf,BufHandle,B},_From,S = #state{inf = I0}) ->
    {reply,ok,S#state{inf = maps:put(BufHandle,B,I0)}};
do_handle_call({erase_bufinf,BufHandle},_From,S = #state{inf = I0}) ->
    {reply,ok,S#state{inf = maps:remove(BufHandle,I0)}};
do_handle_call({open,Async,FileName,Mode},From,#state{xf = XF} = State) ->
    {Access,Flags,Attrs} = open_mode(XF#ssh_xfer.vsn,Mode),
    ReqID = State#state.req_id,
    ssh_xfer:open(XF,ReqID,FileName,Access,Flags,Attrs),
    case Async of
        true->
            {reply,{async,ReqID},update_request_info(ReqID,State,fun ({ok,Handle},State1)->
                open2(ReqID,FileName,Handle,Mode,Async,From,State1);(Rep,State1)->
                async_reply(ReqID,Rep,From,State1) end)};
        false->
            {noreply,update_request_info(ReqID,State,fun ({ok,Handle},State1)->
                open2(ReqID,FileName,Handle,Mode,Async,From,State1);(Rep,State1)->
                sync_reply(Rep,From,State1) end)}
    end;
do_handle_call({opendir,Async,Path},From,State) ->
    ReqID = State#state.req_id,
    ssh_xfer:opendir(State#state.xf,ReqID,Path),
    make_reply(ReqID,Async,From,State);
do_handle_call({readdir,Async,Handle},From,State) ->
    ReqID = State#state.req_id,
    ssh_xfer:readdir(State#state.xf,ReqID,Handle),
    make_reply(ReqID,Async,From,State);
do_handle_call({close,_Async,Handle},From,State) ->
    case get_size(Handle,State) of
        undefined->
            ReqID = State#state.req_id,
            ssh_xfer:close(State#state.xf,ReqID,Handle),
            make_reply_post(ReqID,false,From,State,fun (Rep,State1)->
                {Rep,erase_handle(Handle,State1)} end);
        _->
            case lseek_position(Handle,cur,State) of
                {ok,_}->
                    ReqID = State#state.req_id,
                    ssh_xfer:close(State#state.xf,ReqID,Handle),
                    make_reply_post(ReqID,false,From,State,fun (Rep,State1)->
                        {Rep,erase_handle(Handle,State1)} end);
                Error->
                    {reply,Error,State}
            end
    end;
do_handle_call({pread,Async,Handle,At,Length},From,State) ->
    case lseek_position(Handle,At,State) of
        {ok,Offset}->
            ReqID = State#state.req_id,
            ssh_xfer:read(State#state.xf,ReqID,Handle,Offset,Length),
            State1 = update_offset(Handle,Offset + Length,State),
            make_reply_post(ReqID,Async,From,State1,fun ({ok,Data},State2)->
                case get_mode(Handle,State2) of
                    binary->
                        {{ok,Data},State2};
                    text->
                        {{ok,binary_to_list(Data)},State2}
                end;(Rep,State2)->
                {Rep,State2} end);
        Error->
            {reply,Error,State}
    end;
do_handle_call({read,Async,Handle,Length},From,State) ->
    case lseek_position(Handle,cur,State) of
        {ok,Offset}->
            ReqID = State#state.req_id,
            ssh_xfer:read(State#state.xf,ReqID,Handle,Offset,Length),
            State1 = update_offset(Handle,Offset + Length,State),
            make_reply_post(ReqID,Async,From,State1,fun ({ok,Data},State2)->
                case get_mode(Handle,State2) of
                    binary->
                        {{ok,Data},State2};
                    text->
                        {{ok,binary_to_list(Data)},State2}
                end;(Rep,State2)->
                {Rep,State2} end);
        Error->
            {reply,Error,State}
    end;
do_handle_call({pwrite,Async,Handle,At,Data0},From,State) ->
    case lseek_position(Handle,At,State) of
        {ok,Offset}->
            Data = to_bin(Data0),
            ReqID = State#state.req_id,
            Size = size(Data),
            ssh_xfer:write(State#state.xf,ReqID,Handle,Offset,Data),
            State1 = update_size(Handle,Offset + Size,State),
            make_reply(ReqID,Async,From,State1);
        Error->
            {reply,Error,State}
    end;
do_handle_call({write,Async,Handle,Data0},From,State) ->
    case lseek_position(Handle,cur,State) of
        {ok,Offset}->
            Data = to_bin(Data0),
            ReqID = State#state.req_id,
            Size = size(Data),
            ssh_xfer:write(State#state.xf,ReqID,Handle,Offset,Data),
            State1 = update_offset(Handle,Offset + Size,State),
            make_reply(ReqID,Async,From,State1);
        Error->
            {reply,Error,State}
    end;
do_handle_call({position,Handle,At},_From,State) ->
    case lseek_position(Handle,At,State) of
        {ok,Offset}->
            {reply,{ok,Offset},update_offset(Handle,Offset,State)};
        Error->
            {reply,Error,State}
    end;
do_handle_call({rename,Async,FromFile,ToFile},From,State) ->
    ReqID = State#state.req_id,
    ssh_xfer:rename(State#state.xf,ReqID,FromFile,ToFile,[overwrite]),
    make_reply(ReqID,Async,From,State);
do_handle_call({delete,Async,Name},From,State) ->
    ReqID = State#state.req_id,
    ssh_xfer:remove(State#state.xf,ReqID,Name),
    make_reply(ReqID,Async,From,State);
do_handle_call({make_dir,Async,Name},From,State) ->
    ReqID = State#state.req_id,
    ssh_xfer:mkdir(State#state.xf,ReqID,Name,#ssh_xfer_attr{type = directory}),
    make_reply(ReqID,Async,From,State);
do_handle_call({del_dir,Async,Name},From,State) ->
    ReqID = State#state.req_id,
    ssh_xfer:rmdir(State#state.xf,ReqID,Name),
    make_reply(ReqID,Async,From,State);
do_handle_call({real_path,Async,Name},From,State) ->
    ReqID = State#state.req_id,
    ssh_xfer:realpath(State#state.xf,ReqID,Name),
    make_reply(ReqID,Async,From,State);
do_handle_call({read_file_info,Async,Name},From,State) ->
    ReqID = State#state.req_id,
    ssh_xfer:stat(State#state.xf,ReqID,Name,all),
    make_reply(ReqID,Async,From,State);
do_handle_call({get_file_info,Async,Name},From,State) ->
    ReqID = State#state.req_id,
    ssh_xfer:fstat(State#state.xf,ReqID,Name,all),
    make_reply(ReqID,Async,From,State);
do_handle_call({read_link_info,Async,Name},From,State) ->
    ReqID = State#state.req_id,
    ssh_xfer:lstat(State#state.xf,ReqID,Name,all),
    make_reply(ReqID,Async,From,State);
do_handle_call({read_link,Async,Name},From,State) ->
    ReqID = State#state.req_id,
    ssh_xfer:readlink(State#state.xf,ReqID,Name),
    make_reply(ReqID,Async,From,State);
do_handle_call({make_symlink,Async,Path,TargetPath},From,State) ->
    ReqID = State#state.req_id,
    ssh_xfer:symlink(State#state.xf,ReqID,Path,TargetPath),
    make_reply(ReqID,Async,From,State);
do_handle_call({write_file_info,Async,Name,Info},From,State) ->
    ReqID = State#state.req_id,
    A = info_to_attr(Info),
    ssh_xfer:setstat(State#state.xf,ReqID,Name,A),
    make_reply(ReqID,Async,From,State);
do_handle_call(send_window,_From,State) ->
    XF = State#state.xf,
    [{send_window,{{win_size,Size0},{packet_size,Size1}}}] = ssh:channel_info(XF#ssh_xfer.cm,XF#ssh_xfer.channel,[send_window]),
    {reply,{ok,{Size0,Size1}},State};
do_handle_call(recv_window,_From,State) ->
    XF = State#state.xf,
    [{recv_window,{{win_size,Size0},{packet_size,Size1}}}] = ssh:channel_info(XF#ssh_xfer.cm,XF#ssh_xfer.channel,[recv_window]),
    {reply,{ok,{Size0,Size1}},State};
do_handle_call(stop,_From,State) ->
    {stop,shutdown,ok,State};
do_handle_call(Call,_From,State) ->
    {reply,{error,bad_call,Call,State},State}.

handle_ssh_msg({ssh_cm,_ConnectionManager,{data,_ChannelId,0,Data}},#state{rep_buf = Data0} = State0) ->
    State = handle_reply(State0,<<Data0/binary,Data/binary>>),
    {ok,State};
handle_ssh_msg({ssh_cm,_ConnectionManager,{data,_ChannelId,1,Data}},State) ->
    error_logger:format("ssh: STDERR: ~s\n",[binary_to_list(Data)]),
    {ok,State};
handle_ssh_msg({ssh_cm,_ConnectionManager,{eof,_ChannelId}},State) ->
    {ok,State};
handle_ssh_msg({ssh_cm,_,{signal,_,_}},State) ->
    {ok,State};
handle_ssh_msg({ssh_cm,_,{exit_signal,ChannelId,Signal,Error0,_}},State0) ->
    Error = case Error0 of
        ""->
            Signal;
        _->
            Error0
    end,
    State = reply_all(State0,{error,Error}),
    {stop,ChannelId,State};
handle_ssh_msg({ssh_cm,_,{exit_status,ChannelId,Status}},State0) ->
    State = case State0 of
        0->
            State0;
        _->
            reply_all(State0,{error,{exit_status,Status}})
    end,
    {stop,ChannelId,State}.

handle_msg({ssh_channel_up,_,_},#state{opts = Options,xf = Xf} = State) ->
    Version = proplists:get_value(sftp_vsn,Options,6),
    ssh_xfer:protocol_version_request(Xf,Version),
    {ok,State};
handle_msg({timeout,undefined,From},#state{xf = #ssh_xfer{channel = ChannelId}} = State) ->
    ssh_client_channel:reply(From,{error,timeout}),
    {stop,ChannelId,State};
handle_msg({timeout,Id,From},#state{req_list = ReqList0} = State) ->
    case lists:keysearch(Id,1,ReqList0) of
        false->
            {ok,State};
        _->
            ReqList = lists:keydelete(Id,1,ReqList0),
            ssh_client_channel:reply(From,{error,timeout}),
            {ok,State#state{req_list = ReqList}}
    end;
handle_msg({'DOWN',_Ref,_Type,_Process,_},#state{xf = #ssh_xfer{channel = ChannelId}} = State) ->
    {stop,ChannelId,State};
handle_msg({'EXIT',_,ssh_sftp_stop_channel},#state{xf = #ssh_xfer{channel = ChannelId}} = State) ->
    {stop,ChannelId,State};
handle_msg(_,State) ->
    {ok,State}.

terminate(shutdown,#state{xf = #ssh_xfer{cm = Cm}} = State) ->
    reply_all(State,{error,closed}),
    ssh:close(Cm);
terminate(_Reason,State) ->
    reply_all(State,{error,closed}).

handle_options(UserOptions) ->
    handle_options(UserOptions,[],[],[]).

handle_options([],Sftp,Chan,Ssh) ->
    {Ssh,Chan,Sftp};
handle_options([{timeout,_} = Opt| Rest],Sftp,Chan,Ssh) ->
    handle_options(Rest,[Opt| Sftp],Chan,Ssh);
handle_options([{sftp_vsn,_} = Opt| Rest],Sftp,Chan,Ssh) ->
    handle_options(Rest,[Opt| Sftp],Chan,Ssh);
handle_options([{window_size,_} = Opt| Rest],Sftp,Chan,Ssh) ->
    handle_options(Rest,Sftp,[Opt| Chan],Ssh);
handle_options([{packet_size,_} = Opt| Rest],Sftp,Chan,Ssh) ->
    handle_options(Rest,Sftp,[Opt| Chan],Ssh);
handle_options([Opt| Rest],Sftp,Chan,Ssh) ->
    handle_options(Rest,Sftp,Chan,[Opt| Ssh]).

call(Pid,Msg,TimeOut) ->
    ssh_client_channel:call(Pid,{{timeout,TimeOut},Msg},infinity).

handle_reply(State,<<Len:32/unsigned-big-integer,Reply:Len/binary,Rest/binary>>) ->
    do_handle_reply(State,Reply,Rest);
handle_reply(State,Data) ->
    State#state{rep_buf = Data}.

do_handle_reply(#state{xf = Xf} = State,<<2,Version:32/unsigned-big-integer,BinExt/binary>>,Rest) ->
    Ext = ssh_xfer:decode_ext(BinExt),
    case Xf#ssh_xfer.vsn of
        undefined->
            ok;
        {wait,From,TRef}->
            if is_reference(TRef) ->
                erlang:cancel_timer(TRef);true ->
                ok end,
            ssh_client_channel:reply(From,ok)
    end,
    State#state{xf = Xf#ssh_xfer{vsn = Version,ext = Ext},rep_buf = Rest};
do_handle_reply(State0,Data,Rest) ->
    case  catch ssh_xfer:xf_reply(State0#state.xf,Data) of
        {'EXIT',_Reason}->
            handle_reply(State0,Rest);
        XfReply->
            State = handle_req_reply(State0,XfReply),
            handle_reply(State,Rest)
    end.

handle_req_reply(State0,{_,ReqID,_} = XfReply) ->
    case lists:keysearch(ReqID,1,State0#state.req_list) of
        false->
            State0;
        {value,{_,Fun}}->
            List = lists:keydelete(ReqID,1,State0#state.req_list),
            State1 = State0#state{req_list = List},
            case  catch Fun(xreply(XfReply),State1) of
                {'EXIT',_}->
                    State1;
                State->
                    State
            end
    end.

xreply({handle,_,H}) ->
    {ok,H};
xreply({data,_,Data}) ->
    {ok,Data};
xreply({name,_,Names}) ->
    {ok,Names};
xreply({attrs,_,A}) ->
    {ok,attr_to_info(A)};
xreply({extended_reply,_,X}) ->
    {ok,X};
xreply({status,_,{ok,_Err,_Lang,_Rep}}) ->
    ok;
xreply({status,_,{eof,_Err,_Lang,_Rep}}) ->
    eof;
xreply({status,_,{Stat,_Err,_Lang,_Rep}}) ->
    {error,Stat};
xreply({Code,_,Reply}) ->
    {Code,Reply}.

update_request_info(ReqID,State,Fun) ->
    List = [{ReqID,Fun}| State#state.req_list],
    ID = (State#state.req_id + 1) band 4294967295,
    State#state{req_list = List,req_id = ID}.

async_reply(ReqID,Reply,_From = {To,_},State) ->
    To ! {async_reply,ReqID,Reply},
    State.

sync_reply(Reply,From,State) ->
     catch ssh_client_channel:reply(From,Reply),
    State.

open2(OrigReqID,FileName,Handle,Mode,Async,From,State) ->
    I0 = State#state.inf,
    FileMode = case lists:member(binary,Mode) orelse lists:member(raw,Mode) of
        true->
            binary;
        false->
            text
    end,
    I1 = add_new_handle(Handle,FileMode,I0),
    State0 = State#state{inf = I1},
    ReqID = State0#state.req_id,
    ssh_xfer:stat(State0#state.xf,ReqID,FileName,[size]),
    case Async of
        true->
            update_request_info(ReqID,State0,fun ({ok,FI},State1)->
                Size = FI#file_info.size,
                State2 = if is_integer(Size) ->
                    put_size(Handle,Size,State1);true ->
                    State1 end,
                async_reply(OrigReqID,{ok,Handle},From,State2);(_,State1)->
                async_reply(OrigReqID,{ok,Handle},From,State1) end);
        false->
            update_request_info(ReqID,State0,fun ({ok,FI},State1)->
                Size = FI#file_info.size,
                State2 = if is_integer(Size) ->
                    put_size(Handle,Size,State1);true ->
                    State1 end,
                sync_reply({ok,Handle},From,State2);(_,State1)->
                sync_reply({ok,Handle},From,State1) end)
    end.

reply_all(State,Reply) ->
    List = State#state.req_list,
    lists:foreach(fun ({_ReqID,Fun})->
         catch Fun(Reply,State) end,List),
    State#state{req_list = []}.

make_reply(ReqID,true,From,State) ->
    {reply,{async,ReqID},update_request_info(ReqID,State,fun (Reply,State1)->
        async_reply(ReqID,Reply,From,State1) end)};
make_reply(ReqID,false,From,State) ->
    {noreply,update_request_info(ReqID,State,fun (Reply,State1)->
        sync_reply(Reply,From,State1) end)}.

make_reply_post(ReqID,true,From,State,PostFun) ->
    {reply,{async,ReqID},update_request_info(ReqID,State,fun (Reply,State1)->
        case  catch PostFun(Reply,State1) of
            {'EXIT',_}->
                async_reply(ReqID,Reply,From,State1);
            {Reply1,State2}->
                async_reply(ReqID,Reply1,From,State2)
        end end)};
make_reply_post(ReqID,false,From,State,PostFun) ->
    {noreply,update_request_info(ReqID,State,fun (Reply,State1)->
        case  catch PostFun(Reply,State1) of
            {'EXIT',_}->
                sync_reply(Reply,From,State1);
            {Reply1,State2}->
                sync_reply(Reply1,From,State2)
        end end)}.

info_to_attr(I)
    when is_record(I,file_info)->
    #ssh_xfer_attr{permissions = I#file_info.mode,size = I#file_info.size,type = I#file_info.type,owner = I#file_info.uid,group = I#file_info.gid,atime = datetime_to_unix(I#file_info.atime),mtime = datetime_to_unix(I#file_info.mtime),createtime = datetime_to_unix(I#file_info.ctime)}.

attr_to_info(A)
    when is_record(A,ssh_xfer_attr)->
    #file_info{size = A#ssh_xfer_attr.size,type = A#ssh_xfer_attr.type,access = file_mode_to_owner_access(A#ssh_xfer_attr.permissions),atime = unix_to_datetime(A#ssh_xfer_attr.atime),mtime = unix_to_datetime(A#ssh_xfer_attr.mtime),ctime = unix_to_datetime(A#ssh_xfer_attr.createtime),mode = A#ssh_xfer_attr.permissions,links = 1,major_device = 0,minor_device = 0,inode = 0,uid = A#ssh_xfer_attr.owner,gid = A#ssh_xfer_attr.group}.

file_mode_to_owner_access(FileMode)
    when is_integer(FileMode)->
    ReadPermission = (FileMode bsr 8) band 1,
    WritePermission = (FileMode bsr 7) band 1,
    case {ReadPermission,WritePermission} of
        {1,1}->
            read_write;
        {1,0}->
            read;
        {0,1}->
            write;
        {0,0}->
            none;
        _->
            undefined
    end;
file_mode_to_owner_access(_) ->
    undefined.

unix_to_datetime(undefined) ->
    undefined;
unix_to_datetime(UTCSecs) ->
    UTCDateTime = calendar:gregorian_seconds_to_datetime(UTCSecs + 62167219200),
    erlang:universaltime_to_localtime(UTCDateTime).

datetime_to_unix(undefined) ->
    undefined;
datetime_to_unix(LocalDateTime) ->
    UTCDateTime = erlang:localtime_to_universaltime(LocalDateTime),
    calendar:datetime_to_gregorian_seconds(UTCDateTime) - 62167219200.

open_mode(Vsn,Modes)
    when Vsn >= 5->
    open_mode5(Modes);
open_mode(_Vsn,Modes) ->
    open_mode3(Modes).

open_mode5(Modes) ->
    A = #ssh_xfer_attr{type = regular},
    {Fl,Ac} = case {lists:member(write,Modes),lists:member(read,Modes),lists:member(append,Modes)} of
        {_,_,true}->
            {[append_data],[read_attributes, append_data, write_attributes]};
        {true,false,false}->
            {[create_truncate],[write_data, write_attributes]};
        {true,true,_}->
            {[open_or_create],[read_data, read_attributes, write_data, write_attributes]};
        {false,true,_}->
            {[open_existing],[read_data, read_attributes]}
    end,
    {Ac,Fl,A}.

open_mode3(Modes) ->
    A = #ssh_xfer_attr{type = regular},
    Fl = case {lists:member(write,Modes),lists:member(read,Modes),lists:member(append,Modes)} of
        {_,_,true}->
            [append];
        {true,false,false}->
            [write, creat, trunc];
        {true,true,_}->
            [read, write];
        {false,true,_}->
            [read]
    end,
    {[],Fl,A}.

new_inf() ->
    #{}.

add_new_handle(Handle,FileMode,Inf) ->
    maps:put(Handle,#fileinf{offset = 0,size = 0,mode = FileMode},Inf).

update_size(Handle,NewSize,State) ->
    OldSize = get_size(Handle,State),
    if NewSize > OldSize ->
        put_size(Handle,NewSize,State);true ->
        State end.

update_offset(Handle,NewOffset,State0) ->
    State1 = put_offset(Handle,NewOffset,State0),
    update_size(Handle,NewOffset,State1).

put_size(Handle,Size,State) ->
    Inf0 = State#state.inf,
    case maps:find(Handle,Inf0) of
        {ok,FI}->
            State#state{inf = maps:put(Handle,FI#fileinf{size = Size},Inf0)};
        _->
            State#state{inf = maps:put(Handle,#fileinf{size = Size,offset = 0},Inf0)}
    end.

put_offset(Handle,Offset,State) ->
    Inf0 = State#state.inf,
    case maps:find(Handle,Inf0) of
        {ok,FI}->
            State#state{inf = maps:put(Handle,FI#fileinf{offset = Offset},Inf0)};
        _->
            State#state{inf = maps:put(Handle,#fileinf{size = Offset,offset = Offset},Inf0)}
    end.

get_size(Handle,State) ->
    case maps:find(Handle,State#state.inf) of
        {ok,FI}->
            FI#fileinf.size;
        _->
            undefined
    end.

get_mode(Handle,State) ->
    case maps:find(Handle,State#state.inf) of
        {ok,FI}->
            FI#fileinf.mode;
        _->
            undefined
    end.

erase_handle(Handle,State) ->
    FI = maps:remove(Handle,State#state.inf),
    State#state{inf = FI}.

lseek_position(Handle,Pos,State) ->
    case maps:find(Handle,State#state.inf) of
        {ok,#fileinf{offset = O,size = S}}->
            lseek_pos(Pos,O,S);
        _->
            {error,einval}
    end.

lseek_pos(_Pos,undefined,_) ->
    {error,einval};
lseek_pos(Pos,_CurOffset,_CurSize)
    when is_integer(Pos) andalso 0 =< Pos andalso Pos < 1 bsl 63->
    {ok,Pos};
lseek_pos(bof,_CurOffset,_CurSize) ->
    {ok,0};
lseek_pos(cur,CurOffset,_CurSize) ->
    {ok,CurOffset};
lseek_pos(eof,_CurOffset,CurSize) ->
    {ok,CurSize};
lseek_pos({bof,Offset},_CurOffset,_CurSize)
    when is_integer(Offset) andalso 0 =< Offset andalso Offset < 1 bsl 63->
    {ok,Offset};
lseek_pos({cur,Offset},CurOffset,_CurSize)
    when is_integer(Offset) andalso -(1 bsl 63) =< Offset andalso Offset < 1 bsl 63->
    NewOffset = CurOffset + Offset,
    if NewOffset < 0 ->
        {ok,0};true ->
        {ok,NewOffset} end;
lseek_pos({eof,Offset},_CurOffset,CurSize)
    when is_integer(Offset) andalso -(1 bsl 63) =< Offset andalso Offset < 1 bsl 63->
    NewOffset = CurSize + Offset,
    if NewOffset < 0 ->
        {ok,0};true ->
        {ok,NewOffset} end;
lseek_pos(_,_,_) ->
    {error,einval}.

to_bin(Data)
    when is_list(Data)->
    try iolist_to_binary(Data)
        catch
            _:_->
                unicode:characters_to_binary(Data) end;
to_bin(Data)
    when is_binary(Data)->
    Data.

read_repeat(Pid,Handle,Len,FileOpTimeout) ->
    {ok,{_WindowSz,PacketSz}} = recv_window(Pid,FileOpTimeout),
    read_rpt(Pid,Handle,Len,PacketSz,FileOpTimeout,<<>>).

read_rpt(Pid,Handle,WantedLen,PacketSz,FileOpTimeout,Acc)
    when WantedLen > 0->
    case read(Pid,Handle,min(WantedLen,PacketSz),FileOpTimeout) of
        {ok,Data}->
            read_rpt(Pid,Handle,WantedLen - size(Data),PacketSz,FileOpTimeout,<<Acc/binary,Data/binary>>);
        eof->
            {ok,Acc};
        Error->
            Error
    end;
read_rpt(_Pid,_Handle,WantedLen,_PacketSz,_FileOpTimeout,Acc)
    when WantedLen >= 0->
    {ok,Acc}.

write_to_remote_tar(_Pid,_SftpHandle,<<>>,_FileOpTimeout) ->
    ok;
write_to_remote_tar(Pid,SftpHandle,Bin,FileOpTimeout) ->
    {ok,{_Window,Packet}} = send_window(Pid,FileOpTimeout),
    write_file_loop(Pid,SftpHandle,0,Bin,size(Bin),Packet,FileOpTimeout).

position_buf(Pid,SftpHandle,BufHandle,Pos,FileOpTimeout) ->
    {ok,#bufinf{mode = Mode,plain_text_buf = Buf0,size = Size}} = call(Pid,{get_bufinf,BufHandle},FileOpTimeout),
    case Pos of
        {cur,0}
            when Mode == write->
            {ok,Size + size(Buf0)};
        {cur,0}
            when Mode == read->
            {ok,Size};
        _
            when Mode == read,
            is_integer(Pos)->
            Skip = Pos - Size,
            if Skip < 0 ->
                {error,cannot_rewind};Skip == 0 ->
                {ok,Pos};Skip > 0 ->
                case read_buf(Pid,SftpHandle,BufHandle,Skip,FileOpTimeout) of
                    {ok,_}->
                        {ok,Pos};
                    Other->
                        Other
                end end;
        _->
            {error,{not_yet_implemented,{pos,Pos}}}
    end.

read_buf(Pid,SftpHandle,BufHandle,WantedLen,FileOpTimeout) ->
    {ok,{_Window,Packet}} = send_window(Pid,FileOpTimeout),
    {ok,B0} = call(Pid,{get_bufinf,BufHandle},FileOpTimeout),
    case do_the_read_buf(Pid,SftpHandle,WantedLen,Packet,FileOpTimeout,B0) of
        {ok,ResultBin,B}->
            call(Pid,{put_bufinf,BufHandle,B},FileOpTimeout),
            {ok,ResultBin};
        {error,Error}->
            {error,Error};
        {eof,B}->
            call(Pid,{put_bufinf,BufHandle,B},FileOpTimeout),
            eof
    end.

do_the_read_buf(_Pid,_SftpHandle,WantedLen,_Packet,_FileOpTimeout,B = #bufinf{plain_text_buf = PlainBuf0,size = Size})
    when size(PlainBuf0) >= WantedLen->
    <<ResultBin:WantedLen/binary,PlainBuf/binary>> = PlainBuf0,
    {ok,ResultBin,B#bufinf{plain_text_buf = PlainBuf,size = Size + WantedLen}};
do_the_read_buf(Pid,SftpHandle,WantedLen,Packet,FileOpTimeout,B0 = #bufinf{plain_text_buf = PlainBuf0,enc_text_buf = EncBuf0,chunksize = undefined})
    when size(EncBuf0) > 0->
    {ok,DecodedBin,B} = apply_crypto(EncBuf0,B0),
    do_the_read_buf(Pid,SftpHandle,WantedLen,Packet,FileOpTimeout,B#bufinf{plain_text_buf = <<PlainBuf0/binary,DecodedBin/binary>>,enc_text_buf = <<>>});
do_the_read_buf(Pid,SftpHandle,WantedLen,Packet,FileOpTimeout,B0 = #bufinf{plain_text_buf = PlainBuf0,enc_text_buf = EncBuf0,chunksize = ChunkSize0})
    when size(EncBuf0) >= ChunkSize0->
    <<ToDecode:ChunkSize0/binary,EncBuf/binary>> = EncBuf0,
    {ok,DecodedBin,B} = apply_crypto(ToDecode,B0),
    do_the_read_buf(Pid,SftpHandle,WantedLen,Packet,FileOpTimeout,B#bufinf{plain_text_buf = <<PlainBuf0/binary,DecodedBin/binary>>,enc_text_buf = EncBuf});
do_the_read_buf(Pid,SftpHandle,WantedLen,Packet,FileOpTimeout,B = #bufinf{enc_text_buf = EncBuf0}) ->
    case read(Pid,SftpHandle,Packet,FileOpTimeout) of
        {ok,EncryptedBin}->
            do_the_read_buf(Pid,SftpHandle,WantedLen,Packet,FileOpTimeout,B#bufinf{enc_text_buf = <<EncBuf0/binary,EncryptedBin/binary>>});
        eof->
            {eof,B};
        Other->
            Other
    end.

write_buf(Pid,SftpHandle,BufHandle,PlainBin,FileOpTimeout) ->
    {ok,{_Window,Packet}} = send_window(Pid,FileOpTimeout),
    {ok,B0 = #bufinf{plain_text_buf = PTB}} = call(Pid,{get_bufinf,BufHandle},FileOpTimeout),
    case do_the_write_buf(Pid,SftpHandle,Packet,FileOpTimeout,B0#bufinf{plain_text_buf = <<PTB/binary,PlainBin/binary>>}) of
        {ok,B}->
            call(Pid,{put_bufinf,BufHandle,B},FileOpTimeout),
            ok;
        {error,Error}->
            {error,Error}
    end.

do_the_write_buf(Pid,SftpHandle,Packet,FileOpTimeout,B = #bufinf{enc_text_buf = EncBuf0,size = Size})
    when size(EncBuf0) >= Packet->
    <<BinToWrite:Packet/binary,EncBuf/binary>> = EncBuf0,
    case write(Pid,SftpHandle,BinToWrite,FileOpTimeout) of
        ok->
            do_the_write_buf(Pid,SftpHandle,Packet,FileOpTimeout,B#bufinf{enc_text_buf = EncBuf,size = Size + Packet});
        Other->
            Other
    end;
do_the_write_buf(Pid,SftpHandle,Packet,FileOpTimeout,B0 = #bufinf{plain_text_buf = PlainBuf0,enc_text_buf = EncBuf0,chunksize = undefined})
    when size(PlainBuf0) > 0->
    {ok,EncodedBin,B} = apply_crypto(PlainBuf0,B0),
    do_the_write_buf(Pid,SftpHandle,Packet,FileOpTimeout,B#bufinf{plain_text_buf = <<>>,enc_text_buf = <<EncBuf0/binary,EncodedBin/binary>>});
do_the_write_buf(Pid,SftpHandle,Packet,FileOpTimeout,B0 = #bufinf{plain_text_buf = PlainBuf0,enc_text_buf = EncBuf0,chunksize = ChunkSize0})
    when size(PlainBuf0) >= ChunkSize0->
    <<ToEncode:ChunkSize0/binary,PlainBuf/binary>> = PlainBuf0,
    {ok,EncodedBin,B} = apply_crypto(ToEncode,B0),
    do_the_write_buf(Pid,SftpHandle,Packet,FileOpTimeout,B#bufinf{plain_text_buf = PlainBuf,enc_text_buf = <<EncBuf0/binary,EncodedBin/binary>>});
do_the_write_buf(_Pid,_SftpHandle,_Packet,_FileOpTimeout,B) ->
    {ok,B}.

apply_crypto(In,B = #bufinf{crypto_state = CState0,crypto_fun = F}) ->
    case F(In,CState0) of
        {ok,EncodedBin,CState}->
            {ok,EncodedBin,B#bufinf{crypto_state = CState}};
        {ok,EncodedBin,CState,ChunkSize}->
            {ok,EncodedBin,B#bufinf{crypto_state = CState,chunksize = ChunkSize}}
    end.

open_buf(Pid,CryptoInitFun,BufInfo0,FileOpTimeout) ->
    case CryptoInitFun() of
        {ok,CryptoState}->
            open_buf1(Pid,BufInfo0,FileOpTimeout,CryptoState,undefined);
        {ok,CryptoState,ChunkSize}->
            open_buf1(Pid,BufInfo0,FileOpTimeout,CryptoState,ChunkSize);
        Other->
            Other
    end.

open_buf1(Pid,BufInfo0,FileOpTimeout,CryptoState,ChunkSize) ->
    BufInfo = BufInfo0#bufinf{crypto_state = CryptoState,chunksize = ChunkSize},
    BufHandle = make_ref(),
    call(Pid,{put_bufinf,BufHandle,BufInfo},FileOpTimeout),
    {ok,BufHandle}.

format_channel_start_error({shutdown,Reason}) ->
    Reason;
format_channel_start_error(Reason) ->
    Reason.

ssh_dbg_trace_points() ->
    [terminate].

ssh_dbg_flags(terminate) ->
    [c].

ssh_dbg_on(terminate) ->
    dbg:tp(ssh_sftp,terminate,2,x).

ssh_dbg_off(terminate) ->
    dbg:ctpg(ssh_sftp,terminate,2).

ssh_dbg_format(terminate,{call,{ssh_sftp,terminate,[Reason, State]}}) ->
    ["Sftp Terminating:\n", io_lib:format("Reason: ~p,~nState:~n~s",[Reason, wr_record(State)])];
ssh_dbg_format(terminate,{return_from,{ssh_sftp,terminate,2},_Ret}) ->
    skip.

wr_record(R = #state{}) ->
    ssh_dbg:wr_record(R,record_info(fields,state),[]).
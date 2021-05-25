-file("ssh.erl", 1).

-module(ssh).

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

-file("ssh.erl", 26).

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

-file("ssh.erl", 27).

-file("/usr/lib/erlang/lib/public_key-1.9.2/include/public_key.hrl", 1).

-file("/usr/lib/erlang/lib/public_key-1.9.2/include/OTP-PUB-KEY.hrl", 1).

-record('AlgorithmIdentifier-PKCS1', {algorithm,parameters = asn1_NOVALUE}).

-record('AttributePKCS-7', {type,values}).

-record('AlgorithmIdentifierPKCS-7', {algorithm,parameters = asn1_NOVALUE}).

-record('AlgorithmIdentifierPKCS-10', {algorithm,parameters = asn1_NOVALUE}).

-record('AttributePKCS-10', {type,values}).

-record('SubjectPublicKeyInfo-PKCS-10', {algorithm,subjectPublicKey}).

-record('ECPrivateKey', {version,privateKey,parameters = asn1_NOVALUE,publicKey = asn1_NOVALUE}).

-record('DSAPrivateKey', {version,p,q,g,y,x}).

-record('DHParameter', {prime,base,privateValueLength = asn1_NOVALUE}).

-record('DigestAlgorithm', {algorithm,parameters = asn1_NOVALUE}).

-record('DigestInfoPKCS-1', {digestAlgorithm,digest}).

-record('RSASSA-AlgorithmIdentifier', {algorithm,parameters = asn1_NOVALUE}).

-record('RSASSA-PSS-params', {hashAlgorithm = asn1_DEFAULT,maskGenAlgorithm = asn1_DEFAULT,saltLength = asn1_DEFAULT,trailerField = asn1_DEFAULT}).

-record('RSAES-AlgorithmIdentifier', {algorithm,parameters = asn1_NOVALUE}).

-record('RSAES-OAEP-params', {hashAlgorithm = asn1_DEFAULT,maskGenAlgorithm = asn1_DEFAULT,pSourceAlgorithm = asn1_DEFAULT}).

-record('OtherPrimeInfo', {prime,exponent,coefficient}).

-record('RSAPrivateKey', {version,modulus,publicExponent,privateExponent,prime1,prime2,exponent1,exponent2,coefficient,otherPrimeInfos = asn1_NOVALUE}).

-record('RSAPublicKey', {modulus,publicExponent}).

-record('PSourceAlgorithm', {algorithm,parameters = asn1_NOVALUE}).

-record('MaskGenAlgorithm', {algorithm,parameters = asn1_NOVALUE}).

-record('HashAlgorithm', {algorithm,parameters = asn1_NOVALUE}).

-record('Curve', {a,b,seed = asn1_NOVALUE}).

-record('ECParameters', {version,fieldID,curve,base,order,cofactor = asn1_NOVALUE}).

-record('Pentanomial', {k1,k2,k3}).

-record('Characteristic-two', {m,basis,parameters}).

-record('ECDSA-Sig-Value', {r,s}).

-record('FieldID', {fieldType,parameters}).

-record('ValidationParms', {seed,pgenCounter}).

-record('DomainParameters', {p,g,q,j = asn1_NOVALUE,validationParms = asn1_NOVALUE}).

-record('Dss-Sig-Value', {r,s}).

-record('Dss-Parms', {p,q,g}).

-record('ACClearAttrs', {acIssuer,acSerial,attrs}).

-record('AAControls', {pathLenConstraint = asn1_NOVALUE,permittedAttrs = asn1_NOVALUE,excludedAttrs = asn1_NOVALUE,permitUnSpecified = asn1_DEFAULT}).

-record('SecurityCategory', {type,value}).

-record('Clearance', {policyId,classList = asn1_DEFAULT,securityCategories = asn1_NOVALUE}).

-record('RoleSyntax', {roleAuthority = asn1_NOVALUE,roleName}).

-record('SvceAuthInfo', {service,ident,authInfo = asn1_NOVALUE}).

-record('IetfAttrSyntax', {policyAuthority = asn1_NOVALUE,values}).

-record('TargetCert', {targetCertificate,targetName = asn1_NOVALUE,certDigestInfo = asn1_NOVALUE}).

-record('AttCertValidityPeriod', {notBeforeTime,notAfterTime}).

-record('IssuerSerial', {issuer,serial,issuerUID = asn1_NOVALUE}).

-record('V2Form', {issuerName = asn1_NOVALUE,baseCertificateID = asn1_NOVALUE,objectDigestInfo = asn1_NOVALUE}).

-record('ObjectDigestInfo', {digestedObjectType,otherObjectTypeID = asn1_NOVALUE,digestAlgorithm,objectDigest}).

-record('Holder', {baseCertificateID = asn1_NOVALUE,entityName = asn1_NOVALUE,objectDigestInfo = asn1_NOVALUE}).

-record('AttributeCertificateInfo', {version,holder,issuer,signature,serialNumber,attrCertValidityPeriod,attributes,issuerUniqueID = asn1_NOVALUE,extensions = asn1_NOVALUE}).

-record('AttributeCertificate', {acinfo,signatureAlgorithm,signatureValue}).

-record('IssuingDistributionPoint', {distributionPoint = asn1_NOVALUE,onlyContainsUserCerts = asn1_DEFAULT,onlyContainsCACerts = asn1_DEFAULT,onlySomeReasons = asn1_NOVALUE,indirectCRL = asn1_DEFAULT,onlyContainsAttributeCerts = asn1_DEFAULT}).

-record('AccessDescription', {accessMethod,accessLocation}).

-record('DistributionPoint', {distributionPoint = asn1_NOVALUE,reasons = asn1_NOVALUE,cRLIssuer = asn1_NOVALUE}).

-record('PolicyConstraints', {requireExplicitPolicy = asn1_NOVALUE,inhibitPolicyMapping = asn1_NOVALUE}).

-record('GeneralSubtree', {base,minimum = asn1_DEFAULT,maximum = asn1_NOVALUE}).

-record('NameConstraints', {permittedSubtrees = asn1_NOVALUE,excludedSubtrees = asn1_NOVALUE}).

-record('BasicConstraints', {cA = asn1_DEFAULT,pathLenConstraint = asn1_NOVALUE}).

-record('EDIPartyName', {nameAssigner = asn1_NOVALUE,partyName}).

-record('AnotherName', {type-id,value}).

-record('PolicyMappings_SEQOF', {issuerDomainPolicy,subjectDomainPolicy}).

-record('NoticeReference', {organization,noticeNumbers}).

-record('UserNotice', {noticeRef = asn1_NOVALUE,explicitText = asn1_NOVALUE}).

-record('PolicyQualifierInfo', {policyQualifierId,qualifier}).

-record('PolicyInformation', {policyIdentifier,policyQualifiers = asn1_NOVALUE}).

-record('PrivateKeyUsagePeriod', {notBefore = asn1_NOVALUE,notAfter = asn1_NOVALUE}).

-record('AuthorityKeyIdentifier', {keyIdentifier = asn1_NOVALUE,authorityCertIssuer = asn1_NOVALUE,authorityCertSerialNumber = asn1_NOVALUE}).

-record('EncryptedData', {version,encryptedContentInfo}).

-record('DigestedData', {version,digestAlgorithm,contentInfo,digest}).

-record('SignedAndEnvelopedData', {version,recipientInfos,digestAlgorithms,encryptedContentInfo,certificates = asn1_NOVALUE,crls = asn1_NOVALUE,signerInfos}).

-record('RecipientInfo', {version,issuerAndSerialNumber,keyEncryptionAlgorithm,encryptedKey}).

-record('EncryptedContentInfo', {contentType,contentEncryptionAlgorithm,encryptedContent = asn1_NOVALUE}).

-record('EnvelopedData', {version,recipientInfos,encryptedContentInfo}).

-record('DigestInfoPKCS-7', {digestAlgorithm,digest}).

-record('SignerInfo', {version,issuerAndSerialNumber,digestAlgorithm,authenticatedAttributes = asn1_NOVALUE,digestEncryptionAlgorithm,encryptedDigest,unauthenticatedAttributes = asn1_NOVALUE}).

-record('SignerInfo_unauthenticatedAttributes_uaSet_SETOF', {type,values}).

-record('SignerInfo_unauthenticatedAttributes_uaSequence_SEQOF', {type,values}).

-record('SignedData', {version,digestAlgorithms,contentInfo,certificates = asn1_NOVALUE,crls = asn1_NOVALUE,signerInfos}).

-record('ContentInfo', {contentType,content = asn1_NOVALUE}).

-record('KeyEncryptionAlgorithmIdentifier', {algorithm,parameters = asn1_NOVALUE}).

-record('IssuerAndSerialNumber', {issuer,serialNumber}).

-record('DigestEncryptionAlgorithmIdentifier', {algorithm,parameters = asn1_NOVALUE}).

-record('DigestAlgorithmIdentifier', {algorithm,parameters = asn1_NOVALUE}).

-record('ContentEncryptionAlgorithmIdentifier', {algorithm,parameters = asn1_NOVALUE}).

-record('SignerInfoAuthenticatedAttributes_aaSet_SETOF', {type,values}).

-record('SignerInfoAuthenticatedAttributes_aaSequence_SEQOF', {type,values}).

-record('CertificationRequest', {certificationRequestInfo,signatureAlgorithm,signature}).

-record('CertificationRequest_signatureAlgorithm', {algorithm,parameters = asn1_NOVALUE}).

-record('CertificationRequestInfo', {version,subject,subjectPKInfo,attributes}).

-record('CertificationRequestInfo_subjectPKInfo', {algorithm,subjectPublicKey}).

-record('CertificationRequestInfo_subjectPKInfo_algorithm', {algorithm,parameters = asn1_NOVALUE}).

-record('CertificationRequestInfo_attributes_SETOF', {type,values}).

-record('PreferredSignatureAlgorithm', {sigIdentifier,certIdentifier = asn1_NOVALUE}).

-record('CrlID', {crlUrl = asn1_NOVALUE,crlNum = asn1_NOVALUE,crlTime = asn1_NOVALUE}).

-record('ServiceLocator', {issuer,locator}).

-record('RevokedInfo', {revocationTime,revocationReason = asn1_NOVALUE}).

-record('SingleResponse', {certID,certStatus,thisUpdate,nextUpdate = asn1_NOVALUE,singleExtensions = asn1_NOVALUE}).

-record('ResponseData', {version = asn1_DEFAULT,responderID,producedAt,responses,responseExtensions = asn1_NOVALUE}).

-record('BasicOCSPResponse', {tbsResponseData,signatureAlgorithm,signature,certs = asn1_NOVALUE}).

-record('ResponseBytes', {responseType,response}).

-record('OCSPResponse', {responseStatus,responseBytes = asn1_NOVALUE}).

-record('CertID', {hashAlgorithm,issuerNameHash,issuerKeyHash,serialNumber}).

-record('Request', {reqCert,singleRequestExtensions = asn1_NOVALUE}).

-record('Signature', {signatureAlgorithm,signature,certs = asn1_NOVALUE}).

-record('TBSRequest', {version = asn1_DEFAULT,requestorName = asn1_NOVALUE,requestList,requestExtensions = asn1_NOVALUE}).

-record('OCSPRequest', {tbsRequest,optionalSignature = asn1_NOVALUE}).

-record('TeletexDomainDefinedAttribute', {type,value}).

-record('PresentationAddress', {pSelector = asn1_NOVALUE,sSelector = asn1_NOVALUE,tSelector = asn1_NOVALUE,nAddresses}).

-record('ExtendedNetworkAddress_e163-4-address', {number,sub-address = asn1_NOVALUE}).

-record('PDSParameter', {printable-string = asn1_NOVALUE,teletex-string = asn1_NOVALUE}).

-record('UnformattedPostalAddress', {printable-address = asn1_NOVALUE,teletex-string = asn1_NOVALUE}).

-record('TeletexPersonalName', {surname,given-name = asn1_NOVALUE,initials = asn1_NOVALUE,generation-qualifier = asn1_NOVALUE}).

-record('ExtensionAttribute', {extension-attribute-type,extension-attribute-value}).

-record('BuiltInDomainDefinedAttribute', {type,value}).

-record('PersonalName', {surname,given-name = asn1_NOVALUE,initials = asn1_NOVALUE,generation-qualifier = asn1_NOVALUE}).

-record('BuiltInStandardAttributes', {country-name = asn1_NOVALUE,administration-domain-name = asn1_NOVALUE,network-address = asn1_NOVALUE,terminal-identifier = asn1_NOVALUE,private-domain-name = asn1_NOVALUE,organization-name = asn1_NOVALUE,numeric-user-identifier = asn1_NOVALUE,personal-name = asn1_NOVALUE,organizational-unit-names = asn1_NOVALUE}).

-record('ORAddress', {built-in-standard-attributes,built-in-domain-defined-attributes = asn1_NOVALUE,extension-attributes = asn1_NOVALUE}).

-record('AlgorithmIdentifier', {algorithm,parameters = asn1_NOVALUE}).

-record('TBSCertList', {version = asn1_NOVALUE,signature,issuer,thisUpdate,nextUpdate = asn1_NOVALUE,revokedCertificates = asn1_NOVALUE,crlExtensions = asn1_NOVALUE}).

-record('TBSCertList_revokedCertificates_SEQOF', {userCertificate,revocationDate,crlEntryExtensions = asn1_NOVALUE}).

-record('CertificateList', {tbsCertList,signatureAlgorithm,signature}).

-record('Extension', {extnID,critical = asn1_DEFAULT,extnValue}).

-record('SubjectPublicKeyInfo', {algorithm,subjectPublicKey}).

-record('Validity', {notBefore,notAfter}).

-record('TBSCertificate', {version = asn1_DEFAULT,serialNumber,signature,issuer,validity,subject,subjectPublicKeyInfo,issuerUniqueID = asn1_NOVALUE,subjectUniqueID = asn1_NOVALUE,extensions = asn1_NOVALUE}).

-record('Certificate', {tbsCertificate,signatureAlgorithm,signature}).

-record('AttributeTypeAndValue', {type,value}).

-record('Attribute', {type,values}).

-record('Extension-Any', {extnID,critical = asn1_DEFAULT,extnValue}).

-record('OTPExtension', {extnID,critical = asn1_DEFAULT,extnValue}).

-record('OTPExtensionAttribute', {extensionAttributeType,extensionAttributeValue}).

-record('OTPCharacteristic-two', {m,basis,parameters}).

-record('OTPFieldID', {fieldType,parameters}).

-record('PublicKeyAlgorithm', {algorithm,parameters = asn1_NOVALUE}).

-record('SignatureAlgorithm-Any', {algorithm,parameters = asn1_NOVALUE}).

-record('SignatureAlgorithm', {algorithm,parameters = asn1_NOVALUE}).

-record('OTPSubjectPublicKeyInfo-Any', {algorithm,subjectPublicKey}).

-record('OTPSubjectPublicKeyInfo', {algorithm,subjectPublicKey}).

-record('OTPOLDSubjectPublicKeyInfo', {algorithm,subjectPublicKey}).

-record('OTPOLDSubjectPublicKeyInfo_algorithm', {algo,parameters = asn1_NOVALUE}).

-record('OTPAttributeTypeAndValue', {type,value}).

-record('OTPTBSCertificate', {version = asn1_DEFAULT,serialNumber,signature,issuer,validity,subject,subjectPublicKeyInfo,issuerUniqueID = asn1_NOVALUE,subjectUniqueID = asn1_NOVALUE,extensions = asn1_NOVALUE}).

-record('OTPCertificate', {tbsCertificate,signatureAlgorithm,signature}).

-file("/usr/lib/erlang/lib/public_key-1.9.2/include/public_key.hrl", 27).

-file("/usr/lib/erlang/lib/public_key-1.9.2/include/PKCS-FRAME.hrl", 1).

-record('AlgorithmIdentifierPKCS5v2-0', {algorithm,parameters = asn1_NOVALUE}).

-record('PKAttribute', {type,values,valuesWithContext = asn1_NOVALUE}).

-record('PKAttribute_valuesWithContext_SETOF', {value,contextList}).

-record('AlgorithmIdentifierPKCS-8', {algorithm,parameters = asn1_NOVALUE}).

-record('RC5-CBC-Parameters', {version,rounds,blockSizeInBits,iv = asn1_NOVALUE}).

-record('RC2-CBC-Parameter', {rc2ParameterVersion = asn1_NOVALUE,iv}).

-record('PBMAC1-params', {keyDerivationFunc,messageAuthScheme}).

-record('PBMAC1-params_keyDerivationFunc', {algorithm,parameters = asn1_NOVALUE}).

-record('PBMAC1-params_messageAuthScheme', {algorithm,parameters = asn1_NOVALUE}).

-record('PBES2-params', {keyDerivationFunc,encryptionScheme}).

-record('PBES2-params_keyDerivationFunc', {algorithm,parameters = asn1_NOVALUE}).

-record('PBES2-params_encryptionScheme', {algorithm,parameters = asn1_NOVALUE}).

-record('PBEParameter', {salt,iterationCount}).

-record('PBKDF2-params', {salt,iterationCount,keyLength = asn1_NOVALUE,prf = asn1_DEFAULT}).

-record('PBKDF2-params_salt_otherSource', {algorithm,parameters = asn1_NOVALUE}).

-record('PBKDF2-params_prf', {algorithm,parameters = asn1_NOVALUE}).

-record('Context', {contextType,contextValues,fallback = asn1_DEFAULT}).

-record('EncryptedPrivateKeyInfo', {encryptionAlgorithm,encryptedData}).

-record('EncryptedPrivateKeyInfo_encryptionAlgorithm', {algorithm,parameters = asn1_NOVALUE}).

-record('Attributes_SETOF', {type,values,valuesWithContext = asn1_NOVALUE}).

-record('Attributes_SETOF_valuesWithContext_SETOF', {value,contextList}).

-record('PrivateKeyInfo', {version,privateKeyAlgorithm,privateKey,attributes = asn1_NOVALUE}).

-record('PrivateKeyInfo_privateKeyAlgorithm', {algorithm,parameters = asn1_NOVALUE}).

-file("/usr/lib/erlang/lib/public_key-1.9.2/include/public_key.hrl", 28).

-record('SubjectPublicKeyInfoAlgorithm', {algorithm,parameters = asn1_NOVALUE}).

-record(path_validation_state, {valid_policy_tree,explicit_policy,inhibit_any_policy,policy_mapping,cert_num,last_cert = false,permitted_subtrees = no_constraints,excluded_subtrees = [],working_public_key_algorithm,working_public_key,working_public_key_parameters,working_issuer_name,max_path_length,verify_fun,user_state}).

-record(policy_tree_node, {valid_policy,qualifier_set,criticality_indicator,expected_policy_set}).

-record(revoke_state, {reasons_mask,cert_status,interim_reasons_mask,valid_ext,details}).

-record('ECPoint', {point}).

-file("ssh.erl", 28).

-file("/usr/lib/erlang/lib/kernel-7.2/include/file.hrl", 1).

-record(file_info,{size::non_neg_integer()|undefined,type::device|directory|other|regular|symlink|undefined,access::read|write|read_write|none|undefined,atime::file:date_time()|non_neg_integer()|undefined,mtime::file:date_time()|non_neg_integer()|undefined,ctime::file:date_time()|non_neg_integer()|undefined,mode::non_neg_integer()|undefined,links::non_neg_integer()|undefined,major_device::non_neg_integer()|undefined,minor_device::non_neg_integer()|undefined,inode::non_neg_integer()|undefined,uid::non_neg_integer()|undefined,gid::non_neg_integer()|undefined}).

-record(file_descriptor,{module::module(),data::term()}).

-file("ssh.erl", 29).

-file("/usr/lib/erlang/lib/kernel-7.2/include/inet.hrl", 1).

-record(hostent,{h_name::inet:hostname(),h_aliases = []::[inet:hostname()],h_addrtype::inet|inet6,h_length::non_neg_integer(),h_addr_list = []::[inet:ip_address()]}).

-file("ssh.erl", 30).

-export([start/0, start/1, stop/0, connect/2, connect/3, connect/4, close/1, connection_info/2, connection_info/1, channel_info/3, daemon/1, daemon/2, daemon/3, daemon_info/1, daemon_info/2, set_sock_opts/2, get_sock_opts/2, default_algorithms/0, chk_algos_opts/1, stop_listener/1, stop_listener/2, stop_listener/3, stop_daemon/1, stop_daemon/2, stop_daemon/3, shell/1, shell/2, shell/3, tcpip_tunnel_from_server/5, tcpip_tunnel_from_server/6, tcpip_tunnel_to_server/5, tcpip_tunnel_to_server/6]).

-export_type([ssh_daemon_ref/0, ssh_connection_ref/0, ssh_channel_id/0]).

-opaque(ssh_daemon_ref()::daemon_ref()).

-opaque(ssh_connection_ref()::connection_ref()).

-opaque(ssh_channel_id()::channel_id()).

-export_type([daemon_ref/0, connection_ref/0, channel_id/0, client_options/0, client_option/0, daemon_options/0, daemon_option/0, common_options/0, role/0, subsystem_spec/0, algs_list/0, double_algs/1, modify_algs_list/0, alg_entry/0, kex_alg/0, pubkey_alg/0, cipher_alg/0, mac_alg/0, compression_alg/0, host/0, open_socket/0, ip_port/0]).

-opaque(daemon_ref()::pid()).

-opaque(channel_id()::non_neg_integer()).

-type(connection_ref()::pid()).

-spec(start() -> ok|{error,term()}).

start() ->
    start(temporary).

-spec(start(Type) -> ok|{error,term()} when Type::permanent|transient|temporary).

start(Type) ->
    case application:ensure_all_started(ssh,Type) of
        {ok,_}->
            ssh_transport:clear_default_algorithms_env(),
            ssh_transport:default_algorithms(),
            ok;
        Other->
            Other
    end.

-spec(stop() -> ok|{error,term()}).

stop() ->
    application:stop(ssh).

-spec(connect(OpenTcpSocket,Options) -> {ok,connection_ref()}|{error,term()} when OpenTcpSocket::open_socket(),Options::client_options()).

connect(OpenTcpSocket,Options)
    when is_port(OpenTcpSocket),
    is_list(Options)->
    connect(OpenTcpSocket,Options,infinity).

-spec(connect(open_socket(),client_options(),timeout()) -> {ok,connection_ref()}|{error,term()};(host(),inet:port_number(),client_options()) -> {ok,connection_ref()}|{error,term()}).

connect(Socket,UserOptions,NegotiationTimeout)
    when is_port(Socket),
    is_list(UserOptions)->
    case ssh_options:handle_options(client,UserOptions) of
        {error,Error}->
            {error,Error};
        Options->
            case valid_socket_to_use(Socket,ssh_options:get_value(user_options,transport,Options,ssh,138)) of
                ok->
                    connect_socket(Socket,ssh_options:put_value(internal_options,{connected_socket,Socket},Options,ssh,141),NegotiationTimeout);
                {error,SockError}->
                    {error,SockError}
            end
    end;
connect(Host,Port,Options)
    when is_integer(Port),
    Port > 0,
    is_list(Options)->
    connect(Host,Port,Options,infinity).

-spec(connect(Host,Port,Options,NegotiationTimeout) -> {ok,connection_ref()}|{error,term()} when Host::host(),Port::inet:port_number(),Options::client_options(),NegotiationTimeout::timeout()).

connect(Host0,Port,UserOptions,NegotiationTimeout)
    when is_integer(Port),
    Port > 0,
    is_list(UserOptions)->
    case ssh_options:handle_options(client,UserOptions) of
        {error,_Reason} = Error->
            Error;
        Options->
            {_,Transport,_} = TransportOpts = ssh_options:get_value(user_options,transport,Options,ssh,167),
            ConnectionTimeout = ssh_options:get_value(user_options,connect_timeout,Options,ssh,168),
            SocketOpts = [{active,false}| ssh_options:get_value(user_options,socket_options,Options,ssh,169)],
            Host = mangle_connect_address(Host0,SocketOpts),
            try Transport:connect(Host,Port,SocketOpts,ConnectionTimeout) of 
                {ok,Socket}->
                    connect_socket(Socket,ssh_options:put_value(internal_options,{host,Host},Options,ssh,174),NegotiationTimeout);
                {error,Reason}->
                    {error,Reason}
                catch
                    exit:{function_clause,_F}->
                        {error,{options,{transport,TransportOpts}}};
                    exit:badarg->
                        {error,{options,{socket_options,SocketOpts}}} end
    end.

connect_socket(Socket,Options0,NegotiationTimeout) ->
    {ok,{Host,Port}} = inet:sockname(Socket),
    Profile = ssh_options:get_value(user_options,profile,Options0,ssh,189),
    {ok,{SystemSup,SubSysSup}} = sshc_sup:start_system_subsystem(Host,Port,Profile,Options0),
    ConnectionSup = ssh_system_sup:connection_supervisor(SystemSup),
    Opts = ssh_options:put_value(internal_options,[{user_pid,self()}, {supervisors,[{system_sup,SystemSup}, {subsystem_sup,SubSysSup}, {connection_sup,ConnectionSup}]}],Options0,ssh,198),
    ssh_connection_handler:start_connection(client,Socket,Opts,NegotiationTimeout).

-spec(close(ConnectionRef) -> ok|{error,term()} when ConnectionRef::connection_ref()).

close(ConnectionRef) ->
    ssh_connection_handler:stop(ConnectionRef).

-type(version()::{protocol_version(),software_version()}).

-type(protocol_version()::{Major::pos_integer(),Minor::non_neg_integer()}).

-type(software_version()::string()).

-type(conn_info_algs()::[{kex,kex_alg()}|{hkey,pubkey_alg()}|{encrypt,cipher_alg()}|{decrypt,cipher_alg()}|{send_mac,mac_alg()}|{recv_mac,mac_alg()}|{compress,compression_alg()}|{decompress,compression_alg()}|{send_ext_info,boolean()}|{recv_ext_info,boolean()}]).

-type(conn_info_channels()::[proplists:proplist()]).

-type(connection_info_tuple()::{client_version,version()}|{server_version,version()}|{user,string()}|{peer,{inet:hostname(),ip_port()}}|{sockname,ip_port()}|{options,client_options()}|{algorithms,conn_info_algs()}|{channels,conn_info_channels()}).

-spec(connection_info(ConnectionRef) -> InfoTupleList when ConnectionRef::connection_ref(),InfoTupleList::[InfoTuple],InfoTuple::connection_info_tuple()).

connection_info(ConnectionRef) ->
    connection_info(ConnectionRef,[]).

-spec(connection_info(ConnectionRef,ItemList|Item) -> InfoTupleList|InfoTuple when ConnectionRef::connection_ref(),ItemList::[Item],Item::client_version|server_version|user|peer|sockname|options|algorithms|sockname,InfoTupleList::[InfoTuple],InfoTuple::connection_info_tuple()).

connection_info(ConnectionRef,Key) ->
    ssh_connection_handler:connection_info(ConnectionRef,Key).

-spec(channel_info(connection_ref(),channel_id(),[atom()]) -> proplists:proplist()).

channel_info(ConnectionRef,ChannelId,Options) ->
    ssh_connection_handler:channel_info(ConnectionRef,ChannelId,Options).

-spec(daemon(inet:port_number()) -> {ok,daemon_ref()}|{error,term()}).

daemon(Port) ->
    daemon(Port,[]).

-spec(daemon(inet:port_number()|open_socket(),daemon_options()) -> {ok,daemon_ref()}|{error,term()}).

daemon(Socket,UserOptions)
    when is_port(Socket)->
    try #{} = Options = ssh_options:handle_options(server,UserOptions),
    case valid_socket_to_use(Socket,ssh_options:get_value(user_options,transport,Options,ssh,282)) of
        ok->
            {ok,{IP,Port}} = inet:sockname(Socket),
            finalize_start(IP,Port,ssh_options:get_value(user_options,profile,Options,ssh,285),ssh_options:put_value(internal_options,{connected_socket,Socket},Options,ssh,286),fun (Opts,DefaultResult)->
                try ssh_acceptor:handle_established_connection(IP,Port,Opts,Socket) of 
                    {error,Error}->
                        {error,Error};
                    _->
                        DefaultResult
                    catch
                        C:R->
                            {error,{could_not_start_connection,{C,R}}} end end);
        {error,SockError}->
            {error,SockError}
    end
        catch
            throw:bad_fd->
                {error,bad_fd};
            throw:bad_socket->
                {error,bad_socket};
            error:{badmatch,{error,Error}}->
                {error,Error};
            error:Error->
                {error,Error};
            _C:_E->
                {error,{cannot_start_daemon,_C,_E}} end;
daemon(Port,UserOptions)
    when 0 =< Port,
    Port =< 65535->
    daemon(any,Port,UserOptions).

-spec(daemon(any|inet:ip_address(),inet:port_number(),daemon_options()) -> {ok,daemon_ref()}|{error,term()};(socket,open_socket(),daemon_options()) -> {ok,daemon_ref()}|{error,term()}).

daemon(Host0,Port0,UserOptions0)
    when 0 =< Port0,
    Port0 =< 65535,
    Host0 == any;
    Host0 == loopback;
    is_tuple(Host0)->
    try {Host1,UserOptions} = handle_daemon_args(Host0,UserOptions0),
    #{} = Options0 = ssh_options:handle_options(server,UserOptions),
    {open_listen_socket(Host1,Port0,Options0),Options0} of 
        {{{Host,Port},ListenSocket},Options1}->
            try finalize_start(Host,Port,ssh_options:get_value(user_options,profile,Options1,ssh,336),ssh_options:put_value(internal_options,{lsocket,{ListenSocket,self()}},Options1,ssh,337),fun (Opts,Result)->
                {_,Callback,_} = ssh_options:get_value(user_options,transport,Opts,ssh,339),
                receive {request_control,ListenSocket,ReqPid}->
                    ok = Callback:controlling_process(ListenSocket,ReqPid),
                    ReqPid ! {its_yours,ListenSocket},
                    Result end end) of 
                {error,Err}->
                    close_listen_socket(ListenSocket,Options1),
                    {error,Err};
                OK->
                    OK
                catch
                    error:Error->
                        close_listen_socket(ListenSocket,Options1),
                        error(Error);
                    exit:Exit->
                        close_listen_socket(ListenSocket,Options1),
                        exit(Exit) end
        catch
            throw:bad_fd->
                {error,bad_fd};
            throw:bad_socket->
                {error,bad_socket};
            error:{badmatch,{error,Error}}->
                {error,Error};
            error:Error->
                {error,Error};
            _C:_E->
                {error,{cannot_start_daemon,_C,_E}} end;
daemon(_,_,_) ->
    {error,badarg}.

-type(daemon_info_tuple()::{port,inet:port_number()}|{ip,inet:ip_address()}|{profile,atom()}|{options,daemon_options()}).

-spec(daemon_info(DaemonRef) -> {ok,InfoTupleList}|{error,bad_daemon_ref} when DaemonRef::daemon_ref(),InfoTupleList::[InfoTuple],InfoTuple::daemon_info_tuple()).

daemon_info(DaemonRef) ->
    case  catch ssh_system_sup:acceptor_supervisor(DaemonRef) of
        AsupPid
            when is_pid(AsupPid)->
            [{Host,Port,Profile}] = [{Hst,Prt,Prf} || {{ssh_acceptor_sup,Hst,Prt,Prf},_Pid,worker,[ssh_acceptor]} <- supervisor:which_children(AsupPid)],
            IP = case inet:parse_strict_address(Host) of
                {ok,IP0}->
                    IP0;
                _->
                    Host
            end,
            Opts = case ssh_system_sup:get_options(DaemonRef,Host,Port,Profile) of
                {ok,OptMap}->
                    lists:sort(maps:to_list(ssh_options:keep_set_options(server,ssh_options:keep_user_options(server,OptMap))));
                _->
                    []
            end,
            {ok,[{port,Port}, {ip,IP}, {profile,Profile}, {options,Opts}]};
        _->
            {error,bad_daemon_ref}
    end.

-spec(daemon_info(DaemonRef,ItemList|Item) -> InfoTupleList|InfoTuple|{error,bad_daemon_ref} when DaemonRef::daemon_ref(),ItemList::[Item],Item::ip|port|profile|options,InfoTupleList::[InfoTuple],InfoTuple::daemon_info_tuple()).

daemon_info(DaemonRef,Key)
    when is_atom(Key)->
    case daemon_info(DaemonRef,[Key]) of
        [{Key,Val}]->
            {Key,Val};
        Other->
            Other
    end;
daemon_info(DaemonRef,Keys) ->
    case daemon_info(DaemonRef) of
        {ok,KVs}->
            [{Key,proplists:get_value(Key,KVs)} || Key <- Keys,lists:keymember(Key,1,KVs)];
        _->
            []
    end.

-spec(stop_listener(daemon_ref()) -> ok).

stop_listener(SysSup) ->
    ssh_system_sup:stop_listener(SysSup).

-spec(stop_listener(inet:ip_address(),inet:port_number()) -> ok).

stop_listener(Address,Port) ->
    stop_listener(Address,Port,default).

-spec(stop_listener(any|inet:ip_address(),inet:port_number(),term()) -> ok).

stop_listener(any,Port,Profile) ->
    map_ip(fun (IP)->
        ssh_system_sup:stop_listener(IP,Port,Profile) end,[{0,0,0,0}, {0,0,0,0,0,0,0,0}]);
stop_listener(Address,Port,Profile) ->
    map_ip(fun (IP)->
        ssh_system_sup:stop_listener(IP,Port,Profile) end,{address,Address}).

-spec(stop_daemon(DaemonRef::daemon_ref()) -> ok).

stop_daemon(SysSup) ->
    ssh_system_sup:stop_system(server,SysSup).

-spec(stop_daemon(inet:ip_address(),inet:port_number()) -> ok).

stop_daemon(Address,Port) ->
    stop_daemon(Address,Port,default).

-spec(stop_daemon(any|inet:ip_address(),inet:port_number(),atom()) -> ok).

stop_daemon(any,Port,Profile) ->
    map_ip(fun (IP)->
        ssh_system_sup:stop_system(server,IP,Port,Profile) end,[{0,0,0,0}, {0,0,0,0,0,0,0,0}]);
stop_daemon(Address,Port,Profile) ->
    map_ip(fun (IP)->
        ssh_system_sup:stop_system(server,IP,Port,Profile) end,{address,Address}).

-spec(shell(open_socket()|host()|connection_ref()) -> _).

shell(Socket)
    when is_port(Socket)->
    shell(Socket,[]);
shell(ConnectionRef)
    when is_pid(ConnectionRef)->
    case ssh_connection:session_channel(ConnectionRef,infinity) of
        {ok,ChannelId}->
            success = ssh_connection:ptty_alloc(ConnectionRef,ChannelId,[{pty_opts,[{echo,0}]}]),
            success = ssh_connection:send_environment_vars(ConnectionRef,ChannelId,["LANG", "LC_ALL"]),
            Args = [{channel_cb,ssh_shell}, {init_args,[ConnectionRef, ChannelId]}, {cm,ConnectionRef}, {channel_id,ChannelId}],
            {ok,State} = ssh_client_channel:init([Args]),
            try ssh_client_channel:enter_loop(State)
                catch
                    exit:normal->
                        ok end;
        Error->
            Error
    end;
shell(Host) ->
    shell(Host,22,[]).

-spec(shell(open_socket()|host(),client_options()) -> _).

shell(Socket,Options)
    when is_port(Socket)->
    case connect(Socket,Options) of
        {ok,ConnectionRef}->
            shell(ConnectionRef),
            close(ConnectionRef);
        Error->
            Error
    end;
shell(Host,Options) ->
    shell(Host,22,Options).

-spec(shell(Host,Port,Options) -> _ when Host::host(),Port::inet:port_number(),Options::client_options()).

shell(Host,Port,Options) ->
    case connect(Host,Port,Options) of
        {ok,ConnectionRef}->
            shell(ConnectionRef),
            close(ConnectionRef);
        Error->
            Error
    end.

-spec(default_algorithms() -> algs_list()).

default_algorithms() ->
    ssh_transport:default_algorithms().

-spec(chk_algos_opts(client_options()|daemon_options()) -> internal_options()|{error,term()}).

chk_algos_opts(Opts) ->
    case lists:foldl(fun ({preferred_algorithms,_},Acc)->
        Acc;({modify_algorithms,_},Acc)->
        Acc;(KV,Acc)->
        [KV| Acc] end,[],Opts) of
        []->
            case ssh_options:handle_options(client,Opts) of
                M
                    when is_map(M)->
                    maps:get(preferred_algorithms,M);
                Others->
                    Others
            end;
        OtherOps->
            {error,{non_algo_opts_found,OtherOps}}
    end.

-spec(set_sock_opts(ConnectionRef,SocketOptions) -> ok|{error,inet:posix()} when ConnectionRef::connection_ref(),SocketOptions::[gen_tcp:option()]).

set_sock_opts(ConnectionRef,SocketOptions) ->
    ssh_connection_handler:set_sock_opts(ConnectionRef,SocketOptions).

-spec(get_sock_opts(ConnectionRef,SocketGetOptions) -> ok|{error,inet:posix()} when ConnectionRef::connection_ref(),SocketGetOptions::[gen_tcp:option_name()]).

get_sock_opts(ConnectionRef,SocketGetOptions) ->
    ssh_connection_handler:get_sock_opts(ConnectionRef,SocketGetOptions).

-spec(tcpip_tunnel_to_server(ConnectionRef,ListenHost,ListenPort,ConnectToHost,ConnectToPort) -> {ok,TrueListenPort}|{error,term()} when ConnectionRef::connection_ref(),ListenHost::host(),ListenPort::inet:port_number(),ConnectToHost::host(),ConnectToPort::inet:port_number(),TrueListenPort::inet:port_number()).

tcpip_tunnel_to_server(ConnectionHandler,ListenHost,ListenPort,ConnectToHost,ConnectToPort) ->
    tcpip_tunnel_to_server(ConnectionHandler,ListenHost,ListenPort,ConnectToHost,ConnectToPort,infinity).

-spec(tcpip_tunnel_to_server(ConnectionRef,ListenHost,ListenPort,ConnectToHost,ConnectToPort,Timeout) -> {ok,TrueListenPort}|{error,term()} when ConnectionRef::connection_ref(),ListenHost::host(),ListenPort::inet:port_number(),ConnectToHost::host(),ConnectToPort::inet:port_number(),Timeout::timeout(),TrueListenPort::inet:port_number()).

tcpip_tunnel_to_server(ConnectionHandler,ListenHost,ListenPort,ConnectToHost0,ConnectToPort,Timeout) ->
    SockOpts = [],
    try list_to_binary(case mangle_connect_address(ConnectToHost0,SockOpts) of
        IP
            when is_tuple(IP)->
            inet_parse:ntoa(IP);
        _
            when is_list(ConnectToHost0)->
            ConnectToHost0
    end) of 
        ConnectToHost->
            ssh_connection_handler:handle_direct_tcpip(ConnectionHandler,mangle_tunnel_address(ListenHost),ListenPort,ConnectToHost,ConnectToPort,Timeout)
        catch
            _:_->
                {error,bad_connect_to_address} end.

-spec(tcpip_tunnel_from_server(ConnectionRef,ListenHost,ListenPort,ConnectToHost,ConnectToPort) -> {ok,TrueListenPort}|{error,term()} when ConnectionRef::connection_ref(),ListenHost::host(),ListenPort::inet:port_number(),ConnectToHost::host(),ConnectToPort::inet:port_number(),TrueListenPort::inet:port_number()).

tcpip_tunnel_from_server(ConnectionRef,ListenHost,ListenPort,ConnectToHost,ConnectToPort) ->
    tcpip_tunnel_from_server(ConnectionRef,ListenHost,ListenPort,ConnectToHost,ConnectToPort,infinity).

-spec(tcpip_tunnel_from_server(ConnectionRef,ListenHost,ListenPort,ConnectToHost,ConnectToPort,Timeout) -> {ok,TrueListenPort}|{error,term()} when ConnectionRef::connection_ref(),ListenHost::host(),ListenPort::inet:port_number(),ConnectToHost::host(),ConnectToPort::inet:port_number(),Timeout::timeout(),TrueListenPort::inet:port_number()).

tcpip_tunnel_from_server(ConnectionRef,ListenHost0,ListenPort,ConnectToHost0,ConnectToPort,Timeout) ->
    SockOpts = [],
    ListenHost = mangle_tunnel_address(ListenHost0),
    ConnectToHost = mangle_connect_address(ConnectToHost0,SockOpts),
    case ssh_connection_handler:global_request(ConnectionRef,"tcpip-forward",true,{ListenHost,ListenPort,ConnectToHost,ConnectToPort},Timeout) of
        {success,<<>>}->
            {ok,ListenPort};
        {success,<<TruePort:32/unsigned-integer>>}
            when ListenPort == 0->
            {ok,TruePort};
        {success,_} = Res->
            {error,{bad_result,Res}};
        {failure,<<>>}->
            {error,not_accepted};
        {failure,Error}->
            {error,Error};
        Other->
            Other
    end.

handle_daemon_args(any,Opts) ->
    case proplists:get_value(ip,Opts) of
        undefined->
            {any,Opts};
        IP->
            {IP,Opts}
    end;
handle_daemon_args(IPaddr,Opts)
    when is_tuple(IPaddr);
    IPaddr == loopback->
    case proplists:get_value(ip,Opts) of
        undefined->
            {IPaddr,[{ip,IPaddr}| Opts]};
        IPaddr->
            {IPaddr,Opts};
        IP->
            {IPaddr,[{ip,IPaddr}| Opts -- [{ip,IP}]]}
    end.

valid_socket_to_use(Socket,{tcp,_,_}) ->
    try {is_tcp_socket(Socket),{ok,[{active,false}]} == inet:getopts(Socket,[active])} of 
        {true,true}->
            ok;
        {true,false}->
            {error,not_passive_mode};
        _->
            {error,not_tcp_socket}
        catch
            _:_->
                {error,bad_socket} end;
valid_socket_to_use(_,{L4,_,_}) ->
    {error,{unsupported,L4}}.

is_tcp_socket(Socket) ->
    case inet:getopts(Socket,[delay_send]) of
        {ok,[_]}->
            true;
        _->
            false
    end.

open_listen_socket(_Host0,Port0,Options0) ->
    {ok,LSock} = case ssh_options:get_value(socket_options,fd,Options0,ssh,763) of
        undefined->
            ssh_acceptor:listen(Port0,Options0);
        Fd
            when is_integer(Fd)->
            ssh_acceptor:listen(0,Options0)
    end,
    {ok,{LHost,LPort}} = inet:sockname(LSock),
    {{LHost,LPort},LSock}.

close_listen_socket(ListenSocket,Options) ->
    try {_,Callback,_} = ssh_options:get_value(user_options,transport,Options,ssh,776),
    Callback:close(ListenSocket)
        catch
            _C:_E->
                ok end.

finalize_start(Host,Port,Profile,Options0,F) ->
    try ssh_connection_handler:available_hkey_algorithms(server,Options0),
    sshd_sup:start_child(Host,Port,Profile,Options0) of 
        {error,{already_started,_}}->
            {error,eaddrinuse};
        {error,Error}->
            {error,Error};
        Result = {ok,_}->
            F(Options0,Result)
        catch
            error:{shutdown,Err}->
                {error,Err};
            exit:{noproc,_}->
                {error,ssh_not_started} end.

map_ip(Fun,{address,IP})
    when is_tuple(IP)->
    Fun(IP);
map_ip(Fun,{address,Address}) ->
    IPs = try {ok,#hostent{h_addr_list = IP0s}} = inet:gethostbyname(Address),
    IP0s
        catch
            _:_->
                [] end,
    map_ip(Fun,IPs);
map_ip(Fun,IPs) ->
    lists:map(Fun,IPs).

mangle_connect_address(A,SockOpts) ->
    mangle_connect_address1(A,proplists:get_value(inet6,SockOpts,false)).

loopback(true) ->
    {0,0,0,0,0,0,0,1};
loopback(false) ->
    {127,0,0,1}.

mangle_connect_address1(loopback,V6flg) ->
    loopback(V6flg);
mangle_connect_address1(any,V6flg) ->
    loopback(V6flg);
mangle_connect_address1({0,0,0,0},_) ->
    loopback(false);
mangle_connect_address1({0,0,0,0,0,0,0,0},_) ->
    loopback(true);
mangle_connect_address1(IP,_)
    when is_tuple(IP)->
    IP;
mangle_connect_address1(A,_) ->
    case  catch inet:parse_address(A) of
        {ok,{0,0,0,0}}->
            loopback(false);
        {ok,{0,0,0,0,0,0,0,0}}->
            loopback(true);
        _->
            A
    end.

mangle_tunnel_address(any) ->
    <<"">>;
mangle_tunnel_address(loopback) ->
    <<"localhost">>;
mangle_tunnel_address({0,0,0,0}) ->
    <<"">>;
mangle_tunnel_address({0,0,0,0,0,0,0,0}) ->
    <<"">>;
mangle_tunnel_address(IP)
    when is_tuple(IP)->
    list_to_binary(inet_parse:ntoa(IP));
mangle_tunnel_address(A)
    when is_atom(A)->
    mangle_tunnel_address(atom_to_list(A));
mangle_tunnel_address(X)
    when is_list(X)->
    case  catch inet:parse_address(X) of
        {ok,{0,0,0,0}}->
            <<"">>;
        {ok,{0,0,0,0,0,0,0,0}}->
            <<"">>;
        _->
            list_to_binary(X)
    end.
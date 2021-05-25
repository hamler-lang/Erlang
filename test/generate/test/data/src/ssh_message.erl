-file("ssh_message.erl", 1).

-module(ssh_message).

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

-file("ssh_message.erl", 27).

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

-file("ssh_message.erl", 29).

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

-file("ssh_message.erl", 30).

-file("ssh_auth.hrl", 1).

-record(ssh_msg_userauth_request, {user,service,method,data}).

-record(ssh_msg_userauth_failure, {authentications,partial_success}).

-record(ssh_msg_userauth_success, {}).

-record(ssh_msg_userauth_banner, {message,language}).

-record(ssh_msg_userauth_passwd_changereq, {prompt,languge}).

-record(ssh_msg_userauth_pk_ok, {algorithm_name,key_blob}).

-record(ssh_msg_userauth_info_request, {name,instruction,language_tag,num_prompts,data}).

-record(ssh_msg_userauth_info_response, {num_responses,data}).

-file("ssh_message.erl", 31).

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

-file("ssh_message.erl", 32).

-export([encode/1, decode/1, decode_keyboard_interactive_prompts/2]).

-export([ssh2_pubkey_decode/1, ssh2_pubkey_encode/1, ssh2_privkey_decode2/1]).

-behaviour(ssh_dbg).

-export([ssh_dbg_trace_points/0, ssh_dbg_flags/1, ssh_dbg_on/1, ssh_dbg_off/1, ssh_dbg_format/2]).

ucl(B) ->
    try unicode:characters_to_list(B) of 
        L
            when is_list(L)->
            L;
        {error,_Matched,Rest}->
            throw({error,{bad_unicode,Rest}})
        catch
            _:_->
                throw({error,bad_unicode}) end.

encode(#ssh_msg_global_request{name = Name,want_reply = Bool,data = Data}) ->
    <<80:8/unsigned-big-integer,(size(if is_binary(Name) ->
        Name;is_list(Name) ->
        list_to_binary(Name);Name == undefined ->
        <<>> end)):32/unsigned-big-integer,if is_binary(Name) ->
        Name;is_list(Name) ->
        list_to_binary(Name);Name == undefined ->
        <<>> end/binary,case Bool of
        true->
            1;
        false->
            0
    end:8/unsigned-big-integer,if is_binary(Data) ->
        Data;is_list(Data) ->
        list_to_binary(Data);Data == undefined ->
        <<>> end/binary>>;
encode(#ssh_msg_request_success{data = Data}) ->
    <<81:8/unsigned-big-integer,Data/binary>>;
encode(#ssh_msg_request_failure{}) ->
    <<82:8/unsigned-big-integer>>;
encode(#ssh_msg_channel_open{channel_type = Type,sender_channel = Sender,initial_window_size = Window,maximum_packet_size = Max,data = Data}) ->
    <<90:8/unsigned-big-integer,(size(if is_binary(Type) ->
        Type;is_list(Type) ->
        list_to_binary(Type);Type == undefined ->
        <<>> end)):32/unsigned-big-integer,if is_binary(Type) ->
        Type;is_list(Type) ->
        list_to_binary(Type);Type == undefined ->
        <<>> end/binary,Sender:32/unsigned-big-integer,Window:32/unsigned-big-integer,Max:32/unsigned-big-integer,if is_binary(Data) ->
        Data;is_list(Data) ->
        list_to_binary(Data);Data == undefined ->
        <<>> end/binary>>;
encode(#ssh_msg_channel_open_confirmation{recipient_channel = Recipient,sender_channel = Sender,initial_window_size = InitWindowSize,maximum_packet_size = MaxPacketSize,data = Data}) ->
    <<91:8/unsigned-big-integer,Recipient:32/unsigned-big-integer,Sender:32/unsigned-big-integer,InitWindowSize:32/unsigned-big-integer,MaxPacketSize:32/unsigned-big-integer,if is_binary(Data) ->
        Data;is_list(Data) ->
        list_to_binary(Data);Data == undefined ->
        <<>> end/binary>>;
encode(#ssh_msg_channel_open_failure{recipient_channel = Recipient,reason = Reason,description = Desc,lang = Lang}) ->
    <<92:8/unsigned-big-integer,Recipient:32/unsigned-big-integer,Reason:32/unsigned-big-integer,(size(if is_binary(Desc) ->
        Desc;is_list(Desc) ->
        list_to_binary(Desc);Desc == undefined ->
        <<>> end)):32/unsigned-big-integer,if is_binary(Desc) ->
        Desc;is_list(Desc) ->
        list_to_binary(Desc);Desc == undefined ->
        <<>> end/binary,(size(if is_binary(Lang) ->
        Lang;is_list(Lang) ->
        list_to_binary(Lang);Lang == undefined ->
        <<>> end)):32/unsigned-big-integer,if is_binary(Lang) ->
        Lang;is_list(Lang) ->
        list_to_binary(Lang);Lang == undefined ->
        <<>> end/binary>>;
encode(#ssh_msg_channel_window_adjust{recipient_channel = Recipient,bytes_to_add = Bytes}) ->
    <<93:8/unsigned-big-integer,Recipient:32/unsigned-big-integer,Bytes:32/unsigned-big-integer>>;
encode(#ssh_msg_channel_data{recipient_channel = Recipient,data = Data}) ->
    <<94:8/unsigned-big-integer,Recipient:32/unsigned-big-integer,(size(Data)):32/unsigned-big-integer,Data/binary>>;
encode(#ssh_msg_channel_extended_data{recipient_channel = Recipient,data_type_code = DataType,data = Data}) ->
    <<95:8/unsigned-big-integer,Recipient:32/unsigned-big-integer,DataType:32/unsigned-big-integer,(size(Data)):32/unsigned-big-integer,Data/binary>>;
encode(#ssh_msg_channel_eof{recipient_channel = Recipient}) ->
    <<96:8/unsigned-big-integer,Recipient:32/unsigned-big-integer>>;
encode(#ssh_msg_channel_close{recipient_channel = Recipient}) ->
    <<97:8/unsigned-big-integer,Recipient:32/unsigned-big-integer>>;
encode(#ssh_msg_channel_request{recipient_channel = Recipient,request_type = Type,want_reply = Bool,data = Data}) ->
    <<98:8/unsigned-big-integer,Recipient:32/unsigned-big-integer,(size(if is_binary(Type) ->
        Type;is_list(Type) ->
        list_to_binary(Type);Type == undefined ->
        <<>> end)):32/unsigned-big-integer,if is_binary(Type) ->
        Type;is_list(Type) ->
        list_to_binary(Type);Type == undefined ->
        <<>> end/binary,case Bool of
        true->
            1;
        false->
            0
    end:8/unsigned-big-integer,if is_binary(Data) ->
        Data;is_list(Data) ->
        list_to_binary(Data);Data == undefined ->
        <<>> end/binary>>;
encode(#ssh_msg_channel_success{recipient_channel = Recipient}) ->
    <<99:8/unsigned-big-integer,Recipient:32/unsigned-big-integer>>;
encode(#ssh_msg_channel_failure{recipient_channel = Recipient}) ->
    <<100:8/unsigned-big-integer,Recipient:32/unsigned-big-integer>>;
encode(#ssh_msg_userauth_request{user = User,service = Service,method = Method,data = Data}) ->
    <<50:8/unsigned-big-integer,<<(size(unicode:characters_to_binary(User))):32/unsigned-big-integer,(unicode:characters_to_binary(User))/binary>>/binary,(size(if is_binary(Service) ->
        Service;is_list(Service) ->
        list_to_binary(Service);Service == undefined ->
        <<>> end)):32/unsigned-big-integer,if is_binary(Service) ->
        Service;is_list(Service) ->
        list_to_binary(Service);Service == undefined ->
        <<>> end/binary,(size(if is_binary(Method) ->
        Method;is_list(Method) ->
        list_to_binary(Method);Method == undefined ->
        <<>> end)):32/unsigned-big-integer,if is_binary(Method) ->
        Method;is_list(Method) ->
        list_to_binary(Method);Method == undefined ->
        <<>> end/binary,if is_binary(Data) ->
        Data;is_list(Data) ->
        list_to_binary(Data);Data == undefined ->
        <<>> end/binary>>;
encode(#ssh_msg_userauth_failure{authentications = Auths,partial_success = Bool}) ->
    <<51:8/unsigned-big-integer,(size(if is_binary(Auths) ->
        Auths;is_list(Auths) ->
        list_to_binary(Auths);Auths == undefined ->
        <<>> end)):32/unsigned-big-integer,if is_binary(Auths) ->
        Auths;is_list(Auths) ->
        list_to_binary(Auths);Auths == undefined ->
        <<>> end/binary,case Bool of
        true->
            1;
        false->
            0
    end:8/unsigned-big-integer>>;
encode(#ssh_msg_userauth_success{}) ->
    <<52:8/unsigned-big-integer>>;
encode(#ssh_msg_userauth_banner{message = Banner,language = Lang}) ->
    <<53:8/unsigned-big-integer,<<(size(unicode:characters_to_binary(Banner))):32/unsigned-big-integer,(unicode:characters_to_binary(Banner))/binary>>/binary,(size(if is_binary(Lang) ->
        Lang;is_list(Lang) ->
        list_to_binary(Lang);Lang == undefined ->
        <<>> end)):32/unsigned-big-integer,if is_binary(Lang) ->
        Lang;is_list(Lang) ->
        list_to_binary(Lang);Lang == undefined ->
        <<>> end/binary>>;
encode(#ssh_msg_userauth_pk_ok{algorithm_name = Alg,key_blob = KeyBlob}) ->
    <<60:8/unsigned-big-integer,(size(if is_binary(Alg) ->
        Alg;is_list(Alg) ->
        list_to_binary(Alg);Alg == undefined ->
        <<>> end)):32/unsigned-big-integer,if is_binary(Alg) ->
        Alg;is_list(Alg) ->
        list_to_binary(Alg);Alg == undefined ->
        <<>> end/binary,(size(KeyBlob)):32/unsigned-big-integer,KeyBlob/binary>>;
encode(#ssh_msg_userauth_passwd_changereq{prompt = Prompt,languge = Lang}) ->
    <<60:8/unsigned-big-integer,<<(size(unicode:characters_to_binary(Prompt))):32/unsigned-big-integer,(unicode:characters_to_binary(Prompt))/binary>>/binary,(size(if is_binary(Lang) ->
        Lang;is_list(Lang) ->
        list_to_binary(Lang);Lang == undefined ->
        <<>> end)):32/unsigned-big-integer,if is_binary(Lang) ->
        Lang;is_list(Lang) ->
        list_to_binary(Lang);Lang == undefined ->
        <<>> end/binary>>;
encode(#ssh_msg_userauth_info_request{name = Name,instruction = Inst,language_tag = Lang,num_prompts = NumPromtps,data = Data}) ->
    <<60:8/unsigned-big-integer,<<(size(unicode:characters_to_binary(Name))):32/unsigned-big-integer,(unicode:characters_to_binary(Name))/binary>>/binary,<<(size(unicode:characters_to_binary(Inst))):32/unsigned-big-integer,(unicode:characters_to_binary(Inst))/binary>>/binary,(size(if is_binary(Lang) ->
        Lang;is_list(Lang) ->
        list_to_binary(Lang);Lang == undefined ->
        <<>> end)):32/unsigned-big-integer,if is_binary(Lang) ->
        Lang;is_list(Lang) ->
        list_to_binary(Lang);Lang == undefined ->
        <<>> end/binary,NumPromtps:32/unsigned-big-integer,if is_binary(Data) ->
        Data;is_list(Data) ->
        list_to_binary(Data);Data == undefined ->
        <<>> end/binary>>;
encode(#ssh_msg_userauth_info_response{num_responses = Num,data = Data}) ->
    lists:foldl(fun (Response,Acc)->
        <<Acc/binary,<<(size(unicode:characters_to_binary(Response))):32/unsigned-big-integer,(unicode:characters_to_binary(Response))/binary>>/binary>> end,<<61:8/unsigned-big-integer,Num:32/unsigned-big-integer>>,Data);
encode(#ssh_msg_disconnect{code = Code,description = Desc,language = Lang}) ->
    <<1:8/unsigned-big-integer,Code:32/unsigned-big-integer,<<(size(unicode:characters_to_binary(Desc))):32/unsigned-big-integer,(unicode:characters_to_binary(Desc))/binary>>/binary,(size(if is_binary(Lang) ->
        Lang;is_list(Lang) ->
        list_to_binary(Lang);Lang == undefined ->
        <<>> end)):32/unsigned-big-integer,if is_binary(Lang) ->
        Lang;is_list(Lang) ->
        list_to_binary(Lang);Lang == undefined ->
        <<>> end/binary>>;
encode(#ssh_msg_service_request{name = Service}) ->
    <<5:8/unsigned-big-integer,<<(size(unicode:characters_to_binary(Service))):32/unsigned-big-integer,(unicode:characters_to_binary(Service))/binary>>/binary>>;
encode(#ssh_msg_service_accept{name = Service}) ->
    <<6:8/unsigned-big-integer,<<(size(unicode:characters_to_binary(Service))):32/unsigned-big-integer,(unicode:characters_to_binary(Service))/binary>>/binary>>;
encode(#ssh_msg_ext_info{nr_extensions = N,data = Data}) ->
    lists:foldl(fun ({ExtName,ExtVal},Acc)->
        <<Acc/binary,(size(if is_binary(ExtName) ->
            ExtName;is_list(ExtName) ->
            list_to_binary(ExtName);ExtName == undefined ->
            <<>> end)):32/unsigned-big-integer,if is_binary(ExtName) ->
            ExtName;is_list(ExtName) ->
            list_to_binary(ExtName);ExtName == undefined ->
            <<>> end/binary,(size(if is_binary(ExtVal) ->
            ExtVal;is_list(ExtVal) ->
            list_to_binary(ExtVal);ExtVal == undefined ->
            <<>> end)):32/unsigned-big-integer,if is_binary(ExtVal) ->
            ExtVal;is_list(ExtVal) ->
            list_to_binary(ExtVal);ExtVal == undefined ->
            <<>> end/binary>> end,<<7:8/unsigned-big-integer,N:32/unsigned-big-integer>>,Data);
encode(#ssh_msg_newkeys{}) ->
    <<21:8/unsigned-big-integer>>;
encode(#ssh_msg_kexinit{cookie = Cookie,kex_algorithms = KeyAlgs,server_host_key_algorithms = HostKeyAlgs,encryption_algorithms_client_to_server = EncAlgC2S,encryption_algorithms_server_to_client = EncAlgS2C,mac_algorithms_client_to_server = MacAlgC2S,mac_algorithms_server_to_client = MacAlgS2C,compression_algorithms_client_to_server = CompAlgS2C,compression_algorithms_server_to_client = CompAlgC2S,languages_client_to_server = LangC2S,languages_server_to_client = LangS2C,first_kex_packet_follows = Bool,reserved = Reserved}) ->
    <<20:8/unsigned-big-integer,Cookie/binary,(size(ssh_bits:name_list(KeyAlgs))):32/unsigned-big-integer,(ssh_bits:name_list(KeyAlgs))/binary,(size(ssh_bits:name_list(HostKeyAlgs))):32/unsigned-big-integer,(ssh_bits:name_list(HostKeyAlgs))/binary,(size(ssh_bits:name_list(EncAlgC2S))):32/unsigned-big-integer,(ssh_bits:name_list(EncAlgC2S))/binary,(size(ssh_bits:name_list(EncAlgS2C))):32/unsigned-big-integer,(ssh_bits:name_list(EncAlgS2C))/binary,(size(ssh_bits:name_list(MacAlgC2S))):32/unsigned-big-integer,(ssh_bits:name_list(MacAlgC2S))/binary,(size(ssh_bits:name_list(MacAlgS2C))):32/unsigned-big-integer,(ssh_bits:name_list(MacAlgS2C))/binary,(size(ssh_bits:name_list(CompAlgS2C))):32/unsigned-big-integer,(ssh_bits:name_list(CompAlgS2C))/binary,(size(ssh_bits:name_list(CompAlgC2S))):32/unsigned-big-integer,(ssh_bits:name_list(CompAlgC2S))/binary,(size(ssh_bits:name_list(LangC2S))):32/unsigned-big-integer,(ssh_bits:name_list(LangC2S))/binary,(size(ssh_bits:name_list(LangS2C))):32/unsigned-big-integer,(ssh_bits:name_list(LangS2C))/binary,case Bool of
        true->
            1;
        false->
            0
    end:8/unsigned-big-integer,Reserved:32/unsigned-big-integer>>;
encode(#ssh_msg_kexdh_init{e = E}) ->
    <<30:8/unsigned-big-integer,(ssh_bits:mpint(E))/binary>>;
encode(#ssh_msg_kexdh_reply{public_host_key = {Key,SigAlg},f = F,h_sig = Signature}) ->
    EncKey = ssh2_pubkey_encode(Key),
    EncSign = encode_signature(Key,SigAlg,Signature),
    <<31:8/unsigned-big-integer,(size(EncKey)):32/unsigned-big-integer,EncKey/binary,(ssh_bits:mpint(F))/binary,(size(EncSign)):32/unsigned-big-integer,EncSign/binary>>;
encode(#ssh_msg_kex_dh_gex_request{min = Min,n = N,max = Max}) ->
    <<34:8/unsigned-big-integer,Min:32/unsigned-big-integer,N:32/unsigned-big-integer,Max:32/unsigned-big-integer>>;
encode(#ssh_msg_kex_dh_gex_request_old{n = N}) ->
    <<30:8/unsigned-big-integer,N:32/unsigned-big-integer>>;
encode(#ssh_msg_kex_dh_gex_group{p = Prime,g = Generator}) ->
    <<31:8/unsigned-big-integer,(ssh_bits:mpint(Prime))/binary,(ssh_bits:mpint(Generator))/binary>>;
encode(#ssh_msg_kex_dh_gex_init{e = Public}) ->
    <<32:8/unsigned-big-integer,(ssh_bits:mpint(Public))/binary>>;
encode(#ssh_msg_kex_dh_gex_reply{public_host_key = {Key,SigAlg},f = F,h_sig = Signature}) ->
    EncKey = ssh2_pubkey_encode(Key),
    EncSign = encode_signature(Key,SigAlg,Signature),
    <<33:8/unsigned-big-integer,(size(EncKey)):32/unsigned-big-integer,EncKey/binary,(ssh_bits:mpint(F))/binary,(size(EncSign)):32/unsigned-big-integer,EncSign/binary>>;
encode(#ssh_msg_kex_ecdh_init{q_c = Q_c}) ->
    <<30:8/unsigned-big-integer,(size(Q_c)):32/unsigned-big-integer,Q_c/binary>>;
encode(#ssh_msg_kex_ecdh_reply{public_host_key = {Key,SigAlg},q_s = Q_s,h_sig = Sign}) ->
    EncKey = ssh2_pubkey_encode(Key),
    EncSign = encode_signature(Key,SigAlg,Sign),
    <<31:8/unsigned-big-integer,(size(EncKey)):32/unsigned-big-integer,EncKey/binary,(size(Q_s)):32/unsigned-big-integer,Q_s/binary,(size(EncSign)):32/unsigned-big-integer,EncSign/binary>>;
encode(#ssh_msg_ignore{data = Data}) ->
    <<2:8/unsigned-big-integer,<<(size(unicode:characters_to_binary(Data))):32/unsigned-big-integer,(unicode:characters_to_binary(Data))/binary>>/binary>>;
encode(#ssh_msg_unimplemented{sequence = Seq}) ->
    <<3:8/unsigned-big-integer,Seq:32/unsigned-big-integer>>;
encode(#ssh_msg_debug{always_display = Bool,message = Msg,language = Lang}) ->
    <<4:8/unsigned-big-integer,case Bool of
        true->
            1;
        false->
            0
    end:8/unsigned-big-integer,<<(size(unicode:characters_to_binary(Msg))):32/unsigned-big-integer,(unicode:characters_to_binary(Msg))/binary>>/binary,(size(if is_binary(Lang) ->
        Lang;is_list(Lang) ->
        list_to_binary(Lang);Lang == undefined ->
        <<>> end)):32/unsigned-big-integer,if is_binary(Lang) ->
        Lang;is_list(Lang) ->
        list_to_binary(Lang);Lang == undefined ->
        <<>> end/binary>>.

decode(<<80:8/unsigned-big-integer,__0:32/unsigned-big-integer,Name:__0/binary,Bool:8/unsigned-big-integer,Data/binary>>) ->
    #ssh_msg_global_request{name = Name,want_reply = erl_boolean(Bool),data = Data};
decode(<<81:8/unsigned-big-integer,Data/binary>>) ->
    #ssh_msg_request_success{data = Data};
decode(<<82:8/unsigned-big-integer>>) ->
    #ssh_msg_request_failure{};
decode(<<90:8/unsigned-big-integer,__0:32/unsigned-big-integer,Type:__0/binary,Sender:32/unsigned-big-integer,Window:32/unsigned-big-integer,Max:32/unsigned-big-integer,Data/binary>>) ->
    #ssh_msg_channel_open{channel_type = binary_to_list(Type),sender_channel = Sender,initial_window_size = Window,maximum_packet_size = Max,data = Data};
decode(<<91:8/unsigned-big-integer,Recipient:32/unsigned-big-integer,Sender:32/unsigned-big-integer,InitWindowSize:32/unsigned-big-integer,MaxPacketSize:32/unsigned-big-integer,Data/binary>>) ->
    #ssh_msg_channel_open_confirmation{recipient_channel = Recipient,sender_channel = Sender,initial_window_size = InitWindowSize,maximum_packet_size = MaxPacketSize,data = Data};
decode(<<92:8/unsigned-big-integer,Recipient:32/unsigned-big-integer,Reason:32/unsigned-big-integer,__0:32/unsigned-big-integer,Desc:__0/binary,__1:32/unsigned-big-integer,Lang:__1/binary>>) ->
    #ssh_msg_channel_open_failure{recipient_channel = Recipient,reason = Reason,description = ucl(Desc),lang = Lang};
decode(<<93:8/unsigned-big-integer,Recipient:32/unsigned-big-integer,Bytes:32/unsigned-big-integer>>) ->
    #ssh_msg_channel_window_adjust{recipient_channel = Recipient,bytes_to_add = Bytes};
decode(<<94:8/unsigned-big-integer,Recipient:32/unsigned-big-integer,__0:32/unsigned-big-integer,Data:__0/binary>>) ->
    #ssh_msg_channel_data{recipient_channel = Recipient,data = Data};
decode(<<95:8/unsigned-big-integer,Recipient:32/unsigned-big-integer,DataType:32/unsigned-big-integer,__0:32/unsigned-big-integer,Data:__0/binary>>) ->
    #ssh_msg_channel_extended_data{recipient_channel = Recipient,data_type_code = DataType,data = Data};
decode(<<96:8/unsigned-big-integer,Recipient:32/unsigned-big-integer>>) ->
    #ssh_msg_channel_eof{recipient_channel = Recipient};
decode(<<97:8/unsigned-big-integer,Recipient:32/unsigned-big-integer>>) ->
    #ssh_msg_channel_close{recipient_channel = Recipient};
decode(<<98:8/unsigned-big-integer,Recipient:32/unsigned-big-integer,__0:32/unsigned-big-integer,RequestType:__0/binary,Bool:8/unsigned-big-integer,Data/binary>> = Bytes) ->
    try #ssh_msg_channel_request{recipient_channel = Recipient,request_type = ucl(RequestType),want_reply = erl_boolean(Bool),data = Data}
        catch
            _:_->
                #ssh_msg_channel_request{recipient_channel = Recipient,request_type = faulty_msg,data = Bytes} end;
decode(<<99:8/unsigned-big-integer,Recipient:32/unsigned-big-integer>>) ->
    #ssh_msg_channel_success{recipient_channel = Recipient};
decode(<<100:8/unsigned-big-integer,Recipient:32/unsigned-big-integer>>) ->
    #ssh_msg_channel_failure{recipient_channel = Recipient};
decode(<<50:8/unsigned-big-integer,__0:32/unsigned-big-integer,User:__0/binary,__1:32/unsigned-big-integer,Service:__1/binary,__2:32/unsigned-big-integer,Method:__2/binary,Data/binary>>) ->
    #ssh_msg_userauth_request{user = ucl(User),service = ucl(Service),method = ucl(Method),data = Data};
decode(<<51:8/unsigned-big-integer,__0:32/unsigned-big-integer,Auths:__0/binary,Bool:8/unsigned-big-integer>>) ->
    #ssh_msg_userauth_failure{authentications = ucl(Auths),partial_success = erl_boolean(Bool)};
decode(<<52:8/unsigned-big-integer>>) ->
    #ssh_msg_userauth_success{};
decode(<<53:8/unsigned-big-integer,__0:32/unsigned-big-integer,Banner:__0/binary,__1:32/unsigned-big-integer,Lang:__1/binary>>) ->
    #ssh_msg_userauth_banner{message = Banner,language = Lang};
decode(<<60:8/unsigned-big-integer,__0:32/unsigned-big-integer,Name:__0/binary,__1:32/unsigned-big-integer,Inst:__1/binary,__2:32/unsigned-big-integer,Lang:__2/binary,NumPromtps:32/unsigned-big-integer,Data/binary>>) ->
    #ssh_msg_userauth_info_request{name = Name,instruction = Inst,language_tag = Lang,num_prompts = NumPromtps,data = Data};
decode(<<60:8/unsigned-big-integer,__0:32/unsigned-big-integer,Prompt:__0/binary,__1:32/unsigned-big-integer,Lang:__1/binary>>) ->
    #ssh_msg_userauth_passwd_changereq{prompt = Prompt,languge = Lang};
decode(<<60:8/unsigned-big-integer,__0:32/unsigned-big-integer,Alg:__0/binary,KeyBlob/binary>>) ->
    #ssh_msg_userauth_pk_ok{algorithm_name = Alg,key_blob = KeyBlob};
decode(<<61:8/unsigned-big-integer,Num:32/unsigned-big-integer,Data/binary>>) ->
    #ssh_msg_userauth_info_response{num_responses = Num,data = Data};
decode(<<7:8/unsigned-big-integer,N:32/unsigned-big-integer,BinData/binary>>) ->
    Data = bin_foldr(fun (Bin,Acc)
        when length(Acc) == N->
        {Bin,Acc};(<<__0:32/unsigned-big-integer,V0:__0/binary,__1:32/unsigned-big-integer,V1:__1/binary,Rest/binary>>,Acc)->
        {Rest,[{binary_to_list(V0),binary_to_list(V1)}| Acc]} end,[],BinData),
    #ssh_msg_ext_info{nr_extensions = N,data = Data};
decode(<<20:8/unsigned-big-integer,Cookie:128,Data/binary>>) ->
    decode_kex_init(Data,[Cookie, ssh_msg_kexinit],10);
decode(<<"dh",30:8/unsigned-big-integer,__0:32/unsigned-big-integer,E:__0/big-signed-integer-unit:8>>) ->
    #ssh_msg_kexdh_init{e = E};
decode(<<"dh",31:8/unsigned-big-integer,__0:32/unsigned-big-integer,Key:__0/binary,__1:32/unsigned-big-integer,F:__1/big-signed-integer-unit:8,__2:32/unsigned-big-integer,Hashsign:__2/binary>>) ->
    #ssh_msg_kexdh_reply{public_host_key = ssh2_pubkey_decode(Key),f = F,h_sig = decode_signature(Hashsign)};
decode(<<34:8/unsigned-big-integer,Min:32/unsigned-big-integer,N:32/unsigned-big-integer,Max:32/unsigned-big-integer>>) ->
    #ssh_msg_kex_dh_gex_request{min = Min,n = N,max = Max};
decode(<<"dh_gex",30:8/unsigned-big-integer,N:32/unsigned-big-integer>>) ->
    #ssh_msg_kex_dh_gex_request_old{n = N};
decode(<<"dh_gex",31:8/unsigned-big-integer,__0:32/unsigned-big-integer,Prime:__0/big-signed-integer-unit:8,__1:32/unsigned-big-integer,Generator:__1/big-signed-integer-unit:8>>) ->
    #ssh_msg_kex_dh_gex_group{p = Prime,g = Generator};
decode(<<32:8/unsigned-big-integer,__0:32/unsigned-big-integer,E:__0/big-signed-integer-unit:8>>) ->
    #ssh_msg_kex_dh_gex_init{e = E};
decode(<<33:8/unsigned-big-integer,__0:32/unsigned-big-integer,Key:__0/binary,__1:32/unsigned-big-integer,F:__1/big-signed-integer-unit:8,__2:32/unsigned-big-integer,Hashsign:__2/binary>>) ->
    #ssh_msg_kex_dh_gex_reply{public_host_key = ssh2_pubkey_decode(Key),f = F,h_sig = decode_signature(Hashsign)};
decode(<<"ecdh",30:8/unsigned-big-integer,__0:32/unsigned-big-integer,Q_c:__0/binary>>) ->
    #ssh_msg_kex_ecdh_init{q_c = Q_c};
decode(<<"ecdh",31:8/unsigned-big-integer,__1:32/unsigned-big-integer,Key:__1/binary,__2:32/unsigned-big-integer,Q_s:__2/binary,__3:32/unsigned-big-integer,Sig:__3/binary>>) ->
    #ssh_msg_kex_ecdh_reply{public_host_key = ssh2_pubkey_decode(Key),q_s = Q_s,h_sig = decode_signature(Sig)};
decode(<<5,__0:32/unsigned-big-integer,Service:__0/binary>>) ->
    #ssh_msg_service_request{name = ucl(Service)};
decode(<<6,__0:32/unsigned-big-integer,Service:__0/binary>>) ->
    #ssh_msg_service_accept{name = ucl(Service)};
decode(<<1:8/unsigned-big-integer,Code:32/unsigned-big-integer,__0:32/unsigned-big-integer,Desc:__0/binary,__1:32/unsigned-big-integer,Lang:__1/binary>>) ->
    #ssh_msg_disconnect{code = Code,description = ucl(Desc),language = Lang};
decode(<<1:8/unsigned-big-integer,Code:32/unsigned-big-integer,__0:32/unsigned-big-integer,Desc:__0/binary>>) ->
    #ssh_msg_disconnect{code = Code,description = ucl(Desc),language = <<"en">>};
decode(<<21>>) ->
    #ssh_msg_newkeys{};
decode(<<2:8/unsigned-big-integer,__0:32/unsigned-big-integer,Data:__0/binary>>) ->
    #ssh_msg_ignore{data = Data};
decode(<<3:8/unsigned-big-integer,Seq:32/unsigned-big-integer>>) ->
    #ssh_msg_unimplemented{sequence = Seq};
decode(<<4:8/unsigned-big-integer,Bool:8/unsigned-big-integer,__0:32/unsigned-big-integer,Msg:__0/binary,__1:32/unsigned-big-integer,Lang:__1/binary>>) ->
    #ssh_msg_debug{always_display = erl_boolean(Bool),message = Msg,language = Lang}.

ssh2_pubkey_encode(#'RSAPublicKey'{modulus = N,publicExponent = E}) ->
    <<(size(<<"ssh-rsa">>)):32/unsigned-big-integer,<<"ssh-rsa">>/binary,(ssh_bits:mpint(E))/binary,(ssh_bits:mpint(N))/binary>>;
ssh2_pubkey_encode({Y,#'Dss-Parms'{p = P,q = Q,g = G}}) ->
    <<(size(<<"ssh-dss">>)):32/unsigned-big-integer,<<"ssh-dss">>/binary,(ssh_bits:mpint(P))/binary,(ssh_bits:mpint(Q))/binary,(ssh_bits:mpint(G))/binary,(ssh_bits:mpint(Y))/binary>>;
ssh2_pubkey_encode({#'ECPoint'{point = Q},{namedCurve,OID}}) ->
    Curve = public_key:oid2ssh_curvename(OID),
    KeyType = <<"ecdsa-sha2-",Curve/binary>>,
    <<(size(KeyType)):32/unsigned-big-integer,KeyType/binary,(size(Curve)):32/unsigned-big-integer,Curve/binary,(size(if is_binary(Q) ->
        Q;is_list(Q) ->
        list_to_binary(Q);Q == undefined ->
        <<>> end)):32/unsigned-big-integer,if is_binary(Q) ->
        Q;is_list(Q) ->
        list_to_binary(Q);Q == undefined ->
        <<>> end/binary>>;
ssh2_pubkey_encode({ed_pub,ed25519,Key}) ->
    <<(size(<<"ssh-ed25519">>)):32/unsigned-big-integer,<<"ssh-ed25519">>/binary,(size(if is_binary(Key) ->
        Key;is_list(Key) ->
        list_to_binary(Key);Key == undefined ->
        <<>> end)):32/unsigned-big-integer,if is_binary(Key) ->
        Key;is_list(Key) ->
        list_to_binary(Key);Key == undefined ->
        <<>> end/binary>>;
ssh2_pubkey_encode({ed_pub,ed448,Key}) ->
    <<(size(<<"ssh-ed448">>)):32/unsigned-big-integer,<<"ssh-ed448">>/binary,(size(if is_binary(Key) ->
        Key;is_list(Key) ->
        list_to_binary(Key);Key == undefined ->
        <<>> end)):32/unsigned-big-integer,if is_binary(Key) ->
        Key;is_list(Key) ->
        list_to_binary(Key);Key == undefined ->
        <<>> end/binary>>.

ssh2_pubkey_decode(KeyBlob) ->
    {Key,_RestBlob} = ssh2_pubkey_decode2(KeyBlob),
    Key.

ssh2_pubkey_decode2(<<7:32/unsigned-big-integer,"ssh-rsa",_EL:32/unsigned-big-integer,E:_EL/big-signed-integer-unit:8,_NL:32/unsigned-big-integer,N:_NL/big-signed-integer-unit:8,Rest/binary>>) ->
    {#'RSAPublicKey'{modulus = N,publicExponent = E},Rest};
ssh2_pubkey_decode2(<<7:32/unsigned-big-integer,"ssh-dss",_PL:32/unsigned-big-integer,P:_PL/big-signed-integer-unit:8,_QL:32/unsigned-big-integer,Q:_QL/big-signed-integer-unit:8,_GL:32/unsigned-big-integer,G:_GL/big-signed-integer-unit:8,_YL:32/unsigned-big-integer,Y:_YL/big-signed-integer-unit:8,Rest/binary>>) ->
    {{Y,#'Dss-Parms'{p = P,q = Q,g = G}},Rest};
ssh2_pubkey_decode2(<<TL:32/unsigned-big-integer,"ecdsa-sha2-",KeyRest/binary>>) ->
    Sz = TL - 11,
    <<_Curve:Sz/binary,_IL:32/unsigned-big-integer,SshName:_IL/binary,_QL:32/unsigned-big-integer,Q:_QL/binary,Rest/binary>> = KeyRest,
    OID = public_key:ssh_curvename2oid(SshName),
    {{#'ECPoint'{point = Q},{namedCurve,OID}},Rest};
ssh2_pubkey_decode2(<<11:32/unsigned-big-integer,"ssh-ed25519",_L:32/unsigned-big-integer,Key:_L/binary,Rest/binary>>) ->
    {{ed_pub,ed25519,Key},Rest};
ssh2_pubkey_decode2(<<9:32/unsigned-big-integer,"ssh-ed448",_L:32/unsigned-big-integer,Key:_L/binary,Rest/binary>>) ->
    {{ed_pub,ed448,Key},Rest}.

ssh2_privkey_decode2(<<7:32/unsigned-big-integer,"ssh-rsa",_NL:32/unsigned-big-integer,N:_NL/big-signed-integer-unit:8,_EL:32/unsigned-big-integer,E:_EL/big-signed-integer-unit:8,_DL:32/unsigned-big-integer,D:_DL/big-signed-integer-unit:8,_IQMPL:32/unsigned-big-integer,IQMP:_IQMPL/big-signed-integer-unit:8,_PL:32/unsigned-big-integer,P:_PL/big-signed-integer-unit:8,_QL:32/unsigned-big-integer,Q:_QL/big-signed-integer-unit:8,Rest/binary>>) ->
    {#'RSAPrivateKey'{version = two-prime,modulus = N,publicExponent = E,privateExponent = D,prime1 = P,prime2 = Q,coefficient = IQMP},Rest};
ssh2_privkey_decode2(<<7:32/unsigned-big-integer,"ssh-dss",_PL:32/unsigned-big-integer,P:_PL/big-signed-integer-unit:8,_QL:32/unsigned-big-integer,Q:_QL/big-signed-integer-unit:8,_GL:32/unsigned-big-integer,G:_GL/big-signed-integer-unit:8,_YL:32/unsigned-big-integer,Y:_YL/big-signed-integer-unit:8,_XL:32/unsigned-big-integer,X:_XL/big-signed-integer-unit:8,Rest/binary>>) ->
    {#'DSAPrivateKey'{version = 0,p = P,q = Q,g = G,y = Y,x = X},Rest};
ssh2_privkey_decode2(<<TL:32/unsigned-big-integer,"ecdsa-sha2-",KeyRest/binary>>) ->
    Sz = TL - 11,
    <<_Curve:Sz/binary,_SNN:32/unsigned-big-integer,CurveName:_SNN/binary,_QL:32/unsigned-big-integer,Q:_QL/binary,_PrivL:32/unsigned-big-integer,Priv:_PrivL/binary,Rest/binary>> = KeyRest,
    OID = public_key:ssh_curvename2oid(CurveName),
    {#'ECPrivateKey'{version = 1,parameters = {namedCurve,OID},privateKey = Priv,publicKey = Q},Rest};
ssh2_privkey_decode2(<<11:32/unsigned-big-integer,"ssh-ed25519",_Lpub:32/unsigned-big-integer,Pub:_Lpub/binary,_Lpriv:32/unsigned-big-integer,Priv:_Lpriv/binary,Rest/binary>>) ->
    {{ed_pri,ed25519,Pub,Priv},Rest};
ssh2_privkey_decode2(<<9:32/unsigned-big-integer,"ssh-ed448",_Lpub:32/unsigned-big-integer,Pub:_Lpub/binary,_Lpriv:32/unsigned-big-integer,Priv:_Lpriv/binary,Rest/binary>>) ->
    {{ed_pri,ed448,Pub,Priv},Rest}.

bin_foldr(Fun,Acc,Bin) ->
    lists:reverse(bin_foldl(Fun,Acc,Bin)).

bin_foldl(_,Acc,<<>>) ->
    Acc;
bin_foldl(Fun,Acc0,Bin0) ->
    case Fun(Bin0,Acc0) of
        {Bin0,Acc0}->
            Acc0;
        {Bin,Acc}->
            bin_foldl(Fun,Acc,Bin)
    end.

decode_keyboard_interactive_prompts(<<>>,Acc) ->
    lists:reverse(Acc);
decode_keyboard_interactive_prompts(<<0>>,Acc) ->
    lists:reverse(Acc);
decode_keyboard_interactive_prompts(<<__0:32/unsigned-big-integer,Prompt:__0/binary,Bool:8/unsigned-big-integer,Bin/binary>>,Acc) ->
    decode_keyboard_interactive_prompts(Bin,[{Prompt,erl_boolean(Bool)}| Acc]).

erl_boolean(0) ->
    false;
erl_boolean(1) ->
    true.

decode_kex_init(<<Bool:8/unsigned-big-integer,X:32/unsigned-big-integer>>,Acc,0) ->
    list_to_tuple(lists:reverse([X, erl_boolean(Bool)| Acc]));
decode_kex_init(<<Bool:8/unsigned-big-integer>>,Acc,0) ->
    X = 0,
    list_to_tuple(lists:reverse([X, erl_boolean(Bool)| Acc]));
decode_kex_init(<<__0:32/unsigned-big-integer,Data:__0/binary,Rest/binary>>,Acc,N) ->
    Names = string:tokens(ucl(Data),","),
    decode_kex_init(Rest,[Names| Acc],N - 1).

decode_signature(<<__0:32/unsigned-big-integer,Alg:__0/binary,_:32/unsigned-big-integer,Signature/binary>>) ->
    {binary_to_list(Alg),Signature}.

encode_signature(#'RSAPublicKey'{},SigAlg,Signature) ->
    SignName = list_to_binary(atom_to_list(SigAlg)),
    <<(size(SignName)):32/unsigned-big-integer,SignName/binary,(size(Signature)):32/unsigned-big-integer,Signature/binary>>;
encode_signature({_,#'Dss-Parms'{}},_SigAlg,Signature) ->
    <<(size(<<"ssh-dss">>)):32/unsigned-big-integer,<<"ssh-dss">>/binary,(size(Signature)):32/unsigned-big-integer,Signature/binary>>;
encode_signature({#'ECPoint'{},{namedCurve,OID}},_SigAlg,Signature) ->
    Curve = public_key:oid2ssh_curvename(OID),
    <<(size(<<"ecdsa-sha2-",Curve/binary>>)):32/unsigned-big-integer,<<"ecdsa-sha2-",Curve/binary>>/binary,(size(Signature)):32/unsigned-big-integer,Signature/binary>>;
encode_signature({ed_pub,ed25519,_},_SigAlg,Signature) ->
    <<(size(<<"ssh-ed25519">>)):32/unsigned-big-integer,<<"ssh-ed25519">>/binary,(size(Signature)):32/unsigned-big-integer,Signature/binary>>;
encode_signature({ed_pub,ed448,_},_SigAlg,Signature) ->
    <<(size(<<"ssh-ed448">>)):32/unsigned-big-integer,<<"ssh-ed448">>/binary,(size(Signature)):32/unsigned-big-integer,Signature/binary>>.

ssh_dbg_trace_points() ->
    [ssh_messages, raw_messages].

ssh_dbg_flags(ssh_messages) ->
    [c];
ssh_dbg_flags(raw_messages) ->
    [c].

ssh_dbg_on(P)
    when P == ssh_messages;
    P == raw_messages->
    dbg:tp(ssh_message,encode,1,x),
    dbg:tp(ssh_message,decode,1,x).

ssh_dbg_off(P)
    when P == ssh_messages;
    P == raw_messages->
    dbg:ctpg(ssh_message,encode,1),
    dbg:ctpg(ssh_message,decode,1).

ssh_dbg_format(ssh_messages,{call,{ssh_message,encode,[Msg]}}) ->
    Name = string:to_upper(atom_to_list(element(1,Msg))),
    ["Going to send ", Name, ":\n", wr_record(ssh_dbg:shrink_bin(Msg))];
ssh_dbg_format(ssh_messages,{return_from,{ssh_message,encode,1},_Ret}) ->
    skip;
ssh_dbg_format(ssh_messages,{call,{ssh_message,decode,[_]}}) ->
    skip;
ssh_dbg_format(ssh_messages,{return_from,{ssh_message,decode,1},Msg}) ->
    Name = string:to_upper(atom_to_list(element(1,Msg))),
    ["Received ", Name, ":\n", wr_record(ssh_dbg:shrink_bin(Msg))];
ssh_dbg_format(raw_messages,{call,{ssh_message,decode,[BytesPT]}}) ->
    ["Received plain text bytes (shown after decryption):\n", io_lib:format("~p",[BytesPT])];
ssh_dbg_format(raw_messages,{return_from,{ssh_message,decode,1},_Ret}) ->
    skip;
ssh_dbg_format(raw_messages,{call,{ssh_message,encode,[_]}}) ->
    skip;
ssh_dbg_format(raw_messages,{return_from,{ssh_message,encode,1},BytesPT}) ->
    ["Going to send plain text bytes (shown before encryption):\n", io_lib:format("~p",[BytesPT])].

wr_record(R = #ssh_msg_disconnect{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_disconnect),[]);
wr_record(R = #ssh_msg_ignore{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_ignore),[]);
wr_record(R = #ssh_msg_unimplemented{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_unimplemented),[]);
wr_record(R = #ssh_msg_debug{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_debug),[]);
wr_record(R = #ssh_msg_service_request{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_service_request),[]);
wr_record(R = #ssh_msg_service_accept{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_service_accept),[]);
wr_record(R = #ssh_msg_kexinit{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_kexinit),[]);
wr_record(R = #ssh_msg_kexdh_init{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_kexdh_init),[]);
wr_record(R = #ssh_msg_kexdh_reply{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_kexdh_reply),[]);
wr_record(R = #ssh_msg_newkeys{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_newkeys),[]);
wr_record(R = #ssh_msg_ext_info{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_ext_info),[]);
wr_record(R = #ssh_msg_kex_dh_gex_request{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_kex_dh_gex_request),[]);
wr_record(R = #ssh_msg_kex_dh_gex_request_old{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_kex_dh_gex_request_old),[]);
wr_record(R = #ssh_msg_kex_dh_gex_group{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_kex_dh_gex_group),[]);
wr_record(R = #ssh_msg_kex_dh_gex_init{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_kex_dh_gex_init),[]);
wr_record(R = #ssh_msg_kex_dh_gex_reply{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_kex_dh_gex_reply),[]);
wr_record(R = #ssh_msg_kex_ecdh_init{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_kex_ecdh_init),[]);
wr_record(R = #ssh_msg_kex_ecdh_reply{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_kex_ecdh_reply),[]);
wr_record(R = #ssh_msg_userauth_request{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_userauth_request),[]);
wr_record(R = #ssh_msg_userauth_failure{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_userauth_failure),[]);
wr_record(R = #ssh_msg_userauth_success{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_userauth_success),[]);
wr_record(R = #ssh_msg_userauth_banner{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_userauth_banner),[]);
wr_record(R = #ssh_msg_userauth_passwd_changereq{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_userauth_passwd_changereq),[]);
wr_record(R = #ssh_msg_userauth_pk_ok{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_userauth_pk_ok),[]);
wr_record(R = #ssh_msg_userauth_info_request{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_userauth_info_request),[]);
wr_record(R = #ssh_msg_userauth_info_response{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_userauth_info_response),[]);
wr_record(R = #ssh_msg_global_request{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_global_request),[]);
wr_record(R = #ssh_msg_request_success{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_request_success),[]);
wr_record(R = #ssh_msg_request_failure{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_request_failure),[]);
wr_record(R = #ssh_msg_channel_open{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_channel_open),[]);
wr_record(R = #ssh_msg_channel_open_confirmation{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_channel_open_confirmation),[]);
wr_record(R = #ssh_msg_channel_open_failure{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_channel_open_failure),[]);
wr_record(R = #ssh_msg_channel_window_adjust{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_channel_window_adjust),[]);
wr_record(R = #ssh_msg_channel_data{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_channel_data),[]);
wr_record(R = #ssh_msg_channel_extended_data{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_channel_extended_data),[]);
wr_record(R = #ssh_msg_channel_eof{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_channel_eof),[]);
wr_record(R = #ssh_msg_channel_close{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_channel_close),[]);
wr_record(R = #ssh_msg_channel_request{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_channel_request),[]);
wr_record(R = #ssh_msg_channel_success{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_channel_success),[]);
wr_record(R = #ssh_msg_channel_failure{}) ->
    ssh_dbg:wr_record(R,record_info(fields,ssh_msg_channel_failure),[]);
wr_record(R) ->
    io_lib:format('~p~n',[R]).
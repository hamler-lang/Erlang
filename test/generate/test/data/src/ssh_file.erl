-file("ssh_file.erl", 1).

-module(ssh_file).

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

-file("ssh_file.erl", 28).

-file("/usr/lib/erlang/lib/kernel-7.2/include/file.hrl", 1).

-record(file_info,{size::non_neg_integer()|undefined,type::device|directory|other|regular|symlink|undefined,access::read|write|read_write|none|undefined,atime::file:date_time()|non_neg_integer()|undefined,mtime::file:date_time()|non_neg_integer()|undefined,ctime::file:date_time()|non_neg_integer()|undefined,mode::non_neg_integer()|undefined,links::non_neg_integer()|undefined,major_device::non_neg_integer()|undefined,minor_device::non_neg_integer()|undefined,inode::non_neg_integer()|undefined,uid::non_neg_integer()|undefined,gid::non_neg_integer()|undefined}).

-record(file_descriptor,{module::module(),data::term()}).

-file("ssh_file.erl", 29).

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

-file("ssh_file.erl", 31).

-export([decode_ssh_file/4]).

-behaviour(ssh_server_key_api).

-export([host_key/2, is_auth_key/3]).

-export_type([system_dir_daemon_option/0]).

-type(system_dir_daemon_option()::{system_dir,string()}).

-behaviour(ssh_client_key_api).

-export([is_host_key/5, user_key/2, add_host_key/4]).

-export_type([pubkey_passphrase_client_options/0]).

-type(pubkey_passphrase_client_options()::{dsa_pass_phrase,string()}|{rsa_pass_phrase,string()}|{ecdsa_pass_phrase,string()}).

-export_type([user_dir_common_option/0, user_dir_fun_common_option/0]).

-type(user_dir_common_option()::{user_dir,string()}).

-type(user_dir_fun_common_option()::{user_dir_fun,user2dir()}).

-type(user2dir()::fun((RemoteUserName::string()) -> UserDir::string())).

-type(optimize_key_lookup()::{optimize,time|space}).

-spec(host_key(Algorithm,Options) -> Result when Algorithm::ssh:pubkey_alg(),Result::{ok,public_key:private_key()}|{error,term()},Options::ssh_server_key_api:daemon_key_cb_options(none())).

host_key(Algorithm,Opts) ->
    read_ssh_key_file(system,private,Algorithm,Opts).

-spec(is_auth_key(Key,User,Options) -> boolean() when Key::public_key:public_key(),User::string(),Options::ssh_server_key_api:daemon_key_cb_options(optimize_key_lookup())).

is_auth_key(Key0,User,Opts) ->
    Dir = ssh_dir({remoteuser,User},Opts),
    ok = assure_file_mode(Dir,user_read),
    KeyType = normalize_alg(atom_to_binary(ssh_transport:public_algo(Key0),latin1)),
    Key = encode_key(Key0),
    lookup_auth_keys(KeyType,Key,filename:join(Dir,"authorized_keys"),Opts) orelse lookup_auth_keys(KeyType,Key,filename:join(Dir,"authorized_keys2"),Opts).

-spec(user_key(Algorithm,Options) -> Result when Algorithm::ssh:pubkey_alg(),Result::{ok,public_key:private_key()}|{error,string()},Options::ssh_client_key_api:client_key_cb_options(none())).

user_key(Algorithm,Opts) ->
    read_ssh_key_file(user,private,Algorithm,Opts).

-spec(is_host_key(Key,Host,Port,Algorithm,Options) -> Result when Key::public_key:public_key(),Host::inet:ip_address()|inet:hostname()|[inet:ip_address()|inet:hostname()],Port::inet:port_number(),Algorithm::ssh:pubkey_alg(),Options::ssh_client_key_api:client_key_cb_options(optimize_key_lookup()),Result::boolean()|{error,term()}).

is_host_key(Key0,Hosts0,Port,Algorithm,Opts) ->
    Dir = ssh_dir(user,Opts),
    File = filename:join(Dir,"known_hosts"),
    Hosts = [(list_to_binary(H)) || H <- normalize_hosts_list(Hosts0,Port)],
    KeyType = normalize_alg(atom_to_binary(Algorithm,latin1)),
    Key = encode_key(Key0),
    ok = assure_file_mode(File,user_read),
    lookup_host_keys(Hosts,KeyType,Key,File,Opts).

-spec(add_host_key(Host,Port,Key,Options) -> Result when Host::inet:ip_address()|inet:hostname()|[inet:ip_address()|inet:hostname()],Port::inet:port_number(),Key::public_key:public_key(),Options::ssh_client_key_api:client_key_cb_options(none()),Result::ok|{error,term()}).

add_host_key(Hosts0,Port,Key,Opts) ->
    File = file_name(user,"known_hosts",Opts),
    assure_file_mode(File,user_write),
    case file:open(File,[write, append]) of
        {ok,Fd}->
            KeyType = atom_to_binary(ssh_transport:public_algo(Key),latin1),
            EncKey = ssh_message:ssh2_pubkey_encode(Key),
            Hosts1 = normalize_hosts_list(Hosts0,Port),
            SshBin = iolist_to_binary(["\n", lists:join(",",Hosts1), " ", KeyType, " ", base64:encode(iolist_to_binary(EncKey)), "\n"]),
            Res = file:write(Fd,SshBin),
            file:close(Fd),
            Res;
        {error,Error}->
            {error,{add_host_key,Error}}
    end.

lookup_auth_keys(KeyType,Key,File,Opts) ->
    case get_kb_option(optimize,Opts,time) of
        time->
            case file:read_file(File) of
                {ok,Bin}->
                    Lines = binary:split(Bin,<<"\n">>,[global, trim_all]),
                    find_key(KeyType,Key,Lines);
                _->
                    false
            end;
        space->
            case file:open(File,[read, binary]) of
                {ok,Fd}->
                    Result = read_test_loop(Fd,fun (Line)->
                        find_key(KeyType,Key,[Line]) end),
                    file:close(Fd),
                    Result;
                {error,_Error}->
                    false
            end;
        Other->
            {error,{is_auth_key,{opt,Other}}}
    end.

find_key(KeyType,Key,[<<"#",_/binary>>| Lines]) ->
    find_key(KeyType,Key,Lines);
find_key(KeyType,Key,[Line| Lines]) ->
    try [E1, E2| Es] = binary:split(Line,<<" ">>,[global, trim_all]),
    [normalize_alg(E1), normalize_alg(E2)| Es] of 
        [_Options, KeyType, Key| _Comment]->
            true;
        [KeyType, Key| _Comment]->
            true;
        _->
            find_key(KeyType,Key,Lines)
        catch
            _:_->
                find_key(KeyType,Key,Lines) end;
find_key(_,_,_) ->
    false.

normalize_alg(<<"rsa-sha2-",_/binary>>) ->
    <<"ssh-rsa">>;
normalize_alg(X) ->
    X.

normalize_hosts_list(Hosts,Port)
    when is_list(hd(Hosts))->
    lists:reverse(lists:foldl(fun (H0,Acc)->
        H1s = add_ip(replace_localhost(H0)),
        Hs = case Port of
            22->
                H1s;
            _->
                [(lists:concat(["[", Hx, "]:", Port])) || Hx <- H1s]
        end,
        lists:foldl(fun (Hy,Acc2)->
            case lists:member(Hy,Acc2) of
                true->
                    Acc2;
                false->
                    [Hy| Acc2]
            end end,Acc,Hs) end,[],Hosts));
normalize_hosts_list(Hosts,Port) ->
    normalize_hosts_list([Hosts],Port).

replace_localhost(any) ->
    replace_localhost("localhost");
replace_localhost(loopback) ->
    replace_localhost("localhost");
replace_localhost("localhost") ->
    {ok,Hostname} = inet:gethostname(),
    Hostname;
replace_localhost(H)
    when is_atom(H)->
    replace_localhost(atom_to_list(H));
replace_localhost(Host) ->
    Host.

add_ip(IP)
    when is_tuple(IP)->
    [ssh_connection:encode_ip(IP)];
add_ip(Host) ->
    case inet:getaddr(Host,inet) of
        {ok,Addr}->
            case ssh_connection:encode_ip(Addr) of
                false->
                    [Host];
                Host->
                    [Host];
                IPString->
                    [Host, IPString]
            end;
        _->
            [Host]
    end.

encode_key(Key) ->
    base64:encode(iolist_to_binary(ssh_message:ssh2_pubkey_encode(Key))).

read_test_loop(Fd,Test) ->
    case io:get_line(Fd,) of
        eof->
            file:close(Fd),
            false;
        {error,Error}->
            {error,Error};
        Line0->
            case binary:split(Line0,<<"\n">>,[global, trim_all]) of
                [Line]->
                    case Test(Line) of
                        false->
                            read_test_loop(Fd,Test);
                        Other->
                            Other
                    end;
                _->
                    read_test_loop(Fd,Test)
            end
    end.

lookup_host_keys(Hosts,KeyType,Key,File,Opts) ->
    case get_kb_option(optimize,Opts,time) of
        time->
            case file:read_file(File) of
                {ok,Bin}->
                    Lines = binary:split(Bin,<<"\n">>,[global, trim_all]),
                    case find_host_key(Hosts,KeyType,Key,Lines) of
                        {true,RestLines}->
                            case revoked_key(Hosts,KeyType,Key,RestLines) of
                                true->
                                    {error,revoked_key};
                                false->
                                    true
                            end;
                        false->
                            false
                    end;
                {error,enoent}->
                    false;
                {error,Error}->
                    {error,{is_host_key,Error}}
            end;
        space->
            case file:open(File,[read, binary]) of
                {ok,Fd}->
                    Result = case read_test_loop(Fd,fun (Line)->
                        find_host_key(Hosts,KeyType,Key,[Line]) end) of
                        {true,_}->
                            case read_test_loop(Fd,fun (Line)->
                                revoked_key(Hosts,KeyType,Key,[Line]) end) of
                                true->
                                    {error,revoked_key};
                                false->
                                    true
                            end;
                        {error,Error}->
                            {error,{is_host_key,Error}};
                        Other->
                            Other
                    end,
                    file:close(Fd),
                    Result;
                {error,Error}->
                    {error,Error}
            end;
        Other->
            {error,{is_host_key,{opt,Other}}}
    end.

find_host_key(Hosts,KeyType,EncKey,[<<"#",_/binary>>| PatternLines]) ->
    find_host_key(Hosts,KeyType,EncKey,PatternLines);
find_host_key(Hosts,KeyType,EncKey,[Line| PatternLines]) ->
    SplitLine = binary:split(Line,<<" ">>,[global, trim_all]),
    case known_key_in_line(Hosts,KeyType,EncKey,SplitLine) of
        true->
            {true,PatternLines};
        false->
            find_host_key(Hosts,KeyType,EncKey,PatternLines)
    end;
find_host_key(_,_,_,[]) ->
    false.

revoked_key(Hosts,KeyType,EncKey,[<<"@revoked ",RestLine/binary>>| Lines]) ->
    case binary:split(RestLine,<<" ">>,[global, trim_all]) of
        [Patterns, KeyType, EncKey| _Comment]->
            case host_match(Hosts,Patterns) of
                true->
                    true;
                false->
                    revoked_key(Hosts,KeyType,EncKey,Lines)
            end;
        _->
            revoked_key(Hosts,KeyType,EncKey,Lines)
    end;
revoked_key(Hosts,KeyType,EncKey,[_| Lines]) ->
    revoked_key(Hosts,KeyType,EncKey,Lines);
revoked_key(_,_,_,_) ->
    false.

known_key_in_line(Hosts,KeyType,EncKey,FullLine = [Option| Rest]) ->
    case line_match(Hosts,KeyType,EncKey,Rest) of
        true->
            case Option of
                <<"@revoked">>->
                    {error,revoked_key};
                _->
                    false
            end;
        false->
            line_match(Hosts,KeyType,EncKey,FullLine)
    end;
known_key_in_line(_,_,_,_) ->
    false.

line_match(Hosts,KeyType,EncKey,[Patterns, KeyType0, EncKey0| _Comment]) ->
    KeyType == normalize_alg(KeyType0) andalso EncKey == EncKey0 andalso host_match(Hosts,Patterns);
line_match(_,_,_,_) ->
    false.

host_match(Hosts,Patterns) ->
    PatternList = binary:split(Patterns,<<",">>,[global]),
    host_matchL(Hosts,PatternList).

host_matchL([H| Hosts],Patterns) ->
    case one_host_match(H,Patterns) of
        true->
            true;
        false->
            host_matchL(Hosts,Patterns)
    end;
host_matchL(_,_) ->
    false.

one_host_match(H,[Pat| Patterns]) ->
    case pos_match(H,Pat) of
        true->
             not lists:any(fun (P)->
                neg_match(H,P) end,Patterns);
        false->
            one_host_match(H,Patterns)
    end;
one_host_match(_,_) ->
    false.

neg_match(H,<<"!",P/binary>>) ->
    pos_match(H,P);
neg_match(_,_) ->
    false.

pos_match(_,<<"*">>) ->
    true;
pos_match(_,<<"*:*">>) ->
    true;
pos_match(_,<<"[*]:*">>) ->
    true;
pos_match(H,<<"!",P/binary>>) ->
     not pos_match(H,P);
pos_match(H,H) ->
    true;
pos_match(H,P) ->
    case {binary:split(H,<<":">>),binary:split(P,<<":">>)} of
        {[Hh, _],[Ph, <<"*">>]}->
            Ph == Hh;
        {[Hh],[Ph, <<"*">>]}->
            Sz = size(Hh),
            Ph == <<"[",Hh:Sz/binary,"]">>;
        {[Hh],[Ph, <<"22">>]}->
            Sz = size(Hh),
            Ph == <<"[",Hh:Sz/binary,"]">>;
        _->
            false
    end.

assure_file_mode(File,user_write) ->
    assure_file_mode(File,128);
assure_file_mode(File,user_read) ->
    assure_file_mode(File,256);
assure_file_mode(File,Mode) ->
    case file:read_file_info(File) of
        {ok,#file_info{mode = FileMode}}->
            case FileMode band Mode of
                Mode->
                    ok;
                _->
                    file:change_mode(File,FileMode bor Mode)
            end;
        {error,enoent}->
            ok;
        {error,Error}->
            {error,Error}
    end.

get_kb_option(Key,Opts,Default) ->
    try proplists:get_value(Key,proplists:get_value(key_cb_private,Opts,[]),Default)
        catch
            _:_->
                Default end.

read_ssh_key_file(Role,PrivPub,Algorithm,Opts) ->
    File = file_name(Role,file_base_name(Role,Algorithm),Opts),
    Password = proplists:get_value(identity_pass_phrase(Algorithm),Opts,ignore),
    ok = assure_file_mode(File,user_read),
    case file:read_file(File) of
        {ok,Pem}->
            try decode_ssh_file(PrivPub,Algorithm,Pem,Password) of 
                {ok,[Key| _Keys]}->
                    {ok,Key};
                {error,Reason}->
                    {error,Reason}
                catch
                    throw:Reason->
                        {error,Reason};
                    error:Reason->
                        {error,Reason} end;
        {error,Reason}->
            {error,Reason}
    end.

-spec(decode_ssh_file(PrivPub,Algorithm,Pem,Password) -> Result when PrivPub::private|public,Algorithm::ssh:pubkey_alg(),Pem::binary(),Password::string(),Result::{ok,Keys}|{error,any()},Keys::[Key],Key::public_key:private_key()|public_key:public_key()).

decode_ssh_file(PrivPub,Algorithm,Pem,Password) ->
    try decode_pem_keys(Pem,Password) of 
        {ok,Keys0}->
            case [Key || Key <- Keys0,ssh_transport:valid_key_sha_alg(PrivPub,Key,Algorithm)] of
                []->
                    {error,no_key_found};
                Keys->
                    {ok,Keys}
            end;
        {error,Error}->
            {error,Error}
        catch
            _:_->
                {error,key_decode_failed} end.

decode_pem_keys(Pem,Password) ->
    try get_key_part(Pem) of 
        {openssh-key-v1,Bin,_KeyValues}->
            KeyPairs = new_openssh_decode(Bin,Password),
            Keys = [Key || {Pub,Priv} <- KeyPairs,Key <- [Pub, Priv]],
            {ok,Keys};
        {rfc4716,Bin,_KeyValues}->
            Key = ssh_message:ssh2_pubkey_decode(Bin),
            {ok,[Key]};
        {Type,Bin,KeyValues}->
            case get_encrypt_hdrs(KeyValues) of
                not_encrypted->
                    Key = public_key:pem_entry_decode({Type,Bin,not_encrypted}),
                    {ok,[Key]};
                [Cipher, Salt]
                    when is_binary(Cipher),
                    is_binary(Salt),
                    Password =/= ignore->
                    CryptInfo = {binary_to_list(Cipher),unhex(binary_to_list(Salt))},
                    Key = public_key:pem_entry_decode({Type,Bin,CryptInfo},Password),
                    {ok,[Key]};
                _X->
                    {error,no_pass_phrase}
            end
        catch
            _:_->
                error(bad_or_unsupported_key_format) end.

get_encrypt_hdrs(KVs) ->
    lists:foldl(fun ({<<"Proc-Type">>,<<"4,ENCRYPTED",_/binary>>},_Acc)->
        {proc_type,<<"4,ENCRYPTED">>};({<<"DEK-Info">>,DEKinfo},{proc_type,_})->
        binary:split(DEKinfo,<<",">>);(_,Acc)->
        Acc end,not_encrypted,KVs).

unhex(S) ->
    list_to_binary(lists:foldr(fun (D2,{D1,Acc})->
        [list_to_integer([D2, D1],16)| Acc];(D1,Acc)
        when is_list(Acc)->
        {D1,Acc} end,[],S)).

file_base_name(user,ecdsa-sha2-nistp256) ->
    "id_ecdsa";
file_base_name(user,ecdsa-sha2-nistp384) ->
    "id_ecdsa";
file_base_name(user,ecdsa-sha2-nistp521) ->
    "id_ecdsa";
file_base_name(user,rsa-sha2-256) ->
    "id_rsa";
file_base_name(user,rsa-sha2-384) ->
    "id_rsa";
file_base_name(user,rsa-sha2-512) ->
    "id_rsa";
file_base_name(user,ssh-dss) ->
    "id_dsa";
file_base_name(user,ssh-ed25519) ->
    "id_ed25519";
file_base_name(user,ssh-ed448) ->
    "id_ed448";
file_base_name(user,ssh-rsa) ->
    "id_rsa";
file_base_name(system,ecdsa-sha2-nistp256) ->
    "ssh_host_ecdsa_key";
file_base_name(system,ecdsa-sha2-nistp384) ->
    "ssh_host_ecdsa_key";
file_base_name(system,ecdsa-sha2-nistp521) ->
    "ssh_host_ecdsa_key";
file_base_name(system,rsa-sha2-256) ->
    "ssh_host_rsa_key";
file_base_name(system,rsa-sha2-384) ->
    "ssh_host_rsa_key";
file_base_name(system,rsa-sha2-512) ->
    "ssh_host_rsa_key";
file_base_name(system,ssh-dss) ->
    "ssh_host_dsa_key";
file_base_name(system,ssh-ed25519) ->
    "ssh_host_ed25519_key";
file_base_name(system,ssh-ed448) ->
    "ssh_host_ed448_key";
file_base_name(system,ssh-rsa) ->
    "ssh_host_rsa_key";
file_base_name(system,_) ->
    "ssh_host_key".

identity_pass_phrase(ssh-dss) ->
    dsa_pass_phrase;
identity_pass_phrase(ssh-rsa) ->
    rsa_pass_phrase;
identity_pass_phrase(rsa-sha2-256) ->
    rsa_pass_phrase;
identity_pass_phrase(rsa-sha2-384) ->
    rsa_pass_phrase;
identity_pass_phrase(rsa-sha2-512) ->
    rsa_pass_phrase;
identity_pass_phrase(ecdsa-sha2-nistp256) ->
    ecdsa_pass_phrase;
identity_pass_phrase(ecdsa-sha2-nistp384) ->
    ecdsa_pass_phrase;
identity_pass_phrase(ecdsa-sha2-nistp521) ->
    ecdsa_pass_phrase;
identity_pass_phrase(_) ->
    undefined.

file_name(Type,Name,Opts) ->
    filename:join(ssh_dir(Type,Opts),Name).

ssh_dir({remoteuser,User},Opts) ->
    case proplists:get_value(user_dir_fun,Opts) of
        undefined->
            ssh_dir(user,Opts);
        FUN->
            FUN(User)
    end;
ssh_dir(user,Opts) ->
    case proplists:get_value(user_dir,Opts,false) of
        false->
            default_user_dir();
        D->
            D
    end;
ssh_dir(system,Opts) ->
    proplists:get_value(system_dir,Opts,"/etc/ssh").

default_user_dir() ->
    try default_user_dir(os:getenv("HOME"))
        catch
            _:_->
                default_user_dir(init:get_argument(home)) end.

default_user_dir({ok,[[Home| _]]}) ->
    default_user_dir(Home);
default_user_dir(Home)
    when is_list(Home)->
    UserDir = filename:join(Home,".ssh"),
    ok = filelib:ensure_dir(filename:join(UserDir,"dummy")),
    UserDir.

get_key_part(RawBin)
    when is_binary(RawBin)->
    case binary:split(binary:replace(RawBin,<<"\\\n">>,<<"">>,[global]),<<"\n">>,[global, trim_all]) of
        [<<"---- BEGIN SSH2 PUBLIC KEY ----">>| Lines0]->
            {KeyValues,Lines} = get_hdr_lines(Lines0,[]),
            ExpectedEndLine = <<"---- END SSH2 PUBLIC KEY ----">>,
            {rfc4716,get_body(Lines,ExpectedEndLine),KeyValues};
        [<<"-----BEGIN ",Rest/binary>>| Lines0]->
            ExpectedEndLine = <<"-----END ",Rest/binary>>,
            [MiddlePart, <<>>] = binary:split(Rest,<<" KEY-----">>),
            {KeyValues,Lines} = get_hdr_lines(Lines0,[]),
            {asn1_type(MiddlePart),get_body(Lines,ExpectedEndLine),KeyValues}
    end.

get_hdr_lines(Lines,Acc) ->
    Line1 = hd(Lines),
    case binary:split(Line1,<<":">>) of
        [Line1]->
            {lists:reverse(Acc),Lines};
        [Key, Value]->
            get_hdr_lines(tl(Lines),[{trim(Key),trim(Value)}| Acc])
    end.

get_body(Lines,ExpectedEndLine) ->
    {KeyPart,[ExpectedEndLine]} = lists:split(length(Lines) - 1,Lines),
    base64:mime_decode(iolist_to_binary(KeyPart)).

trim(<<" ",B/binary>>) ->
    trim(B);
trim(B) ->
    B.

asn1_type(<<"RSA PRIVATE">>) ->
    'RSAPrivateKey';
asn1_type(<<"RSA PUBLIC">>) ->
    'RSAPublicKey';
asn1_type(<<"DSA PRIVATE">>) ->
    'DSAPrivateKey';
asn1_type(<<"EC PRIVATE">>) ->
    'ECPrivateKey';
asn1_type(<<"OPENSSH PRIVATE">>) ->
    openssh-key-v1;
asn1_type(_) ->
    undefined.

new_openssh_decode(<<"openssh-key-v1",0,_L1:32/unsigned-big-integer,CipherName:_L1/binary,_L2:32/unsigned-big-integer,KdfName:_L2/binary,_L3:32/unsigned-big-integer,KdfOptions:_L3/binary,N:32/unsigned-big-integer,Rest/binary>>,Pwd) ->
    new_openssh_decode(Rest,N,Pwd,CipherName,KdfName,KdfOptions,N,[]).

new_openssh_decode(<<_L1:32/unsigned-big-integer,BinKey:_L1/binary,Rest/binary>>,I,Pwd,CipherName,KdfName,KdfOptions,N,PubKeyAcc)
    when I > 0->
    PublicKey = ssh_message:ssh2_pubkey_decode(BinKey),
    new_openssh_decode(Rest,I - 1,Pwd,CipherName,KdfName,KdfOptions,N,[PublicKey| PubKeyAcc]);
new_openssh_decode(<<_L:32/unsigned-big-integer,Encrypted:_L/binary>>,0,Pwd,CipherName,KdfName,KdfOptions,N,PubKeyAccRev) ->
    PubKeys = lists:reverse(PubKeyAccRev),
    try Plain = decrypt_new_openssh(Encrypted,KdfName,KdfOptions,CipherName,Pwd),
    new_openssh_decode_priv_keys(Plain,N,N,[],[]) of 
        {PrivKeys,_Comments}->
            lists:map(fun ({{ed_pub,A,Pub},{ed_pri,A,Pub,Pri0}})->
                Pri = binary:part(Pri0,{0,size(Pri0) - size(Pub)}),
                {{ed_pub,A,Pub},{ed_pri,A,Pub,Pri}};(Pair)->
                Pair end,lists:zip(PubKeys,PrivKeys))
        catch
            error:{decryption,DecryptError}->
                error({decryption,DecryptError}) end.

new_openssh_decode_priv_keys(Bin,I,N,KeyAcc,CmntAcc)
    when I > 0->
    {PrivKey,<<_Lc:32/unsigned-big-integer,Comment:_Lc/binary,Rest/binary>>} = ssh_message:ssh2_privkey_decode2(Bin),
    new_openssh_decode_priv_keys(Rest,I - 1,N,[PrivKey| KeyAcc],[Comment| CmntAcc]);
new_openssh_decode_priv_keys(_Padding,0,_N,PrivKeyAccRev,CommentAccRev) ->
    {lists:reverse(PrivKeyAccRev),lists:reverse(CommentAccRev)}.

decrypt_new_openssh(Encrypted,<<"none">>,<<>>,_CipherName,_Pwd) ->
    check_valid_decryption(Encrypted,8);
decrypt_new_openssh(Encrypted,<<>>,<<>>,_CipherName,_Pwd) ->
    check_valid_decryption(Encrypted,8);
decrypt_new_openssh(_Encrypted,<<"bcrypt">>,<<_L:32/unsigned-big-integer,_Salt:_L/binary,_Rounds:32/unsigned-big-integer>>,_CipherName,_Pwd) ->
    error({decryption,{not_supported,bcrypt}});
decrypt_new_openssh(_Encrypted,KdfName,_KdfOpts,_CipherName,_Pwd) ->
    error({decryption,{not_supported,KdfName}}).

check_valid_decryption(<<Checkint1:32/unsigned-big-integer,Checkint2:32/unsigned-big-integer,Plain/binary>>,BlockSize)
    when Checkint2 == Checkint1->
    case check_padding(Plain,BlockSize) of
        true->
            Plain;
        false->
            error({decryption,bad_padding})
    end;
check_valid_decryption(_,_) ->
    error({decryption,bad_result}).

check_padding(Bin,BlockSize) ->
    N = binary:last(Bin),
    if N < BlockSize ->
        Padding = binary:part(Bin,{byte_size(Bin),-N}),
        ExpectedPadding = list_to_binary(lists:seq(1,N)),
        Padding == ExpectedPadding;true ->
        true end.
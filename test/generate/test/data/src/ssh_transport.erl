-file("ssh_transport.erl", 1).

-module(ssh_transport).

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

-file("ssh_transport.erl", 28).

-file("/usr/lib/erlang/lib/kernel-7.2/include/inet.hrl", 1).

-record(hostent,{h_name::inet:hostname(),h_aliases = []::[inet:hostname()],h_addrtype::inet|inet6,h_length::non_neg_integer(),h_addr_list = []::[inet:ip_address()]}).

-file("ssh_transport.erl", 29).

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

-file("ssh_transport.erl", 31).

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

-file("ssh_transport.erl", 32).

-export([versions/2, hello_version_msg/1]).

-export([next_seqnum/1, supported_algorithms/0, supported_algorithms/1, default_algorithms/0, default_algorithms/1, clear_default_algorithms_env/0, algo_classes/0, algo_class/1, algo_two_spec_classes/0, algo_two_spec_class/1, handle_packet_part/5, handle_hello_version/1, key_exchange_init_msg/1, key_init/3, new_keys_message/1, ext_info_message/1, handle_kexinit_msg/3, handle_kexdh_init/2, handle_kex_dh_gex_group/2, handle_kex_dh_gex_init/2, handle_kex_dh_gex_reply/2, handle_new_keys/2, handle_kex_dh_gex_request/2, handle_kexdh_reply/2, handle_kex_ecdh_init/2, handle_kex_ecdh_reply/2, parallell_gen_key/1, extract_public_key/1, ssh_packet/2, pack/2, valid_key_sha_alg/3, sha/1, sign/3, verify/5, get_host_key/2, call_KeyCb/3, public_algo/1]).

-behaviour(ssh_dbg).

-export([ssh_dbg_trace_points/0, ssh_dbg_flags/1, ssh_dbg_on/1, ssh_dbg_off/1, ssh_dbg_format/2]).

-export([pack/3, adjust_algs_for_peer_version/2]).

clear_default_algorithms_env() ->
    application:unset_env(ssh,'$def-algs$').

-spec(default_algorithms() -> algs_list()|no_return()).

default_algorithms() ->
    case application:get_env(ssh,'$def-algs$') of
        undefined->
            Opts = get_alg_conf(),
            Algs1 = case proplists:get_value(preferred_algorithms,Opts) of
                undefined->
                    [{K,default_algorithms1(K)} || K <- algo_classes()];
                Algs0->
                    {true,Algs01} = ssh_options:check_preferred_algorithms(Algs0),
                    Algs01
            end,
            Algs = case proplists:get_value(modify_algorithms,Opts) of
                undefined->
                    Algs1;
                Modifications->
                    ssh_options:initial_default_algorithms(Algs1,Modifications)
            end,
            application:set_env(ssh,'$def-algs$',Algs),
            Algs;
        {ok,Algs}->
            Algs
    end.

get_alg_conf() ->
    [{T,L} || T <- [preferred_algorithms, modify_algorithms],L <- [application:get_env(ssh,T,[])],L =/= []].

algo_classes() ->
    [kex, public_key, cipher, mac, compression].

algo_class(kex) ->
    true;
algo_class(public_key) ->
    true;
algo_class(cipher) ->
    true;
algo_class(mac) ->
    true;
algo_class(compression) ->
    true;
algo_class(_) ->
    false.

algo_two_spec_classes() ->
    [cipher, mac, compression].

algo_two_spec_class(cipher) ->
    true;
algo_two_spec_class(mac) ->
    true;
algo_two_spec_class(compression) ->
    true;
algo_two_spec_class(_) ->
    false.

default_algorithms(Tag) ->
    case application:get_env(ssh,'$def-algs$') of
        undefined->
            default_algorithms1(Tag);
        {ok,Algs}->
            proplists:get_value(Tag,Algs,[])
    end.

default_algorithms1(kex) ->
    supported_algorithms(kex,[diffie-hellman-group1-sha1, diffie-hellman-group14-sha1, diffie-hellman-group-exchange-sha1]);
default_algorithms1(cipher) ->
    supported_algorithms(cipher,same(['AEAD_AES_128_GCM', 'AEAD_AES_256_GCM']));
default_algorithms1(mac) ->
    supported_algorithms(mac,same(['AEAD_AES_128_GCM', 'AEAD_AES_256_GCM', hmac-sha1-96]));
default_algorithms1(public_key) ->
    supported_algorithms(public_key,[ssh-dss]);
default_algorithms1(Alg) ->
    supported_algorithms(Alg,[]).

supported_algorithms() ->
    [{K,supported_algorithms(K)} || K <- algo_classes()].

supported_algorithms(kex) ->
    select_crypto_supported([{ecdh-sha2-nistp384,[{public_keys,ecdh}, {curves,secp384r1}, {hashs,sha384}]}, {ecdh-sha2-nistp521,[{public_keys,ecdh}, {curves,secp521r1}, {hashs,sha512}]}, {ecdh-sha2-nistp256,[{public_keys,ecdh}, {curves,secp256r1}, {hashs,sha256}]}, {diffie-hellman-group-exchange-sha256,[{public_keys,dh}, {hashs,sha256}]}, {diffie-hellman-group16-sha512,[{public_keys,dh}, {hashs,sha512}]}, {diffie-hellman-group18-sha512,[{public_keys,dh}, {hashs,sha512}]}, {diffie-hellman-group14-sha256,[{public_keys,dh}, {hashs,sha256}]}, {curve25519-sha256,[{public_keys,ecdh}, {curves,x25519}, {hashs,sha256}]}, {curve25519-sha256@libssh.org,[{public_keys,ecdh}, {curves,x25519}, {hashs,sha256}]}, {curve448-sha512,[{public_keys,ecdh}, {curves,x448}, {hashs,sha512}]}, {diffie-hellman-group14-sha1,[{public_keys,dh}, {hashs,sha}]}, {diffie-hellman-group-exchange-sha1,[{public_keys,dh}, {hashs,sha}]}, {diffie-hellman-group1-sha1,[{public_keys,dh}, {hashs,sha}]}]);
supported_algorithms(public_key) ->
    select_crypto_supported([{ecdsa-sha2-nistp384,[{public_keys,ecdsa}, {hashs,sha384}, {curves,secp384r1}]}, {ecdsa-sha2-nistp521,[{public_keys,ecdsa}, {hashs,sha512}, {curves,secp521r1}]}, {ecdsa-sha2-nistp256,[{public_keys,ecdsa}, {hashs,sha256}, {curves,secp256r1}]}, {ssh-ed25519,[{public_keys,eddsa}, {curves,ed25519}]}, {ssh-ed448,[{public_keys,eddsa}, {curves,ed448}]}, {rsa-sha2-256,[{public_keys,rsa}, {hashs,sha256}]}, {rsa-sha2-512,[{public_keys,rsa}, {hashs,sha512}]}, {ssh-rsa,[{public_keys,rsa}, {hashs,sha}]}, {ssh-dss,[{public_keys,dss}, {hashs,sha}]}]);
supported_algorithms(cipher) ->
    same(select_crypto_supported([{chacha20-poly1305@openssh.com,[{ciphers,chacha20}, {macs,poly1305}]}, {aes256-gcm@openssh.com,[{ciphers,aes_256_gcm}]}, {aes256-ctr,[{ciphers,aes_256_ctr}]}, {aes192-ctr,[{ciphers,aes_192_ctr}]}, {aes128-gcm@openssh.com,[{ciphers,aes_128_gcm}]}, {aes128-ctr,[{ciphers,aes_128_ctr}]}, {'AEAD_AES_256_GCM',[{ciphers,aes_256_gcm}]}, {'AEAD_AES_128_GCM',[{ciphers,aes_128_gcm}]}, {aes256-cbc,[{ciphers,aes_256_cbc}]}, {aes192-cbc,[{ciphers,aes_192_cbc}]}, {aes128-cbc,[{ciphers,aes_128_cbc}]}, {'3des-cbc',[{ciphers,des_ede3_cbc}]}]));
supported_algorithms(mac) ->
    same(select_crypto_supported([{hmac-sha2-256-etm@openssh.com,[{macs,hmac}, {hashs,sha256}]}, {hmac-sha2-512-etm@openssh.com,[{macs,hmac}, {hashs,sha256}]}, {hmac-sha2-256,[{macs,hmac}, {hashs,sha256}]}, {hmac-sha2-512,[{macs,hmac}, {hashs,sha512}]}, {hmac-sha1-etm@openssh.com,[{macs,hmac}, {hashs,sha256}]}, {hmac-sha1,[{macs,hmac}, {hashs,sha}]}, {hmac-sha1-96,[{macs,hmac}, {hashs,sha}]}, {'AEAD_AES_128_GCM',[{ciphers,aes_128_gcm}]}, {'AEAD_AES_256_GCM',[{ciphers,aes_256_gcm}]}]));
supported_algorithms(compression) ->
    same([none, zlib@openssh.com, zlib]).

versions(client,Options) ->
    Vsn = ssh_options:get_value(internal_options,vsn,Options,fun ()->
        {2,0} end,ssh_transport,252),
    {Vsn,format_version(Vsn,software_version(Options))};
versions(server,Options) ->
    Vsn = ssh_options:get_value(internal_options,vsn,Options,fun ()->
        {2,0} end,ssh_transport,255),
    {Vsn,format_version(Vsn,software_version(Options))}.

format_version({Major,Minor},"") ->
    lists:concat(["SSH-", Major, ".", Minor]);
format_version({Major,Minor},SoftwareVersion) ->
    lists:concat(["SSH-", Major, ".", Minor, "-", SoftwareVersion]).

software_version(Options) ->
    case ssh_options:get_value(user_options,id_string,Options,ssh_transport,264) of
        {random,Nlo,Nup}->
            random_id(Nlo,Nup);
        ID->
            ID
    end.

random_id(Nlo,Nup) ->
    [($a + rand:uniform($z - $a + 1) - 1) || _ <- lists:duplicate(Nlo + rand:uniform(Nup - Nlo + 1) - 1,x)].

hello_version_msg(Data) ->
    [Data, "\r\n"].

next_seqnum(SeqNum) ->
    (SeqNum + 1) band 4294967295.

is_valid_mac(_,_,#ssh{recv_mac_size = 0}) ->
    true;
is_valid_mac(Mac,Data,#ssh{recv_mac = Algorithm,recv_mac_key = Key,recv_sequence = SeqNum}) ->
    crypto:equal_const_time(Mac,mac(Algorithm,Key,SeqNum,Data)).

handle_hello_version(Version) ->
    try StrVersion = trim_tail(Version),
    case string:tokens(Version,"-") of
        [_, "2.0"| _]->
            {{2,0},StrVersion};
        [_, "1.99"| _]->
            {{2,0},StrVersion};
        [_, "1.3"| _]->
            {{1,3},StrVersion};
        [_, "1.5"| _]->
            {{1,5},StrVersion}
    end
        catch
            error:_->
                {undefined,"unknown version"} end.

key_exchange_init_msg(Ssh0) ->
    Msg = kex_init(Ssh0),
    {SshPacket,Ssh} = ssh_packet(Msg,Ssh0),
    {Msg,SshPacket,Ssh}.

kex_init(#ssh{role = Role,opts = Opts,available_host_keys = HostKeyAlgs} = Ssh) ->
    Random = ssh_bits:random(16),
    PrefAlgs = adjust_algs_for_peer_version(Role,ssh_options:get_value(user_options,preferred_algorithms,Opts,ssh_transport,311),Ssh),
    kexinit_message(Role,Random,PrefAlgs,HostKeyAlgs,Opts).

key_init(client,Ssh,Value) ->
    Ssh#ssh{c_keyinit = Value};
key_init(server,Ssh,Value) ->
    Ssh#ssh{s_keyinit = Value}.

adjust_algs_for_peer_version(client,PrefAlgs,#ssh{s_version = V}) ->
    adjust_algs_for_peer_version(V,PrefAlgs);
adjust_algs_for_peer_version(server,PrefAlgs,#ssh{c_version = V}) ->
    adjust_algs_for_peer_version(V,PrefAlgs).

adjust_algs_for_peer_version("SSH-2.0-OpenSSH_6.2" ++ _,PrefAlgs) ->
    C0 = proplists:get_value(cipher,PrefAlgs,same([])),
    C = [{D,L} || D <- [client2server, server2client],L <- [[K || K <- proplists:get_value(D,C0,[]),K =/= aes256-gcm@openssh.com,K =/= aes128-gcm@openssh.com]]],
    lists:keyreplace(cipher,1,PrefAlgs,{cipher,C});
adjust_algs_for_peer_version(_,PrefAlgs) ->
    PrefAlgs.

kexinit_message(Role,Random,Algs,HostKeyAlgs,Opts) ->
    #ssh_msg_kexinit{cookie = Random,kex_algorithms = to_strings(get_algs(kex,Algs)) ++ kex_ext_info(Role,Opts),server_host_key_algorithms = HostKeyAlgs,encryption_algorithms_client_to_server = c2s(cipher,Algs),encryption_algorithms_server_to_client = s2c(cipher,Algs),mac_algorithms_client_to_server = c2s(mac,Algs),mac_algorithms_server_to_client = s2c(mac,Algs),compression_algorithms_client_to_server = c2s(compression,Algs),compression_algorithms_server_to_client = s2c(compression,Algs),languages_client_to_server = [],languages_server_to_client = []}.

c2s(Key,Algs) ->
    x2y(client2server,Key,Algs).

s2c(Key,Algs) ->
    x2y(server2client,Key,Algs).

x2y(DirectionKey,Key,Algs) ->
    to_strings(proplists:get_value(DirectionKey,get_algs(Key,Algs))).

get_algs(Key,Algs) ->
    proplists:get_value(Key,Algs,default_algorithms(Key)).

to_strings(L) ->
    lists:map(fun erlang:atom_to_list/1,L).

new_keys_message(Ssh0) ->
    {SshPacket,Ssh1} = ssh_packet(#ssh_msg_newkeys{},Ssh0),
    Ssh = install_alg(snd,Ssh1),
    {ok,SshPacket,Ssh}.

handle_kexinit_msg(#ssh_msg_kexinit{} = CounterPart,#ssh_msg_kexinit{} = Own,#ssh{role = client} = Ssh) ->
    try {ok,Algorithms} = select_algorithm(client,Own,CounterPart,Ssh#ssh.opts),
    true = verify_algorithm(Algorithms),
    Algorithms of 
        Algos->
            key_exchange_first_msg(Algos#alg.kex,Ssh#ssh{algorithms = Algos})
        catch
            Class:Error->
                ssh_connection_handler:disconnect(3,io_lib:format("Kexinit fa" "iled in cl" "ient: ~p:~" "p",[Class, Error]),ssh_transport,380) end;
handle_kexinit_msg(#ssh_msg_kexinit{} = CounterPart,#ssh_msg_kexinit{} = Own,#ssh{role = server} = Ssh) ->
    try {ok,Algorithms} = select_algorithm(server,CounterPart,Own,Ssh#ssh.opts),
    true = verify_algorithm(Algorithms),
    Algorithms of 
        Algos->
            {ok,Ssh#ssh{algorithms = Algos}}
        catch
            Class:Error->
                ssh_connection_handler:disconnect(3,io_lib:format("Kexinit fa" "iled in se" "rver: ~p:~" "p",[Class, Error]),ssh_transport,397) end.

verify_algorithm(#alg{kex = undefined}) ->
    {false,"kex"};
verify_algorithm(#alg{hkey = undefined}) ->
    {false,"hkey"};
verify_algorithm(#alg{send_mac = undefined}) ->
    {false,"send_mac"};
verify_algorithm(#alg{recv_mac = undefined}) ->
    {false,"recv_mac"};
verify_algorithm(#alg{encrypt = undefined}) ->
    {false,"encrypt"};
verify_algorithm(#alg{decrypt = undefined}) ->
    {false,"decrypt"};
verify_algorithm(#alg{compress = undefined}) ->
    {false,"compress"};
verify_algorithm(#alg{decompress = undefined}) ->
    {false,"decompress"};
verify_algorithm(#alg{kex = Kex}) ->
    case lists:member(Kex,supported_algorithms(kex)) of
        true->
            true;
        false->
            {false,"kex"}
    end.

key_exchange_first_msg(Kex,Ssh0)
    when Kex == diffie-hellman-group1-sha1;
    Kex == diffie-hellman-group14-sha1;
    Kex == diffie-hellman-group14-sha256;
    Kex == diffie-hellman-group16-sha512;
    Kex == diffie-hellman-group18-sha512->
    {G,P} = dh_group(Kex),
    Sz = dh_bits(Ssh0#ssh.algorithms),
    {Public,Private} = generate_key(dh,[P, G, 2 * Sz]),
    {SshPacket,Ssh1} = ssh_packet(#ssh_msg_kexdh_init{e = Public},Ssh0),
    {ok,SshPacket,Ssh1#ssh{keyex_key = {{Private,Public},{G,P}}}};
key_exchange_first_msg(Kex,Ssh0 = #ssh{opts = Opts})
    when Kex == diffie-hellman-group-exchange-sha1;
    Kex == diffie-hellman-group-exchange-sha256->
    {Min,NBits0,Max} = ssh_options:get_value(user_options,dh_gex_limits,Opts,ssh_transport,437),
    DhBits = dh_bits(Ssh0#ssh.algorithms),
    NBits1 = if DhBits =< 112 ->
        2048;DhBits =< 128 ->
        3072;DhBits =< 192 ->
        7680;true ->
        8192 end,
    NBits = min(max(max(NBits0,NBits1),Min),Max),
    {SshPacket,Ssh1} = ssh_packet(#ssh_msg_kex_dh_gex_request{min = Min,n = NBits,max = Max},Ssh0),
    {ok,SshPacket,Ssh1#ssh{keyex_info = {Min,Max,NBits}}};
key_exchange_first_msg(Kex,Ssh0)
    when Kex == ecdh-sha2-nistp256;
    Kex == ecdh-sha2-nistp384;
    Kex == ecdh-sha2-nistp521;
    Kex == curve25519-sha256;
    Kex == curve25519-sha256@libssh.org;
    Kex == curve448-sha512->
    Curve = ecdh_curve(Kex),
    {Public,Private} = generate_key(ecdh,Curve),
    {SshPacket,Ssh1} = ssh_packet(#ssh_msg_kex_ecdh_init{q_c = Public},Ssh0),
    {ok,SshPacket,Ssh1#ssh{keyex_key = {{Public,Private},Curve}}}.

handle_kexdh_init(#ssh_msg_kexdh_init{e = E},Ssh0 = #ssh{algorithms = #alg{kex = Kex,hkey = SignAlg} = Algs,opts = Opts}) ->
    {G,P} = dh_group(Kex),
    if 1 =< E,
    E =< P - 1 ->
        Sz = dh_bits(Algs),
        {Public,Private} = generate_key(dh,[P, G, 2 * Sz]),
        K = compute_key(dh,E,Private,[P, G]),
        MyPrivHostKey = get_host_key(SignAlg,Opts),
        MyPubHostKey = extract_public_key(MyPrivHostKey),
        H = kex_hash(Ssh0,MyPubHostKey,sha(Kex),{E,Public,K}),
        H_SIG = sign(H,sha(SignAlg),MyPrivHostKey),
        {SshPacket,Ssh1} = ssh_packet(#ssh_msg_kexdh_reply{public_host_key = {MyPubHostKey,SignAlg},f = Public,h_sig = H_SIG},Ssh0),
        {ok,SshPacket,Ssh1#ssh{keyex_key = {{Private,Public},{G,P}},shared_secret = ssh_bits:mpint(K),exchanged_hash = H,session_id = sid(Ssh1,H)}};true ->
        ssh_connection_handler:disconnect(3,io_lib:format("Kexdh init" " failed, r" "eceived 'e" "' out of b" "ounds~n  E" "=~p~n  P=~" "p",[E, P]),ssh_transport,505) end.

handle_kexdh_reply(#ssh_msg_kexdh_reply{public_host_key = PeerPubHostKey,f = F,h_sig = H_SIG},#ssh{keyex_key = {{Private,Public},{G,P}},algorithms = #alg{kex = Kex}} = Ssh0) ->
    if 1 =< F,
    F =< P - 1 ->
        K = compute_key(dh,F,Private,[P, G]),
        H = kex_hash(Ssh0,PeerPubHostKey,sha(Kex),{Public,F,K}),
        case verify_host_key(Ssh0,PeerPubHostKey,H,H_SIG) of
            ok->
                {SshPacket,Ssh} = ssh_packet(#ssh_msg_newkeys{},Ssh0),
                {ok,SshPacket,install_alg(snd,Ssh#ssh{shared_secret = ssh_bits:mpint(K),exchanged_hash = H,session_id = sid(Ssh,H)})};
            Error->
                ssh_connection_handler:disconnect(3,io_lib:format("Kexdh" " init" " fail" "ed. V" "erify" " host" " key:" " ~p",[Error]),ssh_transport,527)
        end;true ->
        ssh_connection_handler:disconnect(3,io_lib:format("Kexdh init" " failed, r" "eceived 'f" "' out of b" "ounds~n  F" "=~p~n  P=~" "p",[F, P]),ssh_transport,534) end.

handle_kex_dh_gex_request(#ssh_msg_kex_dh_gex_request{min = Min0,n = NBits,max = Max0},Ssh0 = #ssh{opts = Opts})
    when Min0 =< NBits,
    NBits =< Max0->
    {Min,Max} = adjust_gex_min_max(Min0,Max0,Opts),
    case public_key:dh_gex_group(Min,NBits,Max,ssh_options:get_value(user_options,dh_gex_groups,Opts,ssh_transport,550)) of
        {ok,{_,{G,P}}}->
            {SshPacket,Ssh} = ssh_packet(#ssh_msg_kex_dh_gex_group{p = P,g = G},Ssh0),
            {ok,SshPacket,Ssh#ssh{keyex_key = {x,{G,P}},keyex_info = {Min0,Max0,NBits}}};
        {error,_}->
            ssh_connection_handler:disconnect(3,io_lib:format("No possibl" "e diffie-h" "ellman-gro" "up-exchang" "e group fo" "und",[]),ssh_transport,560)
    end;
handle_kex_dh_gex_request(#ssh_msg_kex_dh_gex_request_old{n = NBits},Ssh0 = #ssh{opts = Opts}) ->
    Min0 = NBits,
    Max0 = 8192,
    {Min,Max} = adjust_gex_min_max(Min0,Max0,Opts),
    case public_key:dh_gex_group(Min,NBits,Max,ssh_options:get_value(user_options,dh_gex_groups,Opts,ssh_transport,582)) of
        {ok,{_,{G,P}}}->
            {SshPacket,Ssh} = ssh_packet(#ssh_msg_kex_dh_gex_group{p = P,g = G},Ssh0),
            {ok,SshPacket,Ssh#ssh{keyex_key = {x,{G,P}},keyex_info = {-1,-1,NBits}}};
        {error,_}->
            ssh_connection_handler:disconnect(3,io_lib:format("No possibl" "e diffie-h" "ellman-gro" "up-exchang" "e group fo" "und",[]),ssh_transport,592)
    end;
handle_kex_dh_gex_request(_,_) ->
    ssh_connection_handler:disconnect(3,"Key exchange failed, bad values " "in ssh_msg_kex_dh_gex_request",ssh_transport,598).

adjust_gex_min_max(Min0,Max0,Opts) ->
    {Min1,Max1} = ssh_options:get_value(user_options,dh_gex_limits,Opts,ssh_transport,601),
    Min2 = max(Min0,Min1),
    Max2 = min(Max0,Max1),
    if Min2 =< Max2 ->
        {Min2,Max2};Max2 < Min2 ->
        ssh_connection_handler:disconnect(2,"No possible diffie-hellm" "an-group-exchange group " "possible",ssh_transport,609) end.

handle_kex_dh_gex_group(#ssh_msg_kex_dh_gex_group{p = P,g = G},Ssh0) ->
    Sz = dh_bits(Ssh0#ssh.algorithms),
    {Public,Private} = generate_key(dh,[P, G, 2 * Sz]),
    {SshPacket,Ssh1} = ssh_packet(#ssh_msg_kex_dh_gex_init{e = Public},Ssh0),
    {ok,SshPacket,Ssh1#ssh{keyex_key = {{Private,Public},{G,P}}}}.

handle_kex_dh_gex_init(#ssh_msg_kex_dh_gex_init{e = E},#ssh{keyex_key = {{Private,Public},{G,P}},keyex_info = {Min,Max,NBits},algorithms = #alg{kex = Kex,hkey = SignAlg},opts = Opts} = Ssh0) ->
    if 1 =< E,
    E =< P - 1 ->
        K = compute_key(dh,E,Private,[P, G]),
        if 1 < K,
        K < P - 1 ->
            MyPrivHostKey = get_host_key(SignAlg,Opts),
            MyPubHostKey = extract_public_key(MyPrivHostKey),
            H = kex_hash(Ssh0,MyPubHostKey,sha(Kex),{Min,NBits,Max,P,G,E,Public,K}),
            H_SIG = sign(H,sha(SignAlg),MyPrivHostKey),
            {SshPacket,Ssh} = ssh_packet(#ssh_msg_kex_dh_gex_reply{public_host_key = {MyPubHostKey,SignAlg},f = Public,h_sig = H_SIG},Ssh0),
            {ok,SshPacket,Ssh#ssh{shared_secret = ssh_bits:mpint(K),exchanged_hash = H,session_id = sid(Ssh,H)}};true ->
            ssh_connection_handler:disconnect(3,"Kexdh init faile" "d, received 'k' " "out of bounds",ssh_transport,649) end;true ->
        ssh_connection_handler:disconnect(3,io_lib:format("Kexdh gex " "init faile" "d, receive" "d 'e' out " "of bounds~" "n  E=~p~n " " P=~p",[E, P]),ssh_transport,655) end.

handle_kex_dh_gex_reply(#ssh_msg_kex_dh_gex_reply{public_host_key = PeerPubHostKey,f = F,h_sig = H_SIG},#ssh{keyex_key = {{Private,Public},{G,P}},keyex_info = {Min,Max,NBits},algorithms = #alg{kex = Kex}} = Ssh0) ->
    if 1 =< F,
    F =< P - 1 ->
        K = compute_key(dh,F,Private,[P, G]),
        if 1 < K,
        K < P - 1 ->
            H = kex_hash(Ssh0,PeerPubHostKey,sha(Kex),{Min,NBits,Max,P,G,Public,F,K}),
            case verify_host_key(Ssh0,PeerPubHostKey,H,H_SIG) of
                ok->
                    {SshPacket,Ssh} = ssh_packet(#ssh_msg_newkeys{},Ssh0),
                    {ok,SshPacket,install_alg(snd,Ssh#ssh{shared_secret = ssh_bits:mpint(K),exchanged_hash = H,session_id = sid(Ssh,H)})};
                Error->
                    ssh_connection_handler:disconnect(3,io_lib:format("Kexdh" " gex " "reply" " fail" "ed. V" "erify" " host" " key:" " ~p",[Error]),ssh_transport,681)
            end;true ->
            ssh_connection_handler:disconnect(3,"Kexdh gex init f" "ailed, 'K' out o" "f bounds",ssh_transport,687) end;true ->
        ssh_connection_handler:disconnect(3,io_lib:format("Kexdh gex " "init faile" "d, receive" "d 'f' out " "of bounds~" "n  F=~p~n " " P=~p",[F, P]),ssh_transport,693) end.

handle_kex_ecdh_init(#ssh_msg_kex_ecdh_init{q_c = PeerPublic},Ssh0 = #ssh{algorithms = #alg{kex = Kex,hkey = SignAlg},opts = Opts}) ->
    Curve = ecdh_curve(Kex),
    {MyPublic,MyPrivate} = generate_key(ecdh,Curve),
    try compute_key(ecdh,PeerPublic,MyPrivate,Curve) of 
        K->
            MyPrivHostKey = get_host_key(SignAlg,Opts),
            MyPubHostKey = extract_public_key(MyPrivHostKey),
            H = kex_hash(Ssh0,MyPubHostKey,sha(Curve),{PeerPublic,MyPublic,K}),
            H_SIG = sign(H,sha(SignAlg),MyPrivHostKey),
            {SshPacket,Ssh1} = ssh_packet(#ssh_msg_kex_ecdh_reply{public_host_key = {MyPubHostKey,SignAlg},q_s = MyPublic,h_sig = H_SIG},Ssh0),
            {ok,SshPacket,Ssh1#ssh{keyex_key = {{MyPublic,MyPrivate},Curve},shared_secret = ssh_bits:mpint(K),exchanged_hash = H,session_id = sid(Ssh1,H)}}
        catch
            Class:Error->
                ssh_connection_handler:disconnect(3,io_lib:format("ECDH compu" "te key fai" "led in ser" "ver: ~p:~p" "~nKex: ~p," " Curve: ~p" "~nPeerPubl" "ic: ~p",[Class, Error, Kex, Curve, PeerPublic]),ssh_transport,731) end.

handle_kex_ecdh_reply(#ssh_msg_kex_ecdh_reply{public_host_key = PeerPubHostKey,q_s = PeerPublic,h_sig = H_SIG},#ssh{keyex_key = {{MyPublic,MyPrivate},Curve}} = Ssh0) ->
    try compute_key(ecdh,PeerPublic,MyPrivate,Curve) of 
        K->
            H = kex_hash(Ssh0,PeerPubHostKey,sha(Curve),{MyPublic,PeerPublic,K}),
            case verify_host_key(Ssh0,PeerPubHostKey,H,H_SIG) of
                ok->
                    {SshPacket,Ssh} = ssh_packet(#ssh_msg_newkeys{},Ssh0),
                    {ok,SshPacket,install_alg(snd,Ssh#ssh{shared_secret = ssh_bits:mpint(K),exchanged_hash = H,session_id = sid(Ssh,H)})};
                Error->
                    ssh_connection_handler:disconnect(3,io_lib:format("ECDH " "reply" " fail" "ed. V" "erify" " host" " key:" " ~p",[Error]),ssh_transport,755)
            end
        catch
            Class:Error->
                ssh_connection_handler:disconnect(3,io_lib:format("Peer ECDH " "public key" " seem inva" "lid: ~p:~p",[Class, Error]),ssh_transport,762) end.

handle_new_keys(#ssh_msg_newkeys{},Ssh0) ->
    try install_alg(rcv,Ssh0) of 
        #ssh{} = Ssh->
            {ok,Ssh}
        catch
            Class:Error->
                ssh_connection_handler:disconnect(2,io_lib:format("Install al" "g failed: " "~p:~p",[Class, Error]),ssh_transport,776) end.

kex_ext_info(Role,Opts) ->
    case ssh_options:get_value(user_options,recv_ext_info,Opts,ssh_transport,783) of
        true
            when Role == client->
            ["ext-info-c"];
        true
            when Role == server->
            ["ext-info-s"];
        false->
            []
    end.

ext_info_message(#ssh{role = client,send_ext_info = true,opts = Opts} = Ssh0) ->
    case proplists:get_value(ext_info_client,ssh_options:get_value(user_options,tstflg,Opts,ssh_transport,795)) of
        true->
            Msg = #ssh_msg_ext_info{nr_extensions = 1,data = [{"test@erlang.org","Testing,PleaseIgnore"}]},
            {SshPacket,Ssh} = ssh_packet(Msg,Ssh0),
            {ok,SshPacket,Ssh};
        _->
            {ok,"",Ssh0}
    end;
ext_info_message(#ssh{role = server,send_ext_info = true,opts = Opts} = Ssh0) ->
    AlgsList = lists:map(fun erlang:atom_to_list/1,ssh_options:get_value(user_options,pref_public_key_algs,Opts,ssh_transport,810)),
    Msg = #ssh_msg_ext_info{nr_extensions = 1,data = [{"server-sig-algs",string:join(AlgsList,",")}]},
    {SshPacket,Ssh} = ssh_packet(Msg,Ssh0),
    {ok,SshPacket,Ssh};
ext_info_message(Ssh0) ->
    {ok,"",Ssh0}.

sid(#ssh{session_id = undefined},H) ->
    H;
sid(#ssh{session_id = Id},_) ->
    Id.

get_host_key(SignAlg,Opts) ->
    case call_KeyCb(host_key,[SignAlg],Opts) of
        {ok,PrivHostKey}->
            case valid_key_sha_alg(private,PrivHostKey,SignAlg) of
                true->
                    PrivHostKey;
                false->
                    exit({error,bad_hostkey})
            end;
        Result->
            exit({error,{Result,unsupported_key_type}})
    end.

call_KeyCb(F,Args,Opts) ->
    {KeyCb,KeyCbOpts} = ssh_options:get_value(user_options,key_cb,Opts,ssh_transport,841),
    UserOpts = ssh_options:get_value(user_options,key_cb_options,Opts,ssh_transport,842),
    apply(KeyCb,F,Args ++ [[{key_cb_private,KeyCbOpts}| UserOpts]]).

extract_public_key(#'RSAPrivateKey'{modulus = N,publicExponent = E}) ->
    #'RSAPublicKey'{modulus = N,publicExponent = E};
extract_public_key(#'DSAPrivateKey'{y = Y,p = P,q = Q,g = G}) ->
    {Y,#'Dss-Parms'{p = P,q = Q,g = G}};
extract_public_key(#'ECPrivateKey'{parameters = {namedCurve,OID},publicKey = Q})
    when is_tuple(OID)->
    {#'ECPoint'{point = Q},{namedCurve,OID}};
extract_public_key({ed_pri,Alg,Pub,_Priv}) ->
    {ed_pub,Alg,Pub};
extract_public_key(#{engine:=_,key_id:=_,algorithm:=Alg} = M) ->
    case {Alg,crypto:privkey_to_pubkey(Alg,M)} of
        {rsa,[E, N]}->
            #'RSAPublicKey'{modulus = N,publicExponent = E};
        {dss,[P, Q, G, Y]}->
            {Y,#'Dss-Parms'{p = P,q = Q,g = G}}
    end.

verify_host_key(#ssh{algorithms = Alg} = SSH,PublicKey,Digest,{AlgStr,Signature}) ->
    case atom_to_list(Alg#alg.hkey) of
        AlgStr->
            case verify(Digest,sha(Alg#alg.hkey),Signature,PublicKey,SSH) of
                false->
                    {error,bad_signature};
                true->
                    known_host_key(SSH,PublicKey,public_algo(PublicKey))
            end;
        _->
            {error,bad_signature_name}
    end.

accepted_host(Ssh,PeerName,Port,Public,Opts) ->
    PortStr = case Port of
        22->
            "";
        _->
            lists:concat([":", Port])
    end,
    case ssh_options:get_value(user_options,silently_accept_hosts,Opts,ssh_transport,884) of
        false->
            yes == yes_no(Ssh,"New host " ++ PeerName ++ PortStr ++ " accept");
        true->
            true;
        {false,Alg}->
            HostKeyAlg = (Ssh#ssh.algorithms)#alg.hkey,
            Prompt = io_lib:format("The authenticity of the host can't be es" "tablished.~n~s host key fingerprint is ~" "s.~nNew host ~p~p accept",[fmt_hostkey(HostKeyAlg), public_key:ssh_hostkey_fingerprint(Alg,Public), PeerName, PortStr]),
            yes == yes_no(Ssh,Prompt);
        F
            when is_function(F,2)->
            case  catch F(PeerName,public_key:ssh_hostkey_fingerprint(Public)) of
                true->
                    true;
                _->
                    {error,fingerprint_check_failed}
            end;
        F
            when is_function(F,3)->
            case  catch F(PeerName,Port,public_key:ssh_hostkey_fingerprint(Public)) of
                true->
                    true;
                _->
                    {error,fingerprint_check_failed}
            end;
        {DigestAlg,F}
            when is_function(F,2)->
            case  catch F(PeerName,public_key:ssh_hostkey_fingerprint(DigestAlg,Public)) of
                true->
                    true;
                _->
                    {error,{fingerprint_check_failed,DigestAlg}}
            end;
        {DigestAlg,F}
            when is_function(F,3)->
            case  catch F(PeerName,Port,public_key:ssh_hostkey_fingerprint(DigestAlg,Public)) of
                true->
                    true;
                _->
                    {error,{fingerprint_check_failed,DigestAlg}}
            end
    end.

yes_no(#ssh{opts = Opts},Prompt) ->
    IoCb = ssh_options:get_value(internal_options,io_cb,Opts,fun ()->
        ssh_io end,ssh_transport,929),
    IoCb:yes_no(Prompt,Opts).

fmt_hostkey(ssh-rsa) ->
    "RSA";
fmt_hostkey(ssh-dss) ->
    "DSA";
fmt_hostkey(ssh-ed25519) ->
    "ED25519";
fmt_hostkey(ssh-ed448) ->
    "ED448";
fmt_hostkey(A)
    when is_atom(A)->
    fmt_hostkey(atom_to_list(A));
fmt_hostkey("ecdsa" ++ _) ->
    "ECDSA";
fmt_hostkey(X) ->
    X.

known_host_key(#ssh{opts = Opts,peer = {PeerName,{IP,Port}}} = Ssh,Public,Alg) ->
    IsHostKey = try call_KeyCb(is_host_key,[Public, [PeerName, IP], Port, Alg],Opts)
        catch
            error:undef->
                call_KeyCb(is_host_key,[Public, PeerName, Alg],Opts) end,
    case IsHostKey of
        true->
            ok;
        false->
            DoAdd = ssh_options:get_value(user_options,save_accepted_host,Opts,ssh_transport,959),
            case accepted_host(Ssh,PeerName,Port,Public,Opts) of
                true
                    when DoAdd == true->
                    try call_KeyCb(add_host_key,[[PeerName, IP], Port, Public],Opts)
                        catch
                            error:undef->
                                call_KeyCb(add_host_key,[PeerName, Public],Opts) end;
                true
                    when DoAdd == false->
                    ok;
                false->
                    {error,rejected_by_user};
                {error,E}->
                    {error,E}
            end;
        {error,Error}->
            {error,Error}
    end.

select_algorithm(Role,Client,Server,Opts) ->
    {Encrypt0,Decrypt0} = select_encrypt_decrypt(Role,Client,Server),
    {SendMac0,RecvMac0} = select_send_recv_mac(Role,Client,Server),
    {Encrypt,SendMac} = aead_gcm_simultan(Encrypt0,SendMac0),
    {Decrypt,RecvMac} = aead_gcm_simultan(Decrypt0,RecvMac0),
    {Compression,Decompression} = select_compression_decompression(Role,Client,Server),
    C_Lng = select(Client#ssh_msg_kexinit.languages_client_to_server,Server#ssh_msg_kexinit.languages_client_to_server),
    S_Lng = select(Client#ssh_msg_kexinit.languages_server_to_client,Server#ssh_msg_kexinit.languages_server_to_client),
    HKey = select_all(Client#ssh_msg_kexinit.server_host_key_algorithms,Server#ssh_msg_kexinit.server_host_key_algorithms),
    HK = case HKey of
        []->
            undefined;
        [HK0| _]->
            HK0
    end,
    Kex = select(Client#ssh_msg_kexinit.kex_algorithms,Server#ssh_msg_kexinit.kex_algorithms),
    SendExtInfo = ssh_options:get_value(user_options,send_ext_info,Opts,ssh_transport,1015) andalso case Role of
        server->
            lists:member("ext-info-c",Client#ssh_msg_kexinit.kex_algorithms);
        client->
            lists:member("ext-info-s",Server#ssh_msg_kexinit.kex_algorithms)
    end,
    RecvExtInfo = ssh_options:get_value(user_options,recv_ext_info,Opts,ssh_transport,1026),
    {ok,#alg{kex = Kex,hkey = HK,encrypt = Encrypt,decrypt = Decrypt,send_mac = SendMac,recv_mac = RecvMac,compress = Compression,decompress = Decompression,c_lng = C_Lng,s_lng = S_Lng,send_ext_info = SendExtInfo,recv_ext_info = RecvExtInfo}}.

aead_gcm_simultan(aes128-gcm@openssh.com,_) ->
    {'AEAD_AES_128_GCM','AEAD_AES_128_GCM'};
aead_gcm_simultan(aes256-gcm@openssh.com,_) ->
    {'AEAD_AES_256_GCM','AEAD_AES_256_GCM'};
aead_gcm_simultan('AEAD_AES_128_GCM' = C,_) ->
    {C,C};
aead_gcm_simultan('AEAD_AES_256_GCM' = C,_) ->
    {C,C};
aead_gcm_simultan(_,'AEAD_AES_128_GCM' = C) ->
    {C,C};
aead_gcm_simultan(_,'AEAD_AES_256_GCM' = C) ->
    {C,C};
aead_gcm_simultan(chacha20-poly1305@openssh.com = C,_) ->
    {C,C};
aead_gcm_simultan(Cipher,Mac) ->
    {Cipher,Mac}.

select_encrypt_decrypt(client,Client,Server) ->
    Encrypt = select(Client#ssh_msg_kexinit.encryption_algorithms_client_to_server,Server#ssh_msg_kexinit.encryption_algorithms_client_to_server),
    Decrypt = select(Client#ssh_msg_kexinit.encryption_algorithms_server_to_client,Server#ssh_msg_kexinit.encryption_algorithms_server_to_client),
    {Encrypt,Decrypt};
select_encrypt_decrypt(server,Client,Server) ->
    Decrypt = select(Client#ssh_msg_kexinit.encryption_algorithms_client_to_server,Server#ssh_msg_kexinit.encryption_algorithms_client_to_server),
    Encrypt = select(Client#ssh_msg_kexinit.encryption_algorithms_server_to_client,Server#ssh_msg_kexinit.encryption_algorithms_server_to_client),
    {Encrypt,Decrypt}.

select_send_recv_mac(client,Client,Server) ->
    SendMac = select(Client#ssh_msg_kexinit.mac_algorithms_client_to_server,Server#ssh_msg_kexinit.mac_algorithms_client_to_server),
    RecvMac = select(Client#ssh_msg_kexinit.mac_algorithms_server_to_client,Server#ssh_msg_kexinit.mac_algorithms_server_to_client),
    {SendMac,RecvMac};
select_send_recv_mac(server,Client,Server) ->
    RecvMac = select(Client#ssh_msg_kexinit.mac_algorithms_client_to_server,Server#ssh_msg_kexinit.mac_algorithms_client_to_server),
    SendMac = select(Client#ssh_msg_kexinit.mac_algorithms_server_to_client,Server#ssh_msg_kexinit.mac_algorithms_server_to_client),
    {SendMac,RecvMac}.

select_compression_decompression(client,Client,Server) ->
    Compression = select(Client#ssh_msg_kexinit.compression_algorithms_client_to_server,Server#ssh_msg_kexinit.compression_algorithms_client_to_server),
    Decompression = select(Client#ssh_msg_kexinit.compression_algorithms_server_to_client,Server#ssh_msg_kexinit.compression_algorithms_server_to_client),
    {Compression,Decompression};
select_compression_decompression(server,Client,Server) ->
    Decompression = select(Client#ssh_msg_kexinit.compression_algorithms_client_to_server,Server#ssh_msg_kexinit.compression_algorithms_client_to_server),
    Compression = select(Client#ssh_msg_kexinit.compression_algorithms_server_to_client,Server#ssh_msg_kexinit.compression_algorithms_server_to_client),
    {Compression,Decompression}.

install_alg(Dir,SSH) ->
    SSH1 = alg_final(Dir,SSH),
    SSH2 = alg_setup(Dir,SSH1),
    alg_init(Dir,SSH2).

alg_setup(snd,SSH) ->
    ALG = SSH#ssh.algorithms,
    SSH#ssh{encrypt = ALG#alg.encrypt,send_mac = ALG#alg.send_mac,send_mac_size = mac_digest_size(ALG#alg.send_mac),compress = ALG#alg.compress,c_lng = ALG#alg.c_lng,s_lng = ALG#alg.s_lng,send_ext_info = ALG#alg.send_ext_info,recv_ext_info = ALG#alg.recv_ext_info};
alg_setup(rcv,SSH) ->
    ALG = SSH#ssh.algorithms,
    SSH#ssh{decrypt = ALG#alg.decrypt,recv_mac = ALG#alg.recv_mac,recv_mac_size = mac_digest_size(ALG#alg.recv_mac),decompress = ALG#alg.decompress,c_lng = ALG#alg.c_lng,s_lng = ALG#alg.s_lng,send_ext_info = ALG#alg.send_ext_info,recv_ext_info = ALG#alg.recv_ext_info}.

alg_init(snd,SSH0) ->
    {ok,SSH1} = send_mac_init(SSH0),
    {ok,SSH2} = encrypt_init(SSH1),
    {ok,SSH3} = compress_init(SSH2),
    SSH3;
alg_init(rcv,SSH0) ->
    {ok,SSH1} = recv_mac_init(SSH0),
    {ok,SSH2} = decrypt_init(SSH1),
    {ok,SSH3} = decompress_init(SSH2),
    SSH3.

alg_final(snd,SSH0) ->
    {ok,SSH1} = send_mac_final(SSH0),
    {ok,SSH2} = encrypt_final(SSH1),
    {ok,SSH3} = compress_final(SSH2),
    SSH3;
alg_final(rcv,SSH0) ->
    {ok,SSH1} = recv_mac_final(SSH0),
    {ok,SSH2} = decrypt_final(SSH1),
    {ok,SSH3} = decompress_final(SSH2),
    SSH3.

select_all(CL,SL)
    when length(CL) + length(SL) < 200->
    CLonly = CL -- SL,
    lists:foldr(fun (ALG,Acc)->
        try [list_to_existing_atom(ALG)| Acc]
            catch
                _:_->
                    Acc end end,[],CL -- CLonly);
select_all(CL,SL) ->
    Error = lists:concat(["Received too many algorithms (", length(CL), "+", length(SL), " >= ", 200, ")."]),
    ssh_connection_handler:disconnect(2,Error,ssh_transport,1198).

select([],[]) ->
    none;
select(CL,SL) ->
    C = case select_all(CL,SL) of
        []->
            undefined;
        [ALG| _]->
            ALG
    end,
    C.

ssh_packet(#ssh_msg_kexinit{} = Msg,Ssh0) ->
    BinMsg = ssh_message:encode(Msg),
    Ssh = key_init(Ssh0#ssh.role,Ssh0,BinMsg),
    pack(BinMsg,Ssh);
ssh_packet(Msg,Ssh) ->
    BinMsg = ssh_message:encode(Msg),
    pack(BinMsg,Ssh).

pack(Data,Ssh = #ssh{}) ->
    pack(Data,Ssh,0).

pack(PlainText,#ssh{send_sequence = SeqNum,send_mac = MacAlg,encrypt = CryptoAlg} = Ssh0,PacketLenDeviationForTests)
    when is_binary(PlainText)->
    {Ssh1,CompressedPlainText} = compress(Ssh0,PlainText),
    {FinalPacket,Ssh2} = pack(pkt_type(CryptoAlg),mac_type(MacAlg),CompressedPlainText,PacketLenDeviationForTests,Ssh1),
    Ssh = Ssh2#ssh{send_sequence = (SeqNum + 1) band 4294967295},
    {FinalPacket,Ssh}.

pack(common,rfc4253,PlainText,DeltaLenTst,#ssh{send_sequence = SeqNum,send_mac = MacAlg,send_mac_key = MacKey} = Ssh0) ->
    PadLen = padding_length(4 + 1 + size(PlainText),Ssh0),
    Pad = ssh_bits:random(PadLen),
    TextLen = 1 + size(PlainText) + PadLen + DeltaLenTst,
    PlainPkt = <<TextLen:32/unsigned-big-integer,PadLen:8/unsigned-big-integer,PlainText/binary,Pad/binary>>,
    {Ssh1,CipherPkt} = encrypt(Ssh0,PlainPkt),
    MAC0 = mac(MacAlg,MacKey,SeqNum,PlainPkt),
    {<<CipherPkt/binary,MAC0/binary>>,Ssh1};
pack(common,enc_then_mac,PlainText,DeltaLenTst,#ssh{send_sequence = SeqNum,send_mac = MacAlg,send_mac_key = MacKey} = Ssh0) ->
    PadLen = padding_length(1 + size(PlainText),Ssh0),
    Pad = ssh_bits:random(PadLen),
    PlainLen = 1 + size(PlainText) + PadLen + DeltaLenTst,
    PlainPkt = <<PadLen:8/unsigned-big-integer,PlainText/binary,Pad/binary>>,
    {Ssh1,CipherPkt} = encrypt(Ssh0,PlainPkt),
    EncPacketPkt = <<PlainLen:32/unsigned-big-integer,CipherPkt/binary>>,
    MAC0 = mac(MacAlg,MacKey,SeqNum,EncPacketPkt),
    {<<PlainLen:32/unsigned-big-integer,CipherPkt/binary,MAC0/binary>>,Ssh1};
pack(aead,_,PlainText,DeltaLenTst,Ssh0) ->
    PadLen = padding_length(1 + size(PlainText),Ssh0),
    Pad = ssh_bits:random(PadLen),
    PlainLen = 1 + size(PlainText) + PadLen + DeltaLenTst,
    PlainPkt = <<PadLen:8/unsigned-big-integer,PlainText/binary,Pad/binary>>,
    {Ssh1,{CipherPkt,MAC0}} = encrypt(Ssh0,<<PlainLen:32/unsigned-big-integer,PlainPkt/binary>>),
    {<<CipherPkt/binary,MAC0/binary>>,Ssh1}.

handle_packet_part(<<>>,Encrypted0,AEAD0,undefined,#ssh{decrypt = CryptoAlg,recv_mac = MacAlg} = Ssh0) ->
    case get_length(pkt_type(CryptoAlg),mac_type(MacAlg),Encrypted0,Ssh0) of
        get_more->
            {get_more,<<>>,Encrypted0,AEAD0,undefined,Ssh0};
        {ok,PacketLen,_,_,_,_}
            when PacketLen > 256 * 1024->
            {error,{exceeds_max_size,PacketLen}};
        {ok,PacketLen,Decrypted,Encrypted1,AEAD,#ssh{recv_mac_size = MacSize} = Ssh1}->
            TotalNeeded = 4 + PacketLen + MacSize,
            handle_packet_part(Decrypted,Encrypted1,AEAD,TotalNeeded,Ssh1)
    end;
handle_packet_part(DecryptedPfx,EncryptedBuffer,AEAD,TotalNeeded,Ssh0)
    when size(DecryptedPfx) + size(EncryptedBuffer) < TotalNeeded->
    {get_more,DecryptedPfx,EncryptedBuffer,AEAD,TotalNeeded,Ssh0};
handle_packet_part(DecryptedPfx,EncryptedBuffer,AEAD,TotalNeeded,#ssh{decrypt = CryptoAlg,recv_mac = MacAlg} = Ssh0) ->
    case unpack(pkt_type(CryptoAlg),mac_type(MacAlg),DecryptedPfx,EncryptedBuffer,AEAD,TotalNeeded,Ssh0) of
        {ok,Payload,NextPacketBytes,Ssh1}->
            {Ssh,DecompressedPayload} = decompress(Ssh1,Payload),
            {packet_decrypted,DecompressedPayload,NextPacketBytes,Ssh};
        Other->
            Other
    end.

unpack(common,rfc4253,DecryptedPfx,EncryptedBuffer,_AEAD,TotalNeeded,#ssh{recv_mac_size = MacSize} = Ssh0) ->
    MoreNeeded = TotalNeeded - size(DecryptedPfx) - MacSize,
    <<EncryptedSfx:MoreNeeded/binary,Mac:MacSize/binary,NextPacketBytes/binary>> = EncryptedBuffer,
    {Ssh1,DecryptedSfx} = decrypt(Ssh0,EncryptedSfx),
    PlainPkt = <<DecryptedPfx/binary,DecryptedSfx/binary>>,
    case is_valid_mac(Mac,PlainPkt,Ssh1) of
        true->
            {ok,payload(PlainPkt),NextPacketBytes,Ssh1};
        false->
            {bad_mac,Ssh1}
    end;
unpack(common,enc_then_mac,<<PlainLen:32/unsigned-big-integer>>,EncryptedBuffer,_AEAD,_TotalNeeded,#ssh{recv_mac_size = MacSize} = Ssh0) ->
    <<Payload:PlainLen/binary,MAC0:MacSize/binary,NextPacketBytes/binary>> = EncryptedBuffer,
    case is_valid_mac(MAC0,<<PlainLen:32/unsigned-big-integer,Payload/binary>>,Ssh0) of
        true->
            {Ssh1,<<PaddingLen:8/unsigned-big-integer,PlainRest/binary>>} = decrypt(Ssh0,Payload),
            CompressedPlainTextLen = size(PlainRest) - PaddingLen,
            <<CompressedPlainText:CompressedPlainTextLen/binary,_Padding/binary>> = PlainRest,
            {ok,CompressedPlainText,NextPacketBytes,Ssh1};
        false->
            {bad_mac,Ssh0}
    end;
unpack(aead,_,DecryptedPfx,EncryptedBuffer,AEAD,TotalNeeded,#ssh{recv_mac_size = MacSize} = Ssh0) ->
    MoreNeeded = TotalNeeded - size(DecryptedPfx) - MacSize,
    <<EncryptedSfx:MoreNeeded/binary,Mac:MacSize/binary,NextPacketBytes/binary>> = EncryptedBuffer,
    case decrypt(Ssh0,{AEAD,EncryptedSfx,Mac}) of
        {Ssh1,error}->
            {bad_mac,Ssh1};
        {Ssh1,DecryptedSfx}->
            DecryptedPacket = <<DecryptedPfx/binary,DecryptedSfx/binary>>,
            {ok,payload(DecryptedPacket),NextPacketBytes,Ssh1}
    end.

get_length(common,rfc4253,EncryptedBuffer,#ssh{decrypt_block_size = BlockSize} = Ssh0) ->
    case size(EncryptedBuffer) >= max(8,BlockSize) of
        true->
            <<EncBlock:BlockSize/binary,EncryptedRest/binary>> = EncryptedBuffer,
            {Ssh,<<PacketLen:32/unsigned-big-integer,_/binary>> = Decrypted} = decrypt(Ssh0,EncBlock),
            {ok,PacketLen,Decrypted,EncryptedRest,<<>>,Ssh};
        false->
            get_more
    end;
get_length(common,enc_then_mac,EncryptedBuffer,Ssh) ->
    case EncryptedBuffer of
        <<Decrypted:4/binary,EncryptedRest/binary>>->
            <<PacketLen:32/unsigned-big-integer>> = Decrypted,
            {ok,PacketLen,Decrypted,EncryptedRest,<<>>,Ssh};
        _->
            get_more
    end;
get_length(aead,_,EncryptedBuffer,Ssh) ->
    case {size(EncryptedBuffer) >= 4,Ssh#ssh.decrypt} of
        {true,chacha20-poly1305@openssh.com}->
            <<EncryptedLen:4/binary,EncryptedRest/binary>> = EncryptedBuffer,
            {Ssh1,PacketLenBin} = decrypt(Ssh,{length,EncryptedLen}),
            <<PacketLen:32/unsigned-big-integer>> = PacketLenBin,
            {ok,PacketLen,PacketLenBin,EncryptedRest,EncryptedLen,Ssh1};
        {true,_}->
            <<PacketLen:32/unsigned-big-integer,EncryptedRest/binary>> = EncryptedBuffer,
            {ok,PacketLen,<<PacketLen:32/unsigned-big-integer>>,EncryptedRest,<<PacketLen:32/unsigned-big-integer>>,Ssh};
        {false,_}->
            get_more
    end.

padding_length(Size,#ssh{encrypt_block_size = BlockSize,random_length_padding = RandomLengthPad}) ->
    PL = (BlockSize - Size rem BlockSize) rem BlockSize,
    MinPadLen = if PL < 4 ->
        PL + BlockSize;true ->
        PL end,
    PadBlockSize = max(BlockSize,4),
    MaxExtraBlocks = (max(RandomLengthPad,MinPadLen) - MinPadLen) div PadBlockSize,
    ExtraPadLen = try (rand:uniform(MaxExtraBlocks + 1) - 1) * PadBlockSize
        catch
            _:_->
                0 end,
    MinPadLen + ExtraPadLen.

payload(<<PacketLen:32,PaddingLen:8,PayloadAndPadding/binary>>) ->
    PayloadLen = PacketLen - PaddingLen - 1,
    <<Payload:PayloadLen/binary,_/binary>> = PayloadAndPadding,
    Payload.

sign(SigData,HashAlg,#{algorithm:=dss} = Key) ->
    mk_dss_sig(crypto:sign(dss,HashAlg,SigData,Key));
sign(SigData,HashAlg,#{algorithm:=SigAlg} = Key) ->
    crypto:sign(SigAlg,HashAlg,SigData,Key);
sign(SigData,HashAlg,#'DSAPrivateKey'{} = Key) ->
    mk_dss_sig(public_key:sign(SigData,HashAlg,Key));
sign(SigData,HashAlg,Key = #'ECPrivateKey'{}) ->
    DerEncodedSign = public_key:sign(SigData,HashAlg,Key),
    #'ECDSA-Sig-Value'{r = R,s = S} = public_key:der_decode('ECDSA-Sig-Value',DerEncodedSign),
    <<(ssh_bits:mpint(R))/binary,(ssh_bits:mpint(S))/binary>>;
sign(SigData,HashAlg,Key) ->
    public_key:sign(SigData,HashAlg,Key).

mk_dss_sig(DerSignature) ->
    #'Dss-Sig-Value'{r = R,s = S} = public_key:der_decode('Dss-Sig-Value',DerSignature),
    <<R:160/big-unsigned-integer,S:160/big-unsigned-integer>>.

verify(PlainText,HashAlg,Sig,{_,#'Dss-Parms'{}} = Key,_) ->
    case Sig of
        <<R:160/big-unsigned-integer,S:160/big-unsigned-integer>>->
            Signature = public_key:der_encode('Dss-Sig-Value',#'Dss-Sig-Value'{r = R,s = S}),
            public_key:verify(PlainText,HashAlg,Signature,Key);
        _->
            false
    end;
verify(PlainText,HashAlg,Sig,{#'ECPoint'{},_} = Key,_) ->
    case Sig of
        <<Rlen:32/unsigned-big-integer,R:Rlen/big-signed-integer-unit:8,Slen:32/unsigned-big-integer,S:Slen/big-signed-integer-unit:8>>->
            Sval = #'ECDSA-Sig-Value'{r = R,s = S},
            DerEncodedSig = public_key:der_encode('ECDSA-Sig-Value',Sval),
            public_key:verify(PlainText,HashAlg,DerEncodedSig,Key);
        _->
            false
    end;
verify(PlainText,HashAlg,Sig,#'RSAPublicKey'{} = Key,#ssh{role = server,c_version = "SSH-2.0-OpenSSH_7." ++ _})
    when HashAlg == sha256;
    HashAlg == sha512->
    public_key:verify(PlainText,HashAlg,Sig,Key) orelse public_key:verify(PlainText,sha,Sig,Key);
verify(PlainText,HashAlg,Sig,Key,_) ->
    public_key:verify(PlainText,HashAlg,Sig,Key).

-record(cipher, {impl,key_bytes,iv_bytes,block_bytes,pkt_type = common}).

cipher('AEAD_AES_128_GCM') ->
    #cipher{impl = aes_128_gcm,key_bytes = 16,iv_bytes = 12,block_bytes = 16,pkt_type = aead};
cipher('AEAD_AES_256_GCM') ->
    #cipher{impl = aes_256_gcm,key_bytes = 32,iv_bytes = 12,block_bytes = 16,pkt_type = aead};
cipher('3des-cbc') ->
    #cipher{impl = des_ede3_cbc,key_bytes = 24,iv_bytes = 8,block_bytes = 8};
cipher(aes128-cbc) ->
    #cipher{impl = aes_128_cbc,key_bytes = 16,iv_bytes = 16,block_bytes = 16};
cipher(aes192-cbc) ->
    #cipher{impl = aes_192_cbc,key_bytes = 24,iv_bytes = 16,block_bytes = 16};
cipher(aes256-cbc) ->
    #cipher{impl = aes_256_cbc,key_bytes = 32,iv_bytes = 16,block_bytes = 16};
cipher(aes128-ctr) ->
    #cipher{impl = aes_128_ctr,key_bytes = 16,iv_bytes = 16,block_bytes = 16};
cipher(aes192-ctr) ->
    #cipher{impl = aes_192_ctr,key_bytes = 24,iv_bytes = 16,block_bytes = 16};
cipher(aes256-ctr) ->
    #cipher{impl = aes_256_ctr,key_bytes = 32,iv_bytes = 16,block_bytes = 16};
cipher(chacha20-poly1305@openssh.com) ->
    #cipher{impl = chacha20_poly1305,key_bytes = 32,iv_bytes = 12,block_bytes = 8,pkt_type = aead};
cipher(_) ->
    #cipher{}.

pkt_type(SshCipher) ->
    (cipher(SshCipher))#cipher.pkt_type.

mac_type(hmac-sha2-256-etm@openssh.com) ->
    enc_then_mac;
mac_type(hmac-sha2-512-etm@openssh.com) ->
    enc_then_mac;
mac_type(hmac-sha1-etm@openssh.com) ->
    enc_then_mac;
mac_type(_) ->
    rfc4253.

decrypt_magic(server) ->
    {"A","C"};
decrypt_magic(client) ->
    {"B","D"}.

encrypt_magic(client) ->
    decrypt_magic(server);
encrypt_magic(server) ->
    decrypt_magic(client).

encrypt_init(#ssh{encrypt = none} = Ssh) ->
    {ok,Ssh};
encrypt_init(#ssh{encrypt = chacha20-poly1305@openssh.com,role = Role} = Ssh) ->
    {_,KeyMagic} = encrypt_magic(Role),
    <<K2:32/binary,K1:32/binary>> = hash(Ssh,KeyMagic,8 * 64),
    {ok,Ssh#ssh{encrypt_keys = {K1,K2}}};
encrypt_init(#ssh{encrypt = SshCipher,role = Role} = Ssh)
    when SshCipher == 'AEAD_AES_128_GCM';
    SshCipher == 'AEAD_AES_256_GCM'->
    {IvMagic,KeyMagic} = encrypt_magic(Role),
    #cipher{impl = CryptoCipher,key_bytes = KeyBytes,iv_bytes = IvBytes,block_bytes = BlockBytes} = cipher(SshCipher),
    IV = hash(Ssh,IvMagic,8 * IvBytes),
    K = hash(Ssh,KeyMagic,8 * KeyBytes),
    {ok,Ssh#ssh{encrypt_cipher = CryptoCipher,encrypt_keys = K,encrypt_block_size = BlockBytes,encrypt_ctx = IV}};
encrypt_init(#ssh{encrypt = SshCipher,role = Role} = Ssh) ->
    {IvMagic,KeyMagic} = encrypt_magic(Role),
    #cipher{impl = CryptoCipher,key_bytes = KeyBytes,iv_bytes = IvBytes,block_bytes = BlockBytes} = cipher(SshCipher),
    IV = hash(Ssh,IvMagic,8 * IvBytes),
    K = hash(Ssh,KeyMagic,8 * KeyBytes),
    Ctx0 = crypto:crypto_init(CryptoCipher,K,IV,true),
    {ok,Ssh#ssh{encrypt_cipher = CryptoCipher,encrypt_block_size = BlockBytes,encrypt_ctx = Ctx0}}.

encrypt_final(Ssh) ->
    {ok,Ssh#ssh{encrypt = none,encrypt_keys = undefined,encrypt_block_size = 8,encrypt_ctx = undefined}}.

encrypt(#ssh{encrypt = none} = Ssh,Data) ->
    {Ssh,Data};
encrypt(#ssh{encrypt = chacha20-poly1305@openssh.com,encrypt_keys = {K1,K2},send_sequence = Seq} = Ssh,<<LenData:4/binary,PayloadData/binary>>) ->
    IV1 = <<0:8/unit:8,Seq:8/unit:8>>,
    EncLen = crypto:crypto_one_time(chacha20,K1,IV1,LenData,true),
    IV2 = <<1:8/little-unit:8,Seq:8/unit:8>>,
    EncPayloadData = crypto:crypto_one_time(chacha20,K2,IV2,PayloadData,true),
    PolyKey = crypto:crypto_one_time(chacha20,K2,<<0:8/unit:8,Seq:8/unit:8>>,<<0:32/unit:8>>,true),
    EncBytes = <<EncLen/binary,EncPayloadData/binary>>,
    Ctag = crypto:mac(poly1305,PolyKey,EncBytes),
    {Ssh,{EncBytes,Ctag}};
encrypt(#ssh{encrypt = SshCipher,encrypt_cipher = CryptoCipher,encrypt_keys = K,encrypt_ctx = IV0} = Ssh,<<LenData:4/binary,PayloadData/binary>>)
    when SshCipher == 'AEAD_AES_128_GCM';
    SshCipher == 'AEAD_AES_256_GCM'->
    {Ctext,Ctag} = crypto:crypto_one_time_aead(CryptoCipher,K,IV0,PayloadData,LenData,true),
    IV = next_gcm_iv(IV0),
    {Ssh#ssh{encrypt_ctx = IV},{<<LenData/binary,Ctext/binary>>,Ctag}};
encrypt(#ssh{encrypt_ctx = Ctx0} = Ssh,Data) ->
    Enc = crypto:crypto_update(Ctx0,Data),
    {Ssh,Enc}.

decrypt_init(#ssh{decrypt = none} = Ssh) ->
    {ok,Ssh};
decrypt_init(#ssh{decrypt = chacha20-poly1305@openssh.com,role = Role} = Ssh) ->
    {_,KeyMagic} = decrypt_magic(Role),
    <<K2:32/binary,K1:32/binary>> = hash(Ssh,KeyMagic,8 * 64),
    {ok,Ssh#ssh{decrypt_keys = {K1,K2}}};
decrypt_init(#ssh{decrypt = SshCipher,role = Role} = Ssh)
    when SshCipher == 'AEAD_AES_128_GCM';
    SshCipher == 'AEAD_AES_256_GCM'->
    {IvMagic,KeyMagic} = decrypt_magic(Role),
    #cipher{impl = CryptoCipher,key_bytes = KeyBytes,iv_bytes = IvBytes,block_bytes = BlockBytes} = cipher(SshCipher),
    IV = hash(Ssh,IvMagic,8 * IvBytes),
    K = hash(Ssh,KeyMagic,8 * KeyBytes),
    {ok,Ssh#ssh{decrypt_cipher = CryptoCipher,decrypt_keys = K,decrypt_block_size = BlockBytes,decrypt_ctx = IV}};
decrypt_init(#ssh{decrypt = SshCipher,role = Role} = Ssh) ->
    {IvMagic,KeyMagic} = decrypt_magic(Role),
    #cipher{impl = CryptoCipher,key_bytes = KeyBytes,iv_bytes = IvBytes,block_bytes = BlockBytes} = cipher(SshCipher),
    IV = hash(Ssh,IvMagic,8 * IvBytes),
    K = hash(Ssh,KeyMagic,8 * KeyBytes),
    Ctx0 = crypto:crypto_init(CryptoCipher,K,IV,false),
    {ok,Ssh#ssh{decrypt_cipher = CryptoCipher,decrypt_block_size = BlockBytes,decrypt_ctx = Ctx0}}.

decrypt_final(Ssh) ->
    {ok,Ssh#ssh{decrypt = none,decrypt_keys = undefined,decrypt_ctx = undefined,decrypt_block_size = 8}}.

decrypt(Ssh,<<>>) ->
    {Ssh,<<>>};
decrypt(#ssh{decrypt = chacha20-poly1305@openssh.com,decrypt_keys = {K1,K2},recv_sequence = Seq} = Ssh,Data) ->
    case Data of
        {length,EncryptedLen}->
            PacketLenBin = crypto:crypto_one_time(chacha20,K1,<<0:8/unit:8,Seq:8/unit:8>>,EncryptedLen,false),
            {Ssh,PacketLenBin};
        {AAD,Ctext,Ctag}->
            PolyKey = crypto:crypto_one_time(chacha20,K2,<<0:8/unit:8,Seq:8/unit:8>>,<<0:32/unit:8>>,false),
            case crypto:equal_const_time(Ctag,crypto:mac(poly1305,PolyKey,<<AAD/binary,Ctext/binary>>)) of
                true->
                    IV2 = <<1:8/little-unit:8,Seq:8/unit:8>>,
                    PlainText = crypto:crypto_one_time(chacha20,K2,IV2,Ctext,false),
                    {Ssh,PlainText};
                false->
                    {Ssh,error}
            end
    end;
decrypt(#ssh{decrypt = none} = Ssh,Data) ->
    {Ssh,Data};
decrypt(#ssh{decrypt = SshCipher,decrypt_cipher = CryptoCipher,decrypt_keys = K,decrypt_ctx = IV0} = Ssh,{AAD,Ctext,Ctag})
    when SshCipher == 'AEAD_AES_128_GCM';
    SshCipher == 'AEAD_AES_256_GCM'->
    Dec = crypto:crypto_one_time_aead(CryptoCipher,K,IV0,Ctext,AAD,Ctag,false),
    IV = next_gcm_iv(IV0),
    {Ssh#ssh{decrypt_ctx = IV},Dec};
decrypt(#ssh{decrypt_ctx = Ctx0} = Ssh,Data) ->
    Dec = crypto:crypto_update(Ctx0,Data),
    {Ssh,Dec}.

next_gcm_iv(<<Fixed:32,InvCtr:64>>) ->
    <<Fixed:32,(InvCtr + 1):64>>.

compress_init(SSH) ->
    compress_init(SSH,1).

compress_init(#ssh{compress = none} = Ssh,_) ->
    {ok,Ssh};
compress_init(#ssh{compress = zlib} = Ssh,Level) ->
    Zlib = zlib:open(),
    ok = zlib:deflateInit(Zlib,Level),
    {ok,Ssh#ssh{compress_ctx = Zlib}};
compress_init(#ssh{compress = zlib@openssh.com} = Ssh,Level) ->
    Zlib = zlib:open(),
    ok = zlib:deflateInit(Zlib,Level),
    {ok,Ssh#ssh{compress_ctx = Zlib}}.

compress_final(#ssh{compress = none} = Ssh) ->
    {ok,Ssh};
compress_final(#ssh{compress = zlib,compress_ctx = Context} = Ssh) ->
    zlib:close(Context),
    {ok,Ssh#ssh{compress = none,compress_ctx = undefined}};
compress_final(#ssh{compress = zlib@openssh.com,authenticated = false} = Ssh) ->
    {ok,Ssh};
compress_final(#ssh{compress = zlib@openssh.com,compress_ctx = Context,authenticated = true} = Ssh) ->
    zlib:close(Context),
    {ok,Ssh#ssh{compress = none,compress_ctx = undefined}}.

compress(#ssh{compress = none} = Ssh,Data) ->
    {Ssh,Data};
compress(#ssh{compress = zlib,compress_ctx = Context} = Ssh,Data) ->
    Compressed = zlib:deflate(Context,Data,sync),
    {Ssh,list_to_binary(Compressed)};
compress(#ssh{compress = zlib@openssh.com,authenticated = false} = Ssh,Data) ->
    {Ssh,Data};
compress(#ssh{compress = zlib@openssh.com,compress_ctx = Context,authenticated = true} = Ssh,Data) ->
    Compressed = zlib:deflate(Context,Data,sync),
    {Ssh,list_to_binary(Compressed)}.

decompress_init(#ssh{decompress = none} = Ssh) ->
    {ok,Ssh};
decompress_init(#ssh{decompress = zlib} = Ssh) ->
    Zlib = zlib:open(),
    ok = zlib:inflateInit(Zlib),
    {ok,Ssh#ssh{decompress_ctx = Zlib}};
decompress_init(#ssh{decompress = zlib@openssh.com} = Ssh) ->
    Zlib = zlib:open(),
    ok = zlib:inflateInit(Zlib),
    {ok,Ssh#ssh{decompress_ctx = Zlib}}.

decompress_final(#ssh{decompress = none} = Ssh) ->
    {ok,Ssh};
decompress_final(#ssh{decompress = zlib,decompress_ctx = Context} = Ssh) ->
    zlib:close(Context),
    {ok,Ssh#ssh{decompress = none,decompress_ctx = undefined}};
decompress_final(#ssh{decompress = zlib@openssh.com,authenticated = false} = Ssh) ->
    {ok,Ssh};
decompress_final(#ssh{decompress = zlib@openssh.com,decompress_ctx = Context,authenticated = true} = Ssh) ->
    zlib:close(Context),
    {ok,Ssh#ssh{decompress = none,decompress_ctx = undefined}}.

decompress(#ssh{decompress = none} = Ssh,Data) ->
    {Ssh,Data};
decompress(#ssh{decompress = zlib,decompress_ctx = Context} = Ssh,Data) ->
    Decompressed = zlib:inflate(Context,Data),
    {Ssh,list_to_binary(Decompressed)};
decompress(#ssh{decompress = zlib@openssh.com,authenticated = false} = Ssh,Data) ->
    {Ssh,Data};
decompress(#ssh{decompress = zlib@openssh.com,decompress_ctx = Context,authenticated = true} = Ssh,Data) ->
    Decompressed = zlib:inflate(Context,Data),
    {Ssh,list_to_binary(Decompressed)}.

send_mac_init(SSH) ->
    case pkt_type(SSH#ssh.send_mac) of
        common->
            case SSH#ssh.role of
                client->
                    KeySize = 8 * mac_key_bytes(SSH#ssh.send_mac),
                    Key = hash(SSH,"E",KeySize),
                    {ok,SSH#ssh{send_mac_key = Key}};
                server->
                    KeySize = 8 * mac_key_bytes(SSH#ssh.send_mac),
                    Key = hash(SSH,"F",KeySize),
                    {ok,SSH#ssh{send_mac_key = Key}}
            end;
        _->
            {ok,SSH}
    end.

send_mac_final(SSH) ->
    {ok,SSH#ssh{send_mac = none,send_mac_key = undefined}}.

recv_mac_init(SSH) ->
    case pkt_type(SSH#ssh.recv_mac) of
        common->
            case SSH#ssh.role of
                client->
                    Key = hash(SSH,"F",8 * mac_key_bytes(SSH#ssh.recv_mac)),
                    {ok,SSH#ssh{recv_mac_key = Key}};
                server->
                    Key = hash(SSH,"E",8 * mac_key_bytes(SSH#ssh.recv_mac)),
                    {ok,SSH#ssh{recv_mac_key = Key}}
            end;
        _->
            {ok,SSH}
    end.

recv_mac_final(SSH) ->
    {ok,SSH#ssh{recv_mac = none,recv_mac_key = undefined}}.

mac(none,_,_,_) ->
    <<>>;
mac(hmac-sha1,Key,SeqNum,Data) ->
    crypto:mac(hmac,sha,Key,[<<SeqNum:32/unsigned-big-integer>>, Data]);
mac(hmac-sha1-96,Key,SeqNum,Data) ->
    crypto:macN(hmac,sha,Key,[<<SeqNum:32/unsigned-big-integer>>, Data],mac_digest_size(hmac-sha1-96));
mac(hmac-md5,Key,SeqNum,Data) ->
    crypto:mac(hmac,md5,Key,[<<SeqNum:32/unsigned-big-integer>>, Data]);
mac(hmac-md5-96,Key,SeqNum,Data) ->
    crypto:macN(hmac,md5,Key,[<<SeqNum:32/unsigned-big-integer>>, Data],mac_digest_size(hmac-md5-96));
mac(hmac-sha2-256,Key,SeqNum,Data) ->
    crypto:mac(hmac,sha256,Key,[<<SeqNum:32/unsigned-big-integer>>, Data]);
mac(hmac-sha2-512,Key,SeqNum,Data) ->
    crypto:mac(hmac,sha512,Key,[<<SeqNum:32/unsigned-big-integer>>, Data]);
mac(hmac-sha1-etm@openssh.com,Key,SeqNum,Data) ->
    mac(hmac-sha1,Key,SeqNum,Data);
mac(hmac-sha2-256-etm@openssh.com,Key,SeqNum,Data) ->
    mac(hmac-sha2-256,Key,SeqNum,Data);
mac(hmac-sha2-512-etm@openssh.com,Key,SeqNum,Data) ->
    mac(hmac-sha2-512,Key,SeqNum,Data).

hash(_SSH,_Char,0) ->
    <<>>;
hash(SSH,Char,N) ->
    HashAlg = sha((SSH#ssh.algorithms)#alg.kex),
    K = SSH#ssh.shared_secret,
    H = SSH#ssh.exchanged_hash,
    K1 = crypto:hash(HashAlg,[K, H, Char, SSH#ssh.session_id]),
    Sz = N div 8,
    <<Key:Sz/binary,_/binary>> = hash(K,H,K1,N - 128,HashAlg),
    Key.

hash(_K,_H,Ki,N,_HashAlg)
    when N =< 0->
    Ki;
hash(K,H,Ki,N,HashAlg) ->
    Kj = crypto:hash(HashAlg,[K, H, Ki]),
    hash(K,H,<<Ki/binary,Kj/binary>>,N - 128,HashAlg).

kex_hash(SSH,Key,HashAlg,Args) ->
    crypto:hash(HashAlg,kex_plaintext(SSH,Key,Args)).

kex_plaintext(SSH,Key,Args) ->
    EncodedKey = ssh_message:ssh2_pubkey_encode(Key),
    <<(size(if is_binary(SSH#ssh.c_version) ->
        SSH#ssh.c_version;is_list(SSH#ssh.c_version) ->
        list_to_binary(SSH#ssh.c_version);SSH#ssh.c_version == undefined ->
        <<>> end)):32/unsigned-big-integer,if is_binary(SSH#ssh.c_version) ->
        SSH#ssh.c_version;is_list(SSH#ssh.c_version) ->
        list_to_binary(SSH#ssh.c_version);SSH#ssh.c_version == undefined ->
        <<>> end/binary,(size(if is_binary(SSH#ssh.s_version) ->
        SSH#ssh.s_version;is_list(SSH#ssh.s_version) ->
        list_to_binary(SSH#ssh.s_version);SSH#ssh.s_version == undefined ->
        <<>> end)):32/unsigned-big-integer,if is_binary(SSH#ssh.s_version) ->
        SSH#ssh.s_version;is_list(SSH#ssh.s_version) ->
        list_to_binary(SSH#ssh.s_version);SSH#ssh.s_version == undefined ->
        <<>> end/binary,(size(SSH#ssh.c_keyinit)):32/unsigned-big-integer,(SSH#ssh.c_keyinit)/binary,(size(SSH#ssh.s_keyinit)):32/unsigned-big-integer,(SSH#ssh.s_keyinit)/binary,(size(EncodedKey)):32/unsigned-big-integer,EncodedKey/binary,(kex_alg_dependent(Args))/binary>>.

kex_alg_dependent({Q_c,Q_s,K})
    when is_binary(Q_c),
    is_binary(Q_s)->
    <<(size(Q_c)):32/unsigned-big-integer,Q_c/binary,(size(Q_s)):32/unsigned-big-integer,Q_s/binary,(ssh_bits:mpint(K))/binary>>;
kex_alg_dependent({E,F,K}) ->
    <<(ssh_bits:mpint(E))/binary,(ssh_bits:mpint(F))/binary,(ssh_bits:mpint(K))/binary>>;
kex_alg_dependent({-1,NBits,-1,Prime,Gen,E,F,K}) ->
    <<NBits:32/unsigned-big-integer,(ssh_bits:mpint(Prime))/binary,(ssh_bits:mpint(Gen))/binary,(ssh_bits:mpint(E))/binary,(ssh_bits:mpint(F))/binary,(ssh_bits:mpint(K))/binary>>;
kex_alg_dependent({Min,NBits,Max,Prime,Gen,E,F,K}) ->
    <<Min:32/unsigned-big-integer,NBits:32/unsigned-big-integer,Max:32/unsigned-big-integer,(ssh_bits:mpint(Prime))/binary,(ssh_bits:mpint(Gen))/binary,(ssh_bits:mpint(E))/binary,(ssh_bits:mpint(F))/binary,(ssh_bits:mpint(K))/binary>>.

valid_key_sha_alg(_,#{engine:=_,key_id:=_},_Alg) ->
    true;
valid_key_sha_alg(public,#'RSAPublicKey'{},rsa-sha2-512) ->
    true;
valid_key_sha_alg(public,#'RSAPublicKey'{},rsa-sha2-384) ->
    true;
valid_key_sha_alg(public,#'RSAPublicKey'{},rsa-sha2-256) ->
    true;
valid_key_sha_alg(public,#'RSAPublicKey'{},ssh-rsa) ->
    true;
valid_key_sha_alg(private,#'RSAPrivateKey'{},rsa-sha2-512) ->
    true;
valid_key_sha_alg(private,#'RSAPrivateKey'{},rsa-sha2-384) ->
    true;
valid_key_sha_alg(private,#'RSAPrivateKey'{},rsa-sha2-256) ->
    true;
valid_key_sha_alg(private,#'RSAPrivateKey'{},ssh-rsa) ->
    true;
valid_key_sha_alg(public,{_,#'Dss-Parms'{}},ssh-dss) ->
    true;
valid_key_sha_alg(private,#'DSAPrivateKey'{},ssh-dss) ->
    true;
valid_key_sha_alg(public,{ed_pub,ed25519,_},ssh-ed25519) ->
    true;
valid_key_sha_alg(private,{ed_pri,ed25519,_,_},ssh-ed25519) ->
    true;
valid_key_sha_alg(public,{ed_pub,ed448,_},ssh-ed448) ->
    true;
valid_key_sha_alg(private,{ed_pri,ed448,_,_},ssh-ed448) ->
    true;
valid_key_sha_alg(public,{#'ECPoint'{},{namedCurve,OID}},Alg)
    when is_tuple(OID)->
    valid_key_sha_alg_ec(OID,Alg);
valid_key_sha_alg(private,#'ECPrivateKey'{parameters = {namedCurve,OID}},Alg)
    when is_tuple(OID)->
    valid_key_sha_alg_ec(OID,Alg);
valid_key_sha_alg(_,_,_) ->
    false.

valid_key_sha_alg_ec(OID,Alg) ->
    try Curve = public_key:oid2ssh_curvename(OID),
    Alg == list_to_existing_atom("ecdsa-sha2-" ++ binary_to_list(Curve))
        catch
            _:_->
                false end.

-dialyzer({no_match,{public_algo,1}}).

public_algo(#'RSAPublicKey'{}) ->
    ssh-rsa;
public_algo({_,#'Dss-Parms'{}}) ->
    ssh-dss;
public_algo({ed_pub,ed25519,_}) ->
    ssh-ed25519;
public_algo({ed_pub,ed448,_}) ->
    ssh-ed448;
public_algo({#'ECPoint'{},{namedCurve,OID}})
    when is_tuple(OID)->
    SshName = public_key:oid2ssh_curvename(OID),
    try list_to_existing_atom("ecdsa-sha2-" ++ binary_to_list(SshName))
        catch
            _:_->
                undefined end.

sha(ssh-rsa) ->
    sha;
sha(rsa-sha2-256) ->
    sha256;
sha(rsa-sha2-384) ->
    sha384;
sha(rsa-sha2-512) ->
    sha512;
sha(ssh-dss) ->
    sha;
sha(ecdsa-sha2-nistp256) ->
    sha(secp256r1);
sha(ecdsa-sha2-nistp384) ->
    sha(secp384r1);
sha(ecdsa-sha2-nistp521) ->
    sha(secp521r1);
sha(ssh-ed25519) ->
    undefined;
sha(ssh-ed448) ->
    undefined;
sha(secp256r1) ->
    sha256;
sha(secp384r1) ->
    sha384;
sha(secp521r1) ->
    sha512;
sha(diffie-hellman-group1-sha1) ->
    sha;
sha(diffie-hellman-group14-sha1) ->
    sha;
sha(diffie-hellman-group14-sha256) ->
    sha256;
sha(diffie-hellman-group16-sha512) ->
    sha512;
sha(diffie-hellman-group18-sha512) ->
    sha512;
sha(diffie-hellman-group-exchange-sha1) ->
    sha;
sha(diffie-hellman-group-exchange-sha256) ->
    sha256;
sha({1,2,840,10045,3,1,7}) ->
    sha(secp256r1);
sha({1,3,132,0,34}) ->
    sha(secp384r1);
sha({1,3,132,0,35}) ->
    sha(secp521r1);
sha(ecdh-sha2-nistp256) ->
    sha(secp256r1);
sha(ecdh-sha2-nistp384) ->
    sha(secp384r1);
sha(ecdh-sha2-nistp521) ->
    sha(secp521r1);
sha(curve25519-sha256) ->
    sha256;
sha(curve25519-sha256@libssh.org) ->
    sha256;
sha(curve448-sha512) ->
    sha512;
sha(x25519) ->
    sha256;
sha(x448) ->
    sha512;
sha(Str)
    when is_list(Str),
    length(Str) < 50->
    sha(list_to_existing_atom(Str)).

mac_key_bytes(hmac-sha1) ->
    20;
mac_key_bytes(hmac-sha1-etm@openssh.com) ->
    20;
mac_key_bytes(hmac-sha1-96) ->
    20;
mac_key_bytes(hmac-md5) ->
    16;
mac_key_bytes(hmac-md5-96) ->
    16;
mac_key_bytes(hmac-sha2-256) ->
    32;
mac_key_bytes(hmac-sha2-256-etm@openssh.com) ->
    32;
mac_key_bytes(hmac-sha2-512) ->
    64;
mac_key_bytes(hmac-sha2-512-etm@openssh.com) ->
    64;
mac_key_bytes('AEAD_AES_128_GCM') ->
    0;
mac_key_bytes('AEAD_AES_256_GCM') ->
    0;
mac_key_bytes(chacha20-poly1305@openssh.com) ->
    0;
mac_key_bytes(none) ->
    0.

mac_digest_size(hmac-sha1) ->
    20;
mac_digest_size(hmac-sha1-etm@openssh.com) ->
    20;
mac_digest_size(hmac-sha1-96) ->
    12;
mac_digest_size(hmac-md5) ->
    20;
mac_digest_size(hmac-md5-96) ->
    12;
mac_digest_size(hmac-sha2-256) ->
    32;
mac_digest_size(hmac-sha2-256-etm@openssh.com) ->
    32;
mac_digest_size(hmac-sha2-512) ->
    64;
mac_digest_size(hmac-sha2-512-etm@openssh.com) ->
    64;
mac_digest_size('AEAD_AES_128_GCM') ->
    16;
mac_digest_size('AEAD_AES_256_GCM') ->
    16;
mac_digest_size(chacha20-poly1305@openssh.com) ->
    16;
mac_digest_size(none) ->
    0.

dh_group(diffie-hellman-group1-sha1) ->
    {2,179769313486231590770839156793787453197860296048756011706444423684197180216158519368947833795864925541502180565485980503646440548199239100050792877003355816639229553136239076508735759914822574862575007425302077447712589550957937778424442426617334727629299387668709205606050270810842907692932019128194467627007};
dh_group(diffie-hellman-group14-sha1) ->
    {2,32317006071311007300338913926423828248817941241140239112842009751400741706634354222619689417363569347117901737909704191754605873209195028853758986185622153212175412514901774520270235796078236248884246189477587641105928646099411723245426622522193230540919037680524235519125679715870117001058055877651038861847280257976054903569732561526167081339361799541336476559160368317896729073178384589680639671900977202194168647225871031411336429319536193471636533209717077448227988588565369208645296636077250268955505928362751121174096972998068410554359584866583291642136218231078990999448652468262416972035911852507045361090559};
dh_group(diffie-hellman-group14-sha256) ->
    {2,32317006071311007300338913926423828248817941241140239112842009751400741706634354222619689417363569347117901737909704191754605873209195028853758986185622153212175412514901774520270235796078236248884246189477587641105928646099411723245426622522193230540919037680524235519125679715870117001058055877651038861847280257976054903569732561526167081339361799541336476559160368317896729073178384589680639671900977202194168647225871031411336429319536193471636533209717077448227988588565369208645296636077250268955505928362751121174096972998068410554359584866583291642136218231078990999448652468262416972035911852507045361090559};
dh_group(diffie-hellman-group16-sha512) ->
    {2,1044388881413152506679602719846529545831269060992135009022588756444338172022322690710444046669809783930111585737890362691860127079270495454517218673016928427459146001866885779762982229321192368303346235204368051010309155674155697460347176946394076535157284994895284821633700921811716738972451834979455897010306333468590751358365138782250372269117968985194322444535687415522007151638638141456178420621277822674995027990278673458629544391736919766299005511505446177668154446234882665961680796576903199116089347634947187778906528008004756692571666922964122566174582776707332452371001272163776841229318324903125740713574141005124561965913888899753461735347970011693256316751660678950830027510255804846105583465055446615090444309583050775808509297040039680057435342253926566240898195863631588888936364129920059308455669454034010391478238784189888594672336242763795138176353222845524644040094258962433613354036104643881925238489224010194193088911666165584229424668165441688927790460608264864204237717002054744337988941974661214699689706521543006262604535890998125752275942608772174376107314217749233048217904944409836238235772306749874396760463376480215133461333478395682746608242585133953883882226786118030184028136755970045385534758453247};
dh_group(diffie-hellman-group18-sha512) ->
    {2,1090748135619415929450294929359784500348155124953172211774101106966150168922785639028532473848836817769712164169076432969224698752674677662739994265785437233596157045970922338040698100507861033047312331823982435279475700199860971612732540528796554502867919746776983759391475987142521315878719577519148811830879919426939958487087540965716419167467499326156226529675209172277001377591248147563782880558861083327174154014975134893125116015776318890295960698011614157721282527539468816519319333337503114777192360412281721018955834377615480468479252748867320362385355596601795122806756217713579819870634321561907813255153703950795271232652404894983869492174481652303803498881366210508647263668376514131031102336837488999775744046733651827239395353540348414872854639719294694323450186884189822544540647226987292160693184734654941906936646576130260972193280317171696418971553954161446191759093719524951116705577362073481319296041201283516154269044389257727700289684119460283480452306204130024913879981135908026983868205969318167819680850998649694416907952712904962404937775789698917207356355227455066183815847669135530549755439819480321732925869069136146085326382334628745456398071603058051634209386708703306545903199608523824513729625136659128221100967735450519952404248198262813831097374261650380017277916975324134846574681307337017380830353680623216336949471306191686438249305686413380231046096450953594089375540285037292470929395114028305547452584962074309438151825437902976012891749355198678420603722034900311364893046495761404333938686140037848030916292543273684533640032637639100774502371542479302473698388692892420946478947733800387782741417786484770190108867879778991633218628640533982619322466154883011452291890252336487236086654396093853898628805813177559162076363154436494477507871294119841637867701722166609831201845484078070518041336869808398454625586921201308185638888082699408686536045192649569198110353659943111802300636106509865023943661829436426563007917282050894429388841748885398290707743052973605359277515749619730823773215894755121761467887865327707115573804264519206349215850195195364813387526811742474131549802130246506341207020335797706780705406945275438806265978516209706795702579244075380490231741030862614968783306207869687868108423639971983209077624758080499988275591392787267627182442892809646874228263172435642368588260139161962836121481966092745325488641054238839295138992979335446110090325230955276870524611359124918392740353154294858383359}.

parallell_gen_key(Ssh = #ssh{keyex_key = {x,{G,P}},algorithms = Algs}) ->
    Sz = dh_bits(Algs),
    {Public,Private} = generate_key(dh,[P, G, 2 * Sz]),
    Ssh#ssh{keyex_key = {{Private,Public},{G,P}}}.

generate_key(ecdh = Algorithm,Args) ->
    crypto:generate_key(Algorithm,Args);
generate_key(Algorithm,Args) ->
    {Public,Private} = crypto:generate_key(Algorithm,Args),
    {crypto:bytes_to_integer(Public),crypto:bytes_to_integer(Private)}.

compute_key(Algorithm,OthersPublic,MyPrivate,Args) ->
    Shared = crypto:compute_key(Algorithm,OthersPublic,MyPrivate,Args),
    crypto:bytes_to_integer(Shared).

dh_bits(#alg{encrypt = Encrypt,send_mac = SendMac}) ->
    C = cipher(Encrypt),
    8 * lists:max([C#cipher.key_bytes, C#cipher.block_bytes, C#cipher.iv_bytes, mac_key_bytes(SendMac)]).

ecdh_curve(ecdh-sha2-nistp256) ->
    secp256r1;
ecdh_curve(ecdh-sha2-nistp384) ->
    secp384r1;
ecdh_curve(ecdh-sha2-nistp521) ->
    secp521r1;
ecdh_curve(curve448-sha512) ->
    x448;
ecdh_curve(curve25519-sha256) ->
    x25519;
ecdh_curve(curve25519-sha256@libssh.org) ->
    x25519.

supported_algorithms(Key,[{client2server,BL1}, {server2client,BL2}]) ->
    [{client2server,As1}, {server2client,As2}] = supported_algorithms(Key),
    [{client2server,As1 -- BL1}, {server2client,As2 -- BL2}];
supported_algorithms(Key,BlackList) ->
    supported_algorithms(Key) -- BlackList.

select_crypto_supported(L) ->
    Sup = crypto:supports(),
    [Name || {Name,CryptoRequires} <- L,crypto_supported(CryptoRequires,Sup)].

crypto_supported(Conditions,Supported) ->
    lists:all(fun ({Tag,CryptoName})
        when is_atom(CryptoName)->
        crypto_name_supported(Tag,CryptoName,Supported) end,Conditions).

crypto_name_supported(Tag,CryptoName,Supported) ->
    Vs = proplists:get_value(Tag,Supported,[]),
    lists:member(CryptoName,Vs).

same(Algs) ->
    [{client2server,Algs}, {server2client,Algs}].

trim_tail(Str) ->
    lists:takewhile(fun (C)->
        C =/= $\r andalso C =/= $\n end,Str).

ssh_dbg_trace_points() ->
    [alg, ssh_messages, raw_messages, hello].

ssh_dbg_flags(alg) ->
    [c];
ssh_dbg_flags(hello) ->
    [c];
ssh_dbg_flags(raw_messages) ->
    ssh_dbg_flags(hello);
ssh_dbg_flags(ssh_messages) ->
    ssh_dbg_flags(hello).

ssh_dbg_on(alg) ->
    dbg:tpl(ssh_transport,select_algorithm,4,x);
ssh_dbg_on(hello) ->
    dbg:tp(ssh_transport,hello_version_msg,1,x),
    dbg:tp(ssh_transport,handle_hello_version,1,x);
ssh_dbg_on(raw_messages) ->
    ssh_dbg_on(hello);
ssh_dbg_on(ssh_messages) ->
    ssh_dbg_on(hello).

ssh_dbg_off(alg) ->
    dbg:ctpl(ssh_transport,select_algorithm,4);
ssh_dbg_off(hello) ->
    dbg:ctpg(ssh_transport,hello_version_msg,1),
    dbg:ctpg(ssh_transport,handle_hello_version,1);
ssh_dbg_off(raw_messages) ->
    ssh_dbg_off(hello);
ssh_dbg_off(ssh_messages) ->
    ssh_dbg_off(hello).

ssh_dbg_format(hello,{call,{ssh_transport,hello_version_msg,[_]}}) ->
    skip;
ssh_dbg_format(hello,{return_from,{ssh_transport,hello_version_msg,1},Hello}) ->
    ["Going to send hello message:\n", Hello];
ssh_dbg_format(hello,{call,{ssh_transport,handle_hello_version,[Hello]}}) ->
    ["Received hello message:\n", Hello];
ssh_dbg_format(hello,{return_from,{ssh_transport,handle_hello_version,1},_Ret}) ->
    skip;
ssh_dbg_format(alg,{call,{ssh_transport,select_algorithm,[_, _, _, _]}}) ->
    skip;
ssh_dbg_format(alg,{return_from,{ssh_transport,select_algorithm,4},{ok,Alg}}) ->
    ["Negotiated algorithms:\n", wr_record(Alg)];
ssh_dbg_format(raw_messages,X) ->
    ssh_dbg_format(hello,X);
ssh_dbg_format(ssh_messages,X) ->
    ssh_dbg_format(hello,X).

wr_record(R = #alg{}) ->
    ssh_dbg:wr_record(R,record_info(fields,alg),[]).
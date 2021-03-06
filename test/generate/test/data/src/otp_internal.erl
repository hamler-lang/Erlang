-file("otp_internal.erl", 1).

-module(otp_internal).

-file("otp_internal.hrl", 1).

-export([obsolete/3, obsolete_type/3]).

-type(tag()::deprecated|removed).

-type(mfas()::mfa()|{atom(),atom(),[byte()]}|string()).

-type(release()::string()).

-spec(obsolete(module(),atom(),arity()) -> no|{tag(),string()}|{tag(),mfas(),release()}).

-spec(obsolete_type(module(),atom(),arity()) -> no|{tag(),string()}|{tag(),mfas(),release()}).

-file("otp_internal.erl", 24).

-dialyzer({no_match,{obsolete,3}}).

obsolete(auth,cookie,0) ->
    {deprecated,"use erlang:get_cookie/0 instead"};
obsolete(auth,cookie,1) ->
    {deprecated,"use erlang:set_cookie/2 instead"};
obsolete(auth,is_auth,1) ->
    {deprecated,"use net_adm:ping/1 instead"};
obsolete(calendar,local_time_to_universal_time,1) ->
    {deprecated,"use calendar:local_time_to_universal_time_dst/1 instead"};
obsolete(code,rehash,0) ->
    {deprecated,"the code path cache feature has been removed"};
obsolete(crypto,block_decrypt,3) ->
    {deprecated,"use crypto:crypto_one_time/4 or crypto:crypto_init/3 + crypto:cry" "pto_update/2 + crypto:crypto_final/1 instead","OTP 24"};
obsolete(crypto,block_decrypt,4) ->
    {deprecated,"use crypto:crypto_one_time/5, crypto:crypto_one_time_aead/6,7 or " "crypto:crypto_(dyn_iv)?_init + crypto:crypto_(dyn_iv)?_update + c" "rypto:crypto_final instead","OTP 24"};
obsolete(crypto,block_encrypt,3) ->
    {deprecated,"use crypto:crypto_one_time/4 or crypto:crypto_init/3 + crypto:cry" "pto_update/2 + crypto:crypto_final/1 instead","OTP 24"};
obsolete(crypto,block_encrypt,4) ->
    {deprecated,"use crypto:crypto_one_time/5, crypto:crypto_one_time_aead/6,7 or " "crypto:crypto_(dyn_iv)?_init + crypto:crypto_(dyn_iv)?_update + c" "rypto:crypto_final instead","OTP 24"};
obsolete(crypto,cmac,3) ->
    {deprecated,"use crypto:mac/4 instead","OTP 24"};
obsolete(crypto,cmac,4) ->
    {deprecated,"use crypto:macN/5 instead","OTP 24"};
obsolete(crypto,hmac,3) ->
    {deprecated,"use crypto:mac/4 instead","OTP 24"};
obsolete(crypto,hmac,4) ->
    {deprecated,"use crypto:macN/5 instead","OTP 24"};
obsolete(crypto,hmac_final,1) ->
    {deprecated,"use crypto:mac_final/1 instead","OTP 24"};
obsolete(crypto,hmac_final_n,2) ->
    {deprecated,"use crypto:mac_finalN/2 instead","OTP 24"};
obsolete(crypto,hmac_init,2) ->
    {deprecated,"use crypto:mac_init/3 instead","OTP 24"};
obsolete(crypto,hmac_update,2) ->
    {deprecated,"use crypto:mac_update/2 instead","OTP 24"};
obsolete(crypto,poly1305,2) ->
    {deprecated,"use crypto:mac/3 instead","OTP 24"};
obsolete(crypto,rand_uniform,2) ->
    {deprecated,"use rand:uniform/1 instead"};
obsolete(crypto,stream_decrypt,2) ->
    {deprecated,"use crypto:crypto_update/2 instead","OTP 24"};
obsolete(crypto,stream_encrypt,2) ->
    {deprecated,"use crypto:crypto_update/2 instead","OTP 24"};
obsolete(erl_tidy,dir,0) ->
    {deprecated,"use https://github.com/richcarl/erl_tidy","OTP 24"};
obsolete(erl_tidy,dir,1) ->
    {deprecated,"use https://github.com/richcarl/erl_tidy","OTP 24"};
obsolete(erl_tidy,file,1) ->
    {deprecated,"use https://github.com/richcarl/erl_tidy","OTP 24"};
obsolete(erl_tidy,module,1) ->
    {deprecated,"use https://github.com/richcarl/erl_tidy","OTP 24"};
obsolete(erl_tidy,module,2) ->
    {deprecated,"use https://github.com/richcarl/erl_tidy","OTP 24"};
obsolete(erlang,get_stacktrace,0) ->
    {deprecated,"use the new try/catch syntax for retrieving the stack backtrace","OTP 24"};
obsolete(erlang,now,0) ->
    {deprecated,"see the \"Time and Time Correction in Erlang\" chapter of the ERT" "S User's Guide for more information"};
obsolete(filename,safe_relative_path,1) ->
    {deprecated,"use filelib:safe_relative_path/2 instead","OTP 25"};
obsolete(http_uri,decode,1) ->
    {deprecated,"use uri_string functions instead","OTP 25"};
obsolete(http_uri,encode,1) ->
    {deprecated,"use uri_string functions instead","OTP 25"};
obsolete(http_uri,parse,1) ->
    {deprecated,"use uri_string functions instead","OTP 25"};
obsolete(http_uri,parse,2) ->
    {deprecated,"use uri_string functions instead","OTP 25"};
obsolete(http_uri,scheme_defaults,0) ->
    {deprecated,"use uri_string functions instead","OTP 25"};
obsolete(httpd,parse_query,1) ->
    {deprecated,"use uri_string:dissect_query/1 instead"};
obsolete(megaco,format_versions,1) ->
    {deprecated,"use megaco:print_version_info/0,1 instead.","OTP 24"};
obsolete(net,broadcast,3) ->
    {deprecated,"use rpc:eval_everywhere/3 instead"};
obsolete(net,call,4) ->
    {deprecated,"use rpc:call/4 instead"};
obsolete(net,cast,4) ->
    {deprecated,"use rpc:cast/4 instead"};
obsolete(net,ping,1) ->
    {deprecated,"use net_adm:ping/1 instead"};
obsolete(net,relay,1) ->
    {deprecated,"use slave:relay/1 instead"};
obsolete(net,sleep,1) ->
    {deprecated,"use 'receive after T -> ok end' instead"};
obsolete(queue,lait,1) ->
    {deprecated,"use queue:liat/1 instead"};
obsolete(snmp,add_agent_caps,2) ->
    {deprecated,"use snmpa:add_agent_caps/2 instead.","OTP 24"};
obsolete(snmp,c,1) ->
    {deprecated,"use snmpc:compile/1 instead.","OTP 24"};
obsolete(snmp,c,2) ->
    {deprecated,"use snmpc:compile/2 instead.","OTP 24"};
obsolete(snmp,change_log_size,1) ->
    {deprecated,"use snmpa:change_log_size/1 instead.","OTP 24"};
obsolete(snmp,compile,3) ->
    {deprecated,"use snmpc:compile/3 instead.","OTP 24"};
obsolete(snmp,current_address,0) ->
    {deprecated,"use snmpa:current_address/0 instead.","OTP 24"};
obsolete(snmp,current_community,0) ->
    {deprecated,"use snmpa:current_community/0 instead.","OTP 24"};
obsolete(snmp,current_context,0) ->
    {deprecated,"use snmpa:current_context/0 instead.","OTP 24"};
obsolete(snmp,current_net_if_data,0) ->
    {deprecated,"use snmpa:current_net_if_data/0 instead.","OTP 24"};
obsolete(snmp,current_request_id,0) ->
    {deprecated,"use snmpa:current_request_id/0 instead.","OTP 24"};
obsolete(snmp,del_agent_caps,1) ->
    {deprecated,"use snmpa:del_agent_caps/1 instead.","OTP 24"};
obsolete(snmp,dump_mibs,0) ->
    {deprecated,"use snmpa:dump_mibs/0 instead.","OTP 24"};
obsolete(snmp,dump_mibs,1) ->
    {deprecated,"use snmpa:dump_mibs/1 instead.","OTP 24"};
obsolete(snmp,enum_to_int,2) ->
    {deprecated,"use snmpa:enum_to_int/2 instead.","OTP 24"};
obsolete(snmp,enum_to_int,3) ->
    {deprecated,"use snmpa:enum_to_int/3 instead.","OTP 24"};
obsolete(snmp,get,2) ->
    {deprecated,"use snmpa:get/2 instead.","OTP 24"};
obsolete(snmp,get_agent_caps,0) ->
    {deprecated,"use snmpa:get_agent_caps/0 instead.","OTP 24"};
obsolete(snmp,get_symbolic_store_db,0) ->
    {deprecated,"use snmpa:get_symbolic_store_db/0 instead.","OTP 24"};
obsolete(snmp,info,1) ->
    {deprecated,"use snmpa:info/1 instead.","OTP 24"};
obsolete(snmp,int_to_enum,2) ->
    {deprecated,"use snmpa:int_to_enum/2 instead.","OTP 24"};
obsolete(snmp,int_to_enum,3) ->
    {deprecated,"use snmpa:int_to_enum/3 instead.","OTP 24"};
obsolete(snmp,is_consistent,1) ->
    {deprecated,"use snmpc:is_consistent/1 instead.","OTP 24"};
obsolete(snmp,load_mibs,2) ->
    {deprecated,"use snmpa:load_mibs/2 instead.","OTP 24"};
obsolete(snmp,log_to_txt,2) ->
    {deprecated,"use snmpa:log_to_txt/2 instead.","OTP 24"};
obsolete(snmp,log_to_txt,3) ->
    {deprecated,"use snmpa:log_to_txt/3 instead.","OTP 24"};
obsolete(snmp,log_to_txt,4) ->
    {deprecated,"use snmpa:log_to_txt/4 instead.","OTP 24"};
obsolete(snmp,mib_to_hrl,1) ->
    {deprecated,"use snmpc:mib_to_hrl/1 instead.","OTP 24"};
obsolete(snmp,name_to_oid,1) ->
    {deprecated,"use snmpa:name_to_oid/1 instead.","OTP 24"};
obsolete(snmp,name_to_oid,2) ->
    {deprecated,"use snmpa:name_to_oid/2 instead.","OTP 24"};
obsolete(snmp,oid_to_name,1) ->
    {deprecated,"use snmpa:oid_to_name/1 instead.","OTP 24"};
obsolete(snmp,oid_to_name,2) ->
    {deprecated,"use snmpa:oid_to_name/2 instead.","OTP 24"};
obsolete(snmp,register_subagent,3) ->
    {deprecated,"use snmpa:register_subagent/3 instead.","OTP 24"};
obsolete(snmp,send_notification,3) ->
    {deprecated,"use snmpa:send_notification/3 instead.","OTP 24"};
obsolete(snmp,send_notification,4) ->
    {deprecated,"use snmpa:send_notification/4 instead.","OTP 24"};
obsolete(snmp,send_notification,5) ->
    {deprecated,"use snmpa:send_notification/5 instead.","OTP 24"};
obsolete(snmp,send_notification,6) ->
    {deprecated,"use snmpa:send_notification/6 instead.","OTP 24"};
obsolete(snmp,send_trap,3) ->
    {deprecated,"use snmpa:send_trap/3 instead.","OTP 24"};
obsolete(snmp,send_trap,4) ->
    {deprecated,"use snmpa:send_trap/4 instead.","OTP 24"};
obsolete(snmp,unload_mibs,2) ->
    {deprecated,"use snmpa:unload_mibs/2 instead.","OTP 24"};
obsolete(snmp,unregister_subagent,2) ->
    {deprecated,"use snmpa:unregister_subagent/2 instead.","OTP 24"};
obsolete(snmpa,old_info_format,1) ->
    {deprecated,"use \"new\" format instead","OTP 24"};
obsolete(snmpm,async_get,3) ->
    {deprecated,"use snmpm:async_get2/3 instead.","OTP 25"};
obsolete(snmpm,async_get,4) ->
    {deprecated,"use snmpm:async_get2/4 instead.","OTP 25"};
obsolete(snmpm,async_get,5) ->
    {deprecated,"use snmpm:async_get2/4 instead.","OTP 25"};
obsolete(snmpm,async_get,6) ->
    {deprecated,"use snmpm:async_get2/4 instead.","OTP 25"};
obsolete(snmpm,async_get_bulk,5) ->
    {deprecated,"use snmpm:async_get_bulk2/5 instead.","OTP 25"};
obsolete(snmpm,async_get_bulk,6) ->
    {deprecated,"use snmpm:async_get_bulk2/6 instead.","OTP 25"};
obsolete(snmpm,async_get_bulk,7) ->
    {deprecated,"use snmpm:async_get_bulk2/6 instead.","OTP 25"};
obsolete(snmpm,async_get_bulk,8) ->
    {deprecated,"use snmpm:async_get_bulk2/6 instead.","OTP 25"};
obsolete(snmpm,async_get_next,3) ->
    {deprecated,"use snmpm:async_get_next2/3 instead.","OTP 25"};
obsolete(snmpm,async_get_next,4) ->
    {deprecated,"use snmpm:async_get_next2/4 instead.","OTP 25"};
obsolete(snmpm,async_get_next,5) ->
    {deprecated,"use snmpm:async_get_next2/4 instead.","OTP 25"};
obsolete(snmpm,async_get_next,6) ->
    {deprecated,"use snmpm:async_get_next2/4 instead.","OTP 25"};
obsolete(snmpm,async_set,3) ->
    {deprecated,"use snmpm:async_set2/3 instead.","OTP 25"};
obsolete(snmpm,async_set,4) ->
    {deprecated,"use snmpm:async_set2/4 instead.","OTP 25"};
obsolete(snmpm,async_set,5) ->
    {deprecated,"use snmpm:async_set2/4 instead.","OTP 25"};
obsolete(snmpm,async_set,6) ->
    {deprecated,"use snmpm:async_set2/4 instead.","OTP 25"};
obsolete(snmpm,sync_get,3) ->
    {deprecated,"use snmpm:sync_get2/3 instead.","OTP 25"};
obsolete(snmpm,sync_get,4) ->
    {deprecated,"use snmpm:sync_get2/4 instead.","OTP 25"};
obsolete(snmpm,sync_get,5) ->
    {deprecated,"use snmpm:sync_get2/4 instead.","OTP 25"};
obsolete(snmpm,sync_get,6) ->
    {deprecated,"use snmpm:sync_get2/4 instead.","OTP 25"};
obsolete(snmpm,sync_get_bulk,5) ->
    {deprecated,"use snmpm:sync_get_bulk2/5 instead.","OTP 25"};
obsolete(snmpm,sync_get_bulk,6) ->
    {deprecated,"use snmpm:sync_get_bulk2/6 instead.","OTP 25"};
obsolete(snmpm,sync_get_bulk,7) ->
    {deprecated,"use snmpm:sync_get_bulk2/6 instead.","OTP 25"};
obsolete(snmpm,sync_get_bulk,8) ->
    {deprecated,"use snmpm:sync_get_bulk2/6 instead.","OTP 25"};
obsolete(snmpm,sync_get_next,3) ->
    {deprecated,"use snmpm:sync_get_next2/3 instead.","OTP 25"};
obsolete(snmpm,sync_get_next,4) ->
    {deprecated,"use snmpm:sync_get_next2/4 instead.","OTP 25"};
obsolete(snmpm,sync_get_next,5) ->
    {deprecated,"use snmpm:sync_get_next2/4 instead.","OTP 25"};
obsolete(snmpm,sync_get_next,6) ->
    {deprecated,"use snmpm:sync_get_next2/4 instead.","OTP 25"};
obsolete(snmpm,sync_set,3) ->
    {deprecated,"use snmpm:sync_set2/3 instead.","OTP 25"};
obsolete(snmpm,sync_set,4) ->
    {deprecated,"use snmpm:sync_set2/4 instead.","OTP 25"};
obsolete(snmpm,sync_set,5) ->
    {deprecated,"use snmpm:sync_set2/4 instead.","OTP 25"};
obsolete(snmpm,sync_set,6) ->
    {deprecated,"use snmpm:sync_set2/4 instead.","OTP 25"};
obsolete(ssl,cipher_suites,0) ->
    {deprecated,"use cipher_suites/2,3 instead","OTP 24"};
obsolete(ssl,cipher_suites,1) ->
    {deprecated,"use cipher_suites/2,3 instead","OTP 24"};
obsolete(sys,get_debug,3) ->
    {deprecated,"incorrectly documented and only for internal use. Can often be re" "placed with sys:get_log/1"};
obsolete(wxCalendarCtrl,enableYearChange,1) ->
    {deprecated,"not available in wxWidgets-2.9 and later"};
obsolete(wxCalendarCtrl,enableYearChange,2) ->
    {deprecated,"not available in wxWidgets-2.9 and later"};
obsolete(wxClientDC,new,0) ->
    {deprecated,"not available in wxWidgets-2.9 and later"};
obsolete(wxCursor,new,3) ->
    {deprecated,"not available in wxWidgets-2.9 and later"};
obsolete(wxCursor,new,4) ->
    {deprecated,"not available in wxWidgets-2.9 and later"};
obsolete(wxDC,computeScaleAndOrigin,1) ->
    {deprecated,"not available in wxWidgets-2.9 and later"};
obsolete(wxGraphicsRenderer,createLinearGradientBrush,7) ->
    {deprecated,"not available in wxWidgets-2.9 and later"};
obsolete(wxGraphicsRenderer,createRadialGradientBrush,8) ->
    {deprecated,"not available in wxWidgets-2.9 and later"};
obsolete(wxGridCellEditor,endEdit,4) ->
    {deprecated,"not available in wxWidgets-2.9 and later"};
obsolete(wxGridCellEditor,paintBackground,3) ->
    {deprecated,"not available in wxWidgets-2.9 and later"};
obsolete(wxIdleEvent,canSend,1) ->
    {deprecated,"not available in wxWidgets-2.9 and later"};
obsolete(wxMDIClientWindow,new,1) ->
    {deprecated,"not available in wxWidgets-2.9 and later"};
obsolete(wxMDIClientWindow,new,2) ->
    {deprecated,"not available in wxWidgets-2.9 and later"};
obsolete(wxPaintDC,new,0) ->
    {deprecated,"not available in wxWidgets-2.9 and later"};
obsolete(wxPostScriptDC,getResolution,0) ->
    {deprecated,"not available in wxWidgets-2.9 and later"};
obsolete(wxPostScriptDC,setResolution,1) ->
    {deprecated,"not available in wxWidgets-2.9 and later"};
obsolete(wxWindowDC,new,0) ->
    {deprecated,"not available in wxWidgets-2.9 and later"};
obsolete(core_lib,get_anno,1) ->
    {removed,"use cerl:get_ann/1 instead"};
obsolete(core_lib,is_literal,1) ->
    {removed,"use cerl:is_literal/1 instead"};
obsolete(core_lib,is_literal_list,1) ->
    {removed,"use cerl:is_literal_list/1 instead"};
obsolete(core_lib,literal_value,1) ->
    {removed,"use cerl:concrete/1 instead"};
obsolete(core_lib,set_anno,2) ->
    {removed,"use cerl:set_ann/2 instead"};
obsolete(crypto,aes_cbc_128_decrypt,3) ->
    {removed,"use crypto:block_decrypt/4 instead"};
obsolete(crypto,aes_cbc_128_encrypt,3) ->
    {removed,"use crypto:block_encrypt/4 instead"};
obsolete(crypto,aes_cbc_256_decrypt,3) ->
    {removed,"use crypto:block_decrypt/4 instead"};
obsolete(crypto,aes_cbc_256_encrypt,3) ->
    {removed,"use crypto:block_encrypt/4 instead"};
obsolete(crypto,aes_cbc_ivec,2) ->
    {removed,"use crypto:next_iv/2 instead"};
obsolete(crypto,aes_cfb_128_decrypt,3) ->
    {removed,"use crypto:block_decrypt/4 instead"};
obsolete(crypto,aes_cfb_128_encrypt,3) ->
    {removed,"use crypto:block_encrypt/4 instead"};
obsolete(crypto,aes_ctr_decrypt,3) ->
    {removed,"use crypto:stream_decrypt/2 instead"};
obsolete(crypto,aes_ctr_encrypt,3) ->
    {removed,"use crypto:stream_encrypt/2 instead"};
obsolete(crypto,aes_ctr_stream_decrypt,2) ->
    {removed,"use crypto:stream_decrypt/2 instead"};
obsolete(crypto,aes_ctr_stream_encrypt,2) ->
    {removed,"use crypto:stream_encrypt/2 instead"};
obsolete(crypto,aes_ctr_stream_init,2) ->
    {removed,"use crypto:stream_init/3 instead"};
obsolete(crypto,blowfish_cbc_decrypt,3) ->
    {removed,"use crypto:block_decrypt/4 instead"};
obsolete(crypto,blowfish_cbc_encrypt,3) ->
    {removed,"use crypto:block_encrypt/4 instead"};
obsolete(crypto,blowfish_cfb64_decrypt,3) ->
    {removed,"use crypto:block_decrypt/4 instead"};
obsolete(crypto,blowfish_cfb64_encrypt,3) ->
    {removed,"use crypto:block_encrypt/4 instead"};
obsolete(crypto,blowfish_ecb_decrypt,2) ->
    {removed,"use crypto:block_decrypt/3 instead"};
obsolete(crypto,blowfish_ecb_encrypt,2) ->
    {removed,"use crypto:block_encrypt/3 instead"};
obsolete(crypto,blowfish_ofb64_decrypt,3) ->
    {removed,"use crypto:block_decrypt/4 instead"};
obsolete(crypto,blowfish_ofb64_encrypt,3) ->
    {removed,"use crypto:block_encrypt/4 instead"};
obsolete(crypto,des3_cbc_decrypt,5) ->
    {removed,"use crypto:block_decrypt/4 instead"};
obsolete(crypto,des3_cbc_encrypt,5) ->
    {removed,"use crypto:block_encrypt/4 instead"};
obsolete(crypto,des3_cfb_decrypt,5) ->
    {removed,"use crypto:block_decrypt/4 instead"};
obsolete(crypto,des3_cfb_encrypt,5) ->
    {removed,"use crypto:block_encrypt/4 instead"};
obsolete(crypto,des3_ede3_cbc_decrypt,5) ->
    {removed,"use crypto:block_decrypt/4 instead"};
obsolete(crypto,des_cbc_decrypt,3) ->
    {removed,"use crypto:block_decrypt/4 instead"};
obsolete(crypto,des_cbc_encrypt,3) ->
    {removed,"use crypto:block_encrypt/4 instead"};
obsolete(crypto,des_cbc_ivec,2) ->
    {removed,"use crypto:next_iv/2 instead"};
obsolete(crypto,des_cfb_decrypt,3) ->
    {removed,"use crypto:block_decrypt/4 instead"};
obsolete(crypto,des_cfb_encrypt,3) ->
    {removed,"use crypto:block_encrypt/4 instead"};
obsolete(crypto,des_cfb_ivec,2) ->
    {removed,"use crypto:next_iv/3 instead"};
obsolete(crypto,des_ecb_decrypt,2) ->
    {removed,"use crypto:block_decrypt/3 instead"};
obsolete(crypto,des_ecb_encrypt,2) ->
    {removed,"use crypto:block_encrypt/3 instead"};
obsolete(crypto,des_ede3_cbc_encrypt,5) ->
    {removed,"use crypto:block_encrypt/4 instead"};
obsolete(crypto,dh_compute_key,3) ->
    {removed,"use crypto:compute_key/4 instead"};
obsolete(crypto,dh_generate_key,1) ->
    {removed,"use crypto:generate_key/2 instead"};
obsolete(crypto,dh_generate_key,2) ->
    {removed,"use crypto:generate_key/3 instead"};
obsolete(crypto,erlint,1) ->
    {removed,"only needed by other removed functions"};
obsolete(crypto,info,0) ->
    {removed,"use crypto:module_info/0 instead"};
obsolete(crypto,md4,1) ->
    {removed,"use crypto:hash/2 instead"};
obsolete(crypto,md4_final,1) ->
    {removed,"use crypto:hash_final/1 instead"};
obsolete(crypto,md4_init,0) ->
    {removed,"use crypto:hash_init/1 instead"};
obsolete(crypto,md4_update,2) ->
    {removed,"use crypto:hash_update/2 instead"};
obsolete(crypto,md5,1) ->
    {removed,"use crypto:hash/2 instead"};
obsolete(crypto,md5_final,1) ->
    {removed,"use crypto:hash_final/1 instead"};
obsolete(crypto,md5_init,0) ->
    {removed,"use crypto:hash_init/1 instead"};
obsolete(crypto,md5_mac,2) ->
    {removed,"use crypto:hmac/3 instead"};
obsolete(crypto,md5_mac_96,2) ->
    {removed,"use crypto:hmac/4 instead"};
obsolete(crypto,md5_update,2) ->
    {removed,"use crypto:hash_update/2 instead"};
obsolete(crypto,mod_exp,3) ->
    {removed,"use crypto:mod_pow/3 instead"};
obsolete(crypto,mpint,1) ->
    {removed,"only needed by other removed functions"};
obsolete(crypto,rand_bytes,1) ->
    {removed,"use crypto:strong_rand_bytes/1 instead"};
obsolete(crypto,rc2_40_cbc_decrypt,3) ->
    {removed,"use crypto:block_decrypt/4 instead"};
obsolete(crypto,rc2_40_cbc_encrypt,3) ->
    {removed,"use crypto:block_encrypt/4 instead"};
obsolete(crypto,rc2_cbc_decrypt,3) ->
    {removed,"use crypto:block_decrypt/4 instead"};
obsolete(crypto,rc2_cbc_encrypt,3) ->
    {removed,"use crypto:block_encrypt/4 instead"};
obsolete(crypto,rc4_encrypt,2) ->
    {removed,"use crypto:stream_encrypt/2 instead"};
obsolete(crypto,rc4_encrypt_with_state,2) ->
    {removed,"use crypto:stream_encrypt/2 instead"};
obsolete(crypto,rc4_set_key,2) ->
    {removed,"use crypto:stream_init/2 instead"};
obsolete(crypto,sha,1) ->
    {removed,"use crypto:hash/2 instead"};
obsolete(crypto,sha_final,1) ->
    {removed,"use crypto:hash_final/1 instead"};
obsolete(crypto,sha_init,0) ->
    {removed,"use crypto:hash_init/1 instead"};
obsolete(crypto,sha_mac,2) ->
    {removed,"use crypto:hmac/3 instead"};
obsolete(crypto,sha_mac,3) ->
    {removed,"use crypto:hmac/4 instead"};
obsolete(crypto,sha_mac_96,2) ->
    {removed,"use crypto:hmac/4 instead"};
obsolete(crypto,sha_update,2) ->
    {removed,"use crypto:hash_update/2 instead"};
obsolete(crypto,strong_rand_mpint,3) ->
    {removed,"only needed by other removed functions"};
obsolete(erl_lint,modify_line,2) ->
    {removed,"use erl_parse:map_anno/2 instead"};
obsolete(erl_parse,get_attribute,2) ->
    {removed,"erl_anno:{column,line,location,text}/1 instead"};
obsolete(erl_parse,get_attributes,1) ->
    {removed,"erl_anno:{column,line,location,text}/1 instead"};
obsolete(erl_parse,set_line,2) ->
    {removed,"use erl_anno:set_line/2"};
obsolete(erl_scan,set_attribute,3) ->
    {removed,"use erl_anno:set_line/2 instead"};
obsolete(erlang,hash,2) ->
    {removed,"use erlang:phash2/2 instead"};
obsolete(httpd_conf,check_enum,2) ->
    {removed,"use lists:member/2 instead"};
obsolete(httpd_conf,clean,1) ->
    {removed,"use sting:strip/1 instead or possibly the re module"};
obsolete(httpd_conf,custom_clean,3) ->
    {removed,"use sting:strip/1 instead or possibly the re module"};
obsolete(httpd_conf,is_directory,1) ->
    {removed,"use filelib:is_dir/1 instead"};
obsolete(httpd_conf,is_file,1) ->
    {removed,"use filelib:is_file/1 instead"};
obsolete(httpd_conf,make_integer,1) ->
    {removed,"use erlang:list_to_integer/1 instead"};
obsolete(rpc,safe_multi_server_call,2) ->
    {removed,"use rpc:multi_server_call/2 instead"};
obsolete(rpc,safe_multi_server_call,3) ->
    {removed,"use rpc:multi_server_call/3 instead"};
obsolete(ssl,connection_info,1) ->
    {removed,"use ssl:connection_information/[1,2] instead"};
obsolete(ssl,negotiated_next_protocol,1) ->
    {removed,"use ssl:negotiated_protocol/1 instead"};
obsolete(auth,node_cookie,_) ->
    {deprecated,"use erlang:set_cookie/2 and net_adm:ping/1 instead"};
obsolete(crypto,next_iv,_) ->
    {deprecated,"see the 'New and Old API' chapter of the CRYPTO User's guide","OTP 24"};
obsolete(crypto,stream_init,_) ->
    {deprecated,"use crypto:crypto_init/3 + crypto:crypto_update/2 + crypto:crypto" "_final/1 or crypto:crypto_one_time/4 instead","OTP 24"};
obsolete(filename,find_src,_) ->
    {deprecated,"use filelib:find_source/1,3 instead","OTP 24"};
obsolete(ssl,ssl_accept,_) ->
    {deprecated,"use ssl_handshake/1,2,3 instead","OTP 24"};
obsolete(asn1ct,decode,_) ->
    {removed,"use Mod:decode/2 instead"};
obsolete(asn1ct,encode,_) ->
    {removed,"use Mod:encode/2 instead"};
obsolete(crypto,dss_sign,_) ->
    {removed,"use crypto:sign/4 instead"};
obsolete(crypto,dss_verify,_) ->
    {removed,"use crypto:verify/5 instead"};
obsolete(crypto,rsa_sign,_) ->
    {removed,"use crypto:sign/4 instead"};
obsolete(crypto,rsa_verify,_) ->
    {removed,"use crypto:verify/5 instead"};
obsolete(erl_scan,attributes_info,_) ->
    {removed,"erl_anno:{column,line,location,text}/1 instead"};
obsolete(erl_scan,token_info,_) ->
    {removed,"erl_scan:{category,column,line,location,symbol,text}/1 instead"};
obsolete(gen_fsm,_,_) ->
    {deprecated,"use the 'gen_statem' module instead"};
obsolete(igor,_,_) ->
    {deprecated,"use https://github.com/richcarl/igor","OTP 24"};
obsolete(pg2,_,_) ->
    {deprecated,"use 'pg' instead","OTP 24"};
obsolete(random,_,_) ->
    {deprecated,"use the 'rand' module instead"};
obsolete(os_mon_mib,_,_) ->
    {removed,"this module was removed in OTP 22.0"};
obsolete(_,_,_) ->
    no.

-dialyzer({no_match,{obsolete_type,3}}).

obsolete_type(crypto,retired_cbc_cipher_aliases,0) ->
    {deprecated,"Use aes_*_cbc or des_ede3_cbc"};
obsolete_type(crypto,retired_cfb_cipher_aliases,0) ->
    {deprecated,"Use aes_*_cfb8, aes_*_cfb128 or des_ede3_cfb"};
obsolete_type(crypto,retired_ctr_cipher_aliases,0) ->
    {deprecated,"Use aes_*_ctr"};
obsolete_type(crypto,retired_ecb_cipher_aliases,0) ->
    {deprecated,"Use aes_*_ecb"};
obsolete_type(erl_scan,column,0) ->
    {removed,"use erl_anno:column() instead"};
obsolete_type(erl_scan,line,0) ->
    {removed,"use erl_anno:line() instead"};
obsolete_type(erl_scan,location,0) ->
    {removed,"use erl_anno:location() instead"};
obsolete_type(_,_,_) ->
    no.
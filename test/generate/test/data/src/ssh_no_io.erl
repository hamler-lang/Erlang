-file("ssh_no_io.erl", 1).

-module(ssh_no_io).

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

-file("ssh_no_io.erl", 27).

-export([yes_no/2, read_password/2, read_line/2, format/2]).

-spec(yes_no(any(),any()) -> no_return()).

yes_no(_,_) ->
    ssh_connection_handler:disconnect(7,"User interaction is not allowed",ssh_no_io,35).

-spec(read_password(any(),any()) -> no_return()).

read_password(_,_) ->
    ssh_connection_handler:disconnect(7,"User interaction is not allowed",ssh_no_io,42).

-spec(read_line(any(),any()) -> no_return()).

read_line(_,_) ->
    ssh_connection_handler:disconnect(7,"User interaction is not allowed",ssh_no_io,48).

-spec(format(any(),any()) -> no_return()).

format(_,_) ->
    ssh_connection_handler:disconnect(7,"User interaction is not allowed",ssh_no_io,54).
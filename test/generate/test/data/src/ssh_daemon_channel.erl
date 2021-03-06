-file("ssh_daemon_channel.erl", 1).

-module(ssh_daemon_channel).

-callback(init(Args::term()) -> {ok,State::term()}|{ok,State::term(),timeout()|hibernate}|{stop,Reason::term()}|ignore).

-callback(terminate(Reason::normal|shutdown|{shutdown,term()}|term(),State::term()) -> term()).

-callback(handle_msg(Msg::term(),State::term()) -> {ok,State::term()}|{stop,ChannelId::ssh:channel_id(),State::term()}).

-callback(handle_ssh_msg({ssh_cm,ConnectionRef::ssh:connection_ref(),SshMsg::term()},State::term()) -> {ok,State::term()}|{stop,ChannelId::ssh:channel_id(),State::term()}).

-export([start_link/5, get_print_info/1]).

start_link(ConnectionManager,ChannelId,CallBack,CbInitArgs,Exec) ->
    ssh_server_channel:start_link(ConnectionManager,ChannelId,CallBack,CbInitArgs,Exec).

get_print_info(Pid) ->
    ssh_server_channel:get_print_info(Pid).
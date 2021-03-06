-file("ssh_connection_sup.erl", 1).

-module(ssh_connection_sup).

-behaviour(supervisor).

-export([start_link/1]).

-export([start_child/2]).

-export([init/1]).

start_link(Args) ->
    supervisor:start_link(ssh_connection_sup,[Args]).

start_child(Sup,Args) ->
    supervisor:start_child(Sup,Args).

init(_) ->
    SupFlags = #{strategy=>simple_one_for_one,intensity=>0,period=>3600},
    ChildSpecs = [#{id=>undefined,start=>{ssh_connection_handler,start_link,[]},restart=>temporary}],
    {ok,{SupFlags,ChildSpecs}}.
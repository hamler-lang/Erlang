-file("ssh_app.erl", 1).

-module(ssh_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_Type,_State) ->
    supervisor:start_link({local,ssh_sup},ssh_sup,[]).

stop(_State) ->
    ok.
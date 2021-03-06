-file("ssh_sup.erl", 1).

-module(ssh_sup).

-behaviour(supervisor).

-export([init/1]).

init(_) ->
    SupFlags = #{strategy=>one_for_one,intensity=>10,period=>3600},
    ChildSpecs = [#{id=>sshd_sup,start=>{sshd_sup,start_link,[]},type=>supervisor}, #{id=>sshc_sup,start=>{sshc_sup,start_link,[]},type=>supervisor}],
    {ok,{SupFlags,ChildSpecs}}.
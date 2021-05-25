-file("asn1ct_name.erl", 1).

-module(asn1ct_name).

-export([start/0, curr/1, clear/0, prev/1, next/1, all/1, new/1]).

start() ->
    Parent = self(),
    case get(asn1ct_name) of
        undefined->
            put(asn1ct_name,spawn_link(fun ()->
                Ref = monitor(process,Parent),
                name_server_loop({Ref,Parent},[]) end)),
            ok;
        _Pid->
            clear()
    end.

name_server_loop({Ref,Parent} = Monitor,Vars) ->
    receive {_From,clear}->
        name_server_loop(Monitor,[]);
    {From,{current,Variable}}->
        From ! {asn1ct_name,get_curr(Vars,Variable)},
        name_server_loop(Monitor,Vars);
    {_From,{new,Variable}}->
        name_server_loop(Monitor,new_var(Vars,Variable));
    {From,{prev,Variable}}->
        From ! {asn1ct_name,get_prev(Vars,Variable)},
        name_server_loop(Monitor,Vars);
    {From,{next,Variable}}->
        From ! {asn1ct_name,get_next(Vars,Variable)},
        name_server_loop(Monitor,Vars);
    {'DOWN',Ref,process,Parent,Reason}->
        exit(Reason) end.

req(Req) ->
    Pid = get(asn1ct_name),
    Ref = monitor(process,Pid),
    Pid ! {self(),Req},
    receive {asn1ct_name,Reply}->
        Reply;
    {'DOWN',Ref,process,Pid,Reason}->
        error({name_server_died,Reason}) end.

cast(Req) ->
    get(asn1ct_name) ! {self(),Req},
    ok.

clear() ->
    cast(clear).

curr(V) ->
    req({current,V}).

new(V) ->
    cast({new,V}).

prev(V) ->
    case req({prev,V}) of
        none->
            exit(cant get prev of none);
        Rep->
            Rep
    end.

next(V) ->
    req({next,V}).

all(V) ->
    Curr = curr(V),
    if Curr == V ->
        [];true ->
        lists:reverse(generate(V,last(Curr),[],0)) end.

generate(V,Number,Res,Pos) ->
    Ell = Pos + 1,
    if Ell > Number ->
        Res;true ->
        generate(V,Number,[list_to_atom(lists:concat([V, Ell]))| Res],Ell) end.

last(V) ->
    last2(lists:reverse(atom_to_list(V))).

last2(RevL) ->
    list_to_integer(lists:reverse(get_digs(RevL))).

get_digs([H| T]) ->
    if H < $9 + 1,
    H > $0 - 1 ->
        [H| get_digs(T)];true ->
        [] end.

get_curr([],Variable) ->
    Variable;
get_curr([{Variable,Digit}| _Tail],Variable) ->
    list_to_atom(lists:concat([Variable, Digit]));
get_curr([_| Tail],Variable) ->
    get_curr(Tail,Variable).

new_var(Vars,Variable) ->
    case lists:keyfind(Variable,1,Vars) of
        false->
            [{Variable,1}| Vars];
        {Variable,Digit}->
            NewVars = lists:keydelete(Variable,1,Vars),
            [{Variable,Digit + 1}| NewVars]
    end.

get_prev(Vars,Variable) ->
    case lists:keyfind(Variable,1,Vars) of
        false->
            none;
        {Variable,Digit}
            when Digit =< 1->
            Variable;
        {Variable,Digit}
            when Digit > 1->
            list_to_atom(lists:concat([Variable, Digit - 1]))
    end.

get_next(Vars,Variable) ->
    case lists:keyfind(Variable,1,Vars) of
        false->
            list_to_atom(lists:concat([Variable, "1"]));
        {Variable,Digit}
            when Digit >= 0->
            list_to_atom(lists:concat([Variable, Digit + 1]))
    end.
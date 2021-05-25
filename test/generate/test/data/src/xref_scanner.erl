-file("xref_scanner.erl", 1).

-module(xref_scanner).

-file("xref.hrl", 1).

-record(xref, {version = 1,mode = functions,variables = not_set_up,modules = dict:new(),applications = dict:new(),releases = dict:new(),library_path = [],libraries = dict:new(),builtins_default = false,recurse_default = false,verbose_default = false,warnings_default = true}).

-record(xref_mod, {name = ,app_name = [],dir = "",mtime,builtins,info,no_unresolved = 0,data}).

-record(xref_app, {name = ,rel_name = [],vsn = [],dir = ""}).

-record(xref_rel, {name = ,dir = ""}).

-record(xref_lib, {name = ,dir = ""}).

-record(xref_var, {name = ,value,vtype,otype,type}).

-file("xref_scanner.erl", 24).

-export([scan/1]).

scan(Chars) ->
    case erl_scan:string(Chars) of
        {ok,Tokens,_Line}->
            {ok,lex(a1(Tokens))};
        {error,{Line,Module,Info},_EndLine}->
            {error,Module:format_error(Info),Line}
    end.

a1([{'-',N}, {integer,N,1}| L]) ->
    [{integer,N,-1}| a1(L)];
a1([T| L]) ->
    [T| a1(L)];
a1([]) ->
    [].

lex([{atom,N,V1}, {'->',_}, {atom,_,V2}| L]) ->
    Constant = {constant,unknown,edge,{V1,V2}},
    [{edge,N,Constant}| lex(L)];
lex([{'{',N}, {atom,_,V1}, {',',_}, {atom,_,V2}, {'}',_}| L]) ->
    Constant = {constant,unknown,edge,{V1,V2}},
    [{edge,N,Constant}| lex(L)];
lex([{atom,N,M}, {':',_}, {atom,_,F}, {'/',_}, {integer,_,A}, {'->',_}, {atom,_,M2}, {':',_}, {atom,_,F2}, {'/',_}, {integer,_,A2}| L]) ->
    Constant = {constant,'Fun',edge,{{M,F,A},{M2,F2,A2}}},
    [{edge,N,Constant}| lex(L)];
lex([{atom,N,M}, {':',_}, {atom,_,F}, {'/',_}, {integer,_,A}| L]) ->
    Constant = {constant,'Fun',vertex,{M,F,A}},
    [{vertex,N,Constant}| lex(L)];
lex([{'{',N}, {'{',_}, {atom,_,M}, {',',_}, {atom,_,F}, {',',_}, {integer,_,A}, {'}',_}, {',',_}, {'{',_}, {atom,_,M2}, {',',_}, {atom,_,F2}, {',',_}, {integer,_,A2}, {'}',_}, {'}',_}| L]) ->
    Constant = {constant,'Fun',edge,{{M,F,A},{M2,F2,A2}}},
    [{edge,N,Constant}| lex(L)];
lex([{'{',N}, {atom,_,M}, {',',_}, {atom,_,F}, {',',_}, {integer,_,A}, {'}',_}| L]) ->
    Constant = {constant,'Fun',vertex,{M,F,A}},
    [{vertex,N,Constant}| lex(L)];
lex([{':',N1}, {var,N2,Decl}| L]) ->
    case is_type(Decl) of
        false->
            [{':',N1}, {var,N2,Decl}| lex(L)];
        true->
            [{decl,N1,Decl}| lex(L)]
    end;
lex([{':',N}, {'=',_}| L]) ->
    [{':=',N}| lex(L)];
lex([{'||',N}, {'|',_}| L]) ->
    [{'|||',N}| lex(L)];
lex([V = {var,N,Var}| L]) ->
    T = case is_type(Var) of
        false->
            V;
        true->
            {cast,N,Var}
    end,
    [T| lex(L)];
lex([T| Ts]) ->
    [T| lex(Ts)];
lex([]) ->
    [{'$end',erl_anno:new(1 bsl 23)}].

is_type('Rel') ->
    true;
is_type('App') ->
    true;
is_type('Mod') ->
    true;
is_type('Fun') ->
    true;
is_type('Lin') ->
    true;
is_type('LLin') ->
    true;
is_type('XLin') ->
    true;
is_type('ELin') ->
    true;
is_type('XXL') ->
    true;
is_type(_) ->
    false.
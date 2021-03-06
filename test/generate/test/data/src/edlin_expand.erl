-file("edlin_expand.erl", 1).

-module(edlin_expand).

-export([expand/1, format_matches/1]).

-import(lists, [reverse/1, prefix/2]).

expand(Bef0) ->
    {Bef1,Word,_} = edlin:over_word(Bef0,[],0),
    case over_white(Bef1,[],0) of
        {[$,| Bef2],_White,_Nwh}->
            {Bef3,_White1,_Nwh1} = over_white(Bef2,[],0),
            {Bef4,Mod,_Nm} = edlin:over_word(Bef3,[],0),
            case expand_function(Bef4) of
                help->
                    expand_function_name(Mod,Word,",");
                _->
                    expand_module_name(Word,",")
            end;
        {[$:| Bef2],_White,_Nwh}->
            {Bef3,_White1,_Nwh1} = over_white(Bef2,[],0),
            {_,Mod,_Nm} = edlin:over_word(Bef3,[],0),
            expand_function_name(Mod,Word,"(");
        {_,_,_}->
            CompleteChar = case expand_function(Bef1) of
                help->
                    ",";
                _->
                    ":"
            end,
            expand_module_name(Word,CompleteChar)
    end.

expand_function("(" ++ Str) ->
    case edlin:over_word(Str,[],0) of
        {_,"h",_}->
            help;
        {_,"ht",_}->
            help_type;
        _->
            module
    end;
expand_function(_) ->
    module.

expand_module_name("",_) ->
    {no,[],[]};
expand_module_name(Prefix,CompleteChar) ->
    match(Prefix,[{list_to_atom(M),P} || {M,P,_} <- code:all_available()],CompleteChar).

expand_function_name(ModStr,FuncPrefix,CompleteChar) ->
    case to_atom(ModStr) of
        {ok,Mod}->
            Exports = case module_loaded(Mod) of
                true->
                    Mod:module_info(exports);
                false->
                    case beam_lib:chunks(code:which(Mod),[exports]) of
                        {ok,{Mod,[{exports,E}]}}->
                            E;
                        _->
                            {no,[],[]}
                    end
            end,
            case Exports of
                {no,[],[]}->
                    {no,[],[]};
                Exports->
                    match(FuncPrefix,Exports,CompleteChar)
            end;
        error->
            {no,[],[]}
    end.

to_atom(Str) ->
    case erl_scan:string(Str) of
        {ok,[{atom,_,A}],_}->
            {ok,A};
        _->
            error
    end.

match(Prefix,Alts,Extra0) ->
    Len = string:length(Prefix),
    Matches = lists:sort([{S,A} || {H,A} <- Alts,prefix(Prefix,S = flat_write(H))]),
    case longest_common_head([N || {N,_} <- Matches]) of
        {partial,[]}->
            {no,[],Matches};
        {partial,Str}->
            case string:slice(Str,Len) of
                []->
                    {yes,[],Matches};
                Remain->
                    {yes,Remain,[]}
            end;
        {complete,Str}->
            Extra = case {Extra0,Matches} of
                {"(",[{Str,0}]}->
                    "()";
                {_,_}->
                    Extra0
            end,
            {yes,string:slice(Str,Len) ++ Extra,[]};
        no->
            {no,[],[]}
    end.

flat_write(T)
    when is_atom(T)->
    lists:flatten(io_lib:fwrite("~tw",[T]));
flat_write(S) ->
    S.

format_matches(L) ->
    {S1,Dots} = format_col(lists:sort(L),[]),
    S = case Dots of
        true->
            {_,Prefix} = longest_common_head(vals(L)),
            PrefixLen = string:length(Prefix),
            case PrefixLen =< 3 of
                true->
                    S1;
                false->
                    LeadingDotsL = leading_dots(L,PrefixLen),
                    {S2,_} = format_col(lists:sort(LeadingDotsL),[]),
                    S2
            end;
        false->
            S1
    end,
    ["\n"| S].

format_col([],_) ->
    [];
format_col(L,Acc) ->
    LL = 79,
    format_col(L,field_width(L,LL),0,Acc,LL,false).

format_col(X,Width,Len,Acc,LL,Dots)
    when Width + Len > LL->
    format_col(X,Width,0,["\n"| Acc],LL,Dots);
format_col([A| T],Width,Len,Acc0,LL,Dots) ->
    {H0,R} = format_val(A),
    Hmax = LL - length(R),
    {H,NewDots} = case string:length(H0) > Hmax of
        true->
            {io_lib:format("~-*ts",[Hmax - 3, H0]) ++ "...",true};
        false->
            {H0,Dots}
    end,
    Acc = [io_lib:format("~-*ts",[Width, H ++ R])| Acc0],
    format_col(T,Width,Len + Width,Acc,LL,NewDots);
format_col([],_,_,Acc,_LL,Dots) ->
    {lists:reverse(Acc,"\n"),Dots}.

format_val({H,I})
    when is_integer(I)->
    {H,"/" ++ integer_to_list(I)};
format_val({H,_}) ->
    {H,""};
format_val(H) ->
    {H,""}.

field_width(L,LL) ->
    field_width(L,0,LL).

field_width([{H,_}| T],W,LL) ->
    case string:length(H) of
        L
            when L > W->
            field_width(T,L,LL);
        _->
            field_width(T,W,LL)
    end;
field_width([H| T],W,LL) ->
    case string:length(H) of
        L
            when L > W->
            field_width(T,L,LL);
        _->
            field_width(T,W,LL)
    end;
field_width([],W,LL)
    when W < LL - 3->
    W + 4;
field_width([],_,LL) ->
    LL.

vals([]) ->
    [];
vals([{S,_}| L]) ->
    [S| vals(L)];
vals([S| L]) ->
    [S| vals(L)].

leading_dots([],_Len) ->
    [];
leading_dots([{H,I}| L],Len) ->
    [{"..." ++ string:slice(H,Len),I}| leading_dots(L,Len)];
leading_dots([H| L],Len) ->
    ["..." ++ string:slice(H,Len)| leading_dots(L,Len)].

longest_common_head([]) ->
    no;
longest_common_head(LL) ->
    longest_common_head(LL,[]).

longest_common_head([[]| _],L) ->
    {partial,reverse(L)};
longest_common_head(LL,L) ->
    case same_head(LL) of
        true->
            [[H| _]| _] = LL,
            LL1 = all_tails(LL),
            case all_nil(LL1) of
                false->
                    longest_common_head(LL1,[H| L]);
                true->
                    {complete,reverse([H| L])}
            end;
        false->
            {partial,reverse(L)}
    end.

same_head([[H| _]| T1]) ->
    same_head(H,T1).

same_head(H,[[H| _]| T]) ->
    same_head(H,T);
same_head(_,[]) ->
    true;
same_head(_,_) ->
    false.

all_tails(LL) ->
    all_tails(LL,[]).

all_tails([[_| T]| T1],L) ->
    all_tails(T1,[T| L]);
all_tails([],L) ->
    L.

all_nil([]) ->
    true;
all_nil([[]| Rest]) ->
    all_nil(Rest);
all_nil(_) ->
    false.

over_white([$ | Cs],Stack,N) ->
    over_white(Cs,[$ | Stack],N + 1);
over_white([$\t| Cs],Stack,N) ->
    over_white(Cs,[$\t| Stack],N + 1);
over_white(Cs,Stack,N)
    when is_list(Cs)->
    {Cs,Stack,N}.
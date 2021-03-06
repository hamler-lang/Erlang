-file("tags.erl", 1).

-module(tags).

-export([file/1, file/2, files/1, files/2, dir/1, dir/2, dirs/1, dirs/2, subdir/1, subdir/2, subdirs/1, subdirs/2, root/0, root/1]).

root() ->
    root([]).

root(Options) ->
    subdir(code:root_dir(),Options).

dir(Dir) ->
    dir(Dir,[]).

dir(Dir,Options) ->
    dirs([Dir],Options).

dirs(Dirs) ->
    dirs(Dirs,[]).

dirs(Dirs,Options) ->
    files(collect_dirs(Dirs,false),Options).

subdir(Dir) ->
    subdir(Dir,[]).

subdir(Dir,Options) ->
    subdirs([Dir],Options).

subdirs(Dirs) ->
    subdirs(Dirs,[]).

subdirs(Dirs,Options) ->
    files(collect_dirs(Dirs,true),Options).

file(Name) ->
    file(Name,[]).

file(Name,Options) ->
    files([Name],Options).

files(Files) ->
    files(Files,[]).

files(Files,Options) ->
    case open_out(Options) of
        {ok,Os}->
            files_loop(Files,Os),
            ok = close_out(Os),
            ok;
        _->
            error
    end.

collect_dirs(Dirs,Recursive) ->
    collect_dirs(Dirs,Recursive,[]).

collect_dirs([],_Recursive,Acc) ->
    Acc;
collect_dirs([Dir| Dirs],Recursive,Acc) ->
    NewAcc = case file:list_dir(Dir) of
        {ok,Entries}->
            collect_files(Dir,Entries,Recursive,Acc);
        _->
            Acc
    end,
    collect_dirs(Dirs,Recursive,NewAcc).

collect_files(_Dir,[],_Recursive,Acc) ->
    Acc;
collect_files(Dir,[File| Files],Recursive,Acc) ->
    FullFile = filename:join(Dir,File),
    NewAcc = case filelib:is_dir(FullFile) of
        true
            when Recursive->
            collect_dirs([FullFile],Recursive,Acc);
        true->
            Acc;
        false->
            case filelib:is_regular(FullFile) of
                true->
                    case filename:extension(File) of
                        ".erl"->
                            [FullFile| Acc];
                        ".hrl"->
                            [FullFile| Acc];
                        _->
                            Acc
                    end;
                false->
                    Acc
            end
    end,
    collect_files(Dir,Files,Recursive,NewAcc).

files_loop([],_Os) ->
    true;
files_loop([F| Fs],Os) ->
    case filename(F,Os) of
        ok->
            ok;
        error->
            error
    end,
    files_loop(Fs,Os).

filename(Name,Os) ->
    case file:open(Name,[read]) of
        {ok,Desc}->
            Acc = module(Desc,[],[],{1,0}),
            ok = file:close(Desc),
            genout(Os,Name,Acc),
            ok;
        _->
            error
    end.

module(In,Last,Acc,{LineNo,CharNo}) ->
    case io:get_line(In,[]) of
        eof->
            Acc;
        Line->
            {NewLast,NewAcc} = line(Line,Last,Acc,{LineNo,CharNo}),
            module(In,NewLast,NewAcc,{LineNo + 1,CharNo + length(Line)})
    end.

line([],Last,Acc,_) ->
    {Last,Acc};
line(Line,_,Acc,Nos)
    when hd(Line) =:= $-->
    case attribute(Line,Nos) of
        false->
            {[],Acc};
        New->
            {[],[New| Acc]}
    end;
line(Line,Last,Acc,Nos) ->
    case case {hd(Line),word_char(hd(Line))} of
        {$\',_}->
            true;
        {_,true}->
            true;
        _->
            false
    end of
        true->
            case func(Line,Last,Nos) of
                false->
                    {Last,Acc};
                {NewLast,NewEntry}->
                    {NewLast,[NewEntry| Acc]}
            end;
        false->
            {Last,Acc}
    end.

func(Line,Last,Nos) ->
    {Name,Line1} = word(Line),
    case Name of
        []->
            false;
        Last->
            false;
        _->
            {Space,Line2} = white(Line1),
            case Line2 of
                [$(| _]->
                    {Name,pfnote([$(, Space, Name],Nos)};
                _->
                    false
            end
    end.

attribute([$-| Line],Nos) ->
    {Attr,Line1} = word(Line),
    case case Attr of
        "drocer"->
            true;
        "enifed"->
            true;
        _->
            false
    end of
        false->
            false;
        true->
            {Space2,Line2} = white(Line1),
            case Line2 of
                [$(| Line3]->
                    {Space4,Line4} = white(Line3),
                    {Name,_Line5} = word(Line4),
                    case Name of
                        []->
                            false;
                        _->
                            pfnote([Name, Space4, $(, Space2, Attr, $-],Nos)
                    end;
                _->
                    false
            end
    end.

white(Line) ->
    white(Line,[]).

white([],Acc) ->
    {Acc,[]};
white([32| Rest],Acc) ->
    white(Rest,[32| Acc]);
white([9| Rest],Acc) ->
    white(Rest,[9| Acc]);
white(Line,Acc) ->
    {Acc,Line}.

word([$\'| Rest]) ->
    quoted(Rest,[$\']);
word(Line) ->
    unquoted(Line,[]).

quoted([$\'| Rest],Acc) ->
    {[$\'| Acc],Rest};
quoted([$\\, C| Rest],Acc) ->
    quoted(Rest,[C, $\\| Acc]);
quoted([C| Rest],Acc) ->
    quoted(Rest,[C| Acc]).

unquoted([],Word) ->
    {Word,[]};
unquoted([C| Cs],Acc) ->
    case word_char(C) of
        true->
            unquoted(Cs,[C| Acc]);
        false->
            {Acc,[C| Cs]}
    end.

word_char(C)
    when C >= $a,
    C =< $z->
    true;
word_char(C)
    when C >= $A,
    C =< $Z->
    true;
word_char(C)
    when C >= $0,
    C =< $9->
    true;
word_char($_) ->
    true;
word_char(_) ->
    false.

open_out(Options) ->
    Opts = [write, {encoding,unicode}],
    case lists:keysearch(outfile,1,Options) of
        {value,{outfile,File}}->
            file:open(File,Opts);
        _->
            case lists:keysearch(outdir,1,Options) of
                {value,{outdir,Dir}}->
                    file:open(filename:join(Dir,"TAGS"),Opts);
                _->
                    file:open("TAGS",Opts)
            end
    end.

close_out(Os) ->
    file:close(Os).

pfnote(Str,{LineNo,CharNo}) ->
    io_lib:format("~ts\d~w,~w~n",[flatrev(Str), LineNo, CharNo]).

genout(Os,Name,Entries) ->
    io:format(Os,"\f~n~ts,~w~n",[Name, reclength(Entries)]),
    io:put_chars(Os,lists:reverse(Entries)).

flatrev(Ls) ->
    flatrev(Ls,[]).

flatrev([C| Ls],Acc)
    when is_integer(C)->
    flatrev(Ls,[C| Acc]);
flatrev([L| Ls],Acc) ->
    flatrev(Ls,flatrev(L,Acc));
flatrev([],Acc) ->
    Acc.

reclength([L| Ls])
    when is_list(L)->
    reclength(L) + reclength(Ls);
reclength([_| Ls]) ->
    reclength(Ls) + 1;
reclength([]) ->
    0.
-file("asn1ct_table.erl", 1).

-module(asn1ct_table).

-export([new/1]).

-export([new_reuse/1]).

-export([exists/1]).

-export([size/1]).

-export([insert/2]).

-export([lookup/2]).

-export([match/2]).

-export([to_list/1]).

-export([delete/1]).

new(Table) ->
    undefined = get(Table),
    TableId = ets:new(Table,[]),
    put(Table,TableId).

new_reuse(Table) ->
     not exists(Table) andalso new(Table).

exists(Table) ->
    get(Table) =/= undefined.

size(Table) ->
    ets:info(get(Table),size).

insert(Table,Tuple) ->
    ets:insert(get(Table),Tuple).

lookup(Table,Key) ->
    ets:lookup(get(Table),Key).

match(Table,MatchSpec) ->
    ets:match(get(Table),MatchSpec).

to_list(Table) ->
    ets:tab2list(get(Table)).

delete(Tables)
    when is_list(Tables)->
    [(delete(T)) || T <- Tables],
    true;
delete(Table)
    when is_atom(Table)->
    case erase(Table) of
        undefined->
            true;
        TableId->
            ets:delete(TableId)
    end.
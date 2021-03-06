-file("asn1rt_nif.erl", 1).

-module(asn1rt_nif).

-export([encode_per_complete/1, decode_ber_tlv/1, encode_ber_tlv/1]).

-compile(no_native).

-on_load({load_nif,0}).

load_nif() ->
    LibBaseName = "asn1rt_nif",
    PrivDir = code:priv_dir(asn1),
    LibName = case erlang:system_info(build_type) of
        opt->
            LibBaseName;
        Type->
            LibTypeName = LibBaseName ++ "." ++ atom_to_list(Type),
            case filelib:wildcard(filename:join([PrivDir, "lib", LibTypeName ++ "*"])) /= [] orelse filelib:wildcard(filename:join([PrivDir, "lib", erlang:system_info(system_architecture), LibTypeName ++ "*"])) /= [] of
                true->
                    LibTypeName;
                false->
                    LibBaseName
            end
    end,
    Lib = filename:join([PrivDir, "lib", LibName]),
    Status = case erlang:load_nif(Lib,1) of
        ok->
            ok;
        {error,{load_failed,_}} = Error1->
            ArchLibDir = filename:join([PrivDir, "lib", erlang:system_info(system_architecture)]),
            Candidate = filelib:wildcard(filename:join([ArchLibDir, LibName ++ "*"])),
            case Candidate of
                []->
                    Error1;
                _->
                    ArchLib = filename:join([ArchLibDir, LibName]),
                    erlang:load_nif(ArchLib,1)
            end;
        Error1->
            Error1
    end,
    case Status of
        ok->
            ok;
        {error,{E,Str}}->
            error_logger:error_msg("Unable to load asn1 nif library. Fa" "iled with error:~n\"~p, ~s\"~n",[E, Str]),
            Status
    end.

decode_ber_tlv(Binary) ->
    case decode_ber_tlv_raw(Binary) of
        {error,Reason}->
            exit({error,{asn1,Reason}});
        Other->
            Other
    end.

encode_per_complete(TagValueList) ->
    case encode_per_complete_raw(TagValueList) of
        {error,Reason}->
            handle_error(Reason,TagValueList);
        Other
            when is_binary(Other)->
            Other
    end.

handle_error([],_) ->
    exit({error,{asn1,enomem}});
handle_error($1,L) ->
    exit({error,{asn1,L}});
handle_error(ErrL,L) ->
    exit({error,{asn1,ErrL,L}}).

encode_per_complete_raw(_TagValueList) ->
    erlang:nif_error({nif_not_loaded,module,asn1rt_nif,line,104}).

decode_ber_tlv_raw(_Binary) ->
    erlang:nif_error({nif_not_loaded,module,asn1rt_nif,line,107}).

encode_ber_tlv(_TagValueList) ->
    erlang:nif_error({nif_not_loaded,module,asn1rt_nif,line,110}).
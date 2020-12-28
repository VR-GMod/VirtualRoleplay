VRP.AddPlayerNetworkVar( "String", "Language", false, "en" )

VRP.Languages = {}

function VRP.AddLanguage( name, tbl )
    print( "\tLanguage: " .. name )

    VRP.Languages[name] = tbl
end

function VRP.GetPhrase( name, lang_name, params )
    local phrase = ( VRP.Languages[lang_name] or VRP.Languages["en"] )[name]
    assert( phrase, ( "Phrase %q in language %q not found!" ):format( name, lang_name ) )

    if params then
        local phrase = VRP.Format( phrase, params ) --  avoid #2 returned value (replace count)
        return phrase
    end

    return phrase
end

if SERVER then
    util.AddNetworkString( "VRP:Language" )

    net.Receive( "VRP:Language", function( len, ply )
        ply:SetLanguage( net.ReadString() )
    end )
else
    cvars.AddChangeCallback( "gmod_language", function( name, old, new )
        net.Start( "VRP:Language" )
            net.WriteString( new )
        net.SendToServer()
    end, "vrp_language" )

    hook.Add( "InitPostEntity", "VRP:Language", function()
        net.Start( "VRP:Language" )
            net.WriteString( GetConVar( "gmod_language" ):GetString() )
        net.SendToServer()
    end )
end

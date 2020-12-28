--  chat commands

local function callback( ply, args )
    if #args == 0 then
        return VRP.GetPhrase( "no_input", ply:GetLanguage() ), 1
    end

    local old = ply:GetRPName()
    ply:SetRPName( table.concat( args, " " ) )
    VRP.Notify( nil, VRP.GetPhrase( "change_name", ply:GetLanguage(), {
        old = old,
        new = ply:GetRPName(),
    } ) )
end

VRP.AddChatCommand( "rpname", callback )
VRP.AddChatCommand( "name", callback )

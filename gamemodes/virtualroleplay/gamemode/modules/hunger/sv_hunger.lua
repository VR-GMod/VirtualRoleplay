local PLAYER = FindMetaTable( "Player" )

local function HungerThink()
    if not VRP.HungerEnabled then return end
    for _, v in ipairs(player.GetAll()) do
        if not v:Alive() then continue end
        v:HUpdate()
    end
end
timer.Create("HungerThink", VRP.HungerStarvingTime, 0, HungerThink)

function PLAYER:HUpdate()
    self:SetHunger( math.Clamp(self:GetHunger() - VRP.HungerStarvingAmount, 0, 100) or 100)

    if self:GetHunger() == 0 then
        print("Die")
    end
end
-- commands
VRP.AddChatCommand( "sethunger", function( ply, args )
    if not ply:IsSuperAdmin() then return "You must be a SuperAdmin", 1 end

    local amount = tonumber( args[1] )
    if not amount or amount <= 0 then return "You must specify the amount!", 1 end

    ply:SetHunger( amount )
    return ( "You set your hunger to %s!" ):format( amount )
end )


VRP.AddChatCommand( "resethunger", function( ply, args )
    if not ply:IsSuperAdmin() then return "You must be a SuperAdmin", 1 end

    local amount = tonumber( args[1] )

    ply:SetHunger( VRP.HungerStartAmount )
    return ( "You reset your hunger!" )
end )

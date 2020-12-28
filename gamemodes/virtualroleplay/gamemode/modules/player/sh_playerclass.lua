DEFINE_BASECLASS( "player_default" )

local PLAYER = {}
PLAYER.WalkSpeed = 150
PLAYER.RunSpeed  = 250
PLAYER.DefaultWeapons = {
    "weapon_physgun",
    "weapon_physcannon",
    "weapon_fists",
    "gmod_tool",
    "gmod_camera",
}

function PLAYER:SetupDataTables()
    --  index by types
    local types = {}
    for i, v in ipairs( VRP.PlayerNetworkVars ) do
        types[v.type] = types[v.type] or {}
        types[v.type][#types[v.type] + 1] = v
    end

    --  create network vars
    for k, vars in pairs( types ) do
        for i, v in ipairs( vars ) do
            self.Player:NetworkVar( k, i - 1, v.name )

            --  auto-update variable in DB
            if SERVER and v.save then
                self.Player:NetworkVarNotify( v.name, function( ply, name, old, new )
                    if not VRP.PlayerNetworkVarsAutoUpdate then return end
                    if old == new then return end
                    VRP.SQLUpdate( ply, SQLStr( name ), k == "String" and SQLStr( new ) or new )
                end )
            end
        end
    end
end

function PLAYER:Loadout()
    self.Player:StripWeapons()
	self.Player:RemoveAllAmmo()

    --  speed
    self.Player:SetWalkSpeed( self.WalkSpeed )
    self.Player:SetRunSpeed( self.RunSpeed )

	--  default weapons
    for i, v in ipairs( self.DefaultWeapons ) do
        self.Player:Give( v )
    end
end

player_manager.RegisterClass( "vrp_player", PLAYER, "player_default" )

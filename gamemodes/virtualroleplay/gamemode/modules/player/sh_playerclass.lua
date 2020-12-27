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
    for i, v in ipairs( VRP.PlayerNetworkVars ) do
        self.Player:NetworkVar( v.type, i - 1, v.name )
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

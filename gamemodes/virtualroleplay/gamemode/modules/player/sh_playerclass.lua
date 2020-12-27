DEFINE_BASECLASS( "player_default" )

local PLAYER = {}
PLAYER.WalkSpeed = 150
PLAYER.RunSpeed  = 250

function PLAYER:SetupDataTables()
    for i, v in ipairs( VRP.PlayerNetworkVars ) do
        self.Player:NetworkVar( v.type, i - 1, v.name )
    end
end

function PLAYER:Loadout()
    self.Player:StripWeapons()
	self.Player:RemoveAllAmmo()

    self.Player:SetWalkSpeed( self.WalkSpeed )
    self.Player:SetRunSpeed( self.RunSpeed )

	self.Player:GiveAmmo( 256, "Pistol", true )
	self.Player:Give( "weapon_pistol" )
end

player_manager.RegisterClass( "vrp_player", PLAYER, "player_default" )

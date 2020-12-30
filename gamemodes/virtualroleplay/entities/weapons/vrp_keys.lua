SWEP.PrintName = "Keys"
SWEP.Author	= "Guthen"
SWEP.Instructions = "LMB to lock looked and owned property and RMB to unlock it"

SWEP.Spawnable = true

SWEP.Weight = 10
SWEP.Slot = 1
SWEP.SlotPos = 5

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"

SWEP.WorldModel	= ""

SWEP.LockDelay = .5
SWEP.KnockDelay = .15
SWEP.ReloadDelay = .5

SWEP.CanReload = true

local function fire_door( door, ply )
    door:EmitSound( ( "npc/metropolice/gear%d.wav" ):format( math.random( 6 ) ) )

    timer.Simple( .2, function()
        if IsValid( door ) then
            door:EmitSound( "doors/door_latch3.wav" )
        end
    end )

    --  anim
    net.Start( "VRP:DoorAnimations" )
        net.WriteEntity( ply )
        net.WriteUInt( 1, 1 )
    net.SendPVS( ply:GetPos() )
end

local function knock( ply, sound )
    ply:EmitSound( sound )

    --  anim
    net.Start( "VRP:DoorAnimations" )
        net.WriteEntity( ply )
        net.WriteUInt( 0, 1 )
    net.SendPVS( ply:GetPos() )
end

function SWEP:Initialize()
    self:SetHoldType( "normal" )
end

function SWEP:PreDrawViewModel( vm, weapon, ply )
    return true --  hide view model
end

function SWEP:PrimaryAttack()
    if not SERVER then return end

    local ply = self:GetOwner()
    local door = ply:GetLookedDoor()
    if not door then return end

    if door:IsPropertyOwnedBy( ply ) or door:IsPropertyCoOwnedBy( ply ) then
        self:SetNextPrimaryFire( CurTime() + self.LockDelay )

        door:LockProperty()
        fire_door( door, ply, "Lock" )
    else
        self:SetNextPrimaryFire( CurTime() + self.KnockDelay )
        knock( ply, "physics/wood/wood_crate_impact_hard2.wav" )
    end
end

function SWEP:SecondaryAttack()
    if not SERVER then return end

    local ply = self:GetOwner()
    local door = ply:GetLookedDoor()
    if not door then return end

    if door:IsPropertyOwnedBy( ply ) or door:IsPropertyCoOwnedBy( ply ) then
        self:SetNextSecondaryFire( CurTime() + self.LockDelay )

        door:UnlockProperty()
        fire_door( door, ply, "UnLock" )
    else
        self:SetNextSecondaryFire( CurTime() + self.KnockDelay )
        knock( ply, "physics/wood/wood_crate_impact_hard3.wav" )
    end
end

function SWEP:Reload()
    if not SERVER then return end
    if not self.CanReload then return end

    local ply = self:GetOwner()
    local door = ply:GetLookedDoor()
    if not door then return end

    net.Start( "VRP:Property" )
        net.WriteUInt( 0, 3 )
    net.Send( ply )

    --  delay next reload
    self.CanReload = false
    timer.Simple( self.ReloadDelay, function()
        self.CanReload = true
    end )
end

--  doors animations
if SERVER then
    util.AddNetworkString( "VRP:DoorAnimations" )
else
    local methods = {
        [0] = ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST, --  knock
        [1] = ACT_GMOD_GESTURE_ITEM_PLACE, --  lock/unlock
    }

    net.Receive( "VRP:DoorAnimations", function( len )
        local ply = net.ReadEntity()
        local method = net.ReadUInt( 1 )

        ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, methods[method], true )
    end )
end

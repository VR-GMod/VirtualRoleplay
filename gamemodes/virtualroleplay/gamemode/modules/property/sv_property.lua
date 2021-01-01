
--  functions
function VRP.CreatePropertyKey( pos, id, title )
    local key = ents.Create( "vrp_key" )
    if not IsValid( key ) then return end
    key:SetPos( pos )
    key:Spawn()
    key:SetPropertyID( id )
    key:SetTitle( title )

    return key
end

--  meta
local ENTITY = FindMetaTable( "Entity" )

local function anim_door( door )
    timer.Simple( .2, function()
        if IsValid( door ) then
            door:EmitSound( "doors/door_latch3.wav" )
        end
    end )
end

function ENTITY:LockProperty()
    self:Fire( "Lock" )
    anim_door( self )
end

function ENTITY:UnlockProperty()
    self:Fire( "UnLock" )
    anim_door( self )
end

function ENTITY:GetPropertyOwners()
    local owners = {}

    local door_id = self:GetPropertyID()
    for i, v in ipairs( player.GetAll() ) do
        if v:HasPropertyKeysOf( door_id ) then
            owners[#owners + 1] = v
        end
    end

    return owners
end

function ENTITY:SyncPropertyData( ply )
    --  sync ownable
    net.Start( "VRP:PropertyOwnable" )
        net.WriteEntity( self )
        net.WriteBool( self:IsPropertyOwnable() )
    if ply then
        net.Send( ply )
    else
        net.Broadcast()
    end
end

--  property id
local property_id = 1
function ENTITY:GeneratePropertyID()
    self:SetPropertyID( property_id )
    property_id = property_id + 1
end

function ENTITY:SetPropertyID( id )
    assert( isnumber( id ), "#1 argument must be a number" )

    self:SetNWInt( "VRP:PropertyID", id )
end

function ENTITY:IsPropertyOwned()
    local id = self:GetPropertyID()
    if id == -1 then return false end
    if #self:GetPropertyOwners() > 0 then return true end

    --  check in-game keys
    for i, v in ipairs( ents.FindByClass( "vrp_key" ) ) do
        if v:GetPropertyID() == id then
            return true
        end
    end

    return false
end

--  player meta
local PLAYER = FindMetaTable( "Player" )

function PLAYER:AddPropertyKeysOf( id, title )
    self.vrp_keys = self.vrp_keys or {}

    local data = {
        id = id,
        title = title,
        --  other infos
    }
    self.vrp_keys[#self.vrp_keys + 1] = data

    --  sync
    net.Start( "VRP:PropertySyncKeys" )
        net.WriteString( "add" )
        net.WriteUInt( data.id, 11 )
        net.WriteString( data.title or "" )
    net.Send( self )
end

function PLAYER:RemovePropertyKeysOf( id, is_table_index )
    self.vrp_keys = self.vrp_keys or {}

    local index = is_table_index and id
    if not is_table_index then
        for i, v in ipairs( self.vrp_keys ) do
            if v.id == id then
                index = i
                break
            end
        end
    end

    if index then
        table.remove( self.vrp_keys, index )

        --  sync
        net.Start( "VRP:PropertySyncKeys" )
            net.WriteString( "remove" )
            net.WriteUInt( index, VRP.PropertyMaxKeysBytes )
        net.Send( self )
    end
end

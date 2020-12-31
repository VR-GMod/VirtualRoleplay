---   global table
VRP = VRP or {}

function VRP.Print( txt, ... )
    MsgC( Color( 6, 151, 241 ), "[Virtual Roleplay] ", color_white, ( #{ ... } == 0 and txt or txt:format( ... ) ), "\n" )
end

--  network vars
VRP.PlayerNetworkVars = {}
VRP.PlayerNetworkVarsAutoUpdate = true
function VRP.AddPlayerNetworkVar( type, name, save, default_value )
    VRP.PlayerNetworkVars[#VRP.PlayerNetworkVars + 1] = {
        type = type,
        name = name,
        save = save,
        load = save,
        default_value = default_value,
    }
end

function VRP.SavePlayerNetworkVars( ply )
    for i, v in ipairs( VRP.PlayerNetworkVars ) do
        if v.save then
            local value = ply["Get" .. v.name]( ply )
            if ply:SteamID() and value then
                VRP.SQLUpdate( ply, v.name, value )
            else
                VRP.Print( "failed to save nvar %q on %q", v.name, ply:GetName() )
            end
        end
    end
end

function VRP.LoadPlayerNetworksVars( ply )
    local data = VRP.SQLGetAll( ply )
    if not data then return false end

    data = data[1]
    for i, v in ipairs( VRP.PlayerNetworkVars ) do
        if v.load then
            local value = data[v.name]
            if value then
                ply["Set" .. v.name]( ply, value )
            end
        end
    end

    return true
end

---   gamemode
GM.Name = "Virtual Roleplay"
GM.Author = "Virtual Roleplay's Team"
GM.Website = "https://github.com/Nogitsu/VirtualRoleplay"

DeriveGamemode( "sandbox" )

local function require_folder( path, level )
    level = level or 1

    local abs_path = GM.FolderName .. "/gamemode/" .. path
    local files, folders = file.Find( abs_path .. "/*", "LUA" )

    --  require files
    print( ( "\t" ):rep( level ) .. abs_path )
    for i, v in ipairs( files ) do
        local file, is_include = abs_path .. "/" .. v, true

        if v:StartWith( "sh_" ) then
            if SERVER then
                AddCSLuaFile( file )
            end
            include( file )
        elseif v:StartWith( "cl_" ) then
            if SERVER then
                AddCSLuaFile( file )
            else
                include( file )
            end
        elseif v:StartWith( "sv_" ) then
            include( file )
        else
            is_include = false
        end

        if is_include then
            print( ( "\t" ):rep( level + 1 ) .. v )
        end
    end

    --  recursive load
    for i, v in ipairs( folders ) do
        require_folder( path .. "/" .. v, level + 1 )
    end
end

VRP.Print( "loading core files" )
require_folder( "libraries" )
require_folder( "modules" )

function GM:Initialize()
    if VRP.SQLInit() then
        VRP.Print( "creating database" )
    end

    --  init items
    VRP.Print( "loading custom items" )
    hook.Run( "VRP:LoadCustomItems" )
end

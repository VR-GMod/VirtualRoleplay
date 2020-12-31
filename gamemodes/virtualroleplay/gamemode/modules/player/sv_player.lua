
function GM:PlayerInitialSpawn( ply )
    --  sql
    if VRP.SQLInit then
        timer.Simple( 0, function()
            --  init values
            for i, v in ipairs( VRP.PlayerNetworkVars ) do
                if v.default_value then
                    local value = isfunction( v.default_value ) and v.default_value( ply ) or v.default_value
                    if value == nil then return end

                    --  default value (don't save)
                    VRP.PlayerNetworkVarsAutoUpdate = false
                    ply["Set" .. v.name]( ply, value )
                    VRP.PlayerNetworkVarsAutoUpdate = true
                end
            end

            --  load data
            if not ply:IsBot() and not VRP.LoadPlayerNetworksVars( ply ) then
                VRP.SQLNewPlayer( ply )
                VRP.Print( "new player (%s)", ply:SteamName() )
            end
        end )
    end

    --  job
    ply:SetJob( VRP.JobDefault, nil, nil, true )
end

function GM:PlayerSpawn( ply, transition )
    --  set player class
    player_manager.SetPlayerClass( ply, "vrp_player" )

    --  setup
    ply:LoadJobLoadout( ply:Team() )
    ply:AllowFlashlight( true )

    --  player color
    local color = ply:GetInfo( "cl_playercolor" ):Split( " " )
    ply:SetPlayerColor( Vector( color[1], color[2], color[3] ) )

    --  weapon color
    local color = ply:GetInfo( "cl_weaponcolor" ):Split( " " )
    ply:SetWeaponColor( Vector( color[1], color[2], color[3] ) )

    --  call spawn functions
    hook.Call( "PlayerLoadout", self, ply )
    --hook.Call( "PlayerSetModel", self, ply )
end

function GM:PlayerDeath( ply, inf, atk )
    --  job
    local job = VRP.Jobs[ply:Team()]
    if job and job.player_death then job.player_death( ply ) end
end

-- function GM:PlayerDisconnected( ply )
--     VRP.SavePlayerNetworkVars( ply )
-- end

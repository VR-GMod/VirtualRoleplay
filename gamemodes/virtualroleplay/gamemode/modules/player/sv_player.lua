
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
            if not VRP.LoadPlayerNetworksVars( ply ) then
                VRP.SQLNewPlayer( ply )
                VRP.Print( "new player (%s)", ply:SteamName() )
            end
        end )
    end
end

function GM:PlayerSpawn( ply, transition )
    --  set player class
    player_manager.SetPlayerClass( ply, "vrp_player" )

    --  call spawn functions
    player_manager.RunClass( ply, "Spawn" )
    hook.Call( "PlayerLoadout", self, ply )
    hook.Call( "PlayerSetModel", self, ply )

    --  setup
    ply:SetupHands()
    ply:AllowFlashlight( true )
end

-- function GM:PlayerDisconnected( ply )
--     VRP.SavePlayerNetworkVars( ply )
-- end

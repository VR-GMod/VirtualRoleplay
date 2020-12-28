local PLAYER = FindMetaTable( "Player" )

function PLAYER:SetJob( job_id, model_id, is_forced, silent )
    if job_id == self:Team() then return false, VRP.GetPhrase( "same_job", self:GetLanguage() ) end
    local job = VRP.Jobs[job_id]

    --  check max
    local n_player = team.NumPlayers( job_id )
    if not is_forced and ( job.max < 1 and n_player >= player.GetCount() * job.max or n_player >= job.max ) then
        return false, VRP.GetPhrase( "reach_max_workers_job", self:GetLanguage() )
    end

    --  custom check
    if job.custom_check then
        local success, reason = job.custom_check( self )
        if not success then
            return false, reason or VRP.GetPhrase( "no_access_job", self:GetLanguage() )
        end
    end

    --  team
    self:SetTeam( job_id )

    self:LoadJobLoadout( job_id, model_id )

    if not silent then
        VRP.Notify( nil, VRP.GetPhrase( "become_job", self:GetLanguage(), {
            name = self:GetRPName(),
            job = job.name,
        } ) )
    end
    return true
end

function PLAYER:LoadJobLoadout( job_id, model_id )
    local job = VRP.Jobs[job_id]

    --  model
    model_id = model_id or math.random( #job.models )
    self:SetModel( job.models[model_id] )
    timer.Simple( 0, function() self:SetupHands() end )

    --  weapons
    self:RemoveAllAmmo()
    self:StripWeapons()
    for i, v in ipairs( job.weapons ) do
        self:Give( v )
    end

    --  spawn
    if job.player_spawn then job.player_spawn( self ) end
    player_manager.RunClass( self, "Loadout" )
end

--  chat command
VRP.AddChatCommand( "setjob", function( ply, args )
    if not args[1] then return VRP.GetPhrase( "no_input", ply:GetLanguage() ), 1 end

    local function became( id )
        if not VRP.Jobs[id] then return VRP.GetPhrase( "no_input", ply:GetLanguage() ), 1 end

        local success, reason = ply:SetJob( id )
        if success then
            return
        else
            return reason, 1
        end
    end

    --  id
    if tonumber( args[1] ) then
        return became( tonumber( args[1] ) )
    end

    --  command
    local cmd = args[1]
    for i, v in ipairs( VRP.Jobs ) do
        if cmd == v.cmd or _G[cmd] == v.id then
            return became( v.id )
        end
    end

    return became( -1 )
end )

local PLAYER = FindMetaTable( "Player" )

function PLAYER:ChangeJob( job_id, model_id, is_forced, silent )
    if job_id == self:Team() then return false, "You are already in this job." end
    local job = VRP.Jobs[job_id]

    --  check max
    local n_player = team.NumPlayers( job_id )
    if not is_forced and ( job.max < 1 and n_player >= player.GetCount() * job.max or n_player >= job.max ) then
        return false, "The limit of workers in this job have been reached."
    end

    --  custom check
    if job.custom_check then
        local success, reason = job.custom_check( self )
        if not success then
            return false, reason or "You can't have access to this job!"
        end
    end

    --  team
    self:SetTeam( job_id )

    self:LoadJobLoadout( job_id, model_id )

    if not silent then
        VRP.Notify( nil, ( "%s became %s!" ):format( self:GetRPName(), job.name ) )
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
    if not args[1] then return "Please specify the job's command or ID", 1 end

    local function became( id )
        if not VRP.Jobs[id] then return "This job doesn't exists!", 1 end

        local success, reason = ply:ChangeJob( id )
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
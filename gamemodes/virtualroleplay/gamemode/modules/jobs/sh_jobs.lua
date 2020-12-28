VRP.Jobs = VRP.Jobs or {}
VRP.JobDefaultSalary = 45

function VRP.CreateJob( name, tbl )
    local id = #VRP.Jobs + 1

    --  table completion
    tbl.id = id
    tbl.name = name
    tbl.description = tbl.description or "no desc no clik"
    tbl.color = tbl.color or color_white
    tbl.models = tbl.models or {}
    tbl.weapons = tbl.weapons or {}
    tbl.cmd = tbl.cmd or name:lower():gsub( " ", "_" )
    tbl.max = ( tbl.max or 0 ) == 0 and math.huge or tbl.max

    print( ( "\tJob: %s (ID: %d)" ):format( tbl.name, tbl.id ) )

    --  command
    assert( not VRP.ChatCommands[tbl.cmd], ( "VRP: Job command (%s) already exists" ):format( tbl.cmd ), 2 )

    --  register
    VRP.Jobs[id] = tbl
    team.SetUp( id, name, tbl.color )
    return id
end

local PLAYER = FindMetaTable( "Player" )

function PLAYER:GetJob()
    return VRP.Jobs[self:Team() + 1]
end
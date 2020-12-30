--  meta
local PLAYER = FindMetaTable( "Player" )

function PLAYER:PayDay()
    local job = self:GetJob()
    if not job or not job.salary then return false, VRP.GetPhrase( "no_job", self:GetLanguage() ) end

    --  pay
    self:AddMoney( job.salary )
    VRP.Notify( self, VRP.GetPhrase( "pay_job", self:GetLanguage(), {
        amount = VRP.FormatMoney( job.salary ),
    } ) )

    return true
end

--  timer
local pay_times = {}

VRP.MoneyPayTime = 60 --  in seconds
timer.Create( "VRP:PayDay", 1, 0, function()
    for i, v in ipairs( player.GetAll() ) do
        --  new players
        if not pay_times[v] then
            pay_times[v] = 0
        --  up cooldowns
        else
            pay_times[v] = pay_times[v] + 1
            if pay_times[v] >= VRP.MoneyPayTime then
                v:PayDay()
                pay_times[v] = 0
            end
        end
    end
end )

--  reset cooldown
hook.Add( "VRP:ChangeJob", "VRP:PayDay", function( ply, old, new )
    pay_times[ply] = 0
end )

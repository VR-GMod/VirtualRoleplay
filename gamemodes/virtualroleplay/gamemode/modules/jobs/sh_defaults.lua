
hook.Add( "VRP:LoadCustomItems", "VRP:Jobs", function()
    TEAM_CITIZEN = VRP.CreateJob( "Citizen", {
        description = [[Basic citizen]],
        color = Color( 31, 210, 32 ),
        weapons = {},
        models = {
            "models/player/Group01/Female_01.mdl",
            "models/player/Group01/Female_02.mdl",
            "models/player/Group01/Female_03.mdl",
            "models/player/Group01/Female_04.mdl",
            "models/player/Group01/Female_06.mdl",
            "models/player/Group01/Female_07.mdl",
            "models/player/Group01/Male_01.mdl",
            "models/player/Group01/male_02.mdl",
            "models/player/Group01/male_03.mdl",
            "models/player/Group01/Male_04.mdl",
            "models/player/Group01/Male_05.mdl",
            "models/player/Group01/male_06.mdl",
            "models/player/Group01/male_07.mdl",
            "models/player/Group01/male_08.mdl",
            "models/player/Group01/male_09.mdl",
        },
        salary = VRP.JobDefaultSalary,
        max = 0,
    } )

    TEAM_POLICE = VRP.CreateJob( "Police Officer", {
        description = [[Police officer is aware of crimes and listen to his superior.]],
        color = Color( 31, 32, 210 ),
        weapons = {
            "weapon_pistol",
            "weapon_smg1",
        },
        models = {
            "models/player/police.mdl",
            "models/player/police_fem.mdl",
        },
        salary = VRP.JobDefaultSalary * 1.5,
        max = .25, --  25% of max player
        cmd = "police",
        custom_check = function( ply )
            return ply:FlashlightIsOn(), "Get your flashlight on!"
        end,
        player_spawn = function( ply )
            ply:GiveAmmo( 250, "pistol", false )
            ply:GiveAmmo( 500, "smg1", false )
        end,
        player_death = function( ply )
            ply:ChangeJob( TEAM_CITIZEN )
        end,
    } )

    VRP.JobDefault = TEAM_CITIZEN
end )

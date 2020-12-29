
hook.Add( "VRP:LoadCustomItems", "VRP:Jobs", function()
    TEAM_CITIZEN = VRP.CreateJob( "Citizen", {
        description = [[Basic citizen]],
        color = Color( 31, 180, 32 ),
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
        color = Color( 61, 62, 210 ),
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
        ammos = {
            ["pistol"] = 250,
            ["smg1"] = 500,
        },
        custom_check = function( ply )
            return ply:FlashlightIsOn(), "Get your flashlight on!"
        end,
        player_spawn = function( ply )
            ply:SetArmor( 25 )
        end,
    } )

    TEAM_CHIEF = VRP.CreateJob( "Police Chief", {
        description = [[Police chief organize his officers in order to maintain security.]],
        color = Color( 61, 62, 210 ),
        weapons = {
            "weapon_357",
            "weapon_smg1",
        },
        models = {
            "models/player/combine_soldier.mdl",
            "models/player/combine_soldier_prisonguard.mdl",
        },
        salary = VRP.JobDefaultSalary * 2,
        max = 1,
        cmd = "chief",
        ammos = {
            ["357"] = 250,
            ["smg1"] = 500,
        },
        custom_check = function( ply )
            return ply:Team() == TEAM_POLICE, "You must be an officer before being the chief!"
        end,
        player_spawn = function( ply )
            ply:SetArmor( 50 )
        end,
        player_death = function( ply )
            ply:SetJob( TEAM_POLICE )
        end,
    } )

    TEAM_MEDIC = VRP.CreateJob( "Medic", {
        description = [[Medic heals people in need.]],
        color = Color( 61, 210, 62 ),
        weapons = {
            "weapon_medkit",
        },
        models = {
            "models/player/Group03m/female_01.mdl",
            "models/player/Group03m/female_02.mdl",
            "models/player/Group03m/female_03.mdl",
            "models/player/Group03m/female_04.mdl",
            "models/player/Group03m/female_05.mdl",
            "models/player/Group03m/female_06.mdl",
            "models/player/Group03m/male_01.mdl",
            "models/player/Group03m/male_02.mdl",
            "models/player/Group03m/male_03.mdl",
            "models/player/Group03m/male_04.mdl",
            "models/player/Group03m/male_05.mdl",
            "models/player/Group03m/male_06.mdl",
            "models/player/Group03m/male_07.mdl",
            "models/player/Group03m/male_08.mdl",
            "models/player/Group03m/male_09.mdl",
        },
        salary = VRP.JobDefaultSalary * 1.5,
        max = .25,
    } )

    VRP.JobDefault = TEAM_CITIZEN
end )

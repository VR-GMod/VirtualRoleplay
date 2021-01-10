hook.Add( "VRP:LoadCustomItems", "VRP:Weapons", function()
    VRP.CreateMarketItem( {
        category = "Weapons",
        name = "9mm Pistol",
        class = "weapon_pistol",
        price = 10,
        description = "9mm gun used by the masters of law."
    } )

    VRP.CreateMarketItem( {
        category = "Weapons",
        name = ".357 Magnum",
        class = "weapon_357",
        price = 40,
        description = "6 shots to kill them all."
    } )

    VRP.CreateMarketItem( {
        category = "Entities",
        type = "entity",
        name = "Health Kit",
        class = "item_healthkit",
        price = 60,
        description = "Emergency health kit."
    } )
end )
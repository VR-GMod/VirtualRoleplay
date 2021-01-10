VRP.Market = VRP.Market or {}

function VRP.CreateMarketItem( tbl )
    assert( tbl.class, ( "VRP: Can't create item with no class." ):format( tbl.name or "Unknown" ), 2 )

    --  Completion
    tbl.id = #VRP.Market + 1
    tbl.description = tbl.description or "It smells like nothing at all"
    tbl.type = tbl.type or "weapon"
    tbl.class = tbl.class
    tbl.name = tbl.name or tbl.class
    tbl.price = tbl.price or 0
    tbl.category = tbl.category or "Items"
    tbl.model = tbl.model or "models/Items/item_item_crate.mdl"

    MsgC( color_white, ( "\tMarket item: %s (ID: %d)\n" ):format( tbl.name, tbl.id ) )

    --  register
    VRP.Market[tbl.id] = tbl

    return tbl.id
end
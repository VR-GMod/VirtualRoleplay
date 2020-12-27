
function VRP.SQLInit()
    return sql.Query( "CREATE TABLE IF NOT EXISTS vrp_player_data( SteamID TEXT, RPName TEXT, Money INTEGER )" )
end

function VRP.SQLNewPlayer( ply )
    local steamid = SQLStr( isstring( ply ) and ply or ply:SteamID() )
    return sql.Query( ( "INSERT INTO vrp_player_data VALUES( %s, %s, %d )" ):format( steamid, SQLStr( ply:GetName() ), ply:GetMoney() ) )
end

function VRP.SQLUpdate( ply, key, value )
    local steamid = SQLStr( isstring( ply ) and ply or ply:SteamID() )
    return sql.Query( ( "UPDATE vrp_player_data SET %s = %s WHERE SteamID = %s" ):format( key, value, steamid ) )
end

function VRP.SQLGetAll( ply )
    local steamid = SQLStr( isstring( ply ) and ply or ply:SteamID() )
    return sql.Query( ( "SELECT * FROM vrp_player_data WHERE SteamID = %s" ):format( steamid ) )
end

util.AddNetworkString( "VRP:F4" )

function GM:ShowSpare2( ply )
    net.Start( "VRP:F4" )
    net.Send( ply )
end
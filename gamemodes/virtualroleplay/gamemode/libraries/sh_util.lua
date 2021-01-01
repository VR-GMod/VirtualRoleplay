
function VRP.Format( text, params )
    return text:gsub( "%${([%w_%d]+)}", function( str )
        return params[str:Trim()] or "?"
    end )
end

function VRP.UpFirstLetter( text )
    return text:sub( 1, 1 ):upper() .. text:sub( 2 )
end

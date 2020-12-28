
function VRP.Format( text, params )
    return text:gsub( "%${([%w_%d]+)}", function( str )
        return params[str:Trim()] or "?"
    end )
end

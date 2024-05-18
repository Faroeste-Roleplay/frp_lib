resource = { }

local RESOURCE_NAME = GetCurrentResourceName()

function resource:getThisResourceName()
    return RESOURCE_NAME
end
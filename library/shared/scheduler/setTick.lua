scheduler = { }

---@alias SetTickCookie fun()

---@param fn fun()
---@return SetTickCookie
function scheduler:setTick(fn)
    local tick = true

    local function endTick()
        tick = false
    end

    CreateThread(function()
        while tick do
            fn()

            Wait(0)
        end
    end)

    return endTick
end

---@param endTick SetTickCookie
function scheduler:clearTick(endTick)
    endTick()
end
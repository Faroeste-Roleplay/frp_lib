--[[ PromptBuilderChain ]]

local eModes = { ['Standard'] = true, ['Hold'] = true, ['AutoFill'] = true }

local PromptBuilderChain = { }

function PromptBuilderChain:setControl(controlHashLike, secondControlHashLike)
    -- TODO: Aceitar strings!

    PromptSetControlAction(self.promptId, controlHashLike)

    if secondControlHashLike then
        PromptSetControlAction(self.promptId, secondControlHashLike)
    end
    
    return self
end

function PromptBuilderChain:setText(text)
    PromptSetText(self.promptId, type(text) == 'number' and text or CreateVarString(10, 'LITERAL_STRING', text))
    
    return self
end

function PromptBuilderChain:setVisible(visible)
    PromptSetVisible(self.promptId, visible)
    
    return self
end

--- @param mode 'Standard'|'Hold'
function PromptBuilderChain:setMode(mode, ... --[[ params ]])

    assert(eModes[mode], ('Mode `%s` não é valido, modes validos: %s'):format(mode, json.encode(eModes)) )

    if mode == 'Standard' then
        -- UiPromptSetPressedTimedMode(self.promptId, 10)
    end

    if mode == 'Hold' then
        PromptSetHoldMode(self.promptId, ...)
    end

    if mode == 'AutoFill' then
        PromptSetHoldMode(self.promptId, ...)
        PromptSetHoldAutoFillMode(self.promptId, ...)
    end
    
    return self
end

function PromptBuilderChain:setGroup(groupHash)
    PromptSetGroup(self.promptId, groupHash, 0)
    
    return self
end

function PromptBuilderChain:setPoint(point)
    -- UiPromptContextSetPoint
    Citizen.InvokeNative(0xAE84C5EE2C384FB3, self.promptId, point.x, point.y, point.z)
    
    return self
end

function PromptBuilderChain:setRadius(radius)
    -- UiPromptContextSetRadius
    N_0x0c718001b77ca468(self.promptId, radius)
    
    return self
end

function PromptBuilderChain:setVolume(volume)
    -- UiPromptContextSetVolume
    N_0x4d107406667423be(self.promptId, volume)
    
    return self
end
function PromptBuilderChain:setEnabled(bool)
    PromptSetEnabled(self.promptId, bool)

    return self
end


function PromptBuilderChain:build()
    PromptRegisterEnd(self.promptId)

    return self.promptId
end

--[[ Globals ]]

local gResourcePrompts = { }

--[[ PromptBuilder ]]

PromptBuilder = { }

function PromptBuilder:new()
    local promptId = PromptRegisterBegin()

    -- PromptSetControlAction(promptId, `INPUT_ATTACK`)
    PromptSetText(promptId, CreateVarString(10, "LITERAL_STRING", ('Sem nome %d'):format(promptId)))
    PromptSetEnabled(promptId, true)
    PromptSetVisible(promptId, true)
    PromptSetStandardMode(promptId, 0)

    gResourcePrompts[promptId] = true

    return setmetatable({ promptId = promptId }, { __index = PromptBuilderChain })
end

--

local origPromptDelete = PromptDelete

--[[ Garantir que o prompt seja removido da pool caso seja deletado por native ]]
function PromptDelete(id)
    if id then
        origPromptDelete(id)

        gResourcePrompts[id] = nil
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for promptId, _ in pairs(gResourcePrompts) do
            print('Deleted prompt', promptId)
            origPromptDelete(promptId)
        end
    end
end)
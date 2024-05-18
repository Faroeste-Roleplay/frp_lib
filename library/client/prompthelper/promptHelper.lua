promptHelper = { }

---@param promptId number
---@param disableMsOnComplete? number
function promptHelper:hasPromptHoldModeCompleted(promptId, disableMsOnComplete)
    
    if not PromptHasHoldModeCompleted(promptId) then
        return false
    end

    --[[ Aguardar um tick para caso a seja tenha desabilitado o prompt no tick anterior! ]]
    Wait(0)

    if not PromptIsEnabled(promptId) then
        return false
    end

    PromptSetEnabled(promptId, false)

    --[[ Desabilitar todos os controls por um frame para forçar que o prompt fique desativado! ]]
    DisableAllControlActions(0)

    SetTimeout(disableMsOnComplete or 1000, function()
        PromptSetEnabled(promptId, true)
    end)

    return true
end
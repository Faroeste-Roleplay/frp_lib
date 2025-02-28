local CONST_DRAG_SPEED = 10.0
local CONST_ZOOM_SPEED = 0.2
local CONST_POSITION_SPEED = 0.2

local gHandle = nil

local function MainControllablePedCamLoop()
    -- DisableAllControlActions(0)

    EnableControlAction(0, `INPUT_ATTACK`, true)
    EnableControlAction(0, `INPUT_LOOK_LR`, true)
    EnableControlAction(0, `INPUT_LOOK_UD`, true)
    EnableControlAction(0, `INPUT_CURSOR_SCROLL_UP`, true)
    EnableControlAction(0, `INPUT_CURSOR_SCROLL_DOWN`, true)

    if IsDisabledControlPressed(0, `INPUT_ATTACK`) then
        local normals = vector2(
            GetDisabledControlNormal(0, `INPUT_LOOK_LR`),
            GetDisabledControlNormal(0, `INPUT_LOOK_UD`)
        )

        AddPedCamAngleX(CONST_DRAG_SPEED * normals.x)
        -- AddPedCamAngleY(CONST_DRAG_SPEED * normals.y)
        AddPedCamPositionZ(CONST_POSITION_SPEED * normals.y)
    end

    if IsDisabledControlPressed(0, `INPUT_CURSOR_SCROLL_UP`) or IsDisabledControlPressed(0, `INPUT_CURSOR_SCROLL_DOWN`) then
        local normals = vector2(
            -GetDisabledControlNormal(0, `INPUT_CURSOR_SCROLL_UP`),
            GetDisabledControlNormal(0, `INPUT_CURSOR_SCROLL_DOWN`)
        )

        local distanceToLookAtPos = GetPedCamDistanceToLookAtPos()

        distanceToLookAtPos += CONST_ZOOM_SPEED * normals.x
        distanceToLookAtPos += CONST_ZOOM_SPEED * normals.y
        
        SetPedCamDistanceToLookAtPos(distanceToLookAtPos)
    end
end

local function ShouldControllablePedCamLoopRun(handle)
    return gHandle == handle
end

function EnableControllablePedCam()
    local handle = EnablePedCam()
    
    gHandle = handle

    local helperPromptId = PromptBuilder:new()
                    :setControl(`INPUT_ATTACK`)
                    :setText('Mover Camera')
                    :setMode('Standard')
                    :build()

    -- print( ('ControllablePedCam(%d) : Enable'):format(gHandle))

    CreateThread(function()
        while ShouldControllablePedCamLoopRun(handle) do
            MainControllablePedCamLoop()

            Wait(0)
        end

        PromptDelete(helperPromptId)

        helperPromptId = nil

        -- print( ('ControllablePedCam(%d) : MainLoop stopped'):format(gHandle))
    end)
end

function DisableControllablePedCam(immediately)
    -- print( ('ControllablePedCam(%d) : Disable'):format(gHandle))

    gHandle = nil

    DisablePedCam(immediately)
end
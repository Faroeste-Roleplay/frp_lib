local CONST_DRAG_SPEED = 10.0
local CONST_ZOOM_SPEED = 5.0

local gHandle = nil

local function MainControllableOrbitalCamLoop()
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

        AddOrbitalCamAngleX(CONST_DRAG_SPEED * normals.x)
        AddOrbitalCamAngleY(CONST_DRAG_SPEED * normals.y)
    end

    if IsDisabledControlPressed(0, `INPUT_CURSOR_SCROLL_UP`) or IsDisabledControlPressed(0, `INPUT_CURSOR_SCROLL_DOWN`) then
        local normals = vector2(
            -GetDisabledControlNormal(0, `INPUT_CURSOR_SCROLL_UP`),
            GetDisabledControlNormal(0, `INPUT_CURSOR_SCROLL_DOWN`)
        )

        local distanceToLookAtPos = GetOrbitalCamDistanceToLookAtPos()

        distanceToLookAtPos += CONST_ZOOM_SPEED * normals.x
        distanceToLookAtPos += CONST_ZOOM_SPEED * normals.y
        
        SetOrbitalCamDistanceToLookAtPos(distanceToLookAtPos)
    end
end

local function ShouldControllableOrbitalCamLoopRun(handle)
    return gHandle == handle
end

function EnableControllableOrbitalCam()
    local handle = EnableOrbitalCam()
    
    gHandle = handle

    local helperPromptId = PromptBuilder:new()
                    :setControl(`INPUT_ATTACK`)
                    :setText('Mover Camera')
                    :setMode('Standard')
                    :build()

    -- print( ('ControllableOrbitalCam(%d) : Enable'):format(gHandle))

    CreateThread(function()
        while ShouldControllableOrbitalCamLoopRun(handle) do
            MainControllableOrbitalCamLoop()

            Wait(0)
        end

        PromptDelete(helperPromptId)

        helperPromptId = nil

        -- print( ('ControllableOrbitalCam(%d) : MainLoop stopped'):format(gHandle))
    end)
end

function DisableControllableOrbitalCam(immediately)
    -- print( ('ControllableOrbitalCam(%d) : Disable'):format(gHandle))

    gHandle = nil

    DisableOrbitalCam(immediately)
end
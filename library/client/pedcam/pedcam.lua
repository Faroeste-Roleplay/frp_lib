local CONST_POSITION_SMOOTHING_FACTOR = 5.0

local gHandle = nil

local gFreeHandle = 1

local gLookAtPosition = nil

local gDistanceToLookAtPos = nil

local gMinDistanceToLookAtPos = nil
local gMaxDistanceToLookAtPos = nil

local gAngleX = nil
local gAngleY = nil
local gPositionZ = nil

local gCamId = nil

local gDisablingPromise = nil

function GetPedCamLookAtPosition()
    return gLookAtPosition
end

function SetPedCamLookAtPosition(position)
    gLookAtPosition = position
end

function GetPedCamDistanceToLookAtPos()
    return gDistanceToLookAtPos
end

function SetPedCamDistanceToLookAtPos(distance)
    gDistanceToLookAtPos = distance
end

function GetPedCamMinDistanceToLookAtPos()
    return gMinDistanceToLookAtPos
end

function SetPedCamMinDistanceToLookAtPos(minDistance)
    gMinDistanceToLookAtPos = minDistance
end

function GetPedCamMaxDistanceToLookAtPos()
    return gMaxDistanceToLookAtPos
end

function SetPedCamMaxDistanceToLookAtPos(maxDistance)
    gMaxDistanceToLookAtPos = maxDistance
end

function GetPedCamAngleX()
    return gAngleX
end

function SetPedCamAngleX(angle, disableInterpolation)
    if angle then
        angle = angle % 360

        if angle < 0 then
            angle += 360
        end
    end

    -- print(" gAngleX :: ", angle)

    gAngleX = angle
end

function AddPedCamAngleX(addAngle, disableInterpolation)
    SetPedCamAngleX(GetPedCamAngleX() + addAngle, disableInterpolation)
end

function GetPedCamAngleY()
    return gAngleY
end



local MIN_ANGLE_Y = -5   -- Ângulo mínimo (olhar reto)
local MAX_ANGLE_Y = 5 -- Ângulo máximo (olhar para cima)

function SetPedCamAngleY(angle, disableInterpolation)
    if angle then
        -- Restringe o ângulo dentro dos limites 0° a 45°
        angle = math.max(MIN_ANGLE_Y, math.min(MAX_ANGLE_Y, angle))
    end

    -- print("gAngleY :: ", angle)

    gAngleY = 0
end

function AddPedCamAngleY(addAngle, disableInterpolation)
    SetPedCamAngleY(GetPedCamAngleY() + addAngle, disableInterpolation)
end

function GetPedCamPositionZ()
    return gPositionZ or 0
end


local MIN_POSITION_Z = -1   -- Ângulo mínimo (olhar reto)
local MAX_POSITION_Z = 1 -- Ângulo máximo (olhar para cima)

function SetPedCamPositionZ(posZ, disableInterpolation)
    if posZ then
        -- Restringe o ângulo dentro dos limites 0° a 45°
        posZ = math.max(MIN_POSITION_Z, math.min(MAX_POSITION_Z, posZ))
    end

    gPositionZ = posZ
end

function AddPedCamPositionZ(addAngle, disableInterpolation)
    SetPedCamPositionZ(GetPedCamPositionZ() + addAngle, disableInterpolation)
end

function GetPedCamId()
    return gCamId
end

function IsPedCamCreated()
    return GetPedCamId() ~= nil
end

local function CreateOrbitCam(position, lookAtPosition)
    local camId = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)

    SetCamCoord(camId, position.x, position.y, position.z)

    PointCamAtCoord(camId, lookAtPosition.x, lookAtPosition.y, lookAtPosition.z)

    SetCamFov(camId, 30.0)
    -- SetCamNearDof(camId, 0.5)

    SetCamActiveWithInterp(camId, GetRenderingCam(), 500, true, true)

    RenderScriptCams(true, true, 500, false, false)

    gCamId = camId
end

local function DestroyOrbitCam(interpolateToCamId)
    if not IsPedCamCreated() then
        return false
    end

    local camId = GetPedCamId()

    local interpolateToGameplayCam = interpolateToCamId == nil

    if interpolateToGameplayCam then
        RenderScriptCams(false, true, 1000, true, true)
    else
        SetCamActiveWithInterp(interpolateToCamId, camId, 1000, true, true)
    end

    DestroyCam(camId, false)

    gCamId = nil

    return true
end

local function GetCollisionBetweenPoints(pointFrom, pointTo, flags)
    -- StartExpensiveSynchronousShapeTestLosProbe
    local handle = Citizen.InvokeNative(0x377906D8A31E5586, pointFrom.x, pointFrom.y, pointFrom.z, pointTo.x, pointTo.y, pointTo.z, flags, 0, 7)

    local _, hit, hitPos = GetShapeTestResult(handle)

    return hit == 1, hitPos
end

require('glm')

local function MainPedCamLoop()
    local lookAtPosition = GetPedCamLookAtPosition()

    local distanceToLookAtPosition = GetPedCamDistanceToLookAtPos()

    local minDistanceLookAtPos = GetPedCamMinDistanceToLookAtPos()
    local maxDistanceLookAtPos = GetPedCamMaxDistanceToLookAtPos()

    local angleX = GetPedCamAngleX()
    local angleY = GetPedCamAngleY()

    local positionZ = GetPedCamPositionZ()

    distanceToLookAtPosition = math.max(distanceToLookAtPosition, minDistanceLookAtPos)
    distanceToLookAtPosition = math.min(distanceToLookAtPosition, maxDistanceLookAtPos)

    lookAtPosition = vec3(lookAtPosition.x ,lookAtPosition.y, lookAtPosition.z - positionZ )

    --[[ logic ]]

    local ft = GetFrameTime()

    --[[ Rotação a partir do angulo X e Y ]]
    local rotation = glm.quatEulerAngleZXY(glm.rad(-(angleX)), glm.rad(-(angleY)), 0.0)

    --[[ Direção a partir da rotação ]]
    local direction = rotation * glm.forward()

    --[[ Posição da camera, matendo X unidades de distancia do local de foco ]]
    local position = lookAtPosition - direction * distanceToLookAtPosition

    --[[
        A gente vai gerar uma nova lookAtPosition caso aconteça uma colisão com um ped ou veículo
        da uma efeito de 'profundidade' para a camera
    --]]
    do
        local shapetestStart = position
        local shapetestEnd   = lookAtPosition

        --[[ Ignorar peds, porque a gente geralmente tá usando a orbitcam em ]]
        local collides, collisionPos = GetCollisionBetweenPoints(shapetestStart, shapetestEnd, 4294967295 & ~(2 | 4 | 8) --[[ Peds ]])

        if collides then
            position = collisionPos - direction * distanceToLookAtPosition
        end
    end

    --[[
        Colisão entre o local de foco(principalmente caso ele mude) e a nova posição da camera
        - é util para que a camera não atravesse paredes que estejam atrás delas
    --]]
    do
        local shapetestStart = lookAtPosition
        local shapetestEnd   =position

        local collides, collisionPos = GetCollisionBetweenPoints(shapetestStart, shapetestEnd, 1 | 16)

        if collides then
            position = collisionPos
        end
    end

    --[[ A ultima coordenada real sempre tem que vir por ultimo, para a gente poder interpolar ]]
    if IsPedCamCreated() then
        --[[ Interpolar a partir da posição atual da camera, caso ela exista. ]]
        position = glm.lerp(GetCamCoord(GetPedCamId()), position, CONST_POSITION_SMOOTHING_FACTOR * ft)
    end

    --[[ state updates ]]

    SetPedCamDistanceToLookAtPos(distanceToLookAtPosition)

    --[[ game updates ]]

    if not IsPedCamCreated() then
        --[[ Criar a camera caso ela não exista ]]
        CreateOrbitCam(position, lookAtPosition)
    end

    local camId = GetPedCamId()

    --[[ Não mudar a posição e rotação da camera enquanto ela estiver interpolando ]]
    if not IsCamInterpolating(camId) then
        SetCamCoord(camId, position.x, position.y, position.z )

        PointCamAtCoord(camId, lookAtPosition.x, lookAtPosition.y, lookAtPosition.z )
    end

    -- print('cam rot', GetCamRot(GetPedCamId(), 2))

    -- You have to run this function every frame (while you want DOF for your camera) otherwise it wont work
    -- SetUseHiDof()
end

local function ShouldPedCamLoopRun(handle)
    return gHandle
end

local function CleanUpPedCam(interpolateToCamId)
    -- print( ('PedCam : Cleanup') )

    SetPedCamLookAtPosition(nil)

    SetPedCamDistanceToLookAtPos(nil)

    SetPedCamMinDistanceToLookAtPos(nil)
    SetPedCamMaxDistanceToLookAtPos(nil)

    SetPedCamAngleX(nil)
    SetPedCamAngleY(nil)
    
    DestroyOrbitCam(interpolateToCamId)

    if gDisablingPromise then
        -- print( ('PedCam : Cleanup resolving') )

        gDisablingPromise:resolve()
    end
end

function EnablePedCam()
    local handle = gFreeHandle

    gFreeHandle += 1

    --[[ Caso já esteja desabilitando uma camera, vamos aguardar! ]]
    if gDisablingPromise then

        -- print( ('PedCam : Enable waiting on disable') )

        Citizen.Await(gDisablingPromise)
    end

    gHandle = handle

    local renderingCamId  = IsGameplayCamRendering() and nil or GetRenderingCam()
    local renderingCamPos = GetFinalRenderedCamCoord()

    local baseLookAtPosition = GetEntityCoords(PlayerPedId()) --[[ Onde a camera de gameplay tá olhando ]]

    local baseDistanceToLookAtPos = 5.0 --[[ A distancia da camera de gameplay para o local que ela está olhando ]]

    local baseMinDistanceLookAtPos = 3.0 --[[ A ]]
    local baseMaxDistanceLookAtPos = 7.0 --[[ B ]]

    SetPedCamLookAtPosition(GetPedCamLookAtPosition() or baseLookAtPosition)

    SetPedCamDistanceToLookAtPos(GetPedCamDistanceToLookAtPos() or baseDistanceToLookAtPos)

    SetPedCamMinDistanceToLookAtPos(GetPedCamMinDistanceToLookAtPos() or baseMinDistanceLookAtPos)
    SetPedCamMaxDistanceToLookAtPos(GetPedCamMaxDistanceToLookAtPos() or baseMaxDistanceLookAtPos)

    local lookAtPosition = GetPedCamLookAtPosition()

    local baseAngleX = math.deg(math.atan(lookAtPosition.x - renderingCamPos.x, lookAtPosition.y - renderingCamPos.y))
    local baseAngleY = 0.0

    -- print(" baseAngleX :: ", baseAngleX)
    -- print(" baseAngleY :: ", baseAngleY)

    SetPedCamAngleX(GetPedCamAngleX() or baseAngleX, false)
    SetPedCamAngleY(GetPedCamAngleY() or baseAngleY, false)
    SetPedCamPositionZ(GetPedCamPositionZ() or baseAngleY, false)
    
    -- print( ('PedCam : Enable') )

    CreateThread(function()

        while ShouldPedCamLoopRun(handle) do
            MainPedCamLoop()

            Wait(0)
        end

        -- print( ('PedCam : MainLoop stopped') )

        CleanUpPedCam(renderingCamId)
    end)

    return handle
end

function DisablePedCam(immediately)
    -- print( ('PedCam( : Disable') )

    local p = promise.new()

    gDisablingPromise = p

    gHandle = nil

    if immediately then
        CleanUpPedCam(nil)
    end

    -- print( ('PedCam : Waiting disable promise') )

    Citizen.Await(p)

    -- print( ('PedCam : Disable promise resolved') )
end
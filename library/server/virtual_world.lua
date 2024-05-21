local VirtualWorlds = {}
local Players = {}

local VirtualWorld = {}
Proxy.addInterface("virtual_world", VirtualWorld)

local globalWorldId = 0

function VirtualWorld:Create( this, players )
    local virtualWorldId = #VirtualWorlds

    local virtualWorld = {
        id = virtualWorldId,
        players = players,
    }

    for _, playerId in pairs( players ) do 

        if Players[playerId] then
            VirtualWorld:RemovePlayerFromVirtualWorld( playerId )
        end
        SetPlayerRoutingBucket(playerId, virtualWorldId)
        Players[playerId] = virtualWorldId
    end

    table.insert(VirtualWorlds, virtualWorld)

    return virtualWorld
end

function VirtualWorld:IsValidWorld( this, virtualWorldId )
    return VirtualWorlds[virtualWorldId] ~= nil
end

function VirtualWorld:DeleteWorld( this, virtualWorldId )
    local virtualWorld = VirtualWorlds[virtualWorldId]

    if not virtualWorld then
        return
    end

    for _, playerId in pairs( virtualWorld.players ) do
        VirtualWorld:AddPlayerToGlobalWorld( playerId )
    end

    VirtualWorlds[virtualWorldId] = nil
end

function VirtualWorld:AddPlayerToGlobalWorld( this, playerId )
    VirtualWorld:RemovePlayerFromVirtualWorld( playerId )
    SetPlayerRoutingBucket( playerId, globalWorldId )
end

function VirtualWorld:AddPlayerOnVirtualWorld( this, playerId, virtualWorldId )
    local virtualWorld = VirtualWorlds[virtualWorldId]
    local playerOnVirtualWorld = VirtualWorld:GetPlayerVirtualWorld( playerId )

    if not virtualWorld then
        return VirtualWorld:Create( { playerId })
    end

    if playerOnVirtualWorld then
        VirtualWorld:RemovePlayerFromVirtualWorld( playerId )
    end

    SetPlayerRoutingBucket(playerId, virtualWorldId)
    Players[playerId] = virtualWorldId
    table.insert(virtualWorld.players, playerId)
end

function VirtualWorld:RemovePlayerFromVirtualWorld( this, playerId )
    local playerVirtualWorld = VirtualWorld:GetPlayerVirtualWorld( playerId )

    if not playerVirtualWorld then
        return
    end

    for _, pId in pairs(playerVirtualWorld.players) do 
        if playerId == pId then
            playerVirtualWorld[_] = nil
            Players[playerId] = nil
        end
    end
end

function VirtualWorld:GetPlayerVirtualWorld( this, playerId )
    local playerVirtualWorldId = Players[playerId]
    local virtualWorld = VirtualWorlds[playerVirtualWorldId]
    
    if not virtualWorld then
        return nil
    end

    return virtualWorld
end

function VirtualWorld:GetPlayersFromVirtualWorld( this, virtualWorldId )
    local virtualWorld = VirtualWorlds[virtualWorldId]
    
    if not virtualWorld then
        return {}
    end

    return virtualWorld.players
end
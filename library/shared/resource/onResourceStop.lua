local onCurrentResourceStopped = scrEvent.new()

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == resource:getThisResourceName() then
        onCurrentResourceStopped()

        onCurrentResourceStopped:reset()
    end
end)

lum.onCurrentResourceStopped = onCurrentResourceStopped
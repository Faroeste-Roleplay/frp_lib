IS_FXSERVER = GetGameName() == 'fxserver'
IS_GAME = not IS_FXSERVER

link '@frp_lib/library/shared/lum.lua'

link '@frp_lib/library/shared/log/logger.lua'
link '@frp_lib/library/shared/log/logger.instance.lua'

link '@frp_lib/library/shared/screvent/screvent.lua'

link '@frp_lib/library/shared/scheduler/setTick.lua'

link '@frp_lib/library/shared/resource/resource.lua'
link '@frp_lib/library/shared/resource/onResourceStop.lua'
link '@frp_lib/library/shared/enum/code.lua'

link '@frp_lib/lib/table.lua'
link '@frp_lib/lib/string.lua'

link '@frp_lib/lib/utils.lua'
link '@frp_lib/lib/i18n.lua'
link '@frp_lib/lib/deferalsCard.lua'
link '@frp_lib/lib/dataview.lua'

link '@frp_lib/library/shared/random/code.lua'

if IS_GAME then
    link '@frp_lib/library/client/prompt_builder.lua'
    link '@frp_lib/library/client/progressbar/code.lua'
    link '@frp_lib/library/client/prompthelper/promptHelper.lua'

    useOrbitalCam             = lazyLink '@frp_lib/library/client/orbitalcam/orbitalcam.lua'
    useControllableOrbitalCam = lazyLink '@frp_lib/library/client/orbitalcam/controllable_orbitalcam.lua'

    usePedCam             = lazyLink '@frp_lib/library/client/pedcam/pedcam.lua'
    useControllablePedCam = lazyLink '@frp_lib/library/client/pedcam/controllable_pedcam.lua'
end

if IS_FXSERVER then
    link '@frp_lib/library/server/logger_datadog_transport.lua'
end
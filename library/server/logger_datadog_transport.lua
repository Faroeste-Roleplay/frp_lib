local KEY = GetConvar('datadog:key', '')
local URL = ('https://http-intake.logs.%s/api/v2/logs'):format(GetConvar('datadog:site', 'datadoghq.com'))

logger:add({
    log = function(info)
        info.hostname = 'TESTE'
        info.service = info.service or 'fxserver'

        local function cb(errorCode, resultData, resultHeaders)
            if errorCode ~= 202 then
                print(('unable to submit logs to %s (%s) (%s) (%s)'):format(URL, errorCode, tostring(resultData), tostring(resultHeaders)))
            end
        end

        if KEY == '' then
            error('Datadog é vazio')
        end

        PerformHttpRequest(URL, cb, 'POST', json.encode(info),
        {
            ['Content-Type'] = 'application/json',
            ['DD-API-KEY'] = KEY
        })
    end
})
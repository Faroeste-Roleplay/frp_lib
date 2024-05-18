---@type eLogLevel 'error'|'warn'|'info'|'http'|'verbose'|'debug'|'silly'

loggerMT = { }

function loggerMT.new(metadata)
    local self =
    {
        transports = { }
    }

    for key, value in pairs(metadata or { }) do
        self[key] = value
    end

    return setmetatable(self, { __index = loggerMT })
end

function loggerMT:_extractLogMetadata(info, args)
    local metadata = { }

    for key, value in pairs(args) do
        if type(value) == 'table' then
            info[key] = value
            args[key] = nil
        end
    end

    return metadata
end

function loggerMT:_extractLogMessage(info, args)
    for i, arg in ipairs(args) do
        args[i] = tostring(arg or '')
    end

    local message = table.concat(args, '    ')

    info.message = message

    return message
end

---@param level eLogLevel
---@vararg any|any[] - VarArg, vai fazer parte da mensagem de log
function loggerMT:log(level, ...)
    level = level or 'log'

    local dbginfo = debug.getinfo(3, 'Sl')

    assert(dbginfo)

    local path = string.match(dbginfo.short_src, '/(.+).lua' )

    local args = { ... }

    local info =
    {
        level = level,
        --[[ ISO8601 ]]
        timestamp = os and os.date('!%Y-%m-%dT%H:%M:%SZ') or GetGameTimer(),
    }

    for key, value in pairs(self) do
        info[key] = value
    end

    --[[ Remover os transports ]]
    info.transports = nil

    self:_extractLogMetadata(info, args)

    local message = self:_extractLogMessage(info, args)

    for _, transport in ipairs(self.transports) do
        if transport.log then
            transport.log(info)
        end
    end

    print( ('^2%s ^5(@%s/%s.lua) ^7: %s'):format(level:upper(), GetCurrentResourceName(), path, message) )
end

function loggerMT:info(...)
    self:log('info', ...)
end

function loggerMT:debug(...)
    self:log('debug', ...)
end

function loggerMT:error(...)
    self:log('error', ...)
end

function loggerMT:child(metadataOverride)
    local child = loggerMT.new(self)

    for key, value in pairs(metadataOverride or { }) do
        child[key] = value
    end

    return child
end

function loggerMT:add(transport)
    table.insert(self.transports, transport)
end
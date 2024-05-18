local IMPORTER_RESOURCE_NAME = GetCurrentResourceName()

---@diagnostic disable-next-line: lowercase-global
function link(scriptFilePath)
    local resourceName, resourceScriptPath = scriptFilePath:match('@(.-)/(.+)')

    assert(resourceName, 'resourceName invalid')
    assert(resourceScriptPath, 'resourceScriptPath invalid')

    local status, err = pcall(function()
        return LoadResourceFile(resourceName, resourceScriptPath)
    end)

    local chunkName = scriptFilePath

    if not status then
        error( ('Arquivo inexistente "%s" error: %s'):format(chunkName, err) )
    end

    local contents = err

    if contents == nil then
        error( ('Arquivo "%s" não pode ser vazio.'):format(chunkName) )
    end

    local chunkFn, errMsg = load(contents, chunkName)

    if errMsg then
        error( ('Error importando arquivo %s : %s'):format(chunkName, errMsg) )
    end

    local chunkRef = chunkFn()
end

---@diagnostic disable-next-line: lowercase-global
function lazyLink(scriptFilePath)
    return setmetatable({ },
    {
        __linked = false,

        __call = function (self)
            local mt = getmetatable(self)
            
            if mt.__linked then
                error( ('Already linked "%s"'):format(scriptFilePath) )
            end

            link(scriptFilePath)

            mt.__linked = true
        end
    })
end

link '@frp_lib/library/bootstrap.lua'
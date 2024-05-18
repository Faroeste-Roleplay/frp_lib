scrEvent = { }

function scrEvent.new()
    return setmetatable({
        callbacks = nil,
        connectCookie = 0,
    },
    {
        __index = scrEvent,
        __call = scrEvent.invoke,
    })
end

local function assert_self(self)
    if not self then
        error('Metodos de instancias do scrEvent precisam ser acessados `:`')
    end 
end

function scrEvent:disconnect(cookie)
    assert_self(self)

    if cookie == -1 then
        return
    end

    local prev = nil

    local cb = self.callbacks

    while cb do

        if cb.cookie == cookie then
            if prev then
                prev.next = cb.next
            else
                self.callbacks = cb.next
            end

            break
        end

        prev = cb

        cb = cb.next
    end
end

function scrEvent:connect(cb, order)
    assert_self(self)

    order = order or 0

    self.connectCookie = self.connectCookie + 1

    local cookie = self.connectCookie

    local cb = { func = cb, next = nil, order = order, cookie = cookie }

    if not self.callbacks then
        self.callbacks = cb
    else
        local cur = self.callbacks
        local last = nil

        while cur and order >= cur.order do
            last = cur
            cur = cur.next
        end

        cb.next = cur

        if not last then
            self.callbacks = cb
        else
            last.next = cb
        end
    end

    return cookie
end

function scrEvent:connectOnce(cb, order)
    local cookie

    cookie = self:connect(function(...)
        self:disconnect(cookie)

        cb(...)
    end, order)
end

function scrEvent:invoke(...)
    assert_self(self)

    if not self.callbacks then
        return true
    end

    local next = nil

    local cb = self.callbacks

    while cb do

        local next = cb.next

        if cb.func(...) == false then
            return false
        end

        cb = next
    end

    return true
end

function scrEvent:reset()
    assert_self(self)
    
    self.callbacks = nil
end
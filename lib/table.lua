function table.filter(t, predicate)
    local filtered = { }

    local isArray = table.type(t) == 'array'
    
    for key, value in each(t) do
        if predicate(value, key) then
            if isArray then
                table.insert(filtered, value)
            else
                filtered[key] = value
            end
        end
    end

    return filtered
end

function table.map(t, predicate)
    local mapped = { }

    for index, value in each(t) do
        local newvalue = predicate(value, index, t)

        table.insert(mapped, newvalue)
    end

    return mapped
end

function table.find(t, predicate)
    for index, value in each(t) do
        if predicate(value, index) then
            return value
        end
    end

    return nil
end

function table.findIndex(t, callbackFn)
    for index, element in each(t) do
        if callbackFn(element, index, t) then
            return index
        end
    end

    return -1
end

function table.forEach(t, callbackFn)
    for index, value in ipairs(t) do
        callbackFn(value, index)
    end
end

function table.merge(t1, t2)
    return table.move(t2, 1, #t2, #t1 + 1, t1)
end

function table.deepClone(tbl)
    tbl = table.clone(tbl)
	for k, v in pairs(tbl) do
		if type(v) == 'table' then
			tbl[k] = table.deepClone(v)
		end
	end
	return tbl
end
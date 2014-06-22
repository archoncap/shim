local _ = {}

function _.isArray(t)
    if type(t) == 'table' then
        local i = 0
        for _ in pairs(t) do
            i = i + 1
            if (t[i] == nil) then
                return false
            end
        end
        return true
    end
    return false
end

function _.each(arr, fn)
    for i = 1, #arr do
        fn(arr[i], i, arr)
    end
    return arr
end

function _.map(arr, fn)
    local ret = {}
    for i = 1, #arr do
        ret[i] = fn(arr[i], i, arr)
    end
    return ret
end

function _.isEqual(a, b)
    -- won't compare metatable
    if a == b then return true end
    if type(a) == 'table' and type(b) == 'table' then
        for k, v in pairs(a) do
            if not _.isEqual(a[k], b[k]) then
                return false
            end
        end
        for k in pairs(b) do
            if a[k] == nil then
                return false
            end
        end
        return true
    else
        return a == b
    end
end

function _.has(list, item)
    local tp = type(list)
    if tp == 'string' then
        return list:find(item) ~= nil
    elseif tp == 'table' then
        for k, v in pairs(list) do
            if v == item then
                return true
            end
        end
    end
    return false
end

function _.extend(dst, ...)
    local src = {...}
    _.each(src, function(obj)
        if type(obj) == 'table' then
            for k, v in pairs(obj) do
                dst[k] = v
            end
        end
    end)
    return dst
end

function _.sort(t, fn)
    table.sort(t, fn)
    return t
end

function _.filter(arr, fn)
    local ret = {}
    _.each(arr, function(x)
        if fn(x) then
            table.insert(ret, x)
        end
    end)
    return ret
end

function call(_, val)
    local ret = {
        wrap = val
    }
    setmetatable(ret, {
        __index = function(ret, k)
            if k == 'chain' then
                return function()
                    ret._chain = true
                    return ret
                end
            elseif k == 'value' then
                return function()
                    return ret.wrap
                end
            elseif type(_[k]) == 'function' then
                return function(ret, ...)
                    local v = _[k](ret.wrap, ...)
                    if ret._chain then
                        ret.wrap = v
                        return ret
                    else
                        return v
                    end
                end
            end
        end
    })
    return ret
end

function dumpTable(o, lastIndent)
    if type(lastIndent) ~= 'string' then
        lastIndent = ''
    end
    local indent = '    ' .. lastIndent
    if #indent > 4 * 7 then
        return '[Nested]' -- may be nested, default is 7
    end
    local ret = '{\n'
    local arr = {}
    for k, v in pairs(o) do
        table.insert(arr, indent .. dump(k) .. ': ' .. dump(v, indent))
    end
    ret = ret .. table.concat(arr, ',\n') .. '\n' .. lastIndent .. '}'
    return ret
end

-- TODO multi args
function dump(v, indent)
    local t = type(v)
    if t == 'number' or t == 'boolean' then
        return tostring(v)
    elseif t == 'string' then
        return "'" .. v .. "'"
    elseif t == 'table' then
        if _.isArray(v) then
            return '[' .. table.concat(_.map(v, function(x)
                return dump(x)
            end) , ', ') .. ']'
        else
            return dumpTable(v, indent)
        end
    elseif t == 'nil' then
        return 'null'
    end
    return '[' .. t .. ']'
end

-- TODO split, reduce, ... other function

_.dump = dump

setmetatable(_, {__call = call})

return _

local _ = {}

-- Basic Util

-- is

local function isTable(val)
	return 'table' == type(val)
end

local function isNumber(val)
	return 'number' == type(val)
end

local function isString(val)
	return 'string' == type(val)
end

local function isFunction(val)
	return 'function' == type(val)
end

local function isBoolean(val)
	return 'boolean' == type(val)
end

local function isNil(val)
	return nil == val
end

local function tostr(val)
	if not isString(val) then
		if nil ~= val then
			val = tostring(val)
		end
	end
	return val or ''
end

_.isTable = isTable
_.isNumber = isNumber
_.isString = isString
_.isFunction = isFunction
_.isBoolean = isBoolean
_.isNil = isNil


-- basic each
local function each(arr, fn)
	if isTable(arr) then
		local len = #arr
		for i = 1, len do
			if false == fn(arr[i], i, arr) then
				return
			end
		end
	end
end

-- basic for in
local function forIn(obj, fn)
	if isTable(obj) then
		for key, val in pairs(obj) do
			if false == fn(val, key, obj) then
				return
			end
		end
	end
end

local function findIndex(arr, fn)
	local ret
	each(arr, function(val, i, arr)
		if fn(val, i, arr) then
			ret = i
			return false
		end
	end)
	return ret
end

_._each = each
_.forIn = forIn
_.findIndex = findIndex

-- Iteration

function _.isArray(t)
	if isTable(t) then
		local i = 0
		for _ in pairs(t) do
			i = i + 1
			if t[i] == nil then
				return false
			end
		end
		return true
	end
	return false
end

function _.negate(fn)
	return function(...)
		return not fn(...)
	end
end

function _.each(arr, fn)
	each(arr, function(...)
		fn(...)
	end)
	return arr
end

function _.every(arr, fn)
	return nil == findIndex(arr, _.negate(fn))
end

function _.some(arr, fn)
	return nil ~= findIndex(arr, fn)
end

function _.find(arr, fn)
	local i = findIndex(arr, fn)
	if i then
		return arr[i]
	end
end

function _.map(arr, fn)
	local ret = {}
	each(arr, function(x, i, arr)
		ret[i] = fn(x, i, arr)
	end)
	return ret
end

function _.isEqual(a, b)
	-- won't compare metatable
	if a == b then return true end
	if isTable(a) and isTable(b) then
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

function _.has(val, sub)
	return nil ~= _.indexOf(val, sub)
end

function _.sub(s, i, j)
	return string.sub(tostr(s), i, j)
end

function _.trim(s, where)
	s = tostr(s)
	local i = 1
	local j = #s
	if 'left' ~= where then
		-- match right space
		local a, b = _.lastIndexOf(s, '%s+')
		if b == j then
			j = a - 1
		end
	end
	if 'right' ~= where then
		-- match left space
		local a, b = _.indexOf(s, '%s+')
		if a == 1 then
			i = b + 1
		end
	end
	return _.sub(s, i, j)
end

function _.flatten(arrs)
	local ret = {}
	each(arrs, function(arr)
		if isTable(arr) then
			each(arr, function(x)
				_.push(ret, x)
			end)
		else
			_.push(ret, arr)
		end
	end)
	return ret
end

function _.push(arr, ...)
	if not isTable(arr) then return arr end
	each({...}, function(x, i)
		table.insert(arr, x)
	end)
	return arr
end

function _.uniq(arr)
	local ret = {}
	each(arr, function(x)
		if not _.has(ret, x) then
			_.push(ret, x)
		end
	end)
	return ret
end

function _.union(...)
	return _.uniq(_.flatten({...}))
end

function _.extend(dst, ...)
	if isTable(dst) then
		local src = {...}
		each(src, function(obj)
			forIn(obj, function(val, key)
				dst[key] = val
			end)
		end)
	end
	return dst
end

function _.sort(t, fn)
	if isTable(t) then
		table.sort(t, fn)
	end
	return t
end

function _.filter(arr, fn)
	local ret = {}
	each(arr, function(x)
		if fn(x) then
			_.push(ret, x)
		end
	end)
	return ret
end

function _.indexOf(arr, sub, from, isPlain)
	-- deprecated from
	local tp = type(arr)
	if tp == 'string' then
		return string.find(arr, tostring(sub), from, isPlain)
	end
	return findIndex(arr, function(item)
		return item == sub
	end)
end

function _.lastIndexOf(arr, val, from, isPlain)
	local tp = type(arr)
	if tp == 'string' then
		return string.find(arr, val .. '$', from, isPlain)
	end
	if tp == 'table' then
		local i = #arr
		while i ~= 0 do
			if arr[i] == val then
				return i
			end
			i = i - 1
		end
	end
end

function _.split(str, sep, isPlain)
	if nil == str then return {} end
	str = tostring(str)
	local from = 1
	local ret = {}
	local len = #str
	while true do
		local i, j = str:find(sep, from, isPlain)
		if i then
			if i > len then break end
			if j < i then
				-- sep == ''
				j = i
				i = i + 1
			end
			table.insert(ret, str:sub(from, i - 1))
			from = j + 1
		else
			table.insert(ret, str:sub(from, len))
			break
		end
	end
	return ret
end

function _.join(arr, sep)
	return table.concat(_.map(arr, tostr), tostr(sep))
end

function _.empty(x)
	local tp = type(x)
	if 'string' == tp then
		return 0 == #x
	elseif 'table' == tp then
		local len = 0
		for k, v in pairs(x) do
			len = len + 1
		end
		return len == 0
	end
	return true
end

function _.difference(arr, other)
	local ret = {}
	each(arr, function(x)
		if not _.has(other, x) then
			table.insert(ret, x)
		end
	end)
	return ret
end

function _.without(arr, ...)
	return _.difference(arr, {...})
end

function _.reduce(arr, fn, prev)
	each(arr, function(x, i)
		prev = fn(prev, x, i, arr)
	end)
	return prev
end


function _.keys(obj)
	local ret = {}
	forIn(obj, function(val, key)
		_.push(ret, key)
	end)
	return ret
end

function _.values(obj)
	local ret = {}
	forIn(obj, function(val)
		_.push(ret, val)
	end)
	return ret
end

function _.mapKeys(obj, fn)
	local ret = {}
	forIn(obj, function(val, key)
		local newKey = fn(val, key, obj)
		if newKey then ret[newKey] = val end
	end)
	return ret
end

function _.mapValues(obj, fn)
	local ret = {}
	forIn(obj, function(val, key)
		ret[key] = fn(val, key, obj)
	end)
	return ret
end

function _.get(obj, arr)
	if isTable(obj) and arr and arr[1] then
		each(arr, function(key)
			if isTable(obj) and obj[key] then
				obj = obj[key]
			else
				return false
			end
		end)
		return obj
	end
end

function _.only(obj, keys)
	obj = obj or {}
	if type(keys) == 'string' then
		keys = _.split(keys, ' +')
	end
	return _.reduce(keys, function(ret, key)
		if nil ~= obj[key] then
			ret[key] = obj[key]
		end
		return ret
	end, {})
end

function _.invoke(arr, fn)
	return _.map(arr, function(x)
		if isFunction(fn) then
			return fn(x)
		end
	end)
end

function _.chain(val)
	return _(val):chain()
end

function _.assertEqual(actual, expect, level)
	level = level or 2
	if not _.isEqual(actual, expect) then
		local msg = 'AssertionError: ' .. _.dump(actual) .. ' == ' .. _.dump(expect)
		error(msg, level)
	end
end

function _.ok(...)
	local arr = {...}
	each(arr, function(x)
		if isTable(x) then
			_.assertEqual(x[1], x[2], 5)
		else
			_.assertEqual(x, true, 5)
		end
	end)
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

local dump, dumpTable

function dumpTable(o, lastIndent)
	if type(lastIndent) ~= 'string' then
		lastIndent = ''
	end
	local indent = '	' .. lastIndent
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
				return dump(x, indent)
			end) , ', ') .. ']'
		else
			return dumpTable(v, indent)
		end
	elseif t == 'nil' then
		return 'null'
	end
	return '[' .. t .. ']'
end

-- TODO other function

_.dump = dump

setmetatable(_, {__call = call})

return _

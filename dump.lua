GetInstancePath = function(obj)
	local path = ""
	local curObj = obj
	local formatLuaString = dump

	while curObj do
		if curObj == game then
			path = "game" .. path
			break
		end

		local className = curObj.ClassName
		local curName = tostring(curObj)
		local indexName
		if string.match(curName, "^[%a_][%w_]*$") then
			indexName = "." .. curName
		else
			local cleanName = formatLuaString(curName)
			indexName = '[' .. cleanName .. ']'
		end

		local parObj = curObj.Parent
		if parObj then
			if parObj == game and className:find("Service") then
				indexName = ':GetService("' .. className .. '")'
			end
		elseif parObj == nil then
			local gotnil = 'getNil("%s", "%s")'
			indexName = gotnil:format(curObj.Name, className)
		end

		path = indexName .. path
		curObj = parObj
	end

	return path
end

function dump(o, tree)
    tree = tree or { o }
    if type(o) == 'table' then
        local s = '{ '
        -- local count = #tree
        local i = 0
        for k, v in next, o do
            i = 1
            if type(k) ~= 'number' then
                k = tostring(dump(k, tree))
            end
            if type(v) == "table" then
                if table.find(tree, v) ~= nil then
                    v = "\"circular reference\""
                else
                    tree[#tree + 1] = v
                end
            end
            s = s .. '[' .. k .. '] = ' .. dump(v, tree) .. ', '
        end
        return s:sub(1, #s - 1 - i) .. '} '
    elseif type(o) == "string" then
        return '"' ..tostring(o):gsub("[^:a-zA-Z0-9%+%-*/=,./`~ _!@#$%%^&*%(%)]", function(c)
			local byte = tostring(string.byte(c))
            return "\\" .. ("0"):rep(3 - #byte) .. byte
        end):gsub("\\10", "\\n") .. '"'
    elseif typeof(o) == "Instance" then
        return GetInstancePath(o)
	elseif typeof(o) == "number" then
		return tostring(o)
	elseif typeof(o) == "boolean" then
		return if o then "true" else "false"
    elseif typeof(o) == "Vector3" then
        return `Vector3.new({o.X}, {o.Y}, {o.Z})`
    elseif typeof(o) == "Vector2" then
        return `Vector2.new({o.X}, {o.Y})`
    elseif typeof(o) == "CFrame" then
        return `CFrame.new({dump(o.Position)}, {dump(o.Position + o.LookVector)})`
    else
        return string.format('"%s (%s)"', tostring(o), typeof(o))
    end
end

function printdump(...)
    local args = {...}
    local output = ""
    for i, value in next, args do
        output = output .. dump(value)
        if i ~= #args then
            output = output .. " "
        end
    end
    print(output)
end

getgenv().printdump = printdump
getgenv().dump = dump
local _setclipboard = setclipboard
getgenv().setclipboard = newcclosure(function(value)
    _setclipboard(dump(value))
end)

return {
  printdump = printdump,
  dump = dump
}

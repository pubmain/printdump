function dump(o, tree)
    tree = tree or { o }
    if type(o) == 'table' then
        local s = '{ '
        -- local count = #tree
        local i = 0
        for k, v in pairs(o) do
            i = 1
            if type(k) ~= 'number' then
                k = tostring(dump(k, tree))
            end
            if type(v) == "table" then
                if table.find(tree, v) ~= nil then
                    v = "circular reference"
                else
                    tree[#tree + 1] = v
                end
            end
            s = s .. '[' .. k .. '] = ' .. dump(v, tree) .. ', '
        end
        return s:sub(1, #s - 1 - i) .. '} '
    elseif type(o) == "string" then
        return '"' ..tostring(o):gsub("[^a-zA-Z0-9%+%-*/=,./`~ _-]", function(c)
            return "\\" .. string.byte(c)
        end):gsub("\\10", "\\n") .. '"'
    else
        return tostring(o)
    end
end

function printdump(...)
    local args = {...}
    local output = ""
    for i, value in pairs(args) do
        output = output .. dump(value)
        if i ~= #args then
            output = output .. " "
        end
    end
    print(output)
end

getgenv().printdump = printdump
getgenv().dump = dump

return {
  printdump = printdump,
  dump = dump
}

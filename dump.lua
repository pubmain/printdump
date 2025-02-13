function dump(o, tree)
    tree = tree or { o }
    if type(o) == 'table' then
        local s = '{ '
        -- local count = #tree
        local i = 0
        for k, v in pairs(o) do
            i = 1
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
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
        return '"' .. tostring(o) .. '"'
    else
        return tostring(o)
    end
end

function printdump(o)
    print(dump(o))
end

getgenv().printdump = printdump
getgenv().dump = dump

return {
  printdump = printdump,
  dump = dump
}

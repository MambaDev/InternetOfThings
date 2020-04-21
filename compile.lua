local source_files = file.list();

local function ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

for k, _ in pairs(source_files) do
    if k ~= "compile.lua" and k ~= "init.lua" and ends_with(k, ".lua") then
        local file_no_ext = k:match("(.+)%..+")
        local compiled_file = file_no_ext .. ".lc"
        if (file.exists(compiled_file)) then
            file.remove(compiled_file)
        end
    end
end

-- build lib files.

print("compiling...")

for k, _ in pairs(source_files) do
    if k ~= "compile.lua" and k ~= "init.lua" and ends_with(k, ".lua") then
        print("compiling " .. k .. "...")
        node.compile(k)
        print("removing " .. k .. "...")
        file.remove(k)
    end
end

print("compiling...complete")
print("pre-heap: " .. node.heap())
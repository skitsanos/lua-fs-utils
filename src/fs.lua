--
-- File System Utils
--
-- @author skitsanos
-- @version 2.0.20230114
--
rawset(_G, 'lfs', false)

local lfs = require('lfs')
local json = require("cjson")

local fs = {}

--
-- Get file name
--
function fs.fileName(path)
    local fileName = string.match(path, "([^/]+)$")
    return fileName
end

--
-- Get file extension
--
function fs.fileExtension(path)
    local extension = string.match(path, "%.([^.]+)$")
    return extension
end

--
-- Find file in a given path
--
function fs.find(path, fileName)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local fullPath = path .. '/' .. file
            local mode = lfs.attributes(fullPath, "mode")
            if mode == "file" and file == fileName then
                return fullPath
            elseif mode == "directory" then
                local result = fs.find(fullPath, fileName)
                if result then
                    return result
                end
            end
        end
    end
    return nil
end

--
-- Read file as text
--
function fs.readAsText(path)
    local status, file, err = pcall(io.open, path, "r")
    if status then
        local content = file:read("*all")
        file:close()
        return content
    else
        return nil, "Error: Could not open file " .. err
    end
end

--
-- Read file as JSON
--
function fs.readAsJson(path)
    local status, file, err = pcall(io.open, path, "r")
    if status then
        local content = file:read("*all")
        file:close()
        local statusJson, jsonObject, _, errJson = pcall(json.decode, content)
        if statusJson then
            return jsonObject
        else
            return nil, "Error: Could not parse JSON - " .. errJson
        end
    else
        return nil, "Error: Could not open file " .. err
    end
end

--
-- Read from file
--
function fs.read(path, binary)
    local status, file, err
    if binary then
        status, file = pcall(io.open, path, "rb")
    else
        status, file = pcall(io.open, path, "r")
    end
    if status then
        local bytes = {}
        if binary then
            for byte in file:lines(1) do
                bytes[#bytes + 1] = string.byte(byte)
            end
        else
            bytes = file:read("*all")
        end
        file:close()
        return bytes
    else
        return nil, "Error: Could not open file " .. err
    end
end

--
-- Write file
--
function fs.write(path, content)
    local status, file, err = pcall(io.open, path, "w")
    if status then
        file:write(content)
        file:close()
        return true
    else
        return nil, "Error: Could not open file " .. err
    end
end

--
-- Check if path exists
--
function fs.exists(path)
    return lfs.attributes(path) ~= nil
end

--
-- Get number of files in a given path
--
function fs.filesCount(path)
    local count = 0
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local filePath = path .. "/" .. file
            local mode = lfs.attributes(filePath, "mode")
            if mode == "file" then
                count = count + 1
            end
        end
    end
    return count
end

--
-- Check if file matching the signature
--
function fs.matchSignature(path, signature)
    local attr = lfs.attributes(path)
    if attr and attr.mode == "file" then
        local file = io.open(path, "rb")
        if file then
            local bytes = {}
            for i = 1, #signature do
                bytes[i] = file:read(1)
            end
            file:close()
            for i = 1, #signature do
                if bytes[i] ~= string.char(signature[i]) then
                    return false
                end
            end
            return true
        else
            return false
        end
    else
        return false
    end
end

--
-- Stream file
--
function fs.stream(path, chunkSize)
    local file = io.open(path, "rb")
    if file then
        if ngx then -- check if running under OpenResty
            ngx.send_headers() -- send headers to the client
            ngx.flush(true) -- flush the headers
            while true do
                local chunk = file:read(chunkSize)
                if not chunk then break end
                ngx.print(chunk)
                ngx.flush(true) -- flush the chunk
            end
        else
            while true do
                local chunk = file:read(chunkSize)
                if not chunk then break end
                io.stdout:write(chunk)
                io.stdout:flush() -- flush the chunk
            end
        end
        io.close(file)
    else
        return nil, "Error: Could not open file"
    end
end

return fs
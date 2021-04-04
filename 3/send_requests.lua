local client = require('http.client').new()
json = require('json')
print("Testing the bootstrapped instances")
local function getConfig(filename)
    local configFile = io.open(filename, "r")
    if not configFile then
        print("Error reading file")
        return nil
    end
    local content = configFile:read("all")
    configFile:close()
    return json.decode(content)
end

local config = getConfig(arg[1])
local function assureConfig()
    print("The config is:")
    print(json.encode(config))
    for uuid, port in pairs(config) do
        if port ~= 'null' then
            print(port)
            local ret = client:request("GET", "localhost:"..port).body
            if ret ~= nil then
                assert(ret == uuid, "uuids do not match: "..uuid .. " vs " .. ret)
                print(string.format("uuid %s successfully running on port %s", uuid, port))
            end
        end
    end
end
assureConfig()
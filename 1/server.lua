yaml = require('yaml')
configFile = io.open("./config.yml", "r")
if not configFile then
    print("Error reading file")
    return nil
end
content = configFile:read("all")
configFile:close()
decoded = yaml.decode(content)

-- parsing paramenters
local inPort = tonumber(decoded['proxy']['port'])
local host = decoded['proxy']['bypass']['host']
local goalPort = tonumber(decoded['proxy']['bypass']['port'])

http_client = require('http.client').new({})
local function redirect(req)
    url = host .. ":" .. goalPort .. req:path() .. "?" .. req:query()
    return http_client:request(req:method(), url, req.body, {
        req:headers()
    })
end

local router = require('http.router').new()
router:route({ path = '/' }, redirect)
router:route({ path = '/.*' }, redirect)

local server = require('http.server').new('localhost', inPort)
server:set_router(router)

server:start()

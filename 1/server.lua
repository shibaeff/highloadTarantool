local yaml = require('yaml')
local fio = require('fio')
local err
configFile, err = fio.open("./config.yml", {'O_RDONLY'})
if not configFile then
    print('Error reading file')
    print(err)
    os.exit(1)
end

local content = configFile:read()
configFile:close()
err = nil
decoded, err = yaml.decode(content)
if err ~= nil then
    print('Parsing error')
    print(err)
    os.exit(1)
end

-- parsing paramenters
local inPort = tonumber(decoded['proxy']['port'])
local host = decoded['proxy']['bypass']['host']
local goalPort = tonumber(decoded['proxy']['bypass']['port'])

local http_client = require('http.client').new({})
local function redirect(req)
    local url = host .. ":" .. goalPort .. req:path() .. "?" .. req:query()
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

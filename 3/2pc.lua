local port = tonumber(arg[1])
local function hello()
    return {
        status = 200,
        body = 'hello, world'
    }
end

local router = require('http.router').new()
router:route({ method = 'GET', path = '/' }, hello)

local server = require('http.server').new('localhost', port)
server:set_router(router)

if port == nil then
    error('Invalid port')
end

_G.swim = require('swim').new()

local instance_uuid = '804f00ed-271c-47fa-844e-df4c6e0d' .. tostring(port)

_G.swim:cfg({
    uuid = instance_uuid,
    uri = port,
    heartbeat_rate = 1,
    ack_timeout = 0.1,
    gc_mode = 'off',
})

function get_members()
    local result = {}
    for k, v in _G.swim:pairs() do
        result[k] = v
    end
    return result
end

server:start()
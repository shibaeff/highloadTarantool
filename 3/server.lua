#!/usr/bin/env tarantool


json = require('json')

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
local config = getConfig("ini_config.json")
print(config["1"])

local fio = require('fio')
local digest = require('digest')
local port = tonumber(arg[1])
local uuid = tonumber(arg[2])

if port == nil then
    error('Invalid port')
end
if uuid == nil then
    error('Invalid uuid')
end
if _G.ports == nil then
    _G.ports = {}
end

function handler()
    local str = string.format("%d", uuid)
    return {
        status = 200,
        body =  str,
    }
end

local router = require('http.router').new()
router:route({ method = 'GET', path = '/' }, handler)


local socket = require('socket')
local function can_use_port(port)
    local sock = socket('AF_INET', 'SOCK_STREAM', 'tcp')
    local ok = sock:bind('0.0.0.0', port)
    local err = sock:error()
    sock:close()
    return ok
end

function ack(req)
    local askedPort = tostring(req:query_param("askedPort"))
    return {
        status=200,
        body = can_use_port(askedPort),
    }
end

router:route({ method = 'GET', path = '/ack' }, ack)

local s = nil
function restart(req)
    local newPort = tostring(req:query_param("newPort"))
    local location = tostring(req:query_param("location"))
    local config = getConfig(location)
    print(newPort)
    if newPort == nil then
        return {
            status = 202
        }
    end
    print("Halt!")
    s:stop()
    server = require('http.server').new('0.0.0.0', newPort)
    server:set_router(router)
    print("Los gehen!")
    server:start()
    s = server
    return {
        status = 200
    }
    end

router:route({ method = 'GET', path = '/restart' }, restart)

local client = require('http.client').new()

local server = require('http.server').new('0.0.0.0', port)
s = server

local function all_trim(str)
    local normalisedString = string.gsub(str, "%s+", "")
    return normalisedString
end

function applyConfig(filename)
    local newConfig = getConfig(filename)
    print(newConfig)
    print("Starting the validation stage")
    for k, v in pairs(config) do
        if k == arg[2] then
            --print('Stopping the main server')
            --server:stop()
            --server = require('http.server').new('0.0.0.0', tonumber(v))
            --print('Starting the main server')
            --server:set_router(router)
            --server:start()
            goto next
        end
        print(k, all_trim(v))
        if client:request("GET", "localhost:" .. config[k] .. "/ack?askedPort=" .. newConfig[k]).body ~= 'true' then
            print("Problem with " .. k .. "on port " .. v)
            print("Aborting commit")
            return
        end
        ::next::
    end
    print("Validation successful. Applying the changes.")
    local suuid = tostring(uuid)
    if newConfig[suuid] ~= nil then
        print('Stopping the main server')
        server:stop()
        server = require('http.server').new('0.0.0.0', tonumber(newConfig[suuid]))
        print('Starting the main server')
        server:set_router(router)
        server:start()
    end
    for k, v in pairs(newConfig) do
        client:request("GET", "localhost:" .. config[k] .. "/restart?newPort=" .. v .. "&location=filename")
    end
    print("Update completed")
end

local function commit()
    applyConfig("config.json")
    return {
        status = 200,
        body = "complete"
    }
end
router:route({method = 'GET', path = '/commit'}, commit)

server:set_router(router)
server:start()

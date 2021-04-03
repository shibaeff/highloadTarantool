client = require('http.client').new()
json = require('json')
local config = {
    ["1"] = "8080"
}
local ret = client:request("POST", "localhost:8080/setConfig", json.encode(config))
print(ret.body)
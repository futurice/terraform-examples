local hmac = require "resty.hmac"
local hmacs = {}
local version = "v0"
local err

local _M = {
    _VERSION = '0.01',
}

function _M.isAuthentic(request, signingsecret)
    if hmacs[signingsecret] == nil then
        hmacs[signingsecret] = hmac:new(signingsecret, hmac.ALGOS.SHA256)
    end

    local hmac_sha256 = hmacs[signingsecret]
    local timestamp = request.get_headers()["X-Slack-Request-Timestamp"]
    local signature = request.get_headers()["X-Slack-Signature"]
    local body = request.get_body_data()
    if body == nil or timestamp == nil or signature == nil then 
        return false
    end

    local basestring = version .. ":" .. timestamp .. ":" .. body
    local mac = version .. "=" .. hmac_sha256:final(basestring, true)
    hmac_sha256:reset()
    return mac == signature
end

return _M
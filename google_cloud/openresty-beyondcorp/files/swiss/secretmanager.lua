local _M = {
    _VERSION = '0.01',
}
local cjson = require "cjson"
local http = require "resty.http"
local b64 = require("ngx.base64")

function _M.fetch(location, access_token)
    local httpc = http.new()
    local secretlocation = location
    ngx.log(ngx.WARN, "fetching secret from: " .. secretlocation)
    local res, err = httpc:request_uri(
        secretlocation,
        {
            headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. access_token
            },
            ssl_verify = false
        }
    )
    if err ~= nil then
        return nil, err
    elseif res.status == 200 then
        local content = cjson.decode(res.body)
        return b64.decode_base64url(content.payload.data), nil
    else
        return nil, res.body
    end
end

return _M
local SL = {}
SL.__index = SL

SL.Data = {}

local function info(f)
    local ok, i = pcall(debug.getinfo, f)
    if not ok then return nil end
    return i
end

function SL:ProtectFunction(f)
    if type(f) ~= "function" then return end
    if self.Data[f] then return end

    local i = info(f)

    self.Data[f] = {
        ref = f,
        what = i and i.what,
        source = i and i.source,
        linedefined = i and i.linedefined,
        nups = i and i.nups,
        iscclosure = iscclosure and iscclosure(f),
        env = getfenv(f)
    }
end

function SL:VerifyFunctionIntegrity(f)
    if type(f) ~= "function" then return false end
    local d = self.Data[f]
    if not d then return false end

    local i = info(f)
    if not i then return true end

    if d.iscclosure and not (iscclosure and iscclosure(f)) then
        return true
    end

    if d.what ~= i.what then
        return true
    end

    if d.source ~= i.source then
        return true
    end

    if d.linedefined ~= i.linedefined then
        return true
    end

    if d.nups ~= i.nups then
        return true
    end

    if getfenv(f) ~= d.env then
        return true
    end

    return false
end

function SL:RevertHook(f)
    local d = self.Data[f]
    if not d then return false end
    for k, v in pairs(getgenv()) do
        if v == f then
            rawset(getgenv(), k, d.ref)
        end
    end
    return true
end

return setmetatable({}, SL)

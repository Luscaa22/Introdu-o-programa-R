local SL = {}
SL.__index = SL

SL.Originals = {}

local function iscc(f)
    return iscclosure and iscclosure(f)
end

function SL:ProtectFunction(f)
    if type(f) ~= "function" then return end
    if self.Originals[f] then return end
    self.Originals[f] = {
        ref = f,
        dump = (not iscc(f) and pcall(string.dump, f) and string.dump(f)) or nil,
        iscclosure = iscc(f)
    }
end

function SL:VerifyFunctionIntegrity(f)
    if type(f) ~= "function" then return false end
    local d = self.Originals[f]
    if not d then return false end
    if f ~= d.ref then
        return true
    end
    if not d.iscclosure and d.dump then
        local ok, dumped = pcall(string.dump, f)
        if ok and dumped ~= d.dump then
            return true
        end
    end
    return false
end

function SL:RevertHook(f)
    local d = self.Originals[f]
    if not d then return false end
    for _, v in pairs(getgc(true)) do
        if v == f then
            rawset(getfenv(), _, d.ref)
        end
    end
    return true
end

return setmetatable({}, SL)

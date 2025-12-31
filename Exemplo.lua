local SL = {}
SL.__index = SL

SL.Data = {}
SL.Locked = false

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
    if d.iscclosure and not (iscclosure and iscclosure(f)) then return true end
    if d.what ~= i.what then return true end
    if d.source ~= i.source then return true end
    if d.linedefined ~= i.linedefined then return true end
    if d.nups ~= i.nups then return true end
    if getfenv(f) ~= d.env then return true end
    return false
end

function SL:ForceDominance(f, crash)
    if type(f) ~= "function" then return end
    local original = f
    hookfunction(f, newcclosure(function(...)
        if SL.Locked then
            task.spawn(crash, "Interceptacao detectada")
            while true do end
        end
        return original(...)
    end))
end

function SL:ConsistencyTest(f, crash)
    if type(f) ~= "function" then return end
    local a = {pcall(f, {a=1})}
    task.wait()
    local b = {pcall(f, {a=1})}
    if #a ~= #b then crash("HTTP inconsistente") end
    for i = 1, #a do
        if a[i] ~= b[i] then
            crash("HTTP inconsistente")
        end
    end
end

function SL:Seal()
    SL.Locked = true
end

return setmetatable({}, SL)

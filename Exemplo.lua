--// SafetyHookLibrary FINAL
local SL = {}
SL.__index = SL

SL.Data = {}
SL.Protected = {}

--// Utils
local function safeInfo(f)
    local ok, info = pcall(debug.getinfo, f)
    return ok and info or nil
end

local function id(f)
    return tostring(f)
end

--// Protege função REAL
function SL:ProtectFunction(f)
    if type(f) ~= "function" or self.Data[f] then return end

    self.Data[f] = {
        ref = f,
        clone = clonefunction and clonefunction(f) or f,
        id = id(f),
        env = getfenv(f),
        isc = iscclosure and iscclosure(f),
        info = safeInfo(f)
    }
end

--// Verificação forte
function SL:VerifyFunctionIntegrity(f)
    local d = self.Data[f]
    if not d then return false end

    if id(f) ~= d.id then
        return true
    end

    if getfenv(f) ~= d.env then
        return true
    end

    if d.isc and iscclosure and not iscclosure(f) then
        return true
    end

    return false
end

--// Reverte hook DE VERDADE
function SL:RevertHook(f)
    local d = self.Data[f]
    if not d or not replaceclosure then return false end

    replaceclosure(f, d.clone)
    return true
end

--// Detecta uso
function SL:ForceHook(f, crash)
    if type(f) ~= "function" then return end

    hookfunction(f, newcclosure(function(...)
        crash("HTTP / REQUEST USADO")
        while true do end
    end))
end

--// Scan UI realista
function SL:ScanUI(crash)
    for _, v in ipairs(game.CoreGui:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextBox") then
            local t = (v.Text or ""):lower()
            if t:find("http") and (t:find("request") or t:find("spy")) then
                crash("INTERFACE DE SPY DETECTADA")
            end
        end
    end
end

--// Proteção contra hook tools
function SL:ProtectHookFunction(name, crash)
    local f = rawget(getgenv(), name)
    if type(f) ~= "function" or self.Protected[name] then return end
    self.Protected[name] = true

    hookfunction(f, newcclosure(function(...)
        crash("TENTATIVA DE USAR "..name)
        while true do end
    end))
end

return setmetatable({}, SL)

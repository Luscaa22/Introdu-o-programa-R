local SL = {}
SL.__index = SL

SL.Data = {}
SL.Alive = true

local function info(f)
    local ok, i = pcall(debug.getinfo, f)
    if not ok then return nil end
    return i
end

function SL:Protect(f)
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

function SL:Corrupted(f)
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

function SL:Dominate(f, crash)
    if type(f) ~= "function" then return end
    local real = f
    hookfunction(f, newcclosure(function(...)
        if not SL.Alive then
            task.spawn(crash, "Hook externo detectado")
            while true do end
        end
        return real(...)
    end))
end

function SL:Watch(crash, interval)
    task.spawn(function()
        while true do
            task.wait(interval or 0.2)
            for f in pairs(self.Data) do
                if self:Corrupted(f) then
                    crash("HTTP Spy detectado")
                end
            end
        end
    end)
end

return setmetatable({}, SL)

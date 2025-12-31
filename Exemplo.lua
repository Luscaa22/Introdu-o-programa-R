local SL = {}
SL.__index = SL

SL.Originals = {}
SL.Hooks = {}

local function isCClosure(func)
    return iscclosure and iscclosure(func)
end

function SL:ProtectFunction(func)
    if type(func) ~= "function" then return end
    if self.Originals[func] then return end
    self.Originals[func] = {
        ref = func,
        dump = (not isCClosure(func) and string.dump(func)) or nil,
        iscclosure = isCClosure(func)
    }
end

function SL:VerifyFunctionIntegrity(func)
    if type(func) ~= "function" then return false end
    local data = self.Originals[func]
    if not data then return false end
    if func ~= data.ref then
        return true
    end
    if not data.iscclosure then
        local ok, dumped = pcall(string.dump, func)
        if ok and dumped ~= data.dump then
            return true
        end
    end
    return false
end

function SL:RevertHook(func)
    local data = self.Originals[func]
    if not data then return false end
    for _, v in pairs(getgc(true)) do
        if v == func then
            rawset(getfenv(), _, data.ref)
        end
    end
    return true
end

function SL:Hook(func, callback)
    if type(func) ~= "function" then return end
    if self.Hooks[func] then return end
    self:ProtectFunction(func)
    local old
    old = hookfunction(func, newcclosure(function(...)
        return callback(old, ...)
    end))
    self.Hooks[func] = old
    return old
end

function SL:ProtectFunctions(funcs)
    for _, f in pairs(funcs) do
        if type(f) == "function" then
            self:ProtectFunction(f)
        end
    end
end

hookfunction(hookfunction, newcclosure(function(...)
    task.spawn(function()
        while true do end
    end)
    local args = {...}
    if typeof(args[1]) == "function" then
        SL:RevertHook(args[1])
    end
    while true do end
end))

return setmetatable({}, SL)

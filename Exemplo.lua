local SL = {}
SL.Hooks = {}
SL.Fingerprints = {}

function SL:Register(func)
    if type(func) == "function" and not self.Fingerprints[func] then
        self.Fingerprints[func] = tostring(func)
    end
end

function SL:Hook(func, callback)
    if type(func) ~= "function" then return end
    if self.Hooks[func] then return self.Hooks[func] end

    self:Register(func)

    local old
    old = hookfunction(func, function(...)
        local ok, res = pcall(callback, old, ...)
        if not ok then
            return old(...)
        end
        return res
    end)

    self.Hooks[func] = old
    return old
end

function SL:RevertHook(func)
    local old = self.Hooks[func]
    if old then
        hookfunction(func, old)
        self.Hooks[func] = nil
        return true
    end
    return false
end

function SL:VerifyFunctionIntegrity(func)
    if type(func) ~= "function" then return false end
    local fp = self.Fingerprints[func]
    if not fp then return false end
    return tostring(func) ~= fp
end

return SL

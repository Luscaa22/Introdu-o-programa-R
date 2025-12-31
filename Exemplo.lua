local SL = {}
SL.Hooks = {}

function SL:Hook(func, callback)
    if type(func) ~= "function" then return end
    if self.Hooks[func] then return self.Hooks[func] end

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
    return self.Hooks[func] ~= nil
end

return SL

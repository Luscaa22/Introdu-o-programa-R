local SafetyHook = {}
SafetyHook.__index = SafetyHook

SafetyHook.Hooks = {}

function SafetyHook:Hook(func, callback)
    if type(func) ~= "function" then
        error("Função inválida")
    end

    if type(callback) ~= "function" then
        error("Callback inválido")
    end

    if self.Hooks[func] then
        return self.Hooks[func]
    end

    local old
    old = hookfunction(func, function(...)
        local ok, result = pcall(callback, old, ...)
        if not ok then
            return old(...)
        end
        return result
    end)

    self.Hooks[func] = old
    return old
end

function SafetyHook:Unhook(func)
    local old = self.Hooks[func]
    if not old then
        return false
    end

    hookfunction(func, old)
    self.Hooks[func] = nil
    return true
end

function SafetyHook:UnhookAll()
    for func, old in pairs(self.Hooks) do
        hookfunction(func, old)
    end
    self.Hooks = {}
end

function SafetyHook:IsHooked(func)
    return self.Hooks[func] ~= nil
end

return SafetyHook

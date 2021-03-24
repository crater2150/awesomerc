-- change color of wibars on numlock/capslock/scrolllock
--
require("beautiful")

local lockhl = { bg_lock = beautiful.bg_urgent, bg_normal = beautiful.bg_normal }
local target_wibars = {}

function lockhl:setup(wibars, bg_lock, bg_normal)
    target_wibars = wibars
    if bg_lock then self.bg_lock = bg_lock end
    if bg_normal then self.bg_normal = bg_normal end
    return lockhl
end

local function check_lock(lock, cb)
    awful.spawn.with_line_callback(
        'bash -c "sleep 0.2; xset q | grep -Po \\"' .. lock .. ' Lock:\\\\s*\\\\K(on|off)\\" 2>&1"',
        { stdout = function(output) cb(output == "on") end }
    )
end

function lockhl:target_color(is_on, lock)
    if is_on then
        if type(self.bg_lock) == 'table' then
            return self.bg_lock[lock]
        else
            return self.bg_lock
        end
    else
        return self.bg_normal
    end
end

function lockhl:on_lock(lock)
    check_lock(lock, function(is_on)
        local newbg = self:target_color(is_on, lock)
        for _, bar in pairs(target_wibars) do
            bar.bg = newbg
        end
    end)
end

return setmetatable(lockhl, { __call = function(_, lock)
    return function() lockhl:on_lock(lock) end
end })

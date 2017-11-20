local awful = require("awful")
local beautiful = beautiful


client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

local fixed_clients = {
    -- action search and similar windows in IDEA
    { rule = { name = "", class = "jetbrains-idea", type = "dialog" } },
    -- password inputs
    { rule = { class = "Pinentry-gtk-2" } },
}

local function may_lose_focus(c)
    if c ~= nil then return true end
    return not awful.rules.matches_list(c, fixed_clients)
end

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if may_lose_focus(client.focus)
        and awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

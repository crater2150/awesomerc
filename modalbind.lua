local M = {}
local inited = false
local modewidget = {}
local modewibox = { screen = -1 }

--local functions
local ensure_init, set_default, update_settings, show_box, hide_box 
M.grab = function(keymap, stay_in_mode)
	if keymap.name then show_box(mouse.screen, keymap) end

	keygrabber.run(function(mod, key, event)
		if key == "Escape" then
			keygrabber.stop()
			hide_box();
			return true
		end

		if event == "release" then return true end

		if keymap[key] then
			keygrabber.stop()
			keymap[key]()
			if stay_in_mode then
				M.grab(keymap, true)
			else
				hide_box()
				return true
			end
		end

		return true
	end)
end

-- Partially adapted from Obvious Widget Library module "popup_run_prompt" --
-- Original Author: Andrei "Garoth" Thorp                                  --
-- Copyright 2009 Andrei "Garoth" Thorp                                    --

local defaults = {}
-- Default is 1 for people without compositing
defaults.opacity = 1.0
defaults.height = 22
defaults.border_width = 1
defaults.x_offset = 18
defaults.show_options = true

-- Clone the defaults for the used settings
local settings = {}
for key, value in pairs(defaults) do
    settings[key] = value
end


M.set_opacity = function (amount)
    settings.opacity = amount or defaults.opacity
    update_settings()
end

M.set_height = function (amount)
    settings.height = amount or defaults.height
    update_settings()
end

M.set_border_width = function (amount)
    settings.border_width = amount or defaults.border_width
    update_settings()
end

M.set_x_offset = function (amount)
    settings.x_offset = amount or defaults.x_offset
    update_settings()
end

M.set_show_options = function (bool)
    settings.show_options = bool
end

ensure_init = function ()
    if inited then
    return
    end

    inited = true
    for s = 1, screen.count() do
        modewidget[s] = widget({
            type = "textbox",
            name = "modewidget" .. s,
            align = "center"
        })

        modewibox[s] = wibox({
            fg = beautiful.fg_normal,
            bg = beautiful.bg_normal,
            border_width = settings.border_width,
            border_color = beautiful.bg_focus,
        })
        set_default(s)
        modewibox[s].visible = false
        modewibox[s].screen = s
        modewibox[s].ontop = true

        -- Widgets for prompt wibox
        modewibox[s].widgets = {
            modewidget[s],
            layout = awful.widget.layout.vertical.center
        }
    end
end

set_default = function (s)
    modewibox[s]:geometry({
        width = modewidget[s].extents(modewidget[s]).width,
        height = settings.height,
        x = settings.x_offset < 0 and
		screen[s].geometry.x - width + settings.x_offset or
		settings.x_offset,
        y = screen[s].geometry.y + screen[s].geometry.height - settings.height
    })
end

update_settings = function ()
    for s, value in ipairs(modewibox) do
        value.border_width = settings.border_width
        set_default(s)
        value.opacity = settings.opacity
    end
end

show_box = function (s, map)
	ensure_init()
	modewibox.screen = s
	local label = " -- " .. map.name .. " -- "
	if settings.show_options then
		for key in pairs(map) do
			if key ~= "name" then label = label .. " " .. key end
		end
	end
	modewidget[s].text = label
        set_default(s)
        modewibox[s].visible = true
end

hide_box = function ()
	local s = modewibox.screen
        if s ~= -1 then modewibox[s].visible = false end
end

return M

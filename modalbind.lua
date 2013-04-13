local M = {}
local inited = false
local modewidget = {}
local modewibox = { screen = -1 }

--local functions

local defaults = {}

defaults.opacity = 1.0
defaults.height = 22
defaults.border_width = 1
defaults.x_offset = 0
defaults.y_offset = 0
defaults.show_options = true

-- Clone the defaults for the used settings
local settings = {}
for key, value in pairs(defaults) do
	settings[key] = value
end

local function update_settings()
	for s, value in ipairs(modewibox) do
		value.border_width = settings.border_width
		set_default(s)
		value.opacity = settings.opacity
	end
end


--- Change the opacity of the modebox.
-- @param amount opacity between 0.0 and 1.0, or nil to use default
M.set_opacity = function (amount)
	settings.opacity = amount or defaults.opacity
	update_settings()
end

--- Change height of the modebox.
-- @param amount height in pixels, or nil to use default
M.set_height = function (amount)
	settings.height = amount or defaults.height
	update_settings()
end

--- Change border width of the modebox.
-- @param amount width in pixels, or nil to use default
M.set_border_width = function (amount)
	settings.border_width = amount or defaults.border_width
	update_settings()
end

--- Change horizontal offset of the modebox.
-- set location for the box with set_corner(). The box is shifted to the right
-- if it is in one of the left corners or to the left otherwise
-- @param amount horizontal shift in pixels, or nil to use default
M.set_x_offset = function (amount)
	settings.x_offset = amount or defaults.x_offset
	update_settings()
end

--- Change vertical offset of the modebox.
-- set location for the box with set_corner(). The box is shifted downwards if it
-- is in one of the upper corners or upwards otherwise.
-- @param amount vertical shift in pixels, or nil to use default
M.set_y_offset = function (amount)
	settings.y_offset = amount or defaults.y_offset
	update_settings()
end

--- Set the corner, where the modebox will be displayed
-- If a parameter is not a valid orientation (see below), the function returns
-- without doing anything
-- @param vertical either top or bottom
-- @param horizontal either left or right
M.set_corner = function (vertical, horizontal)
	if (vertical ~= "top" and vertical ~= "bottom") then
		return
	end
	if (horizontal ~= "left" and horizontal ~= "right") then
		return
	end
	settings.corner_v = vertical or defaults.corner_v
	settings.corner_h = horizontal or defaults.corner_h
end

M.set_show_options = function (bool)
	settings.show_options = bool
end

local function set_default(s)
	minwidth, minheight = modewidget[s]:fit(screen[s].geometry.width,
		screen[s].geometry.height)
	modewibox[s].width = minwidth + 1;
	modewibox[s].height = math.max(settings.height, minheight)
	modewibox[s].x = settings.x_offset < 0 and
		screen[s].geometry.x - width + settings.x_offset or
		settings.x_offset
	modewibox[s].y = screen[s].geometry.height - settings.height
end

local function ensure_init()
	if inited then
		return
	end
	inited = true
	for s = 1, screen.count() do
		modewidget[s] = wibox.widget.textbox()
		modewidget[s]:set_align("center")

		modewibox[s] = wibox({
			fg = beautiful.fg_normal,
			bg = beautiful.bg_normal,
			border_width = settings.border_width,
			border_color = beautiful.bg_focus,
		})

		local modelayout = {}
		modelayout[s] = wibox.layout.fixed.horizontal()
		modelayout[s]:add(modewidget[s])
		modewibox[s]:set_widget(modelayout[s]);
		set_default(s)
		modewibox[s].visible = false
		modewibox[s].screen = s
		modewibox[s].ontop = true

		-- Widgets for prompt wibox
		modewibox[s].widgets = {
			modewidget[s],
			layout = wibox.layout.fixed.horizontal
		}
	end
end

local function show_box(s, map)
	ensure_init()
	modewibox.screen = s
	local label = " -- " .. map.name .. " -- "
	if settings.show_options then
		for key in pairs(map) do
			if key ~= "name" then label = label .. " " .. key end
		end
	end
	modewidget[s]:set_text(label)
	modewibox[s].visible = true
	set_default(s)
end

local function hide_box()
	local s = modewibox.screen
	if s ~= -1 then modewibox[s].visible = false end
end

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
M.grabf = function(keymap, stay_in_mode)
	return function() M.grab(keymap, stay_in_mode) end
end

M.wibox = function() return modewibox[1] end

return M

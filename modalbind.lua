local modalbind = {}
local wibox = require("wibox")
local inited = false
local modewidget = {}
local modewibox = { screen = -1 }
local nesting = 0

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
function set_opacity(amount)
	settings.opacity = amount or defaults.opacity
	update_settings()
end
modalbind.set_opacity = set_opacity

--- Change height of the modebox.
-- @param amount height in pixels, or nil to use default
function set_height(amount)
	settings.height = amount or defaults.height
	update_settings()
end
modalbind.set_height = set_height 

--- Change border width of the modebox.
-- @param amount width in pixels, or nil to use default
function set_border_width(amount)
	settings.border_width = amount or defaults.border_width
	update_settings()
end
modalbind.set_border_width = set_border_width

--- Change horizontal offset of the modebox.
-- set location for the box with set_corner(). The box is shifted to the right
-- if it is in one of the left corners or to the left otherwise
-- @param amount horizontal shift in pixels, or nil to use default
function set_x_offset (amount)
	settings.x_offset = amount or defaults.x_offset
	update_settings()
end
modalbind.set_x_offset = set_x_offset  

--- Change vertical offset of the modebox.
-- set location for the box with set_corner(). The box is shifted downwards if it
-- is in one of the upper corners or upwards otherwise.
-- @param amount vertical shift in pixels, or nil to use default
function set_y_offset(amount)
	settings.y_offset = amount or defaults.y_offset
	update_settings()
end
modalbind.set_y_offset = set_y_offset

--- Set the corner, where the modebox will be displayed
-- If a parameter is not a valid orientation (see below), the function returns
-- without doing anything
-- @param vertical either top or bottom
-- @param horizontal either left or right
function set_corner(vertical, horizontal)
	if (vertical ~= "top" and vertical ~= "bottom") then
		return
	end
	if (horizontal ~= "left" and horizontal ~= "right") then
		return
	end
	settings.corner_v = vertical or defaults.corner_v
	settings.corner_h = horizontal or defaults.corner_h
end
modalbind.set_corner = set_corner

function set_show_options(bool)
	settings.show_options = bool
end
modalbind.set_show_options = set_show_options

local function set_default(s, position)
	minwidth, minheight = modewidget[s]:fit(screen[s].geometry.width,
		screen[s].geometry.height)
	modewibox[s].width = minwidth + 1;
	modewibox[s].height = math.max(settings.height, minheight)
	if position then
		modewibox[s].x = getXOffset(s, position)
		modewibox[s].y = getYOffset(s, position)
	else
		modewibox[s].x = settings.x_offset < 0 and
			screen[s].geometry.x - modewibox[s].width + settings.x_offset or
			settings.x_offset
		modewibox[s].y = screen[s].geometry.height - modewibox[s].height
	end
end

local function getXOffset(s,position)
	if type(position) == "table" then
		return position.x
	elseif position == "topleft" or position == "bottomleft" then
		return 0
	elseif position == "topright" or position == "bottomright" then
		return screen[s].geometry.x - modewibox[s].width
	end
end


local function getYOffset(s,position)
	if type(position) == "table" then
		return position.y
	elseif position == "topleft" or position == "topright" then
		return 0
	elseif position == "bottomleft" or position == "bottomright" then
		return screen[s].geometry.y - modewibox[s].height
	end
end

local function ensure_init()
	if inited then
		return
	end
	inited = true
	for s = 1, screen.count() do
		modewidget[s] = wibox.widget.textbox()
		modewidget[s]:set_align("left")
		if beautiful.fontface then
			modewidget[s]:set_font(beautiful.fontface .. " " .. (beautiful.fontsize + 4))
		end

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

local function show_box(s, map, name)
	ensure_init()
	modewibox.screen = s
	local label = "<b>" .. name .. "</b>"
	if settings.show_options then
		for key, mapping in pairs(map) do
			if key ~= "onClose" then
				label = label .. "\n<b>" .. key .. "</b>"
				if type(mapping) == "table" then
					label = label .. "\t" .. (mapping.desc or "???")
				end
			end
		end
	end
	modewidget[s]:set_markup(label)
	modewibox[s].visible = true
	set_default(s)
end

local function hide_box()
	local s = modewibox.screen
	if s ~= -1 then modewibox[s].visible = false end
end

function grab(keymap, name, stay_in_mode)
	if name then
		show_box(mouse.screen, keymap, name)
		nesting = nesting + 1
	end

	keygrabber.run(function(mod, key, event)
		if key == "Escape" then
			if keymap["onClose"] then
				keymap["onClose"]()
			end
			keygrabber.stop()
			nesting = 0
			hide_box();
			return true
		end

		if event == "release" then return true end

		if keymap[key] then
			keygrabber.stop()
			if type(keymap[key]) == "table" then
				keymap[key].func()
			else
				keymap[key]()
			end
			if stay_in_mode then
				grab(keymap, name, true)
			else
				nesting = nesting - 1
				if nesting < 1 then hide_box() end
				return true
			end
		end

		return true
	end)
end
modalbind.grab = grab

function grabf(keymap, name, stay_in_mode)
	return function() grab(keymap, name, stay_in_mode) end
end
modalbind.grabf = grabf

function modebox() return modewibox[1] end
modalbind.modebox = modebox

return modalbind

local wibox = require("wibox")
local vicious = require("vicious")
local modkey = conf.modkey or "Mod4"
local awful = require("awful")

local widgets = { add = {} }

--------------------------------------------------------------------------------
-- table declarations {{{
--------------------------------------------------------------------------------
local wlist = {}
local bars = {}
local leftwibox = {}
local rightwibox = {}

local mytaglist = {}
mytaglist.buttons = awful.util.table.join(
awful.button({ }, 1, awful.tag.viewonly),
awful.button({ modkey }, 1, awful.client.movetotag),
awful.button({ }, 3, awful.tag.viewtoggle),
awful.button({ modkey }, 3, awful.client.toggletag),
awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- setup {{{
--------------------------------------------------------------------------------
local function setup() -- {{{
	for s = 1, screen.count() do
		wlist[s]={}
		bars[s]={}



		-- Create the wibox
		leftwibox[s] = awful.wibox({
			position = "left",
			screen = s,
			width = 18
		})
		rightwibox[s] = awful.wibox({
			position = "right",
			screen = s,
			width = 18
		})

		-- {{{ create layouts
		local left_bottom_layout = wibox.layout.fixed.horizontal()
		local left_top_layout = wibox.layout.fixed.horizontal()

		local left_layout = wibox.layout.align.horizontal()
		left_layout:set_left(left_bottom_layout)
		left_layout:set_right(left_top_layout)

		local right_bottom_layout = wibox.layout.fixed.horizontal()
		local right_top_layout = wibox.layout.fixed.horizontal()

		local right_layout = wibox.layout.align.horizontal()
		right_layout:set_left(right_top_layout)
		right_layout:set_right(right_bottom_layout)
		--}}}


		-- {{{ rotate layouts and add to wibox
		local leftrotate = wibox.layout.rotate()
		leftrotate:set_direction('east')
		leftrotate:set_widget(left_layout)
		leftwibox[s]:set_widget(leftrotate)

		local rightrotate = wibox.layout.rotate()
		rightrotate:set_direction('west')
		rightrotate:set_widget(right_layout)
		rightwibox[s]:set_widget(rightrotate)
		--}}}


		bars[s] = {}
		bars[s].left = {}
		bars[s].left.bottom = left_bottom_layout
		bars[s].left.top = left_top_layout
		bars[s].right = {}
		bars[s].right.bottom = right_bottom_layout
		bars[s].right.top = right_top_layout
	end
end -- }}}

-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Utility {{{
--------------------------------------------------------------------------------

-- force update of a widget
local function update(widgetname, index) -- {{{
	for s = 1, screen.count() do
		if wlist[s] ~= nil and wlist[s][widgetname] ~= nil then
			if index ~= nil then
				vicious.force({ wlist[s][widgetname][index] })
			else
				vicious.force({ wlist[s][widgetname] })
			end
		end
	end
end
--}}}
widgets.update = update

-- get layout for adding widgets
local function get_layout(screen, bar, align) --{{{
	if bars[screen][bar] == nil then return nil end

	return {screen = screen, layout = bars[screen][bar][align]}
end --}}}
widgets.layout = get_layout

-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- widget creators {{{
--------------------------------------------------------------------------------

-- mail widget
local function mailwidget(name, parent, mailboxes, notify_pos) --{{{
	local widget = wibox.widget.textbox()
	local bg = wibox.widget.background()
	bg:set_widget(widget)
	vicious.register(widget, vicious.widgets.mdir, function(widget, args) 
		if args[1] > 0 then
			naughty.notify({
				title = "New mail arrived",
				text = "Unread "..args[2].." / New "..args[1],
				position = notify_pos or "top_left"

			})
			bg:set_bg(theme.bg_urgent)
			bg:set_fg(theme.fg_urgent)
		elseif args[2] > 0 then
			bg:set_bg(theme.bg_focus)
			bg:set_fg(theme.fg_focus)
		else
			bg:set_bg(theme.bg_normal)
			bg:set_fg(theme.fg_normal)
		end
		return "⬓⬓ Unread "..args[2].." / New "..args[1].. " "
	end, 0, mailboxes)
	wlist[parent.screen][name] = widget
	parent.layout:add(bg)
	widgets.update(name)
end
--}}}
widgets.add.mail = mailwidget

-- text clock
local function clockwidget(name, parent) -- {{{
	wlist[parent.screen][name] = awful.widget.textclock()
	parent.layout:add(wlist[parent.screen][name])
end
--}}}
widgets.add.clock = clockwidget

-- layoutbox
local function layoutwidget(parent) -- {{{
	wlist[parent.screen]["layout"] = awful.widget.layoutbox(s)
	parent.layout:add(wlist[parent.screen]["layout"])
end
--}}}
widgets.add.layout = layoutwidget

-- taglist
local function taglistwidget(name, parent) --{{{
	-- Create a taglist widget
	wlist[parent.screen][name] = awful.widget.taglist(parent.screen,
		awful.widget.taglist.filter.all,
		mytaglist.buttons)
	parent.layout:add(wlist[parent.screen][name])
end --}}}
widgets.add.taglist = taglistwidget

-- system tray
-- not using a name argument, because only one systray is allowed
local function systraywidget(parent) --{{{
	if (wlist["systray"] ~= nil) then
		return
	end
	wlist["systray"] = wibox.widget.systray()
	parent.layout:add(wlist["systray"])
end --}}}
widgets.add.systray = systraywidget

-- cpu usage
local function cpuwidget(name, parent) --{{{
	wlist[parent.screen][name] = wibox.widget.textbox()
	vicious.register(wlist[parent.screen][name], vicious.widgets.cpu, "CPU: $1%")
	parent.layout:add(wlist[parent.screen][name])
end --}}}
widgets.add.cpu = cpuwidget

-- battery
local function batterywidget(name, parent, batname) --{{{
	print("creating batwidget '" .. name .. "' for battery '"..batname.."'")
	local widget = wibox.widget.textbox()
	local bg = wibox.widget.background()
	bg:set_widget(widget)
	vicious.register(widget, vicious.widgets.bat, function (widget, args)
		if args[2] == 0 then return ""
		else
			if args[2] < 15 then
				bg:set_bg(theme.bg_urgent)
				bg:set_fg(theme.fg_urgent)
			else
				bg:set_bg(theme.bg_normal)
				bg:set_fg(theme.fg_normal)
			end
			return name .. ": " ..
				args[1]..args[2].."% - "..args[3]
		end
	end, 61, batname)
	wlist[parent.screen][name] = widget
	parent.layout:add(bg)
	widgets.update(name)
end --}}}
widgets.add.battery = batterywidget

-- wireless status
local function wifiwidget(name, parent, interface) --{{{
	wlist[parent.screen][name] = wibox.widget.textbox()
	vicious.register(wlist[parent.screen][name], vicious.widgets.wifi,
	"WLAN ${ssid} @ ${sign}dBm, Q:${link}/70", 31, interface)
	parent.layout:add(wlist[parent.screen][name])
end --}}}
widgets.add.wifi = wifiwidget

-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- spacers {{{
--------------------------------------------------------------------------------

local spacer = wibox.widget.textbox()
spacer:set_text(" ")

-- manual spacing between widgets
local function spacerwidget(parent) --{{{
	parent.layout:add(spacer)
end --}}}
widgets.add.spacer = spacerwidget

-- change appearance of spacers
local function spacertext(text) --{{{
	spacer:set_text(text)
end --}}}
widgets.set_spacer_text = spacertext

-- }}}
--------------------------------------------------------------------------------

setup()

return widgets

-- vim:foldmethod=marker

local wibox = require("wibox")
local vicious = require("vicious")
local naughty = require("naughty")
local modkey = conf.modkey or "Mod4"
local awful = require("awful")
local tag = require("awful.tag")
local beautiful = require("beautiful")
local widgets = { add = {} }

--------------------------------------------------------------------------------
-- table declarations {{{
--------------------------------------------------------------------------------
local wlist = {}
local bars = {}
local leftwibar = {}
local rightwibar = {}

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
local function setup()
	for s in screen do
		wlist[s]={}
		bars[s]={}



		-- Create the wibar
		leftwibar[s] = awful.wibar({
			position = "left",
			screen = s,
			width = 18
		})
		rightwibar[s] = awful.wibar({
			position = "right",
			screen = s,
			width = 18
		})

		-- {{{ create containers
		local left_bottom_container = wibox.layout.fixed.horizontal()
		local left_top_container = wibox.layout.fixed.horizontal()

		local left_container = wibox.layout.align.horizontal()
		left_container:set_left(left_bottom_container)
		left_container:set_right(left_top_container)

		local right_bottom_container = wibox.layout.fixed.horizontal()
		local right_top_container = wibox.layout.fixed.horizontal()

		local right_container = wibox.layout.align.horizontal()
		right_container:set_left(right_top_container)
		right_container:set_right(right_bottom_container)
		--}}}


		-- {{{ rotate containers and add to wibox
		local leftrotate = wibox.container.rotate()
		leftrotate:set_direction('east')
		leftrotate:set_widget(left_container)
		leftwibar[s]:set_widget(leftrotate)

		local rightrotate = wibox.container.rotate()
		rightrotate:set_direction('west')
		rightrotate:set_widget(right_container)
		rightwibar[s]:set_widget(rightrotate)
		--}}}


		bars[s] = {}
		bars[s].left = {}
		bars[s].left.bottom = left_bottom_container
		bars[s].left.top = left_top_container
		bars[s].right = {}
		bars[s].right.bottom = right_bottom_container
		bars[s].right.top = right_top_container
	end
end

-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Utility {{{
--------------------------------------------------------------------------------

-- force update of a widget
local function update(widgetname, index)
	for s in screen do
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

-- get container for adding widgets
local function get_container(screen, bar, align)
	if bars[screen][bar] == nil then return nil end

	return {screen = screen, container = bars[screen][bar][align]}
end
widgets.container = get_container

-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- widget creators {{{
--------------------------------------------------------------------------------

local show = function(self)
	self:set_widget(self.widget)
end

local hide = function(self)
	self:set_widget(nil)
end

local function wrap_and_add(name, parent, widget, callback_widget)
	local container = wibox.container.margin(widget)
	container.widget = widget
	container.show = show
	container.hide = hide

	wlist[parent.screen][name] = callback_widget == nil and widget or callback_widget
	parent.container:add(container)
	return container
end


-- mail widget
local function mailwidget(name, parent, mailboxes, notify_pos, title)
	local widget = wibox.widget.textbox()
	local bg = wibox.container.background()
	bg:set_widget(widget)

	local container = wrap_and_add(name, parent, bg, widget)
	vicious.register(widget, vicious.widgets.mdir, function(widget, args)
		if args[1] > 0 then
			naughty.notify({
				title = "New mail arrived in box " .. title,
				text = title .. " " ..args[2].." / "..args[1],
				position = notify_pos or "top_left"

			})
			bg:set_bg(beautiful.bg_urgent)
			bg:set_fg(beautiful.fg_urgent)
			container:show()
		elseif args[2] > 0 then
			bg:set_bg(beautiful.bg_focus)
			bg:set_fg(beautiful.fg_focus)
			container:show()
		else
			bg:set_bg(beautiful.bg_normal)
			bg:set_fg(beautiful.fg_normal)
			container:hide()
		end
		return "⬓⬓ Unread "..args[2].." / New "..args[1].. " "
	end, 0, mailboxes)
	widgets.update(name)
	return container
end
--}}}
widgets.add.mail = mailwidget

-- text clock
local function clockwidget(name, parent)
	return wrap_and_add(name, parent, wibox.widget.textclock())
end
--}}}
widgets.add.clock = clockwidget

-- containerbox
local function layoutwidget(parent)
	local mylayoutbox = awful.widget.layoutbox(s)

	mylayoutbox:buttons(awful.util.table.join(
		awful.button({ }, 1, function () awful.layout.inc( 1) end),
		awful.button({ }, 3, function () awful.layout.inc(-1) end),
		awful.button({ }, 4, function () awful.layout.inc( 1) end),
		awful.button({ }, 5, function () awful.layout.inc(-1) end)
	))
	return wrap_and_add("layout", parent, mylayoutbox);
end
--}}}
widgets.add.layout_indicator = layoutwidget

-- taglist
local function taglistwidget(name, parent)
	local filter_urgentonly = function(t, args)
		for k, c in pairs(t:clients()) do
			if c.urgent then return true end
		end
		return t.selected
	end
	-- Create a taglist widget
	return wrap_and_add(name, parent,
	awful.widget.taglist(parent.screen, awful.widget.taglist.filter.noempty, mytaglist.buttons)
	)
end --}}}
widgets.add.taglist = taglistwidget

-- system tray
-- not using a name argument, because only one systray is allowed
local function systraywidget(parent)
	if (wlist["systray"] ~= nil) then
		return
	end
	wlist["systray"] = wibox.widget.systray()
	parent.container:add(wlist["systray"])
	return wlist["systray"]
end --}}}
widgets.add.systray = systraywidget

-- cpu usage
local function cpuwidget(name, parent)
	local cpu = wrap_and_add(name, parent, wibox.widget.textbox())
	vicious.register(wlist[parent.screen][name], vicious.widgets.cpu, "CPU: $1%")
	return cpu
end --}}}
widgets.add.cpu = cpuwidget

-- battery
local function batterywidget(name, parent, batname)
	local widget = wibox.widget.textbox()
	local bg = wibox.container.background()
	bg:set_widget(widget)
	vicious.register(widget, vicious.widgets.bat, function (widget, args)
		if args[2] == 0 then return ""
		else
			if args[2] < 15 then
				bg:set_bg(beautiful.bg_urgent)
				bg:set_fg(beautiful.fg_urgent)
			else
				bg:set_bg(beautiful.bg_normal)
				bg:set_fg(beautiful.fg_normal)
			end
			return name .. ": " ..
			args[1]..args[2].."% - "..args[3]
		end
	end, 61, batname)
	widgets.update(name)
	return wrap_and_add(name, parent, bg)
end --}}}
widgets.add.battery = batterywidget

-- wireless status
local function wifiwidget(name, parent, interface)
	local wifi = wrap_and_add(name, parent, wibox.widget.textbox())
	vicious.register(wlist[parent.screen][name], vicious.widgets.wifi,
	"WLAN ${ssid} @ ${sign}dBm, Q:${link}/70", 31, interface)
	return wifi
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
local function spacerwidget(parent)
	parent.container:add(spacer)
end --}}}
widgets.add.spacer = spacerwidget

-- manual spacing between widgets
local function textwidget(text, parent)
	local newtext = wibox.widget.textbox()
	newtext:set_text(text)
	parent.container:add(newtext)
end --}}}
widgets.add.text = textwidget

-- change appearance of spacers
local function spacertext(text)
	spacer:set_text(text)
end --}}}
widgets.set_spacer_text = spacertext

-- }}}
--------------------------------------------------------------------------------

setup()

return widgets

-- vim:foldmethod=marker

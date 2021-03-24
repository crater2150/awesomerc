local wibox = require("wibox")
local vicious = require("vicious")
local naughty = require("naughty")
local modkey = conf.modkey or "Mod4"
local awful = require("awful")
local tag = require("awful.tag")
local beautiful = require("beautiful")
local widgets = { add = {} }

local wlist = {}

local mytaglist = {}
mytaglist.buttons = awful.util.table.join(
awful.button({ }, 1, awful.tag.viewonly),
awful.button({ modkey }, 1, awful.client.movetotag),
awful.button({ }, 3, awful.tag.viewtoggle),
awful.button({ modkey }, 3, awful.client.toggletag),
awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)


local function percentage_overlay(p, color, prefix, suffix)
	return (
		'<span color="%s">%s%d%%%s</span>'
	):format(color, prefix or "", p, suffix or "")
end


function widgets.setup(s)
	return {
		left = function(bottom, top) s.leftwibar = add_bar(s, "left", "east", bottom, top) end,
		right = function(top, bottom) s.rightwibar = add_bar(s, "right", "west", top, bottom) end
	}
end

function add_bar(s, position, direction, first, second)
	newbar = awful.wibar({
		position = position,
		screen = s,
		opacity = 0.6,
		width = math.floor(s.dpi / 5)
	})

	newbar:setup {
		{
			first,
			nil,
			second,
			layout = wibox.layout.align.horizontal
		},
		direction = direction,
		widget = wibox.container.rotate
	}
	return newbar
end


function widgets.mail(mailboxes, notify_pos, title)
	local widget = wibox.widget.textbox()
	local bg = wibox.widget { widget, widget = wibox.container.background }

	local callback = function(widget, args)
		if args[1] > 0 then
			bg:set_bg(beautiful.bg_urgent)
			bg:set_fg(beautiful.fg_urgent)
			bg.visible = true
		elseif args[2] > 0 then
			bg:set_bg(beautiful.bg_focus)
			bg:set_fg(beautiful.fg_focus)
			bg.visible = true
		else
			bg.visible = false
		end
		return "⬓⬓ Unread "..args[2].." / New "..args[1].. " "
	end
	vicious.register(widget, vicious.widgets.mdir, callback, 60, mailboxes)
	table.insert(wlist, widget)
	return bg
end

function widgets.layout(s)
	local mylayoutbox = awful.widget.layoutbox(s)

	mylayoutbox:buttons(awful.util.table.join(
		awful.button({ }, 1, function () awful.layout.inc( 1) end),
		awful.button({ }, 3, function () awful.layout.inc(-1) end),
		awful.button({ }, 4, function () awful.layout.inc( 1) end),
		awful.button({ }, 5, function () awful.layout.inc(-1) end)
	))
	return mylayoutbox
end

function widgets.screennum(s)
		return wibox.widget.textbox("Screen " .. s.index)
end

function widgets.taglist(s)
	return awful.widget.taglist(
		s, awful.widget.taglist.filter.noempty, mytaglist.buttons
	)
end

function widgets.systray(s)
	return {
		wibox.widget.systray(),
		layout = awful.widget.only_on_screen,
		screen = s and s.index or "primary",
	}
end

local function graph_label(graph, label, rotation, fontsize)
	return wibox.widget {
		{
			{
				text = label,
				font = beautiful.fontface and (beautiful.fontface .. " " .. (fontsize or 7)) or beautiful.font,
				widget = wibox.widget.textbox
			},
			direction = rotation or 'east', widget = wibox.container.rotate
		},
		graph,
		layout = wibox.layout.fixed.horizontal
	}
end

function widgets.cpu(s)
	vicious.cache(vicious.widgets.cpu)
	return widgets.graph(s, "CPU", vicious.widgets.cpu, "$1", 1)
end

function widgets.ram(s)
	return widgets.graph(s, "RAM", vicious.widgets.mem, "$1", 1)
end

function widgets.graph(s, label, viciouswidget, viciousformat, interval)
	local graph = wibox.widget {
		width = 60,
		background_color = beautiful.bg_focus,
		color = "linear:0,0:0,20:0,#FF0000:0.3,#FFFF00:0.6," .. beautiful.fg_normal,
		widget = wibox.widget.graph,
	}
	local overlay = wibox.widget {
		align = 'center',
		widget = wibox.widget.textbox
	}
	local callback = function(widget, args)
		overlay.markup = percentage_overlay(args[1], beautiful.bg_normal)
		return args[1]
	end
	vicious.register(graph, viciouswidget, callback, interval or 1)
	table.insert(wlist, graph)

	return {
		layout = awful.widget.only_on_screen,
		screen = s and s.index or "primary",
		graph_label(
			{
				graph,
				overlay,
				layout = wibox.layout.stack
			},
			label,
			nil,
			7
		)
	}
end

local function bar_with_overlay(fg, bg, width, height)
	local progress = wibox.widget {
		max_value = 1,
		color = fg,
		background_color = bg,
		forced_width = width,
		forced_height = height,
		widget        = wibox.widget.progressbar,
	}

	progress.overlay = wibox.widget {
		font = beautiful.fontface and (beautiful.fontface .. " " .. 7) or beautiful.font,
		align = center,
		widget = wibox.widget.textbox
	}

	return {
		progress,
		progress.overlay,
		layout = wibox.layout.stack
	}
end

-- battery
function widgets.battery(s)
	bat1 = bar_with_overlay(beautiful.fg_focus, beautiful.bg_focus, 100, math.floor(s.dpi / 10))
	bat2 = bar_with_overlay(beautiful.fg_focus, beautiful.bg_focus, 100, math.floor(s.dpi / 10))

	combined_bats = graph_label(
		{ bat1,bat2,layout = wibox.layout.fixed.vertical },
		"BAT"
	)

	callback = function (widget, args)
		if args[2] == 0 then
			combined_bats:set_visible(false)
			return ""
		else
			combined_bats.visible = true
			if args[2] < 15 then
				widget.background_color = beautiful.bg_urgent
			else
				widget.background_color = beautiful.bg_focus
			end
			widget.overlay.markup = percentage_overlay(
				args[2], beautiful.bg_normal, args[1] .. " "
			)
			return args[2]
		end
	end

	vicious.register(bat1[1], vicious.widgets.bat, callback, 61, "BAT0")
	table.insert(wlist, bat1[1])
	vicious.register(bat2[1], vicious.widgets.bat, callback, 61, "BAT1")
	table.insert(wlist, bat2[1])

	return combined_bats
end

-- name is ignored and there for backwards compatibility. will simply update all
-- widgets registered with vicious
function widgets.update(name)
	vicious.force(wlist)
end

return setmetatable(widgets, { __call = function(_, ...) return widgets.setup(...) end })

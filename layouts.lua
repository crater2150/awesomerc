local awful = awful
local conf = conf
local modkey = conf.modkey or "Mod4"

local layouts={ mt={} }
local list = {
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
	awful.layout.suit.tile,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,
	awful.layout.suit.floating
}

function layouts.set_list(layout_list)
	list = layout_list
end

function layouts.extend_key_table(globalkeys)
	local layoutkeys = globalkeys or {}
	return awful.util.table.join(layoutkeys,
		awful.key({ modkey }, "j", function ()
			awful.client.focus.byidx( 1)
			if client.focus then client.focus:raise() end
		end),
		awful.key({ modkey }, "k", function ()
			awful.client.focus.byidx(-1)
			if client.focus then client.focus:raise() end
		end),

		-- Layout manipulation
		awful.key({ modkey }, "u", awful.client.urgent.jumpto),
		awful.key({ modkey }, "Tab", function ()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end),
		awful.key({ "Mod1",           }, "Tab", function ()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end),
		awful.key({ modkey,           }, "l",     function ()
			awful.tag.incmwfact( 0.05)
		end),
		awful.key({ modkey,           }, "h",     function ()
			awful.tag.incmwfact(-0.05)
		end),
		awful.key({ modkey, "Shift"   }, "h",     function ()
			awful.tag.incnmaster( 1)
		end),
		awful.key({ modkey, "Shift"   }, "l",     function ()
			awful.tag.incnmaster(-1)
		end),
		awful.key({ modkey, "Control" }, "h",     function ()
			awful.tag.incncol(1)
		end),
		awful.key({ modkey, "Control" }, "l",     function ()
			awful.tag.incncol(-1)
		end),
		awful.key({ modkey,           }, "space", function ()
			awful.layout.inc(list,  1)
		end),
		awful.key({ modkey, "Shift"   }, "space", function ()
			awful.layout.inc(list, -1)
		end),
		awful.key({ modkey, "Shift"   }, "j", function ()
			awful.client.swap.byidx(  1)
		end),
		awful.key({ modkey, "Shift"   }, "k", function ()
			awful.client.swap.byidx( -1)
		end),
		awful.key({ modkey, "Control" }, "j", function ()
			awful.screen.focus_relative( 1)
		end),
		awful.key({ modkey, "Control" }, "k", function ()
			awful.screen.focus_relative(-1)
		end),
		awful.key({ modkey }, "Left",   awful.tag.viewprev       ),
		awful.key({ modkey }, "Right",  awful.tag.viewnext       ),
		awful.key({ modkey }, "Escape", awful.tag.history.restore)
	);
end

layouts.mt.__index = list
layouts.mt.__newindex = list
return setmetatable(layouts, layouts.mt)

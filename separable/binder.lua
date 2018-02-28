-- key bindings
local awful = require("awful")
local beautiful = beautiful

local modkey = conf.modkey or "Mod4"
local mb = require("modalbind")

local globalkeys = {}

app_folders = {
	"/usr/share/applications",
	"/usr/local/share/applications",
	os.getenv("HOME") .. "/.local/applications",
	os.getenv("HOME") .. "/Desktop"
}
local menubar = require("menubar")

menubar.utils.terminal = conf.cmd.terminal -- Set the terminal for applications that require it

local binder = {modal = mb}

local function spawnf(cmd) return function() awful.spawn(cmd) end end
binder.spawn = spawnf

conf.cmd.run = conf.cmd.run or spawnf("dmenu_run")

local function use_layout(layout) return function() awful.layout.set(layout) end end
layoutmap = {
	{"f", use_layout(awful.layout.suit.fair),            "Fair" },
	{"h", use_layout(awful.layout.suit.fair.horizontal), "Fair Horizontal" },
	{"t", use_layout(awful.layout.suit.tile),            "Tile" },
	{"b", use_layout(awful.layout.suit.tile.bottom),     "Tile Bottom" },
	{"m", use_layout(awful.layout.suit.max),             "Maximized" },
	{"F", use_layout(awful.layout.suit.max.fullscreen),  "Fullscreen" },
	{"space", use_layout(awful.layout.suit.floating),    "Float" }
}

layoutsettings = {
	{"h", function () awful.tag.incmwfact(-0.05) end,  "Master smaller" },
	{"l", function () awful.tag.incmwfact( 0.05) end,  "Master bigger" },
	{"H", function () awful.tag.incnmaster( 1) end,    "More masters" },
	{"L", function () awful.tag.incnmaster(-1) end,    "Less masters" },
	{"c", function () awful.tag.incncol( 1) end,       "More columns" },
	{"C", function () awful.tag.incncol(-1) end,       "Less columns" },
}

local function screen_focus_wrapdir(dir)
	return function()
		local target = screen_in_wrapdir(dir)
		awful.screen.focus(target)
	end
end

local function screen_move_client_wrapdir(dir)
	return function(c)
		local target = screen_in_wrapdir(dir)
		awful.client.movetoscreen(c, target)
	end
end

local opposite_dirs = {
	left  = "right",
	right = "left",
	up    = "down",
	down  = "up"
}

function screen_in_wrapdir(dir, _screen)
    local sel = _screen or mouse.screen
    if sel then
        local geomtbl = {}
        for s = 1, screen.count() do
            geomtbl[s] = screen[s].geometry
        end
        local target = awful.util.get_rectangle_in_direction(dir, geomtbl, screen[sel].geometry)
        if not target then
		local new_target = sel
		while new_target do
			target = new_target
			new_target = awful.util.get_rectangle_in_direction(opposite_dirs[dir], geomtbl, screen[target].geometry)
		end
        end

	return target
    end
end

local default_bindings = awful.util.table.join(
	awful.key({ modkey, "Control" }, "r", awesome.restart),
	awful.key({ modkey, "Shift"   }, "q", awesome.quit),
	awful.key({ modkey,           }, "Return", spawnf(conf.cmd.terminal)),

	--{{{ Layout manipulation and client position
	awful.key({ modkey }, "j", function ()
		awful.client.focus.byidx( 1)
		if client.focus then client.focus:raise() end
	end),
	awful.key({ modkey }, "k", function ()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	end),

	-- Layout manipulation
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
	awful.key({ modkey, "Shift"   }, "j", function ()
		awful.client.swap.byidx(  1)
	end),
	awful.key({ modkey, "Shift"   }, "k", function ()
		awful.client.swap.byidx( -1)
	end),
	awful.key({ modkey,           }, "h", screen_focus_wrapdir("left")),
	awful.key({ modkey,           }, "l", screen_focus_wrapdir("right")),
	--}}}

	--{{{ Modal mappings

	awful.key({ modkey            },  "space",  mb.grabf(layoutmap, "Layouts")),
	awful.key({ modkey, "Control" },  "space",  mb.grabf(layoutsettings, "Layout settings", true)),
	--}}}

	--{{{ Audio control

	--awful.key({ }, "XF86AudioLowerVolume",  spawnf("amixer set Master 2%-")),
	--awful.key({ }, "XF86AudioRaiseVolume",  spawnf("amixer set Master 2%+")),
	--awful.key({ }, "XF86AudioMute",         spawnf("amixer set Master toggle")),

	--}}}

	--{{{ Prompt

	awful.key({ modkey }, "r", conf.cmd.run),
	awful.key({ modkey, "Shift" }, "r", menubar.show)
	--}}}
)

function binder.add_bindings(keys)
	globalkeys = awful.util.table.join(globalkeys, keys);
	return binder
end

function binder.add_default_bindings()
	return binder.add_bindings(default_bindings)
end

function binder.clear()
	globalkeys = {}
end


function binder.apply()
	root.keys(globalkeys)
end

local function client_opacity_set(c, default, max, step)
	if c.opacity < 0 or c.opacity > 1 then
		c.opacity = default
	end

	if c.opacity * step < (max-step) * step then
		c.opacity = c.opacity + step
	else
		c.opacity = max
	end
end

local clientkeys = awful.util.table.join(
awful.key({ modkey, "Shift"   }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
awful.key({ modkey,           }, "f",      awful.client.floating.toggle                     ),
awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
awful.key({ modkey, "Shift"   }, "h", screen_move_client_wrapdir("left")),
awful.key({ modkey, "Shift"   }, "l", screen_move_client_wrapdir("right")),
awful.key({ modkey, "Control" }, "o",      function (c) c.ontop = not c.ontop end),
awful.key({ modkey, "Shift"   }, "a",      function (c) c.sticky = not c.sticky end),
awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
awful.key({ modkey,           }, "b",      function (c) c.border_width = c.border_width > 0 and 0 or beautiful.border_width end),
awful.key({ modkey,           }, "Up",     function(c) client_opacity_set(c, 1, 1, 0.1) end),
awful.key({ modkey,           }, "Down",   function(c) client_opacity_set(c, 1, 0, -0.1) end),
awful.key({ }, "XF86Calculater",      awful.client.movetoscreen                        ),
awful.key({ modkey }, "i", function(c)
	require("naughty").notify({ text =
	    string.format("name: %s\nclass: %s\ntype: %s", c["name"], c["class"], c["type"])
	})
    end)
)

root.buttons(awful.util.table.join(
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
))

local clientbuttons = awful.util.table.join(
awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
awful.button({ modkey }, 1, awful.mouse.client.move),
awful.button({ modkey }, 3, awful.mouse.client.resize))

binder.client = {}

function binder.client.buttons()
	return clientbuttons
end

function binder.client.keys()
	return clientkeys
end

function binder.client.add_buttons(buttons)
	clientbuttons = awful.util.table.join(clientbuttons, buttons);
end

function binder.client.add_bindings(keys)
	clientkeys = awful.util.table.join(clientkeys, keys);
end


return binder
-- vim: set fenc=utf-8 tw=80 foldmethod=marker :

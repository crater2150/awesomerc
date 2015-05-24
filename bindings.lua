-- key bindings
local awful = require("awful")
local beautiful = beautiful
local conf = conf
local mpd = require("mpd")
local scratch = require("scratch")

local modkey = conf.modkey or "Mod4"
local mb = require("modalbind")
local calendar = require("calendar")

local globalkeys = {}

app_folders = {
	"/usr/share/applications",
	"/usr/local/share/applications",
	os.getenv("HOME") .. "/.local/applications",
	os.getenv("HOME") .. "/Desktop"
}
local menubar = require("menubar")

menubar.utils.terminal = conf.cmd.terminal -- Set the terminal for applications that require it

local bindings = {modalbind = mb}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

local function spawnf(cmd) return function() awful.util.spawn(cmd) end end
bindings.spawnf = spawnf

conf.cmd.run = conf.cmd.run or spawnf("dmenu_run")

local function mpdserver(host)
	return function() mpd.set_server(host, "6600") end
end

mpdhosts = {
	n = { func = mpdserver("nas.fritz.box"), desc = "NAS" },
	b = { func = mpdserver("berryhorst.fritz.box"), desc = "Berry" },
	l = { func = mpdserver("127.0.0.1"), desc = "Local" }
}

mpdmap = {
	m = { func = mpd.ctrl.toggle, desc = "Toggle" },
	n = { func = mpd.ctrl.next, desc = "Next" },
	N = { func = mpd.ctrl.prev, desc = "Prev" },
	s = { func = spawnf("mpd"), desc = "start MPD" },
	S = { func = spawnf("mpd --kill"), desc = "kill MPD" },
	g = { func = spawnf(conf.cmd.mpd_client), desc = "Gmpc" },
}

mpdpromts = {
	a = { func = mpd.prompt.artist, desc = "artist" },
	b = { func = mpd.prompt.album, desc = "album" },
	t = { func = mpd.prompt.title, desc = "title" },
	r = { func = mpd.prompt.toggle_replace_on_search, desc = "toggle replacing" },
	h = { func = mb.grabf(mpdhosts, "Select MPD host"), desc = "Change host" }
}

progmap = {
	f = { func = spawnf(conf.cmd.browser), desc = "Browser" },
	i = { func = spawnf(conf.cmd.im_client), desc = "IM Client" },
	I = { func = spawnf(conf.cmd.irc_client), desc = "IRC" },
	m = { func = spawnf(conf.cmd.mail_client), desc = "Mail" },
	s = { func = spawnf("steam"), desc = "Steam" }
}

docmap = {
	u = { func = spawnf("docopen ~/doc/uni pdf"), desc = "Uni-Dokumente" },
	b = { func = spawnf("docopen ~/books pdf epub mobi txt lit html htm"), desc = "Bücher" },
	t = { func = spawnf("dmtexdoc"), desc = "Texdoc" },
	j = { func = spawnf("dmjavadoc"), desc = "Javadoc" }
}

calendarmap = {
	o = { func = function() calendar:next() end, desc = "Next" },
	i = { func = function() calendar:prev() end, desc = "Prev" },
	onClose = function() calendar:hide() end
}

local function use_layout(layout) return function() awful.layout.set(layout) end end
layoutmap = {
	f = { func = use_layout(awful.layout.suit.fair),            desc ="Fair" },
	h = { func = use_layout(awful.layout.suit.fair.horizontal), desc ="Fair Horizontal" },
	t = { func = use_layout(awful.layout.suit.tile),            desc ="Tile" },
	b = { func = use_layout(awful.layout.suit.tile.bottom),     desc ="Tile Bottom" },
	m = { func = use_layout(awful.layout.suit.max),             desc ="Maximized" },
	F = { func = use_layout(awful.layout.suit.max.fullscreen),  desc ="Fullscreen" },
	Space = { func = use_layout(awful.layout.suit.floating),    desc ="Float" }
}

layoutsettings = {
	l = { func = function () awful.tag.incmwfact( 0.05) end, desc = "Master bigger" },
	h = { func = function () awful.tag.incmwfact(-0.05) end, desc = "Master smaller" },
	H = { func = function () awful.tag.incnmaster( 1) end, desc = "More masters" },
	L = { func = function () awful.tag.incnmaster(-1) end, desc = "Less masters" },
	c = { func = function () awful.tag.incncol( 1) end, desc = "More columns" },
	C = { func = function () awful.tag.incncol(-1) end, desc = "Less columns" },
}

function bindings.setup()
	globalkeys = awful.util.table.join(
	awful.key({ }, "Pause", spawnf('wmselect')), -- old keyboard
	awful.key({ }, "Print", spawnf('wmselect')), -- new keyboard

	awful.key({ modkey, "Control" }, "r", awesome.restart),
	awful.key({ modkey, "Shift"   }, "q", awesome.quit),
	awful.key({ modkey,           }, "Return", spawnf(conf.cmd.terminal)),

	awful.key({ modkey, "Control" }, "n", awful.client.restore),
	awful.key({ modkey, "Shift"   }, "n",
	function()
		local tag = awful.tag.selected()
		for i=1, #tag:clients() do
			awful.client.restore(tag:clients()[i])
		end
	end),

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
	awful.key({ modkey,           }, "h", function ()
		awful.screen.focus_relative( 1)
	end),
	awful.key({ modkey,           }, "l", function ()
		awful.screen.focus_relative(-1)
	end),
	--}}}

	--{{{ Modal mappings

	awful.key({ modkey            },  "m",  mb.grabf(mpdmap, "MPD", true)),
	awful.key({ modkey, "Shift"   },  "m",  mb.grabf(mpdpromts, "MPD - Search for")),
	awful.key({ modkey            },  "c",  mb.grabf(progmap, "Commands")),
	awful.key({ modkey            },  "d",  mb.grabf(docmap, "Documents")),
	awful.key({ modkey            },  "space",  mb.grabf(layoutmap, "Layouts")),
	awful.key({ modkey, "Shift"   },  "space",  mb.grabf(layoutsettings, "Layout settings", true)),
	--}}}

	--{{{ Audio control

	awful.key({ }, "XF86AudioLowerVolume",  spawnf("amixer set Master 2%-")),
	awful.key({ }, "XF86AudioRaiseVolume",  spawnf("amixer set Master 2%+")),
	awful.key({ }, "XF86AudioMute",         spawnf("amixer set Master toggle")),
	awful.key({ }, "XF86AudioPlay",         mpd.ctrl.toggle),
	awful.key({ }, "XF86AudioNext",         mpd.ctrl.next),
	awful.key({ }, "XF86AudioPrev",         mpd.ctrl.prev),

	--}}}

	-- {{{ teardrops
	awful.key({ }, "F12", function ()
		scratch.drop(conf.cmd.terminal,"center","center", 0.99, 0.7)
	end ),
	awful.key({ modkey }, "`", function ()
		scratch.drop("gpms","bottom","center", 0.99, 0.4)
	end ),
	-- }}}

	--{{{ Prompt

	awful.key({ modkey }, "r", conf.cmd.run),
	awful.key({ modkey, "Shift" }, "r", menubar.show),

	awful.key({ modkey }, "s", spawnf("dmsearch")),

	--}}}

	--{{{ misc. XF86 Keys

	awful.key({ }, "XF86Sleep",  spawnf("s2ram")),
	awful.key({ }, "XF86Away",  spawnf("xlock")),
	awful.key({ }, "XF86TouchpadToggle",  spawnf("touchpad")),
	awful.key({ "Shift" }, "XF86TouchpadToggle",  spawnf("wacomtouch")),

	--}}}

	-- calendar {{{
	awful.key({ modkey,           },  "y",  function()
		calendar:show()
		mb.grab(calendarmap, "Calendar", true)
	end)
	)

	--}}}
end

function bindings.add_bindings(keys)
	globalkeys = awful.util.table.join(globalkeys, keys);
end

function bindings.apply()
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

clientkeys = awful.util.table.join(
    awful.key({ modkey, "Shift"   }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "h", function (c)
	    awful.client.movetoscreen(c, mouse.screen + 1)
    end),
    awful.key({ modkey, "Shift"   }, "l", function (c)
	    awful.client.movetoscreen(c, mouse.screen - 1)
    end),
    awful.key({ modkey, "Control" }, "o",      function (c) c.ontop = not c.ontop end),
    awful.key({ modkey, "Shift"   }, "a",      function (c) c.sticky = not c.sticky end),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "b",      function (c) c.border_width = c.border_width > 0 and 0 or beautiful.border_width end),
    awful.key({ modkey,           }, "Up",     function(c) client_opacity_set(c, 1, 1, 0.1) end),
    awful.key({ modkey,           }, "Down",   function(c) client_opacity_set(c, 1, 0, -0.1) end),
    awful.key({ }, "XF86Calculater",      awful.client.movetoscreen                        )
)

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

return bindings
-- vim: set fenc=utf-8 tw=80 foldmethod=marker :

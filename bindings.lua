-- key bindings
local awful = require("awful")
local conf = conf
local mpd = require("mpd")
local scratch = require("scratch")

local modkey = conf.modkey or "Mod4"
local mb = require("modalbind")
local calendar = require("calendar")

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

mpdmap = {
	m = { func = mpd.ctrl.toggle, desc = "Toggle" },
	n = { func = mpd.ctrl.next, desc = "Next" },
	N = { func = mpd.ctrl.prev, desc = "Prev" },
	s = { func = spawnf("mpd"), desc = "start MPD" },
	S = { func = spawnf("mpd --kill"), desc = "kill MPD" },
	g = { func = spawnf(conf.cmd.mpd_client), desc = "Gmpc" }
}
mpdpromts = {
	a = { func = mpd.prompt.artist, desc = "artist" },
	b = { func = mpd.prompt.album, desc = "album" },
	t = { func = mpd.prompt.title, desc = "title" },
	r = { func = mpd.prompt.toggle_replace_on_search, desc = "toggle replacing" }
}

progmap = {
	f = { func = spawnf(conf.cmd.browser), desc = "Browser" },
	i = { func = spawnf(conf.cmd.im_client), desc = "IM Client" },
	I = { func = spawnf(conf.cmd.irc_client), desc = "IRC" },
	m = { func = spawnf(conf.cmd.mail_client), desc = "Mail" }
}

docmap = {
	u = { func = spawnf("docopen ~/uni pdf"), desc = "Uni-Dokumente" },
	b = { func = spawnf("docopen ~/books pdf epub mobi txt lit html htm"), desc = "Bücher" },
	t = { func = spawnf("dtexdoc"), desc = "Texdoc" }
}

calendarmap = {
	o = { func = function() calendar:next() end, desc = "Next" },
	i = { func = function() calendar:prev() end, desc = "Prev" },
	q = { func = function() calendar:prev() end, desc = "Close" }
}


adapters = { u = "wwan", w = "wlan", b = "bluetooth" }
local function rfkill(cmd)
	map = {}
	for key, adapter in pairs(adapters) do
		map[key] = { func = spawnf("sudo rfkill "..cmd.." "..adapter), desc = adapter }
	end
	return map
end

connectmap = {
	u = { func = spawnf("umts"), desc = "umts" },
	w = { func = spawnf("wlanacpi"), desc = "wlan" }
}

wirelessmap = {
	b = { func = mb.grabf(rfkill("block"),"Block"), desc = "block" },
	u = { func = mb.grabf(rfkill("unblock"),"Unblock"), desc = "unblock" },
	c = { func = mb.grabf(connectmap, "Connect"), desc = "connect" }
}

function bindings.extend_key_table(globalkeys)
	return awful.util.table.join(globalkeys or {},
	awful.key({ }, "Pause", spawnf('wmselect')),

	awful.key({ modkey, "Control" }, "r", awesome.restart),
	awful.key({ modkey, "Shift"   }, "q", awesome.quit),
	awful.key({ modkey,           }, "Return", spawnf(conf.cmd.terminal)),

	--{{{ Modal mappings

	awful.key({ modkey            },  "m",  mb.grabf(mpdmap, "MPD", true)),
	awful.key({ modkey, "Shift"   },  "m",  mb.grabf(mpdpromts, "MPD - Search for")),
	awful.key({ modkey            },  "c",  mb.grabf(progmap, "Commands")),
	awful.key({ modkey            },  "w",  mb.grabf(wirelessmap, "Wifi")),
	awful.key({ modkey            },  "d",  mb.grabf(docmap, "Documents")),
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
	awful.key({ }, "Print", function ()
		scratch.drop("gpulse-mixer","top","center", 0.99, 0.4)
	end ),
	-- }}}

	--{{{ Prompt

	awful.key({ modkey }, "r", conf.cmd.run),
	awful.key({ modkey, "Shift" }, "r", spawnf("dmenu_desktopfile")),

	awful.key({ modkey }, "s", spawnf("dmsearch")),

	--}}}

	--{{{ misc. XF86 Keys

	awful.key({ }, "XF86Sleep",  spawnf("s2ram")),
	awful.key({ }, "XF86Away",  spawnf("xlock")),
	awful.key({ }, "XF86TouchpadToggle",  spawnf("touchpad")),

	--}}}

	-- calendar {{{
	awful.key({ modkey            },  "y",  function() calendar:toggle() end),
	awful.key({ modkey, "Shift"   },  "y",  function()
		calendar.wibox.visible = true
		mb.grab(calendarmap, "Calendar", true)
	end)
	)

	--}}}
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
    awful.key({ modkey, "Control" }, "o",      function (c) c.ontop = not c.ontop end),
    awful.key({ modkey, "Shift"   }, "a",      function (c) c.sticky = not c.sticky end),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
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

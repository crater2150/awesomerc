-- key bindings
local awful = awful
local conf = conf
local mpd = require("mpd")
local scratch = require("scratch")

local modkey = conf.modkey or "Mod4"
local mb = require("modalbind")

local bindings = {mb = mb}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
awful.button({ }, 4, awful.tag.viewnext),
awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

local function spawnf(cmd) return function() awful.util.spawn(cmd) end end

mpdmap = {
	name = "MPD",
	m = mpd.ctrl.toggle,
	n = mpd.ctrl.next,
	N = mpd.ctrl.prev,
	s = spawnf("mpd"),
	S = spawnf("mpd --kill"),
	g = spawnf(conf.cmd.mpd_client)
}
mpdpromts = {
	name = "MPD PROMPTS",
	a = mpd.prompt.artist,
	b = mpd.prompt.album,
	t = mpd.prompt.title,
	r = mpd.prompt.toggle_replace_on_search
}

progmap = {
	name = "PROGRAMS",
	f = spawnf(conf.cmd.browser),
	i = spawnf(conf.cmd.im_client),
	I = spawnf(conf.cmd.irc_client),
	m = spawnf(conf.cmd.mail_client)
}

adapters = { u = "wwan", w = "wlan", b = "bluetooth" } 
function rfkill(cmd)
	map={ name = string.upper(cmd) }
	for key, adapter in pairs(adapters) do
		map[key] = spawnf("sudo rfkill "..cmd.." "..adapter)
	end
	return map
end
wirelessmap = {
	name = "RFKILL",
	b = mb.grabf(rfkill("block")),
	u = mb.grabf(rfkill("unblock"))
}

function bindings.extend_and_register_key_table(globalkeys)
	local totalkeys = globalkeys or {}
	totalkeys = awful.util.table.join(totalkeys,
	awful.key({ }, "Menu", spawnf('wmselect')),

	awful.key({ modkey, "Control" }, "r", awesome.restart),
	awful.key({ modkey, "Shift"   }, "q", awesome.quit),
	awful.key({ modkey,           }, "Return", spawnf(conf.cmd.terminal)),

	--{{{ Modal mappings

	awful.key({ modkey            },  "m",  mb.grabf(mpdmap, true)),
	awful.key({ modkey, "Shift"   },  "m",  mb.grabf(mpdpromts)),
	awful.key({ modkey            },  "c",  mb.grabf(progmap)),
	awful.key({ modkey            },  "w",  mb.grabf(wirelessmap)),
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
		scratch.drop("urxvtc -e ncmpcpp","bottom","center", 0.99, 0.4)
	end ),
	awful.key({ }, "Print", function ()
		scratch.drop("galsamixer","top","center", 0.99, 0.4)
	end ),
	-- }}}

	--{{{ Prompt

	awful.key({ modkey }, "r", spawnf("dmenu_run")),

	awful.key({ modkey }, "s", spawnf("dmsearch")),

	--}}}

	--{{{ misc. XF86 Keys

	awful.key({ }, "XF86Sleep",  spawnf("s2ram")),
	awful.key({ }, "XF86Away",  spawnf("xlock")),
	awful.key({ }, "XF86TouchpadToggle",  spawnf("touchpad"))
	)

	--}}}

	-- Set keys
	root.keys(totalkeys)
end


function client_opacity_set(c, default, max, step)
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
    awful.key({ modkey,           }, "a",      function (c) c.sticky = not c.sticky end),
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

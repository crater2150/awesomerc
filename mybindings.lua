-- key bindings
local awful = require("awful")
local conf = conf

local modkey = conf.modkey or "Mod4"
local binder = binder or require("separable.binder")
local mb = binder.modal

local mpd = require("separable.mpd")
local scratch = require("scratch")
local calendar = require("separable.calendar")

local myglobalkeys = {}

local function mpdserver(host)
	return function()
		mpd.set_server(host, "6600")
		awful.util.spawn("mpd-host set " .. host .. " 6600")
	end
end

local mpdhosts = {
	n = { func = mpdserver("nas"), desc = "NAS" },
	b = { func = mpdserver("berryhorst"), desc = "Berry" },
	l = { func = mpdserver("127.0.0.1"), desc = "Local" }
}

local mpdmap = {
	m = { func = mpd.ctrl.toggle, desc = "Toggle" },
	n = { func = mpd.ctrl.next, desc = "Next" },
	N = { func = mpd.ctrl.prev, desc = "Prev" },
	s = { func = binder.spawn("mpd"), desc = "start MPD" },
	S = { func = binder.spawn("mpd --kill"), desc = "kill MPD" },
	g = { func = binder.spawn(conf.cmd.mpd_client), desc = "Gmpc" },
}

local mpdpromts = {
	a = { func = mpd.prompt.artist, desc = "artist" },
	b = { func = mpd.prompt.album, desc = "album" },
	t = { func = mpd.prompt.title, desc = "title" },
	r = { func = mpd.prompt.toggle_replace_on_search, desc = "toggle replacing" },
	h = { func = mb.grabf(mpdhosts, "Select MPD host"), desc = "Change host" }
}

local progmap = {
	f = { func = binder.spawn(conf.cmd.browser), desc = "Browser" },
	i = { func = binder.spawn(conf.cmd.im_client), desc = "IM Client" },
	I = { func = binder.spawn(conf.cmd.irc_client), desc = "IRC" },
	t = { func = binder.spawn("telegram"), desc = "Telegram" },
	m = { func = binder.spawn(conf.cmd.mail_client), desc = "Mail" },
	s = { func = binder.spawn("steam"), desc = "Steam" }
}

local docmap = {
	u = { func = binder.spawn("docopen ~/doc/uni pdf"), desc = "Uni-Dokumente" },
	b = { func = binder.spawn("docopen ~/books pdf epub mobi txt lit html htm"), desc = "Bücher" },
	t = { func = binder.spawn("dmtexdoc"), desc = "Texdoc" },
	j = { func = binder.spawn("dmjavadoc"), desc = "Javadoc" }
}

local reloadmap = {
	r = { func = awesome.restart, desc = "Awesome, full restart" },
	b = { func = function()
		binder.add_bindings(require("mybindings"))
	end, desc = "Bindings" },
}

local calendarmap = {
	o = { func = function() calendar:next() end, desc = "Next" },
	i = { func = function() calendar:prev() end, desc = "Prev" },
	onClose = function() calendar:hide() end
}


local myglobalkeys = awful.util.table.join(
	awful.key({ }, "Pause", binder.spawn('wmselect')),
	awful.key({ }, "Print", binder.spawn('dmscrot')),

	--{{{ Modal mappings

	awful.key({ modkey            },  "m",  mb.grabf(mpdmap, "MPD", true)),
	awful.key({ modkey, "Shift"   },  "m",  mb.grabf(mpdpromts, "MPD - Search for")),
	awful.key({ modkey            },  "c",  mb.grabf(progmap, "Commands")),
	awful.key({ modkey            },  "d",  mb.grabf(docmap, "Documents")),

	awful.key({ modkey, "Control" },  "r",  mb.grabf(reloadmap, "Reload")),
	--}}}

	-- {{{ scratch drop
	awful.key({ }, "F12", function ()
		scratch.drop(conf.cmd.terminal,"center","center", 0.99, 0.7)
	end ),
	-- }}}

	--{{{ dmenu prompts

	awful.key({ modkey }, "s", binder.spawn("dmsearch")),
	awful.key({ modkey }, "x", binder.spawn("dmxrandr")),
	awful.key({ modkey, "Shift" }, "x", binder.spawn("xd --dmenu")),

	--}}}

	--{{{ misc. XF86 Keys

	awful.key({         }, "Scroll_Lock",   binder.spawn("xlock")),
	awful.key({         }, "XF86Explorer",  binder.spawn("touchpad")),
	awful.key({ "Shift" }, "XF86Explorer",  binder.spawn("wacomtouch")),

	awful.key({         }, "XF86AudioPlay", mpd.ctrl.toggle),
	awful.key({         }, "XF86AudioNext", mpd.ctrl.next),
	awful.key({         }, "XF86AudioPrev", mpd.ctrl.prev),

	--}}}

	-- calendar {{{
	awful.key({ modkey },  "y",
	function()
		calendar:show()
		mb.grab(calendarmap, "Calendar", true)
	end
	)
	--}}}
)

return myglobalkeys

-- vim: set fenc=utf-8 tw=80 foldmethod=marker :

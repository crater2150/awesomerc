-- key bindings
local awful = require("awful")
local conf = conf

local modkey = conf.modkey or "Mod4"
local binder = binder or require("separable.binder")
local mb = binder.modal

local mpd = require("separable.mpd")
local handy = require("handy")
--local calendar = require("separable.calendar")

local myglobalkeys = {}

local function mpdserver(host)
	return function()
		mpd.set_server(host, "6600")
		awful.util.spawn("mpd-host set " .. host .. " 6600")
	end
end

local mpdhosts = {
	{"n", mpdserver("nas"),        "NAS" },
	{"b", mpdserver("berryhorst"), "Berry" },
	{"l", mpdserver("127.0.0.1"),  "Local" }
}

local mpdmap = {
	{"m", mpd.ctrl.toggle,                   "Toggle" },
	{"n", mpd.ctrl.next,                     "Next" },
	{"N", mpd.ctrl.prev,                     "Prev" },
	{"s", binder.spawn("mpd"),               "start MPD" },
	{"S", binder.spawn("mpd --kill"),        "kill MPD" },
	{"g", binder.spawn(conf.cmd.mpd_client), "Gmpc" },
}

local mpdpromts = {
	{"a", mpd.prompt.artist, "artist" },
	{"b", mpd.prompt.album,  "album" },
	{"t", mpd.prompt.title,  "title" },
	{"r", mpd.prompt.toggle_replace_on_search,   "toggle replacing" },
	{"h", mb.grabf(mpdhosts, "Select MPD host"), "Change host" }
}

local progmap = {
	{"f", binder.spawn(conf.cmd.browser),     "Browser" },
	{"i", binder.spawn(conf.cmd.irc_client),  "IRC" },
	{"t", binder.spawn("telegram"),           "Telegram" },
	{"w", binder.spawn("wire"),               "Wire" },
	{"m", binder.spawn(conf.cmd.mail_client), "Mail" },
	{"s", binder.spawn("steam"),              "Steam" }
}

local home = os.getenv("HOME")
local docmap = {
	{"p", binder.spawn("docopen " .. home .. "/ pdf"), "Alle PDF-Dokumente" },
	{"b", binder.spawn("docopen " .. home .. "/doc/books pdf epub mobi txt lit html htm"), "Bücher" },
	{"t", binder.spawn("dmtexdoc"), "Texdoc" },
	{"j", binder.spawn("dmjavadoc"), "Javadoc" }
}

local notifymap = {
	{"m", binder.spawn("newmails -p"), "Show unread mails" },
}

--local calendarmap = {
--	o = { function() calendar:next() end, "Next" },
--	i = { function() calendar:prev() end, "Prev" },
--	onClose = function() calendar:hide() end
--}


local myglobalkeys = awful.util.table.join(
	awful.key({ }, "Pause", binder.spawn('wmselect')),
	awful.key({ }, "Print", binder.spawn('dmscrot')),

	--{{{ Modal mappings

	awful.key({ modkey            },  "m",  mb.grabf(mpdmap, "MPD", true)),
	awful.key({ modkey, "Shift"   },  "m",  mb.grabf(mpdpromts, "MPD - Search for")),
	awful.key({ modkey            },  "c",  mb.grabf(progmap, "Commands")),
	awful.key({ modkey            },  "d",  mb.grabf(docmap, "Documents")),
	awful.key({ modkey            },  "n",  mb.grabf(notifymap, "Notifications")),
	--}}}

	-- {{{ handy console
	awful.key({ }, "F12", function ()
		handy(conf.cmd.terminal, awful.placement.centered, 0.9, 0.7)
	end ),
	-- }}}

	--{{{ dmenu prompts

	awful.key({ modkey }, "s", binder.spawn("dmsearch")),
	awful.key({ modkey }, "x", binder.spawn("dmxrandr")),
	awful.key({ modkey, "Shift" }, "x", binder.spawn("xd --dmenu")),
	awful.key({ modkey }, "z", binder.spawn("dmumount")),

	--}}}

	--{{{ misc. XF86 Keys

	awful.key({         },         "Scroll_Lock", binder.spawn("xlock")),
	awful.key({ modkey  },         "BackSpace",   binder.spawn("xlock")),
	awful.key({ modkey, "Shift" }, "BackSpace",   binder.spawn("feierabend")),

	awful.key({         }, "XF86Explorer",  binder.spawn("touchpad")),
	awful.key({ "Shift" }, "XF86Explorer",  binder.spawn("wacomtouch")),

	awful.key({         }, "XF86AudioPlay", mpd.ctrl.toggle),
	awful.key({         }, "XF86AudioNext", mpd.ctrl.next),
	awful.key({         }, "XF86AudioPrev", mpd.ctrl.prev),

	awful.key({ modkey }, "y", binder.spawn("copyq toggle"))

	--}}}
)

return myglobalkeys

-- vim: set fenc=utf-8 tw=80 foldmethod=marker :

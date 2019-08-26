-- key bindings
local awful = require("awful")
local conf = conf

local naughty = require("naughty")

local modkey = conf.modkey or "Mod4"
local binder = binder or require("separable.binder")
local mb = binder.modal

local mpd = require("separable.mpd")
local handy = require("handy")
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
	{"separator", "Search" },
	{"a", mpd.prompt.artist, "artist" },
	{"b", mpd.prompt.album,  "album" },
	{"t", mpd.prompt.title,  "title" },
	{"j", mpd.prompt.jump,  "jump" },
	{"r", mpd.prompt.toggle_replace_on_search,   "toggle replacing" },
	{"h", mb.grabf{keymap=mpdhosts, name="Select MPD host"}, "Change host" }
}
local mprismap = {
	{"m", binder.spawn("playerctl play-pause"), "Toggle" },
	{"n", binder.spawn("playerctl next"),       "Next" },
	{"N", binder.spawn("playerctl previous"),   "Prev" },
	{"s", binder.spawn("playerctl stop"),       "Prev" },
}

local progmap = {
	{"f", binder.spawn("firefox"),         "Firefox" },
	{"q", binder.spawn("qutebrowser"),     "Qutebrowser" },
	--{"b", binder.spawn(conf.cmd.browser),     "Browser" },
	{"i", binder.spawn(conf.cmd.irc_client),  "IRC" },
	{"m", binder.spawn(conf.cmd.mail_client), "Mail" },
	{"t", binder.spawn("telegram"),           "Telegram" },
	{"w", binder.spawn("wire"),               "Wire" },
	{"s", binder.spawn("steam"),              "Steam" },
	{"n", binder.spawn("netflix"),            "Netflix" }
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

local myglobalkeys = awful.util.table.join(
	awful.key({ }, "Pause", binder.spawn('rofi -show window')),
	awful.key({ }, "Print", binder.spawn('dmscrot')),

	--{{{ Modal mappings

	awful.key({ modkey            },  "m",  function()
		awful.spawn.easy_async("which playerctl && playerctl -p spotify status", function(stdout, stderr, reason, exitcode)
			if exitcode > 0 then
				mb.grab{keymap=mpdmap, name="MPD", stay_in_mode=true}
			else
				mb.grab{keymap=mprismap, name="Spotify", stay_in_mode=true}
			end
		end)
	end),
	--awful.key({ modkey, "Shift"   },  "m",  mb.grabf(mpdpromts, "MPD - Search for")),
	awful.key({ modkey            },  "c",  mb.grabf{keymap=progmap, name="Commands"}),
	awful.key({ modkey            },  "d",  mb.grabf{keymap=docmap, name="Documents"}),
	awful.key({ modkey            },  "n",  function()
		if naughty.is_suspended() then
			naughty.resume()
			naughty.notify({ text = "Notifications enabled", timeout = 2 })
		else
			naughty.notify({ text = "Notifications disabled", timeout = 2 })
			naughty.suspend()
		end
	end),
	--}}}

	-- {{{ handy console
	awful.key({ }, "F12", function ()
		handy("urxvt -e tmux", awful.placement.centered, 0.9, 0.7)
	end ),
	awful.key({ modkey }, "x", function ()
		handy("urxvt -e ikhal", awful.placement.centered, 0.9, 0.7)
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

	awful.key({ modkey }, "y", binder.spawn("copyq toggle")),
	awful.key({ modkey }, "/", binder.spawn("rofi -show calc -modi calc -no-show-match -no-sort"))

	--}}}
)

return myglobalkeys

-- vim: set fenc=utf-8 tw=80 foldmethod=marker :

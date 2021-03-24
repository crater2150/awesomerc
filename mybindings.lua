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

local wibars = {}
for s in screen do
	table.insert(wibars, s.leftwibar)
	table.insert(wibars, s.rightwibar)
end
local lockhl = require("lockhl")
lockhl:setup(wibars, '#F2C740')

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
	{"g", binder.spawn(conf.cmd.mpd_client), "Gmpc", stay_in_mode=false },
	{"separator", "Search" },
	{"a", mpd.prompt.artist, "artist" },
	{"b", mpd.prompt.album,  "album" },
	{"t", mpd.prompt.title,  "title" },
	{"j", mpd.prompt.jump,  "jump" },
	{"r", mpd.prompt.toggle_replace_on_search,   "toggle replacing" },
	{"h", mb.grabf{keymap=mpdhosts, name="Select MPD host"},
		"Change host", stay_in_mode=false }
}

local playerctl = "playerctl"
if conf.mprisplayer then
	playerctl = playerctl .. " -p " .. conf.mprisplayer
end

local mprismap = {
	{"m", binder.spawn(playerctl .. " play-pause"), "Toggle" },
	{"n", binder.spawn(playerctl .. " next"),       "Next" },
	{"N", binder.spawn(playerctl .. " previous"),   "Prev" },
	{"s", binder.spawn(playerctl .. " stop"),       "Prev" },
}

local messengermap = {
	{"e", binder.spawn("launch-elements"),    "Element" },
	{"i", binder.spawn(conf.cmd.irc_client),  "IRC" },
	{"m", binder.spawn(conf.cmd.mail_client), "Mail" },
	{"r", binder.spawn("rocketchat"),         "RocketChat" },
	{"s", binder.spawn("signal-desktop"),     "Signal" },
	{"t", binder.spawn("telegram-desktop"),   "Telegram" },
	{"w", binder.spawn("wire"),               "Wire" },
}

local function brightnesskey(key)
	return {key, binder.spawn("xbacklight -set " .. key .. "0"),  key .. "0%" }
end
local brightnessmap = {
	brightnesskey("1"),
	brightnesskey("2"),
	brightnesskey("3"),
	brightnesskey("4"),
	brightnesskey("5"),
	brightnesskey("6"),
	brightnesskey("7"),
	brightnesskey("8"),
	brightnesskey("9"),
	{"0", binder.spawn("xbacklight -set 100"),  "100%" },
}

local progmap = {
	{"f", binder.spawn("firefox"),         "Firefox" },
	{"q", binder.spawn("qutebrowser"),     "Qutebrowser" },
	--{"b", binder.spawn(conf.cmd.browser),     "Browser" },
	{"s", binder.spawn("steam"),              "Steam" },
	{"n", binder.spawn("netflix"),            "Netflix" },
	{"m", mb.grabf{keymap=messengermap, name="⇒ Messengers"}, "Messengers" },
}

local home = os.getenv("HOME")
local docmap = {
	{"p", binder.spawn("docopen -e pdf " .. home), "Alle PDF-Dokumente" },
	{"b", binder.spawn("docopen -e pdf -e epub -e mobi -e txt -e lit -e html -e htm " .. home .. "/doc/books "), "Bücher" },
	{"t", binder.spawn("dmtexdoc"), "Texdoc" },
	{"j", binder.spawn("dmjavadoc"), "Javadoc" }
}

local notifymap = {
	{"m", binder.spawn("newmails -p"), "Show unread mails" },
}

local myglobalkeys = awful.util.table.join(
	awful.key({ }, "Pause", binder.spawn('rofi -show window')),
	--awful.key({ }, "Print", binder.spawn('dmscrot')),
	awful.key({ }, "Print", binder.spawn('flameshot gui')),

	--{{{ Modal mappings

	awful.key({ modkey            },  "m",  function()
		awful.spawn.easy_async_with_shell(
		"which playerctl && " .. playerctl .. " status",
		function(stdout, stderr, reason, exitcode)
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
	awful.key({ modkey            },  "b",  mb.grabf{keymap=brightnessmap, name="Brightness"}),
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
	awful.key({ }, "F12", nil, function ()
		handy("alacritty --class handy -e tmux", awful.placement.centered, 0.9, 0.7, nil, "handy")
	end ),
	awful.key({ modkey }, "x", function ()
		handy("alacritty --class handy -e ikhal", awful.placement.centered, 0.9, 0.7, 'single', "handy")
	end ),
	awful.key({ modkey }, "a", function ()
		handy("pavucontrol", awful.placement.centered, 0.6, 0.8, 'single')
	end ),
	-- }}}

	--{{{ dmenu prompts

	awful.key({ modkey }, "s", binder.spawn("dmsearch")),
	awful.key({ modkey }, "x", binder.spawn("dmxrandr")),
	awful.key({ modkey, "Shift" }, "x", binder.spawn("xd --dmenu")),
	awful.key({ modkey }, "z", binder.spawn("dmumount")),
	awful.key({ modkey }, "p", nil, binder.spawn("passmenu --type")),
	awful.key({ modkey, "Shift" }, "p", binder.spawn("passmenu")),

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
	awful.key({ modkey }, "/", binder.spawn("rofi -show calc -modi calc -no-show-match -no-sort")),
	awful.key({ modkey }, "e", binder.spawn('rofi -show emoji')),
	awful.key( {}, "Num_Lock", lockhl("Num")),
	awful.key( {}, "Caps_Lock", lockhl("Caps"))

	--}}}
)

return myglobalkeys

-- vim: set fenc=utf-8 tw=80 foldmethod=marker :

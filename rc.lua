-- libraries {{{
local awful = require("awful")
              require("awful.autofocus")
beautiful   = require("beautiful")
naughty     = require("naughty")
conf        = require("localconf")
              require("errors")
inspect = require("lib.inspect")
-- }}}

beautiful.init(awful.util.getdir("config") .. "/theme.lua")

require("tapestry")

-- {{{ Logging
log = require("talkative")
log.add_logger(log.loggers.stdio, log.level.DEBUG)
log.add_logger(log.loggers.naughty, log.level.WARNING)
-- }}}

-- {{{ Tags

tags = require('tags')
tags.setup()

-- }}}

-- {{{ widgets
widgets = require("widgets")
for s in screen do
	local ltop = widgets.container(s, "left", "top")
	local rtop = widgets.container(s, "right", "top")
	local lbottom = widgets.container(s, "left", "bottom")
	local rbottom = widgets.container(s, "right", "bottom")

	local clock = widgets.add.clock("clock", ltop)

	widgets.add.layout_indicator(lbottom)
	widgets.add.taglist("tags", lbottom)

	local mail = widgets.add.mail("mail", rbottom, { os.getenv("HOME") .. "/.maildir/uber" }, "bottom_right", "uber")
	mail:set_left(15)

	widgets.add.cpu("cpu", rtop)
	widgets.add.spacer(rtop)
	widgets.add.battery("int", rtop, "BAT0")
	widgets.add.spacer(rtop)
	widgets.add.battery("ext", rtop, "BAT1")
	widgets.add.spacer(rtop)
	widgets.add.wifi("wlan", rtop, "wlan0")
	widgets.add.spacer(rtop)
	widgets.add.systray(rtop)

	widgets.set_spacer_text("  ◈  ")
end
-- }}}

audiowheel = require("audiowheel")-- { bg = "#ffff00aa" }


-- {{{ Key bindings

binder = require("separable.binder")
binder.modal.set_location("bottom_left")
--binder.modal.set_x_offset(18)

binder.add_default_bindings()
binder.add_bindings(tags.create_bindings())
binder.add_bindings(require("mybindings"))

binder.add_bindings(awful.util.table.join(
    awful.key({}, "XF86AudioRaiseVolume", function() audiowheel:up() end),
    awful.key({}, "XF86AudioLowerVolume", function() audiowheel:down() end),
    awful.key({}, "XF86AudioMute",        function() audiowheel:toggle() end)
))

binder.apply()

-- }}}

require("rules")
require("signals")

--
-- vim: fdm=marker
--

-- libraries {{{
local awful = require("awful")
              require("awful.autofocus")
beautiful   = require("autobeautiful")
naughty     = require("naughty")
conf        = require("localconf")
              require("errors")
inspect = require("lib.inspect")
-- }}}

-- {{{ Logging
log = require("separable.simplelog")
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

	local mail1 = widgets.add.mail("mail_me", rbottom, { os.getenv("HOME") .. "/.maildir/me" }, "bottom_right", "me")
	mail1:set_left(15)
	local mail2 = widgets.add.mail("mail_uber", rbottom, { os.getenv("HOME") .. "/.maildir/uber" }, "bottom_right", "uber")
	mail2:set_left(15)

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

-- {{{ Key bindings

binder = require("separable.binder")
binder.modal.set_location("bottom","left")
binder.modal.set_x_offset(18)

binder.add_default_bindings()
binder.add_bindings(tags.create_bindings())
binder.add_bindings(require("mybindings"))

binder.apply()

-- }}}

require("rules")
require("signals")

--
-- vim: fdm=marker
--

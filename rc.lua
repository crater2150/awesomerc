-- libraries {{{
awful           = require("awful")
awful.rules     = require("awful.rules")
                  require("awful.autofocus")
beautiful       = require("autobeautiful")
naughty         = require("naughty")
conf            = require("localconf")
                  require("errors")
inspect = require("inspect")
-- }}}

layouts = require('layouts')

-- {{{ Logging
log = require("simplelog")
log.add_logger(log.loggers.stdio, log.level.DEBUG)
log.add_logger(log.loggers.naughty, log.level.WARNING)
-- }}}

-- {{{ Tags

tags = require('tags')
tags.setup()

-- }}}

-- {{{ widgets
widgets = require("widgets")
for s = 1, screen.count() do
	local ltop = widgets.layout(s, "left", "top")
	local rtop = widgets.layout(s, "right", "top")
	local lbottom = widgets.layout(s, "left", "bottom")
	local rbottom = widgets.layout(s, "right", "bottom")

	local clock = widgets.add.clock("clock", rtop)
	clock:set_right(10)

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

bindings = require("bindings")
bindings.setup()
bindings.modalbind.set_x_offset(18)
bindings.add_bindings(tags.create_bindings())
bindings.apply()
-- }}}

-- {{{ rules
rules = require("rules")
rules.setup()
-- }}}

require("signals")

--
-- vim: fdm=marker
--

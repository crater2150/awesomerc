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
log.add_logger(log.loggers.stdio, log.level.debug)
log.add_logger(log.loggers.naughty, log.level.warn)

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

	widgets.add.clock("clock", ltop)

	widgets.add.layout(lbottom)
	widgets.add.taglist("tags", lbottom)

	widgets.add.mail("mail_me", rbottom, { os.getenv("HOME") .. "/.maildir/me" }, "bottom_right")
	widgets.add.spacer(rbottom)
	widgets.add.mail("mail_uber", rbottom, { os.getenv("HOME") .. "/.maildir/uber" }, "bottom_right")

	widgets.add.cpu("cpu", rtop)
	widgets.add.spacer(rtop)
	widgets.add.battery("int", rtop, "BAT0")
	widgets.add.spacer(rtop)
	widgets.add.battery("ext", rtop, "BAT1")
	widgets.add.spacer(rtop)
	widgets.add.wifi("wlan", rtop, "wlan0")
	widgets.add.spacer(rtop)
	widgets.add.systray(rtop)

	widgets.set_spacer_text("   ◈   ")
end
-- }}}

-- {{{ Key bindings
globalkeys = {}
globalkeys = tags.extend_key_table(globalkeys);

bindings = require("bindings")
bindings.modalbind.set_x_offset(18)
globalkeys = bindings.extend_key_table(globalkeys)

root.keys(globalkeys)
-- }}}

-- {{{ rules
rules = require("rules")
rules.setup()
-- }}}

require("signals")

--
-- vim: fdm=marker
--

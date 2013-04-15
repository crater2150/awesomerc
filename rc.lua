-- libraries {{{
awful           = require("awful")
awful.rules     = require("awful.rules")
                  require("awful.autofocus")
wibox           = require("wibox")
beautiful       = require("autobeautiful")
naughty         = require("naughty")
conf            = require("localconf")
                  require("errors")
-- }}}

layouts = require('layouts')

-- {{{ Logging
log = require("simplelog")
log.add_logger(log.loggers.stdio, 0)
log.add_logger(log.loggers.naughty, 2)

-- }}}

-- {{{ Tags

tags = require('tags')
tags.setup()
-- }}}

-- {{{ widgets
widgets = require("widgets")
widgets.setup()
for s = 1, screen.count() do
	local ltop = widgets.layout(s,"left","top")
	local rtop = widgets.layout(s,"right","top")
	local lbottom = widgets.layout(s,"left","bottom")

	-- {{{
	widgets.add.mail("mail_me", s, ltop, { os.getenv("HOME") .. "/.maildir/me" })
	widgets.add.spacer(ltop)
	widgets.add.mail("mail_uber", s, ltop, { os.getenv("HOME") .. "/.maildir/uber" })
	widgets.add.spacer(ltop)
	widgets.add.clock("clock", s, ltop)

	widgets.add.layout(s, lbottom)
	widgets.add.taglist("tags", s, lbottom)

	widgets.add.cpu("cpu", s, rtop)
	widgets.add.spacer(rtop)
	widgets.add.battery("bat", s, rtop, "BAT0")
	widgets.add.spacer(rtop)
	widgets.add.battery("slice", s, rtop, "BAT1")
	widgets.add.spacer(rtop)
	widgets.add.wifi("wlan", s, rtop, "wlan0")
	widgets.add.spacer(rtop)
	widgets.add.systray(s, rtop)

	widgets.set_spacer_text("    ◈    ")
end
-- }}}

-- {{{ Key bindings
globalkeys = {}
globalkeys = layouts.extend_key_table(globalkeys);
globalkeys = tags.extend_key_table(globalkeys);

bindings = require("bindings")
bindings.extend_and_register_key_table(globalkeys)
bindings.mb.set_x_offset(18)
-- }}}

-- {{{ rules
rules = require("rules")
rules.setup()
-- }}}

require("signals")

--
-- vim: fdm=marker

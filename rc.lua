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
	widgets.add.mail(s, ltop, { os.getenv("HOME") .. "/.maildir/" })
	widgets.add.spacer(ltop)
	widgets.add.clock(s, ltop)

	widgets.add.layout(s, lbottom)
	widgets.add.taglist(s, lbottom)

	widgets.add.cpu(s, rtop)
	widgets.add.spacer(rtop)
	widgets.add.battery(s, rtop, "BAT0")
	widgets.add.spacer(rtop)
	widgets.add.battery(s, rtop, "BAT1")
	widgets.add.spacer(rtop)
	widgets.add.wifi(s, rtop, "wlan0")
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

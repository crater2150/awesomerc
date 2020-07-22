-- libraries {{{
local awful = require("awful")
              require("awful.autofocus")
beautiful   = require("beautiful")
naughty     = require("naughty")
conf        = require("localconf")
              require("errors")
inspect = require("lib.inspect")
wibox = require("wibox")
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
awful.screen.connect_for_each_screen(function(s)
    widgets(s).left(
	{
	    widgets.screennum(s),
	    widgets.spacer,
	    widgets.layout(s),
	    widgets.taglist(s),
	    layout = wibox.layout.fixed.horizontal
	},
	wibox.widget.textclock()
	)

    widgets(s).right(
	{
	    widgets.cpu(),
	    widgets.ram(),
	    widgets.battery(s),
	    widgets.systray(s),
	    layout = wibox.layout.fixed.horizontal
	},
	widgets.mail({ os.getenv("HOME") .. "/.maildir/uber" }, "bottom_right", "uber")
	)
end)
-- }}}

audiowheel = require("audiowheel")-- { bg = "#ffff00aa" }


-- {{{ Key bindings

binder = require("separable.binder")
binder.modal.set_location("bottom_left")
binder.modal.hide_default_options()
--binder.modal.set_x_offset(18)

binder.add_default_bindings()
binder.add_reloadable(tags.create_bindings)
mybindings = awful.util.getdir("config") .. "/mybindings.lua"
binder.add_reloadable(function() return dofile(mybindings) end)

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

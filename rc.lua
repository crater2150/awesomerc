terminal = "sakura -e screen"
editor_cmd = "sakura -e vim"
modkey = "Mod4"

-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful")
require("naughty")
require("teardrop")
require("obvious.battery")
require("obvious.popup_run_prompt")
require("vicious")



-- Themes define colours, icons, and wallpapers
beautiful.init("/home/crater2150/.config/awesome/zenburn/theme.lua")


-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.floating
}

dofile "./helpers.lua"
dofile "./tags.lua"
dofile "./wibox.lua"
dofile "./bindings.lua"
dofile "./rules.lua"
dofile "./signals.lua"



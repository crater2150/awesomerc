terminal = "urxvtc -e screen"
editor_cmd = "urxvt -e vim"
modkey = "Mod4"
hyper = "Mod3"

-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful")
require("naughty")
require("teardrop")
require("obvious.popup_run_prompt")
require("vicious")
require("aweswt")

-- Themes define colours, icons, and wallpapers
beautiful.init("/home/crater2150/.config/awesome/zenburn/theme.lua")


-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.floating
}

MY_PATH = os.getenv("HOME") .. "/.config/awesome/"
dofile (MY_PATH .. "helpers.lua")
dofile (MY_PATH .. "tags.lua")
dofile (MY_PATH .. "wibox.lua")
dofile (MY_PATH .. "bindings.lua")
dofile (MY_PATH .. "rules.lua")
dofile (MY_PATH .. "signals.lua")
dofile (MY_PATH .. "wp.lua")

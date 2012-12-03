
-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful")
require("naughty")
require("teardrop")
require("obvious.popup_run_prompt")
require("vicious")
require("rodentbane.rodentbane")

MY_PATH  = os.getenv("HOME") .. "/.config/awesome/"

dofile (MY_PATH .. "localconf.lua")

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

awful.util.spawn("wmname LG3D")

dofile (MY_PATH .. "/tags.lua")
dofile (MY_PATH .. "/boxes.lua")
dofile (MY_PATH .. "/bindings.lua")
dofile (MY_PATH .. "/rules.lua")
dofile (MY_PATH .. "/signals.lua")
-- dofile (MY_PATH .. "uzbl.lua")

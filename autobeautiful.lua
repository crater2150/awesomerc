local beautiful = require("beautiful")
local gears     = require("gears")
local awful     = require("awful")

beautiful.init(awful.util.getdir("config") .. "/theme.lua")

local wallpaperrc = awful.util.getdir("config") .. "/wallpaperrc.lua"
local f=io.open(wallpaperrc,"r")
if f~=nil then
    io.close(f)
    require("wallpaperrc")
    for s in screen do
	set_wallpaper(s)
    end
    screen.connect_signal("property::geometry", set_wallpaper)
elseif beautiful.wallpaper then
    f = io.open(beautiful.wallpaper)
    if  f ~= nil then
	io.close(f)
	screen.connect_signal("property::geometry", function(s)
	    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
	end)
    end
end

return beautiful

local beautiful = require("beautiful")
local gears     = require("gears")
local awful     = require("awful")

beautiful.init(awful.util.getdir("config") .. "/theme.lua")

local wallpaperrc = awful.util.getdir("config") .. "/wallpaperrc"
local f=io.open(wallpaperrc,"r")
if f~=nil then
	io.close(f)
	dofile(wallpaperrc)
elseif beautiful.wallpaper then
    f = io.open(beautiful.wallpaper)
    if  f ~= nil then
	io.close(f)
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
    end
end

return beautiful

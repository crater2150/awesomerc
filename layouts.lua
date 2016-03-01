local awful = require("awful")
local conf = conf

local layouts={ mt={} }
local list = {
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
	awful.layout.suit.tile,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,
	awful.layout.suit.floating
}

function layouts.set_list(layout_list)
	list = layout_list
end


layouts.mt.__index = list
layouts.mt.__newindex = list
return setmetatable(layouts, layouts.mt)

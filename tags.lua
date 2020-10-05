-- tags
local awful = require("awful")
local conf = conf
local modkey = conf.modkey or "Mod4"

local tags={}

awful.layout.layouts = {
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
	awful.layout.suit.tile,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,
	awful.layout.suit.floating,
	-- awful.layout.suit.magnifier,
	-- awful.layout.suit.corner.nw,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}


local function getfunc_viewonly(i)
	return function ()
		local screen = awful.screen.focused()
		local tag = screen.tags[i]
		if tag then
			tag:view_only()
		end
	end
end

local function getfunc_viewtoggle(i)
	return function ()
		local screen = awful.screen.focused()
		local tag = screen.tags[i]
		if tag then
			awful.tag.viewtoggle(tag)
		end
	end
end

local function getfunc_moveto(i)
	return function ()
		if client.focus then
			local tag = client.focus.screen.tags[i]
			if tag then
				client.focus:move_to_tag(tag)
			end
		end
	end
end

local function getfunc_clienttoggle(i)
	return function ()
		if client.focus then
			local tag = client.focus.screen.tags[i]
			if tag then
				client.focus:toggle_tag(tag)
			end
		end
	end
end

local tagdef = {
	{"1"},
	{"2", { layout = awful.layout.suit.max }},
	{"3"},
	{"4", { layout = awful.layout.suit.max }},
	{"5"},
	{"6"},
	{"7"},
	{"8"},
	{"9"},
	{"0"},
	{"F1", { layout = awful.layout.suit.max }},
	{"F2"},
	{"F3"},
	{"F4", { layout = awful.layout.suit.max }},
}

function defaultlayout(s)
	if s.geometry.width > s.geometry.height then
		return awful.layout.suit.fair
	else
		return awful.layout.suit.fair.horizontal
	end
end

function tags.setup()
	awful.screen.connect_for_each_screen(function(s)
		for _,t in ipairs(tagdef) do
			awful.tag.add(t[1], awful.util.table.join(
				{screen = s},
				t[2] or { layout = defaultlayout(s) }
			))
		end
		s.tags[1]:view_only()
	end)
end

function tags.create_bindings()
	local tagkeys = {}

	-- Bind all number keys and F-keys to tags
	for i = 1, 21 do
		if i < 10 then
			k = "#" .. i + 9 -- number keys 1-9
		elseif i == 10 then
			k = "#19" -- zero
		elseif i > 10 then
			k = "F" .. i - 10 -- F keys
		end
		tagkeys = awful.util.table.join(tagkeys,
		awful.key( { modkey }, k, getfunc_viewonly(i)),
		awful.key( { modkey, "Control" }, k, getfunc_viewtoggle(i)),
		awful.key( { modkey, "Shift" }, k, getfunc_moveto(i)),
		awful.key( { modkey, "Control", "Shift" }, k, getfunc_clienttoggle(i))
		)
	end

	-- keys for all tags
	tagkeys = awful.util.table.join(tagkeys,
	awful.key({ modkey }, "u", awful.client.urgent.jumpto),
	awful.key({ modkey }, "Left",   awful.tag.viewprev       ),
	awful.key({ modkey }, "Right",  awful.tag.viewnext       ),
	awful.key({ modkey }, "Escape", awful.tag.history.restore)
	)
	return tagkeys;
end

return tags

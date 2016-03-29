-- tags
local awful = require("awful")
local conf = conf
local modkey = conf.modkey or "Mod4"

local tags={ mt={} }

local function getfunc_viewonly(i)
	return function ()
		local screen = mouse.screen
		if tags[screen][i] then
			awful.tag.viewonly(tags[screen][i])
		end
	end
end

local function getfunc_viewtoggle(i)
	return function ()
		local screen = mouse.screen
		if tags[screen][i] then
			awful.tag.viewtoggle(tags[screen][i])
		end
	end
end

local function getfunc_moveto(i)
	return function ()
		if client.focus and tags[client.focus.screen][i] then
			awful.client.movetotag(tags[client.focus.screen][i])
		end
	end
end

local function getfunc_clienttoggle(i)
	return function ()
		if client.focus and tags[client.focus.screen][i] then
			awful.client.toggletag(tags[client.focus.screen][i])
		end
	end
end

local defaultsetup = {
    {"1:⚙"},
    { name = "2:⌘",   layout = awful.layout.suit.max  },
    { name = "3:☻",   layout = awful.layout.suit.tile, mwfact = 0.20, ncol = 2, nmaster = 2},
    { name = "4:✉",   layout = awful.layout.suit.max  },
    {"5:☑"},
    {"6:♫"},
    {"7:☣"},
    {"8:☕"},
    {"9:⚂"},
    {"0:☠"},
    { name = "F1:☭",   layout = awful.layout.suit.max },
    {"F2:♚"},
    {"F3:♛"},
    {"F4:♜"}--,
    -- {"F5:♝"},
    -- {"F6:♞"},
    -- {"F7:♟"},
    -- {"F8:⚖"},
    -- {"F9:⚛"},
    -- {"F10:⚡"},
    -- {"F11:⚰"},
    -- {"F12:⚙"}
}

local list = {}

function tags.setup(setuptable)
	local setup = setuptable or defaultsetup
	for s = 1, screen.count() do
		list[s] = {}
		for i, t in ipairs(setup) do
			local layout = t.layout or conf.default_layout or awful.layout.suit.fair
			local name = t.name or t[1]
			list[s][i] = awful.tag.new({name}, s, layout)[1];
			list[s][i].selected = false
			if(t.mwfact) then
				awful.tag.setmwfact(t.mwfact,list[s][i])
			end
			if(t.ncol) then
				awful.tag.setncol(t.ncol,list[s][i])
			end
			if(t.nmaster) then
				awful.tag.setnmaster(t.nmaster,list[s][i])
			end
		end
		list[s][1].selected = true
	end
end

function tags.create_bindings()
	-- Compute the maximum number of digit we need, limited to 22
	keynumber = 0
	for s = 1, screen.count() do
		keynumber = math.min(22, math.max(#(list[s]), keynumber));
	end

	local tagkeys = {}

	-- Bind all key numbers to tags, using keycodes
	for i = 1, keynumber do
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

tags.mt.__index = list
tags.mt.__newindex = list
return setmetatable(tags, tags.mt)

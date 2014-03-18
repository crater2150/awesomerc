-- MPD control and playlist editing
-- prompts require dmpc script
local M = {}
local conf = conf
local awful = awful
local log = log

-- local functions
local dmenu, notify, mpc

local defaults = {}
local settings = {}

defaults.replace_on_search = true

for key, value in pairs(defaults) do
    settings[key] = value
end

mpc = function(command)
	awful.util.spawn("mpc " .. command)
end

-- {{{ mpd.ctrl submodule

M.ctrl = {}

M.ctrl.toggle = function ()
	mpc("toggle")
end

M.ctrl.play = function ()
	mpc("play")
end

M.ctrl.pause = function ()
	mpc("pause")
end

M.ctrl.next = function ()
	mpc("next")
end

M.ctrl.prev = function ()
	mpc("prev")
end

-- }}}

-- {{{ mpd.prompt submodule

local clear_before = conf.mpd_prompt_clear_before == nil and
	true or
	conf.mpd_prompt_clear_before 

M.prompt = {}

M.prompt.artist = function()
	dmenu("-a")
end

M.prompt.album = function()
	dmenu("-a -b")
end


M.prompt.title = function()
	dmenu("-a -b -t")
end
M.prompt.title = title

function dmenu(opts)
	awful.util.spawn("dmpc " .. (clear_before and "-r" or "-R") .. " " .. opts)
end

M.prompt.replace_on_search = function(bool)
	clear_before = bool
end

M.prompt.toggle_replace_on_search = function()
	clear_before = not clear_before
	notify("MPD prompts now " ..(
			clear_before and "replace" or "add to"
			).. " the playlist")
end

-- }}}

-- {{{ notify wrapper
notify = function(stext)
	if not (naughty == nil) then
		naughty.notify({
			text= stext
		})
	end
end
--}}}

return M

-- vim: set fenc=utf-8 tw=80 foldmethod=marker :

local awful = awful
local M = {}
local type = ""

-- local functions
local show, mpc_play_search, notify

local defaults = {}
local settings = {}

defaults.host = "127.0.0.1"
defaults.port = 6600
defaults.replace_on_search = true

for key, value in pairs(defaults) do
    settings[key] = value
end

-- {{{ basic functions

-- }}}

-- {{{ mpd.ctrl submodule

M.ctrl = {}

M.ctrl.toggle = function ()
	awful.util.spawn("mpc toggle")
end

M.ctrl.play = function ()
	awful.util.spawn("mpc play")
end

M.ctrl.pause = function ()
	awful.util.spawn("mpc pause")
end

M.ctrl.next = function ()
	awful.util.spawn("mpc next")
end

M.ctrl.prev = function ()
	awful.util.spawn("mpc prev")
end

M.ctrl.clear = function ()
	awful.util.spawn("mpc clear")
end

-- }}}

-- {{{ mpd.prompt submodule

local clear_before = cfg.mpd_prompt_clear_before == nil and
	true or
	cfg.mpd_prompt_clear_before 

M.prompt = {}

M.prompt.artist = function()
	type = "artist"
	show()
end

M.prompt.album = function()
	type = "album"
	show()
end


M.prompt.title = function()
	type = "title"
	show()
end
M.prompt.title = title

M.prompt.replace_on_search = function(bool)
	clear_before = bool
end

M.prompt.toggle_replace_on_search = function()
	clear_before = not clear_before
	notify("MPD prompts now " ..(
			clear_before and "replace" or "add to"
			).. " the playlist")
end

function show()
	obvious.popup_run_prompt.set_prompt_string("Play ".. type .. ":")
	obvious.popup_run_prompt.set_cache("/mpd_ ".. type);
	obvious.popup_run_prompt.set_run_function(mpc_play_search)
	obvious.popup_run_prompt.run_prompt()
end

function mpc_play_search(s)
	if clear_before then M.ctrl.clear() end
	awful.util.spawn("mpc search " .. type .. " | mpc add;  mpc play")
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

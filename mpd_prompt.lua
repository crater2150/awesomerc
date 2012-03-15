local awful     = awful
local obvious   = obvious
local naughty   = naughty
local keygrabber = keygrabber
local io = io
local pairs = pairs

local M = {}

local type = ""
local clear_before = true

local keymap = {}

local show,
	mpc_play_search

M.grabber = function()
	keygrabber.run(function(mod, key, event)
		if event == "release" then return true end
		keygrabber.stop()
		if keymap[key] then keymap[key]() end
		return true
	end)
end

M.artist = function()
	type = "artist"
	show()
end

M.album = function()
	type = "album"
	show()
end


M.title = function()
	type = "title"
	show()
end
M.title = title

M.replace_on_search = function(bool)
	clear_before = bool
end

M.toggle_replace_on_search = function()
	clear_before = not clear_before
	if not (naughty == nil) then
		naughty.notify({
			text="MPD prompts now " ..(
			clear_before and "replace" or "add to"
			).. " the playlist"
		})
	end
end

function show()
	obvious.popup_run_prompt.set_prompt_string("Play ".. type .. ":")
	obvious.popup_run_prompt.set_run_function(mpc_play_search)
	obvious.popup_run_prompt.run_prompt()
end

function mpc_play_search(s)
	if clear_before then awful.util.spawn("mpc clear") end
	awful.util.spawn_with_shell("mpc search ".. type .." '" .. s .. "' | mpc add")
	awful.util.spawn("mpc play");
end

keymap = {
    a = M.artist,
    A = M.album,
    t = M.title,
    r = M.toggle_replace_on_search
}

return M

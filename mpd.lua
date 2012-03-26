local luampd = require("luampd")
local M = {}

local type = ""

-- local functions
local show, mpc_play_search, notify

local conn = nil

local defaults = {}
local settings = {}

defaults.host = "127.0.0.1"
defaults.port = 6600
defaults.replace_on_search = true

for key, value in pairs(defaults) do
    settings[key] = value
end

-- {{{ basic functions

M.connect = function ()
	print("Connecting to mpd")
	conn = luampd:new({
		hostname = settings.hostname,
		port = settings.port,
		debug = false
	})
end

M.disconnect = function()
	if conn ~= nil then conn:close() end
	conn = nil
end

M.ensure_connection = function()
	-- luampd throws SOCKET_ERRORs all the time. catch them and reconnect
	if conn == nil or not pcall(conn:status()) then M.connect() end
end

-- }}}

-- {{{ mpd.ctrl submodule

M.ctrl = {}

M.ctrl.toggle = function ()
	M.ensure_connection()
	local status = conn:status()
	if status["state"] == "pause" or status["state"] == "stop" then
		conn:play()
	else
		conn:pause()
	end
end

M.ctrl.play = function ()
	M.ensure_connection()
	conn:play()
	-- TODO widget updating
end

M.ctrl.pause = function ()
	M.ensure_connection()
	conn:pause()
	-- TODO widget updating
end

M.ctrl.next = function ()
	M.ensure_connection()
	conn:next_()
	-- TODO widget updating
end

M.ctrl.prev = function ()
	M.ensure_connection()
	conn:previous()
	-- TODO widget updating
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
	M.ensure_connection()
	if clear_before then conn:clear() end
	local result, num = conn:isearch(type, s)
	notify("Found " .. (num) .. " matches");
	conn:iadd(result)
	conn:play()
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

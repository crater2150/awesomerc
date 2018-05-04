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
defaults.host = "127.0.0.1"
defaults.port = "6600"

for key, value in pairs(defaults) do
    settings[key] = value
end

for key, value in pairs(conf.mpd) do
    settings[key] = value
end

-- {{{ local helpers
local function mpc(command)
	log.spawn("mpc -h " .. settings.host .. " -p " .. settings.port .. " " .. command)
end

local function dmenu(opts)
	log.spawn("dmpc -h " .. settings.host .. " -p " .. settings.port .. " " ..
		(settings.replace_on_search and "-r" or "-R") .. " " .. opts)
end

local function notify(stext)
	if not (naughty == nil) then
		naughty.notify({
			text= stext
		})
	end
end
--}}}

M.set_server = function(host, port)
	settings.host = host
	settings.port = port
	notify("Using mpd server " .. settings.host .. ":" .. settings.port)
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

M.prompt.jump = function()
	dmenu("-j")
end

M.prompt.title = title

M.prompt.replace_on_search = function(bool)
	settings.replace_on_search = bool
end

M.prompt.toggle_replace_on_search = function()
	settings.replace_on_search = not settings.replace_on_search
	notify("MPD prompts now " ..(
			settings.replace_on_search and "replace" or "add to"
			).. " the playlist")
end

-- }}}


return M

-- vim: set fenc=utf-8 tw=80 foldmethod=marker :

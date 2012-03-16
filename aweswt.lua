-- aweswt.lua
-- Application switcher using dmenu
--

local M = {}

-- local functions
local get_out, get_input, _switch, assemble_command

local defaults = {}
local settings = {}

defaults.bg_focus = theme.bg_focus
defaults.fg_focus = theme.fg_focus
defaults.bg_normal = theme.bg_normal
defaults.fg_normal = theme.fg_normal
defaults.font = string.gsub(theme.font, " ","-")
defaults.menu_cmd = "dmenu -nf %q -nb %q -sf %q -sb %q -p 'Switch to' -fn %q -i"

local command

for key, value in pairs(defaults) do
    settings[key] = value
end



-- switch with window titles
M.switch = function()
	_switch(true)
end

-- switch with client instance and class
M.switch_class = function()
	_switch(false)
end

-- {{{ option setters

M.set_bg_focus = function (color)
	settings.bg_focus = color or defaults.bg_focus
	assemble_command()
end

M.set_fg_focus = function (color)
	settings.fg_focus = color or defaults.fg_focus
	assemble_command()
end

M.set_bg_normal = function (color)
	settings.bg_normal = color or defaults.bg_normal
	assemble_command()
end

M.set_fg_normal = function (color)
	settings.fg_normal = color or defaults.fg_normal
	assemble_command()
end

M.set_font = function (font)
	settings.font = font or defaults.font
	assemble_command()
end

M.set_menu_command = function (command)
	settings.menu_cmd = command or defaults.menu_cmd
	assemble_command()
end

-- }}}

-- {{{ io functions 
get_out = function (a)
	local  f = io.popen(a)
	t = {}
	for line in f:lines() do
		table.insert(t, line)
	end
	return t
end

get_input = function (a)
	s1 = 'echo "' .. a .. '" | ' .. command
	return get_out(s1)
end

-- }}}

-- {{{ main worker function
_switch = function(use_name)
	local clients = client.get()

	if table.getn(clients) == 0 then 
		return
	end

	local client_list_table = {}
	local apps = {}

	for key, client in pairs(clients) do
		local app

		if use_name then
			app = client['name']
		else
			app = key .. ':' .. client['instance'] .. '.' .. client['class']
		end

		table.insert(client_list_table, app)
		apps[app] = client
	end

	table.sort(client_list_table, function(a, b)
		return string.lower(a) < string.lower(b)
	end)
	local client_list = table.concat(client_list_table, "\n")

	local client_selected = apps[get_input(client_list)[1]]
	if client_selected then
		local ctags = client_selected:tags()
		awful.tag.viewonly(ctags[1])
		client.focus = client_selected
		client_selected:raise()
	end
end
-- }}}

assemble_command = function()
	command = string.format(settings.menu_cmd,
		settings.fg_normal,
		settings.bg_normal,
		settings.fg_focus,
		settings.bg_focus,
		settings.font)
end

assemble_command()
return M

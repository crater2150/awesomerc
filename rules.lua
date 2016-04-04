local rules = { mt={} }
local awful = require("awful")
local tags = tags
local beautiful = require("beautiful")
local binder = binder or require("separable.binder")

local rule_screen = 1

local function popup_urgent(message)
	return function(client)
		client:connect_signal("property::urgent", function (c)
			if c.urgent and not c.focus then
				naughty.notify({ text=message })
			end
		end)
	end
end

local function setup(self)
	awful.rules.rules = {
		-- All clients will match this rule.
		{
			rule = { },
			properties = {
				border_width = beautiful.border_width,
				border_color = beautiful.border_normal,
				focus = awful.client.focus.filter,
				raise = true,
				minimized = false,
				size_hints_honor = false,
				keys = binder.client.keys(),
				buttons = binder.client.buttons(),
			},
			-- print name and class of new windows for debugging purposes
			callback = function(c)
				print("-----------\nnew client\n")
				if (c["name"] ~= nil) then
					print("name: " .. c["name"])
				end
				if (c["class"] ~= nil) then
					print("class: " .. c["class"])
				end
			end
		},
		{
			rule = { class = "Passprompt" },
			properties = { ontop = true, focus = true}
		},
		{
			rule = { class = "Sm" },
			properties = {
				--ontop = true,
				fullscreen = true,
				border_width = 0
			}
		},
		{
			rule_any = { class = {
				"pinentry", "Passprompt", "MPlayer"
			}},
			properties = { floating = true, size_hints_honor = true }
		},
		{
			rule = { class = "Firefox", instance = "Navigator" },
			properties = {
				tag = tags[rule_screen][2],
				floating = false, minimized = false
			},
		},
		{
			rule_any = { class = {"Pidgin"}, instance = {"Weechat"} },
			properties = {
				tag = tags[rule_screen][3], opacity = 0.8
			},
			callback = popup_urgent("new chat message")
		},
		{
			rule = { role = "buddy_list" },
			callback = awful.client.setmaster
		},
		{
			rule = { class = "Steam", name = "Friends" },
			properties = {
				tag = tags[rule_screen][3],
			},
			callback = awful.client.setmaster
		},
		{
			rule = { class = "Steam", name = "Chat" },
			properties = {
				tag = tags[rule_screen][3],
			},
			callback = awful.client.setslave
		},
		{
			rule = { class = "Steam", name = "Steam" },
			properties = {
				tag = tags[rule_screen][11],
			}
		},
		{
			rule = { class = "Telegram" },
			properties = {
				tag = tags[rule_screen][3],
			},
			callback = awful.client.setslave
		},
		{
			rule_any = { role ={  "conversation" }, instance = { "Weechat" } },
			callback = awful.client.setslave
		},
		{
			rule = { class = "Irssi"},
			properties = {
				tag = tags[rule_screen][3]
			} ,
			callback = awful.client.setslave
		},
		{
			rule = { class = "Claws-mail" },
			properties = {
				tag = tags[rule_screen][4]
			}
		},
		{
			rule = { instance = "Gmutt" },
			properties = {
				tag = tags[rule_screen][4]
			}
		},
		{
			rule = { instance = "Gcanto" },
			properties = {
				tag = tags[rule_screen][5]
			}
		},
		{
			rule = { instance = "Gncmpcpp" },
			properties = {
				tag = tags[rule_screen][6]
			}
		},
		{
			rule = { class = "Gmpc" },
			properties = {
				tag = tags[rule_screen][6]
			}
		},
		{
			rule = { class = "Deluge" },
			properties = {
				tag = tags[rule_screen][7]
			}
		},
		{
			rule = { class = "Pdfpc" },
			properties = {
				size_hints_honor = true,
				float = true,
				fullscreen = true
			}
		},
		{
			rule = { class = "Cellwriter" },
			properties = {
				tag = tags[rule_screen][1],
				ontop = true,
				size_hints_honor = true,
				float = true,
				sticky = true,
				fullscreen = true
			}
		},
		{
			rule = { class = "Xhtop" },
			properties = {
				tag = tags[rule_screen][22]
			}
		},
		{
			rule = { class = "Dmenu" },
			properties = {
				opacity = 0.8
			}
		},
		{
			rule = { class = "URxvt" },
			properties = {
				opacity = 0.8
			}
		},
		{
			rule = { class = "Gvim" },
			properties = {
				opacity = 0.8
			}
		},
		{
			rule = { class = "feh", name = "timetable" },
			properties = {
				tag = tags[rule_screen][13],
				skip_taskbar = true,
				type = desktop,
				focusable = false,
				border_width = 0
			}
		},
		{
			rule = { instance = "Awesomelog" },
			properties = {
				tag = tags[rule_screen][14]
			}
		},
		{
			rule = { class = "GLSlideshow" },
			properties = {

			}
		}
	}
end

rules.setup = setup

rules.mt.__call = setup

return setmetatable(rules, rules.mt)

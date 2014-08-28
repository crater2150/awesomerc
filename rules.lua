local rules = { mt={} }
local awful = awful
local conf = conf
local tags = tags
local beautiful = beautiful
local inspect=require("inspect")

local rule_screen = conf.rule_screen or 1

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
				keys = clientkeys,
				minimized = false,
				buttons = clientbuttons 
			},
			-- print name and class of new windows for debugging purposes
			callback = function(c)
				if(c["name"] ~= nil and c["class"] ~= nil) then
					print("-----------\nnew client\n")
					print("name: " .. c["name"])
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
			}
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
			properties = {
				master = true 
			}
		},
		{
			rule = { class = "Steam", name = "Friends" },
			properties = {
				tag = tags[rule_screen][3],
			}
		},
		{
			rule = { class = "Steam", name = "Chat" },
			properties = {
				tag = tags[rule_screen][3],
			},
			callback = function(c)
				awful.client.setslave(c)
				callback = popup_urgent("new chat message")(c)
			end
		},
		{
			rule = { class = "Steam", name = "Steam" },
			properties = {
				tag = tags[rule_screen][11],
			}
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

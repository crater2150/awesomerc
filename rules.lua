local awful = require("awful")
awful.rules = require("awful.rules")

local beautiful = require("beautiful")
local binder = binder or require("separable.binder")

-- create a notification when given client becomes urgent
local function popup_urgent(client, message)
      client:connect_signal("property::urgent", function (c)
	    if c.urgent and not c.focus then
		  naughty.notify({ text=message })
	    end
      end)
end

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
		  screen = awful.screen.preferred,
		  placement = awful.placement.no_overlap+awful.placement.no_offscreen
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
		  floating = true,
		  size_hints_honor = true,
		  --		--ontop = true,
		  fullscreen = true,
		  --		border_width = 0
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
		  screen = 1, tag = "2",
		  floating = false, minimized = false
	    },
      },
      {
	    rule_any = { class = {"Pidgin"}, instance = {"Weechat"} },
	    properties = {
		  tag = "3", opacity = 0.8
	    },
	    callback = function(c) popup_urgent(c, "new chat message") end
      },
      {
	    rule = { role = "buddy_list" },
	    callback = awful.client.setmaster
      },
      {
	    rule = { class = "Eclipse" },
	    properties = {
		  float = false
	    }
      },
      {
	    rule = { class = "Steam", name = "Friends" },
	    properties = {
		  tag = "3"
	    },
	    callback = awful.client.setmaster
      },
      {
	    rule = { class = "Steam", name = "Chat" },
	    properties = {
		  tag = "3"
	    },
	    callback = awful.client.setslave
      },
      {
	    rule = { class = "Steam", name = "Steam" },
	    properties = {
		  tag = "F1"
	    }
      },
      {
	    rule = { class = "Telegram" },
	    properties = {
		  tag = "3"
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
		  tag = "3"
	    } ,
	    callback = awful.client.setslave
      },
      {
	    rule = { instance = "Gmutt" },
	    properties = {
		  tag = "4"
	    }
      },
      {
	    rule = { class = "Gmpc" },
	    properties = {
		  tag = "6"
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
	    rule = { instance = "Awesomelog" },
	    properties = {
		  tag = "F4"
	    }
      }
}

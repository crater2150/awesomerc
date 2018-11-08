local awful = require("awful")
awful.rules = require("awful.rules")

local beautiful = require("beautiful")
local binder = binder or require("separable.binder")
local log = require("talkative")

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
	    -- log name and class of new windows for debugging purposes
	    callback = function(c)
		  log("-----------\nnew client\n")
		  if (c["name"] ~= nil) then
		        log("name: " .. c["name"])
		  end
		  if (c["class"] ~= nil) then
		        log("class: " .. c["class"])
		  end
		  if (c["type"] ~= nil) then
		        log("type: " .. c["type"])
		  end
	    end
      },
      { rule = { class = "qutebrowser" }, properties = { tag = "2" } },
      --{ rule = { name = "", class = "jetbrains-idea", type = "dialog" },
      --      properties = { placement = false },
      --      callback = function(c)
      --  	  c:connect_signal("unfocus", function() client.focus = c end)
      --      end
      --},
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
		  "pinentry", "Passprompt", "copyq"
	    }},
	    properties = { floating = true, size_hints_honor = true }
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
		  screen = 1, tag = "8",
		  floating = false
	    }
      },
      {
	    rule = { class = "Eclipse", name = nil, type = "dialog" },
	    properties = {
		  screen = 2, tag = "8",
		  floating = false
	    }
      },
      {
	    rule = { class = "Eclipse", name = ".*", type = "dialog" },
	    properties = {
		  screen = 1, tag = "8",
		  floating = false
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
	    rule_any = { instance = {"Gmutt"}, name = {"Gmutt"} },
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
	    rule_any = { class = {"URxvt", "Alacritty", "GVim" } },
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

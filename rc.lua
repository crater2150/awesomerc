-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful")
require("naughty")
require("teardrop")
require("obvious.popup_run_prompt")
require("vicious")

confdir = "/home/crater2150/.config/awesome"
-- {{{ Spawns cmd if no client can be found matching properties
-- If such a client can be found, pop to first tag where it is visible, and give it focus
-- @param cmd the command to execute
-- @param properties a table of properties to match against clients.  Possible entries: any properties of the client object
function runraise(cmd, properties)
   local clients = client.get()
   local focused = awful.client.next(0)
   local findex = 0
   local matched_clients = {}
   local n = 0
   for i, c in pairs(clients) do
      --make an array of matched clients
      if match(properties, c) then
         n = n + 1
         matched_clients[n] = c
         if c == focused then
            findex = n
         end
      end
   end
   if n > 0 then
      local c = matched_clients[1]
      -- if the focused window matched switch focus to next in list
      if 0 < findex and findex < n then
         c = matched_clients[findex+1]
      end
      local ctags = c:tags()
      if table.getn(ctags) == 0 then
         -- ctags is empty, show client on current tag
         local curtag = awful.tag.selected()
         awful.client.movetotag(curtag, c)
      else
         -- Otherwise, pop to first tag client is visible on
         awful.tag.viewonly(ctags[1])
      end
      -- And then focus the client
      client.focus = c
      c:raise()
      return
   end
   awful.util.spawn(cmd)
end --}}}

-- Returns true if all pairs in table1 are present in table2
function match (table1, table2)
   for k, v in pairs(table1) do
      if table2[k] ~= v and not table2[k]:find(v) then
         return false
      end
   end
   return true
end

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/crater2150/.config/awesome/zenburn/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "sakura -e screen"
editor_cmd = "sakura -e vim"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.floating
}
-- }}}

-- {{{ Tags
local tags = {}
tags.setup = {
    { name = "1:⚙",   layout = layouts[1]  },
    { name = "2:⌘",   layout = layouts[7]  },
    { name = "3:☻",   layout = layouts[2], mwfact = 0.80 },
    { name = "4:✉",   layout = layouts[7]  },
    { name = "5:☑",   layout = layouts[7]  },
    { name = "6:♫",   layout = layouts[1]  },
    { name = "7:☣",   layout = layouts[1]  },
    { name = "8:☕",   layout = layouts[1]  },
    { name = "9:⚂",   layout = layouts[1]  },
    { name = "0:☠",   layout = layouts[1]  },
    { name = "F1:☭",  layout = layouts[1]  },
    { name = "F2:♚",  layout = layouts[1]  },
    { name = "F3:♛",  layout = layouts[1]  },
    { name = "F4:♜",  layout = layouts[1]  },
    { name = "F5:♝",  layout = layouts[1]  },
    { name = "F6:♞",  layout = layouts[1]  },
    { name = "F7:♟",  layout = layouts[1]  },
    { name = "F8:⚖",  layout = layouts[1]  },
    { name = "F9:⚛",  layout = layouts[1]  },
    { name = "F10:⚡", layout = layouts[1]  },
    { name = "F11:⚰", layout = layouts[1]  },
    { name = "F12:⚙", layout = layouts[1]  }
}

for s = 1, screen.count() do
    tags[s] = {}
    for i, t in ipairs(tags.setup) do
        tags[s][i] = tag({ name = t.name })
        tags[s][i].screen = s
        awful.tag.setproperty(tags[s][i], "layout", t.layout)
        awful.tag.setproperty(tags[s][i], "mwfact", t.mwfact)
        awful.tag.setproperty(tags[s][i], "hide",   t.hide)
    end
    tags[s][1].selected = true
end
-- }}}

-- {{{ Reusable separators
spacer         = widget({ type = "textbox", name = "spacer" })
spacer.text    = " "

separator      = widget({ type = "textbox", name = "separator", align = "center" })
separator.text = " )( "
-- }}}

-- {{{ Wibox

--popup run

-- Create a textclock widget
--clock     = awful.widget.textclock({ align = "right" })
mysystray = widget({ type = "systray" })

clock = widget({ type = "textbox" })
vicious.register(clock, vicious.widgets.date, "%b %d, %R", 60)

memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem, "⌸ $1% ($2MB / $3MB) ", 13)

cpuwidget = awful.widget.progressbar()
cpulabel = widget({ type = "textbox" })
cpuwidget:set_width(50)
cpuwidget:set_background_color("#494B4F")
cpuwidget:set_color("#FF5656")
cpuwidget:set_gradient_colors({ "#FF5656", "#88A175", "#AECF96" })
vicious.register(cpuwidget, vicious.widgets.cpu, "$1",41)
vicious.register(cpulabel, vicious.widgets.cpu, "CPU: $1%")


-- Create a wibox for each screen and add it
leftwibox = {}
rightwibox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )

for s = 1, screen.count() do
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)


    -- Create the wibox
    leftwibox[s] = awful.wibox({ position = "left", screen = s })
    rightwibox[s] = awful.wibox({ position = "right", screen = s })
    -- Add widgets to the wibox - order matters
    leftwibox[s].widgets = {
        mytaglist[s],
        mylayoutbox[s],
        spacer,
        layout = awful.widget.layout.horizontal.rightleft
    }
    rightwibox[s].widgets = {
        {
            clock,
            separator, spacer, memwidget,
            separator, spacer, cpulabel, cpuwidget,
            spacer,
            layout = awful.widget.layout.horizontal.leftright
        },
        separator, spacer, s == 1 and mysystray or nil,
        layout = awful.widget.layout.horizontal.leftright
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
awful.button({ }, 3, function () mymainmenu:toggle() end),
awful.button({ }, 4, awful.tag.viewnext),
awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

curtag = 1
function prevtag() 
    curtag = curtag - 1
    if curtag == 0 then curtag = 22 end
    awful.util.spawn("awbg " .. curtag)
    awful.tag.viewprev()
end

function nexttag()
    if curtag == 23 then curtag = 1 end
    awful.util.spawn("awbg " .. curtag)
    awful.tag.viewnext()
end

-- {{{ Key bindings
globalkeys = awful.util.table.join(
--{{{ 
    --awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    --awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Left",   prevtag       ),
    awful.key({ modkey,           }, "Right",  nexttag       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    --awful.key({ }, "XF86Word",   awful.tag.viewprev       ),
    --awful.key({ }, "XF86WebCam",  awful.tag.viewnext       ),
    awful.key({ }, "XF86Word",   prevtag       ),
    awful.key({ }, "XF86WebCam",  nexttag       ),
    awful.key({ }, "XF86Away", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show(true)        end),
--}}}
    --{{{ Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({ "Mod1",           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    --}}}
    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey,           }, "f",      function () awful.util.spawn("firefox") end),
    awful.key({ modkey,           }, "t",      function () awful.util.spawn("claws-mail") end),
    awful.key({ modkey,           }, "p",      function () awful.util.spawn("pidgin") end),
    awful.key({ modkey,           }, "g",      function () awful.util.spawn("gmpc") end),
    awful.key({ }, "XF86Mail",                 function () awful.util.spawn("xset dpms force off") end),
    awful.key({ }, "XF86Mail",                 function () awful.util.spawn("xset dpms force off") end),
    awful.key({ modkey }, "XF86Mail",                 function () awful.util.spawn("urslock") end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),
    
    -- Audio control
    awful.key({ }, "Print",  function () teardrop("sakura --class=Teardrop -e alsamixer","top","center", 0.99, 0.4)end ),
    awful.key({ }, "XF86AudioLowerVolume",  function () awful.util.spawn("amixer set Front 2dB-")end ),
    awful.key({ }, "XF86AudioRaiseVolume",  function () awful.util.spawn("amixer set Front 2dB+")end ),
    awful.key({ }, "XF86AudioMute",         function () awful.util.spawn("amixer set Front toggle") end),
    awful.key({ modkey , "Shift" },   "m",  function () awful.util.spawn("mpdmenu -a") end),
    awful.key({ modkey , "Control" }, "m",  function () awful.util.spawn("mpdmenu -t") end),
    awful.key({ modkey },             "m",  function () awful.util.spawn("mpc toggle") end),
    awful.key({ modkey },             "n",  function () awful.util.spawn("mpc next") end),
    awful.key({ modkey , "Shift"},    "n",  function () awful.util.spawn("mpc prev") end),
    awful.key({ },        "XF86AudioPlay",  function () awful.util.spawn("mpc toggle") end),
    awful.key({ },        "XF86AudioNext",  function () awful.util.spawn("mpc next") end),
    awful.key({ },        "XF86AudioPrev",  function () awful.util.spawn("mpc prev") end),
    awful.key({ },        "XF86AudioStop",  function () awful.util.spawn("mpdmenu -a") end),
    awful.key({ modkey , "Control" }, "n",  function () awful.util.spawn("mpdmenu -j") end),
    -- Prompt
    awful.key({ modkey }, "r", function () obvious.popup_run_prompt.run_prompt() end),
    awful.key({ }, "Scroll_Lock", function () awful.util.spawn("wli") end),
    awful.key({ }, "F12",        function () teardrop("sakura --class=Teardrop -e 'screen -l'","center","center", 0.99, 0.7)end ),


    --{{{Default
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, 0) end)
    
    --}}}
)

clientkeys = awful.util.table.join(
    awful.key({ modkey, "Shift"   }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      function (c) c.ontop = not c.ontop end),
    awful.key({ modkey,           }, "a",      function (c) c.sticky = not c.sticky end),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(22, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
-- FKeys: 67-78
for i = 1, keynumber do
    if i < 10 then
        k = "#" .. i + 9
    elseif i == 10 then
        k = "#19"
    elseif i > 10 then
        k = "F" .. i - 10
    end
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, k,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            curtag = i
                            awful.util.spawn("awbg " .. i)
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, k,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, k,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, k,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     size_hints_honor = false,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true,
                     size_hints_honor = true } },
    { rule = { class = "Passprompt" },
      properties = { floating = true,
                     ontop = true,
                     focus = true  } },
    { rule = { class = "Teardrop" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][2] } },
    { rule = { class = "Pidgin" },
      properties = { tag = tags[1][3] } },
    { rule = { role = "buddy_list" },
      properties = { master = true } },
    { rule = { class = "Claws-mail" },
      properties = { tag = tags[1][4] } },
    { rule = { class = "Sunbird-bin" },
      properties = { tag = tags[1][5] } },
    { rule = { class = "Gmpc" },
      properties = { tag = tags[1][6] } },
    { rule = { class = "Deluge" },
      properties = { tag = tags[1][7] } },
    { rule = { class = "Xhtop" },
      properties = { tag = tags[1][22] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

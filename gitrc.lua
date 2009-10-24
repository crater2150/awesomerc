--###
-- Standard awesome library
require("awful")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Dynamic tagging with shifty
require("lib/shifty")

-- Wicked
require("wicked")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
-- Just link your theme to ~/.awesome_theme
theme_path = os.getenv("HOME") .. "/.config/awesome/theme.lua"

-- Actually load theme
beautiful.init(theme_path)

-- Default applications
terminal = "terminal"
-- Editor to use
editor = "terminal -e vim"
-- this is the default level when adding a todo note
todo_level = "high"
-- Default modkey.                                                l
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod1"
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

-- Table of clients that should be set floating. The index may be either
-- the application class or instance. The instance is useful when running
-- a console app in a terminal like (Music on Console)
--    xterm -name mocp -e mocp
floatapps =
{
    -- by class
    ["MPlayer"] = true,
    ["Xmessage"] = true,
    ["Wireshark"] = true,
    ["XBoard"] = true,
    ["feh"] = true,
	["nitrogen"] = true,
    ["Wicd-client.py"] = true,
    ["gimp"] = true,
    ["XCalc"] = true,
    ["display"] = true,
    ["Preferences"] = true,
    ["XClipboard"] = true,
    ["Imagemagick"] = true,
    ["Snes9X"] = true,
    ["Add-ons"] = true,
    ["Wine desktop"] = true
}

-- Define if we want to use titlebar on all applications.
use_titlebar = false
-- }}}

--{{{ Shifty

shifty.config.defaults = {
  layout = "tilebottom",
}
shifty.config.tags = {
	["1:terms"] 	= { init = true, },
	["2:web"] 		= { init = true, nopopup = true },
	["3:music"] 	= { init =false, nopopup = true, position = 3, spawn = "ario" },
	["4:dls"]		= { init =false, nopopup =false, position = 4, spawn = "dtella && linuxdcpp" },
	["5:files"]		= { init =false, nopopup =false, position = 5 },
	["6:images"]	= { init =false, nopopup =false, position = 6, layout = "float" },
    ["7:videos"]	= { init =false, nopopup =false, position = 7, layout = "float" },
    ["8:exps"] 		= { init =false, nopopup =false, position = 8, layout = "float" },
    ["9:work"] 		= { init =false, nopopup =false, position = 9 },
}

shifty.config.apps = {
		{ match = { "VLC.*" }, float = true },
        { match = { "" }, honorsizehints= false,
                            buttons = {
                             button({ }, 1, function (c) client.focus = c; c:raise() end),
                             button({ modkey }, 1, function (c) awful.mouse.client.move() end),
                             button({ modkey }, 3, awful.mouse.client.resize ), }, },
        }

-- tag defaults
shifty.config.defaults = {
	layout = "tilebottom",
	ncol = 1,
	floatBars = true,
}
shifty.config.layouts = layouts
shifty.config.guess_position = true
shifty.config.remember_index = true
shifty.init()
-- }}}

-- {{{ Widgets
-- Create a systray
mysystray = widget({ type = "systray", align = "right" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = { button({ }, 1, awful.tag.viewonly),
                      button({ modkey }, 1, awful.client.movetotag),
                      button({ }, 3, function (tag) tag.selected = not tag.selected end),
                      button({ modkey }, 3, awful.client.toggletag),
                      button({ }, 4, awful.tag.viewnext),
                      button({ }, 5, awful.tag.viewprev) }
                      shifty.taglist = mytaglist
mytasklist = {}
mytasklist.buttons = { button({ }, 1, function (c) client.focus = c; c:raise() end),
                       button({ }, 3, function () awful.menu.clients({ width=250 }) end),
                       button({ }, 4, function () awful.client.focus.byidx(1) end),
                       button({ }, 5, function () awful.client.focus.byidx(-1) end) }

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = widget({ type = "textbox" })

-- Create a datebox widget
datebox = widget({ type = "textbox", align = "right" })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = widget({ type = "imagebox" })
    mylayoutbox[s]:buttons({ button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                             button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                             button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                             button({ }, 5, function () awful.layout.inc(layouts, -1) end) })
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist.new(s, awful.widget.taglist.label.all, mytaglist.buttons)
        -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist.new(function(c)
                                                  return awful.widget.tasklist.label.currenttags(c, s)
                                              end, mytasklist.buttons)
--}}}

--{{{ Wibox
    mywibox[s] = wibox({ position = "top", fg = beautiful.fg_normal, bg = beautiful.bg_normal })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
         mylayoutbox[s],
         mytaglist[s],
			   mypromptbox[s],
			   mysystray,
         datebox,
		}
    mywibox[s].screen = s
end
--}}}

--{{{ Functions

--{{{ Add a todo note

	function addtodo (todo)
		infobox.text = "| <b><u>todo:</u></b> " .. "<span color='#FF00FF'>" .. awful.util.spawn("todo --add --priority high " .. "'" .. todo .. "'") .. "</span>"
	end
--}}}

--{{{ Show todos
    function show_todo()
        local todo = awful.util.pread("todo --mono")
        todo = naughty.notify({
            text = string.format(os.date("%a, %d %B %Y") .. "\n" .. todo),
            timeout = 6,
            width = 300,
        })
    end
--}}}



--}}}

--{{{ Keybindings
-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Bindings for shifty
    awful.key({ modkey,           }, "comma",   awful.tag.viewprev       ),
    awful.key({ modkey,  "Shift"  }, "comma",   shifty.shift_prev        ),
    awful.key({ modkey,  "Shift"  }, "period",  shifty.shift_next        ),
    awful.key({ modkey,           }, "period",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    awful.key({ modkey            }, "t",           function() shifty.add({ rel_index = 1 }) end),
    awful.key({ modkey, "Control" }, "t",           function() shifty.add({ rel_index = 1, nopopup = true }) end),
    awful.key({ modkey            }, "r",           shifty.rename),
    awful.key({ modkey            }, "w",           shifty.delete),
    awful.key({ modkey, "Shift"   }, "o",      function() shifty.set(awful.tag.selected(mouse.screen), { screen = awful.util.cycle(screen.count() , mouse.screen + 1) }) end),
    awful.key({ modkey,           }, "y",      function() list = naughty.notify({
                                                          text = get_albumart(),
                                                          width = 400 }) end),
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

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1) end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1) end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus( 1)       end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus(-1)       end),
    awful.key({ modkey, "Shift"   }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
	        awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey, "Shift"   }, "Tab",
        function ()
	        awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),


    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Shift"   }, "Return", function () awful.util.spawn(editor) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    -- display playlist
    awful.key({ modkey,           }, "p",      function() list = naughty.notify({
                                                          text = get_playlist(),
                                                          width = 400 }) end),

   -- Display the todo list
    awful.key({ modkey,           }, "d", function () show_todo() end),

   -- Paste content of the xbuffer
   awful.key({ modkey, "Control"  }, "p", function ()
      awful.prompt.run({ prompt = "<b>Paste to:</b> "},
      mypromptbox[mouse.screen],
      function (s) paste(s) end,
      awful.completion.shell) end),
  -- Lock the screen

    awful.key({ modkey            }, "t",           function() shifty.add({ rel_index = 1 }) end),
    awful.key({ modkey, "Control" }, "t",           function() shifty.add({ rel_index = 1, nopopup = true }) end),
    awful.key({ modkey            }, "r",           shifty.rename),
    awful.key({ modkey            }, "w",           shifty.del),
    awful.key({ modkey, "Control" }, "o",     function () shifty.set(awful.tag.selected(mouse.screen), { screen = awful.util.cycle(mouse.screen + 1, screen.count()) }) end),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    -- add a todo
   awful.key({ modkey, "Shift" }, "d",
              function ()
                  awful.prompt.run({ prompt = " Add Todo Note: " },
                  mypromptbox[mouse.screen],
                  addtodo(t), t,
                  awful.util.getdir("cache") .. "/todos")
              end),
   awful.key({ modkey }, "F2",
              function ()
                  awful.prompt.run({ fg_cursor = 'orange', bg_cursor = beautiful.bg_normal,
                  ul_cursor = "single", prompt = " Run: " },
                  mypromptbox[mouse.screen],
                  awful.util.spawn, awful.completion.shell,
                  awful.util.getdir("cache") .. "/history")
              end),
   awful.key({ modkey }, "F4",
              function ()
                  awful.prompt.run({ prompt = " Run Lua code: " },
                  mypromptbox[mouse.screen],
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

-- Client awful tagging: this is useful to tag some clients and then do stuff like move to tag on them
clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey,			  }, "semicolon",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey }, "t", awful.client.togglemarked),
    awful.key({ modkey,}, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

for i=1,9 do
  
  globalkeys = awful.util.table.join(globalkeys, awful.key({ modkey }, i,
  function ()
    local t = awful.tag.viewonly(shifty.getpos(i))
  end))
  globalkeys = awful.util.table.join(globalkeys, awful.key({ modkey, "Control" }, i,
  function ()
    local t = shifty.getpos(i)
    t.selected = not t.selected
  end))
  globalkeys = awful.util.table.join(globalkeys, awful.key({ modkey, "Control", "Shift" }, i,
  function ()
    if client.focus then
      awful.client.toggletag(shifty.getpos(i))
    end
  end))
  -- move clients to other tags
  globalkeys = awful.util.table.join(globalkeys, awful.key({ modkey, "Shift" }, i,
    function ()
      if client.focus then
        local t = shifty.getpos(i)
        awful.client.movetotag(t)
        awful.tag.viewonly(t)
      end
    end))
end
-- Set keys
root.keys(globalkeys)
shifty.config.globalkeys = globalkeys
shifty.config.clientkeys = clientkeys
--}}}
--}}}

-- {{{ Hooks
-- Hook function to execute when focusing a client.
awful.hooks.focus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_focus
    end
end)

-- Hook function to execute when unfocusing a client.
awful.hooks.unfocus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_normal
    end
end)

-- Hook function to execute when marking a client
awful.hooks.marked.register(function (c)
    c.border_color = beautiful.border_marked
end)

-- Hook function to execute when unmarking a client.
awful.hooks.unmarked.register(function (c)
    c.border_color = beautiful.border_focus
end)

-- Hook function to execute when the mouse enters a client.
awful.hooks.mouse_enter.register(function (c)
    -- Sloppy focus, but disabled for magnifier layout
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

-- Hook function to execute when arranging the screen.
-- (tag switch, new client, etc)
awful.hooks.arrange.register(function (screen)
    local layout = awful.layout.getname(awful.layout.get(screen))
    if layout and beautiful["layout_" ..layout] then
        mylayoutbox[screen].image = image(beautiful["layout_" .. layout])
    else
        mylayoutbox[screen].image = nil
    end

    -- Give focus to the latest client in history if no window has focus
    -- or if the current window is a desktop or a dock one.
    if not client.focus then
        local c = awful.client.focus.history.get(screen, 0)
        if c then client.focus = c end
    end
end)

-- Hook called every 15 seconds, displays info
function hook_date ()
	-- writes status to .status
    os.execute("echo $(mpc | grep -)  $(gmail.py)  $(acpi -b | sed -e 's/%.*/%/;s/.*, //')  $(date +'%a %d %b')  $(date +'%I:%M') > ~/.status")
	-- read .status
	io.input("/home/jack/.status")
	datebox.text = io.read("*line")
end

-- Set timers for the hooks
awful.hooks.timer.register(15, hook_date)

-- run the hook so we don't have to wait
hook_date()

--}}}

-- startup commands
os.execute("xmodmap ~/.xmodmap &")
os.execute("xbindkeys &")
os.execute("nitrogen --restore &")
os.execute("xsetroot -cursor_name left_ptr &")

-- vim: foldmethod=marker:filetype=lua:expandtab:shiftwidth=2:tabstop=2:softtabstop=2:encoding=utf-8:textwidth=80

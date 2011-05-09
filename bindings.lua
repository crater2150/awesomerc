
-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
awful.button({ }, 4, awful.tag.viewnext),
awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
--{{{ Focus and Tags
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

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

    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
--}}}

    --{{{ Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
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
--
    --{{{ Spawns
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey,           }, "f",      function () awful.util.spawn("firefox") end),
    awful.key({ modkey,           }, "t",      function () awful.util.spawn("claws-mail") end),
    awful.key({ modkey,           }, "p",      function () awful.util.spawn("pidgin") end),
    awful.key({ modkey,           }, "g",      function () awful.util.spawn("gmpc") end),
    awful.key({ modkey,           }, "w",      function () awful.util.spawn("awsetbg -a -r /home/crater2150/.config/awesome/walls/ &") end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),
    awful.key({ }, "Menu", aweswt.switch),
    awful.key({ }, "Scroll_Lock", aweswt.switch),
   
    --}}}
    
    --{{{ tabletpc keys

    awful.key({ hyper }, "6", function () awful.util.spawn("/usr/local/bin/rotate") end),
    awful.key({ modkey }, "x",  function () teardrop("cellwriter","top","center", 0.99, 0.4)end ),
    awful.key({ modkey, "Control" }, "Delete", function () awful.util.spawn("xlock") end),

    --}}}
    
    --{{{ Audio control
    awful.key({ }, "Print",  function () teardrop("urxvtc -e alsamixer","top","center", 0.99, 0.4)end ),
    awful.key({ }, "XF86AudioLowerVolume",  function () awful.util.spawn("amixer set Master 2%-")end ),
    awful.key({ }, "XF86AudioRaiseVolume",  function () awful.util.spawn("amixer set Master 2%+")end ),
    awful.key({ }, "XF86AudioMute",         function () awful.util.spawn("amixer set Master toggle") end),
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

    --}}}

    --{{{ Prompt

    awful.key({ modkey }, "r", function ()
			obvious.popup_run_prompt.set_prompt_string(" Run~ ")
			obvious.popup_run_prompt.set_cache("history")
			obvious.popup_run_prompt.set_run_function(awful.util.spawn)
			obvious.popup_run_prompt.run_prompt()
			end),
    awful.key({ modkey }, "e", function ()
			obvious.popup_run_prompt.set_prompt_string(" exec Lua~ ")
			obvious.popup_run_prompt.set_cache("history_eval")
			obvious.popup_run_prompt.set_run_function(awful.util.eval)
			obvious.popup_run_prompt.run_prompt()
			end),
    awful.key({ }, "F12",        function () teardrop(terminal,"center","center", 0.99, 0.7)end ),

    --}}}

    --{{{ g15Keys

    awful.key({ }, "XF86Word",   awful.tag.viewprev       ),
    awful.key({ }, "XF86WebCam",  awful.tag.viewnext       ),
    awful.key({ }, "XF86Away", awful.tag.history.restore),

    awful.key({ }, "XF86iTouch", function () awful.screen.focus_relative( 1) end),
    awful.key({ }, "XF86Support", function () awful.screen.focus_relative(-1) end),

    --}}}

    --{{{ Default
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
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Control" }, "o",      function (c) c.ontop = not c.ontop end),
    awful.key({ modkey,           }, "a",      function (c) c.sticky = not c.sticky end),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),

    awful.key({ }, "XF86Calculater",      awful.client.movetoscreen                        )
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

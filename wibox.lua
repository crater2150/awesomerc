
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

--batwidget  = obvious.battery();
batwidget = widget({ type = "textbox" })
vicious.register(batwidget, vicious.widgets.bat, "⌁ $1$2% - $3", 61)

cpuwidget = awful.widget.progressbar()
cpulabel = widget({ type = "textbox" })
cpuwidget:set_width(50)
cpuwidget:set_background_color("#494B4F")
cpuwidget:set_color("#FF5656")
cpuwidget:set_gradient_colors({ "#FF5656", "#88A175", "#AECF96" })
vicious.register(cpuwidget, vicious.widgets.cpu, "$1",41)
vicious.register(cpulabel, vicious.widgets.cpu, "CPU: $1%")


wlanwidget = widget({ type = "textbox" })
vicious.register(wlanwidget, vicious.widgets.wifi, "WLAN ${ssid} @ ${sign}, Q:${link}/70", 31, "wlan0")
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
            separator, spacer, batwidget,
            separator, spacer, wlanwidget,
            separator, spacer, cpulabel, cpuwidget,
            spacer,
            layout = awful.widget.layout.horizontal.leftright
        },
        separator, spacer, s == 1 and mysystray or nil,
        layout = awful.widget.layout.horizontal.leftright
    }
end
-- }}}

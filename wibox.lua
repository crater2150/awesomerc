function exists(filename)
  local file = io.open(filename)
  if file then
    io.close(file)
    return true
  else
    return false
  end
end


-- {{{ Reusable separators
spacer         = widget({ type = "textbox", name = "spacer" })
spacer.text    = " "

separator      = widget({ type = "textbox", name = "separator", align = "center" })
separator.text = " )( "

nullwidget     = widget({ type = "textbox", name = "nullwidget" })
separator.text = ""
-- }}}

-- {{{ Wibox

--popup run

-- Create a textclock widget
--clock     = awful.widget.textclock({ align = "right" })
mysystray = widget({ type = "systray" })

clock = widget({ type = "textbox" })
vicious.register(clock, vicious.widgets.date, "%b %d, %R", 60)

memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem, "RAM: $1% ($2MB / $3MB) ", 13)

if exists("/proc/acpi/battery/BAT0") then
    batwidget1 = widget({ type = "textbox" })
    vicious.register(batwidget1, vicious.widgets.bat, " )(  BAT0: $1$2% - $3", 61, "BAT0")
else batwidget1 = nullwidget end

if exists("/proc/acpi/battery/BAT1") then
    batwidget2 = widget({ type = "textbox" })
    vicious.register(batwidget2, vicious.widgets.bat, " )(  BAT1: $1$2% - $3", 61, "BAT1")
else batwidget2 = nullwidget end

if exists("/proc/acpi/battery/BAT2") then
    batwidget3 = widget({ type = "textbox" })
    vicious.register(batwidget3, vicious.widgets.bat, " )(  BAT2: $1$2% - $3", 61, "BAT2")
else batwidget3 = nullwidget end

cpulabel = widget({ type = "textbox" })
vicious.register(cpulabel, vicious.widgets.cpu, "CPU: $1%")

if exists("/sys/class/net/wlan0") then
    wlanwidget = widget({ type = "textbox" })
    vicious.register(wlanwidget, vicious.widgets.wifi, " )(  WLAN ${ssid} @ ${sign}, Q:${link}/70", 31, "wlan0")
else wlanwidget = nullwidget end

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
            batwidget1,
            batwidget2,
            batwidget3,
            wlanwidget,
            separator, spacer, cpulabel, cpuwidget,
            spacer,
            layout = awful.widget.layout.horizontal.leftright
        },
        separator, spacer, s == 1 and mysystray or nil,
        layout = awful.widget.layout.horizontal.leftright
    }
end
-- }}}

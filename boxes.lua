local wibox = require("wibox")
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
spacer         = wibox.widget.textbox({ name = "spacer" })
spacer.set_text(" ")

nullwidget     = wibox.widget.textbox({ name = "nullwidget" })
-- }}}

-- {{{ Wibox

--popup run

-- Create a textclock widget
--clock     = awful.widget.textclock({ align = "right" })
mysystray = wibox.widget.systray()

clock = wibox.widget.textbox()
vicious.register(clock, vicious.widgets.date, "%b %d, %R", 60)


-- music widget {{{
mpdwidget = wibox.widget.textbox()
vicious.register(mpdwidget, vicious.widgets.mpd,
	function(widget, args)
		if args["{state}"] == "N/A" then
			return ""
		else
			return "[ ♫ "..args["{Artist}"].." - "..args["{Title}"].." ]"
		end
	end, 3, {nil, os.getenv("MPD_HOST"), os.getenv("MPD_PORT")})
-- }}}

-- mail widget {{{
mailwidget = wibox.widget.textbox()
vicious.register(mailwidget, vicious.widgets.mdir,
	function(widget, args) 
		if args[1] > 0 then
			naughty.notify({
				title = "New mail arrived",
				text = "Unread "..args[2].." / New "..args[1],
				position = "top_left"

			})
			widget.bg = theme.bg_urgent
			widget.fg = theme.fg_urgent
		elseif args[2] > 0 then
			widget.bg = theme.bg_focus
			widget.fg = theme.fg_focus
		else
			widget.bg = theme.bg_normal
			widget.fg = theme.fg_normal
		end
		return "⬓⬓ Unread "..args[2].." / New "..args[1].. " "
	end, 181, {os.getenv("HOME") .. "/.maildir/"})
--}}}

-- battery {{{
if exists("/sys/class/power_supply/BAT0") then
    batwidget0 = wibox.widget.textbox()
    vicious.register(batwidget0, vicious.widgets.bat,
	function (widget, args)
		if args[2] == 0 then return ""
		else
			if args[2] < 15 then
				widget.bg = theme.bg_urgent
				widget.fg = theme.fg_urgent
			else
				widget.bg = theme.bg_normal
				widget.fg = theme.fg_normal
			end
			return "(  BAT0: "..args[1]..args[2].."% - "..args[3].." )"
		end
	end, 61, "BAT0")
else batwidget0 = nullwidget end

if exists("/sys/class/power_supply/BAT1") then
    batwidget1 = wibox.widget.textbox()
    vicious.register(batwidget1, vicious.widgets.bat,
	function (widget, args)
		if args[2] == 0 then return ""
		else
			if args[2] < 15 then
				widget.bg = theme.bg_urgent
				widget.fg = theme.fg_urgent
			else
				widget.bg = theme.bg_normal
				widget.fg = theme.fg_normal
			end
			return "(  BAT1: "..args[1]..args[2].."% - "..args[3].." )"
		end
	end, 61, "BAT1")
else batwidget1 = nullwidget end

if exists("/sys/class/power_supply/BAT2") then
    batwidget2 = wibox.widget.textbox()
    vicious.register(batwidget2, vicious.widgets.bat,
	function (widget, args)
		if args[2] == 0 then return ""
		else
			if args[2] < 15 then
				widget.bg = theme.bg_urgent
				widget.fg = theme.fg_urgent
			else
				widget.bg = theme.bg_normal
				widget.fg = theme.fg_normal
			end
			return "(  BAT2: "..args[1]..args[2].."% - "..args[3].." )"
		end
	end, 61, "BAT2")
else batwidget2 = nullwidget end

--}}}

cpulabel = wibox.widget.textbox()
vicious.register(cpulabel, vicious.widgets.cpu, "CPU: $1%")

if exists("/sys/class/net/wlan0") then
    wlanwidget = wibox.widget.textbox()
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
    leftwibox[s] = awful.wibox({ position = "left", screen = s, width = 18 })
    rightwibox[s] = awful.wibox({ position = "right", screen = s , width = 18})
    -- Add widgets to the wibox - order matters
    leftwibox[s].widgets = {
        mytaglist[s],
        mylayoutbox[s],
		mailwidget,
        spacer,
        layout = awful.widget.layout.horizontal.rightleft
    }
    rightwibox[s].widgets = {
        {
            clock, spacer, 
            batwidget0,
            batwidget1,
            batwidget2,
            wlanwidget,
            spacer, cpulabel, cpuwidget,
            spacer, mpdwidget, mpdnext, spacer, mpdprev,
            spacer,
            layout = awful.widget.layout.horizontal.leftright
        },
        separator, spacer, mysystray,
        layout = awful.widget.layout.horizontal.leftright
    }
end
-- }}}
--
-- vim:foldmethod=marker

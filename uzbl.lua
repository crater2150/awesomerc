

uzbltag = tags[rule_screen][2]
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
awful.button({ }, 1, function (c)
	if c == client.focus then
		c.minimized = true
	else
		if not c:isvisible() then
			awful.tag.viewonly(c:tags()[1])
		end
		-- This will also un-minimize
		-- the client, if needed
		client.focus = c
		c:raise()
	end
end),
awful.button({ }, 3, function ()
	if instance then
		instance:hide()
		instance = nil
	else
		instance = awful.menu.clients({ width=250 })
	end
end),
awful.button({ }, 4, function ()
	awful.client.focus.byidx(1)
	if client.focus then client.focus:raise() end
end),
awful.button({ }, 5, function ()
	awful.client.focus.byidx(-1)
	if client.focus then client.focus:raise() end
end))

mytasklist[rule_screen] = awful.widget.tasklist(function(c)
	return awful.widget.tasklist.label.currenttags(c, rule_screen)
end, mytasklist.buttons)
uzblbox = {}
uzblbox = awful.wibox({ position = "top", screen = rule_screen })
uzblbox.visible = false
uzblbox.widgets = { mytasklist[rule_screen],
layout = awful.widget.layout.horizontal.rightleft }

uzbltag:add_signal("property::selected", function (tag)
	uzblbox.visible = tag.selected
end)

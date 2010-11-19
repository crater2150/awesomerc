

keybinding({ modkey }, "Return", function () awful.util.spawn(terminal) end):add()
keybinding({ modkey }, "f", function () awful.util.spawn("firefox") end):add()
keybinding({ }, "XF86AudioLowerVolume", function () awful.util.spawn("voldown 3") end):add()
keybinding({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("volup 3") end):add()
keybinding({ "Shift" }, "XF86AudioLowerVolume", function () awful.util.spawn("voldown 10") end):add()
keybinding({ "Shift" }, "XF86AudioRaiseVolume", function () awful.util.spawn("volup 10") end):add()
keybinding({ modkey }, "XF86Mail", function () awful.util.spawn("xset dpms force off") end):add()
keybinding({ modkey }, "XF86WWW", function () awful.util.spawn(terminal .. " -e apselect") end):add()


keybinding({ }, "XF86AudioPlay", function () awful.util.spawn("mpc toggle") end):add()
keybinding({ }, "XF86AudioNext", function () awful.util.spawn("mpc next") end):add()
keybinding({ }, "XF86AudioPrev", function () awful.util.spawn("mpc prev") end):add()
keybinding({ }, "XF86AudioStop", function () awful.util.spawn("mpc stop") end):add()
keybinding({ modkey }, "XF86AudioStop", function () awful.util.spawn("mpc clear") end):add()
keybinding({ modkey }, "XF86AudioPlay", function ()
    awful.prompt.run({ prompt = "Play Band: " }, 
	mypromptbox[mouse.screen], playband, 
	awful.completion.bash,
    awful.util.getdir("cache") .. "/history")
end):add()

function playband(b)
	return awful.util.spawn("playband " .. b)
end


keybinding({ modkey }, "Return", function () awful.util.spawn(terminal) end):add()

keybinding({ modkey }, "F1", function ()
    awful.prompt.run({ prompt = "Run: " }, 
	mypromptbox[mouse.screen], awful.util.spawn,
	awful.completion.bash,
    awful.util.getdir("cache") .. "/history")
end):add()

keybinding({ modkey }, "F4", function ()
    awful.prompt.run({ prompt = "Run Lua code: " },
	mypromptbox[mouse.screen],
	awful.util.eval,
	awful.prompt.bash,
	awful.util.getdir("cache") .. "/history_eval")
end):add()

keybinding({ modkey, "Ctrl" }, "i", function ()
	local s = mouse.screen
    if mypromptbox[s].text then
        mypromptbox[s].text = nil
    elseif client.focus then
        mypromptbox[s].text = nil
    	if client.focus.class then
	        mypromptbox[s].text = "Class: " .. client.focus.class .. " "
    	end
	    if client.focus.instance then
        	mypromptbox[s].text = mypromptbox[s].text .. "Instance: "
			  .. client.focus.instance .. " "
	    end
    	if client.focus.role then
    	    mypromptbox[s].text = mypromptbox[s].text .. "Role: "
		      .. client.focus.role
    	end
    end
                                    end):add()


keybinding({}, "F12", function ()

	tags[1][10].selected = not tags[1][10].selected;
	
end):add()


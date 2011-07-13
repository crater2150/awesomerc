
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
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "Gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    { rule = { class = "Uzbl-core" },
      properties = { tag = tags[rule_screen][2],
  					skip_taskbar = false } },
    { rule = { class = "Firefox", instance = "Navigator" },
      properties = { tag = tags[rule_screen][2],
					 skip_taskbar = true,
                     floating = false } },
    { rule = { class = "Pidgin" },
      properties = { tag = tags[rule_screen][3]} },
    { rule = { role = "buddy_list" },
      properties = { master = true } },
    { rule = { role = "conversation" },
      callback = awful.client.setslave},
    { rule = { instance = "Weechat"},
      properties = { tag = tags[rule_screen][3]} ,
      callback = awful.client.setslave},
    { rule = { class = "Irssi"},
      properties = { tag = tags[rule_screen][3]} ,
      callback = awful.client.setslave},
    { rule = { class = "Claws-mail" },
      properties = { tag = tags[rule_screen][4] } },
    { rule = { instance = "Gmutt" },
      properties = { tag = tags[rule_screen][4] } },
    { rule = { class = "Gmpc" },
      properties = { tag = tags[rule_screen][6] } },
    { rule = { class = "Deluge" },
      properties = { tag = tags[rule_screen][7] } },
    { rule = { class = "Xhtop" },
      properties = { tag = tags[rule_screen][22] } },
    { rule = { class = "Cellwriter" },
      properties = { tag = tags[rule_screen][1],
                     ontop = true,
                     size_hints_honor = true,
                     float = true,
                     sticky = true,
                     fullscreen = true
                     } },
}

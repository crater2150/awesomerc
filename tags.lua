
-- {{{ Tags
tags={}
tags.setup = {
    { name = "1:⚙",   layout = layouts[1]  },
    { name = "2:⌘",   layout = layouts[5]  },
    { name = "3:☻",   layout = layouts[3], mwfact = 0.20 },
    { name = "4:✉",   layout = layouts[5]  },
    { name = "5:☑",   layout = layouts[1]  },
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

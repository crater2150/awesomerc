---------------------------------------------------------------
-- Basic scratchpad manager for the awesome window manager
---------------------------------------------------------------
-- Adrian C. <anrxc.sysphere.org>
-- Licensed under the WTFPL version 2
--   * http://sam.zoy.org/wtfpl/COPYING
---------------------------------------------------------------
-- To use this module add:
--     require("scratchpad")
-- to the top of your rc.lua, and call:
--     scratchpad.set(c, width, height, sticky, screen)
-- from a clientkeys binding, and:
--     scratchpad.toggle(screen)
-- from a globalkeys binding.
--
-- Parameters:
--     c      - Client to scratch or un-scratch
--     width  - Width in absolute pixels, or width percentage
--              when < 1 (0.50 (50% of the screen) by default)
--     height - Height in absolute pixels, or height percentage
--              when < 1 (0.50 (50% of the screen) by default)
--     sticky - Visible on all tags, false by default
--     screen - Screen (optional), mouse.screen by default
---------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local capi = {
    mouse = mouse,
    client = client,
    screen = screen
}

-- Scratchpad: Basic scratchpad manager for the awesome window manager
module("scratchpad")

local scratch = {}

-- Scratch the focused client, or un-scratch and tile it. If another
-- client is already scratched, replace it with the focused client.
function set(c, width, height, sticky, screen)
    local width  = width  or 0.50
    local height = height or 0.50
    local sticky = sticky or false
    local screen = screen or capi.mouse.screen

    local function setscratch(c)
        -- Scratchpad is floating
        awful.client.floating.set(c, true)

        -- Scratchpad geometry and placement
        local screengeom = capi.screen[screen].workarea

        if width  < 1 then width  = screengeom.width  * width  end
        if height < 1 then height = screengeom.height * height end

        c:geometry({ -- Client is always centered on screen
            x = screengeom.x + (screengeom.width  - width)  / 2,
            y = screengeom.y + (screengeom.height - height) / 2,
            width = width,      height = height
        })

        -- Scratchpad properties
        c.ontop = true
        c.above = true
        c.skip_taskbar = true
        if sticky then c.sticky = true end
        if c.titlebar then awful.titlebar.remove(c) end

        -- Scratchpad should not loose focus
        c:raise()
        capi.client.focus = c
    end

    -- Prepare a table for storing clients,
    if not scratch["pad"] then scratch["pad"] = {}
        -- add unmanage signal for scratchpad clients
        capi.client.add_signal("unmanage", function (c)
            local oc = scratch["pad"][screen]
            if oc == c then
                scratch["pad"][screen] = nil
            end
        end)
    end

    -- If the scratcphad is emtpy, store the client,
    if not scratch["pad"][screen] then
        scratch["pad"][screen] = c
        -- then apply geometry and properties
        setscratch(c)
    else -- If a client is already scratched,
        local oc = scratch["pad"][screen]
        -- compare it with the focused client
        if oc == c then
            -- If it matches then unscratch and clear the table
            awful.client.floating.toggle(oc); oc.sticky = false
            oc.ontop = false; oc.above = false
            scratch["pad"][screen] = nil
        else -- If they don't match, unscratch and replace it
            oc.hidden = false; oc.sticky = false
            oc.ontop = false; oc.above = false
            awful.client.floating.toggle(oc)
            scratch["pad"][screen] = c
            setscratch(c)
        end
    end
end

-- Move the scratchpad to the current workspace, focus and raise it
-- when it's hidden, or hide it when it's visible.
function toggle(screen)
    local screen = screen or capi.mouse.screen

    -- Check if we have a client on storage,
    if scratch["pad"] and
       scratch["pad"][screen] ~= nil
    then -- and get it out, to play
        local c = scratch["pad"][screen]

        -- If it's visible on another tag hide it,
        if c:isvisible() == false then c.hidden = true;
            -- and move it to the current worskpace
            awful.client.movetotag(awful.tag.selected(screen), c)
        end

        -- Focus and raise if it's hidden,
        if c.hidden then
            awful.placement.centered(c)
            c.hidden = false
            c:raise()
            capi.client.focus = c
        else -- hide it if it's not
            c.hidden = true
        end
    end
end

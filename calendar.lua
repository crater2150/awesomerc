local beautiful = beautiful
local wibox = wibox
local conf = conf
local modkey = conf.modkey or "Mod4"
local mb = require("modalbind")

local log = log
local calendar = {}

local weekdays = {"Su","Mo","Tu","We","Th","Fr","Sa"}
local monthdays = {31,28,31,30,31,30,31,31,30,31,30,31}
local monthnames = {"January", "February", "March", "April", "May", "June",
	"July", "August", "September", "October", "November", "December"}

local num_rows = 6

local function get_weekday(day)
	index = day + conf.calendar.start_week
	if index > 7 then
		index = index - math.floor(index / 7) * 7
	end
	print(index)
	return weekdays[index]
end

function calendar.setup()
	local cal = {}
	setmetatable(cal, { __index = calendar })

	cal.wibox = wibox({
		fg = beautiful.fg_normal,
		bg = beautiful.bg_normal,
		border_width = 1,
		border_color = beautiful.bg_focus,
	})

	cal.title = wibox.widget.textbox()
	cal.layout = wibox.layout.fixed.vertical()

	cal.layout:add(cal.title)
	cal.wibox:set_widget(cal.layout)
	cal.wibox.screen = 1

	cal.wibox.visible = false
	cal.wibox.ontop = true
	cal.title:set_align("center")
	cal:set_title("Calendar loading")
	local wdays = wibox.layout.flex.horizontal()
	local fieldwidth = 0
	for day = 1,7,1 do
		local label = wibox.widget.textbox()
		wdays:add(label)
		label:set_align("center")
		label:set_markup("<b><i>"..get_weekday(day).."</i></b>")
		local w,_ = label:fit(screen[1].geometry.width, screen[1].geometry.height)
		fieldwidth = math.max(w, fieldwidth)
		if beautiful.fontface then
			label:set_font(beautiful.fontface .. " " .. (beautiful.fontsize + 4))
		end
	end
	cal.layout:add(wdays)
	local _, title_h = cal.title:fit(0, 0)
	local _, wdays_h = wdays:fit(0, 0)
	cal.header_height = title_h + wdays_h
	cal.header_width  = (fieldwidth + 10) * 7

	local cols = {}
	local days = {}
	for row = 1, num_rows, 1 do
		days[row] = {}
		cols[row] = wibox.layout.flex.horizontal()
		for day = 1,7,1 do
			days[row][day] = wibox.widget.textbox()
			local d = days[row][day]
			cols[row]:add(d)
			d:set_text("[99]")
			d:set_align("center")
			if beautiful.fontface then
				d:set_font(beautiful.fontface .. " " .. (beautiful.fontsize + 4))
			end
		end

		cal.layout:add(cols[row])
	end
	cal.cols = cols
	cal.days = days

	cal.offset = 0

	cal:calculate_size()
	cal:fill_days()

	cal.layout:buttons(awful.util.table.join(
		awful.button({ }, 1, function () cal:next() end),
		awful.button({ }, 2, function () cal:now() end),
		awful.button({ }, 3, function () cal:prev() end)
	));

	return cal
end

function calendar:calculate_size()
	local minheight = 0
	local fieldwidth = 0
	local inner_minheight = 0

	for row = 1, num_rows, 1 do
		for day = 1,7,1 do
			local w,_ = self.days[row][day]:fit(screen[1].geometry.width, screen[1].geometry.height)
			fieldwidth = math.max(w, fieldwidth)
		end
		_, inner_minheight = self.cols[row]:fit(0, 0)
		minheight = minheight + inner_minheight
	end

--	_, inner_minheight = self.title:fit(screen[1].geometry.width, screen[1].geometry.height)
--	minheight = minheight + inner_minheight

	self.wibox.width = math.max(fieldwidth * 9, self.header_width);
	self.wibox.height = math.max(50, minheight) + self.header_height
	self.wibox.x = 18
	self.wibox.y = 0 -- screen[1].geometry.height - self.wibox.height - 50
end


function calendar:set_day_by_date(row, col, date, current)
	if(current == date.day) then
		self.days[row][col]:set_markup(
		"<span background=\"" .. beautiful.bg_focus
		.. "\" foreground=\""..beautiful.fg_focus
		.. "\" weight=\"ultrabold\">["..current.."]</span>")
	else
		self.days[row][col]:set_text(current)
	end
end

function calendar:set_day_label(row, col, label)
	self.days[row][col]:set_markup(label)
end

function calendar:next()
	self.offset = self.offset + 1
	self:fill_days()
end

function calendar:prev()
	self.offset = self.offset - 1
	self:fill_days()
end

function calendar:now()
	self.offset = 0
	self:fill_days()
end

function calendar:fill_days()
	local date = os.date("*t")
	if self.offset ~= 0 then
		local newdate = {}
		newdate.year = date.year
		newdate.day = 1
		newdate.month = date.month + self.offset

		while newdate.month < 1 do
			newdate.year = newdate.year - 1
			newdate.month = newdate.month + 12
		end

		while newdate.month > 12 do
			newdate.year = newdate.year + 1
			newdate.month = newdate.month - 12
		end

		date = os.date("*t", os.time(newdate))
	end

	self:set_title(monthnames[date.month] .. " " .. date.year)

	local startday = (date.wday - date.day - conf.calendar.start_week) % 7 + 1
	local cur_day = 1

	for d = 1, startday - 1, 1 do
		self.days[1][d]:set_text("")
	end

	for d = startday, 7, 1 do
		if self.offset == 0 then
			self:set_day_by_date(1, d, date, cur_day)
		else
			self.days[1][d]:set_text(cur_day)
		end

		cur_day = cur_day + 1
	end
	for r = 2,num_rows,1 do
		for d = 1, 7, 1 do
			if(cur_day > monthdays[date.month]) then
				self.days[r][d]:set_text("")
			else
				if self.offset == 0 then
					self:set_day_by_date(r, d, date, cur_day)
				else
					self.days[r][d]:set_text(cur_day)
				end
			end
			cur_day = cur_day + 1
		end
	end
end

function calendar:toggle()
	self:update_before_showing()
	self.wibox.visible = not self.wibox.visible
end

function calendar:show()
	self:update_before_showing()
	self.wibox.visible = true
end

function calendar:update_before_showing()
	if not self.wibox.visible then
		self:now()
	end
end

function calendar:set_title(text)
	self.title:set_markup("<span weight=\"bold\" size=\"larger\">"..text.."</span>")
end

-- settings.x_offset < 0 and
-- 	screen[s].geometry.x - width + settings.x_offset or
-- 	settings.x_offset

return calendar.setup()

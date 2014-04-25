local beautiful = beautiful
local wibox = wibox

local calendar = {}

local weekday = {"su","mo","tu","we","th","fr","sa"}
local monthdays = {31,28,31,30,31,30,31,31,30,31,30,31}


function calendar.setup()
	local cal = {}
	setmetatable(cal, { __index = calendar })

	cal.wibox = wibox({
		fg = beautiful.fg_normal,
		bg = beautiful.bg_normal,
		border_width = 1,
		border_color = beautiful.bg_focus,
	})

	cal.widget = wibox.widget.textbox()
	cal.layout = wibox.layout.fixed.vertical()

	cal.layout:add(cal.widget)
	cal.wibox:set_widget(cal.layout)
	cal.wibox.screen = 1

	cal.wibox.visible = true
	cal.widget:set_markup("<span weight=\"bold\" size=\"larger\">Calendar</span>")
	cal.widget:set_align("center")

	local rows = wibox.layout.fixed.vertical()
	local cols = {}
	local days = {}
	for row = 1, 5, 1 do
		days[row] = {}
		cols[row] = wibox.layout.flex.horizontal()
		for day = 1,7,1 do
			days[row][day] = wibox.widget.textbox()
			local d = days[row][day]
			cols[row]:add(d)
			d:set_align("center")
			if beautiful.fontface then
				d:set_font(beautiful.fontface .. " " .. (beautiful.fontsize + 4))
			end
		end

		rows:add(cols[row])
	end
	cal.rows = rows
	cal.cols = cols
	cal.days = days

	cal.layout:add(rows)


	cal:fill_days()
	cal:calculate_size()
end

function calendar:calculate_size()
	local minheight = 0
	local fieldwidth = 0
	local inner_minheight = 0

	for row = 1, 5, 1 do
		for day = 1,7,1 do
			local w,_ = self.days[row][day]:fit(screen[1].geometry.width, screen[1].geometry.height)
			fieldwidth = math.max(w, fieldwidth)
		end
		_, inner_minheight = self.cols[row]:fit(
		0, 0
		)
		minheight = minheight + inner_minheight
	end

	_, inner_minheight = self.widget:fit(screen[1].geometry.width, screen[1].geometry.height)
	minheight = minheight + inner_minheight

	self.wibox.width = fieldwidth * 9;
	self.wibox.height = math.max(50, minheight)
	self.wibox.x = 30
	self.wibox.y = screen[1].geometry.height - self.wibox.height - 50
end


function calendar:set_day(row, col, date, current)
	if(current == date.day) then
		self.days[row][col]:set_markup(
		"<span background=\"" .. beautiful.bg_focus
		.. "\" foreground=\""..beautiful.fg_focus
		.. "\" weight=\"ultrabold\">"..current.."</span>")
	else
		self.days[row][col]:set_text(current)
	end
end


function calendar:fill_days()
	local date = os.date("*t")

	local startday = date.wday - date.day % 7+ 1
	local cur_day = 1
	for d = startday, 7, 1 do
		self:set_day(1, d, date, cur_day)
		cur_day = cur_day + 1
	end
	for r = 2,5,1 do
		for d = 1, 7, 1 do
			self:set_day(r, d, date, cur_day)
			cur_day = cur_day + 1
			if(cur_day > monthdays[date.month]) then
				return
			end
		end
	end
end

-- settings.x_offset < 0 and
-- 	screen[s].geometry.x - width + settings.x_offset or
-- 	settings.x_offset

local mt = { __call = calendar.setup }

return setmetatable(calendar, mt)

local naughty = require("naughty")

local simplelog = { loggers = {}, mt = {}}

local defaults = {}
local settings = {}

defaults.loggers = { }
defaults.defaultlevel = 0

for key, value in pairs(defaults) do
    settings[key] = value
end

local level = {
	ERROR = 3,
	WARNING = 2,
	NORMAL = 1,
	DEBUG = 0
}
simplelog.level = level

local function loglv(msg, level)
	for _,logger in ipairs(settings.loggers) do
		logger(msg, level)
	end
end

function simplelog.dbg(msg)
	loglv(msg, 0)
end

function simplelog.log(msg)
	loglv(msg, 1)
end

function simplelog.warn(msg)
	loglv(msg, 2)
end

function simplelog.error(msg)
	loglv(msg, 3)
end

function simplelog.add_logger(logger, level)
	if level == nil then
		level = settings.defaultlevel
	end
	table.insert(settings.loggers, function(msg, severity)
		if severity >= level then 
			logger(msg, severity) 
		end
	end)
end

function simplelog.loggers.naughty(msg, severity)
	if severity == level.WARNING then
		msg = "<span color=\"#ff6\">".. msg .. "</span>"
	elseif severity == level.ERROR then
		msg = "<span color=\"#f66\">".. msg .. "</span>"
	end
	naughty.notify({ text = msg })
end

function simplelog.loggers.stdio(msg, severity)
	print(msg)
end

simplelog.mt.__call = simplelog.log

return setmetatable(simplelog, simplelog.mt)
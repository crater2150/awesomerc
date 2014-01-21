local naughty = require("naughty")

local simplelog = { loggers = {}, mt = {}}

local defaults = {}
local settings = {}

defaults.loggers = { }
defaults.defaultlevel = 0

for key, value in pairs(defaults) do
    settings[key] = value
end

level = {
	ERROR = 3,
	WARNING = 2,
	NORMAL = 1,
	DEBUG = 0
}
simplelog.level = level

function loglv(msg, level)
	for _,logger in ipairs(settings.loggers) do
		logger(msg, level)
	end
end

function dbg(msg)
	loglv(msg, 0)
end
simplelog.debug = dbg

function log(msg)
	loglv(msg, 1)
end
simplelog.log = log

function warn(msg)
	loglv(msg, 2)
end
simplelog.warn = warn

function error(msg)
	loglv(msg, 3)
end
simplelog.error = error

function add_logger(logger, level)
	if level == nil then
		level = settings.defaultlevel
	end
	table.insert(settings.loggers, function(msg, severity)
		if severity >= level then 
			logger(msg, severity) 
		end
	end)
end
simplelog.add_logger = add_logger

function logger_naughty(msg, severity)
	if severity == level.WARNING then
		msg = "<span color=\"#ff6\">".. msg .. "</span>"
	elseif severity == level.ERROR then
		msg = "<span color=\"#f66\">".. msg .. "</span>"
	end
	naughty.notify({ text = msg })
end
simplelog.loggers.naughty = logger_naughty


function logger_print(msg, severity)
	print(msg)
end
simplelog.loggers.stdio = logger_print

simplelog.mt.__call = log

return setmetatable(simplelog, simplelog.mt)

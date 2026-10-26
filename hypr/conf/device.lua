local vars = require("conf.vars")
local s = require("conf.settings")

local devices = {
	{ name = vars.touch_screen, enabled = false },
	{ name = vars.touchpad, natural_scroll = s.natural_scroll },
	{ name = vars.touchpad_mouse, natural_scroll = s.natural_scroll },
}

for _, d in ipairs(devices) do
	if d.name then
		hl.device(d)
	end
end

local vars = require("conf.vars")
local qs = vars.qs

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({
	fingers = 3,
	direction = "up",
	action = function()
		hl.exec_cmd(qs .. " ipc call wow activate")
	end,
})
hl.gesture({
	fingers = 3,
	direction = "down",
	action = function()
		hl.exec_cmd(qs .. " ipc call wow deactivate")
	end,
})

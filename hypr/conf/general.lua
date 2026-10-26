local s = require("conf.settings")
local colors = require("conf.colors")

hl.config({
	general = {
		gaps_in = s.gaps_in,
		gaps_out = s.gaps_out,
		border_size = s.border_size,
		col = {
			active_border = { colors = { colors.active_border_1 }, angle = s.border_angle },
			inactive_border = "0x00000000",
		},
		resize_on_border = s.resize_on_border,
		allow_tearing = s.allow_tearing,
		layout = s.layout,
	},
})

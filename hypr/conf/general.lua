local colors = require("conf.colors")

hl.config({
	general = {
		gaps_in = 2,
		gaps_out = 10,
		border_size = 1,
		col = {
			active_border = { colors = { colors.active_border_1, colors.active_border_2 }, angle = 45 },
			inactive_border = "0x00000000",
		},
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},
})

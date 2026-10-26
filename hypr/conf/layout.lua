local s = require("conf.settings")

hl.config({
	dwindle = {
		preserve_split = s.preserve_split,
	},
	master = {
		new_status = "master",
	},
	scrolling = {
		fullscreen_on_one_column = true,
		column_width = s.scrolling_column_width,
		follow_focus = true,
	},
})

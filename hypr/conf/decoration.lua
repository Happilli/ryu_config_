local s = require("conf.settings")

hl.config({
	decoration = {
		active_opacity = s.active_opacity,
		inactive_opacity = s.inactive_opacity,
		rounding = s.rounding,
		shadow = {
			enabled = s.shadow_enabled,
		},
		dim_inactive = s.dim_inactive,
		blur = {
			enabled = s.blur_enabled,
			size = s.blur_size,
			passes = s.blur_passes,
		},
	},
})

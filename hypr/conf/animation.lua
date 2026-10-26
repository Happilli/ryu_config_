local s = require("conf.settings")

hl.config({ animations = { enabled = s.animations_enabled } })

local function spring(name)
	hl.curve("spring_" .. name, {
		type = "spring",
		mass = s["spring_" .. name .. "_mass"],
		stiffness = s["spring_" .. name .. "_stiffness"],
		dampening = s["spring_" .. name .. "_dampening"],
	})
end

spring("workspace")
spring("special")
spring("move")

hl.animation({ leaf = "windowsIn", enabled = false })
hl.animation({ leaf = "border", enabled = false })
hl.animation({ leaf = "borderangle", enabled = false })
hl.animation({ leaf = "windowsOut", enabled = false })
hl.animation({ leaf = "fadeIn", enabled = false })
hl.animation({ leaf = "fadeOut", enabled = false })
hl.animation({ leaf = "windowsMove", enabled = true, speed = s.anim_speed, spring = "spring_move", style = "slide" })
hl.animation({ leaf = "workspaces", enabled = true, speed = s.anim_speed, spring = "spring_workspace", style = "slide" })
hl.animation({
	leaf = "specialWorkspace",
	enabled = true,
	speed = s.anim_speed,
	spring = "spring_special",
	style = "slidevert",
})

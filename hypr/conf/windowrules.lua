local window_rules = {
	{
		name = "suppress-maximize-events",
		match = { class = ".*" },
		suppress_event = "maximize",
	},
	{
		name = "fix-xwayland-drags",
		match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
		no_focus = true,
	},
	{
		name = "move-hyprland-run",
		match = { class = "hyprland-run" },
		move = "20 monitor_h-120",
		float = true,
	},
	{
		name = "no-wobble-default",
		match = { class = ".*" },
		no_wobble = true,
	},
	{
		name = "wobble-quickshell",
		match = { class = "^org\\.quickshell$" },
		no_wobble = false,
	},
	o_wobble = false,
}

for _, rule in ipairs(window_rules) do
	hl.window_rule(rule)
end

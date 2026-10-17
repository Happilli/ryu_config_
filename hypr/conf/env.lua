local envs = {
	{ "XCURSOR_SIZE", "24" },
	{ "HYPRCURSOR_SIZE", "24" },
	{ "XCURSOR_THEME", "Bibata-Modern-Classic" },
	{ "HYPRCURSOR_THEME", "Bibata-Modern-Classic" },
	{ "ELECTRON_OZONE_PLATFORM_HINT", "auto" },
	{ "QT_QPA_PLATFORMTHEME", "xdgdesktopportal" },
	{ "QS_ICON_THEME", "Adwaita" },
}

for _, e in ipairs(envs) do
	hl.env(e[1], e[2])
end

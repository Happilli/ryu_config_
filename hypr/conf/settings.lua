local settings = {}

for line in io.lines(os.getenv("HOME") .. "/.config/hypr/ergonDumbah") do
	local k, v = line:match("(.-)=(.*)")
	if k then
		if v == "true" then
			v = true
		elseif v == "false" then
			v = false
		else
			v = tonumber(v) or v
		end
		settings[k] = v
	end
end

return settings

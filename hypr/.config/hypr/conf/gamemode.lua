-- Gamemode toggle: SUPER + ALT + G
hl.bind("SUPER + ALT + G", function()
	local game_mode = (hl.get_config("animations.enabled") == false)

	if game_mode then
		-- Gamemode is on: reload the config to restore your normal settings
		hl.exec_cmd("hyprctl reload")
	else
		hl.config({
			general = {
				gaps_in = 0,
				gaps_out = 0,
			},
			animations = { enabled = false },
			decoration = {
				shadow = { enabled = false },
				blur = { enabled = false },
				rounding = 0,
			},
		})
	end
end)

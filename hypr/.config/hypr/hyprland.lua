-- ~/.config/hypr/hyprland.lua

require("conf/hyprland-session")
local theme = require("conf/rose-pine")


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
	output	= "",
	mode	= "highrr",
	position	= "auto",
	scale	= "1",
	vrr	= 1,
})


-------------------------------------
---- GENERAL / LOOK AND FEEL --------
-------------------------------------

-- See https://wiki.hypr.land/Configuring/Variables/ 
hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 15,
		border_size = 2,

		col = {
			active_border   = { colors = { theme.iris, theme.love }, angle = 45 },
			inactive_border = theme.overlay,
		},

		resize_on_border = false,
		allow_tearing = true,
		layout = "dwindle",
	},

	group = {
		col = {
			border_active   = theme.iris,
			border_inactive = theme.overlay,
		},

		groupbar = {
			height          = 15,
			font_size       = 11,
			gradients       = false,
			text_color      = theme.text,

			col = {
				active   = theme.iris,
				inactive = theme.overlay,
			},
		},
	},

	decoration = {
		rounding = 12,
		rounding_power = 3.0,
		active_opacity = 1.0,
		inactive_opacity = 0.8,

		shadow = {
			enabled = true,
			range = 4,
			color = theme.base .. "aa",
		},

		blur = {
			enabled = true,
			size = 3,
			passes = 2,
			vibrancy = 0.1696,
			new_optimizations = true,
		},
	},

	dwindle = {
		preserve_split = true,
	},

	master = {
		new_status = "master",
	},

	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo   = true,
	},

	animations = {
		enabled = true,
	}
})


-------------------
---- MODULES -----
-------------------

require("conf/programs")
require("conf/environment")
require("conf/keybindings")
require("conf/input_gestures")
require("conf/animations")
require("conf/rules")


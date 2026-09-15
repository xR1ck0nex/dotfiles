-- ~/.config/hypr/conf/input_gestures.lua

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us, ru",
		kb_options = "grp:alt_shift_toggle",

		touchpad = {
			natural_scroll = true,
		},
	},
})


------------------
---- GESTURES ----
------------------

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace"
})

hl.gesture({
	fingers = 3,
	direction = "down",
	mods = "ALT",
	action = "close"
})

hl.gesture({
	fingers = 3,
	direction = "up",
	scale = 1.5,
	action = "fullscreen"
})

hl.gesture({
	fingers = 3,
	direction = "down",
	scale = 1.5,
	action = "fullscreen"
})

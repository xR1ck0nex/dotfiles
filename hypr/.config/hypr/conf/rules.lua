--------------------
---- WINDOW RULES --
--------------------

-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

hl.window_rule({
	name  = "yazi-float",
	match = { initial_class = "^(yazi)$" },
	float = true,
	size  = "1400 800",
})

hl.window_rule({
	name           = "suppress-maximize",
	match          = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name     = "no-focus-xwayland-dnd",
	match    = { class = "^$", title = "^$", xwayland = true, float = true },
	no_focus = true,
})

hl.window_rule({
	name      = "steam-games",
	match     = { initial_class = "^(steam_app_.*)$" },
	immediate = true,
})


------------------------
---- WORKSPACE RULES --
------------------------

-- https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/


------------------------
---- LAYER RULES ------
------------------------
 
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

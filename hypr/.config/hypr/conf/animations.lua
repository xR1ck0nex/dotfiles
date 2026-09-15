-- ~/.config/hypr/conf/animations.lua

-------------------------
---- ANIMATIONS --------
-------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })

hl.animation({ leaf = "global",       enabled = true, speed = 6,    bezier= "easeOutQuint" })

hl.animation({ leaf = "windows",      enabled = true, speed = 5,    bezier= "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",   enabled = true, speed = 1.5,  bezier= "quick",        style = "popin 87%" })
hl.animation({ leaf = "windowsMove",  enabled = true, speed = 5,    bezier= "easeOutQuint" })

hl.animation({ leaf = "fade",         enabled = true, speed = 6,    bezier= "quick" })
hl.animation({ leaf = "fadeSwitch",   enabled = true, speed = 4,    bezier= "easeInOutCubic" })  -- group tab switch
hl.animation({ leaf = "fadeDim",      enabled = true, speed = 5,    bezier= "quick" })

hl.animation({ leaf = "layers",       enabled = true, speed = 4,    bezier= "easeOutQuint", style = "fade" })

hl.animation({ leaf = "workspaces",   enabled = true, speed = 6,    bezier= "easeInOutCubic", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "easeOutQuint", style = "slidevert" })

hl.animation({ leaf = "border",       enabled = true, speed = 8,    bezier = "easeOutQuint" })
hl.animation({ leaf = "borderangle",  enabled = true, speed = 8,    bezier = "linear", style = "once" })

hl.animation({ leaf = "zoomFactor",   enabled = true, speed = 7,    bezier = "quick" })

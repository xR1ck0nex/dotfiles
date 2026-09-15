-- ~/.config/hypr/conf/environment.lua

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24") 
hl.env("QT_QPA_PLATFORMTHEME", "hyprqt6engine")
hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
hl.env("XCURSOR_THEME", "BreezeX-RosePine-Linux")
local home = os.getenv("HOME")
local path = os.getenv("PATH")
if home and path then
	hl.env("PATH", home .. "/.local/bin:" .. path)
end

-- ~/.config/hypr/conf/hyprland-session.lua

--------------------------
---- Hyprland Session ----
--------------------------

-- See https://wiki.hypr.land/Useful-Utilities/Systemd-start/
hl.on("hyprland.start", function()
	hl.exec_cmd("systemctl --user start hyprland-session.target")

	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")

	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("playerctld daemon")
end)

hl.on("hyprland.shutdown", function()
	os.execute("systemctl --user stop hyprland-session.target && sleep 0.1")
end)

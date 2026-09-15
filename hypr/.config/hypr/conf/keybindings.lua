---------------------
---- KEYBINDINGS ----
---------------------

local v = require("conf/programs")
local mainMod = "SUPER"

-- See https://wiki.hypr.land/Configuring/Basics/Binds/
--     https://wiki.hypr.land/Configuring/Basics/Dispatchers/

---- applications ----
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(v.terminal)) 
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(v.fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(v.menu))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(v.browser))

---- window management ----
hl.bind(mainMod .. " + X", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + M",   hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + Tab", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + G",   hl.dsp.group.toggle())
hl.bind(mainMod .. " + bracketright", hl.dsp.group.next())
hl.bind(mainMod .. " + bracketleft",  hl.dsp.group.prev())

---- focus ----
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))

---- workspaces ----
-- 1..9 then 0, matching the number-row order.
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key,           hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key,   hl.dsp.window.move({ workspace = i }))
end

-- scratchpad
hl.bind(mainMod .. " + Q", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.move({ workspace = "special:magic" }))

---- audio (wireplumber) ----
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),     { locked = true })

---- media ----
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

---- screenshots ----
hl.bind(mainMod .. " + CTRL + S",           hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
hl.bind(mainMod .. " + S",    hl.dsp.exec_cmd('grim -g "$(slurp)" ~/Pictures/Screenshots/$(date +%d%m%Y-%H%M%S).png'))
hl.bind(mainMod .. " + SHIFT + S",    hl.dsp.exec_cmd('grim ~/Pictures/Screenshots/$(date +%d%m%Y-%H%M%S).png'))

---- clipboard history via the launcher's dmenu mode ----
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("cliphist list | hyprlauncher --dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("cliphist wipe && notify-send 'Clipboard' 'History wiped'"))

---- notifications ---
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("makoctl dismiss"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("makoctl dismiss --all"))
hl.bind(mainMod .. " + CTRL + D", hl.dsp.exec_cmd("makoctl mode -t dnd"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("makoctl restore"))

---- network menu ----
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("network-menu"))

---- session ----
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

---- move window within the layout ----
-- NOT verified: the directional form of window.move. The workspace form
-- (used above) is documented; check `direction` against the stubs.
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
 
---- resize with the keyboard ----
local step = 40
local function resize(dx, dy, name)
	return hl.dsp.window.resize({ x = dx, y = dy, relative = true }),
	       { description = "Resize active window " .. name, repeating = true }
end
 
hl.bind(mainMod .. " + CTRL + h", resize(-step, 0, "left"))
hl.bind(mainMod .. " + CTRL + j", resize(0, step,  "down"))
hl.bind(mainMod .. " + CTRL + k", resize(0, -step, "up"))
hl.bind(mainMod .. " + CTRL + l", resize(step, 0,  "right"))
 
---- mouse: drag to move, drag to resize ----
-- 272 = LMB, 273 = RMB 
hl.config({ binds = { drag_threshold = 5 } })
 
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true, drag = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, drag = true })
 
---- scroll through workspaces ----
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))


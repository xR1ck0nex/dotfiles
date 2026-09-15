# ~/.zshenv

export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}

if [[ -z "$WAYLAND_DISPLAY" && -d "$XDG_RUNTIME_DIR" ]]; then
	export WAYLAND_DISPLAY=$(ls "$XDG_RUNTIME_DIR" 2>/dev/null | grep -m1 '^wayland-[0-9]*$')
fi

if [[ -z "$HYPRLAND_INSTANCE_SIGNATURE" && -d "$XDG_RUNTIME_DIR/hypr" ]]; then
	export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t "$XDG_RUNTIME_DIR/hypr" 2>/dev/null | head -n1)
fi

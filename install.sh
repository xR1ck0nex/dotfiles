#!/usr/bin/env bash
# install.sh — bring a machine up to this configuration.
#
# Idempotent: safe to re-run. Each stage can be run alone.
#
#   ./install.sh              everything except services
#   ./install.sh packages     install from packages.txt
#   ./install.sh stow         symlink the config packages
#   ./install.sh dirs         create the directories configs expect
#   ./install.sh post         bat cache, gtk4 link
#   ./install.sh services     enable system + user units  (READ THE NOTE)
#   ./install.sh manual       print the steps no script can do

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES"

[[ $EUID -eq 0 ]] && { echo "Do not run as root. It uses sudo where needed."; exit 1; }

say() { printf '\n\033[1;35m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m !\033[0m %s\n' "$*"; }

# ---------------------------------------------------------------- packages
packages() {
	say "Checking multilib"
	if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
		warn "[multilib] is not enabled in /etc/pacman.conf."
		warn "Steam and every lib32-* package need it. Uncomment the section, then re-run."
		exit 1
	fi

	if ! command -v paru >/dev/null; then
		say "Bootstrapping paru"
		sudo pacman -S --needed --noconfirm base-devel git
		tmp=$(mktemp -d)
		git clone https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
		( cd "$tmp/paru-bin" && makepkg -si --noconfirm )
		rm -rf "$tmp"
	fi

	say "Verifying every package name resolves"
	local missing=()
	while read -r p; do
		paru -Si "$p" >/dev/null 2>&1 || missing+=("$p")
	done < <(grep -v '^#' packages.txt | awk 'NF {print $1}')

	if (( ${#missing[@]} )); then
		warn "These names do not resolve — AUR packages get renamed and dropped:"
		printf '    %s\n' "${missing[@]}"
		warn "Fix packages.txt or continue without them."
		read -rp "Continue? [y/N] " a; [[ $a == [yY] ]] || exit 1
	fi

	say "Installing GPU drivers based on vendor"
	GPU_INFO="$(lspci | grep -Ei 'vga|3d|display' | head -n 1 || true)"

	if [[ -z "$GPU_INFO" ]]; then
		warn "No GPU detected - no drivers will be installed"
	else
		say "Detected GPU: "
		echo "$GPU_INFO"
		paru -S mesa lib32-mesa vulkan-mesa-layers lib32-vulkan-mesa-layers vulkan-icd-loader lib32-vulkan-icd-loader 

		case "$GPU_INFO" in
			*AMD*|*Radeon*)
				paru -S vulkan-radeon lib32-vulkan-radeon
				;;
			*Intel*|*Arc*)
				paru -S vulkan-intel lib32-vulkan-intel
				;;
			*NVIDIA*|*Geforce*|*RTX*|*GTX*)
				paru -S nvidia-utils lib32-nvidia-utils
				;;
		esac
	fi

	say "Installing the rest"
	paru -S --needed $(grep -v '^#' packages.txt | awk 'NF {print $1}')
	paru -Rsnu $(paru -Qdtq)
}

# -------------------------------------------------------------------- dirs
dirs() {
	say "Creating directories the configs expect"
	# Each of these fails SILENTLY if missing: screenshot binds write nowhere,
	# mpd refuses to start, compinit complains.
	mkdir -p ~/Pictures/Screenshots ~/Music ~/.config/mpd/playlists \
	         ~/.cache/zsh ~/.local/bin ~/.config/gtk-4.0
}

# -------------------------------------------------------------------- stow
stow_all() {
	say "Stowing"
	# */ matches directories only, so README.md, install.sh and packages.txt
	# are not treated as packages.
	# --restow unstows first, pruning links to files deleted since last run.
	stow --target="$HOME" --restow */
	say "Symlinks in the repo (should print nothing):"
	find . -path ./.git -prune -o -type l -print
}

# -------------------------------------------------------------------- post
post() {
	say "Rebuilding bat's theme cache"
	# bat will not see a theme in its themes/ dir until this runs
	bat cache --build

	say "Linking the GTK4 stylesheet"
	# GTK4 has no theme-directory mechanism — adwaita is compiled in and the
	# only override is CSS loaded directly. Not tracked in the repo because
	# it is reproducible from the installed theme package.
	local gtk4
	for gtk4 in /usr/share/themes/rose-pine*/gtk-4.0/gtk.css; do
		[[ -f $gtk4 ]] && { ln -sf "$gtk4" ~/.config/gtk-4.0/gtk.css; break; }
	done
	[[ -L ~/.config/gtk-4.0/gtk.css ]] || warn "No rose-pine gtk-4.0/gtk.css found; is the theme installed?"
}

# ---------------------------------------------------------------- services
services() {
	warn "greetd is NOT enabled here."
	warn "A broken greetd config means no way to log in graphically. Test it"
	warn "with 'greetd --config ...' or from a TTY before enabling it by hand."

	say "System units"
	sudo systemctl enable --now NetworkManager bluetooth fstrim.timer snapper-cleanup.timer limine-snapper-sync.service

	say "User units"
	systemctl --user daemon-reload
	systemctl --user enable --now mpd mpd.socket mpd-mpris playerctld syncthing graphical-session waybar hypridle
}

# ------------------------------------------------------------------ manual
manual() {
	cat <<'EOF'

Steps no script can do — GUI clicks and per-machine values:

  nwg-look            pick rose-pine theme, icons, cursor, font -> Apply
                      (writes gtk-3.0/settings.ini AND a binary dconf db,
                       which is why it is not tracked)

  kvantummanager --set rose-pine

  Librewolf           about:config ->
                      widget.use-xdg-desktop-portal.file-picker = 1
                      (default 2 = auto, which picks the internal GTK dialog
                       and termfilechooser never fires)

  Steam               Settings -> Compatibility -> enable Steam Play for all
                      titles. On the Vulkan driver prompt during install,
                      choose the driver matching the GPU — pacman offers
                      lib32-nvidia-utils first by alphabetical order, which
                      breaks Vulkan on AMD and Intel.

  Heroic              Accessibility -> Custom Themes Path ->
                      ~/.config/heroic-themes

  waybar              config.jsonc "temperature" -> hwmon-path differs per
                      machine:
                        for f in /sys/class/hwmon/*/name; do echo "$f: $(cat $f)"; done

  Syncthing           http://127.0.0.1:8384 — pair devices, and tick
                      "Introducer" on the always-on one so folders propagate

  WireGuard           nmcli connection import type wireguard file /etc/wireguard/wg0.conf
                      nmcli connection modify wg0 connection.autoconnect no
                      DNS: needs systemd-resolved + systemd-resolvconf, or
                      NetworkManager overwrites resolv.conf and the tunnel
                      appears to die after a while.

  Forgejo             register this machine's SSH key, or use an access token
                      over HTTPS

For the OS-level install (partitioning, btrfs subvolumes, limine, snapper,
zram), see arch-install.md.

EOF
}

# -------------------------------------------------------------------- main
case "${1:-all}" in
	packages) packages ;;
	dirs)     dirs ;;
	stow)     stow_all ;;
	post)     post ;;
	services) services ;;
	manual)   manual ;;
	all)      packages; dirs; stow_all; post; manual ;;
	*)        sed -n '2,12p' "$0"; exit 1 ;;
esac



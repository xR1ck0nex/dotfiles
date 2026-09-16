# Desktop build record

---

## 1. From the Arch ISO

```bash
timedatectl set-ntp true
cat /sys/firmware/efi/fw_platform_size     # must print 64
lsblk -o NAME,SIZE,MODEL,TYPE              # confirm the target disk
```

## 2. Partition

`cfdisk /dev/nvme0n1 _(or any /dev/sdX)_` (or `fdisk`). Create a new **GPT** label - that wipes the existing table - then two partitions:

| # | Size | Type | Mount |
|---|---|---|---|
| 1 | 1 GiB | EFI System | `/boot` |
| 2 | rest of the disk | Linux filesystem | `/` |

In `cfdisk` the type is chosen from a list after creating each partition. In `fdisk` it's `t`, then type `1` for EFI System and `20` for Linux filesystem (the default, so partition 2 usually needs no change). Write the table and quit, then confirm with `lsblk`.

No separate swap partition — zram covers it, and no swap means no hibernation on this machine.

## 3. Format

```bash
mkfs.fat -F32 -n ESP /dev/nvme0n1p1 (/dev/sdX)
mkfs.btrfs -L arch -f /dev/nvme0n1p2 (/dev/sdX)
```

Kernels, initramfs and `limine.conf` all live on the ESP, which is why it's 1 GiB and not 512 MiB — two kernels plus fallbacks fill the smaller size fast.

## 4. Subvolumes

```bash
mount /dev/nvme0n1p2 _(/dev/sdX)_ /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@pkg
btrfs subvolume create /mnt/@snapshots
umount /mnt
```

```
@           →  /
@home       →  /home
@log        →  /var/log
@pkg        →  /var/cache/pacman/pkg
@snapshots  →  /.snapshots
```

`@log` and `@pkg` are separate so a root rollback keeps the logs that explain the breakage and the packages needed to repair it. `var/lib/portables` and `var/lib/machines` appear later — created automatically by systemd, leave them.

## 5. Mount

```bash
OPTS="noatime,compress=zstd:1,ssd"

mount -o $OPTS,subvol=@ /dev/nvme0n1p2 _(/dev/sdX)_ /mnt
mkdir -p /mnt/{home,boot,.snapshots,var/log,var/cache/pacman/pkg}

mount -o $OPTS,subvol=@home      /dev/nvme0n1p2 _(/dev/sdX)_ /mnt/home
mount -o $OPTS,subvol=@log       /dev/nvme0n1p2 _(/dev/sdX)_ /mnt/var/log
mount -o $OPTS,subvol=@pkg       /dev/nvme0n1p2 _(/dev/sdX)_ /mnt/var/cache/pacman/pkg
mount -o $OPTS,subvol=@snapshots /dev/nvme0n1p2 _(/dev/sdX)_ /mnt/.snapshots
mount /dev/nvme0n1p1 _(/dev/sdX)_ /mnt/boot

findmnt -R /mnt                            # 5 btrfs rows + 1 vfat, subvol= on each
```

No `discard=async` — `fstrim.timer` handles TRIM instead. Running both is redundant.

## 6. Install base

```bash
pacstrap -K /mnt base base-devel linux linux-firmware btrfs-progs \
  intel-ucode limine efibootmgr networkmanager neovim git zsh sudo \
  snapper snap-pac zram-generator

genfstab -U /mnt >> /mnt/etc/fstab
```

Swap `intel-ucode` for `amd-ucode` if the CPU is AMD. Verify later with:
```bash
lscpu | grep "Model name"
dmesg | grep -i microcode
```

Then edit `/mnt/etc/fstab` — the ESP line needs restrictive masks:
```
UUID=XXXX-XXXX  /boot  vfat  defaults,fmask=0077,dmask=0077  0 2
```
FAT has no permission bits of its own; 0077 makes `/boot` root-only and silences the `bootctl` world-readable warning.

## 7. Chroot

```bash
arch-chroot /mnt

ln -sf /usr/share/zoneinfo/Europe/Rome _(choose yours)_ /etc/localtime
hwclock --systohc
_edit:_ nvim /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "<hostname>" > /etc/hostname
cat > /etc/hosts << 'EOF'
127.0.0.1   localhost
::1         localhost
127.0.1.1   <hostname>.localdomain <hostname>
EOF

mkinitcpio -P
passwd
useradd -mG wheel -s /usr/bin/zsh <user>
passwd <user>
EDITOR=nvim visudo                         # uncomment %wheel ALL=(ALL:ALL) ALL

systemctl enable NetworkManager fstrim.timer snapper-cleanup.timer
```

`btrfs` needs no entry in `MODULES` — the `filesystems` hook detects it from the mounted root.
`/etc/hostname` is what the Hyprland Lua config reads to pick its host module.

## 8. Limine

```bash
mkdir -p /boot/EFI/limine
cp /usr/share/limine/BOOTX64.EFI /boot/EFI/limine/
efibootmgr --create --disk /dev/nvme0n1 --part 1 \
  --label "Arch Linux" --loader '\EFI\limine\BOOTX64.EFI' --unicode

blkid -s UUID -o value /dev/nvme0n1p2 _(/dev/sdX)_      # root UUID for the config below
```

`/boot/limine.conf`:
```
timeout: 3

/Arch Linux

//Arch Linux
    protocol: linux
    path: boot():/vmlinuz-linux
    cmdline: root=UUID=<uuid> rootflags=subvol=@ rw
    module_path: boot():/intel-ucode.img
    module_path: boot():/initramfs-linux.img
```

- Single `/` is a top-level entry, `//` nests under the one above it.
  limine-snapper-sync REQUIRES this nesting — with kernels at top level it
  reports "Your OS entry has no kernel" and refuses to add snapshots.
- `rootflags=subvol=@` is mandatory. Without it the kernel mounts the btrfs
  top level and boot fails with no useful message.
- Microcode `module_path` must come BEFORE the initramfs, or it's ignored.
- Never create `/boot/EFI/limine/limine.conf` — that path outranks this file.

Redeploy hook, `/etc/pacman.d/hooks/limine.hook`:
```ini
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = limine

[Action]
Description = Deploying Limine after upgrade...
When = PostTransaction
Exec = /usr/bin/cp /usr/share/limine/BOOTX64.EFI /boot/EFI/limine/
```

```bash
exit
umount -R /mnt
reboot
```

---

## 9. First boot: verify

```bash
findmnt -t btrfs
btrfs subvolume list /
journalctl -p 3 -b
```

Expected noise, both harmless: `virt/tdx: TDX not supported by the host platform` (kernel probes for a feature consumer CPUs lack).

## 10. Snapper

`create-config` insists on creating its own `.snapshots` subvolume where `@snapshots` already sits, so let it, then put yours back:

```bash
sudo umount /.snapshots
sudo rmdir /.snapshots
sudo snapper -c root create-config /
sudo btrfs subvolume delete /.snapshots
sudo mkdir /.snapshots
sudo mount -a
sudo chmod 750 /.snapshots
sudo btrfs quota disable /                 # qgroups badly hurt performance, snapper doesn't need them

findmnt /.snapshots                        # must show subvol=/@snapshots
```

`/etc/snapper/configs/root`:
```
TIMELINE_CREATE="no"
NUMBER_CLEANUP="yes"
NUMBER_MIN_AGE="1800"
NUMBER_LIMIT="10"
NUMBER_LIMIT_IMPORTANT="5"
ALLOW_USERS="<user>"
SYNC_ACL="yes"
```

`TIMELINE_CREATE="no"` because `snap-pac` already brackets every pacman transaction — that is when the system actually changes. `snapper-timeline.timer` stays disabled.

Test:
```bash
sudo pacman -S tree
snapper list                               # a pre/post pair appears
```

## 11. zram

`/etc/systemd/zram-generator.conf`:
```ini
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
```

`/etc/sysctl.d/99-zram.conf`:
```ini
vm.swappiness = 180
vm.page-cluster = 0
```

```bash
sudo systemctl daemon-reload
sudo systemctl start systemd-zram-setup@zram0.service
zramctl && swapon --show
```

No disk swap → no hibernation.

## 12. Cleanup

```bash
sudo systemctl mask systemd-boot-random-seed.service    # systemd-boot feature, Limine ignores it
sudo rm -rf /boot/loader
```

## 13. Multilib + AUR helper

Uncomment the `[multilib]` section in `/etc/pacman.conf` — required for Steam and any 32-bit game libraries (`lib32-*`):

```
[multilib]
Include = /etc/pacman.d/mirrorlist
```

```bash
sudo pacman -Sy
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin && makepkg -si
```

`paru` then handles both repos and AUR, so `packages.txt` installs in one command.

## 14. Baseline snapshot

```bash
sudo snapper -c root create -d "clean base install"
```

---

## Graphical session (when Hyprland goes on)

Hyprland doesn't tell systemd it's a graphical session, so portals (XDPH included) and any
`WantedBy=graphical-session.target` units won't start.

`~/.config/systemd/user/hyprland-session.target` (wiki version — create it with
`SYSTEMD_EDITOR=nvim systemctl --user edit --full --force hyprland-session.target`):
```ini
[Unit]
Description=Hyprland session
BindsTo=graphical-session.target
Wants=graphical-session-pre.target
After=graphical-session-pre.target
PropagatesStopTo=graphical-session.target
```

`BindsTo=` is what starts `graphical-session.target`; `PropagatesStopTo=` is what tears it down
when Hyprland exits.

Started from the Lua config:
```lua
hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start hyprland-session.target")
end)
```

Verify with `systemctl --user list-dependencies hyprland-session.target` and
`systemctl --user status xdg-desktop-portal-hyprland` — if the portal is active, the target is
working; if it's dead, screenshots and screen sharing are what break.

## Rollback

Snapshot entries now appear in the boot menu via limine-snapper-sync:
`limine-snapper-list`, `limine-snapper-info`, `limine-snapper-restore`.

Snapper snapshots are READ-ONLY, so a booted snapshot is a rescue environment,
not a working desktop — greetd and anything else needing a writable /var will
fail. Boot the snapshot, drop to a TTY, run `limine-snapper-restore`, reboot.

Fallback path from an Arch USB if the menu itself is broken:

```bash
mount /dev/nvme0n1p2 /mnt                  # top level, subvolid=5
btrfs subvolume list /mnt                  # find the snapshot number
mv /mnt/@ /mnt/@broken
btrfs subvolume snapshot /mnt/@snapshots/<N>/snapshot /mnt/@
umount /mnt && reboot
```

Delete `@broken` once the system is confirmed good: `btrfs subvolume delete /mnt/@broken`.

Snapshots are read-only by default — a booted snapshot is a rescue environment, not a working desktop. And they are **not** backups: same disk, same failure domain.

---

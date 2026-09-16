# Arch install - btrfs + limine + snapper

A reproducible base install for any machine this configuration runs on.
Ends at a booting system with snapshots and rollback; the desktop itself is
`install.sh` plus the manual steps in the README.

Works on UEFI and on legacy BIOS (coreboot/SeaBIOS included). Where they
differ, both paths are given.

---

## 0. Set these once

Every command below uses these, so nothing needs editing inline.

```bash
DISK=/dev/nvme0n1          # lsblk -o NAME,SIZE,MODEL,TYPE
P=p                        # "p" for nvme/mmc, "" for sata/usb  -> /dev/sda1
ESP=${DISK}${P}1
ROOT=${DISK}${P}2
UCODE=amd-ucode            # or intel-ucode - lscpu | grep "Model name"
HOST=myhost
USER_NAME=myuser
TZ=Europe/Rome             # ls /usr/share/zoneinfo
```

Firmware mode decides the partition layout and the bootloader step:

```bash
[ -d /sys/firmware/efi ] && echo UEFI || echo BIOS
```

```bash
timedatectl set-ntp true
```

---

## 1. Partition

`cfdisk $DISK` (or `fdisk`). New **GPT** label - that wipes the existing table.

**UEFI:**

| # | Size | Type | Becomes |
|---|---|---|---|
| 1 | 1 GiB | EFI System | `/boot` |
| 2 | rest | Linux filesystem | `/` |

**BIOS on GPT:** add a 1 MiB **BIOS boot** partition first, for the bootloader's
second stage. Partition numbers shift by one, so set `ESP=${DISK}${P}2` and
`ROOT=${DISK}${P}3`.

| # | Size | Type | Becomes |
|---|---|---|---|
| 1 | 1 MiB | BIOS boot | - |
| 2 | 1 GiB | Linux filesystem | `/boot` |
| 3 | rest | Linux filesystem | `/` |

In `cfdisk` the type is chosen from a list after creating each partition. In
`fdisk` it's `t`, then `1` = EFI System, `4` = BIOS boot, `20` = Linux
filesystem (the default). Write, quit, confirm with `lsblk`.

1 GiB for `/boot` because kernels, initramfs and `limine.conf` all live there -
512 MiB fills up fast with two kernels plus fallbacks.

No swap partition: zram covers it. That also means **no hibernation** - add a
swap partition of at least RAM size if you need suspend-to-disk.

## 2. Format

```bash
mkfs.fat -F32 -n ESP "$ESP"        # UEFI only
mkfs.ext4 -L boot "$ESP"           # BIOS instead - /boot need not be FAT
mkfs.btrfs -L arch -f "$ROOT"
```

## 3. Subvolumes

```bash
mount "$ROOT" /mnt
for sv in @ @home @log @pkg @snapshots; do btrfs subvolume create /mnt/$sv; done
umount /mnt
```

```
@           →  /
@home       →  /home
@log        →  /var/log
@pkg        →  /var/cache/pacman/pkg
@snapshots  →  /.snapshots
```

`@log` and `@pkg` are separate so a root rollback keeps the logs that explain
the breakage and the packages needed to repair it. `var/lib/portables` and
`var/lib/machines` appear later - systemd creates them, leave them.

## 4. Mount

```bash
OPTS="noatime,compress=zstd:1"
# add ",ssd" on solid state; btrfs autodetects, this only forces it

mount -o $OPTS,subvol=@ "$ROOT" /mnt
mkdir -p /mnt/{home,boot,.snapshots,var/log,var/cache/pacman/pkg}

mount -o $OPTS,subvol=@home      "$ROOT" /mnt/home
mount -o $OPTS,subvol=@log       "$ROOT" /mnt/var/log
mount -o $OPTS,subvol=@pkg       "$ROOT" /mnt/var/cache/pacman/pkg
mount -o $OPTS,subvol=@snapshots "$ROOT" /mnt/.snapshots
mount "$ESP" /mnt/boot

findmnt -R /mnt        # 5 btrfs rows + /boot, subvol= on each
```

No `discard=async` - `fstrim.timer` handles TRIM. Running both is redundant.

## 5. Install base

```bash
pacstrap -K /mnt base base-devel linux linux-firmware btrfs-progs \
  "$UCODE" limine efibootmgr networkmanager neovim git zsh sudo \
  snapper snap-pac zram-generator

genfstab -U /mnt >> /mnt/etc/fstab
```

On UEFI, tighten the ESP line in `/mnt/etc/fstab` - FAT has no permission bits
of its own, so the mask is what restricts it:

```
UUID=XXXX-XXXX  /boot  vfat  defaults,fmask=0077,dmask=0077  0 2
```

Without it `/boot` is world-readable and `bootctl` complains about the random
seed. On BIOS with ext4 `/boot`, use `chmod 700 /boot` instead.

## 6. Chroot

```bash
arch-chroot /mnt

ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
hwclock --systohc

nvim /etc/locale.gen                       # uncomment the locales you want
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us"        > /etc/vconsole.conf

echo "$HOST" > /etc/hostname
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOST.localdomain $HOST
EOF

mkinitcpio -P
passwd
useradd -mG wheel -s /usr/bin/zsh "$USER_NAME"
passwd "$USER_NAME"
EDITOR=nvim visudo                         # uncomment %wheel ALL=(ALL:ALL) ALL and add Defaults !tty_tickets

systemctl enable NetworkManager fstrim.timer snapper-cleanup.timer
```

`btrfs` needs no entry in `MODULES` - the `filesystems` hook detects it from the
mounted root.

## 7. Limine

```bash
blkid -s UUID -o value "$ROOT"             # root UUID for the config below
```

**UEFI:**
```bash
mkdir -p /boot/EFI/limine
cp /usr/share/limine/BOOTX64.EFI /boot/EFI/limine/
efibootmgr --create --disk "$DISK" --part 1 \
  --label "Arch Linux" --loader '\EFI\limine\BOOTX64.EFI' --unicode
```

**BIOS:**
```bash
cp /usr/share/limine/limine-bios.sys /boot/
limine bios-install "$DISK"
```

`/boot/limine.conf`:
```
timeout: 3

/Arch Linux

//Arch Linux
    protocol: linux
    path: boot():/vmlinuz-linux
    cmdline: root=UUID=<uuid> rootflags=subvol=@ rw
    module_path: boot():/<ucode>.img
    module_path: boot():/initramfs-linux.img
```

- Single `/` is a top-level entry; `//` nests under the one above it.
  **limine-snapper-sync requires this nesting** - with kernels at top level it
  reports "Your OS entry has no kernel" and refuses to add snapshots.
- `rootflags=subvol=@` is mandatory. Without it the kernel mounts the btrfs top
  level and boot fails with no useful message.
- Microcode `module_path` must come **before** the initramfs, or it's ignored.
- Never create `/boot/EFI/limine/limine.conf` - that path outranks this file.
- Adding a fallback entry means the image must exist
  (`'fallback'` in `/etc/mkinitcpio.d/linux.preset`, then `mkinitcpio -P`), or
  limine-snapper-sync skips snapshot creation entirely.

Redeploy hook, `/etc/pacman.d/hooks/limine.hook` - UEFI version; on BIOS the
`Exec` line becomes `limine bios-install $DISK`:
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

## 8. First boot: verify

```bash
findmnt -t btrfs
btrfs subvolume list /
journalctl -p 3 -b
dmesg | grep -i microcode      # confirms the right ucode package
```

Errors at boot are often hardware probes for features the CPU lacks
(`virt/tdx: TDX not supported by the host platform` and similar) - harmless.

## 9. Snapper

`create-config` insists on making its own `.snapshots` subvolume where
`@snapshots` already sits, so let it, then put yours back:

```bash
sudo umount /.snapshots
sudo rmdir /.snapshots
sudo snapper -c root create-config /
sudo btrfs subvolume delete /.snapshots
sudo mkdir /.snapshots
sudo mount -a
sudo chmod 750 /.snapshots
sudo btrfs quota disable /     # qgroups badly hurt performance; snapper doesn't need them

findmnt /.snapshots            # must show subvol=/@snapshots
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

`TIMELINE_CREATE="no"` because `snap-pac` already brackets every pacman
transaction - that is when the system actually changes. `snapper-timeline.timer`
stays disabled.

```bash
sudo pacman -S tree
snapper list                   # a pre/post pair appears
```

## 10. zram

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

High swappiness is correct here: swapping to compressed RAM is cheap, so the
kernel should do it eagerly. `page-cluster = 0` disables read-ahead, which only
helps rotational media.

## 11. Cleanup

```bash
sudo systemctl mask systemd-boot-random-seed.service   # systemd-boot feature; limine ignores it
sudo rm -rf /boot/loader
```

## 12. Multilib + AUR helper

`[multilib]` in `/etc/pacman.conf` - required for Steam and any `lib32-*`
package. Skip on a machine that will never need 32-bit libraries.

```
[multilib]
Include = /etc/pacman.d/mirrorlist
```

```bash
sudo pacman -Sy
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin && makepkg -si
```

## 13. Baseline snapshot

```bash
sudo snapper -c root create -d "clean base install"
```

From here: clone the dotfiles repo and run `./install.sh`.

---

## Graphical session

Hyprland doesn't tell systemd it's a graphical session, so portals (XDPH
included) and any `WantedBy=graphical-session.target` unit won't start.

`~/.config/systemd/user/hyprland-session.target` - create it with
`SYSTEMD_EDITOR=nvim systemctl --user edit --full --force hyprland-session.target`
(systemd's editor fallback list is `editor`, `nano`, `vim`, `vi`, none of which
may exist):

```ini
[Unit]
Description=Hyprland session
BindsTo=graphical-session.target
Wants=graphical-session-pre.target
After=graphical-session-pre.target
PropagatesStopTo=graphical-session.target
```

`BindsTo=` starts `graphical-session.target`; `PropagatesStopTo=` tears it down
when Hyprland exits.

Started from the Lua config:
```lua
hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start hyprland-session.target")
end)
```

Verify with `systemctl --user list-dependencies hyprland-session.target` and
`systemctl --user status xdg-desktop-portal-hyprland`. If the portal is active
the target works; if it's dead, screenshots and screen sharing are what break.

No `dbus-update-activation-environment` call is needed - Hyprland manages the
systemd and dbus activation environments itself, disabled only via
`HYPRLAND_NO_SD_VARS=1`.

---

## Rollback

Snapshot entries appear in the boot menu via limine-snapper-sync:
`limine-snapper-list`, `limine-snapper-info`, `limine-snapper-restore`.

Snapper snapshots are **read-only**, so a booted snapshot is a rescue
environment, not a working desktop - a display manager and anything else needing
a writable `/var` will fail. Boot the snapshot, drop to a TTY, run
`limine-snapper-restore`, reboot.

Fallback from an Arch USB if the menu itself is broken:

```bash
mount "$ROOT" /mnt                 # top level, subvolid=5
btrfs subvolume list /mnt          # find the snapshot number
mv /mnt/@ /mnt/@broken
btrfs subvolume snapshot /mnt/@snapshots/<N>/snapshot /mnt/@
umount /mnt && reboot
```

Delete `@broken` once the system is confirmed good:
`btrfs subvolume delete /mnt/@broken`.

Snapshots are **not** backups - same disk, same failure domain.

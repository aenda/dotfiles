#!/bin/bash

# License: GPL v2.0 http://www.gnu.org/licenses/gpl.html
#
# Initially scripted by the Arch Linux Community
# Mircea Bardac (dev AT mircea.bardac.net)
# http://mircea.bardac.net/
# Modified by Jan Janssen, graysky, karol, asdffdsa, iceram, and others
#
# Description:
# Search for files which are not part of installed Arch Linux packages
#
# Usage:
# lostfiles {relaxed|strict}

# get current kernel version for excluding current dkms module folder in /usr/lib/modules

CURRENTKERNEL="$(uname -r)"

if [ $UID != "0" ]; then
  echo "You must run this script as root." 1>&2
  exit 1
fi

# strict mode aims to be more verbose ignoring less

strict() {
  comm -13 \
    <(pacman -Qlq | sed -e 's|/$||' | sort -u) \
    <(find / -not \( \
    -wholename '/dev' -prune -o \
    -wholename '/home' -prune -o \
    -wholename '/lost+found' -prune -o \
    -wholename '/media' -prune -o \
    -wholename '/mnt' -prune -o \
    -wholename '/proc' -prune -o \
    -wholename '/root' -prune -o \
    -wholename '/run' -prune -o \
    -wholename '/scratch' -prune -o \
    -wholename '/srv' -prune -o \
    -wholename '/sys' -prune -o \
    -wholename '/tmp' -prune -o \
    -wholename '/var/.updated' -prune -o \
    -wholename '/var/lock' -prune -o \
    -wholename '/var/lib' -prune -o \
    -wholename '/var/log' -prune -o \
    -wholename '/var/run' -prune -o \
    -wholename '/var/spool' -prune \) | sort -u \
    ) | sed -e 's|^\t||;'
}

# relaxed mode is more forgiving about hits

relaxed() {
  comm -13 \
    <(pacman -Qlq | sed -e 's|/$||' | sort -u) \
    <(find / -not \( \
    -wholename '/swapfile' -prune -o \
    -wholename '/.snapshots' -prune -o \
    -wholename '/boot/syslinux' -prune -o \
    -wholename '/boot/grub' -prune -o \
    -wholename '/boot/loader' -prune -o \
    -wholename '/boot/EFI' -prune -o \
    -wholename '/boot/initramfs*' -prune -o \
    -wholename '/boot/lost+found' -prune -o \
    -wholename '/dev' -prune -o \
    -wholename '/etc/.etckeeper' -prune -o \
    -wholename '/etc/.git' -prune -o \
    -wholename '/etc/.pwd.lock' -prune -o \
    -wholename '/etc/.updated' -prune -o \
    -wholename '/etc/blkid.tab' -prune -o \
    -wholename '/etc/ca-certificates' -prune -o \
    -wholename '/etc/conf.d' -prune -o \
    -wholename '/etc/dfs' -prune -o \
    -wholename '/etc/pacman.d/gnupg' -prune -o \
    -wholename '/etc/adjtime' -prune -o \
    -wholename '/etc/dhcpcd.duid' -prune -o \
    -wholename '/etc/digitalocean' -prune -o \
    -wholename '/etc/fancontrol' -prune -o \
    -wholename '/etc/gshadow' -prune -o \
    -wholename '/etc/gshadow-' -prune -o \
    -wholename '/etc/gshadow.OLD' -prune -o \
    -wholename '/etc/easy-rsa' -prune -o \
    -wholename '/etc/openvpn' -prune -o \
    -wholename '/etc/group' -prune -o \
    -wholename '/etc/group-' -prune -o \
    -wholename '/etc/group.OLD' -prune -o \
    -wholename '/etc/hostname' -prune -o \
    -wholename '/etc/letsencrypt' -prune -o \
    -wholename '/etc/locale.conf' -prune -o \
    -wholename '/etc/localtime' -prune -o \
    -wholename '/etc/ld.so.cache' -prune -o \
    -wholename '/etc/machine-id' -prune -o \
    -wholename '/etc/network.d/ethernet-static' -prune -o \
    -wholename '/etc/os-release' -prune -o \
    -wholename '/etc/passwd' -prune -o \
    -wholename '/etc/passwd-' -prune -o \
    -wholename '/etc/passwd.OLD' -prune -o \
    -wholename '/etc/shadow' -prune -o \
    -wholename '/etc/shadow-' -prune -o \
    -wholename '/etc/shadow.OLD' -prune -o \
    -wholename '/etc/udev/hwdb.bin' -prune -o \
    -wholename '/etc/ssh/ssh_host*' -prune -o \
    -wholename '/etc/NetworkManager/system-connections' -prune -o \
    -wholename '/etc/rc.digitalocean' -prune -o \
    -wholename '/etc/samba/private/passdb.tdb' -prune -o \
    -wholename '/etc/samba/private/secrets.tdb' -prune -o \
    -wholename '/etc/samba/private/smbpasswd' -prune -o \
    -wholename '/etc/samba/smb.conf' -prune -o \
    -wholename '/etc/ssl' -prune -o \
    -wholename '/etc/xml/catalog' -prune -o \
    -wholename '/etc/systemd/system' -prune -o \
    -wholename '/etc/systemd/network' -prune -o \
    -wholename '/etc/udev/rules.d/70-digitalocean-net.rules' -prune -o \
    -wholename '/etc/vconsole.conf' -prune -o \
    -wholename '/etc/zfs/zpool.cache' -prune -o \
    -wholename '/home' -prune -o \
    -wholename '/lost+found' -prune -o \
    -wholename '/opt/google-appengine-go/appengine/api/*.pyc' -prune -o \
    -wholename '/media' -prune -o \
    -wholename '/mnt' -prune -o \
    -wholename '/proc' -prune -o \
    -wholename '/root' -prune -o \
    -wholename '/run' -prune -o \
    -wholename '/scratch' -prune -o \
    -wholename '/srv' -prune -o \
    -wholename '/sys' -prune -o \
    -wholename '/tmp' -prune -o \
    -wholename '/usr/bin/__pycache__' -prune -o \
    -wholename '/usr/lib/ghc-*' -prune -o \
    -wholename '/usr/lib/locale/locale-archive' -prune -o \
    -wholename '/usr/lib/modules/'$CURRENTKERNEL'' -prune -o \
    \( -wholename '/usr/lib/node_modules*' -and -not -wholename '/usr/lib/node_modules/npm/*' \) -o \
    -wholename '/usr/lib/python*/site-packages' -prune -o \
    -wholename '/usr/lib/ruby/gems' -prune -o \
    -wholename '/usr/lib/virtualbox/ExtensionPacks/Oracle_VM_VirtualBox_Extension_Pack' -prune -o \
    -wholename '/usr/local' -prune -o \
    -wholename '/usr/share/dict/words' -prune -o \
    -wholename '/usr/share/info/dir' -prune -o \
    -wholename '/usr/share/.mono/certs/Trust' -prune -o \
    -wholename '/usr/share/applications/mimeinfo.cache' -prune -o \
    -wholename '/usr/share/backintime' -prune -o \
    -wholename '/usr/share/fonts/TTF/fonts.dir' -prune -o \
    -wholename '/usr/share/fonts/TTF/fonts.scale' -prune -o \
    -wholename '/usr/share/fonts/misc/fonts.dir' -prune -o \
    -wholename '/usr/share/fonts/misc/fonts.scale' -prune -o \
    -wholename '/usr/share/mime' -prune -o \
    -wholename '/usr/share/webapps/owncloud/data' -prune -o \
    -wholename '/usr/var/cache' -prune -o \
    -wholename '/usr/var/run' -prune -o \
    -wholename '/var/.updated' -prune -o \
    -wholename '/var/lost+found' -prune -o \
    -wholename '/var/abs' -prune -o \
    -wholename '/var/cache' -prune -o \
    -wholename '/var/lock' -prune -o \
    -wholename '/var/lib' -prune -o \
    -wholename '/var/log' -prune -o \
    -wholename '/var/run' -prune -o \
    -wholename '/var/spool' -prune -o \
    -wholename '/var/db/sudo' -prune -o \
    -wholename '/var/tmp' -prune \) | sort -u \
    ) | sed -e 's|^\t||;'
}

case "$1" in
  s|S|strict|Strict)
    strict
    ;;
  r|R|relaxed|Relaxed)
    relaxed
    ;;
  *)
    echo "Usage $0 {strict|relaxed}"
    ;;
esac
exit 0

# vim:set ts=2 sw=2 et:

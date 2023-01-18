MAGISKTMP="$(magisk --path)" || MAGISKTMP=/sbin
MODPATH="${0%/*}"

[ -d "$MAGISKTMP/.magisk/mirror/early-mount/initrc.d" ] || exit

rm -rf "$MAGISKTMP/.magisk/mirror/early-mount/initrc.d/oem.rc"
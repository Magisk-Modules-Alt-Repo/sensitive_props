MAGISKTMP="$(magisk --path)" || MAGISKTMP=/sbin
MODPATH="${0%/*}"

# Use Magisk Delta feature to dynamic patch prop

[ -d "$MAGISKTMP/.magisk/mirror/early-mount/initrc.d" ] && cp -Tf "$MODPATH/oem.rc" "$MAGISKTMP/.magisk/mirror/early-mount/initrc.d/oem.rc"

. "$MODPATH/resetprop.sh"

# Hiding SELinux | Use toybox to protect *stat* access time reading
if [[ "$(toybox cat /sys/fs/selinux/enforce)" == "0" ]]; then
    chmod 640 /sys/fs/selinux/enforce
    chmod 440 /sys/fs/selinux/policy
fi

while [ "$(getprop sys.boot_completed)" != 1 ]; do
    sleep 1
done

# these props should be set after boot completed to avoid breaking some device features

check_resetprop ro.boot.vbmeta.device_state locked
check_resetprop ro.boot.verifiedbootstate green
check_resetprop ro.boot.flash.locked 1
check_resetprop ro.boot.veritymode enforcing
check_resetprop ro.boot.warranty_bit 0
check_resetprop ro.warranty_bit 0
check_resetprop ro.debuggable 0
check_resetprop ro.secure 1
check_resetprop ro.secureboot.devicelock 1
check_resetprop ro.secureboot.lockstate locked
check_resetprop ro.build.type user
check_resetprop ro.build.keys release-keys
check_resetprop ro.build.tags release-keys
check_resetprop ro.vendor.boot.warranty_bit 0
check_resetprop ro.vendor.warranty_bit 0
check_resetprop vendor.boot.vbmeta.device_state locked
check_resetprop vendor.boot.verifiedbootstate green
check_resetprop sys.oem_unlock_allowed 0
check_resetprop ro.oem_unlock_supported 0
check_resetprop init.svc.flash_recovery stopped
check_resetprop ro.boot.realmebootstate green
check_resetprop ro.boot.realme.lockstate 1

# fake encryption
check_resetprop ro.crypto.state encrypted

maybe_resetprop ro.bootmode recovery unknown
maybe_resetprop ro.boot.bootmode recovery unknown
maybe_resetprop ro.boot.mode recovery unknown
maybe_resetprop vendor.bootmode recovery unknown
maybe_resetprop vendor.boot.bootmode recovery unknown
maybe_resetprop vendor.boot.mode recovery unknown
maybe_resetprop ro.boot.hwc CN GLOBAL
maybe_resetprop ro.boot.hwcountry China GLOBAL
selinux="$(resetprop ro.build.selinux)"
[ -z "$selinux" ] || resetprop --delete ro.build.selinux

for prefix in system vendor system_ext product oem odm vendor_dlkm odm_dlkm; do
    check_resetprop ro.${prefix}.build.type user
    check_resetprop ro.${prefix}.build.tags release-keys
done

if [[ "$(resetprop -v ro.product.first_api_level)" -ge 33 ]]; then
    resetprop -v -n ro.product.first_api_level 32
fi

# Don't expose the raw commandline to unprivileged processes.
chmod 0440 /proc/cmdline

# Restrict permissions to socket file to hide Magisk & co.
chmod 0440 /proc/net/unix
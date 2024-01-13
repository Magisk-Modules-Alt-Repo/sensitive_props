MAGISKTMP="$(magisk --path)" || MAGISKTMP=/sbin
MODPATH="${0%/*}"


# Use Magisk Delta feature to dynamic patch prop

[ -d "$MAGISKTMP/.magisk/mirror/early-mount/initrc.d" ] && cp -Tf "$MODPATH/oem.rc" "$MAGISKTMP/.magisk/mirror/early-mount/initrc.d/oem.rc"

. "$MODPATH/resetprop.sh"

# Hiding SELinux | Use toybox to protect *stat* access time reading
if [ "$(toybox cat /sys/fs/selinux/enforce)" == "0" ]; then
    chmod 640 /sys/fs/selinux/enforce
    chmod 440 /sys/fs/selinux/policy
fi

while [ "$(getprop sys.boot_completed)" != 1 ]; do
    sleep 1
done

# these props should be set after boot completed to avoid breaking some device features

# Avoid breaking Realme fingerprint scanners
check_resetprop ro.boot.flash.locked 1

# Avoid breaking Oppo fingerprint scanners
check_resetprop ro.boot.vbmeta.device_state locked

# Avoid breaking OnePlus display modes/fingerprint scanners
check_resetprop vendor.boot.verifiedbootstate green

# Avoid breaking OnePlus/Oppo display fingerprint scanners on OOS/ColorOS 12+
check_resetprop ro.boot.verifiedbootstate green
check_resetprop ro.boot.veritymode enforcing
check_resetprop vendor.boot.vbmeta.device_state locked

# Samsung
check_resetprop ro.boot.warranty_bit 0
check_resetprop ro.warranty_bit 0
check_resetprop ro.vendor.boot.warranty_bit 0
check_resetprop ro.vendor.warranty_bit 0

# OnePlus
check_resetprop ro.is_ever_orange 0
    
check_resetprop ro.debuggable 0
check_resetprop ro.secure 1
check_resetprop ro.adb.secure 1

check_resetprop ro.secureboot.devicelock 1
check_resetprop ro.secureboot.lockstate locked

# RootBeer, Microsoft
check_resetprop ro.build.type user
check_resetprop ro.build.keys release-keys
check_resetprop ro.build.tags release-keys

# makes bank apps and Google Pay happy
check_resetprop sys.oem_unlock_allowed 0
check_resetprop ro.oem_unlock_supported 0

# Init.rc
check_resetprop init.svc.flash_recovery stopped

# Realme
check_resetprop ro.boot.realmebootstate green
check_resetprop ro.boot.realme.lockstate 1

# fake encryption
check_resetprop ro.crypto.state encrypted

# Disable Lsposed logs
resetprop -n persist.log.tag.LSPosed S
resetprop -n persist.log.tag.LSPosed-Bridge S

# Fix Native Bridge Detection 
# resetprop --delete ro.dalvik.vm.native.bridge

# Hide that we booted from recovery when magisk is in recovery mode
maybe_resetprop ro.bootmode recovery unknown
maybe_resetprop ro.boot.bootmode recovery unknown
maybe_resetprop ro.boot.mode recovery unknown
maybe_resetprop vendor.bootmode recovery unknown
maybe_resetprop vendor.boot.bootmode recovery unknown
maybe_resetprop vendor.boot.mode recovery unknown

# MIUI cross-region flash
maybe_resetprop ro.boot.hwc CN GLOBAL
maybe_resetprop ro.boot.hwcountry China GLOBAL

# SELinux
if [ -n "$(resetprop ro.build.selinux)" ]; then
    resetprop --delete ro.build.selinux
fi

for prefix in system vendor system_ext product oem odm vendor_dlkm odm_dlkm; do
    check_resetprop ro.${prefix}.build.type user
    check_resetprop ro.${prefix}.build.tags release-keys
done

# Avoid breaking encryption, set shipping level to 32 for devices >=33 to allow for software attestation
if [[ "$(resetprop -v ro.product.first_api_level)" -ge 33 ]]; then
    resetprop -v -n ro.product.first_api_level 32
fi

# Don't expose the raw commandline to unprivileged processes.
chmod 0440 /proc/cmdline

# Restrict permissions to socket file to hide Magisk & co.
chmod 0440 /proc/net/unix

# Hide Addon.d
chmod 0750 /system/addon.d

# Fix Restrictions on non-SDK interface
settings delete global hidden_api_policy
settings delete global hidden_api_policy_pre_p_apps
settings delete global hidden_api_policy_p_apps
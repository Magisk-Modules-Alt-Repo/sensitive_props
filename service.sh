#!/system/bin/sh

MAGISKDIR="$(magisk --path)"
[ -z "$MAGISKDIR" ] && MAGISKDIR=/sbin
for propfile in /default.prop /system/build.prop /vendor/build.prop /product/build.prop /vendor/odm/etc/build.prop; do
    cat $propfile |  grep "^ro." | grep userdebug >>"$MAGISKDIR/.magisk/hide-userdebug.prop"
    cat $propfile |  grep "^ro." | grep test-keys >>"$MAGISKDIR/.magisk/hide-userdebug.prop"
done
sed -i "s/userdebug/user/g" "$MAGISKDIR/.magisk/hide-userdebug.prop"
sed -i "s/test-keys/release-keys/g" "$MAGISKDIR/.magisk/hide-userdebug.prop"
resetprop --file "$MAGISKDIR/.magisk/hide-userdebug.prop"

{
    while true; do
        resetprop -n init.svc.adbd stopped
        sleep 1;
    done
} &
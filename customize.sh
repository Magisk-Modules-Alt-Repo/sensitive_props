$BOOTMODE || abort "! Recovery is not supported"

ui_print "- Reset sensitive props"

sh "$MODPATH/service.sh" 2>&1
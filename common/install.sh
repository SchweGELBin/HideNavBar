##########################################################################################
# Custom Logic
##########################################################################################

#Detect and use compatible AAPT
chmod +x "$MODPATH"/tools/*
[ "$($MODPATH/tools/aapt v)" ] && AAPT=aapt
[ "$($MODPATH/tools/aapt64 v)" ] && AAPT=aapt64
cp -af "$MODPATH"/tools/$AAPT "$MODPATH"/aapt
mkdir -p "$MODPATH"/Mods/Q/NavigationBarModeGestura/
mkdir -p "$MODPATH"/Mods/Qtmp/
mkdir -p "$MODPATH"/system/app/
cp -rf "$MODPATH"/Mods/QS/* "$MODPATH"/Mods/Qtmp/
cp -rf "$MODPATH"/tools/service.sh "$MODPATH"

#if [ -d /system/xbin/ ] && [ ! -f /system/xbin/empty ] ; then
#    mkdir -p "$MODPATH"/system/xbin/
#    cp -rf "$MODPATH"/tools/hn "$MODPATH"/system/xbin/
#    cp -rf "$MODPATH"/tools/hnr "$MODPATH"/system/xbin/
#else
#    mkdir -p "$MODPATH"/system/bin/
#    cp -rf "$MODPATH"/tools/hn "$MODPATH"/system/bin/
#    cp -rf "$MODPATH"/tools/hnr "$MODPATH"/system/bin/
#fi

#Find and delete conflicting overlays/package-cache/resource-cache
find /data/adb/modules -type d -not -path "*HideNavBar/system*" -iname "*navigationbarmodegestural*" -exec rm -rf {} \; 2>/dev/null 
find /data/system/package_cache -type f -iname "*NavigationBarMode*" -exec rm -rf {} \; 2>/dev/null
find /data/resource-cache -type f -iname "*NavigationBarMode*" -exec rm -rf {} \; 2>/dev/null

#Fullscreen options
#KeyboardHeight - 0
BH=0.0
FBH=0
FFH=0
FH=0.0
#Sensitivity
SS=true
#ImmersiveMode - False
FIM=false
#FullscreenMode
VAR3=a
#HideKeyboardButtons - False
HKB=false
#GestureSensitivity (Android Default)
GS=32.0
FGS=9000
#DisableBackGesture - False
DBG=false
settings delete secure back_gesture_inset_scale_left &>/dev/null
settings delete secure back_gesture_inset_scale_right &>/dev/null

#Write to overlay resources
RES="$MODPATH"/Mods/Qtmp/res/values/dimens.xml
FOL="$MODPATH"/service.sh

if [ "$API" -ge 29 ]; then
sed -i s/0.3/"$BH"/g "$RES"
sed -i s/0.1/"$FH"/g "$RES"
sed -i s/0.2/"$GS"/g "$RES"
mkdir -p "$MODPATH"/Mods/Qtmp/res/values-sw900dp/
mkdir -p "$MODPATH"/Mods/Qtmp/res/values-sw600dp/
mkdir -p "$MODPATH"/Mods/Qtmp/res/values-440dpi/
mkdir -p "$MODPATH"/Mods/Qtmp/res/values-xhdpi/
mkdir -p "$MODPATH"/Mods/Qtmp/res/values-xxhdpi/
mkdir -p "$MODPATH"/Mods/Qtmp/res/values-xxxhdpi/
cp -rf "$MODPATH"/Mods/Qtmp/res/values/dimens.xml "$MODPATH"/Mods/Qtmp/res/values-sw900dp/
cp -rf "$MODPATH"/Mods/Qtmp/res/values/dimens.xml "$MODPATH"/Mods/Qtmp/res/values-sw600dp/
cp -rf "$MODPATH"/Mods/Qtmp/res/values/dimens.xml "$MODPATH"/Mods/Qtmp/res/values-440dpi/
cp -rf "$MODPATH"/Mods/Qtmp/res/values/dimens.xml "$MODPATH"/Mods/Qtmp/res/values-xhdpi/
cp -rf "$MODPATH"/Mods/Qtmp/res/values/dimens.xml "$MODPATH"/Mods/Qtmp/res/values-xxhdpi/
cp -rf "$MODPATH"/Mods/Qtmp/res/values/dimens.xml "$MODPATH"/Mods/Qtmp/res/values-xxxhdpi/
fi

#Detect original overlay location
#OP=$(find /system/overlay /product/overlay /vendor/overlay /system_ext/overlay -type d -iname "navigationbarmodegestural" | cut -d 'N' -f1)

#Building overlays (A11 and below)
if [ "$API" -lt 34 ] && [ "$API" -ge 29 ]; then
    "$MODPATH"/aapt p -f -v -M "$MODPATH/Mods/Qtmp/AndroidManifest.xml" -I /system/framework/framework-res.apk -S "$MODPATH/Mods/Qtmp/res" -F "$MODPATH"/unsigned.apk >/dev/null
elif [ "$API" -ge 34 ]; then
     "$MODPATH"/aapt p -f -v -M "$MODPATH/Mods/Qtmp/AndroidManifest.xml" -I "$MODPATH"/tools/framework-res.apk -S "$MODPATH/Mods/Qtmp/res" -F "$MODPATH"/unsigned.apk >/dev/null
fi

if [ "$API" -ge 30 ]; then
"$MODPATH"/tools/zipsigner "$MODPATH"/unsigned.apk "$MODPATH"/Mods/Q/NavigationBarModeGestura/NavigationBarModeGesturalOverlay.apk
elif [ "$API" -eq 29 ] ; then
"$MODPATH"/tools/zipsignero "$MODPATH"/unsigned.apk "$MODPATH"/Mods/Q/NavigationBarModeGestura/NavigationBarModeGesturalOverlay.apk
fi

#Install overlays (A11 and below)
if [ "$API" -ge 29 ]; then
mkdir -p "$MODPATH"/system"$OP"
cp -rf "$MODPATH"/Mods/Q/* "$MODPATH"/Mods/"$VAR3"/ "$MODPATH"/system/app/
 if [ "$HKB" = true ]; then
 cp -rf "$MODPATH"/Mods/HKB/ "$MODPATH"/system/app/
 fi
fi

#ui_print "Complete"

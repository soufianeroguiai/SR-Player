#!/bin/bash
echo "جاري بناء التطبيق..."
flutter build apk --debug
echo "تم البناء بنجاح! جاري التثبيت..."
am start -a android.intent.action.VIEW -d "file:///public/S-Player/build/app/outputs/flutter-apk/app-debug.apk" -t application/vnd.android.package-archive

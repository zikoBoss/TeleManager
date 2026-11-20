# بيئة البناء والتحقق — المهمة 02

## Sandbox المحلية

المضيف المحلي Ubuntu 24.04 ARM64. Android SDK Command-line Tools و`platforms;android-36` revision 2 و`build-tools;36.1.0` و`platform-tools` revision 37.0.3 مثبتة محليًا، وقُبل `android-sdk-license` وحده بعد موافقة المستخدم. ملفات `adb` و`aapt` و`aapt2` x86-64؛ لا تشغّلها على ARM64. Flutter وDart غير متاحين محليًا، لذلك لم يُشغّل تحليل Flutter أو بناء Android على Sandbox.

## Runner خارجي

استخدم GitHub Actions runner `ubuntu-24.04` x64. سجل التشغيل النهائي على المشروع الموجود بالمستودع، [44744990391](https://github.com/zikoBoss/TeleManager/actions/runs/44744990391)، يثبت `x86_64` وUbuntu 24.04.5، وTemurin JDK `21.0.13+9`، وFlutter Stable `3.50.0`، وDart `3.14.0`، وAndroid Command-line Tools / `sdkmanager` `12.0`. تحققت الحزم المحددة: `platforms;android-36` revision 2، و`build-tools;36.1.0`، و`platform-tools` revision `37.0.3`.

أظهر `flutter doctor -v` Flutter وAndroid toolchain، مع تحذير عن تراخيص Android الأخرى غير المقبولة، وتحذير عن GTK و`eglinfo` الخاصين بتطوير Linux desktop. بقيت التحذيرات ظاهرة؛ لم ينفذ workflow `sdkmanager --licenses` أو قبولًا إضافيًا. سجل تثبيت الحزم أظهر `android-sdk-license` وحده.

## scaffold وإصدارات البناء

وُلّد scaffold Android-only من Flutter 3.50.0 على runner x64 في [run 44743248440](https://github.com/zikoBoss/TeleManager/actions/runs/44743248440)، ثم أُضيف إلى الفرع `task02-github-ci`. يثبت سجل build في ذلك التشغيل وفي [تشغيل المستودع 44744990391](https://github.com/zikoBoss/TeleManager/actions/runs/44744990391) الإعدادات التي أنشأها القالب: Android Gradle Plugin `9.3.1`، Kotlin Gradle Plugin `2.4.20`، وGradle wrapper `9.5.0`. أبلغ Gradle عن Kotlin مضمّن `2.3.20`؛ هذا ليس رقم Kotlin Gradle Plugin. يحدد القالب Java/Kotlin bytecode target `17`.

معرّف Android الحالي `com.example.telemanager` هو القيمة الافتراضية التي ولّدها Flutter، وليس معرّف نشر اعتمده المستخدم. ملف `android/app/build.gradle.kts` لا يثبت إصدار NDK. مع ذلك، أثناء بناء APK نزّل Gradle تلقائيًا Android NDK Side by side `28.2` (`r28c`). هذا أثر جانبي مثبت في سجل البناء، وليس تثبيتًا طلبه `sdkmanager` في خطوة إعداد الحزم ولا قرارًا معماريًا لمشروع TeleManager. لم يسجل workflow قبول أي معرف ترخيص غير `android-sdk-license`.

## النتائج الفعلية

في run `44744990391` على commit `d8d26fb`:

- نجح `flutter doctor -v` مع التحذيرات المذكورة أعلاه.
- نجح `dart format --output=none --set-exit-if-changed lib test`؛ لم تتغير ملفات التنسيق.
- نجح `flutter analyze`: `No issues found!`.
- نجح `flutter test`: اختبار widget واحد (`Counter increments smoke test`). هذا اختبار القالب، وليس اختبارًا لوظائف TeleManager.
- نجح `flutter build apk --debug`، ثم تحقق وجود APK غير فارغ ورفع كـartifact.

APK المنزّل من artifact حجمه `157,929,508` بايت، وبصمة SHA-256 هي `1a493573f872fa4167c92a0e6d043039372c4a7fd83f9e30c139b88a1a744666`. اجتاز `unzip -t` دون أخطاء. الملف محفوظ في `build/app/outputs/flutter-apk/app-debug.apk` وهو بناء debug غير موقع للنشر.

المهمة 02 الخاصة ببيئة Flutter وAndroid وscaffold والتحليل والاختبار والبناء اكتملت. لم يبدأ العمل في المرحلة 03، ولم يدمج فرع المهمة إلى `main`.

# إعداد Flutter وKotlin وAndroid SDK

## الحالة المحلية — Sandbox ARM64

المضيف المحلي Ubuntu 24.04 بمعمارية `aarch64`. Android SDK Command-line Tools الرسمية في `/home/ubuntu/Android/Sdk/cmdline-tools/latest` (`sdkmanager` `22.0`). Flutter وDart غير متاحين على `PATH` محليًا، ولم تُشغّل أدوات Flutter أو APK على ARM64.

حزم Android المحلية المثبتة بعد الموافقة هي `platforms;android-36` revision 2 و`build-tools;36.1.0` و`platform-tools` revision `37.0.3`. قُبل `android-sdk-license` وحده. أظهر `file` أن `adb` و`aapt` و`aapt2` x86-64؛ لا يمكن تشغيلها على ARM64. `android.jar` موجود واجتاز `unzip -t`. لم يثبت Emulator أو NDK أو CMake يدويًا على Sandbox.

## بيئة GitHub Actions x64

يستخدم workflow runner `ubuntu-24.04` بمعمارية x64. أثبت [تشغيل إعداد الأدوات 44740810758](https://github.com/zikoBoss/TeleManager/actions/runs/44740810758) و[تشغيل المشروع 44744990391](https://github.com/zikoBoss/TeleManager/actions/runs/44744990391) الإصدارات التالية:

- Ubuntu `24.04.5`، ومعمارية `x86_64`.
- Temurin JDK `21.0.13+9`.
- Flutter Stable `3.50.0`، وDart `3.14.0` بعد التحقق من archive الرسمي وSHA-256.
- Android Command-line Tools / `sdkmanager` `12.0`.
- `platforms;android-36` revision 2، و`build-tools;36.1.0`، و`platform-tools` `37.0.3`.

يقبل workflow `android-sdk-license` وحده، ولا يشغّل `sdkmanager --licenses`. أظهر `flutter doctor -v` تحذير تراخيص Android أخرى غير مقبولة، إضافة إلى تحذيرات GTK و`eglinfo` الخاصة بتطوير Linux desktop. لم تُخفَ التحذيرات.

## scaffold وإعداد Gradle/Kotlin

وُلّد مشروع Android-only بـFlutter 3.50.0 على x64، ثم نُقل إلى الفرع. يحتوي على `lib/main.dart` و`test/widget_test.dart` و`android/app/src/main/kotlin/com/example/telemanager/MainActivity.kt` وGradle wrapper. ليس فيه بعد TM-Core أو TDLib أو Drift أو Riverpod أو GoRouter أو واجهة TeleManager فعلية.

قيم scaffold الحالية التي أظهرها التشغيل: Android Gradle Plugin `9.3.1`، Kotlin Gradle Plugin `2.4.20`، Gradle wrapper `9.5.0`، وهدف bytecode Java/Kotlin `17`. Kotlin المضمّن في Gradle `9.5.0` هو `2.3.20`، وهو غير نسخة Kotlin Gradle Plugin. هذه الإعدادات جاءت من Flutter 3.50.0 template، وليست قرارات أُقرت قبل التوليد. `applicationId` هو `com.example.telemanager` المؤقت، ويجب استبداله بمعرّف يعتمد لاحقًا قبل النشر.

لم يثبت scaffold إصدار NDK في Gradle. مع ذلك، أظهر build أن Gradle نزّل NDK Side by side `28.2` (`r28c`) تلقائيًا. لم يطلبه workflow صراحة في خطوة `sdkmanager --install` ولم يظهر قبول ترخيص إضافي؛ بقي `android-sdk-license` وحده في نتيجة خطوة قبول الترخيص. راجع سجل التشغيل قبل إدخال أي اعتماد native.

## النتائج الفعلية

في [run 44744990391](https://github.com/zikoBoss/TeleManager/actions/runs/44744990391)، على الملفات المضافة فعليًا إلى commit `d8d26fb`:

- نجح `flutter doctor -v` مع التحذيرات المسجلة.
- نجح تنسيق `dart format --output=none --set-exit-if-changed lib test` دون تعديل ملفات.
- نجح `flutter analyze` ولم يعثر على مشاكل.
- نجح `flutter test` باختبار widget واحد من القالب الافتراضي.
- نجح `flutter build apk --debug` ورفع artifact.

تقرير الأدلة وبصمة APK في [`TASK02_STATUS_2026-11-19.md`](TASK02_STATUS_2026-11-19.md). المهمة 02 مكتملة، ولم تبدأ المرحلة 03 أو يحصل دمج إلى `main`.

## `scripts/setup_toolchain.sh`

السكربت لم يُشغّل في جولة التدقيق؛ تمت مراجعته ساكنًا. على ARM64 ينفذ `apt-get update` ويثبت متطلبات نظام، ويتحقق من Command-line Tools وقد ينزلها إذا غابت، ثم يخرج بالرمز `2` قبل تنزيل Flutter أو تحديث `.bashrc` أو تثبيت حزم منصات SDK أو قبول التراخيص أو إنشاء المشروع أو اختبار/بناء APK. لذلك تشغيله لا يكمل إعداد Android على ARM64.

على Linux x86-64 ينزّل السكربت Flutter Stable المتغير وقت التشغيل بعد التحقق من SHA، ويضيف المسارات إلى PATH ويشغّل `flutter --version`. لكنه لا يثبت حزم Android المطلوبة، ولا يقبل التراخيص، ولا ينشئ scaffold أو يشغّل التحليل والاختبار أو يبني APK.

## مراجع

[1]: https://docs.flutter.dev/install/manual "Install Flutter manually"
[2]: https://docs.flutter.dev/platform-integration/android/setup "Set up Android development"
[3]: https://developer.android.com/studio "Android Studio and SDK command-line tools downloads"
[4]: https://docs.flutter.dev/reference/create-new-app "Create a new Flutter app"
[5]: https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json "Official Flutter Linux release manifest"

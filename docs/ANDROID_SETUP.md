# إعداد Flutter وKotlin وAndroid SDK

## الحالة الحالية — 2026-11-19

المضيف Ubuntu 24.04 بمعمارية `aarch64`/ARM64. Android SDK Command-line Tools الرسمية موجودة في `/home/ubuntu/Android/Sdk/cmdline-tools/latest`، و`sdkmanager --version` يعيد `22.0`. Flutter وDart وGradle وKotlin compiler غير متاحين على `PATH`. لم يُنشأ scaffold Flutter، ولم تُنفذ `flutter doctor` أو `flutter analyze` أو `flutter test` أو عملية بناء APK.

المستودع المحلي مهيأ، لكن لا يوجد commit أو remote؛ لم يُنشأ مستودع GitHub. تمت دراسة GitHub Actions كخيار خارجي فقط، دون إنشاء workflow أو تنفيذ بناء. التفاصيل في [تقرير المهمة 02](TASK02_STATUS_2026-11-19.md).

## دعم Flutter على مضيف Linux ARM64

تُظهر manifests الرسمية التي فُحصت لإصدار Flutter Stable 3.50.0 أن سجل Linux الوحيد يستخدم `dart_sdk_arch: x64`، ولا يوجد سجل Linux ARM64. السجل ARM64 للإصدار نفسه يخص macOS. في فحص سابق للحزمة الرسمية على Linux، كان Dart المضمّن ELF x86-64 وفشل تشغيله على ARM64 برسالة `Exec format error`. لم تُجرَ محاولة تنزيل أو تثبيت Flutter في جولة التدقيق الحالية. تفاصيل السجلات وروابط الأرشيفات وSHA-256 في [`FLUTTER_LINUX_ARM64_SUPPORT.md`](FLUTTER_LINUX_ARM64_SUPPORT.md). [6] [7]

## حزم Android SDK المثبتة

وافق المستخدم على نطاق الحزم الثلاث التالية، ثم وافق على قبول `android-sdk-license` وحده. أظهر `sdkmanager --list_installed`، وملفات `source.properties` و`package.xml`، الحالات التالية:

- `platforms;android-36`، revision `2` (API 36)، في `/home/ubuntu/Android/Sdk/platforms/android-36`.
- `build-tools;36.1.0` في `/home/ubuntu/Android/Sdk/build-tools/36.1.0`.
- `platform-tools`، revision `37.0.3`، في `/home/ubuntu/Android/Sdk/platform-tools`.

ملف `/home/ubuntu/Android/Sdk/platforms/android-36/android.jar` موجود واجتاز `unzip -t` دون أخطاء. بصمات SHA-256 لبعض الملفات محفوظة في تقرير المهمة 02 كسجل محلي للمقارنة، وليست مقارنةً مستقلة ببصمات أرشيفات Google الرسمية.

قُبل `android-sdk-license` وحده. بقيت سبعة تراخيص أخرى غير مقبولة وفق سجل التثبيت؛ لا يُفترض أن موافقة المستخدم على الترخيص في Sandbox تمتد إلى أي runner خارجي. نص الترخيص المقبول وملخصه موثقان في [`ANDROID_SDK_LICENSE_REVIEW.md`](ANDROID_SDK_LICENSE_REVIEW.md).

أظهر `file` أن الملفات التنفيذية `adb` و`aapt` و`aapt2` هي ELF x86-64. لم تُشغّل على مضيف ARM64، ولذلك لا تعني حالة “مثبت” أنها قابلة للاستخدام على هذا المضيف. `android.jar` وmetadata موجودان، لكن أدوات البناء المطلوبة ليست صالحة للتشغيل هنا. لم يُطلب أو يثبت Emulator أو NDK أو CMake.

ضُبط `ANDROID_HOME` و`ANDROID_SDK_ROOT` في `~/.bashrc` وأضيف `cmdline-tools/latest/bin` فقط إلى `PATH`. Java OpenJDK `21.0.12.1` مثبتة وتعمل على AArch64. لم تُضف مجلدات `platform-tools` أو `build-tools` إلى `PATH` على هذا المضيف.

## مراجعة `scripts/setup_toolchain.sh`

راجعنا السكربت بقراءة الشيفرة فقط؛ لم نشغّله في جولة التدقيق لأن بدايته تنفذ `apt-get update` وتثبت حزم نظام وقد تنزّل أدوات عند غيابها.

على ARM64 ينفذ السكربت أولاً `apt-get update` وتثبيت متطلبات النظام (`curl`, `git`, `unzip`, `xz-utils`, `zip`, `libglu1-mesa`). ثم يتأكد من وجود Android Command-line Tools؛ وإذا لم يوجد `sdkmanager` ينزّل حزمة Command-line Tools Linux المحددة، ويتحقق من SHA-256 الرسمي ويفكها. بعد ذلك يقرأ `uname -m`، ويطبع رسالة العائق ويخرج بالرمز `2` في فرع `aarch64|arm64`.

بسبب الخروج المبكر، لا يصل السكربت على ARM64 إلى قراءة manifest Flutter أو تنزيل Flutter أو تثبيته، ولا يصل إلى إعداد أسطر `ANDROID_HOME` و`ANDROID_SDK_ROOT` و`PATH` في `.bashrc` أو تنفيذ `flutter --version`. ولا يثبت `platforms;android-36` أو `build-tools;36.1.0` أو `platform-tools`، ولا يقبل تراخيص Android SDK، ولا ينشئ مشروع Flutter أو يشغل التحليل أو الاختبارات أو بناء APK. لذا فإن تشغيله لا يكمل إعداد Android على ARM64، حتى لو كانت Command-line Tools موجودة.

على Linux x86-64 يقرأ السكربت manifest ويختار إصدار Flutter stable الحالي وقت التشغيل ويتحقق من SHA-256 قبل فك الحزمة، ثم يضيف مسارات Flutter وCommand-line Tools و`platform-tools` إلى PATH ويشغّل `flutter --version`. لكنه لا يثبت حزم Android Platform أو Build-Tools أو Platform-Tools نفسها، ولا يقبل التراخيص، ولا ينشئ scaffold أو يشغّل التحليل والاختبارات أو يبني APK. كما أن اختيار Flutter فيه يتبع أحدث stable في manifest وقت التشغيل وليس إصدارًا ثابتًا محددًا للمشروع.

## Kotlin وGradle والتحقق اللاحق

لا يحتوي المستودع حاليًا على `pubspec.yaml` أو `android/gradlew` أو `gradle-wrapper.properties` أو ملفات إعداد Gradle/Kotlin فعلية. لذلك لا توجد نسخ Kotlin Gradle Plugin أو Android Gradle Plugin أو Gradle خاصة بـ TeleManager لتدقيقها أو اعتمادها. لا تُختَر هذه الإصدارات بالتخمين؛ تُحدد بعد إنشاء scaffold رسمي على مضيف متوافق، ثم مراجعة إعداداته ومصفوفة التوافق.

بعد توفر بيئة Linux x86-64 موثوقة وإنشاء scaffold، تكون خطوات التحقق المطلوبة: `dart format --output=none --set-exit-if-changed lib test`، ثم `flutter analyze` و`flutter test`، وأخيرًا `flutter build apk --debug` بعد التحقق من وجود مكونات SDK المطلوبة على مضيف البناء المتوافق والحصول على الموافقات اللازمة لتراخيصها هناك. الحزم المثبتة في Sandbox الحالية لا تجعل أدوات x86-64 قابلة للتشغيل على ARM64. لا تُسجل أي خطوة على أنها ناجحة قبل تشغيلها وتوثيق نتيجتها الفعلية.

## المراجع الرسمية

[1]: https://docs.flutter.dev/install/manual "Install Flutter manually"
[2]: https://docs.flutter.dev/platform-integration/android/setup "Set up Android development"
[3]: https://developer.android.com/studio "Android Studio and SDK command-line tools downloads"
[4]: https://docs.flutter.dev/reference/create-new-app "Create a new Flutter app"
[5]: https://docs.flutter.dev/release/breaking-changes/kotlin-version "Required Kotlin version"
[6]: https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json "Official Flutter Linux release manifest"
[7]: https://docs.flutter.dev/install/archive "Flutter SDK archive and architecture metadata"

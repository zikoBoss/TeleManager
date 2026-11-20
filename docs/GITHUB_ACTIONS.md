# GitHub Actions — Flutter وAndroid CI

## النطاق والحالة

يعمل workflow الموجود في [`.github/workflows/android-ci.yml`](../.github/workflows/android-ci.yml) على `ubuntu-24.04` المستضاف من GitHub، وهو runner Linux x64. يهيئ أدوات المرحلة الثانية، ويتحقق من SDK، ثم يشغّل تحليل Dart واختبارات Flutter وبناء APK debug فقط إذا وجد `pubspec.yaml` في المستودع. إذا لم يوجد scaffold Flutter، تظهر ملاحظة صريحة وتظل خطوات التحليل والاختبار والبناء متخطاة؛ نجاح فحص البيئة لا يعني أن TeleManager صار تطبيقًا قابلًا للبناء.

لا يحتوي الفرع على `pubspec.yaml` أو `android/gradlew` أو إعدادات AGP/Kotlin/Gradle خاصة بالمشروع. لذلك لا تُثبت هذه الإعدادات بالتخمين، ولا تُعد الأدوات العامة المثبتة في صورة runner بديلًا عن wrapper وإعدادات المشروع.

## إصدارات البيئة المثبتة

يستخدم workflow إصدار Flutter Stable `3.50.0` الرسمي لمضيف Linux x64، وإصدار Dart `3.14.0`. قبل التنزيل، يقرأ manifest الرسمي ويتأكد من الإصدار والقناة والمعمارية ومسار archive وبصمة SHA-256 التالية. [5]

```text
stable/linux/flutter_linux_3.50.0-stable.tar.xz
6ea2d806fd57269ae783e6788e2a81fc26eaad782f1e0d0ff38623bb765ff9f5
```

يُثبَّت Temurin JDK `21.0.13+9` عبر `actions/setup-java` الرسمي. ويُفحص `flutter doctor -v` ونسخة Java وAndroid SDK أثناء كل تشغيل.

تتضمن صورة GitHub Actions `ubuntu-24.04` Android Command-line Tools. يطلب workflow عبر `sdkmanager` الحزم الثلاث المحددة فقط: `platforms;android-36` revision `2`، و`build-tools;36.1.0`، و`platform-tools` revision `37.0.3`، ويتحقق من وجودها في قائمة الحزم المثبتة وملفات `source.properties`. إصدارات الصورة المستضافة تتغير؛ سجل التشغيل الفعلي هو المرجع لكل run. [1]

## موافقة Android SDK

وافق المستخدم صراحةً على قبول `android-sdk-license` وحده في runner مؤقت، لتثبيت `platforms;android-36` و`build-tools;36.1.0` و`platform-tools`. يضيف workflow hash المقبول `24333f8a63b6825ea9c5514f83c2829b004d1fee` إلى ملف هذا الترخيص فقط. لا ينفذ `sdkmanager --licenses` ولا يستخدم `yes` لقبول بقية التراخيص. إذا تغير الترخيص أو تطلبت الحزم ترخيصًا آخر، يتوقف التثبيت إلى حين مراجعة وموافقة منفصلة.

لا تُطلب أو تُستخدم أسرار GitHub أو Telegram أو مفاتيح توقيع لهذا workflow. صلاحية `GITHUB_TOKEN` محدودة إلى `contents: read`. لا ينشئ workflow إصدارًا ولا يوقع APK للنشر.

## خطوات التحقق

يثبت workflow ثلاث actions رسمية إلى commit SHA كامل: `actions/checkout` v7.0.1 (`3d3c42e5aac5ba805825da76410c181273ba90b1`)، و`actions/setup-java` v6.3.0 (`d1374f8ac74474200d16ef8ecee22c7ae7a51880`)، و`actions/upload-artifact` v7.0.2 (`cf430e030ddbb5b0abf93d22962f4752f3646cd9`). [2] [3] [4]

بعد تحقق الحزم، ينزل Flutter من المستودع الرسمي، ويطابق SHA-256، ثم يشغّل `flutter precache --android` و`flutter doctor -v`. عند وجود مشروع Flutter فعلي، يشغّل `flutter pub get` و`dart format` كتحقق، ثم `flutter analyze` و`flutter test` و`flutter build apk --debug`. يُرفع APK كـartifact لمدة 7 أيام فقط بعد بناء ناجح.

## أول تشغيل فعلي — 2026-11-20

اكتمل التشغيل [44737667246](https://github.com/zikoBoss/TeleManager/actions/runs/44737667246) على commit `cac20ad419c22307fca3f9b0f4ba6be7dce0a16f` بنتيجة `success` خلال نحو 1 دقيقة و40 ثانية. [6] كان المضيف `x86_64` على Ubuntu `24.04.5`، وصورة runner `20261116.133.1`. نجحت خطوات إعداد JDK وقبول الترخيص المحدود والتحقق من حزم SDK وتنزيل Flutter والتحقق من Java/SDK. أظهر السجل `sdkmanager` 12.0 وTemurin `21.0.13+9` وFlutter `3.50.0` وDart `3.14.0`. وأكد أن الحزم المطلوبة هي API 36 revision 2 وBuild Tools 36.1.0 وPlatform Tools 37.0.3.

أكد السجل وجود اسم ترخيص `android-sdk-license` وحده في مجلد licenses. وأظهرت صورة runner أيضًا حزم SDK إضافية موجودة مسبقًا، منها NDK وCMake ومنصات وأدوات بناء أخرى؛ لم يطلب workflow تثبيتها ولم يقبل تراخيصها. ظهرت الحزم الإضافية في سجل القائمة فقط، ولا تُعد جزءًا من نطاق إعداد workflow.

عرض `flutter doctor -v` تحذيرًا بأن تراخيص Android أخرى لم تُقبل؛ هذا متوقع لأن الموافقة اقتصرت على `android-sdk-license`. كما أظهر نقص GTK ومعلومة `eglinfo` لأدوات Linux desktop، وهي غير مطلوبة لتطوير Android. اختتمت خطوة التحقق بنجاح مع إبقاء هذه التحذيرات ظاهرة، ولم تُقبل تراخيص إضافية لحلها.

وجد runner أدوات عامة `Gradle 9.9.1` و`kotlinc-jvm 2.4.21`. هذه إصدارات عامة للصورة وليست إعداد مشروع TeleManager؛ لا يوجد wrapper أو `build.gradle` أو Android Gradle Plugin أو Kotlin Gradle Plugin لتدقيق التوافق معها. كذلك أظهر Flutter doctor اختيار SDK/منصة أحدث موجودة مسبقًا على الصورة، فلا ينبغي الخلط بينها وبين الحزم المحددة التي تحقق منها workflow.

لم يجد التشغيل `pubspec.yaml`؛ لذلك كانت خطوة التحليل والاختبارات وبناء APK وخطوة رفع artifact بحالة `skipped`. التشغيل الناجح يثبت إعداد بيئة الأدوات فقط، ولا يثبت نجاح `flutter analyze` أو `flutter test` أو إنتاج APK. ما زالت المهمة 02 مفتوحة.

## مراجع المصادر

[1]: https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md "Ubuntu 24.04 hosted runner software"
[2]: https://github.com/actions/checkout/releases "actions checkout releases"
[3]: https://github.com/actions/setup-java/releases "actions setup-java releases"
[4]: https://github.com/actions/upload-artifact/releases "actions upload-artifact releases"
[5]: https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json "Flutter Linux stable release manifest"
[6]: https://github.com/zikoBoss/TeleManager/actions/runs/44737667246 "Android CI run 44737667246"

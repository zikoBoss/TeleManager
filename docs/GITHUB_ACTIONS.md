# GitHub Actions — Flutter وAndroid CI

## النطاق والحالة

يعمل workflow الموجود في [`.github/workflows/android-ci.yml`](../.github/workflows/android-ci.yml) على `ubuntu-24.04` المستضاف من GitHub، وهو runner Linux x64. يهيئ أدوات المرحلة الثانية، ويتحقق من SDK، ثم يشغّل تحليل Dart واختبارات Flutter وبناء APK debug فقط إذا وجد `pubspec.yaml` في المستودع. إذا لم يوجد scaffold Flutter، تظهر ملاحظة صريحة وتظل خطوات التحليل والاختبار والبناء متخطاة؛ نجاح فحص البيئة لا يعني أن TeleManager صار تطبيقًا قابلًا للبناء.

وقت إعداد هذا الملف، لا يحتوي الفرع على `pubspec.yaml` أو `android/gradlew` أو إعدادات AGP/Kotlin/Gradle خاصة بالمشروع. لذلك لا تُثبت هذه الإعدادات بالتخمين، ولا تُعد الأدوات العامة المثبتة في صورة runner بديلًا عن wrapper وإعدادات المشروع.

## إصدارات البيئة المثبتة

يستخدم workflow إصدار Flutter Stable `3.50.0` الرسمي لمضيف Linux x64، وإصدار Dart `3.14.0`. قبل التنزيل، يقرأ manifest الرسمي ويتأكد من الإصدار والقناة والمعمارية ومسار archive وبصمة SHA-256 التالية:

```text
stable/linux/flutter_linux_3.50.0-stable.tar.xz
6ea2d806fd57269ae783e6788e2a81fc26eaad782f1e0d0ff38623bb765ff9f5
```

يُثبَّت Temurin JDK `21.0.13+9` عبر `actions/setup-java` الرسمي. ويُفحص `flutter doctor -v` ونسخة Java وAndroid SDK أثناء كل تشغيل.

تتضمن صورة GitHub Actions `ubuntu-24.04` التي جرى فحصها Android Command-line Tools `12.0`، و`platforms;android-36` revision `2`، و`build-tools;36.1.0`، و`platform-tools` revision `37.0.1`، مع `ANDROID_HOME=/usr/local/lib/android/sdk`. ينفذ `sdkmanager --install` للحزم الثلاث المحددة ويتحقق من ظهورها في قائمة الحزم المثبتة. نسخة الصورة المستضافة تتغير بمرور الوقت؛ تُسجل النسخة الفعلية في سجل كل run بدل اعتبار هذا الوصف ضمانًا ثابتًا لمحتواها. [1]

## موافقة Android SDK

وافق المستخدم صراحةً في 2026-11-19 على قبول `android-sdk-license` وحده في runner مؤقت، لتثبيت `platforms;android-36` و`build-tools;36.1.0` و`platform-tools`. يُضاف إلى ملف الترخيص hash المقبول `24333f8a63b6825ea9c5514f83c2829b004d1fee` فقط. لا ينفذ workflow الأمر `sdkmanager --licenses` ولا يستخدم `yes` لقبول بقية التراخيص. إذا تغير الترخيص أو تطلبت الحزم ترخيصًا آخر، يتوقف التثبيت إلى حين مراجعة وموافقة منفصلة.

لا تُطلب أو تُستخدم أسرار GitHub أو Telegram أو مفاتيح توقيع لهذا workflow. صلاحية `GITHUB_TOKEN` محدودة إلى `contents: read`. لا ينشئ workflow إصدارًا ولا يوقع APK للنشر.

## خطوات التحقق

يثبت workflow ثلاث actions رسمية إلى commit SHA كامل: `actions/checkout` v7.0.1 (`3d3c42e5aac5ba805825da76410c181273ba90b1`)، و`actions/setup-java` v6.3.0 (`d1374f8ac74474200d16ef8ecee22c7ae7a51880`)، و`actions/upload-artifact` v7.0.2 (`cf430e030ddbb5b0abf93d22962f4752f3646cd9`).[2] [3] [4]

بعد تحقق الحزم، ينزل Flutter من مستودع Google الرسمي، ويطابق SHA-256، ثم يشغل `flutter precache --android` و`flutter doctor -v`. عند وجود مشروع Flutter فعلي، يشغل `flutter pub get`، و`dart format` كتحقق، ثم `flutter analyze` و`flutter test` و`flutter build apk --debug`. يُرفع APK كـartifact لمدة 7 أيام فقط بعد بناء ناجح. هذه الخطوات ليست نجاحًا مثبتًا قبل ظهور run فعلي بالنتائج.

## مراجع المصادر

[1]: https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md "Ubuntu 24.04 hosted runner software"
[2]: https://github.com/actions/checkout/releases "actions checkout releases"
[3]: https://github.com/actions/setup-java/releases "actions setup-java releases"
[4]: https://github.com/actions/upload-artifact/releases "actions upload-artifact releases"
[5]: https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json "Flutter Linux stable release manifest"
[6]: https://docs.github.com/en/actions/reference/security/secure-use "GitHub Actions secure use reference"

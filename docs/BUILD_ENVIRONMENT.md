# بيئة البناء والتحقق — المهمة 02

## Sandbox المحلية

المضيف الحالي Ubuntu 24.04 ARM64. Android SDK Command-line Tools و`platforms;android-36` revision 2 و`build-tools;36.1.0` و`platform-tools` revision 37.0.3 مثبتة محليًا، وقُبل `android-sdk-license` في هذه الـSandbox بعد موافقة المستخدم السابقة. لا تشغّل `adb` أو `aapt` أو `aapt2` هنا؛ هذه الملفات التنفيذية x86-64 ولا تعمل على ARM64. Flutter وDart لا يزالان غير مثبتين على `PATH`، ولم يُنشأ scaffold محليًا.

## Runner خارجي

يستخدم GitHub Actions تسمية `ubuntu-24.04`، ويؤكد workflow معمارية المضيف باستخدام `uname -m`. في التشغيل الفعلي بتاريخ 2026-11-20 كانت البيئة `x86_64` على Ubuntu `24.04.5` وصورة runner `20261116.133.1`. أثبت السجل أن Command-line Tools هي `12.0`، وأن Temurin JDK هو `21.0.13+9`، وأن الحزم المطلوبة موجودة بإصدارات `platforms;android-36` revision `2` و`build-tools;36.1.0` و`platform-tools` revision `37.0.3`. [3]

نجح workflow في تنزيل Flutter Stable `3.50.0` وDart `3.14.0` من manifest الرسمي، ومطابقة SHA-256، وإظهار ملف Dart كتنفيذي Linux x86-64. كما نجحت خطوة `flutter doctor -v` على مستوى Action، لكنها سجلت تحذيرات ظاهرة: تراخيص Android الأخرى غير مقبولة وفق نطاق الموافقة، ومكتبات GTK وبيانات `eglinfo` الخاصة بتطوير Linux desktop غير موجودة. لا تؤثر مكونات Linux desktop في نطاق Android، ولا ينبغي قبول تراخيص إضافية لإزالة التحذير.

أظهرت قائمة SDK في runner حزمًا إضافية موجودة في صورة GitHub المستضافة، منها NDK وCMake وإصدارات منصات وأدوات بناء أخرى. أمر `sdkmanager --install` في workflow يطلب الحزم الثلاث المسموح بها فقط؛ لم يُطلب تثبيت NDK أو CMake أو Emulator، ولم يقبل workflow تراخيص أخرى. لا يعني ظهور هذه المكونات المسبقة أن المشروع يحتاجها.

## Kotlin وGradle

لا توجد في المستودع ملفات مشروع Android أو Gradle wrapper أو `settings.gradle` أو `build.gradle` أو ملفات Kotlin. أظهر التشغيل وجود `Gradle 9.9.1` و`kotlinc-jvm 2.4.21` على runner العام. هذه أدوات عامة للصورة وليست نسخًا معتمدة لـTeleManager، ولا تثبت توافق تطبيق أو نجاح بناء. لم يوجد Gradle wrapper أو `Android Gradle Plugin` أو `Kotlin Gradle Plugin` خاص بالمشروع لتدقيقه. تُحدد الإصدارات بعد إنشاء scaffold Flutter رسمي على هذا الفرع ومراجعة القالب الناتج ومصفوفة التوافق.

## ما تثبته النتيجة وما لا تثبته

اكتمل run رقم `44737667246` بنتيجة `success` كفحص إعداد البيئة وتثبيت الأدوات المصرح بها. لم يوجد `pubspec.yaml`؛ لذلك لم تُنفذ `flutter analyze` أو `flutter test` أو بناء APK، ولم يُرفع artifact. تبقى المهمة 02 مفتوحة إلى أن يوجد مشروع فعلي وينجح التحليل والاختبار والبناء على بيئة متوافقة.

راجع [ANDROID_SETUP.md](ANDROID_SETUP.md) للحالة المحلية وسلوك سكربت الإعداد، و[GITHUB_ACTIONS.md](GITHUB_ACTIONS.md) لتفاصيل workflow والسجل الفعلي.

## المراجع

[1]: https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md "Ubuntu 24.04 hosted runner software"
[2]: https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json "Flutter Linux stable release manifest"
[3]: https://github.com/zikoBoss/TeleManager/actions/runs/44737667246 "Android CI run 44737667246"

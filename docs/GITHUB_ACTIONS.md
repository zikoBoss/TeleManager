# GitHub Actions — Flutter وAndroid CI

## النطاق والسلوك

يعمل [`.github/workflows/android-ci.yml`](../.github/workflows/android-ci.yml) على GitHub-hosted `ubuntu-24.04` runner. يهيئ Java وAndroid SDK وFlutter Stable، ويتحقق من الأدوات، ثم يشغّل `flutter pub get` و`dart format` و`flutter analyze` و`flutter test` وبناء APK debug عند وجود `pubspec.yaml`.

يقبل `workflow_dispatch` خيارًا اختياريًا اسمه `generate_scaffold`. إذا اختير، يولّد workflow مشروع Android-only مؤقتًا على runner بعد التحقق من البيئة، ثم يشغّل عليه الفحوص ويرفع scaffold وAPK كـartifacts لمدة 7 أيام. لا يضيف الملفات إلى Git أو يدفعها تلقائيًا. صلاحيات workflow تبقى `contents: read` فقط.

## إصدارات البيئة

يقرأ workflow manifest Flutter الرسمي ويثبت Stable `3.50.0` لمضيف Linux x64 مع Dart `3.14.0`. يتحقق من SHA-256 قبل فك archive:

```text
stable/linux/flutter_linux_3.50.0-stable.tar.xz
6ea2d806fd57269ae783e6788e2a81fc26eaad782f1e0d0ff38623bb765ff9f5
```

يستخدم Temurin JDK `21.0.13+9`. يطلب `sdkmanager` الحزم التالية فقط في خطوة الإعداد ويتحقق من إصداراتها: `platforms;android-36` revision 2، `build-tools;36.1.0`، و`platform-tools` revision `37.0.3`.

## موافقة Android SDK

وافق المستخدم على قبول `android-sdk-license` وحده. يضيف workflow hash `24333f8a63b6825ea9c5514f83c2829b004d1fee` إلى ملف الترخيص هذا فقط، ولا يشغّل `sdkmanager --licenses` أو `yes` لقبول تراخيص إضافية. أظهر سجل التشغيل النهائي اسم هذا الترخيص وحده في خطوة إعداد SDK؛ بقي `flutter doctor -v` يحذر من تراخيص أخرى غير مقبولة.

ملاحظة بناء: في خطوة `flutter build apk --debug` نزّل Gradle تلقائيًا NDK Side by side `28.2` (`r28c`) رغم أن workflow لا يطلبه في خطوة إعداد SDK وملف المشروع لا يثبت `ndkVersion`. لا يغيّر هذا نتيجة أن workflow لم يقبل ترخيصًا إضافيًا، لكنه اعتماد عابر ظهر في سجل البناء ويجب إعادة تقييمه إذا أُضيفت شيفرة Android native.

لا تُستخدم أسرار Telegram أو مفاتيح توقيع. لا ينشئ workflow إصدار نشر ولا يوقّع APK release.

## الإعدادات التي ولّدها scaffold

سجّل runner من القالب Flutter 3.50.0: Android Gradle Plugin `9.3.1`، Kotlin Gradle Plugin `2.4.20`، وGradle wrapper `9.5.0`. Gradle نفسه أبلغ عن Kotlin مضمّن `2.3.20`. القيم ناتجة عن القالب الحالي وليست قرارات معمارية سابقة. معرّف `applicationId` الحالي `com.example.telemanager` قيمة مؤقتة من القالب.

## نتائج التشغيل

- [44740810758](https://github.com/zikoBoss/TeleManager/actions/runs/44740810758): تحقق toolchain بعد إضافة خيار dispatch؛ نجح، وتخطت فحوص المشروع لعدم وجود `pubspec.yaml` آنذاك.
- [44742740367](https://github.com/zikoBoss/TeleManager/actions/runs/44742740367): تحقق workflow المعدّل؛ نجح، وكانت فحوص المشروع متخطاة عمدًا قبل إضافة scaffold.
- [44743248440](https://github.com/zikoBoss/TeleManager/actions/runs/44743248440): ولّد scaffold على x64؛ نجح `flutter analyze` بلا مشاكل، ونجح اختبار widget واحد، وبُني APK debug. أظهر السجل تنزيل NDK تلقائيًا، وتم تنقيح artifact من إعدادات runner المحلية وملفات IDE.
- [44744990391](https://github.com/zikoBoss/TeleManager/actions/runs/44744990391): تحقق من الملفات الموجودة فعلًا في commit `d8d26fb` على `task02-github-ci`. نجح doctor مع تحذيرات التراخيص وLinux desktop، ثم التنسيق والتحليل والاختبار وبناء APK ورفع artifact. لم يبدأ `Generate scaffold` في هذا التشغيل لأن المشروع كان موجودًا في المصدر.

في التشغيل النهائي: `flutter analyze` أعاد `No issues found!`؛ `flutter test` أعاد `1 test passed`؛ و`flutter build apk --debug` أعاد `Built build/app/outputs/flutter-apk/app-debug.apk`. اجتاز APK فحص ZIP بعد تنزيله. بصمة الملف وتفاصيل البيئة في [`BUILD_ENVIRONMENT.md`](BUILD_ENVIRONMENT.md) و[`TASK02_STATUS_2026-11-19.md`](TASK02_STATUS_2026-11-19.md).

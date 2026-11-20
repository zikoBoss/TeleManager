# بيئة البناء والتحقق — المهمة 02

## Sandbox المحلية

المضيف الحالي Ubuntu 24.04 ARM64. Android SDK Command-line Tools و`platforms;android-36` revision 2 و`build-tools;36.1.0` و`platform-tools` revision 37.0.3 مثبتة محليًا، وقُبل `android-sdk-license` في هذه الـSandbox بعد موافقة المستخدم السابقة. لا تشغّل `adb` أو`aapt` أو`aapt2` هنا؛ هذه الملفات التنفيذية x86-64 ولا تعمل على ARM64. Flutter وDart لا يزالان غير مثبتين على `PATH`، ولم يُنشأ scaffold محليًا.

## Runner خارجي

يستخدم GitHub Actions تسمية `ubuntu-24.04`، ويؤكد workflow معمارية المضيف باستخدام `uname -m`. صورة Ubuntu 24.04 الرسمية التي فُحصت بتاريخ 2026-11-19 كانت `20261111.370.1`، وتضم Java 21.0.13+9 عبر `JAVA_HOME_21_X64`، وAndroid Command-line Tools 12.0، وAndroid API 36 revision 2، وBuild Tools 36.1.0، وPlatform Tools 37.0.1. لأن صور GitHub-hosted runners تتغير، فإن المرجع الحاسم هو سجل التشغيل الفعلي، لا رقم الصورة المنشور اليوم. [1]

يُثبت workflow Flutter Stable 3.50.0 Linux x64 وDart 3.14.0 من manifest الرسمي مع مطابقة SHA-256. ويثبت Temurin `21.0.13+9`. لا يُنزّل NDK أو CMake أو Emulator ولا يستخدمها workflow.

## Kotlin وGradle

لا توجد في المستودع ملفات مشروع Android أو Gradle wrapper أو `settings.gradle` أو `build.gradle` أو ملفات Kotlin. قد تحتوي صورة runner على أدوات Gradle أو Kotlin عامة، لكن ذلك لا يحدد إصدارات `Gradle`, `Android Gradle Plugin`, أو `Kotlin Gradle Plugin` الخاصة بـTeleManager، ولا يُعد اختبارًا لبناء Android. تُحدد الإصدارات بعد إنشاء scaffold Flutter رسمي على هذا الفرع ومراجعة القالب الناتج ومصفوفة التوافق. حتى ذلك الحين، لا يُسجل تحليل Flutter أو اختبارات أو APK كإنجاز.

راجع [ANDROID_SETUP.md](ANDROID_SETUP.md) للحالة المحلية وسلوك سكربت الإعداد، و[GITHUB_ACTIONS.md](GITHUB_ACTIONS.md) لطريقة تهيئة runner وحدود workflow.

## المراجع

[1]: https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md "Ubuntu 24.04 hosted runner software"
[2]: https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json "Flutter Linux stable release manifest"

# TeleManager

مدير ملفات افتراضي سحابي لـ Android، يبدأ بـ Telegram كمزود تخزين عبر TDLib، مع إبقاء محرك الملفات مستقلاً عن المزود. المرجع الكامل: [`docs/MASTER_BLUEPRINT.md`](docs/MASTER_BLUEPRINT.md).

## حالة المشروع

**المهمة 02 ما زالت مفتوحة، ولم يبدأ العمل في المهمة 03.** المستودع العام أُنشئ له commit تأسيسي `a70a106` على `main`، والعمل الحالي محصور في `task02-github-ci`؛ لن تُرفع تعديلات المهمة إلى `main`.

المضيف الحالي Ubuntu 24.04 ARM64. ثُبتت Android SDK Command-line Tools (sdkmanager 22.0)، وكذلك `platforms;android-36` revision 2، و`build-tools;36.1.0`، و`platform-tools` 37.0.3. تحققنا من metadata، واجتاز `android.jar` فحص ZIP. لكن `adb` و`aapt` و`aapt2` ملفات Linux x86-64، فلم تُشغّل على ARM64. قُبل ترخيص `android-sdk-license` وحده بإذن المستخدم، وما زالت سبعة تراخيص أخرى غير مقبولة.

Flutter وDart غير متاحين محليًا على PATH. أظهر manifest الرسمي أن Flutter Stable 3.50.0 المتاح لـLinux هو x64 فقط؛ Dart المضمّن لا يعمل على مضيف ARM64. أُضيف workflow رسمي على Ubuntu x64 للتحقق من البيئة، لكن تحليل Flutter واختباراته وبناء APK لا تُنفذ إلا عند وجود `pubspec.yaml`. لا يوجد scaffold Flutter حتى الآن.

أُنشئ workflow في [إعداد GitHub Actions](docs/GITHUB_ACTIONS.md) مع توثيق [بيئة البناء](docs/BUILD_ENVIRONMENT.md). نتائج تشغيله الفعلية وحالة التحليل والبناء محفوظة في [تقرير المهمة 02](docs/TASK02_STATUS_2026-11-19.md). لا تُعامل أي ميزة على أنها مكتملة قبل اختبارها فعليًا.

## التوجيه التقني المعتمد

- Android أولاً.
- Flutter/Dart للتطبيق والمنطق العام، Kotlin/NDK فقط لحدود Android/TDLib عند الحاجة.
- SQLite عبر Drift، Riverpod، GoRouter، Material 3 (هذه اختيارات التصميم المقترحة بالمخطط، ويجب التحقق من الإصدارات قبل تثبيتها).
- فصل TM-Core وTM-Cloud وTM-Transfer وTM-Cache وTM-Backup وTM-Sync.
- لا يستبدل هذا المشروع بتقنية Expo/React Native؛ ذلك لا يطابق المرجع المعتمد.

## البدء

1. اقرأ `PROJECT_RULES.md` ثم `docs/ARCHITECTURE.md` و`docs/INTERFACES.md` والوثيقة المتعلقة بالمهمة.
2. اقرأ المخطط الكامل في `docs/MASTER_BLUEPRINT.md`.
3. وفّر مضيف Linux x86-64 موثوقًا، ثم أنشئ scaffold Flutter رسميًا قابلًا للبناء وتحقق منه. لا تعتبر ملفات إعداد SDK الحالية إثباتًا لجهوزية Android build على ARM64.
4. قيّم TDLib/artifacts وبناء Android في مشروع تجريبي مستقل قبل تنفيذ المصادقة أو الرفع/التنزيل.
5. حافظ على ترتيب المراحل وحالة الإنجاز في `TODO.md`. لا تدّع إكمال ميزة بلا اختبار ناجح.

## ملفات التوثيق

- `docs/ANDROID_SETUP.md`: الحالة الفعلية لأدوات Android وFlutter وسلوك سكربت الإعداد.
- `docs/TASK02_STATUS_2026-11-19.md`: تقرير المهمة 02 ودراسة GitHub Actions.
- `docs/GITHUB_ACTIONS.md`: إعداد CI وإصدارات الأدوات ونطاق قبول Android SDK license.
- `docs/BUILD_ENVIRONMENT.md`: الفرق بين أدوات Sandbox المحلية وبيئة GitHub runner.
- `docs/FLUTTER_LINUX_ARM64_SUPPORT.md`: manifests الرسمية ونتيجة دعم Flutter Linux ARM64.
- `docs/ANDROID_SDK_LICENSE_REVIEW.md`: نص الترخيص الذي قُبل وملخصه، مع حالة التراخيص الأخرى.
- `docs/MASTER_BLUEPRINT.md`: المواصفات الأصلية.
- `docs/ARCHITECTURE.md`: حدود المحركات والبوابات والقرارات المؤجلة.
- `docs/INTERFACES.md`: حالة العقود العابرة للوحدات؛ حدثه مع كل عقد فعلي.
- `docs/DATABASE.md`: مخطط قاعدة البيانات المقترح، غير منفذ بعد.
- `docs/TELEGRAM_INTEGRATION.md`: بوابة تقييم TDLib وحالات Telegram.
- `docs/SECURITY.md`: مبادئ الأمن والخصوصية.
- `docs/ROADMAP.md`: ترتيب المراحل ومعايير الانتقال.
- `TODO.md`: حالة المتطلبات ومعاييرها.

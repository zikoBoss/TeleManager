# TeleManager

مدير ملفات افتراضي سحابي لـ Android، يبدأ بـ Telegram كمزود تخزين عبر TDLib، مع إبقاء محرك الملفات مستقلاً عن المزود. المرجع الكامل: [`docs/MASTER_BLUEPRINT.md`](docs/MASTER_BLUEPRINT.md).

## حالة المشروع

**المهمة 02 ما زالت مفتوحة، ولم يبدأ العمل في المهمة 03.** أُنشئ commit تأسيسي `a70a106` على `main`. العمل اللاحق مرفوع على الفرع `task02-github-ci` عند commit `cac20ad`، ولم تُدمج أي تغييرات إلى `main`.

اكتمل أول تشغيل فعلي لـGitHub Actions بنجاح كفحص لبيئة الأدوات على Ubuntu 24.04 x86-64. ثُبتت وتحققت حزم Android المستهدفة، وجرى تنزيل Flutter Stable 3.50.0 والتحقق من بصمته، كما نجح فحص Java وSDK. أظهر `flutter doctor -v` تحذيرات عن تراخيص Android الأخرى غير المقبولة وعن أدوات Linux desktop غير اللازمة لـAndroid؛ ولم تُخفَ هذه التحذيرات. [تفاصيل التشغيل](https://github.com/zikoBoss/TeleManager/actions/runs/44737667246)

المضيف المحلي Ubuntu 24.04 ARM64. Android SDK Command-line Tools مثبتة (`sdkmanager` 22.0)، وكذلك `platforms;android-36` revision 2، و`build-tools;36.1.0`، و`platform-tools` 37.0.3. تحققنا من metadata واجتاز `android.jar` فحص ZIP. لكن `adb` و`aapt` و`aapt2` ملفات Linux x86-64، فلم تُشغّل على ARM64. قُبل ترخيص `android-sdk-license` وحده محليًا، وما زالت تراخيص SDK أخرى غير مقبولة.

Flutter وDart غير متاحين محليًا على PATH. لا يوجد scaffold Flutter أو `pubspec.yaml` في المستودع. لذلك لم تُنفذ `flutter analyze` أو `flutter test` ولم يُبن APK؛ تخطت GitHub Actions هذه الخطوات وأكدت السبب في السجل. نجاح فحص البيئة لا يعني أن TeleManager صار تطبيقًا قابلًا للبناء.

## التوجيه التقني المعتمد

- Android أولاً.
- Flutter/Dart للتطبيق والمنطق العام، Kotlin/NDK فقط لحدود Android/TDLib عند الحاجة.
- SQLite عبر Drift، Riverpod، GoRouter، Material 3 (هذه اختيارات التصميم المقترحة بالمخطط، ويجب التحقق من الإصدارات قبل تثبيتها).
- فصل TM-Core وTM-Cloud وTM-Transfer وTM-Cache وTM-Backup وTM-Sync.
- لا يستبدل هذا المشروع بتقنية Expo/React Native؛ ذلك لا يطابق المرجع المعتمد.

## البدء

1. اقرأ `PROJECT_RULES.md` ثم `docs/ARCHITECTURE.md` و`docs/INTERFACES.md` والوثيقة المتعلقة بالمهمة.
2. اقرأ المخطط الكامل في `docs/MASTER_BLUEPRINT.md`.
3. استمر في المهمة 02 بإنشاء scaffold Flutter رسمي قابل للبناء والتحقق منه على مضيف Linux x86-64 موثوق. لا تعتبر ملف CI أو تثبيت حزم SDK دليلًا على اكتمال التحليل أو بناء Android.
4. قيّم TDLib/artifacts وبناء Android في مشروع تجريبي مستقل قبل تنفيذ المصادقة أو الرفع/التنزيل.
5. حافظ على ترتيب المراحل وحالة الإنجاز في `TODO.md`. لا تدّع إكمال ميزة بلا اختبار ناجح.

## ملفات التوثيق

- `docs/ANDROID_SETUP.md`: الحالة الفعلية لأدوات Android وFlutter وسلوك سكربت الإعداد.
- `docs/TASK02_STATUS_2026-11-19.md`: تقرير المهمة 02 ونتائج تشغيل GitHub Actions.
- `docs/GITHUB_ACTIONS.md`: إعداد CI وإصدارات الأدوات ونطاق قبول Android SDK license ونتيجة التشغيل.
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

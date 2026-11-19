# TeleManager

مدير ملفات افتراضي سحابي لـ Android، يبدأ بـ Telegram كمزود تخزين عبر TDLib، مع إبقاء محرك الملفات مستقلاً عن المزود. المرجع الكامل: [`docs/MASTER_BLUEPRINT.md`](docs/MASTER_BLUEPRINT.md).

## حالة المشروع

**المهمة 02 مفتوحة ومتوقفة بانتظار بيئة بناء واختبار موثوقة؛ لم يبدأ العمل في المهمة 03.** المستودع المحلي مهيأ، لكن لا يوجد Git commit أو remote حتى الآن. لم يُنشأ مستودع GitHub أو workflow.

المضيف الحالي Ubuntu 24.04 ARM64. ثُبتت Android SDK Command-line Tools (sdkmanager 22.0)، وكذلك `platforms;android-36` revision 2، و`build-tools;36.1.0`، و`platform-tools` 37.0.3. تحققنا من metadata، واجتاز `android.jar` فحص ZIP. لكن `adb` و`aapt` و`aapt2` ملفات Linux x86-64، فلم تُشغّل على ARM64. قُبل ترخيص `android-sdk-license` وحده بإذن المستخدم، وما زالت سبعة تراخيص أخرى غير مقبولة.

Flutter وDart غير متاحين حاليًا على PATH. أظهر التحقق السابق من manifest الرسمي لـ Flutter Stable 3.50.0 أن سجل Linux المتاح x64 فقط؛ وتوثق نتيجة الفحص السابقة أن Dart المضمّن كان x86-64 ولم يعمل على مضيف ARM64. لم يُنشأ scaffold Flutter، ولم تُشغّل `flutter analyze` أو `flutter test` أو Kotlin/Gradle، ولم يُبن APK.

دُرست GitHub Actions كخيار Linux x64 خارجي، لكن لم يُنشأ مستودع بعيد أو workflow ولم يُشغّل أي بناء. راجع [تقرير حالة المهمة 02](docs/TASK02_STATUS_2026-11-19.md) و[إعداد Flutter وAndroid](docs/ANDROID_SETUP.md) و[تحقق Flutter Linux ARM64](docs/FLUTTER_LINUX_ARM64_SUPPORT.md). لا تُعامل أي ميزة على أنها مكتملة قبل اختبارها فعليًا.

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

# TeleManager

مدير ملفات افتراضي سحابي لـ Android، يبدأ بـ Telegram كمزود تخزين عبر TDLib، مع إبقاء محرك الملفات مستقلاً عن المزود. المرجع الكامل: [`docs/MASTER_BLUEPRINT.md`](docs/MASTER_BLUEPRINT.md).

## حالة المشروع

اكتملت المهمة 02 الخاصة بإعداد Flutter/Android وإنشاء scaffold قابل للبناء والتحقق. أُضيف scaffold Android-only مولّد بواسطة Flutter Stable الرسمي 3.50.0 على GitHub runner بمعمارية x64. يحتوي المشروع الآن على نقطة دخول Flutter افتراضية و`MainActivity.kt` فقط؛ لم تُنفذ محركات TeleManager أو تكامل TDLib أو قاعدة البيانات أو ميزات Telegram/VFS. لم تبدأ المرحلة 03.

نجح تشغيل CI على commit `d8d26fbe05fd9ba5b057aea6d65fff1540178de6` في [run 44744990391](https://github.com/zikoBoss/TeleManager/actions/runs/44744990391): `flutter doctor -v` أكد Flutter وJava وAndroid SDK مع تحذيرات موضحة في الوثائق؛ `flutter analyze` انتهى بـ`No issues found`; `flutter test` نجح باختبار widget واحد؛ وبُني APK debug. ملف APK محفوظ محليًا في [`build/app/outputs/flutter-apk/app-debug.apk`](build/app/outputs/flutter-apk/app-debug.apk) وبصمة SHA-256 موثقة في تقرير المهمة 02.

أثناء بناء APK، نزّل Gradle تلقائيًا NDK Side by side 28.2 / `r28c` رغم عدم وجود pin لـNDK في إعداد المشروع. لم يشغّل workflow `sdkmanager --licenses`، وظل `android-sdk-license` هو معرف الترخيص الوحيد الذي سجله إعداد SDK؛ بقي تحذير التراخيص الأخرى ظاهرًا. لا تعتبر نسخة NDK قرارًا معماريًا أو اعتمادًا مثبتًا في المستودع.

العمل باقٍ على الفرع `task02-github-ci` فقط؛ بقي `main` عند commit التأسيس `a70a106` ولم يحصل دمج. Flutter وDart غير مثبتين على Sandbox المحلية ARM64، ولم تُشغّل أدوات x64 عليها.

## إعداد scaffold الحالي

استخدم القالب الرسمي Flutter `3.50.0` / Dart `3.14.0`. قيم البناء التي ولّدها القالب الحالي هي Android Gradle Plugin `9.3.1`، وKotlin Gradle Plugin `2.4.20`، وGradle wrapper `9.5.0`. هذه إعدادات scaffold فعلية أثبتها runner وليست قرارات أُقرت قبل التوليد؛ راجعها قبل توسيع المشروع. معرّف الحزمة `com.example.telemanager` مؤقت من قالب Flutter ويحتاج قرارًا لاحقًا قبل النشر. لم تُضف اعتمادات Drift أو Riverpod أو GoRouter أو TDLib.

## التوجيه التقني المعتمد

- Android أولاً، وFlutter/Dart لطبقة TM-UI.
- Kotlin/NDK لا يُستخدم كطبقة ميزات الآن؛ حدود الربط الأصلية مع TDLib وABI ما زالت مؤجلة.
- TM-Core مستقل عن Android وTDLib ومزودات التخزين.
- لا تخلط منطق الواجهة مع التخزين أو أعمال Telegram.
- لا تبدأ المرحلة التالية قبل موافقة المستخدم واتباع بوابات `docs/ROADMAP.md`.

## البدء

1. اقرأ `PROJECT_RULES.md` ثم `docs/ARCHITECTURE.md` و`docs/INTERFACES.md` والوثيقة المتعلقة بالمهمة.
2. اقرأ المخطط الكامل في `docs/MASTER_BLUEPRINT.md`.
3. استخدم إصدار Flutter/Android الموثق في ملفات المشروع عند إجراء تغييرات ضمن المهمة 02.
4. لا تنتقل إلى TDLib أو المصادقة أو عمليات الملفات قبل اعتماد المستخدم ونجاح بوابة تقييم TDLib.
5. حافظ على ترتيب المراحل وحالة الإنجاز في `TODO.md`. لا تدّع إكمال ميزة بلا اختبار ناجح.

## ملفات التوثيق

- `docs/ANDROID_SETUP.md`: حالة أدوات Android/Flutter على ARM64 وx64.
- `docs/TASK02_STATUS_2026-11-19.md`: تقرير المهمة 02 ونتائج CI الموثقة.
- `docs/GITHUB_ACTIONS.md`: إعداد workflow وإصدارات الأدوات وسجل التشغيل.
- `docs/BUILD_ENVIRONMENT.md`: الفرق بين Sandbox ARM64 وrunner x64.
- `docs/FLUTTER_LINUX_ARM64_SUPPORT.md`: manifests الرسمية ونتيجة دعم Flutter Linux ARM64.
- `docs/ANDROID_SDK_LICENSE_REVIEW.md`: نص الترخيص الذي قُبل وحالة التراخيص الأخرى.
- `docs/MASTER_BLUEPRINT.md`: المواصفات الأصلية.
- `docs/ARCHITECTURE.md`: حدود المحركات والبوابات والقرارات المؤجلة.
- `docs/INTERFACES.md`: حالة العقود العابرة للوحدات؛ حدّثه مع كل عقد فعلي.
- `docs/DATABASE.md`: مخطط قاعدة البيانات المقترح، غير منفذ بعد.
- `docs/TELEGRAM_INTEGRATION.md`: بوابة تقييم TDLib وحالات Telegram.
- `docs/SECURITY.md`: مبادئ الأمن والخصوصية.
- `docs/ROADMAP.md`: ترتيب المراحل ومعايير الانتقال.
- `TODO.md`: حالة المتطلبات ومعاييرها.

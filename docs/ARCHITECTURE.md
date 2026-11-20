# TeleManager — المعمارية

## الحالة

هذه وثيقة تأسيسية مشتقة من `MASTER_BLUEPRINT.md`. أضيف scaffold Flutter وAndroid/Kotlin أساسي مولّد من Flutter 3.50.0، لكنه لا يطبق محركات TeleManager. لا يوجد تكامل TDLib أو قاعدة بيانات أو منطق VFS أو مزود تخزين منفذ. لا تُعامل الرسوم أو العقود المقترحة على أنها ميزات منفذة.

## الهدف

مدير ملفات افتراضي سحابي، لا واجهة Telegram. الهاتف يحتفظ بالبيانات الوصفية وCache محدود، ويظل منطق إدارة الملفات مستقلًا عن مزود التخزين. Telegram/TDLib هو المزود الأول فقط.

## حدود الوحدات

- **TM-Core:** نموذج الملفات والمجلدات، VFS، التصنيف والبحث والوسوم والمفضلة. لا يعتمد على Android أو TDLib أو أي مزود.
- **TM-Cloud:** عقود التخزين الموحدة، قدرات الحساب، نتائج المزود والأخطاء. يعتمد عليه منسق العمليات، وينفذه TelegramProvider.
- **TelegramProvider:** المصادقة والرفع والتنزيل والحذف واسترجاع بيانات التخزين عبر TDLib. لا يصل مباشرة إلى Widgets أو TM-Core.
- **TM-Transfer:** طابور دائم للرفع والتنزيل، التقدم والإلغاء والاستعادة والمحاولات وحدود التزامن.
- **TM-Cache:** Cache وthumbnail وOffline وسياسات المساحة. لا يحذف أي أصل سحابي.
- **TM-Backup:** snapshot متسق ومشفّر ومتحقق منه، ثم استعادة وترحيل.
- **TM-Sync:** سجل تغييرات متعدد الأجهزة، idempotency والتعارضات وtombstones.
- **TM-UI:** Flutter presentation فقط. scaffold الحالي هو شاشة العداد الافتراضية، وليس واجهة TeleManager.
- **Android bridge:** Kotlin/NDK boundary محتمل لـTDLib؛ لم تُنشأ واجهة الربط بعد، والاختيار مؤجل حتى تقييم المكتبة والـABI والتراخيص والبناء.
- **Data:** SQLite عبر Drift، مخططات ومهاجرات ومستودعات؛ DB محلية لبيانات TeleManager وليست قاعدة TDLib. لم تنفذ بعد.

## تدفق مقترح

`TM-UI → Application/Use Cases → TM-Core + TM-Transfer → TM-Cloud → TelegramProvider → TDLib`

يتعامل TM-Core مع معرفات TeleManager الداخلية UUID. المراجع الخاصة بالمزود محفوظة منفصلة في `storage_objects` ويمكن تحديثها؛ لا يكون `message_id` مفتاحًا داخليًا.

## بنية المجلدات

المجلدات الحالية تشمل `lib/core`, `lib/data`, `lib/engines`, `lib/providers`, `lib/features`, `lib/shared`, `android/native/tdlib_bridge`, `assets`, `test`, و`docs`. أضيفت ملفات Flutter الرسمية الدنيا: `lib/main.dart`، واختبار قالب في `test/widget_test.dart`، و`MainActivity.kt` في `android/app`. تبقى مجلدات المحركات و`android/native/tdlib_bridge` هياكل فارغة؛ لا تُنقل إليها ميزات قبل البوابات المعمارية.

## بوابات التنفيذ

1. تأسيس المستودع والوثائق والقواعد.
2. تجهيز Flutter/Android والتحقق من scaffold والبناء.
3. لم تبدأ بعد: بناء تجربة مستقلة لتقييم TDLib، بما يشمل المصدر والترخيص والإصدارات وABI والتوافق.
4. لا يبدأ تكامل المصادقة والرفع والتنزيل قبل نجاح/توثيق بوابة TDLib.
5. بعد إثبات المزود: VFS/قاعدة البيانات والعمليات والطابور وفق ترتيب roadmap، ثم الواجهة النهائية والمعاينة والمزامنة والنسخ.

## قرارات مؤجلة وقيود scaffold

- Flutter `3.50.0` وDart `3.14.0` مستخدمان في workflow والقالب الحالي. الإعدادات التي ولّدها القالب هي AGP `9.3.1` وKotlin Gradle Plugin `2.4.20` وGradle wrapper `9.5.0`؛ هذه قيم build فعلية وليست قرارات معمارية وافق عليها المستخدم قبل scaffold.
- `applicationId`/`namespace` الحاليان `com.example.telemanager` placeholder افتراضي، ويجب اتخاذ قرار مستقل قبل النشر.
- لا يوجد NDK pin في Gradle ولا ABI معتمدة. رغم ذلك، نزّل Gradle NDK Side by side `28.2` تلقائيًا أثناء APK build؛ هذه ملاحظة تشغيلية وليست اعتمادًا معماريًا.
- مكتبة/حزمة TDLib وطريقة الربط؛ إصدارات Drift وRiverpod وGoRouter وحزم التشفير؛ وسياسة النسخ ومزامنة الملفات تبقى مؤجلة.

لا تثبت قرارًا إنتاجيًا أو واجهة جديدة اعتمادًا على القالب وحده؛ راجع التوافق والوثائق الرسمية وجرب تغييرات Android native في بوابة مستقلة.

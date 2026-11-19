# TeleManager --- Master Technical Blueprint

## وثيقة المواصفات الهندسية وخطة التنفيذ الرئيسية

**الإصدار:** 1.0\
**الحالة:** مواصفات تأسيسية قابلة للتطوير\
**المنصة المستهدفة أولًا:** Android\
**الهدف:** بناء مدير ملفات سحابي احترافي يعتمد على Telegram كأول مزود
تخزين، مع بنية تسمح بإضافة مزودين آخرين مستقبلًا.

------------------------------------------------------------------------

# 1. الرؤية والهدف

TeleManager هو مدير ملفات افتراضي (Cloud Virtual File Manager)، وليس
مجرد تطبيق لرفع الملفات إلى Telegram.

يجب أن يشعر المستخدم بأنه يتعامل مع مدير ملفات تقليدي مثل MT Manager،
بينما تُخزّن الملفات الأصلية سحابيًا ويحتفظ الهاتف ببياناتها الوصفية
(Metadata) وذاكرة مؤقتة محدودة عند الحاجة.

## الأهداف الأساسية

1.  تقليل استهلاك مساحة الهاتف.
2.  إدارة الملفات السحابية كما لو كانت ملفات محلية.
3.  إنشاء مجلدات ومجلدات فرعية افتراضية بحرية.
4.  تصنيف الملفات تلقائيًا حسب النوع والامتداد.
5.  البحث السريع في أسماء الملفات والمجلدات والوسوم والامتدادات.
6.  رفع الملفات وتنزيلها مع إظهار التقدم وإمكانية الإلغاء والاستئناف
    الآمن.
7.  دعم الملفات التي تتجاوز حد Telegram لكل ملف عن طريق تقسيمها إلى
    أجزاء مستقلة، عند اختيار هذه الميزة.
8.  توفير Cache ذكي ومعاينة للملفات.
9.  نسخ احتياطي مشفر واستعادة بنية الملفات.
10. دعم المزامنة بين عدة أجهزة وفق بروتوكول واضح.
11. فصل محرك إدارة الملفات عن مزود التخزين، حتى يمكن إضافة WebDAV أو
    Google Drive أو خادم خاص مستقبلًا.

## المبدأ المعماري الأهم

**TeleManager مستقل عن Telegram في منطق إدارة الملفات. Telegram هو مزود
تخزين أول، وليس قلب التطبيق.**

------------------------------------------------------------------------

# 2. القيود والحقائق التقنية

## 2.1 حدود حجم الملفات في Telegram

يجب عدم افتراض أن جميع الحسابات تستطيع رفع الحجم نفسه.

-   الحد المعلن للحساب العادي: حتى 2 GB للملف الواحد.
-   الحد المعلن لمشتركي Telegram Premium: حتى 4 GB للملف الواحد.
-   يجب التحقق من القيود الفعلية التي تسمح بها TDLib والخادم والحساب وقت
    التنفيذ.
-   لا تثبّت حدود الرفع في أماكن متعددة داخل الكود؛ اجعلها جزءًا من
    `AccountCapabilities` أو إعدادات مزود التخزين.
-   تعامل مع أخطاء الخادم بوصفها مصدرًا نهائيًا للحقيقة، ولا تعتمد على
    التحقق المحلي وحده.

روابط مرجعية: - https://telegram.org/faq -
https://core.telegram.org/api/files - https://core.telegram.org/tdlib

## 2.2 الملفات التي تتجاوز الحد

إذا اختار المستخدم رفع ملف أكبر من الحد المتاح لحسابه، اعرض الخيارات
التالية:

1.  تقسيم الملف إلى أجزاء مستقلة ورفع كل جزء كرسالة منفصلة.
2.  استخدام مزود تخزين خارجي يدعم الحجم المطلوب.
3.  إلغاء العملية.

### تصميم File Chunking

مثال: ملف حجمه 6 GB وحساب يسمح بحد 2 GB لكل ملف.

1.  فحص الحجم والمساحة المؤقتة المتاحة.
2.  تقسيم الملف إلى أجزاء أصغر من الحد مع هامش أمان.
3.  حساب SHA-256 للملف الأصلي، وحساب بصمة لكل جزء.
4.  رفع كل جزء كملف مستقل.
5.  حفظ معرف كل رسالة/ملف سحابي لكل جزء.
6.  إنشاء Manifest يحدد ترتيب الأجزاء وأحجامها وبصماتها.
7.  عند التنزيل، تنزيل الأجزاء والتحقق منها ثم إعادة تركيب الملف.
8.  حساب بصمة الملف النهائي ومقارنتها بالبصمة الأصلية.
9.  عدم إعلان نجاح إعادة التجميع إلا بعد اجتياز التحقق.

**مهم:** هذه الآلية لا تجعل Telegram يقبل ملفًا واحدًا يتجاوز الحد. إنها
تخزن عدة ملفات مستقلة وتعيد تجميعها داخل TeleManager.

يجب أن يدعم النظام: - فشل جزء دون إعادة رفع الأجزاء المكتملة. - إعادة
محاولة الجزء الفاشل فقط. - إيقاف العملية واستئنافها بأمان. - التحقق من
مساحة الهاتف قبل إعادة التجميع. - حذف الأجزاء المؤقتة بعد اكتمال
العملية، وفق إعداد المستخدم. - معالجة Manifest المفقود أو التالف. -
إظهار الحجم وعدد الأجزاء للمستخدم.

لا تفترض حجم جزء ثابتًا دون اختبار TDLib وحدود الخادم. اجعل حجم الأجزاء
قابلًا للضبط ضمن الحدود المسموح بها.

## 2.3 قيود أخرى

-   TDLib عميل Telegram كامل، وليست مجرد واجهة HTTP لرفع الملفات.
-   TDLib تحتفظ ببيانات محلية وملفات مؤقتة؛ لذلك لا يمكن ضمان أن التطبيق
    لا يستخدم أي مساحة محلية.
-   لا تفترض وجود رابط HTTP مباشر ودائم للملف.
-   لا تعتمد على `message_id` أو `file_id` وحده كمعرف داخلي دائم للملف.
-   يجب احترام `FLOOD_WAIT` والقيود التي يعيدها Telegram، وعدم استخدام
    تأخير ثابت عشوائي بدلًا منها.
-   القنوات والمحادثات السحابية العادية ليست Secret Chats مشفرة من طرف
    إلى طرف.
-   يجب الالتزام بشروط Telegram API، واستخدام `api_id` و`api_hash`
    مسجلين للتطبيق، وعدم تضمين أسرار المستخدم في السجلات.

------------------------------------------------------------------------

# 3. القرارات التقنية المقترحة

  المكوّن                      الاختيار المقترح
  --------------------------- --------------------------------
  المنصة الأولى               Android
  Framework                   Flutter
  لغة الواجهة والمنطق العام   Dart
  طبقة Android الأصلية        Kotlin
  Telegram Client             TDLib
  قاعدة البيانات              SQLite عبر Drift
  إدارة الحالة                Riverpod
  التنقل                      GoRouter
  التصميم                     Material 3 بتخصيص كامل
  التخزين المحلي الآمن        Android Keystore عند الحاجة
  تشفير النسخ الاحتياطية      AES-GCM عبر مكتبة موثوقة
  بصمات الملفات               SHA-256
  الاختبارات                  Unit + Integration + Widget/UI

## لماذا Android أولًا؟

ابدأ بـ Android لتقليل تعقيد التكامل واختبار TDLib والتخزين وإدارة
الملفات. حافظ على استقلال Core عن Android حتى لا يصبح نقل المشروع إلى
iOS مستحيلًا لاحقًا.

## ملاحظة TDLib

TDLib مكتوبة أساسًا بـ C++ وتحتاج إلى ربط مناسب مع Flutter. يمكن تنفيذ
طبقة Android أصلية باستخدام Kotlin وواجهة JNI/Native أو آلية ربط موثوقة.
يجب دراسة طريقة توزيع وبناء TDLib على Android قبل كتابة التطبيق الكامل.

لا تفترض أن حزمة Flutter غير رسمية توفر كل وظائف TDLib أو أنها محدثة
وآمنة. قيّم المصدر والترخيص والإصدارات والقدرات قبل اعتماد أي wrapper.

------------------------------------------------------------------------

# 4. المعمارية العامة

يتكون المشروع من محركات مستقلة:

``` text
                    TeleManager UI
                          |
                    Application Layer
                          |
       +------------------+------------------+
       |                  |                  |
    TM-Core            TM-Cloud           TM-Sync
       |                  |                  |
  Virtual File       Storage Provider    Change Log
    System                 |              Conflict
       |              +----+----+         Resolution
       |              |         |
    Database       Telegram   Future Providers
                   Provider   (WebDAV, Drive...)
                       |
                      TDLib
                       |
                 Telegram Cloud

       TM-Cache       TM-Backup       TM-Transfer
```

## 4.1 TM-Core

محرك إدارة الملفات الافتراضية، ولا يعتمد على Telegram.

المسؤوليات: - إنشاء المجلدات وحذفها ونقلها. - إعادة تسمية الملفات. -
التصنيف. - البحث. - الوسوم والمفضلة. - الإصدارات. - حالة الملف. - قواعد
نقل الملفات بين المجلدات. - إدارة علاقات المجلدات والملفات.

## 4.2 TM-Cloud

طبقة تجريد موحدة لمزودي التخزين.

المسؤوليات: - الاتصال بمزود التخزين. - المصادقة. - رفع وتنزيل الملفات. -
حذف الملفات السحابية. - جلب بيانات الملف. - التعامل مع أخطاء المزود. -
الإبلاغ عن قدرات الحساب والحدود.

## 4.3 TM-UI

مسؤول عن الواجهة فقط: - Explorer. - القوائم والتبويبات. - تفاصيل
الملفات. - البحث. - الإعدادات. - عرض العمليات والتقدم.

لا تضع منطق TDLib أو قاعدة البيانات مباشرة داخل Widgets.

## 4.4 TM-Transfer

مسؤول عن: - Queue للرفع والتنزيل. - التقدم. - الإلغاء. - الإيقاف
والاستئناف. - إعادة المحاولة. - استعادة العمليات بعد إعادة تشغيل
التطبيق. - ترتيب الأولويات وحدود التزامن.

## 4.5 TM-Cache

مسؤول عن: - الصور المصغرة. - الملفات المفتوحة مؤخرًا. - أجزاء الوسائط
المؤقتة. - سياسة الحذف التلقائي. - حدود المساحة. - الملفات المحفوظة
Offline.

## 4.6 TM-Backup

مسؤول عن: - إنشاء نسخة متسقة من قاعدة البيانات. - التشفير. - التحقق من
السلامة. - رفع النسخ. - الاحتفاظ بالإصدارات. - الاستعادة وترقية مخطط
قاعدة البيانات.

## 4.7 TM-Sync

مسؤول عن: - سجل تغييرات الأجهزة. - رفع التغييرات وتنزيلها. - اكتشاف
التعارضات. - منع تكرار تطبيق العملية. - مزامنة الحذف والنقل وإعادة
التسمية.

------------------------------------------------------------------------

# 5. بنية Storage Provider

أنشئ واجهة مجردة لا تعتمد على Telegram.

مثال واجهة مفاهيمية:

``` dart
abstract interface class StorageProvider {
  Future<void> initialize();
  Future<AuthState> authenticate();
  Future<AccountCapabilities> getAccountCapabilities();

  Future<UploadResult> uploadFile(
    UploadRequest request,
    ProgressCallback onProgress,
  );

  Future<DownloadResult> downloadFile(
    DownloadRequest request,
    ProgressCallback onProgress,
  );

  Future<void> deleteFile(StorageObjectId id);
  Future<RemoteFileInfo> getFileInfo(StorageObjectId id);
  Future<void> cancelOperation(OperationId id);
}
```

هذه واجهة أولية وليست عقدًا نهائيًا. عدّل التواقيع بحسب متطلبات TDLib، لكن
حافظ على مبدأ فصل المزود عن Core.

التنفيذ الأول:

``` text
StorageProvider
    |
    +---- TelegramProvider (TDLib)
```

المزودون المستقبليون المحتملون:

``` text
StorageProvider
    |
    +---- TelegramProvider
    +---- WebDAVProvider
    +---- GoogleDriveProvider
    +---- CustomServerProvider
```

لا تنفذ مزودين إضافيين في الإصدار الأول؛ صمم حدود الواجهة فقط.

------------------------------------------------------------------------

# 6. قاعدة البيانات المحلية

استخدم SQLite عبر Drift.

## 6.1 الجداول المقترحة

  الجدول            الوظيفة
  ----------------- ---------------------------------
  folders           شجرة المجلدات
  files             البيانات الوصفية للملفات
  storage_objects   مراجع الملفات لدى مزودي التخزين
  file_parts        أجزاء الملفات الكبيرة
  tags              الوسوم
  file_tags         ربط الملفات بالوسوم
  file_versions     إصدارات الملفات
  operations        سجل العمليات
  sync_queue        عمليات المزامنة المنتظرة
  device_registry   الأجهزة المعروفة
  change_log        سجل التغييرات
  thumbnails        بيانات الصور المصغرة أو مراجعها
  app_settings      إعدادات المستخدم
  backup_records    سجل النسخ الاحتياطية

## 6.2 قواعد تصميم قاعدة البيانات

1.  لكل ملف UUID داخلي ثابت.
2.  لكل مجلد UUID داخلي ثابت.
3.  لا تستخدم `message_id` مفتاحًا أساسيًا للملف.
4.  افصل بيانات الملف المنطقية عن مرجع التخزين الفعلي.
5.  اسمح للملف بامتلاك أكثر من Storage Object عند الحاجة.
6.  استخدم Transactions للعمليات المركبة.
7.  أضف فهارس إلى `name`, `extension`, `folder_id`, `updated_at`.
8.  استخدم migrations لكل تغيير في المخطط.
9.  لا تحذف سجل الملف لمجرد فشل الرفع.
10. خزّن حالات العمليات بشكل دائم حتى يمكن استعادتها بعد إغلاق التطبيق.

## 6.3 حقول الملفات المقترحة

``` json
{
  "id": "internal-uuid",
  "name": "project.zip",
  "extension": "zip",
  "mime_type": "application/zip",
  "size": 12500000,
  "folder_id": "folder-uuid",
  "status": "uploaded",
  "checksum_algorithm": "sha256",
  "checksum": "hex-value",
  "created_at": 1795100000,
  "updated_at": 1795100000
}
```

## 6.4 بيانات التخزين السحابي

مثال مفاهيمي:

``` json
{
  "id": "storage-object-uuid",
  "file_id": "internal-file-uuid",
  "provider": "telegram",
  "account_id": "account-uuid",
  "chat_id": "telegram-chat-id",
  "message_id": 12345,
  "tdlib_file_id": 67890,
  "remote_unique_id": "provider-unique-reference",
  "remote_status": "available"
}
```

اعتبر مراجع TDLib قابلة للتغير أو التحديث وفق طبيعة الواجهة. احتفظ
بالمعرفات المناسبة لاسترجاع الملف، ولا تعتمد على قيمة واحدة فقط.

## 6.5 توثيق العقود البرمجية (API Contracts)

أنشئ الملف `docs/INTERFACES.md` ليكون المرجع المختصر والموحد للواجهات العامة بين المحركات والوحدات.

يجب أن يوثق:
- اسم الواجهة أو العقد والطبقة المالكة له.
- مسؤولية الواجهة.
- الدوال العامة وتواقيعها وأنواع المدخلات والمخرجات.
- نماذج البيانات والنتائج والأخطاء المتوقعة.
- قواعد دورة الحياة والتزامن والإلغاء وإدارة الموارد عند انطباقها.
- الوحدات التي تعتمد على الواجهة.

قواعد إلزامية:
1. حدّث `docs/INTERFACES.md` كلما أُضيفت أو عُدّلت أو حُذفت واجهة عامة، مثل `StorageProvider` أو واجهات TM-Core.
2. ركّز على العقود التي تعبر حدود الوحدات، ولا تحوّل الملف إلى نسخة من الشيفرة المصدرية.
3. اجعل التوثيق مطابقًا للكود الفعلي والاختبارات.
4. عند تغيير عقد قائم، وضّح أثر التغيير على الوحدات المستهلكة وخطة التوافق أو الترحيل.
5. عند بدء محادثة جديدة مع مساعد AI، اقرأ `PROJECT_RULES.md` و`docs/INTERFACES.md` والوثائق المرتبطة بالمهمة.
6. لا تخترع دوالًا أو معاملات اعتمادًا على الذاكرة؛ تحقق من العقد الحالي في الكود والوثيقة.

## 6.5 علاقات البيانات

``` mermaid
erDiagram
    FOLDERS ||--o{ FOLDERS : parent
    FOLDERS ||--o{ FILES : contains
    FILES ||--o{ STORAGE_OBJECTS : stored_as
    FILES ||--o{ FILE_PARTS : split_into
    FILES ||--o{ FILE_VERSIONS : versions
    FILES ||--o{ FILE_TAGS : tagged
    TAGS ||--o{ FILE_TAGS : assigned
    FILES ||--o{ OPERATIONS : operations
    DEVICES ||--o{ CHANGE_LOG : creates
```

------------------------------------------------------------------------

# 7. Telegram TDLib Integration

نفّذ تكامل TDLib في وحدة مستقلة، ولا تربطه مباشرة بالواجهة.

## 7.1 المصادقة

تسلسل العمل:

1.  إدخال رقم الهاتف.
2.  بدء تدفق المصادقة.
3.  إدخال رمز التحقق.
4.  التعامل مع كلمة مرور Two-Step Verification عند طلبها.
5.  انتظار حالة `authorizationStateReady`.
6.  تخزين جلسة TDLib في مساحة التطبيق الخاصة.
7.  استعادة الجلسة عند إعادة فتح التطبيق.
8.  توفير تسجيل خروج آمن يمسح بيانات الجلسة وفق اختيار المستخدم.

لا تسجل رموز التحقق أو كلمات المرور أو بيانات الجلسة في Logs.

## 7.2 إنشاء قناة التخزين

بعد المصادقة:

1.  التحقق من وجود قناة TeleManager المرتبطة بالحساب.
2.  إذا لم توجد، اطلب موافقة المستخدم قبل إنشائها.
3.  أنشئ قناة خاصة باسم افتراضي مثل `TeleManager Cloud`.
4.  خزّن `chat_id` في قاعدة البيانات.
5.  تحقق من صلاحيات الحساب.
6.  لا تنشئ قناة جديدة عند كل تشغيل.
7.  أتح للمستخدم معرفة القناة وإدارتها أو إعادة ربطها.

لا تفترض أن إنشاء القناة أو إدارتها سينجح في جميع الحالات؛ تعامل مع
القيود وأخطاء الحساب بوضوح.

## 7.3 الرفع

تسلسل الرفع:

``` text
Select File
    |
Validate File
    |
Read Metadata
    |
Calculate Checksum (asynchronously)
    |
Check Account Capabilities
    |
Check Telegram File Limit
    |
Create Persistent Operation
    |
Upload Through TDLib
    |
Monitor TDLib Updates
    |
Confirm Message/Remote Object
    |
Persist Storage References
    |
Mark Operation Completed
```

لا تسجل العملية `Completed` قبل تأكيد نجاح الإرسال وحفظ المرجع السحابي.

## 7.4 التنزيل

-   تنزيل عند الطلب.
-   عرض التقدم.
-   الإلغاء.
-   الاستئناف وفق قدرات TDLib.
-   التحقق من البصمة عند توفرها.
-   الحفظ في Cache أو في مسار يختاره المستخدم.
-   تنظيف النسخ المؤقتة وفق السياسة.
-   عدم افتراض وجود URL مباشر دائم.

## 7.5 الأخطاء

  الخطأ                     السلوك
  ------------------------- ----------------------------------------------
  FLOOD_WAIT                احترام مدة الانتظار التي يحددها Telegram
  Network Error             إعادة المحاولة بتدرج زمني مناسب
  Upload Failed             الاحتفاظ بسجل العملية وحالتها
  File Reference Expired    تحديث المرجع باستخدام TDLib
  Local Storage Full        إيقاف العمليات التي تحتاج مساحة وإظهار السبب
  Authentication Required   طلب إعادة المصادقة
  File Too Large            اقتراح التقسيم أو مزود آخر
  Permission Error          توضيح صلاحيات الحساب المطلوبة

لا تستخدم إعادة محاولات غير محدودة. أضف حدًا للمحاولات، وسياسة backoff،
وحالة نهائية يمكن للمستخدم فهمها.

------------------------------------------------------------------------

# 8. نظام Transfer Queue

كل عملية رفع أو تنزيل يجب أن تكون سجلًا دائمًا.

الحالات المقترحة:

``` text
Pending
Queued
Preparing
Uploading
Downloading
Paused
Retrying
Completed
Failed
Cancelled
NeedsAuthentication
WaitingForRateLimit
```

الخصائص:

-   استعادة العمليات بعد إغلاق التطبيق.
-   إظهار النسبة والسرعة والحجم المنقول.
-   إلغاء عملية.
-   إيقاف واستئناف حيث تسمح TDLib.
-   إعادة محاولة آمنة.
-   عدم تكرار رفع ملف اكتمل بالفعل بسبب إعادة تشغيل التطبيق.
-   تحديد عدد عمليات الرفع والتنزيل المتزامنة بعد اختبارات الأداء.
-   إعطاء الأولوية للعمليات التي يختارها المستخدم.
-   احترام حدود Telegram وFLOOD_WAIT.

لا تفترض أن كل عملية TDLib قابلة للاستئناف من أي نقطة؛ تحقق من سلوك API
المستخدم وصمم الاستعادة وفق ما تدعمه المكتبة.

------------------------------------------------------------------------

# 9. Virtual File System (VFS)

المجلدات افتراضية، وعلاقاتها محفوظة في قاعدة البيانات، ولا يلزم إنشاء
مجلد مقابل لكل مجلد في قناة Telegram.

مثال:

``` text
TeleManager Cloud/
├── Projects/
│   └── Web Projects/
│       ├── project.zip
│       ├── index.html
│       └── app.py
├── Documents/
│   └── Report.pdf
└── Media/
```

## وظائف VFS

-   إنشاء مجلد.
-   مجلد فرعي.
-   إعادة تسمية.
-   نقل.
-   نسخ مرجع ملف داخل مجلد آخر عند دعم ذلك.
-   حذف منطقي.
-   حذف نهائي منفصل.
-   المفضلة.
-   الوسوم.
-   البحث.
-   الفرز.
-   سجل العمليات.
-   إظهار حالة التوفر السحابي والمحلي.

## قواعد مهمة

-   نقل الملف بين مجلدين افتراضيين لا يحتاج إلى إعادة رفع الملف.
-   يجب الفصل بين إزالة الملف من VFS وحذفه من التخزين السحابي.
-   الحذف السحابي يجب أن يتطلب تأكيدًا واضحًا.
-   استخدم Trash/Soft Delete أو سجلًا يسمح بالتراجع قبل الحذف النهائي،
    إذا كان ذلك متوافقًا مع سياسة المنتج.
-   لا تسمح بعلاقات مجلدات دائرية.
-   ضع قواعد واضحة لحذف مجلد غير فارغ.

------------------------------------------------------------------------

# 10. تصنيف الملفات

أنشئ نظامًا قابلًا للتوسعة لتصنيف الملفات.

  التصنيف        امتدادات أولية
  -------------- ------------------------------
  Archives       ZIP, RAR, 7Z, TAR, GZ
  Programming    PY, JS, TS, JAVA, KT, C, CPP
  Web            HTML, CSS, JSON, XML, PHP
  Documents      PDF, DOCX, XLSX, PPTX, TXT
  Images         PNG, JPG, WEBP, SVG, GIF
  Videos         MP4, MKV, MOV, AVI
  Audio          MP3, WAV, FLAC, OGG
  Applications   APK, XAPK, AAB
  Other          أنواع غير معروفة

القواعد:

1.  لا تعتمد على الامتداد وحده.
2.  استخدم MIME Type عند توفره.
3.  استخدم File Signature/Magic Bytes عند الحاجة.
4.  اسمح للمستخدم بتغيير التصنيف يدويًا.
5.  اجعل تعريفات الأنواع قابلة للتحديث.
6.  لا تفتح أو تنفذ ملفات غير موثوقة تلقائيًا.

------------------------------------------------------------------------

# 11. File Cache وإدارة المساحة

هذه وظيفة أساسية وليست تحسينًا ثانويًا.

## سياسات التخزين

  العنصر             السياسة
  ------------------ --------------------------
  Metadata           دائم محليًا
  Thumbnails         Cache محدود
  PDF Preview        مؤقت أو Cache
  الفيديو            أجزاء مؤقتة عند التشغيل
  الملفات المفتوحة   Cache وفق حد المستخدم
  الملفات المؤقتة    تنظيف تلقائي آمن
  قاعدة البيانات     دائمة
  النسخ الاحتياطية   حسب إعداد المستخدم
  Offline Files      يحتفظ بها المستخدم صراحة

## إعدادات Cache

-   100 MB.
-   250 MB.
-   500 MB.
-   1 GB.
-   حد مخصص.
-   تنظيف تلقائي.
-   حذف الملفات غير المستخدمة منذ مدة.
-   استثناء ملفات أو مجلدات من التنظيف.
-   الاحتفاظ بملفات Offline.

**قاعدة غير قابلة للتفاوض:** تنظيف Cache المحلي لا يحذف الملف الأصلي من
Telegram أو أي مزود تخزين.

يجب أيضًا ضبط مسارات Cache الخاصة بـ TDLib وفهم ما الذي يمكن حذفه بأمان
من ملفاتها المحلية. لا تمسح ملفات قاعدة TDLib أو بيانات جلسة المصادقة
عشوائيًا.

------------------------------------------------------------------------

# 12. واجهة المستخدم

التصميم المقترح: واجهة داكنة احترافية مستوحاة من سهولة MT Manager، دون
نسخ تصميمه حرفيًا.

## الشاشات

1.  Splash Screen.
2.  Login.
3.  Home.
4.  File Explorer.
5.  Folder Explorer.
6.  File Details.
7.  Search.
8.  Categories.
9.  Upload Queue.
10. Download Queue.
11. Preview.
12. Settings.
13. Cloud Account.
14. Backup & Restore.
15. Storage Analytics.

## Explorer

-   List View وGrid View.
-   فرز حسب الاسم والحجم والتاريخ والنوع.
-   تحديد متعدد.
-   نسخ ونقل وإعادة تسمية وحذف.
-   إنشاء مجلدات.
-   بحث فوري.
-   عرض أيقونات امتدادات مناسبة.
-   عرض حالة الملف.
-   إظهار حالة الاتصال.
-   عرض حجم Cache.
-   إمكانية إظهار الملفات المحلية والسحابية معًا.

## Dual Pane

اجعل Dual-Pane ميزة اختيارية:

-   جهة للتخزين المحلي.
-   جهة للتخزين السحابي.
-   نقل ونسخ بين الجهتين.
-   لا تخلط بين نسخ ملف إلى Cache ورفعه إلى Cloud.

## Transfer Manager

شاشة مستقلة تعرض: - الملفات المنتظرة. - الملفات قيد الرفع. - الملفات قيد
التنزيل. - الملفات المكتملة. - الملفات الفاشلة. - سبب الفشل. - إعادة
المحاولة. - الإلغاء. - الإيقاف والاستئناف.

------------------------------------------------------------------------

# 13. المعاينة وStreaming

افصل بين ثلاثة أوضاع:

  الوضع      السلوك
  ---------- ------------------------------------
  Preview    معاينة صغيرة أو بيانات مختصرة
  Stream     تنزيل تدريجي أثناء التشغيل إن أمكن
  Download   تنزيل الملف كاملًا

## الفيديو والصوت

-   اختبار التشغيل دون اكتمال التنزيل.
-   اختبار Seek.
-   اختبار الاتصال الضعيف.
-   إيقاف أو تقليل التحميل عند إيقاف التشغيل.
-   إعادة استخدام البيانات المؤقتة.
-   عدم افتراض دعم كل صيغ الفيديو.
-   عدم افتراض وجود HTTP URL مباشر.
-   اختيار مشغل بعد إثبات أن طريقة إمداده بالبيانات متوافقة مع TDLib.

إذا لم يدعم مسار TDLib المستخدم التشغيل الجزئي بالشكل المطلوب، اعرض
تنزيلًا تدريجيًا أو تنزيلًا كاملًا بدل الادعاء بوجود Streaming حقيقي.

------------------------------------------------------------------------

# 14. النسخ الاحتياطي والاستعادة

لا ترفع نسخة SQLite عادية إلى القناة دون حماية.

## Backup Manager

1.  إنشاء Snapshot متسق من قاعدة البيانات باستخدام آلية SQLite آمنة.
2.  تشفير النسخة باستخدام AES-GCM.
3.  إضافة رقم إصدار للمخطط.
4.  إضافة معلومات الإصدار والتاريخ والجهاز.
5.  حساب SHA-256 للنسخة المشفرة.
6.  رفعها إلى قناة التخزين.
7.  حفظ مرجع النسخة في سجل محلي وسحابي.
8.  الاحتفاظ بعدد من النسخ السابقة.
9.  اختبار الاستعادة دوريًا.

## محتوى النسخة

-   المجلدات.
-   بيانات الملفات.
-   علاقات التخزين.
-   الوسوم.
-   المفضلة.
-   الإعدادات الضرورية.
-   سجل المزامنة المطلوب.

لا تضع كلمات المرور أو مفاتيح التشفير الخام داخل النسخة الاحتياطية.

## Restore Manager

1.  تسجيل الدخول.
2.  العثور على نسخ TeleManager.
3.  عرض النسخ وتواريخها.
4.  تنزيل نسخة يختارها المستخدم.
5.  التحقق من سلامة الملف.
6.  فك التشفير بعد الحصول على مفتاح صحيح.
7.  التحقق من إصدار المخطط.
8.  تنفيذ migrations عند الحاجة.
9.  استعادة العلاقات.
10. مطابقة الملفات مع مراجع التخزين.
11. عرض العناصر التي تعذر العثور عليها بدل إسقاطها بصمت.

## مفاتيح التشفير

يجب تصميم طريقة استعادة لا تعتمد على مفتاح محفوظ في الهاتف القديم فقط.
وضّح للمستخدم كيف يحفظ أو يستعيد مفتاحه أو عبارة الاسترداد. فقدان المفتاح
قد يعني فقدان القدرة على قراءة النسخة الاحتياطية.

------------------------------------------------------------------------

# 15. المزامنة بين عدة أجهزة

لا تستبدل قاعدة البيانات كاملة عند كل تحديث.

استخدم Change Log.

حقول مقترحة:

``` json
{
  "operation_id": "uuid",
  "device_id": "device-uuid",
  "entity_type": "file",
  "entity_id": "file-uuid",
  "operation_type": "rename",
  "revision": 12,
  "created_at": 1795100000,
  "payload": {}
}
```

## متطلبات Sync Manager

-   معرف فريد لكل جهاز.
-   معرف فريد لكل عملية.
-   منع تطبيق العملية نفسها مرتين.
-   ترتيب التغييرات أو اكتشاف الاعتماديات.
-   مزامنة الحذف.
-   مزامنة النقل وإعادة التسمية.
-   التعامل مع الأجهزة غير المتصلة.
-   اكتشاف التعارضات.
-   سجل واضح لنتائج المزامنة.

## حل التعارضات

-   لا تعتمد Last-Write-Wins لكل شيء.
-   يمكن استخدامه لبعض الحقول البسيطة بعد تحديد معنى الوقت ومصدره.
-   لا تحذف الملفات نهائيًا عند تعارض غير محسوم.
-   استخدم Tombstones للحذف المتزامن.
-   اجعل استعادة الملفات المحذوفة ممكنة ضمن فترة محددة إن أمكن.
-   وثّق سياسة التعارض واختبرها على جهازين أو أكثر.

------------------------------------------------------------------------

# 16. الأمن والخصوصية

1.  لا تسجل Telegram API credentials أو رموز الدخول أو كلمات المرور أو
    بيانات الجلسة.
2.  استخدم التخزين الخاص بالتطبيق لبيانات TDLib.
3.  استخدم Android Keystore لحماية الأسرار المحلية عند ملاءمته.
4.  شفّر النسخ الاحتياطية.
5.  قدم خيار تشفير الملفات قبل رفعها إذا أراد المستخدم حماية محتواها من
    مزود التخزين.
6.  وضّح أن Telegram Cloud Chats ليست Secret Chats مشفرة من طرف إلى طرف.
7.  لا ترفع أي ملف دون إجراء واضح من المستخدم.
8.  لا تحذف ملفات سحابية بسبب تنظيف Cache.
9.  اطلب تأكيدًا قبل الحذف النهائي أو العمليات الجماعية الخطرة.
10. لا تنفذ ملفات APK أو Scripts أو مستندات تلقائيًا.
11. تحقق من سلامة الملفات عند إعادة التجميع.
12. التزم بشروط Telegram API.

------------------------------------------------------------------------

# 17. خارطة الطريق التنفيذية

المدد التالية تقديرية لمطور واحد يستخدم أدوات مساعدة بالذكاء الاصطناعي،
وقد تزيد بسبب بناء TDLib واختبارات Android.

  ------------------------------------------------------------------------
  المرحلة                            المدة التقديرية المخرج
  --------------------- ---------------------------- ---------------------
  1\. Project                                  أسبوع هيكل المشروع
  Foundation                                         والاعتماديات

  2\. TDLib Integration             أسبوع أو أسبوعان تسجيل الدخول واستعادة
                                                     الجلسة

  3\. Cloud Operations                         أسبوع رفع وتنزيل وإدارة
                                                     الأخطاء

  4\. VFS Database                             أسبوع قاعدة البيانات
                                                     والمجلدات

  5\. File                                  عدة أيام التصنيف والبحث
  Classification                                     

  6\. Transfer Queue                           أسبوع طابور عمليات موثوق

  7\. Main UI                                أسبوعان Explorer والشاشات
                                                     الأساسية

  8\. Cache & Preview                          أسبوع Cache ومعاينة

  9\. Backup & Restore                         أسبوع نسخ مشفرة واستعادة

  10\. Multi-device                    أسبوع أو أكثر سجل التغييرات
  Sync                                               والتعارضات

  11\. Advanced                         حسب الأولوية Streaming وArchive
  Features                                           Preview وغيرها

  12\. Testing &                             أسبوعان APK مستقر واختبارات
  Release                                            
  ------------------------------------------------------------------------

لا تنتقل إلى مرحلة جديدة لمجرد انتهاء الوقت. الانتقال يكون بعد اجتياز
معايير القبول.

------------------------------------------------------------------------

# 18. هيكل المجلدات المقترح

``` text
telemanager/
│
├── android/
│   └── native/
│       └── tdlib_bridge/
│
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── utils/
│   │   └── security/
│   │
│   ├── data/
│   │   ├── database/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── migrations/
│   │
│   ├── engines/
│   │   ├── tm_core/
│   │   ├── tm_cloud/
│   │   ├── tm_sync/
│   │   ├── tm_cache/
│   │   ├── tm_transfer/
│   │   └── tm_backup/
│   │
│   ├── providers/
│   │   ├── storage_provider.dart
│   │   └── telegram/
│   │       ├── tdlib_client.dart
│   │       ├── telegram_auth.dart
│   │       ├── telegram_upload.dart
│   │       ├── telegram_download.dart
│   │       └── telegram_channel.dart
│   │
│   ├── features/
│   │   ├── authentication/
│   │   ├── explorer/
│   │   ├── folders/
│   │   ├── search/
│   │   ├── categories/
│   │   ├── transfers/
│   │   ├── preview/
│   │   ├── backup/
│   │   ├── settings/
│   │   └── analytics/
│   │
│   ├── shared/
│   │   ├── widgets/
│   │   ├── themes/
│   │   └── components/
│   │
│   └── main.dart
│
├── assets/
│   ├── icons/
│   ├── images/
│   └── file_types/
│
├── test/
│   ├── unit/
│   ├── integration/
│   └── widget/
│
├── docs/
│   ├── ARCHITECTURE.md
│   ├── DATABASE.md
│   ├── TELEGRAM_INTEGRATION.md
│   ├── SECURITY.md
│   ├── SYNC_PROTOCOL.md
│   ├── INTERFACES.md
│   └── ROADMAP.md
│
├── PROJECT_RULES.md
└── README.md
```

يمكن تعديل التفاصيل وفق متطلبات البناء الفعلية، لكن يجب الحفاظ على فصل
المسؤوليات.

------------------------------------------------------------------------

# 19. اختبارات القبول

لا تعتبر أي مرحلة مكتملة لمجرد أن التطبيق يعمل دون انهيار.

  -----------------------------------------------------------------------
  الاختبار                            معيار النجاح
  ----------------------------------- -----------------------------------
  تسجيل الدخول                        نجاح المصادقة ومعالجة 2FA

  استعادة الجلسة                      عدم طلب الدخول في كل تشغيل

  إنشاء القناة                        إنشاء مرة واحدة بعد موافقة المستخدم

  رفع ملف صغير                        رفعه وتسجيل مرجعه الصحيح

  رفع ملف كبير                        تقدم صحيح دون تجميد الواجهة

  ملف أكبر من الحد                    اقتراح التقسيم أو مزود بديل

  فشل جزء من ملف مقسم                 إعادة الجزء الفاشل فقط

  إعادة تجميع                         تطابق SHA-256

  انقطاع الإنترنت                     حالة عملية واضحة وإعادة محاولة آمنة

  إغلاق التطبيق                       استعادة العمليات الممكنة دون تكرار
                                      غير مقصود

  حذف Cache                           بقاء الملفات السحابية

  نقل ملف داخل VFS                    تغيير المجلد دون إعادة رفع

  حذف سحابي                           تأكيد واضح وتحديث قاعدة البيانات

  استعادة نسخة احتياطية               استرجاع بنية المجلدات

  نسخة احتياطية تالفة                 رفض الاستعادة مع توضيح السبب

  جهازان                              مزامنة التغييرات واكتشاف التعارض

  ملف مكرر                            اكتشافه وفق البصمة والسياسة

  ملف تالف                            اكتشاف فشل التحقق

  بحث محلي                            هدف أولي أقل من 200ms لعشرة آلاف
                                      سجل على جهاز متوسط، بعد القياس

  قوائم كبيرة                         عدم تحميل كل السجلات أو الصور دفعة
                                      واحدة
  -----------------------------------------------------------------------

------------------------------------------------------------------------

# 20. ميزات مستقبلية بعد استقرار الأساس

لا تنفذ هذه الميزات قبل استقرار VFS وTDLib وTransfer Queue:

-   File Versioning.
-   Duplicate Detection.
-   Archive Preview.
-   Batch Upload.
-   Batch Download.
-   File Integrity Verification.
-   Custom Tags.
-   Favorites.
-   Recently Opened.
-   Offline Favorites.
-   Advanced Filters.
-   Client-side File Encryption.
-   Import/Export Folder Tree.
-   Multiple Telegram Accounts.
-   WebDAV.
-   Google Drive.
-   Custom Storage Server.

------------------------------------------------------------------------

# 21. قواعد العمل مع Claude أو Kimi أو manus

استخدم ملف التعليمات التالي في جذر المشروع باسم `PROJECT_RULES.md`.

## PROJECT_RULES.md

``` text
# TeleManager — AI Development Rules

You are the lead software engineer of TeleManager.

## Project Objective
Build a professional Android cloud-based virtual file manager using Flutter, Kotlin, TDLib, and SQLite/Drift.

## Mandatory Architecture
- TM-Core: Independent virtual file system and file management logic.
- TM-Cloud: Storage provider abstraction.
- TelegramProvider: Telegram integration through TDLib.
- TM-UI: Flutter presentation layer.
- TM-Sync: Multi-device synchronization.
- TM-Backup: Encrypted backup and restoration.
- TM-Cache: Local cache management.
- TM-Transfer: Persistent transfer queue.

## Non-Negotiable Rules
1. Never mix UI code with storage or Telegram business logic.
2. Never hardcode Telegram upload limits in multiple locations.
3. Handle account capabilities and server errors.
4. Support oversized files through optional chunking and manifests.
5. Never assume Telegram provides a permanent direct HTTP download URL.
6. Never use Telegram message IDs as internal file IDs.
7. Never delete cloud files when clearing local cache.
8. Never mark uploads completed before Telegram confirms success.
9. All long-running operations must be asynchronous.
10. All transfer operations must support progress, cancellation, error reporting, and safe recovery where supported.
11. Database operations must use transactions where appropriate.
12. Backups must be encrypted, versioned, and integrity-checked.
13. Preserve compatibility with database migrations.
14. Do not replace real implementations with mocks without explicitly identifying them.
15. Do not claim a feature is complete unless its tests pass.
16. Never expose Telegram credentials, session data, or encryption keys in logs.
17. Do not silently delete cloud data.
18. Do not assume streaming is supported until tested with the chosen TDLib integration.
19. Keep provider-specific logic outside TM-Core.
20. Document every important architectural decision.
21. Before building TDLib from source for Android, evaluate trustworthy, maintained, compatible prebuilt artifacts (including Maven/JitPack where applicable). Verify provenance, license, version, ABI coverage, Android compatibility, and update history; never trust an artifact solely because it is published.
22. If no suitable prebuilt artifact exists, document and reproduce the source-build process, including exact TDLib version, Android NDK/CMake versions, build flags, and supported ABIs.
23. Keep docs/INTERFACES.md synchronized with every public interface or cross-module contract change.

## Context Window Management
- Do not read the entire project on every task.
- Read PROJECT_RULES.md, the task-relevant engine/module files, their directly connected interfaces, and only the documentation needed for the task.
- Start with docs/ARCHITECTURE.md and docs/INTERFACES.md to understand module boundaries and existing contracts.
- Expand the inspected scope only when dependencies, tests, or a concrete issue require it.
- Do not assume unseen code exists or invent APIs; inspect relevant declarations before using them.
- In the completion report, state which modules and interface documents were inspected.

## Development Workflow
For each task:

1. Inspect the relevant project structure without loading unrelated modules.
2. Read PROJECT_RULES.md and the relevant sections of docs/ARCHITECTURE.md and docs/INTERFACES.md.
3. Inspect task-relevant module files, directly connected interfaces, and relevant tests.
4. Identify dependencies and affected components.
5. Explain the implementation plan before major changes.
6. Implement only the requested scope.
7. Add or update tests.
8. Run relevant tests and static analysis.
9. Report changed files, inspected modules, test results, known issues, and remaining work.
10. Update documentation, including docs/INTERFACES.md when a public interface or contract changes.
11. Do not proceed to the next milestone without reporting the current milestone status.

## Change Management
- Do not rewrite working modules without a technical reason.
- Do not modify unrelated features.
- Do not add dependencies without explaining their purpose.
- Do not change database schemas without migrations.
- Preserve previously working functionality.
- Ask before making an irreversible architectural change.
- If a requirement is technically impossible, explain why and propose alternatives.
- Never fabricate successful test results.

## Completion Report
Every task must finish with:
- Implemented features.
- Modified files.
- Dependencies added.
- Tests executed and results.
- Known limitations.
- Remaining work.
- Recommended next task.
```

------------------------------------------------------------------------

# 22. مهام التنفيذ التي تعطى للنموذج بالترتيب

لا تطلب بناء التطبيق كاملًا في Prompt واحد. استخدم مهمة مستقلة لكل مرحلة.

    رقم المهمة
  ----- -------------------------------------
     01 تحليل المواصفات وإعداد هيكل المشروع
     02 إعداد Flutter وKotlin
     03 دراسة وبناء TDLib على Android
     04 تنفيذ المصادقة واستعادة الجلسة
     05 إنشاء StorageProvider
     06 تنفيذ Telegram Upload/Download
     07 تنفيذ أخطاء Telegram وFLOOD_WAIT
     08 إنشاء Drift Database
     09 تنفيذ Virtual File System
     10 تنفيذ File Classification
     11 تنفيذ Transfer Queue
     12 بناء File Explorer
     13 تنفيذ Cache Manager
     14 تنفيذ File Chunking وManifest
     15 تنفيذ Backup Manager
     16 تنفيذ Restore Manager
     17 تنفيذ Sync Manager
     18 تنفيذ File Preview
     19 اختبار Streaming الفعلي
     20 اختبارات التكامل والأمان والأداء
     21 تجهيز إصدار APK

## إدارة العقود بين المحركات

يجب أن يكون `docs/INTERFACES.md` خريطة عملية للواجهات العامة، لا نسخة من الشيفرة المصدرية.

عند إنهاء أي مهمة تنشئ أو تعدّل عقدًا بين وحدتين:
1. حدّث الواجهة في الكود والاختبارات.
2. حدّث `docs/INTERFACES.md` بالتوقيع الفعلي والسلوك والأخطاء.
3. حدّث أمثلة الاستخدام إذا تغيّر أسلوب الاستدعاء.
4. اذكر الوحدات المتأثرة في تقرير الإنجاز.

عند بدء جلسة AI جديدة، زوّد المساعد بـ `PROJECT_RULES.md` و`docs/INTERFACES.md` والوثيقة الخاصة بالمهمة الحالية، واطلب منه فحص الملفات ذات الصلة فقط.

## قالب Prompt لكل مهمة

انسخ القالب التالي واملأ اسم المهمة:

``` text
We are developing TeleManager.

Read PROJECT_RULES.md and all relevant architecture documents first.

Current task:
[DESCRIBE ONE TASK]

Requirements:
- Follow the established architecture.
- Inspect existing code before changing anything.
- Do not modify unrelated modules.
- Do not create fake implementations.
- Add tests for the requested behavior.
- Preserve database compatibility.
- Document important decisions.

Before implementation:
1. Explain the current state.
2. List files that need changes.
3. Describe the implementation plan.
4. Identify technical risks and dependencies.

After implementation:
1. Run relevant tests.
2. Run static analysis.
3. Report exact test results.
4. List modified files.
5. List known limitations.
6. Update documentation.
7. Recommend the next task.

Do not start the next milestone automatically.
```

------------------------------------------------------------------------

# 23. ترتيب البدء الفعلي

ابدأ بالخطوات التالية فقط:

1.  أنشئ مستودع Git خاصًا بالمشروع.
2.  ضع هذه الوثيقة في `docs/MASTER_BLUEPRINT.md`.
3.  أنشئ `PROJECT_RULES.md` من القسم 21.
4.  اطلب من Claude أو Kimi تحليل الوثيقة، لا كتابة التطبيق مباشرة.
5.  اطلب منه إعداد هيكل المشروع وخطة الاعتماديات.
6.  راجع طريقة بناء TDLib على Android واختبرها في مشروع صغير مستقل.
7.  بعد نجاح اختبار TDLib، ابدأ المصادقة والرفع والتنزيل.
8.  لا تبدأ تصميم الواجهة النهائية قبل إثبات عمل محرك التخزين.

## أول نموذج أولي MVP

يجب أن يحقق أول إصدار تجريبي هذه الوظائف فقط:

-   تسجيل الدخول إلى Telegram.
-   استعادة الجلسة.
-   إنشاء قناة التخزين بعد الموافقة.
-   اختيار ملف محلي.
-   رفعه إلى القناة.
-   حفظ Metadata ومرجع الرسالة.
-   عرض الملف داخل قائمة TeleManager.
-   تنزيل الملف والتحقق منه.
-   حذف Cache دون حذف الملف السحابي.

بعد نجاح هذه الوظائف، انتقل إلى المجلدات الافتراضية والتصنيف والبحث.

------------------------------------------------------------------------

# 24. المراجع الرسمية

استخدم الوثائق الرسمية باعتبارها المصدر الأساسي عند تنفيذ التكامل:

-   TDLib: https://core.telegram.org/tdlib
-   Telegram File API: https://core.telegram.org/api/files
-   Telegram API ID: https://core.telegram.org/api/obtaining_api_id
-   Telegram API Terms: https://core.telegram.org/api/terms
-   Telegram FAQ: https://telegram.org/faq
-   Flutter: https://docs.flutter.dev/
-   Drift: https://drift.simonbinder.eu/
-   SQLite: https://www.sqlite.org/docs.html
-   Android Keystore:
    https://developer.android.com/privacy-and-security/keystore

تحقق من أحدث الإصدارات والقيود قبل اعتماد تفاصيل تنفيذية؛ قد تتغير
واجهات المكتبات أو سياسات المنصات.

------------------------------------------------------------------------

# 25. المبدأ النهائي للمشروع

**لا تجعل TeleManager واجهة لتيليجرام. اجعله مدير ملفات مستقلًا يستخدم
تيليجرام لتخزين الملفات.**

الأولوية الهندسية:

1.  صحة البيانات.
2.  سلامة الملفات.
3.  موثوقية الرفع والتنزيل.
4.  استعادة العمليات بعد الانقطاع.
5.  سلامة النسخ الاحتياطي والمزامنة.
6.  تقليل استهلاك مساحة الهاتف.
7.  سهولة الاستخدام والأداء.
8.  الميزات المتقدمة.

إذا تم بناء TM-Core وTM-Cloud وTM-Transfer بشكل صحيح، فستكون إضافة مزودي
تخزين وميزات جديدة ممكنة دون إعادة كتابة المشروع من الصفر.

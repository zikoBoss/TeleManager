# قاعدة البيانات — مخطط مبدئي

الحالة: مواصفات فقط؛ لم تثبت اعتماديات Flutter/Drift ولم تنشأ migrations أو جداول بعد.

## القرار المقترح
SQLite عبر Drift. كل تغييرات المخطط عبر migrations. استخدم Transactions للعمليات المركبة. قاعدة TeleManager منفصلة مفاهيميًا عن ملفات/قاعدة جلسة TDLib؛ لا تمسح بيانات TDLib عشوائيًا.

## جداول أولية
| الجدول | الوظيفة المتوقعة |
|---|---|
| folders | شجرة مجلدات VFS |
| files | metadata منطقية للملفات |
| storage_objects | مراجع التخزين عند المزودين |
| file_parts | أجزاء ملف كبير وبياناتها |
| tags / file_tags | تعريف الوسوم وربطها بالملفات |
| file_versions | إصدارات مستقبلية |
| operations | سجلات النقل الدائمة |
| sync_queue | تغييرات تنتظر المزامنة |
| device_registry | الأجهزة المعروفة |
| change_log | سجل تغييرات الأجهزة |
| thumbnails | بيانات أو مراجع thumbnails |
| app_settings | إعدادات المستخدم |
| backup_records | سجلات النسخ الاحتياطية |

## قواعد بيانات إلزامية
- UUID داخلي ثابت لكل ملف ومجلد؛ لا تستخدم message_id مفتاحًا أساسيًا.
- افصل الملف المنطقي عن التخزين الفعلي؛ اسمح بعدة `storage_objects` للملف.
- الفهارس الأولية: name, extension, folder_id, updated_at.
- فشل الرفع لا يحذف سجل الملف أو العملية.
- احتفظ بالحالة الدائمة لتمكين استعادة ما يمكن استعادته بعد إغلاق التطبيق.
- حدد سياسة soft-delete/tombstone والتعارض قبل حذف البيانات نهائيًا.

## عناصر الملف المرجعية
`id`, `name`, `extension`, `mime_type`, `size`, `folder_id`, `status`, `checksum_algorithm`, `checksum`, `created_at`, `updated_at`.

## مرجع التخزين المرجعي
`id`, `file_id`, `provider`, `account_id`, `chat_id`, `message_id`, `tdlib_file_id`, `remote_unique_id`, `remote_status`. تعامل مع معرفات TDLib بوصفها مراجع قابلة للتحديث حسب API؛ لا تعتمد على قيمة واحدة فقط.

## قبل اعتماد schema
تحقق من إصدار Drift وSQLite، ودعم المنصة، وأنواع الحقول والفهارس والمعاملات، وسياسة المهاجرات. حدّث هذا الملف و`INTERFACES.md` والاختبارات مع الكود الفعلي.

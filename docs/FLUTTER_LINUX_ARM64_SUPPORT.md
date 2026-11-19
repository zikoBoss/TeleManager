# تحقق دعم Flutter Stable على مضيف Linux ARM64

**تاريخ التحقق:** 2026-11-19. **الغرض:** تحديد ما إذا كان Flutter Stable 3.50.0 يوفر Flutter SDK رسميًا قابلًا للتشغيل على Linux ARM64، وتسجيل حالة Android SDK المرتبطة بالمهمة 02.

## مصدر البيانات والمنهج

فُتحت manifests الرسمية لـ Linux وmacOS وWindows، ثم استُخرجت جميع السجلات التي تطابق `channel == stable` و`version == 3.50.0`. حقل المعمارية في manifest هو `dart_sdk_arch` وحقل SHA-256 هو `sha256`. روابط الملفات أدناه مبنية من `base_url` و`archive` كما وردا في السجلات، ولم تُخمن أسماء بديلة.

المضيف الحالي أعاد `uname -m` النتيجة `aarch64`. في فحص سابق لحزمة Flutter Linux الرسمية، أظهر `file` أن Dart المضمّن ELF x86-64، وفشل تشغيله على ARM64 برسالة `Exec format error`. أما في جولة التدقيق الحالية، فلا يوجد Flutter أو Dart على `PATH`، ولم تُجرَ محاولة تنزيل أو تثبيت لهما.

## جميع سجلات Stable 3.50.0 حسب manifests الرسمية

| OS | معمارية المضيف في manifest (`dart_sdk_arch`) | مسار archive | رابط archive الرسمي | SHA-256 |
|---|---|---|---|---|
| Linux | x64 | `stable/linux/flutter_linux_3.50.0-stable.tar.xz` | [تنزيل Linux x64](https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.50.0-stable.tar.xz) | `6ea2d806fd57269ae783e6788e2a81fc26eaad782f1e0d0ff38623bb765ff9f5` |
| macOS | x64 | `stable/macos/flutter_macos_3.50.0-stable.zip` | [تنزيل macOS x64](https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.50.0-stable.zip) | `d4e1bf2e2fc0c2e92267f45660c16a7d805e84ad42cb40b64b466446bffe48e0` |
| macOS | arm64 | `stable/macos/flutter_macos_arm64_3.50.0-stable.zip` | [تنزيل macOS ARM64](https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.50.0-stable.zip) | `ed2d08a3e3c023e84cbe9316d21bd88fda6ee9552f90c1eb4da41a07c170fb35` |
| Windows | x64 | `stable/windows/flutter_windows_3.50.0-stable.zip` | [تنزيل Windows x64](https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.50.0-stable.zip) | `35fb843409c80a1c69b64bbae1756bba437222f909622d83540e266e1759aab8` |

يحتوي manifest الرسمي لـ Linux على سجل stable واحد فقط للإصدار 3.50.0، ومعماريته `x64`. لا يوجد سجل Linux ARM64؛ وسجل `arm64` المتاح يخص macOS ولا يصلح لمضيف Ubuntu. لذلك لا تتوفر في manifest الذي فُحص حزمة Flutter Stable 3.50.0 رسمية متوافقة مع مضيف Linux ARM64. لا يُستخدم تنزيل macOS ARM64 أو تعديل Dart أو تشغيل ملف x86-64 على ARM64 بديلًا عن ذلك.

## حالة Android SDK والمهمة

Android SDK Command-line Tools الرسمية مثبتة في `~/Android/Sdk/cmdline-tools/latest` (`sdkmanager` 22.0). كما ثبتت `platforms;android-36` revision `2`، و`build-tools;36.1.0`، و`platform-tools` 37.0.3. قُبل ترخيص `android-sdk-license` وحده. أدوات `adb` و`aapt` و`aapt2` هي ملفات Linux x86-64، ولذلك لا يمكن تشغيلها على مضيف ARM64. Flutter غير مثبت، ولم يُنشأ مشروع Flutter أو يُبن APK.

المهمة 02 ما زالت مفتوحة بانتظار بيئة بناء واختبار موثوقة. لا انتقال إلى المهمة 03. راجع أيضًا [`ANDROID_SETUP.md`](ANDROID_SETUP.md) و[`TASK02_STATUS_2026-11-19.md`](TASK02_STATUS_2026-11-19.md) للحالة الموحدة وسلوك سكربت الإعداد.

## المراجع الرسمية

[1]: https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json "Official Flutter Linux release manifest"
[2]: https://storage.googleapis.com/flutter_infra_release/releases/releases_macos.json "Official Flutter macOS release manifest"
[3]: https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json "Official Flutter Windows release manifest"
[4]: https://docs.flutter.dev/install/archive "Flutter SDK archive and architecture metadata"
[5]: https://docs.flutter.dev/install/manual "Install Flutter manually"
[6]: https://developer.android.com/studio "Android SDK command-line tools"

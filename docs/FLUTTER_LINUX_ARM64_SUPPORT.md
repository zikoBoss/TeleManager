# تحقق دعم Flutter Stable على مضيف Linux ARM64

**تاريخ التحقق:** 2026-11-19. **الغرض:** توثيق دعم Flutter Stable 3.50.0 لمضيف Linux ARM64 وحالة بيئة Android للمهمة 02.

## مصدر البيانات والمنهج

فُتحت manifests الرسمية لـ Linux وmacOS وWindows، ثم استُخرجت جميع السجلات المطابقة لـ`channel == stable` و`version == 3.50.0`. حقل المعمارية في manifest هو `dart_sdk_arch` وحقل SHA-256 هو `sha256`. روابط الملفات مبنية من `base_url` و`archive` كما وردا في السجلات.

المضيف المحلي يعيد `uname -m` النتيجة `aarch64`. في فحص الحزمة الرسمية أظهر `file` أن Dart المضمّن ELF x86-64 وفشل تشغيله على ARM64 برسالة `Exec format error`. لا يوجد Flutter أو Dart محلي على `PATH` ولم يُشغّل ملف x64 على Sandbox.

## جميع سجلات Stable 3.50.0 حسب manifests الرسمية

| OS | معمارية المضيف في manifest (`dart_sdk_arch`) | مسار archive | رابط archive الرسمي | SHA-256 |
|---|---|---|---|---|
| Linux | x64 | `stable/linux/flutter_linux_3.50.0-stable.tar.xz` | [تنزيل Linux x64](https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.50.0-stable.tar.xz) | `6ea2d806fd57269ae783e6788e2a81fc26eaad782f1e0d0ff38623bb765ff9f5` |
| macOS | x64 | `stable/macos/flutter_macos_3.50.0-stable.zip` | [تنزيل macOS x64](https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.50.0-stable.zip) | `d4e1bf2e2fc0c2e92267f45660c16a7d805e84ad42cb40b64b466446bffe48e0` |
| macOS | arm64 | `stable/macos/flutter_macos_arm64_3.50.0-stable.zip` | [تنزيل macOS ARM64](https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.50.0-stable.zip) | `ed2d08a3e3c023e84cbe9316d21bd88fda6ee9552f90c1eb4da41a07c170fb35` |
| Windows | x64 | `stable/windows/flutter_windows_3.50.0-stable.zip` | [تنزيل Windows x64](https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.50.0-stable.zip) | `35fb843409c80a1c69b64bbae1756bba437222f909622d83540e266e1759aab8` |

يحتوي manifest Linux على سجل Stable واحد للإصدار 3.50.0 ومعماريته x64. لا يوجد سجل Linux ARM64؛ وحزمة macOS ARM64 لا تصلح لمضيف Ubuntu. لذلك يستخدم TeleManager GitHub Actions x64، ولا يحاول تشغيل Flutter x64 على Sandbox ARM64.

## حالة Android وFlutter

Android SDK المحلي مثبت: Command-line Tools في `~/Android/Sdk/cmdline-tools/latest` (`sdkmanager` 22.0)، و`platforms;android-36` revision 2، و`build-tools;36.1.0`، و`platform-tools` 37.0.3. قُبل `android-sdk-license` وحده. `adb` و`aapt` و`aapt2` ملفات Linux x86-64 ولا تعمل على ARM64.

على GitHub runner x64، تحقق إعداد Java وAndroid SDK وFlutter. ولّد workflow scaffold Android-only بـFlutter 3.50.0، ثم نجح التحليل والاختبار وبناء APK على commit المشروع في [run 44744990391](https://github.com/zikoBoss/TeleManager/actions/runs/44744990391). يثبت السجل النهائي Flutter 3.50.0/Dart 3.14.0 وTemurin 21.0.13+9 وحزم Android المستهدفة، كما يسجل تحذير تراخيص Android الأخرى وLinux desktop. لم يقبل workflow ترخيصًا آخر.

في تشغيل البناء نزّل Gradle تلقائيًا NDK Side by side 28.2 (`r28c`) على runner رغم عدم وجود NDK pin في ملف المشروع. لم يُنفذ ذلك على Sandbox المحلية، ولا يُعامل كقرار NDK/ABI معتمد.

المهمة 02 الخاصة بإعداد البيئة وscaffold والتحقق مكتملة. Flutter غير مثبت على المضيف المحلي، ولا يعني ذلك عدم وجود scaffold في المستودع؛ الـscaffold نُقل من x64. المرحلة 03 لم تبدأ.

## المراجع الرسمية

[1]: https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json "Official Flutter Linux release manifest"
[2]: https://storage.googleapis.com/flutter_infra_release/releases/releases_macos.json "Official Flutter macOS release manifest"
[3]: https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json "Official Flutter Windows release manifest"
[4]: https://docs.flutter.dev/install/archive "Flutter SDK archive and architecture metadata"
[5]: https://docs.flutter.dev/install/manual "Install Flutter manually"
[6]: https://developer.android.com/studio "Android SDK command-line tools"

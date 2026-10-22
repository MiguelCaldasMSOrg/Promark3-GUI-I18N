# PM3 GUI

[简体中文](README.md) | **English**

A GPL-3.0 Flutter desktop interface for the official Proxmark3 client.
The interface is available in Simplified Chinese and English.
Windows x64 and Linux x64 are supported desktop targets; the Proxmark3
client and firmware are installed separately.

Only operate on devices, cards and systems you own or are explicitly
authorized to use.

## Languages

Choose **Settings → Language**:

- **System default** follows the operating system's preferred languages.
  Unsupported languages fall back to English.
- **简体中文** selects Simplified Chinese.
- **English** selects English.

Changes apply immediately without restarting or disconnecting the device.
The selection is saved in `language.json` in the operating system's application
support directory, separately from the existing `pm3_settings.json`.
Read/write failures are shown in Settings.

The application uses Flutter's standard ARB / `gen-l10n` pipeline, typed
localization accessors, ICU placeholders/plurals and localized Material,
Cupertino and widget delegates. Both languages cover navigation, operation
pages, warnings, editing, dump analysis and application-generated messages.
Terminal command help switches languages as well.

Proxmark3 commands, protocol names, hexadecimal data, file-format identifiers,
exported machine-readable content and raw client output are intentionally
unchanged. Native operating system file dialogs follow the operating system's
language; their appearance is not controlled by Flutter.

## Development

Use the stable Flutter SDK with its bundled Dart SDK and the Windows or Linux
desktop toolchain. This change was developed with Flutter 3.47.7 / Dart 3.13.5;
`flutter pub get` resolves the framework-pinned dependencies for your SDK.

```powershell
git clone https://github.com/Babel36acl/Promark3-GUI.git
Set-Location .\Promark3-GUI
flutter pub get
flutter run -d windows
```

For Linux, run `flutter run -d linux`. If Flutter is not in the current process's
PATH, invoke your installed SDK's `bin\flutter.bat` directly on Windows.

On Windows, select `pm3.bat` in the **root of the official Proxmark3 distribution**
in the connection page or Settings. The script initializes its own environment
and detects devices. Saved GUI port/argument values are not passed to that
script. Native clients, including Linux `proxmark3`, still use the selected
port and arguments. Each launch argument is entered on a separate line;
spaces, quotes and backslashes are preserved.

```powershell
flutter gen-l10n
dart run tools\check_localizations.dart
flutter analyze --no-pub --no-fatal-infos
flutter test --no-pub
flutter build windows --release --no-pub
```

`flutter pub get` and builds also generate localizations automatically.
Generated localization Dart files are ignored by Git; edit the ARB files,
not generated accessors.

For translator guidance and adding another language, see
[Localization](docs/localization.md). The original [Chinese README](README.md)
describes file formats, session logging and device integration in more detail.

## Privacy and license

The application does not upload device data or session logs. Local logs and
dump files can contain card identifiers, keys and other sensitive information;
review and redact them before sharing.

See [CONTRIBUTING.md](CONTRIBUTING.md), [SECURITY.md](SECURITY.md) and
[LICENSE](LICENSE).
The Proxmark3 client and firmware belong to
[RfidResearchGroup/proxmark3](https://github.com/RfidResearchGroup/proxmark3)
and their respective contributors; they are not redistributed by this project.

# Localization

## Design

This project follows Flutter's official
[internationalization guide](https://docs.flutter.dev/ui/internationalization):

- `flutter_localizations` supplies framework translations and text direction.
- `lib/l10n/app_en.arb` is the template; `app_zh.arb` preserves Simplified Chinese.
- `l10n.yaml` configures `flutter gen-l10n`; generated Dart files live beside
  the ARB files and are not committed.
- `MaterialApp` uses generated delegates, supported locales and
  `onGenerateTitle`. English is the fallback for unsupported system languages.
- UI code reads `context.l10n`. Stateful pages remain mounted when language
  changes; navigation, text controllers, draft data and connections are retained.
- Domain objects receive localization explicitly through `updateLocalizations`
  or optional `localizations` arguments. There is no mutable global locale or
  run-time dictionary that replaces text in hardware output. The immutable
  Chinese default preserves existing non-UI caller behavior.
- Dump-analysis caches include the locale; terminal suggestions are reloaded
  on locale changes with stale asynchronous results discarded.

## Editing messages

Give messages stable, semantic camelCase keys. Localize complete sentences:
do not concatenate translated word fragments, use display text as a storage
key, or decide application behavior by comparing translated strings.

Each template entry requires `@messageKey` translator metadata. Interpolations
use named ARB placeholders with explicit Dart types. Counts with grammatical
variants use ICU plurals, for example:

```json
{
  "messageCommands": "{value, plural, =0{No commands} =1{1 command} other{{value} commands}}",
  "@messageCommands": {
    "description": "Number of commands in terminal history.",
    "placeholders": {
      "value": {"type": "int"}
    }
  }
}
```

Keep placeholder names identical across languages, but allow translators to
reorder them. Hex values, commands, protocol names, serialized field names and
exported data must remain unchanged. Raw client output and OS diagnostic
details are not machine-translated.

After editing:

```powershell
flutter gen-l10n
dart run tools\check_localizations.dart
flutter analyze --no-pub --no-fatal-infos
flutter test --no-pub
```

The resource check rejects missing/extra/empty messages, missing template
metadata and untranslated Chinese in the English catalog. `gen-l10n` validates
ICU syntax and typed placeholders. Tests cover both languages on all 30 pages,
live switching, data retention, persistence, failure reporting, locale fallback,
framework strings, command-help language and locale-aware analysis.

Use wrapping or flexible layouts for captions that expand in translation.
Do not shorten safety warnings to make them fit.

## Adding a language

1. Copy the template to `lib/l10n/app_<language>.arb`, set `@@locale`, and
   translate every message while preserving placeholders.
2. Add the language's native name to the selector in
   `lib/ui/pages/settings_page.dart`. Native language names are deliberately
   constant so users can recover from choosing an unfamiliar language.
3. Run the commands above and exercise the new locale, including dialogs,
   errors, larger text and long captions.
4. If translated command help is available, add its asset and update
   `Pm3CommandCatalog` selection. Otherwise document that command help remains
   in English. Do not translate command syntax.

Generated `supportedLocales` and the preference controller recognize languages
from the ARB files, so a separate hard-coded locale list is not required.

## Preference storage

`LocaleSettingsStore` writes `language.json` in the application support
directory using an exclusive temporary file, a flushed write and same-directory
replacement. `null` means system default. Writes are serialized and flushed
during application exit. Missing files are normal; corrupt, unsupported or
unwritable preferences produce an explicit Settings error.

Language settings are separate from Proxmark3 launch settings and do not change
session records, device data, dump formats or client configuration.

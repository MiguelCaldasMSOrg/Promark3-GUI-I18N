import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'pm3_settings_store.dart';

abstract interface class LocaleSettingsRepository {
  Future<String?> load();
  Future<void> save(String? languageCode);
}

final class LocaleSettingsStore implements LocaleSettingsRepository {
  LocaleSettingsStore({SettingsDirectoryProvider? directoryProvider})
      : _directoryProvider =
            directoryProvider ?? getApplicationSupportDirectory;

  final SettingsDirectoryProvider _directoryProvider;
  static var _sequence = 0;

  Future<File> _file() async {
    final directory = await _directoryProvider();
    return File('${directory.path}${Platform.pathSeparator}language.json');
  }

  @override
  Future<String?> load() async {
    final file = await _file();
    if (!await file.exists()) return null;
    final json = jsonDecode(await file.readAsString());
    if (json is! Map<String, dynamic> ||
        !json.containsKey('language') ||
        (json['language'] != null && json['language'] is! String)) {
      throw const FormatException('Invalid language preference file');
    }
    return json['language'] as String?;
  }

  @override
  Future<void> save(String? languageCode) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.$pid.${_sequence++}.tmp');
    try {
      await temporary.create(exclusive: true);
      await temporary.writeAsString(
        jsonEncode({'language': languageCode}),
        flush: true,
      );
      await temporary.rename(file.path);
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }
}

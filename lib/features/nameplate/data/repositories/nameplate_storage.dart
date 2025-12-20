import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../domain/models/models.dart';

class NameplateStorage {
  static const String _fileName = 'nameplate_data.json';

  static Future<void> save(NameplateData data) async {
    final file = await _getLocalFile();
    await file.writeAsString(jsonEncode(data.toJson()));
  }

  static Future<NameplateData?> load() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) return null;
      final jsonMap = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return NameplateData.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final file = await _getLocalFile();
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }
}

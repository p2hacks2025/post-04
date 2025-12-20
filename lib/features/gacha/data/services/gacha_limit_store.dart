import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class GachaLimitStore {
  GachaLimitStore({required this.dailyLimit});

  static const String fileName = 'gacha_limits.json';

  final int dailyLimit;

  String _lastDate = '';
  int _remaining = 0;

  String get lastDate => _lastDate;
  int get remaining => _remaining;

  Future<void> loadOrInit() async {
    final today = _todayKey();
    final file = await _getFile();

    if (await file.exists()) {
      try {
        final jsonMap = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        _lastDate = (jsonMap['lastDate'] as String?) ?? '';
        _remaining = (jsonMap['remaining'] as num?)?.toInt() ?? dailyLimit;

        if (_lastDate != today) {
          _lastDate = today;
          _remaining = dailyLimit;
          await save();
        }
        return;
      } catch (_) {
        // fall through to init
      }
    }

    _lastDate = today;
    _remaining = dailyLimit;
    await save();
  }

  Future<void> refreshForToday() async {
    final today = _todayKey();
    if (_lastDate == today) return;
    _lastDate = today;
    _remaining = dailyLimit;
    await save();
  }

  Future<bool> consumeOne() async {
    await refreshForToday();
    if (_remaining <= 0) return false;
    _remaining -= 1;
    await save();
    return true;
  }

  Future<void> save() async {
    final file = await _getFile();
    final data = {
      'lastDate': _lastDate,
      'remaining': _remaining,
      'dailyLimit': dailyLimit,
    };
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  static String _todayKey() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

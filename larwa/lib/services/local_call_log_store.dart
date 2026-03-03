import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/local_call_log.dart';

class LocalCallLogStore {
  static const String _boxName = 'local_call_logs';
  static const int _maxItems = 50;

  Box<dynamic>? _box;

  Future<void> init() async {
    _box ??= await Hive.openBox<dynamic>(_boxName);
  }

  ValueListenable<Box<dynamic>> listenable() {
    final box = _box;
    if (box == null) {
      throw StateError('LocalCallLogStore not initialized');
    }
    return box.listenable();
  }

  List<LocalCallLog> all() {
    final box = _box;
    if (box == null) return const [];

    final items = <LocalCallLog>[];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        items.add(LocalCallLog.fromJson(Map<String, dynamic>.from(raw)));
      }
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<void> add(LocalCallLog log) async {
    final box = _box;
    if (box == null) return;

    await box.put(log.id, log.toJson());

    final keys = box.keys.toList();
    if (keys.length > _maxItems) {
      final logs = all();
      final toKeep = logs.take(_maxItems).map((e) => e.id).toSet();
      for (final k in keys) {
        if (!toKeep.contains(k.toString())) {
          await box.delete(k);
        }
      }
    }
  }

  Future<void> clear() async {
    final box = _box;
    if (box == null) return;
    await box.clear();
  }
}

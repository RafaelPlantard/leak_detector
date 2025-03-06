// Copyright (c) 2021, Jiakuo Liu. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:leak_detector/src/leak_data.dart';
import 'package:leak_detector/src/leak_data_store.dart';
import 'package:path/path.dart' as path show join;
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;
import 'package:sqlite3/sqlite3.dart';

///database
class _LeakDataBase {
  static Future<Database> _openDatabase() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final filename = path.join(docsDir.path, 'leak_recording.db');
    final db = sqlite3.open(filename);

    db.execute(
      'CREATE TABLE IF NOT EXISTS ${_LeakRecordingTable._kTableName}('
      '${_LeakRecordingTable._kId} TEXT NOT NULL PRIMARY KEY, '
      '${_LeakRecordingTable._kGCRootType} TEXT, '
      '${_LeakRecordingTable._kLeakPathJson} TEXT)',
    );

    return db;
  }
}

/// table
class _LeakRecordingTable {
  static const String _kTableName = 'leak_recording_table';
  static const String _kGCRootType = 'gcType';
  static const String _kLeakPathJson = 'leakPath'; //leaked path to json
  static const String _kId = '_id'; //time
}

///[_LeakRecordingTable] Helper
class LeakedRecordSQLiteStore implements LeakedRecordStore {
  static LeakedRecordSQLiteStore? _instance;
  late final Database _db;
  bool _initialized = false;

  factory LeakedRecordSQLiteStore() {
    _instance ??= LeakedRecordSQLiteStore._();
    return _instance!;
  }

  LeakedRecordSQLiteStore._();

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      _db = await _LeakDataBase._openDatabase();
      _initialized = true;
    }
  }

  Future<List<LeakedInfo>> _queryAll() async {
    await _ensureInitialized();
    final ResultSet resultSet = _db.select(
      'SELECT * FROM ${_LeakRecordingTable._kTableName}',
    );

    return resultSet.map((row) => _toData(row)).toList();
  }

  Future<void> _insert(LeakedInfo data) async {
    await _ensureInitialized();
    _db.execute(
      'INSERT OR REPLACE INTO ${_LeakRecordingTable._kTableName} '
      '(${_LeakRecordingTable._kId}, ${_LeakRecordingTable._kGCRootType}, ${_LeakRecordingTable._kLeakPathJson}) '
      'VALUES (?, ?, ?)',
      [data.timestamp.toString(), data.gcRootType, data.retainingPathJson],
    );
  }

  Future<void> _insertAll(List<LeakedInfo> data) async {
    await _ensureInitialized();
    final stmt = _db.prepare(
      'INSERT OR REPLACE INTO ${_LeakRecordingTable._kTableName} '
      '(${_LeakRecordingTable._kId}, ${_LeakRecordingTable._kGCRootType}, ${_LeakRecordingTable._kLeakPathJson}) '
      'VALUES (?, ?, ?)',
    );

    for (var info in data) {
      stmt.execute([info.timestamp.toString(), info.gcRootType, info.retainingPathJson]);
    }

    stmt.dispose();
  }

  Future<void> _deleteById(int id) async {
    await _ensureInitialized();
    _db.execute(
      'DELETE FROM ${_LeakRecordingTable._kTableName} WHERE ${_LeakRecordingTable._kId} = ?',
      [id.toString()],
    );
  }

  Future<void> _deleteAll() async {
    await _ensureInitialized();
    _db.execute('DELETE FROM ${_LeakRecordingTable._kTableName}');
  }

  LeakedInfo _toData(Map<String, dynamic> dataMap) {
    String gcRootType = dataMap[_LeakRecordingTable._kGCRootType];
    String leakPathJson = dataMap[_LeakRecordingTable._kLeakPathJson];
    String timestamp = dataMap[_LeakRecordingTable._kId];
    List dataList = jsonDecode(leakPathJson);
    return LeakedInfo(
      dataList.map((map) => RetainingNode.fromJson(map)).toList(),
      gcRootType,
      timestamp: int.tryParse(timestamp),
    );
  }

  @override
  void add(LeakedInfo info) => _insert(info);

  @override
  void addAll(List<LeakedInfo> list) => _insertAll(list);

  @override
  void clear() => _deleteAll();

  @override
  Future<List<LeakedInfo>> getAll() => _queryAll();

  @override
  void deleteById(int id) => _deleteById(id);
}

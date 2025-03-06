// Copyright (c) 2021, Jiakuo Liu. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:leak_detector/src/leak_data_store.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart';

import 'leak_data.dart';

///database
class _LeakDataBase {
  static Database _openDatabase() {
    final dbPath = join(Directory.current.path, 'leak_recording.db');
    final db = sqlite3.open(dbPath);

    db.execute(
      "CREATE TABLE IF NOT EXISTS ${_LeakRecordingTable._kTableName}("
      "${_LeakRecordingTable._kId} TEXT NOT NULL PRIMARY KEY, "
      "${_LeakRecordingTable._kGCRootType} TEXT, "
      "${_LeakRecordingTable._kLeakPathJson} TEXT)",
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
  final Database _db;

  factory LeakedRecordSQLiteStore() {
    _instance ??= LeakedRecordSQLiteStore._();
    return _instance!;
  }

  LeakedRecordSQLiteStore._() : _db = _LeakDataBase._openDatabase();

  Future<List<LeakedInfo>> _queryAll() async {
    final ResultSet resultSet = _db.select(
      'SELECT * FROM ${_LeakRecordingTable._kTableName}',
    );

    return resultSet.map((row) => _toData(row)).toList();
  }

  Future<void> _insert(LeakedInfo data) async {
    _db.execute(
      'INSERT OR REPLACE INTO ${_LeakRecordingTable._kTableName} '
      '(${_LeakRecordingTable._kId}, ${_LeakRecordingTable._kGCRootType}, ${_LeakRecordingTable._kLeakPathJson}) '
      'VALUES (?, ?, ?)',
      [data.timestamp.toString(), data.gcRootType, data.retainingPathJson],
    );
  }

  Future<void> _insertAll(List<LeakedInfo> data) async {
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
    _db.execute(
      'DELETE FROM ${_LeakRecordingTable._kTableName} WHERE ${_LeakRecordingTable._kId} = ?',
      [id.toString()],
    );
  }

  Future<void> _deleteAll() async {
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

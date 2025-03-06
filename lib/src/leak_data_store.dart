// Copyright (c) 2021, Jiakuo Liu. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:leak_detector/src/leak_data.dart';
import 'package:leak_detector/src/leak_sqlite_store.dart';

///Leaked record store.
abstract class LeakedRecordStore {
  static final LeakedRecordStore _instance = LeakedRecordSQLiteStore();

  factory LeakedRecordStore() => _instance;

  //get all data
  Future<List<LeakedInfo>> getAll();

  //clean the store
  void clear();

  //delete by id
  void deleteById(int id);

  //insert a info list
  void addAll(List<LeakedInfo> list);

  //add one
  void add(LeakedInfo info);
}

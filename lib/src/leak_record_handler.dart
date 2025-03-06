// Copyright (c) 2021, Jiakuo Liu. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:leak_detector/src/leak_data.dart';
import 'package:leak_detector/src/leak_data_store.dart';

///save leak info to database
Function(LeakedInfo) saveLeakedRecord =
    (LeakedInfo leakInfo) => LeakedRecordStore().add(leakInfo);

// // Copyright (c) 2021, Jiakuo Liu. All rights reserved. Use of this source code
// // is governed by a BSD-style license that can be found in the LICENSE file.

library;

import 'package:leak_detector/src/leak_data.dart';
import 'package:leak_detector/src/leak_data_store.dart';

export 'package:leak_detector/src/leak_data.dart';
export 'package:leak_detector/src/leak_detector.dart';
export 'package:leak_detector/src/leak_navigator_observer.dart';
export 'package:leak_detector/src/leak_state_mixin.dart';
export 'package:leak_detector/src/view/leak_preview_page.dart';

///read historical leaked data
Future<List<LeakedInfo>> getLeakedRecording() => LeakedRecordStore().getAll();

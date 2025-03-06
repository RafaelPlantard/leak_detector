package com.ljk.leak_detector_example

import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    init {
        Log.setLogLevel(Log.ERROR)
    }
}

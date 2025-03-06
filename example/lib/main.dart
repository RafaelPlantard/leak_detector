import 'package:flutter/material.dart';
import 'package:leak_detector/leak_detector.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(MyApp());
}

final class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

final class _MyAppState extends State<MyApp> {
  bool _checking = false;

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  final Logger _logger = Logger();
  final LeakDetector _leakDetector = LeakDetector();

  @override
  void initState() {
    super.initState();

    _leakDetector.init(maxRetainingPath: 300);
    _leakDetector.onLeakedStream.listen((LeakedInfo info) {
      // logging to console
      _logger.d('Leak detected!');
      for (var node in info.retainingPath) {
        _logger.d(node);
      }

      //show preview page
      showLeakedInfoPage(_navigatorKey.currentContext!, info);
    });
    _leakDetector.onEventStream.listen((DetectorEvent event) {
      _logger.d('Leak detector event: $event');

      if (event.type == DetectorEventType.startAnalyze) {
        setState(() {
          _checking = true;
        });
      } else if (event.type == DetectorEventType.endAnalyze) {
        setState(() {
          _checking = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      routes: {
        '/p1': (_) => GuaranteedLeakPage(),
      },
      navigatorObservers: [
        //used the LeakNavigatorObserver.
        LeakNavigatorObserver(
          checkLeakDelay: 0,
          shouldCheck: (route) {
            // You can customize which `route` can be detected
            final shouldCheck = route.settings.name != null && route.settings.name != '/';
            return shouldCheck;
          },
        ),
      ],
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: _checking ? Colors.red : null,
          onPressed: () {},
          child: Icon(
            Icons.adjust,
            color: _checking ? Colors.white : null,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(_navigatorKey.currentContext!).pushNamed('/p1');
                },
                style: ButtonStyle(
                  side: WidgetStateProperty.resolveWith(
                    (states) => BorderSide(width: 1, color: Colors.blue),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text('jump(Guaranteed Leak)'),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  getLeakedRecording().then((List<LeakedInfo> infoList) {
                    showLeakedInfoListPage(_navigatorKey.currentContext!, infoList);
                  });
                },
                style: ButtonStyle(
                  side: WidgetStateProperty.resolveWith(
                    (states) => BorderSide(width: 1, color: Colors.blue),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text('read history'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class GuaranteedLeakPage extends StatefulWidget {
  const GuaranteedLeakPage({super.key});

  @override
  State<GuaranteedLeakPage> createState() => _GuaranteedLeakPageState();
}

final class _GuaranteedLeakPageState extends State<GuaranteedLeakPage> {
  // Controllers that won't be disposed
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Callback that holds reference to the widget
  VoidCallback? _callback;

  @override
  void initState() {
    super.initState();

    // Create a callback that holds reference to this widget
    _callback = () {
      debugPrint('Callback executed: ${widget.toString()}');
    };

    // Add the callback to a global list
    GlobalCallbacks.addCallback(_callback!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guaranteed Leak Page'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: 'Text Field (Controller not disposed)',
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: 100,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Item $index'),
                  onTap: _callback, // Use the callback that holds reference
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Pop without disposing anything
          Navigator.of(context).pop();
        },
        child: Icon(Icons.arrow_back),
      ),
    );
  }
}

// Global class to hold callbacks
class GlobalCallbacks {
  static final List<VoidCallback> _callbacks = [];

  static void addCallback(VoidCallback callback) {
    _callbacks.add(callback);
  }

  static void removeCallback(VoidCallback callback) {
    _callbacks.remove(callback);
  }
}

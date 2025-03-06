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

  @override
  void initState() {
    super.initState();

    LeakDetector().init(maxRetainingPath: 300);
    LeakDetector().onLeakedStream.listen((LeakedInfo info) {
      // logging to console
      for (var node in info.retainingPath) {
        _logger.d(node);
      }

      //show preview page
      showLeakedInfoPage(_navigatorKey.currentContext!, info);
    });
    LeakDetector().onEventStream.listen((DetectorEvent event) {
      _logger.d(event);

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
        '/p1': (_) => LeakPage1(),
        '/p2': (_) => LeakPage2(),
        '/p3': (_) => LeakPage3(),
        '/p4': (_) => LeakPage4(),
      },
      navigatorObservers: [
        //used the LeakNavigatorObserver.
        LeakNavigatorObserver(
          checkLeakDelay: 0,
          shouldCheck: (route) {
            //You can customize which `route` can be detected
            return route.settings.name != null && route.settings.name != '/';
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
                  child: Text('jump(Stateless,widget leaked)'),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(_navigatorKey.currentContext!).pushNamed('/p2');
                },
                style: ButtonStyle(
                  side: WidgetStateProperty.resolveWith(
                    (states) => BorderSide(width: 1, color: Colors.blue),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text('jump(Stateful,widget leaked)'),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(_navigatorKey.currentContext!).pushNamed('/p3');
                },
                style: ButtonStyle(
                  side: WidgetStateProperty.resolveWith(
                    (states) => BorderSide(width: 1, color: Colors.blue),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text('jump(Stateful,state leaked)'),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(_navigatorKey.currentContext!).pushNamed('/p4');
                },
                style: ButtonStyle(
                  side: WidgetStateProperty.resolveWith(
                    (states) => BorderSide(width: 1, color: Colors.blue),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text('jump(Stateful,element leaked)'),
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

final class LeakPage1 extends StatelessWidget {
  const LeakPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pop(this);
          },
          style: ButtonStyle(
            side: WidgetStateProperty.resolveWith(
              (states) => BorderSide(width: 1, color: Colors.blue),
            ),
          ),
          child: Text('back'),
        ),
      ),
    );
  }
}

class LeakPage2 extends StatefulWidget {
  const LeakPage2({super.key});

  @override
  State<StatefulWidget> createState() {
    return LeakPageState2();
  }
}

class LeakPageState2 extends State<LeakPage2> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pop(widget);
          },
          style: ButtonStyle(
            side: WidgetStateProperty.resolveWith(
              (states) => BorderSide(width: 1, color: Colors.blue),
            ),
          ),
          child: Text('back'),
        ),
      ),
    );
  }
}

class LeakPage3 extends StatefulWidget {
  const LeakPage3({super.key});

  @override
  State<StatefulWidget> createState() {
    return LeakPageState3();
  }
}

class LeakPageState3 extends State<LeakPage3> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pop(this);
          },
          style: ButtonStyle(
            side: WidgetStateProperty.resolveWith(
              (states) => BorderSide(width: 1, color: Colors.blue),
            ),
          ),
          child: Text('back'),
        ),
      ),
    );
  }
}

class LeakPage4 extends StatefulWidget {
  const LeakPage4({super.key});

  @override
  State<StatefulWidget> createState() {
    return LeakPageState4();
  }
}

final class LeakPageState4 extends State<LeakPage4> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          TextField(
            controller: _controller,
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(context);
            },
            style: ButtonStyle(
              side: WidgetStateProperty.resolveWith(
                (states) => BorderSide(width: 1, color: Colors.blue),
              ),
            ),
            child: Text('back'),
          )
        ],
      ),
    );
  }
}

[English](README.md)

# leak_detector

Flutter 内存泄漏检测工具
> 基于 [leak_detector](https://github.com/liujiakuoyx/leak_detector.git) 由 Liu 开发

## 使用方法

#### 初始化

为了防止底层库 `vm service` 崩溃，请在添加内存泄漏检测对象之前调用：
```dart
LeakDetector().init(maxRetainingPath: 300); //maxRetainingPath 默认为 300
```
启用泄漏检测会降低性能，Full GC 可能会导致页面掉帧。
该插件通过 `assert` 进行初始化，因此在 `release` 模式下构建时无需关闭。

#### 检测

在 `MaterialApp` 的 `navigatorObservers` 中添加 `LeakNavigatorObserver`，它将自动检测页面的 `Widget` 及其对应的 `Element` 对象是否存在内存泄漏。如果页面的 Widget 是 `StatefulWidget`，它还会自动检查其对应的 `State`。

```dart
import 'package:leak_detector/leak_detector.dart';

@override
Widget build(BuildContext context) {
  return MaterialApp(
    navigatorObservers: [
      //使用 LeakNavigatorObserver
      LeakNavigatorObserver(
        shouldCheck: (route) {
          return route.settings.name != null && route.settings.name != '/';
        },
      ),
    ],
  );
}
```

#### 获取泄漏信息

`LeakDetector().onLeakedStream` 可以注册你的监听器，在检测到内存泄漏后通知对象的引用链。
`LeakDetector().onEventStream` 可以监控内部时间通知，如 `start Gc`、`end Gc` 等。

提供了一个引用链的预览页面。你只需要添加以下代码。注意 `Build Context` 必须能够获取到 `NavigatorState`：

```dart
import 'package:leak_detector/leak_detector.dart';

//显示预览页面
LeakDetector().onLeakedStream.listen((LeakedInfo info) {
  //打印到控制台
  info.retainingPath.forEach((node) => print(node));
  //显示预览页面
  showLeakedInfoPage(navigatorKey.currentContext, info);
});
```

预览页面显示：

<img src="https://liujiakuoyx.github.io/images/leak_detector/image2-1.png" width = "280" align=center />

<img src="https://liujiakuoyx.github.io/images/leak_detector/image4.png" width = "280" align=center />

<img src="https://liujiakuoyx.github.io/images/leak_detector/image2-2.png" width = "280" align=center />

它包含引用链节点的类信息、引用的属性信息、属性声明的源代码以及源代码位置（行号：列号）。

#### 获取内存泄漏记录

```dart
import 'package:leak_detector/leak_detector.dart';

getLeakedRecording().then((List<LeakedInfo> infoList) {
  showLeakedInfoListPage(navigatorKey.currentContext, infoList);
});
```

<img src="https://liujiakuoyx.github.io/images/leak_detector/image2-3.png" width = "280" align=center />

#### *在真机上无法连接到 `vm_service`

VM 服务通过 Dart 开发服务（DDS）提供扩展功能集，该服务将本文档中描述的所有核心 VM 服务 RPC 转发到真正的 VM 服务。

因此，当我们连接电脑运行时，电脑上的 `DDS` 会先连接到我们移动端的 `vm_service`，导致我们的 `leak_detector` 插件无法再次连接到 `vm_service`。

有两种解决方案：

- 在 `run` 完成后，断开与电脑的连接，然后最好重启应用。

  如果测试包已经安装在手机上，则不存在上述问题，因此此方法适合测试人员使用。

- 在 `flutter run` 后添加 `--disable-dds` 参数来关闭 `DDS`。经过测试，这不会影响调试

  可以在 `Android Studio` 中按如下方式配置。

在 [Pull Request #80900](https://github.com/flutter/flutter/pull/80900) 合并后，`--disable-dds` 被重命名为 `--no-dds`

![image](https://liujiakuoyx.github.io/images/leak_detector/peizhi1.png)

![image](https://liujiakuoyx.github.io/images/leak_detector/peizhi2.png) 
import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:vm_service/utils.dart';
import 'package:vm_service/vm_service_io.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final info = await Service.getInfo();
  final serverUri = info.serverUri;

  if (serverUri != null) {
    final vmService = await vmServiceConnectUri(convertToWebSocketUrl(serviceProtocolUrl: serverUri).toString());
    final vm = await vmService.getVM();
    final version = vm.version;

    expect(version, isNotNull);
  }
}

import 'package:flutter/foundation.dart';

class Constant {
  static const String appEnv = String.fromEnvironment('APP_ENV', defaultValue: kReleaseMode ? 'online' : 'debug');

  static const Map<String, dynamic> envConfigs = {
    'debug': {
      'http_base_url': 'http://127.0.0.1:8001',
      'ws_base_url': 'ws://127.0.0.1:8001',
      'seckey': '1a229752c483f57994efb9a0e64d0139',
    },
    'online': {
      'http_base_url': 'http://127.0.0.1:8001',
      'ws_base_url': 'ws://127.0.0.1:8001',
      'seckey': '1a229752c483f57994efb9a0e64d0139',
    },
  };
  static Map<String, dynamic> envConfig = envConfigs[appEnv];
  static String httpBaseUrl = envConfigs[appEnv]['httpBaseUrl'];
  static String wsBaseUrl = envConfigs[appEnv]['wsBaseUrl'];

  static const bool ISDEBUG = !bool.fromEnvironment("dart.vm.product");

}

class AppConfig {
  static const String appId = 'org.benstone.qnc_app';
  static const String appName = 'qnc_app';
  static const String version = '0.0.1';
  static const bool isDebug = kDebugMode;
}

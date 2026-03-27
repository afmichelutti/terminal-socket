import 'package:shop_blink/services/enum.dart';

class EnvironmentConfig {
  static Environments? environmentBuild;

  static String urlsConfig({bool socket = true}) {
    switch (environmentBuild) {
      case Environments.developer:
        return (socket)
            ? 'https://visual.tigoo.com.br:9001/socket'
            : 'http://192.168.68.105:3334/api';
      case Environments.production:
        return (socket)
            ? 'https://visual.tigoo.com.br:9001/socket'
            : 'http://138.204.224.235:3334/api';
      default:
        return 'http://138.204.224.235:3334/api';
    }
  }
}

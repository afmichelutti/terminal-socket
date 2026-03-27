enum Environments { developer, test, production }

class EnvironmentConfig {
  static Environments? environmentBuild;

  static String urlsConfig() {
    switch (environmentBuild) {
      case Environments.developer:
        //return 'http://localhost:8081/api';
        return 'https://visual.tigoo.com.br:9001/socket';
      case Environments.test:
        return 'http://localhost:8081/api';
      case Environments.production:
        return 'https://flutter-web-admin-afmichelutti.herokuapp.com/api';
      default:
        return 'http://localhost:8081/api';
    }
  }
}

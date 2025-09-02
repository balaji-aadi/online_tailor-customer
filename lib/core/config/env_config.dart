class EnvConfig {
  static const String PROD_URL = "https://groomer.nablean.com/api/v1/";
  static const String DEV_URL = "http://192.168.1.9:5008/api/v1/";
  // // static const String DEV_URL = "http://localhost:5008/api/v1/";
  // static const String DEV_URL = "https://groomer.nablean.com/api/v1/";

  static String get baseUrl {
    const bool isDevelopment = bool.fromEnvironment('DEV_MODE', defaultValue: true);
    return isDevelopment ? DEV_URL : PROD_URL;
  }
}

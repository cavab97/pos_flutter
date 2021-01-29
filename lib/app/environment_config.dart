class Config {
  static const CURRENT_ENVIRONMENT = "";
  //backend
  static const SERVER_URL = "SERVER_URL";
  static const SERVER_ACCESS_TOKEN = "SERVER_ACCESS_TOKEN";

  static Map<String, dynamic> localConstants = {
    CURRENT_ENVIRONMENT: "local",
    SERVER_URL: "http://192.168.68.109/laravel-admin-panel/api/v1/en/",
  };

  static Map<String, dynamic> developmentConstants = {
    CURRENT_ENVIRONMENT: "development",
    SERVER_URL: "https://development.mcnpos.com.my/api/v1/en/",
  };

  static Map<String, dynamic> stagingConstants = {
    CURRENT_ENVIRONMENT: "staging",
    SERVER_URL: "https://staging.mcnpos.com.my/api/v1/en/",
  };

  static Map<String, dynamic> productionConstants = {
    CURRENT_ENVIRONMENT: "production",
    SERVER_URL: "https://mcnpos.com.my/api/v1/en/",
  };
}

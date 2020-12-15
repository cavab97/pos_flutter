class Config {
  static const CURRENT_ENVIRONMENT = "null";
  static const SERVER_URL = "SERVER_URL";
  static const SERVER_ACCESS_TOKEN = "SERVER_ACCESS_TOKEN";

  static Map<String, dynamic> localConstants = {
    CURRENT_ENVIRONMENT: "local",
    SERVER_URL: "http://localhost/pos/api/v1/en/",
    //SERVER_ACCESS_TOKEN: "lkriekxqo1w04rsxugfvijwcya3lth59"
  };

  static Map<String, dynamic> developmentConstants = {
    CURRENT_ENVIRONMENT: "development",
    SERVER_URL: "https://development.mcnpos.com.my/api/v1/en/",
    //SERVER_ACCESS_TOKEN: "lkriekxqo1w04rsxugfvijwcya3lth59"
  };

  static Map<String, dynamic> stagingConstants = {
    CURRENT_ENVIRONMENT: "staging",
    SERVER_URL: "https://staging.mcnpos.com.my/api/v1/en/",
    //SERVER_ACCESS_TOKEN: "lkriekxqo1w04rsxugfvijwcya3lth59"
  };

  static Map<String, dynamic> productionConstants = {
    CURRENT_ENVIRONMENT: "production",
    SERVER_URL: "https://mcnpos.com.my/api/v1/en/",
    //SERVER_ACCESS_TOKEN: "lkriekxqo1w04rsxugfvijwcya3lth59"
  };
}

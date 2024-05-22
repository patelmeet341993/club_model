class ElasticSearchCredentials {
  static const String _elasticUrl = "https://sportiwe-dev-770218.es.asia-south1.gcp.elastic-cloud.com:9243/";
  static const String _elasticBasicAuth = "Basic ZWxhc3RpYzozaVdWQ1prY3NoQVJod0NpZGxNSVRPNmY=";

  static String geBaseUrl() => _elasticUrl;

  static String getBasicAuth() => _elasticBasicAuth;
}

class CloudinaryCredentials {
  static const String _apiKey = "171586126114162";
  static const String _apiSecret = "edWUeme4_p4kJD1YMBCAFm9XRE0";
  static const String _cloudName = "dfjdlhxuy";

  static String getCloudinaryApiKey() => _apiKey;

  static String getCloudinaryApiSecret() => _apiSecret;

  static String getCloudinaryCloudName() => _cloudName;
}

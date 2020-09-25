import 'dart:io';

class HeadersUtil {

  static Map<String, String> getHeaders() {
    return {
      HttpHeaders.contentTypeHeader: "application/json"
    };
  }

  static Map<String, String> getAuthorizedHeaders(String token) {
    return {
      HttpHeaders.contentTypeHeader: "application/json",
      'Authorization': 'Bearer $token'
    };
  }
}
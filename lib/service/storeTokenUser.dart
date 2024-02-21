// ignore: 
// ignore_for_file: file_names, avoid_web_libraries_in_flutter

import 'dart:html' as html;

class WebSessionStorageService {
  static void storeToken(String token) {
    html.window.sessionStorage['auth_token'] = token;
  }

  static String? retrieveToken() {
    return html.window.sessionStorage['auth_token'];
  }

  static void clearToken() {
    html.window.sessionStorage.remove('auth_token');
  }
}
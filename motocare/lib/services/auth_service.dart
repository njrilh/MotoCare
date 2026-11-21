
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import 'api_service.dart';

class AuthService {
  static const String tokenKey = 'access_token';
  static const String roleKey = 'user_role';
  static const String userKey = 'user_data';

  // REGISTER
  static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
    String? noHp,
  }) async {
    return await ApiService.post(
      ApiConfig.register,
      {
        'nama': nama,
        'email': email,
        'password': password,
        'no_hp': noHp,
      },
    );
  }

  // LOGIN
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await ApiService.post(
      ApiConfig.login,
      {
        'email': email,
        'password': password,
      },
    );

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(tokenKey, result['access_token']);
    await prefs.setString(roleKey, result['user']['role']);
    await prefs.setString(
      userKey,
      jsonEncode(result['user']),
    );

    return result;
  }

  // AMBIL TOKEN
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // AMBIL ROLE
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(roleKey);
  }

  // AMBIL DATA USER
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(userKey);

    if (data == null) return null;

    return jsonDecode(data) as Map<String, dynamic>;
  }

  // LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(tokenKey);
    await prefs.remove(roleKey);
    await prefs.remove(userKey);
  }
}

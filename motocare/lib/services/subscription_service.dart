
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/subscription_model.dart';
import 'auth_service.dart';

class SubscriptionService {
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Membuat langganan
  static Future<void> createSubscription(String packageName) async {
    final response = await http.post(
      Uri.parse(ApiConfig.subscriptions),
      headers: await _headers(),
      body: jsonEncode({
        'nama_paket': packageName,
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      final result = jsonDecode(response.body);
      throw Exception(
        result['detail'] ?? 'Gagal membuat langganan',
      );
    }
  }

  // Mengambil langganan terbaru
  static Future<Subscription?> getMySubscription() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.subscriptions}me'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      final result = jsonDecode(response.body);
      throw Exception(
        result['detail'] ?? 'Gagal mengambil langganan',
      );
    }

    if (response.body == 'null') {
      return null;
    }

    final data = jsonDecode(response.body);

    if (data == null) return null;

    return Subscription.fromJson(data);
  }

  // Mengambil riwayat langganan
  static Future<List<Subscription>> getHistory() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.subscriptions}history'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      final result = jsonDecode(response.body);
      throw Exception(
        result['detail'] ?? 'Gagal mengambil riwayat',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map((item) => Subscription.fromJson(item))
        .toList();
  }
}

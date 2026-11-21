
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/booking_model.dart';
import 'auth_service.dart';

class BookingService {
  // Mengambil token login
  static Future<String?> _getToken() async {
    return await AuthService.getToken();
  }

  // Header autentikasi
  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Mengambil semua booking milik user
  static Future<List<Booking>> getBookings() async {
    final response = await http.get(
      Uri.parse(ApiConfig.bookings),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data booking');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map((item) => Booking.fromJson(item))
        .toList();
  }

  // Membuat booking baru
  static Future<void> createBooking(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse(ApiConfig.bookings),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      final result = jsonDecode(response.body);
      throw Exception(
        result['detail'] ?? 'Gagal membuat booking',
      );
    }
  }

  // Mengedit booking
  static Future<void> updateBooking(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.bookings}$id'),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      final result = jsonDecode(response.body);
      throw Exception(
        result['detail'] ?? 'Gagal mengubah booking',
      );
    }
  }

  // Membatalkan booking
  static Future<void> cancelBooking(int id) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.bookings}$id/cancel'),
      headers: await _headers(),
      body: jsonEncode({}),
    );

    if (response.statusCode != 200) {
      final result = jsonDecode(response.body);
      throw Exception(
        result['detail'] ?? 'Gagal membatalkan booking',
      );
    }
  }
}

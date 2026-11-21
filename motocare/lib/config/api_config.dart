
class ApiConfig {
  // Gunakan IP laptop jika menjalankan Flutter di HP fisik.
  static const String baseUrl = 'http://192.168.1.124:8000';

  static const String login = '$baseUrl/api/auth/login';
  static const String register = '$baseUrl/api/auth/register';
  static const String me = '$baseUrl/api/auth/me';

  static const String vehicles = '$baseUrl/api/vehicles/';
  static const String bookings = '$baseUrl/api/bookings/';
  static const String subscriptions = '$baseUrl/api/subscriptions/';
}

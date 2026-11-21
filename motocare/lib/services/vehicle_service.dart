
import '../config/api_config.dart';
import '../models/vehicle_model.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VehicleService {
  // GET semua kendaraan
  static Future<List<Vehicle>> getVehicles() async {
  final token = await AuthService.getToken();

  final response = await http.get(
    Uri.parse(ApiConfig.vehicles),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Gagal mengambil kendaraan');
  }

  final List<dynamic> data = jsonDecode(response.body);

  return data.map((item) => Vehicle.fromJson(item)).toList();
}

  // CREATE kendaraan
  static Future<void> createVehicle({
    required String merk,
    required String model,
    required String nomorPolisi,
    int? tahun,
  }) async {
    final token = await AuthService.getToken();

    await ApiService.post(
      ApiConfig.vehicles,
      {
        'merk': merk,
        'model': model,
        'nomor_polisi': nomorPolisi,
        'tahun': tahun,
      },
      token: token,
    );
  }

  // UPDATE kendaraan
  static Future<void> updateVehicle({
    required int id,
    required String merk,
    required String model,
    required String nomorPolisi,
    int? tahun,
  }) async {
    final token = await AuthService.getToken();

    await ApiService.put(
      '${ApiConfig.vehicles}$id',
      {
        'merk': merk,
        'model': model,
        'nomor_polisi': nomorPolisi,
        'tahun': tahun,
      },
      token: token,
    );
  }

  // DELETE kendaraan
  static Future<void> deleteVehicle(int id) async {
    final token = await AuthService.getToken();

    await ApiService.delete(
      '${ApiConfig.vehicles}$id',
      token: token,
    );
  }
}

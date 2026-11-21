
class Vehicle {
  final int idVehicle;
  final int idUser;
  final String merk;
  final String model;
  final String nomorPolisi;
  final int? tahun;
  final int totalKm;
  final int lastServiceKm;

  Vehicle({
    required this.idVehicle,
    required this.idUser,
    required this.merk,
    required this.model,
    required this.nomorPolisi,
    this.tahun,
    required this.totalKm,
    required this.lastServiceKm,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      idVehicle: json['id_vehicle'],
      idUser: json['id_user'],
      merk: json['merk'],
      model: json['model'],
      nomorPolisi: json['nomor_polisi'],
      tahun: json['tahun'],
      totalKm: json['total_km'] ?? 0,
      lastServiceKm: json['last_service_km'] ?? 0,
    );
  }
}

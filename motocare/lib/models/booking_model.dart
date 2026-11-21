
class Booking {
  final int idBooking;
  final int idUser;
  final int idVehicle;
  final String jenisServis;
  final String? keluhan;
  final DateTime tanggalBooking;
  final int odometerKm;
  final String? namaBengkel;
  final String? alamatBengkel;
  final double biayaEstimasi;
  final double biayaFinal;
  final String status;
  final DateTime? completedAt;

  Booking({
    required this.idBooking,
    required this.idUser,
    required this.idVehicle,
    required this.jenisServis,
    this.keluhan,
    required this.tanggalBooking,
    required this.odometerKm,
    this.namaBengkel,
    this.alamatBengkel,
    required this.biayaEstimasi,
    required this.biayaFinal,
    required this.status,
    this.completedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      idBooking: json['id_booking'],
      idUser: json['id_user'],
      idVehicle: json['id_vehicle'],
      jenisServis: json['jenis_servis'],
      keluhan: json['keluhan'],
      tanggalBooking: DateTime.parse(json['tanggal_booking']),
      odometerKm: json['odometer_km'],
      namaBengkel: json['nama_bengkel'],
      alamatBengkel: json['alamat_bengkel'],
      biayaEstimasi: double.parse(
        json['biaya_estimasi'].toString(),
      ),
      biayaFinal: double.parse(
        json['biaya_final'].toString(),
      ),
      status: json['status'],
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at']),
    );
  }
}

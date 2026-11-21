
class Subscription {
  final int idSubscription;
  final int idUser;
  final String namaPaket;
  final double harga;
  final DateTime? tanggalMulai;
  final DateTime? tanggalAkhir;
  final String status;
  final String paymentStatus;

  Subscription({
    required this.idSubscription,
    required this.idUser,
    required this.namaPaket,
    required this.harga,
    this.tanggalMulai,
    this.tanggalAkhir,
    required this.status,
    required this.paymentStatus,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      idSubscription: json['id_subscription'],
      idUser: json['id_user'],
      namaPaket: json['nama_paket'],
      harga: double.parse(json['harga'].toString()),
      tanggalMulai: json['tanggal_mulai'] == null
          ? null
          : DateTime.parse(json['tanggal_mulai']),
      tanggalAkhir: json['tanggal_akhir'] == null
          ? null
          : DateTime.parse(json['tanggal_akhir']),
      status: json['status'],
      paymentStatus: json['payment_status'],
    );
  }
}


import 'package:flutter/material.dart';

import '../models/subscription_model.dart';
import '../services/subscription_service.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  Subscription? subscription;
  List<Subscription> history = [];

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final current = await SubscriptionService.getMySubscription();
      final records = await SubscriptionService.getHistory();

      if (!mounted) return;

      setState(() {
        subscription = current;
        history = records;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  String rupiah(double value) {
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'expired':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String getStatusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'pending':
        return 'Menunggu Verifikasi';
      case 'expired':
        return 'Kedaluwarsa';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Future<void> choosePackage(
    String packageName,
    double price,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Langganan'),
        content: Text(
          'Pilih $packageName dengan harga ${rupiah(price)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      isSaving = true;
    });

    try {
      await SubscriptionService.createSubscription(packageName);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Langganan berhasil dibuat. Menunggu verifikasi admin.',
          ),
        ),
      );

      await loadData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Widget packageCard({
    required String name,
    required String duration,
    required double price,
    required List<String> benefits,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              rupiah(price),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(duration),
            const Divider(height: 24),
            ...benefits.map(
              (benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(benefit)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () => choosePackage(name, price),
                child: const Text('Pilih Paket'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget currentSubscription() {
    if (subscription == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Kamu belum memiliki langganan.'),
        ),
      );
    }

    final item = subscription!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.namaPaket,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Chip(
              label: Text(
                getStatusLabel(item.status),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: getStatusColor(item.status),
            ),
            Text('Harga: ${rupiah(item.harga)}'),
            Text('Pembayaran: ${item.paymentStatus}'),
            Text(
              'Mulai: ${item.tanggalMulai?.toString().split(' ').first ?? '-'}',
            ),
            Text(
              'Berakhir: ${item.tanggalAkhir?.toString().split(' ').first ?? '-'}',
            ),
          ],
        ),
      ),
    );
  }

  Widget historyCard(Subscription item) {
    return Card(
      child: ListTile(
        title: Text(item.namaPaket),
        subtitle: Text(
          '${rupiah(item.harga)} • ${item.paymentStatus}',
        ),
        trailing: Text(
          getStatusLabel(item.status),
          style: TextStyle(
            color: getStatusColor(item.status),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bengkel Care'),
        actions: [
          IconButton(
            onPressed: loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Langganan Saya',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  currentSubscription(),
                  const SizedBox(height: 24),
                  const Text(
                    'Pilih Paket Bengkel Care',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  packageCard(
                    name: 'Bengkel Care Bulanan',
                    duration: 'Berlaku selama 30 hari',
                    price: 50000,
                    benefits: const [
                      'Keanggotaan Bengkel Care',
                      'Prioritas layanan booking',
                      'Riwayat servis kendaraan',
                    ],
                  ),
                  packageCard(
                    name: 'Bengkel Care Tahunan',
                    duration: 'Berlaku selama 365 hari',
                    price: 500000,
                    benefits: const [
                      'Keanggotaan selama satu tahun',
                      'Prioritas layanan booking',
                      'Riwayat servis kendaraan',
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Riwayat Langganan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (history.isEmpty)
                    const Text('Belum ada riwayat langganan.')
                  else
                    ...history.map(historyCard),
                ],
              ),
            ),
    );
  }
}

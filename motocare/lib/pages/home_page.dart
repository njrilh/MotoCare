
import 'package:flutter/material.dart';
import 'package:motocare/pages/booking_page.dart';
import 'package:motocare/pages/subscription_page.dart';

import '../services/auth_service.dart';
import 'login_page.dart';
import 'vehicle_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MotorCare'),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService.logout();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat Datang di MotorCare',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kelola kendaraan dan kebutuhan servis motormu.',
            ),
            const SizedBox(height: 24),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.motorcycle,
                  size: 35,
                  color: Colors.green,
                ),
                title: const Text('Kendaraan Saya'),
                subtitle: const Text(
                  'Kelola data kendaraan',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VehiclePage(),
                    ),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Booking Servis'),
                subtitle: const Text('Buat dan lihat riwayat servis'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookingPage(),
                    ),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.workspace_premium),
                title: const Text('Bengkel Care'),
                subtitle: const Text('Kelola keanggotaan dan langganan'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const MotorCareApp());
}

class MotorCareApp extends StatelessWidget {
  const MotorCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MotorCare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A5C30),
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

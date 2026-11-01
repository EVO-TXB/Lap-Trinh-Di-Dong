import 'package:flutter/material.dart';
import 'features/cong_viec/screens/lich_tuan_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TimassApp());
}

class TimassApp extends StatelessWidget {
  const TimassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timass - Quản lý Lịch trình & Thời gian',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C987A),
          primary: const Color(0xFF6C987A),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF1EE),
      ),
      home: const LichTuanScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // পারমিশন চাওয়া
  await [
    Permission.storage,
    Permission.accessMediaLocation,
    Permission.manageExternalStorage,
  ].request();

  if (kDebugMode) print('App started');

  runApp(const MkShareApp());
}

class MkShareApp extends StatelessWidget {
  const MkShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mk Share',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00FF41), // নিয়ন গ্রিন
        scaffoldBackgroundColor: const Color(0xFF0A0A0A), // কালো ব্যাকগ্রাউন্ড
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

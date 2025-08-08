import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:catalyze/auth_gate.dart';
import 'package:catalyze/constants/app_theme.dart'; // 新しいテーマをインポート
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catalyze',
      // 新しいテーマを適用
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // OSの設定に応じてテーマを自動で切り替え

      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:study_ai_assistant/main_scaffold.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Flutterアプリのウィジェット（UI部品）を動かすための準備
  WidgetsFlutterBinding.ensureInitialized();

  // Firebaseを初期化します
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
      title: 'Study AI Assistant',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'NotoSansJP',
      ),
      home: const MainScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

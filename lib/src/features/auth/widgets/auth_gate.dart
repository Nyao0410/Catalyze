import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:catalyze/src/features/home/widgets/main_scaffold.dart';
import 'package:catalyze/src/features/auth/screens/login_screen.dart'; // AuthScreenの代わりにLoginScreenをインポート
import 'package:catalyze/src/features/auth/services/auth_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // 接続状態をチェック
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ユーザーがログインしているかチェック
        if (snapshot.hasData) {
          return const MainScaffold();
        } else {
          return const LoginScreen(); // AuthScreenの代わりにLoginScreenを表示
        }
      },
    );
  }
}
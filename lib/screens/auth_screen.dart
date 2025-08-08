import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_ai_assistant/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true; // true: ログイン, false: サインアップ

  void _submitAuthForm() async {
    try {
      if (_isLogin) {
        await _authService.logIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await _authService.signUp(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'そのメールアドレスのユーザーは見つかりません。';
      } else if (e.code == 'wrong-password') {
        message = 'パスワードが間違っています。';
      } else if (e.code == 'email-already-in-use') {
        message = 'このメールアドレスは既に使用されています。';
      } else if (e.code == 'weak-password') {
        message = 'パスワードが弱すぎます。';
      } else {
        message = '認証エラーが発生しました: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('予期せぬエラーが発生しました: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'ログイン' : 'サインアップ'),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'メールアドレス'),
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'パスワード'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitAuthForm,
                  child: Text(_isLogin ? 'ログイン' : 'サインアップ'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(_isLogin ? 'アカウントを作成する' : 'すでにアカウントをお持ちですか？'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

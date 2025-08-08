import 'package:flutter/material.dart';
import 'package:study_ai_assistant/constants/app_sizes.dart';
import 'package:study_ai_assistant/screens/signup_screen.dart';
import 'package:study_ai_assistant/services/auth_service.dart';
import 'package:study_ai_assistant/widgets/common/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _authService.logIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ログインに失敗しました: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(p24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('ログイン', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                gapH24,
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'メールアドレス'),
                  validator: (value) => value!.isEmpty ? '入力してください' : null,
                ),
                gapH8,
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'パスワード'),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? '入力してください' : null,
                ),
                gapH24,
                PrimaryButton(
                  onPressed: _login,
                  text: 'ログイン',
                  isLoading: _isLoading,
                ),
                TextButton(
                  onPressed: _isLoading ? null : () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen()));
                  },
                  child: const Text('新規登録はこちら'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

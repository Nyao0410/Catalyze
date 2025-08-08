import 'package:flutter/material.dart';
import 'package:catalyze/constants/app_sizes.dart';
import 'package:catalyze/screens/signup_screen.dart';
import 'package:catalyze/services/auth_service.dart';
import 'package:catalyze/widgets/app_logo.dart';
import 'package:catalyze/widgets/error_display.dart';
import 'package:catalyze/widgets/common/loading_indicator.dart';
import 'package:catalyze/widgets/common/primary_button.dart';
import 'package:catalyze/widgets/secondary_button.dart'; // 変更点1: インポートを追加

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // ここを修正
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  // 変更点2: エラーメッセージを管理する状態変数を追加
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) { // バリデーションが失敗したら処理を中断
      return;
    }

    setState(() {
      _isLoading = true;
      // 変更点3: 試行時に過去のエラーメッセージをクリア
      _errorMessage = null;
    });

    try {
      await _authService.logIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // 成功した場合、AuthWrapperが自動的にホーム画面へ遷移させる
    } catch (e) {
      // 変更点4: catch節でエラーメッセージをsetState
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(p24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppLogo(),
                const SizedBox(height: p32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'メールアドレス'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty ? '入力してください' : null,
                ),
                const SizedBox(height: p16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'パスワード'),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? '入力してください' : null,
                ),
                const SizedBox(height: p24),
                if (_errorMessage != null) ...[
                  ErrorDisplay(errorMessage: _errorMessage!),
                  const SizedBox(height: p24),
                ],
                if (_isLoading)
                  const LoadingIndicator()
                else
                  PrimaryButton(
                    onPressed: _login,
                    text: 'ログイン',
                  ),
                const SizedBox(height: p16),
                SecondaryButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen()));
                  },
                  text: 'アカウント作成はこちら',
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

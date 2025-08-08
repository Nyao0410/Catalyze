import 'package:flutter/material.dart';
import 'package:catalyze/src/constants/app_sizes.dart';
import 'package:catalyze/src/features/auth/services/auth_service.dart';
import 'package:catalyze/src/common_widgets/app_logo.dart';
import 'package:catalyze/src/common_widgets/error_display.dart';
import 'package:catalyze/src/common_widgets/loading_indicator.dart';
import 'package:catalyze/src/common_widgets/primary_button.dart';
import 'package:catalyze/src/common_widgets/secondary_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  // 変更点2: エラーメッセージを管理する状態変数を追加
  String? _errorMessage;

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      // 変更点3: サインアップ試行時に過去のエラーメッセージをクリア
      _errorMessage = null;
    });

    try {
      await _authService.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // 成功した場合、次の画面に遷移する（AuthWrapperが自動的に処理）
    } catch (e) {
      // 変更点4: catch節でエラーメッセージをsetStateする処理を追加
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppLogo(),
              const SizedBox(height: p32),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'メールアドレス'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: p16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'パスワード'),
                obscureText: true,
              ),
              const SizedBox(height: p24),
              // 変更点5: エラーメッセージがある場合にErrorDisplayを表示
              if (_errorMessage != null) ...[
                ErrorDisplay(errorMessage: _errorMessage!),
                const SizedBox(height: p24),
              ],
              if (_isLoading)
                const LoadingIndicator()
              else
                PrimaryButton(
                  onPressed: _signUp,
                  text: 'アカウントを作成',
                ),
              const SizedBox(height: p16),
              // 変更点6: ログイン画面への遷移をSecondaryButtonに変更
              SecondaryButton(
                onPressed: () => Navigator.pop(context),
                text: 'ログインはこちら',
              )
            ],
          ),
        ),
      ),
    );
  }
}
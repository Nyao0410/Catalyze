import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Firebase Authenticationのインスタンスを取得
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- 認証状態の監視 ---
  // ユーザーがログインしているか、ログアウトしているか、状態の変化をリアルタイムで監視します。
  // これがアプリの認証状態のすべての基準点となります。
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- 現在のユーザー情報の取得 ---
  // 現在ログインしているユーザーの情報を取得します。
  User? get currentUser => _auth.currentUser;

  // --- サインアップ（新規登録） ---
  // メールアドレスとパスワードで新しいユーザーを作成します。
  Future<UserCredential?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // エラーハンドリング（例: パスワードが弱い、メールアドレスが既に使用されているなど）
      // UI側でこのエラーをキャッチして、適切なメッセージを表示します。
      print('SignUp Error: ${e.message}');
      rethrow; // エラーを呼び出し元に再スローする
    }
  }

  // --- ログイン ---
  // 既存のユーザーがメールアドレスとパスワードでログインします。
  Future<UserCredential?> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // エラーハンドリング（例: ユーザーが見つからない、パスワードが違うなど）
      print('LogIn Error: ${e.message}');
      rethrow;
    }
  }

  // --- ログアウト ---
  // 現在のユーザーをログアウトさせます。
  Future<void> logOut() async {
    await _auth.signOut();
  }
}

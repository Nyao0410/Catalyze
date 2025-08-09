# プロジェクト構造分析レポート

## 全体アーキテクチャ

このFlutterプロジェクトは、**フィーチャーベース**のディレクトリ構造と**サービス層アーキテクチャ**を組み合わせた、現代的でスケーラブルな設計を採用しています。

- **アーキテクチャの基盤**:
  - **Firebase**をバックエンドとして全面的に活用しており、特に**Firebase Authentication**（認証）と**Cloud Firestore**（データベース）が中心的な役割を担っています。
  - UIとビジネスロジックの分離が意識されており、各フィーチャーディレクトリ内に`screens`（UI）、`services`（ロジック）、`models`（データ構造）などが配置されています。これにより、関心事の分離が図られ、コードの保守性と再利用性が向上しています。

- **状態管理**:
  - `AuthGate`ウィジェットでの`StreamBuilder`の使用から、認証状態の管理には**Streamベースのアプローチ**が採用されていることがわかります。`AuthService`が提供する`authStateChanges`ストリームをリッスンし、ログイン状態に応じてUIをリアクティブに切り替えています。
  - 他のフィーチャーにおける状態管理については、ファイルだけでは特定できませんが、シンプルなものでは`StatefulWidget`が、より複雑なものではProviderやRiverpodなどの外部ライブラリが利用されている可能性があります。

- **UI構成**:
  - `common_widgets`ディレクトリの存在は、アプリケーション全体で再利用可能な共通UIコンポーネント（ボタン、ロゴなど）を抽象化し、一貫性のあるUIを効率的に構築しようとする意図を示しています。
  - `constants`ディレクトリにテーマ（`AppTheme`）や文字列（`AppStrings`）をまとめることで、デザインの一貫性を保ち、多言語対応やテーマ変更を容易にしています。

## ディレクトリ構造と各責務

`lib`ディレクトリは、アプリケーションのコアロジックを格納する中心的な場所です。その内部は`src`ディレクトリに集約され、フィーチャーごとに整理されています。

- **`lib/`**:
  - `main.dart`: アプリケーションのエントリーポイント。Firebaseの初期化、`MaterialApp`の定義、テーマの設定、そして認証状態に応じて表示を切り替える`AuthGate`の呼び出しを行います。
  - `firebase_options.dart`: Firebaseプロジェクトの設定ファイル（自動生成）。

- **`lib/src/`**:
  - **`common_widgets/`**: アプリケーション全体で再利用される共通UIコンポーネントを格納します。（例: `PrimaryButton`, `AppLogo`）
  - **`constants/`**: アプリケーション全体で使用される定数を定義します。（例: `AppSizes`, `AppStrings`, `AppTheme`）
  - **`features/`**: アプリケーションの各機能を独立したモジュールとして管理します。この構造は、機能追加や修正が他の部分に影響を与えにくい、スケーラブルな開発を可能にします。
    - **`auth/`**: 認証機能（サインアップ、ログイン、ログアウト）に関連するファイルを格納します。
      - `screens/`: ログイン画面や新規登録画面などのUI。
      - `services/`: `AuthService`クラス。Firebase Authenticationとのやり取りを抽象化し、認証ロジックをカプセル化します。
      - `widgets/`: `AuthGate`など、認証状態に応じてUIを制御するウィジェット。
    - **`plan/`**: 学習計画の作成、表示、管理機能に関連するファイルを格納します。
      - `models/`: `StudyPlan`など、Firestoreで扱うデータ構造を定義するクラス。
      - `services/`: `PlanService`クラス。Firestoreとのやり取り（CRUD操作）を担当し、学習計画に関するビジネスロジックを実装します。
      - `screens/`, `widgets/`: 計画の作成画面や一覧表示カードなどのUIコンポーネント。
    - **`home/`**, **`analysis/`**, **`evaluation/`**, **`settings/`**: 他の主要な機能も同様に、それぞれの責務に応じたサブディレクトリ（`screens`, `widgets`, `models`, `services`など）を持っています。

## 認証フロー

このアプリケーションの認証フローは、`AuthService`と`AuthGate`ウィジェットによって非常に堅牢かつ効率的に実装されています。

1.  **アプリ起動**:
    - `main.dart`が実行され、Firebaseが初期化されます。
    - `MyApp`ウィジェットの`home`として`AuthGate`が設定されます。

2.  **認証状態の監視**:
    - `AuthGate`は`AuthService`の`authStateChanges`ストリームを`StreamBuilder`でリッスンします。このストリームは、Firebase Authenticationのユーザーのログイン状態が変化するたびに新しい値を通知します。

3.  **UIの分岐**:
    - **接続待ち**: ストリームが最初のデータを待っている間は、`CircularProgressIndicator`（ローディング画面）が表示されます。
    - **ログイン済み**: `snapshot.hasData`が`true`の場合（つまり、`User`オブジェクトが存在する場合）、ユーザーは認証済みと判断され、アプリケーションのメイン画面である`MainScaffold`が表示されます。
    - **未ログイン**: `snapshot.hasData`が`false`の場合（`User`オブジェクトが`null`の場合）、ユーザーは未認証と判断され、`LoginScreen`が表示されます。

4.  **ログイン/サインアップ処理**:
    - `LoginScreen`や`SignupScreen`でユーザーが情報を入力し操作を行うと、UIは`AuthService`の`logIn()`や`signUp()`メソッドを呼び出します。
    - `AuthService`がFirebase Authenticationとの通信を行い、成功すると`authStateChanges`ストリームが新しい`User`オブジェクトを通知します。
    - `AuthGate`の`StreamBuilder`がこの変化を検知し、UIを自動的に`MainScaffold`に更新します。

5.  **ログアウト処理**:
    - ユーザーがログアウト操作を行うと、`AuthService`の`logOut()`メソッドが呼び出されます。
    - これにより`authStateChanges`ストリームが`null`を通知し、`AuthGate`はUIを`LoginScreen`に切り替えます。

このアーキテクチャにより、認証ロジックはUIから完全に分離され、アプリのどの部分からも`AuthService`を通じて一貫した方法で認証状態を取得・変更できます。また、`AuthGate`が認証状態の関心事を一手に引き受けることで、各画面は自身の責務に集中できる設計となっています。

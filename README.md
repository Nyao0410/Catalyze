# Study AI Assistant

**あなただけのパーソナライズAI学習コーチ**


## 概要

**Study AI Assistant**は、日々の学習を記録し、そのデータを基に最適な学習計画を動的に提案する、次世代の学習管理アプリです。

単にタスクを管理するだけでなく、あなたの学習ペース、集中度、各タスクの難易度を分析し、「いつまでに、何を、どれくらいやれば良いか」を自動で調整します。まるで専属のAIコーチが、あなたの目標達成まで伴走してくれるような体験を提供します。

## ✨ 主な機能

このアプリのコア機能は以下の通りです。

* **自動計画立案**: 参考書や問題集の総量と目標日を設定するだけで、日々の学習ノルマを自動で算出します。
* **学習の記録**: タイマー機能で学習時間を計測し、進んだ量、タスクの難易度、集中度を簡単な操作で記録できます。
* **動的な計画調整**: 毎日の学習記録を基に、AIが学習ペースを再計算。無理なく、しかし着実に目標達成できるよう、翌日以降のノルマを常に最適化します。
* **進捗の可視化**: 学習時間や参考書ごとの進捗をグラフで直感的に確認でき、モチベーションの維持に繋がります。
* **柔軟なカスタマイズ**: 参考書の単位（ページ、問、章など）を自由に設定したり、計画を後から編集・削除したりと、あなたの学習スタイルに合わせた運用が可能です。

## 🛠️ 技術スタック

このプロジェクトは、モダンで効率的な技術スタックで構築されています。

* **フレームワーク**: [Flutter](https://flutter.dev/)
* **ローカルデータベース**: [Hive](https://pub.dev/packages/hive)
* **グラフ・チャート**: [fl_chart](https://pub.dev/packages/fl_chart)
* **状態管理**: `ValueListenableBuilder`, `StatefulWidget`

## 🚀 セットアップ方法

1.  **リポジトリをクローン**:
    ```bash
    git clone [リポジトリのURL]
    cd study_ai_assistant
    ```

2.  **依存関係をインストール**:
    ```bash
    flutter pub get
    ```

3.  **コード生成を実行**:
    （データベースモデルの変更後に必要です）
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **アプリを実行**:
    ```bash
    flutter run
    ```

## 🗺️ 今後のロードマップ

このアプリはまだ進化の途中です。将来的には以下の機能の追加を計画しています。

* **フェーズ2: 内蔵Anki機能の実装**: 科学的根拠に基づいた効率的な復習機能の統合。
* **フェーズ3: 拡張機能と改善**:
    * **クラウド同期 (Firebase)**: 複数デバイスでのデータ同期。

## 開発環境でのローカルテスト手順（Firebase に依存しない InMemory 実行方法）

このプロジェクトは、Firebase などの外部サービスに依存しない InMemory リポジトリを使用して、ローカル環境でテストおよび開発を行うことができます。これにより、CI/CD パイプラインやオフライン環境での開発が容易になります。

### `catalyze_ai` パッケージのテスト

`catalyze_ai` パッケージのユニットテストを実行するには、以下のコマンドを使用します。

```bash
cd packages/catalyze_ai
dart pub get
dart test
```

### `flutter_app` のウィジェットテスト

`flutter_app` のウィジェットテストを実行するには、以下のコマンドを使用します。これらのテストは、`catalyze_ai` パッケージの `InMemoryRepository` を使用して、Firebase への依存なしに UI の動作を検証します。

```bash
cd flutter_app
flutter pub get
flutter test
```

### `flutter_app` のローカル実行（InMemory モード）

`flutter_app` を InMemory モードでローカル実行するには、`lib/main.dart` で `AIService` のインスタンス化時に `InMemoryRepository` を明示的に注入するか、デフォルトの `InMemoryRepository` が使用されることを確認します。

```dart
// lib/main.dart (抜粋)
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<AIService>(
      // InMemoryRepository がデフォルトで使用されます
      create: (_) => AIService(),
      child: MaterialApp(
        title: 'Catalyze',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
```

その後、通常通り Flutter アプリケーションを実行します。

```bash
cd flutter_app
flutter run
```

これにより、Firebase などの実際のバックエンドサービスに接続することなく、アプリケーションの主要な機能をテストできます。
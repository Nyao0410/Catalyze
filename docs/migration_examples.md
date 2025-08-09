# スキーマ移行の具体例: v1 から v2 へ

このドキュメントでは、`StudyPlan` モデルに新しいフィールド `isArchived` (bool) を追加する v1 から v2 へのスキーマ移行の具体的な手順を説明します。

## v1 スキーマ (例)

```dart
class StudyPlan {
  final String id;
  final String title;
  final int totalUnits;
  final DateTime deadline;
  final int schemaVersion; // v1 では 1
  // ... 他のフィールド ...
}
```

## v2 スキーマ (目標)

```dart
class StudyPlan {
  final String id;
  final String title;
  final int totalUnits;
  final DateTime deadline;
  final bool isArchived; // 新しいフィールド
  final int schemaVersion; // v2 では 2
  // ... 他のフィールド ...
}
```

## 移行手順

### 1. 既存データのバックアップ

**重要**: 移行作業を開始する前に、必ず既存のデータベースの完全なバックアップを取得してください。これにより、問題が発生した場合にデータを復元できます。

*   **Firestore の場合**: Firestore のエクスポート機能を使用して、現在のデータベース全体を Cloud Storage にエクスポートします。
    ```bash
    gcloud firestore export gs://YOUR_BUCKET_NAME
    ```
*   **ローカルデータベースの場合**: データベースファイル（例: Hive の `.hive` ファイル）を安全な場所にコピーします。

### 2. データモデルの更新 (Dart コード)

`packages/catalyze_ai/lib/models/study_plan.dart` を更新し、`isArchived` フィールドと `schemaVersion` を追加します。

```dart
// packages/catalyze_ai/lib/models/study_plan.dart (抜粋)
class StudyPlan {
  // ... 既存のフィールド ...
  final bool isArchived; // 新しいフィールド
  final int schemaVersion; // 新しいフィールド

  StudyPlan({
    // ... 既存の引数 ...
    this.isArchived = false, // デフォルト値を設定
    this.schemaVersion = 2, // 新しいバージョン
  });

  StudyPlan copyWith({
    // ... 既存のcopyWith引数 ...
    bool? isArchived,
    int? schemaVersion,
  }) {
    return StudyPlan(
      // ... 既存のcopyWithロジック ...
      isArchived: isArchived ?? this.isArchived,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }
}
```

### 3. マイグレーションロジックの実装

`Repository` の実装（例: `InMemoryRepository` や将来の `FirestoreRepository`）に、古いスキーマのデータを新しいスキーマに変換するロジックを追加します。

```dart
// packages/catalyze_ai/lib/services/in_memory_repository.dart (抜粋)
// または FirestoreRepository の実装
import 'package:catalyze_ai/models/study_plan.dart';

const int _currentSchemaVersion = 2; // 現在のスキーマバージョン

class InMemoryRepository implements Repository {
  // ... 既存のコード ...

  @override
  Future<StudyPlan> getStudyPlan(String planId) async {
    // ... データをフェッチ ...
    final fetchedPlan = _plans[planId]; // 仮のフェッチ
    if (fetchedPlan == null) {
      throw Exception('StudyPlan with id $planId not found.');
    }

    if (fetchedPlan.schemaVersion < _currentSchemaVersion) {
      return _migratePlan(fetchedPlan, _currentSchemaVersion);
    }
    return fetchedPlan;
  }

  StudyPlan _migratePlan(StudyPlan oldPlan, int targetVersion) {
    StudyPlan migratedPlan = oldPlan;

    // v1 から v2 への移行
    if (oldPlan.schemaVersion < 2 && targetVersion >= 2) {
      migratedPlan = migratedPlan.copyWith(
        isArchived: false, // v1 データには isArchived がないのでデフォルト値を設定
        schemaVersion: 2,
      );
    }
    // 将来のバージョンへの移行ロジックをここに追加

    return migratedPlan;
  }
}
```

### 4. マイグレーションスクリプトの実行 (オプション、バッチ移行の場合)

大量の既存データを一度に移行する必要がある場合は、バックエンドで実行するマイグレーションスクリプトを作成します。

*   **例 (Node.js と Firebase Admin SDK)**:
    ```javascript
    const admin = require('firebase-admin');
    // ... Firebase 初期化 ...

    async function migrateStudyPlans() {
      const plansRef = admin.firestore().collection('studyPlans');
      const snapshot = await plansRef.where('schemaVersion', '<', 2).get();

      const batch = admin.firestore().batch();
      snapshot.docs.forEach(doc => {
        const data = doc.data();
        if (data.schemaVersion === 1) {
          batch.update(doc.ref, {
            isArchived: false,
            schemaVersion: 2
          });
        }
      });
      await batch.commit();
      console.log('Migration complete.');
    }

    migrateStudyPlans().catch(console.error);
    ```

### 5. フェールバック手順

移行中に問題が発生した場合に備え、元の状態に戻すための手順を確立しておくことが重要です。

1.  **アプリケーションのロールバック**: 問題のある新しいバージョンのアプリケーションをデプロイ解除し、安定した古いバージョンに戻します。
2.  **データベースの復元**: ステップ1で取得したバックアップを使用して、データベースを元の状態に復元します。
3.  **問題の診断と修正**: 問題の原因を特定し、修正します。

この手順により、安全かつ計画的にスキーマ移行を行うことができます。

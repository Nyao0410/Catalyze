class AppStrings {
  // Common
  static const String appName = 'Catalyze';
  static const String error = 'エラー';
  static const String cancel = 'キャンセル';
  static const String add = '追加';
  static const String delete = '削除';
  static const String edit = '編集';
  static const String save = '保存する';
  static const String update = '更新する';
  static const String pleaseInput = '入力してください';
  static const String pleaseSelect = '選択してください';
  static const String noData = 'データがありません。';
  static const String loadingError = 'データの読み込みに失敗しました。';
  static const String saveSuccess = '保存しました！';
  static const String saveFailure = '保存に失敗しました。';

  // Auth
  static const String login = 'ログイン';
  static const String logout = 'ログアウト';
  static const String signup = 'アカウント作成';
  static const String emailAddress = 'メールアドレス';
  static const String password = 'パスワード';
  static const String toSignupScreen = 'アカウント作成はこちら';
  static const String toLoginScreen = 'ログインはこちら';
  static const String guestUser = 'ゲストユーザー';

  // Main Scaffold
  static const String home = 'ホーム';
  static const String analysis = '分析';
  static const String settings = '設定';

  // Home Screen
  static const String todayProgress = '今日の進捗';
  static const String studyPlans = '学習計画';
  static const String noStudyPlans = 'まだ学習計画がありません。';
  static const String overallProgressError = '今日の進捗データの読み込みに失敗しました。';
  static const String overallProgressTitle = '今日のノルマ達成度';

  // Plan Screens
  static const String planCreation = '新しい学習計画を作成';
  static const String planEdit = '計画を編集';
  static const String planTitle = '参考書名・タイトル';
  static const String planDescription = '説明（任意）';
  static const String planTotalAmount = '総量';
  static const String planUnit = '単位';
  static const String planSelectUnit = '単位を選択';
  static const String planSelectUnitError = '単位を選択してください。';
  static const String planPredictedPt = '予測PT（25分=1PT）';
  static const String planInitialDifficulty = '初期難易度';
  static const String planSelectDate = '日付を選択';
  static const String planComplete = '学習計画を完了する';
  static const String planListError = '計画の読み込みに失敗しました。';
  static const String planDeleteConfirmationTitle = '計画の削除';
  static String planDeleteConfirmationContent(String title) => '「$title」を本当に削除しますか？この操作は元に戻せません。';

  // Analysis Screen
  static const String weeklyBarChart = '週間学習グラフ';
  static const String bookBalancePieChart = '参考書バランス';
  static const String pastLearningRecords = '過去の学習記録';
  static const String learningAmount = '学習量';
  static const String learningTime = '学習時間';
  static const String noLearningRecords = 'まだ学習記録がありません。';
  static const String analysisError = '分析データの読み込みに失敗しました。';
  static const String monday = '月';
  static const String tuesday = '火';
  static const String wednesday = '水';
  static const String thursday = '木';
  static const String friday = '金';
  static const String saturday = '土';
  static const String sunday = '日';

  // Evaluation Screen
  static const String evaluationTitle = '学習の評価';
  static const String evaluationMessage = '学習お疲れ様でした！';
  static String evaluationPomodoroMessage(int count, int minutes) => 'ポモドーロ $count 回 ($minutes 分) が終了しました。';
  static const String evaluationCompleteMessage = '学習計画を完了します。';
  static const String evaluationProgressAmount = '進捗量';
  static String evaluationProgressAmountWithUnit(String unit) => '進捗量 ($unit)';
  static const String evaluationExampleHint = '例: 10';
  static const String evaluationConcentration = '集中度';
  static const String evaluationDifficulty = '難易度';
  static const String evaluationSaveAndComplete = '記録して完了';
  static const String evaluationInputError = '進捗量を正しく入力してください。';
  static const String evaluationSaveSuccess = '学習記録を保存しました！';
  static String evaluationSaveFailure(String error) => '記録の保存に失敗しました: $error';


  // Settings Screen
  static const String account = 'アカウント';
  static const String theme = 'テーマ';
  static const String selectTheme = 'アプリのテーマを選択';
  static const String currentTheme = '現在のテーマ: システム設定';
  static const String unitManagement = '単位管理';
  static const String customUnits = 'カスタム単位';
  static const String noCustomUnits = 'まだカスタム単位がありません。';
  static const String addUnit = '単位を追加';
  static const String deleteUnit = '単位を削除';
  static const String addNewUnit = '新しい単位を追加';
  static const String unitExampleHint = '例: ページ, 問';
  static const String selectUnitToDelete = '削除する単位を選択';
}
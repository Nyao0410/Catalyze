import 'package:flutter/material.dart';
import 'package:catalyze/services/auth_service.dart';
import 'package:catalyze/services/plan_service.dart'; // 追加
import 'package:catalyze/constants/app_sizes.dart'; // 追加

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final PlanService _planService = PlanService(); // 追加
  final TextEditingController _unitController = TextEditingController(); // 追加

  @override
  void dispose() {
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _showAddUnitDialog() async {
    _unitController.clear();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('新しい単位を追加'),
          content: TextField(
            controller: _unitController,
            decoration: const InputDecoration(hintText: '例: ページ, 問'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('追加'),
              onPressed: () async {
                if (_unitController.text.isNotEmpty) {
                  await _planService.addCustomUnit(_unitController.text);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteUnitDialog(List<String> units) async {
    String? selectedUnit;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('単位を削除'),
          content: StatefulBuilder(
            builder: (context, setStateInDialog) {
              return DropdownButton<String>(
                isExpanded: true,
                hint: const Text('削除する単位を選択'),
                value: selectedUnit,
                onChanged: (String? newValue) {
                  setStateInDialog(() {
                    selectedUnit = newValue;
                  });
                },
                items: units.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('削除'),
              onPressed: () async {
                if (selectedUnit != null) {
                  await _planService.deleteCustomUnit(selectedUnit!);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // アカウントセクション
            Text('アカウント', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: p8),
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(p12)),
              child: Padding(
                padding: const EdgeInsets.all(p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_circle, size: p48, color: colorScheme.onSurfaceVariant), // モックアイコン
                        const SizedBox(width: p16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _authService.currentUser?.email ?? 'ゲストユーザー', // ユーザー名モック
                                style: textTheme.titleMedium,
                              ),
                              // TODO: アカウント名とアイコンを追加する
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: p16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _authService.logOut();
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('ログアウト'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: p24),

            // テーマセクション
            Text('テーマ', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: p8),
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(p12)),
              child: Padding(
                padding: const EdgeInsets.all(p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('アプリのテーマを選択', style: textTheme.titleMedium),
                    const SizedBox(height: p8),
                    // TODO: ポップメニューでカラー選択を実装
                    Text('現在のテーマ: システム設定', style: textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: p24),

            // 単位管理セクション
            Text('単位管理', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: p8),
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(p12)),
              child: Padding(
                padding: const EdgeInsets.all(p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('カスタム単位', style: textTheme.titleMedium),
                    const SizedBox(height: p8),
                    StreamBuilder<List<String>>(
                      stream: _planService.getCustomUnits(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('エラー: ${snapshot.error}');
                        }
                        final customUnits = snapshot.data ?? [];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (customUnits.isEmpty)
                              const Text('まだカスタム単位がありません。')
                            else
                              Wrap(
                                spacing: p8,
                                runSpacing: p8,
                                children: customUnits.map((unit) => Chip(
                                  label: Text(unit),
                                  onDeleted: () => _planService.deleteCustomUnit(unit),
                                )).toList(),
                              ),
                            const SizedBox(height: p16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _showAddUnitDialog,
                                    icon: const Icon(Icons.add),
                                    label: const Text('単位を追加'),
                                  ),
                                ),
                                const SizedBox(width: p8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: customUnits.isEmpty ? null : () => _showDeleteUnitDialog(customUnits),
                                    icon: const Icon(Icons.delete),
                                    label: const Text('単位を削除'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

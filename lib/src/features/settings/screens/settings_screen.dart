import 'package:catalyze/src/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:catalyze/src/features/auth/services/auth_service.dart';
import 'package:catalyze/src/features/plan/services/plan_service.dart'; // 追加
import 'package:catalyze/src/constants/app_sizes.dart';

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
          title: const Text(AppStrings.addNewUnit),
          content: TextField(
            controller: _unitController,
            decoration: const InputDecoration(hintText: AppStrings.unitExampleHint),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(AppStrings.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text(AppStrings.add),
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
          title: const Text(AppStrings.deleteUnit),
          content: StatefulBuilder(
            builder: (context, setStateInDialog) {
              return DropdownButton<String>(
                isExpanded: true,
                hint: const Text(AppStrings.selectUnitToDelete),
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
              child: const Text(AppStrings.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text(AppStrings.delete),
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
        title: const Text(AppStrings.settings),
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
            Text(AppStrings.account, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
                                _authService.currentUser?.email ?? AppStrings.guestUser, // ユーザー名モック
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
                      label: const Text(AppStrings.logout),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: p24),

            // テーマセクション
            Text(AppStrings.theme, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
                    Text(AppStrings.selectTheme, style: textTheme.titleMedium),
                    const SizedBox(height: p8),
                    // TODO: ポップメニューでカラー選択を実装
                    Text(AppStrings.currentTheme, style: textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: p24),

            // 単位管理セクション
            Text(AppStrings.unitManagement, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
                    Text(AppStrings.customUnits, style: textTheme.titleMedium),
                    const SizedBox(height: p8),
                    StreamBuilder<List<String>>(
                      stream: _planService.getCustomUnits(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('${AppStrings.error}: ${snapshot.error}');
                        }
                        final customUnits = snapshot.data ?? [];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (customUnits.isEmpty)
                              const Text(AppStrings.noCustomUnits)
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
                                    label: const Text(AppStrings.addUnit),
                                  ),
                                ),
                                const SizedBox(width: p8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: customUnits.isEmpty ? null : () => _showDeleteUnitDialog(customUnits),
                                    icon: const Icon(Icons.delete),
                                    label: const Text(AppStrings.deleteUnit),
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

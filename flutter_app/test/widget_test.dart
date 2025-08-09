import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catalyze_ai/catalyze_ai.dart';
import 'package:flutter_app/screens/home_screen.dart';
import 'package:flutter_app/services/ai_service.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('HomeScreen displays tasks from AIService', (WidgetTester tester) async {
    // 1. Setup: Create a repository with seed data.
    final repository = InMemoryRepository();
    final plan = StudyPlan(
      id: 'p1',
      userId: 'user1',
      title: 'Flutter Basics',
      totalUnits: 100,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      deadline: DateTime.now().add(const Duration(days: 20)),
    );
    // User has completed 20 units.
    final record = StudyRecord(
        id: 'r1',
        planId: 'p1',
        date: DateTime.now().subtract(const Duration(days: 1)),
        unitsCompleted: 20,
        duration: const Duration(hours: 2));

    await repository.saveStudyPlan(plan);
    await repository.saveStudyRecord(record);

    // 2. Create the AIService with the seeded repository.
    final aiService = AIService(repository: repository);

    // 3. Build our app and trigger a frame.
    await tester.pumpWidget(
      Provider<AIService>.value(
        value: aiService,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // 4. Verify: Check for loading indicator first.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 5. Re-pump the widget to process the Future from fetchDailyTasks.
    await tester.pumpAndSettle();

    // 6. Verify: Check that the tasks are displayed.
    // Let's calculate the expected quota to be sure.
    // remaining=80. daysUntil=20. basic=4.
    // elapsed=10, total=30. expected=33.3. actual=20. rate=0.6 < 0.8 -> quota=5
    expect(find.text('Study Flutter Basics'), findsOneWidget);
    expect(find.text('Complete 5 units today.'), findsOneWidget);
    expect(find.text('Review Session'), findsOneWidget);
  });
}
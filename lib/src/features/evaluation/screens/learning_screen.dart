import 'package:flutter/material.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学習'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 80, color: Colors.white54),
            SizedBox(height: 20),
            Text(
              'この画面は現在準備中です',
              style: TextStyle(fontSize: 18, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

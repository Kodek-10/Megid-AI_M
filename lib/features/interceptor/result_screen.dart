import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ResultScreen extends StatelessWidget {
  final String url;
  final double score;

  const ResultScreen({
    super.key,
    required this.url,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat analyse'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('URL: $url'),
            const SizedBox(height: 16),
            Text('Score: ${score.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
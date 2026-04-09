import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ResilienceTestScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const ResilienceTestScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<ResilienceTestScreen> createState() => _ResilienceTestScreenState();
}

class _ResilienceTestScreenState extends State<ResilienceTestScreen> {
  final List<Map<String, dynamic>> _testQuestions = [
    {
      'question': 'Utilisez-vous un mot de passe unique pour chaque compte ?',
      'answers': ['Toujours', 'Souvent', 'Parfois', 'Jamais'],
      'correctAnswer': 0,
      'points': 20,
    },
    {
      'question': 'Comment réagissez-vous face à un email suspect ?',
      'answers': ['Je le signale immédiatement', 'Je l\'ignore et le supprime', 'Je clique pour vérifier', 'Je le transfère'],
      'correctAnswer': 0,
      'points': 25,
    },
    {
      'question': 'Avez-vous activé l\'authentification à deux facteurs ?',
      'answers': ['Sur tous mes comptes', 'Sur les comptes importants', 'Sur un seul compte', 'Non, jamais'],
      'correctAnswer': 1,
      'points': 25,
    },
    {
      'question': 'Mettez-vous à jour régulièrement votre téléphone ?',
      'answers': ['Automatiquement chaque jour', 'Une fois par mois', 'Rarement', 'Jamais'],
      'correctAnswer': 0,
      'points': 20,
    },
    {
      'question': 'Comment partagez-vous vos informations personnelles en ligne ?',
      'answers': ['Avec prudence et sélectivité', 'Facilement', 'Jamais', 'Je ne sais pas'],
      'correctAnswer': 0,
      'points': 10,
    },
  ];

  Color _getScoreColor(double score) {
    if (score >= 80) return MegidaiColors.success;
    if (score >= 60) return MegidaiColors.warning;
    return MegidaiColors.error;
  }

  String _getScoreLabel(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Bon';
    if (score >= 40) return 'Moyen';
    return 'À améliorer';
  }
  
  String _getTestResultMessage(int score) {
    if (score >= 80) return 'Excellent ! Vous avez une bonne maîtrise des pratiques de sécurité.';
    if (score >= 60) return 'Bon résultat. Continuez à améliorer vos connaissances de sécurité.';
    if (score >= 40) return 'Résultat moyen. Suivez les cours pour améliorer vos compétences.';
    return 'À améliorer. Consultez la section Éducation pour progresser.';
  }

  void _showTestResults(int score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('Résultats du test'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 8,
                      backgroundColor: theme.dividerColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getScoreColor(score.toDouble()),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$score',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(score.toDouble()),
                            ),
                          ),
                          Text(
                            '/100',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _getScoreLabel(score.toDouble()),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _getTestResultMessage(score),
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Retour à la page de résilience originelle
              },
              child: const Text('Fermer et Retourner'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test de Résilience'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
            tooltip: widget.isDarkMode ? 'Mode jour' : 'Mode nuit',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ResilienceTestWidget(
              questions: _testQuestions,
              onTestComplete: _showTestResults,
            ),
          ),
        ),
      ),
    );
  }
}

class ResilienceTestWidget extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final Function(int) onTestComplete;

  const ResilienceTestWidget({
    required this.questions,
    required this.onTestComplete,
    super.key,
  });

  @override
  State<ResilienceTestWidget> createState() => _ResilienceTestWidgetState();
}

class _ResilienceTestWidgetState extends State<ResilienceTestWidget> {
  int _currentIndex = 0;
  int _totalScore = 0;

  void _selectAnswer(int answerIndex) {
    final question = widget.questions[_currentIndex];
    final isCorrect = answerIndex == question['correctAnswer'];
    
    if (isCorrect) {
      _totalScore += (question['points'] as int);
    }

    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      // Calculate final percentage
      final maxScore = widget.questions.fold<int>(0, (sum, q) => sum + (q['points'] as int));
      final percentage = ((_totalScore / maxScore) * 100).toInt();
      widget.onTestComplete(percentage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = widget.questions[_currentIndex];
    final progress = (_currentIndex + 1) / widget.questions.length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: theme.dividerColor,
            valueColor: const AlwaysStoppedAnimation<Color>(MegidaiColors.primary),
          ),
          const SizedBox(height: 16),
          
          // Question counter
          Text(
            'Question ${_currentIndex + 1}/${widget.questions.length}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),

          // Question
          Text(
            question['question'],
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // Answers
          ...List.generate(
            (question['answers'] as List).length,
            (index) {
              final answer = question['answers'][index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _selectAnswer(index),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: MegidaiColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            answer,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

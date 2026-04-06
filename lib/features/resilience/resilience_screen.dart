import 'package:flutter/material.dart';
import '../../core/bottom_nav.dart';
import '../../core/theme.dart';

class ResilienceScreen extends StatefulWidget {
  const ResilienceScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  @override
  State<ResilienceScreen> createState() => _ResilienceScreenState();
}

class _ResilienceScreenState extends State<ResilienceScreen> {
  double _resilienceScore = 75.0; // Mock score

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

  final List<Map<String, dynamic>> _factors = [
    {
      'name': 'Connaissance des menaces',
      'score': 80,
      'description': 'Compréhension des risques en ligne',
      'icon': Icons.lightbulb,
    },
    {
      'name': 'Pratiques sécurisées',
      'score': 70,
      'description': 'Utilisation de mots de passe forts',
      'icon': Icons.lock,
    },
    {
      'name': 'Réactivité',
      'score': 85,
      'description': 'Capacité à réagir aux menaces',
      'icon': Icons.speed,
    },
    {
      'name': 'Éducation continue',
      'score': 65,
      'description': 'Apprentissage régulier',
      'icon': Icons.school,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résilience'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
            tooltip: widget.isDarkMode ? 'Mode jour' : 'Mode nuit',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [MegidaiColors.primary.withOpacity(0.8), MegidaiColors.secondary.withOpacity(0.8)]
                      : [MegidaiColors.primary, MegidaiColors.secondary],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score de Résilience',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Évaluez votre niveau de protection',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Score display
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  children: [
                    // Circular progress
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        children: [
                          CircularProgressIndicator(
                            value: _resilienceScore / 100,
                            strokeWidth: 8,
                            backgroundColor: theme.dividerColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getScoreColor(_resilienceScore),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${_resilienceScore.round()}',
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _getScoreColor(_resilienceScore),
                                  ),
                                ),
                                Text(
                                  '/100',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getScoreLabel(_resilienceScore),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getScoreDescription(_resilienceScore),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Factors
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Facteurs de résilience',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _factors.length,
              itemBuilder: (context, index) {
                final factor = _factors[index];
                return _buildFactorCard(factor);
              },
            ),

            const SizedBox(height: 24),

            // Action button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _startResilienceTest(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Lancer le test de résilience'),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: const MegidaiBottomNav(currentRoute: '/resilience'),
    );
  }

  Widget _buildFactorCard(Map<String, dynamic> factor) {
    final theme = Theme.of(context);
    final score = factor['score'] as int;

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    factor['name'],
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    factor['description'],
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Score actuel : $score%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Conseil : améliorez ce facteur en suivant les exercices et bonnes pratiques disponibles dans la section Éducation.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getScoreColor(score.toDouble()).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                factor['icon'],
                color: _getScoreColor(score.toDouble()),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    factor['name'],
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    factor['description'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getScoreColor(score.toDouble()).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$score%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getScoreColor(score.toDouble()),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  String _getScoreDescription(double score) {
    if (score >= 80) return 'Votre niveau de résilience est excellent. Continuez ainsi !';
    if (score >= 60) return 'Bon niveau général, quelques améliorations possibles.';
    if (score >= 40) return 'Il y a des points à améliorer pour renforcer votre sécurité.';
    return 'Votre résilience nécessite des améliorations importantes.';
  }

  void _startResilienceTest() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ResilienceTestWidget(
          questions: _testQuestions,
          onTestComplete: (score) {
            Navigator.of(context).pop();
            _showTestResults(score);
          },
        );
      },
    );
  }

  void _showTestResults(int score) {
    showDialog(
      context: context,
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String _getTestResultMessage(int score) {
    if (score >= 80) return 'Excellent ! Vous avez une bonne maîtrise des pratiques de sécurité.';
    if (score >= 60) return 'Bon résultat. Continuez à améliorer vos connaissances de sécurité.';
    if (score >= 40) return 'Résultat moyen. Suivez les cours pour améliorer vos compétences.';
    return 'À améliorer. Consultez la section Éducation pour progresser.';
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
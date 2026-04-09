import 'package:flutter/material.dart';
import '../../core/theme.dart';

class QuizScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const QuizScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<Map<String, dynamic>> _quizzes = [
    {
      'question': 'Que signifie HTTPS ?',
      'answers': [
        'HyperText Transfer Protocol Secure',
        'HyperText Transfer Protocol System',
        'High Tech Protocol Security',
        'Home Transfer Protocol Safety'
      ],
      'correctAnswer': 0,
      'explanation': 'HTTPS signifie HyperText Transfer Protocol Secure, qui chiffre vos données.'
    },
    {
      'question': 'Quel est le meilleur endroit pour stocker vos mots de passe ?',
      'answers': [
        'Dans un gestionnaire de mots de passe',
        'Dans un fichier texte sur votre bureau',
        'Dans votre navigateur',
        'Écrit sur un post-it'
      ],
      'correctAnswer': 0,
      'explanation': 'Un gestionnaire de mots de passe est la solution la plus sûre.'
    },
    {
      'question': 'Que faire si vous recevez un email suspect ?',
      'answers': [
        'Cliquer sur le lien pour vérifier',
        'Le signaler et le supprimer immédiatement',
        'Répondre à l\'email',
        'Le transférer à vos amis'
      ],
      'correctAnswer': 1,
      'explanation': 'Signalez les emails suspects à votre fournisseur de messagerie et supprimez-les.'
    },
    {
      'question': 'Comment reconnaître un site phishing ?',
      'answers': [
        'L\'URL n\'est pas exactement celle attendue',
        'Le site demande des informations confidentielles inopinément',
        'Le design semble mauvais',
        'Les deux premières réponses'
      ],
      'correctAnswer': 3,
      'explanation': 'Les deux premiers points sont des signes d\'alerte pour le phishing.'
    },
  ];

  void _showQuizResults(int score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        
        return AlertDialog(
          title: const Text('Résultats du quiz'),
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
                        score >= 70 ? MegidaiColors.success : MegidaiColors.warning,
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
                              color: score >= 70 ? MegidaiColors.success : MegidaiColors.warning,
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
                score >= 70 ? 'Bien joué !' : 'Vous pouvez améliorer',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                score >= 70
                    ? 'Vous maîtrisez bien ce sujet !'
                    : 'Revoyez la leçon pour améliorer vos connaissances.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pop(); // exit quiz screen
              },
              child: const Text('Retourner à l\'accueil'),
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
        title: const Text('Quiz de Sécurité'),
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
            child: QuizWidget(
              questions: _quizzes,
              onQuizComplete: _showQuizResults,
            ),
          ),
        ),
      ),
    );
  }
}

class QuizWidget extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final Function(int) onQuizComplete;

  const QuizWidget({
    required this.questions,
    required this.onQuizComplete,
    super.key,
  });

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  int _currentIndex = 0;
  int _correctAnswers = 0;

  void _selectAnswer(int answerIndex) {
    final question = widget.questions[_currentIndex];
    final isCorrect = answerIndex == question['correctAnswer'];
    
    if (isCorrect) {
      _correctAnswers++;
    }

    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      final percentage = ((_correctAnswers / widget.questions.length) * 100).round();
      widget.onQuizComplete(percentage);
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

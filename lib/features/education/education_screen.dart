import 'package:flutter/material.dart';
import '../../core/theme.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final List<Map<String, dynamic>> _lessons = [
    {
      'title': 'Les bases de la sécurité en ligne',
      'description': 'Comprendre les menaces courantes et les bonnes pratiques',
      'tag': 'Débutant',
      'duration': '15 min',
      'status': 'completed',
      'color': Colors.green,
    },
    {
      'title': 'Reconnaître les tentatives de phishing',
      'description': 'Identifier les emails et sites frauduleux',
      'tag': 'Intermédiaire',
      'duration': '20 min',
      'status': 'in_progress',
      'color': Colors.blue,
    },
    {
      'title': 'Gérer ses mots de passe',
      'description': 'Créer et stocker des mots de passe sécurisés',
      'tag': 'Débutant',
      'duration': '12 min',
      'status': 'new',
      'color': Colors.orange,
    },
    {
      'title': 'La navigation sécurisée',
      'description': 'Utiliser HTTPS et éviter les sites dangereux',
      'tag': 'Intermédiaire',
      'duration': '18 min',
      'status': 'new',
      'color': Colors.purple,
    },
  ];

  final Map<String, int> _progressStats = {
    'Terminés': 12,
    'En cours': 3,
    'Total': 25,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Éducation'),
      ),
      body: Column(
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
                    ? [const Color(0xFF0F2A6E), const Color(0xFF1B4FD8)]
                    : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modules Éducatifs',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Apprenez à vous protéger en ligne',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Progress summary
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: _progressStats.entries.map((entry) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          entry.value.toString(),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: MegidaiColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.key,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Quiz card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFDE68A).withOpacity(0.3),
                    const Color(0xFFFEF9EB),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFFFDE68A),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.quiz,
                    color: const Color(0xFF92400E),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quiz du jour',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: const Color(0xFF92400E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Testez vos connaissances sur la sécurité',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF78350F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Quiz bientôt disponible')),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    color: const Color(0xFF92400E),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Lessons title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Leçons disponibles',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Lessons list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _lessons.length,
              itemBuilder: (context, index) {
                final lesson = _lessons[index];
                return _buildLessonCard(lesson);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(Map<String, dynamic> lesson) {
    final theme = Theme.of(context);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (lesson['status']) {
      case 'completed':
        statusColor = MegidaiColors.success;
        statusText = 'Terminé';
        statusIcon = Icons.check_circle;
        break;
      case 'in_progress':
        statusColor = MegidaiColors.primary;
        statusText = 'En cours';
        statusIcon = Icons.play_circle;
        break;
      default:
        statusColor = theme.textTheme.bodySmall?.color ?? Colors.grey;
        statusText = 'Nouveau';
        statusIcon = Icons.circle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          // Color bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: lesson['color'],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: lesson['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    lesson['tag'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: lesson['color'],
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Title
                Text(
                  lesson['title'],
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                // Description
                Text(
                  lesson['description'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 12),

                // Meta
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: theme.iconTheme.color?.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lesson['duration'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            statusIcon,
                            size: 12,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
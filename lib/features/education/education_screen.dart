import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/bottom_nav.dart';
import '../../core/theme.dart';
class EducationScreen extends StatefulWidget {
  const EducationScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  final VoidCallback onThemeToggle;
  final bool isDarkMode;

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
      'color': MegidaiColors.safe,
      'content': {
        'sections': [
          {
            'title': 'Introduction',
            'text': 'La sécurité en ligne est fondamentale. Apprenez les concepts clés pour vous protéger.'
          },
          {
            'title': 'Les menaces courantes',
            'text': 'Virus, malwares, phishing, vol d\'identité... Connaître les risques est le premier pas.'
          },
          {
            'title': 'Bonnes pratiques',
            'text': 'Utilisez des mots de passe forts, activez l\'authentification à deux facteurs, gardez vos logiciels à jour.'
          },
        ]
      }
    },
    {
      'title': 'Reconnaître les tentatives de phishing',
      'description': 'Identifier les emails et sites frauduleux',
      'tag': 'Intermédiaire',
      'duration': '20 min',
      'status': 'in_progress',
      'color': MegidaiColors.danger,
      'content': {
        'sections': [
          {
            'title': 'Qu\'est-ce que le phishing ?',
            'text': 'Le phishing est une technique de cybercriminalité visant à obtenir vos données personnelles.'
          },
          {
            'title': 'Comment le reconnaître',
            'text': 'Cherchez les pièges : adresses email suspectes, liens étranges, demandes d\'informations confidentielles.'
          },
        ]
      }
    },
    {
      'title': 'Gérer ses mots de passe',
      'description': 'Créer et stocker des mots de passe sécurisés',
      'tag': 'Débutant',
      'duration': '12 min',
      'status': 'new',
      'color': MegidaiColors.accent,
      'content': {
        'sections': [
          {
            'title': 'Mots de passe forts',
            'text': 'Un bon mot de passe contient des majuscules, minuscules, chiffres et caractères spéciaux.'
          },
          {
            'title': 'Gestionnaires de mots de passe',
            'text': 'Utilisez des applications comme Bitwarden ou 1Password pour stocker vos mots de passe de manière sécurisée.'
          },
        ]
      }
    },
    {
      'title': 'La navigation sécurisée',
      'description': 'Utiliser HTTPS et éviter les sites dangereux',
      'tag': 'Intermédiaire',
      'duration': '18 min',
      'status': 'new',
      'color': MegidaiColors.primary,
      'content': {
        'sections': [
          {
            'title': 'HTTPS vs HTTP',
            'text': 'HTTPS chiffre vos données. Vérifiez toujours que le site utilise HTTPS (le cadenas dans la barre d\'adresse).'
          },
          {
            'title': 'Avertissements du navigateur',
            'text': 'Si votre navigateur affiche un avertissement, ne poursuivez pas. Le site n\'est probablement pas sûr.'
          },
        ]
      }
    },
  ];



  String _selectedLevel = 'Tous';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filteredLessons = _lessons.where((lesson) {
      if (_selectedLevel == 'Tous') return true;
      return lesson['tag'] == _selectedLevel;
    }).toList();

    final completedCount = _lessons.where((l) => l['status'] == 'completed').length;
    final inProgressCount = _lessons.where((l) => l['status'] == 'in_progress').length;
    final Map<String, int> dynamicProgressStats = {
      'Terminés': completedCount,
      'En cours': inProgressCount,
      'Total': _lessons.length,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Éducation'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
            tooltip: widget.isDarkMode ? 'Mode jour' : 'Mode nuit',
          ),
        ],
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
                    ? [MegidaiColors.primary.withOpacity(0.8), MegidaiColors.secondary.withOpacity(0.8)]
                    : [MegidaiColors.primary, MegidaiColors.secondary],
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
              children: dynamicProgressStats.entries.map((entry) {
                return Expanded(
                  child: InkWell(
                    onTap: () => _showCoursesList(entry.key),
                    borderRadius: BorderRadius.circular(12),
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
                  ),
                );
              }).toList(),
            ),
          ),

          // Quiz card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () => _startQuiz(),
              borderRadius: BorderRadius.circular(12),
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
                    Icon(
                      Icons.play_arrow,
                      color: const Color(0xFF92400E),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Niveau filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: ['Tous', 'Débutant', 'Intermédiaire', 'Avancé'].map((level) {
                final isSelected = _selectedLevel == level;
                return ChoiceChip(
                  label: Text(level),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedLevel = level;
                    });
                  },
                  selectedColor: MegidaiColors.primary.withOpacity(0.15),
                  backgroundColor: theme.cardColor,
                  labelStyle: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected ? MegidaiColors.primary : theme.textTheme.bodySmall?.color,
                  ),
                );
              }).toList(),
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
              itemCount: filteredLessons.length,
              itemBuilder: (context, index) {
                final lesson = filteredLessons[index];
                return _buildLessonCard(lesson);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MegidaiBottomNav(currentRoute: '/education'),
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

    return InkWell(
      onTap: () => _showLessonContent(lesson),
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
      ),
    );
  }

  void _startQuiz() {
    context.push('/quiz');
  }

  void _showCoursesList(String category) {
    String statusFilter;
    Color headerColor;
    if (category == 'Terminés') {
      statusFilter = 'completed';
      headerColor = MegidaiColors.success;
    } else if (category == 'En cours') {
      statusFilter = 'in_progress';
      headerColor = MegidaiColors.primary;
    } else {
      statusFilter = 'all';
      headerColor = Theme.of(context).cardColor;
    }

    final courses = _lessons.where((lesson) {
      if (statusFilter == 'all') return true;
      return lesson['status'] == statusFilter;
    }).toList();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 8,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: headerColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border(bottom: BorderSide(color: headerColor.withOpacity(0.2), width: 2)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        category == 'Terminés' ? Icons.check_circle : (category == 'En cours' ? Icons.play_circle : Icons.list),
                        color: headerColor == theme.cardColor ? theme.iconTheme.color : headerColor,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Cours $category',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: headerColor == theme.cardColor ? theme.textTheme.titleLarge?.color : headerColor,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                ),
                // Courses List
                Flexible(
                  child: courses.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(48),
                          child: Text(
                            'Aucun cours pour cette catégorie.',
                            style: theme.textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodySmall?.color),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            return _buildLessonCard(courses[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLessonContent(Map<String, dynamic> lesson) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final sections = lesson['content']?['sections'] as List? ?? [];
        
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 8,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: (lesson['color'] as Color).withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.menu_book, color: lesson['color'], size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          lesson['title'],
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: lesson['color'],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: sections.length,
                    itemBuilder: (context, index) {
                      final section = sections[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section['title'],
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              section['text'],
                              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Footer button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Compris, merci.'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

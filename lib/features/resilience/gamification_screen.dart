import 'package:flutter/material.dart';
import '../../core/bottom_nav.dart';
import '../../core/theme.dart';

class GamificationScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const GamificationScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen> {
  final List<Map<String, dynamic>> _badges = [
    {
      'title': 'Première menace bloquée',
      'date': 'Il y a 2 jours',
      'icon': Icons.shield_moon,
      'color': MegidaiColors.success,
      'unlocked': true,
    },
    {
      'title': '7 jours sans clic suspect',
      'date': 'Aujourd\'hui',
      'icon': Icons.verified,
      'color': MegidaiColors.primary,
      'unlocked': true,
    },
    {
      'title': 'Ange Gardien actif depuis 30 jours',
      'date': 'Verrouillé',
      'icon': Icons.lock,
      'color': Colors.grey,
      'unlocked': false,
    },
  ];

  final List<Map<String, dynamic>> _defis = [
    {
      'title': 'Terminer le module "Phishing"',
      'points': 50,
      'progress': 0.8,
    },
    {
      'title': 'Vérifier 3 de vos comptes HIBP',
      'points': 30,
      'progress': 0.33,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Badges & Défis'),
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
                      ? [MegidaiColors.accent.withOpacity(0.8), MegidaiColors.secondary.withOpacity(0.8)]
                      : [MegidaiColors.accent, MegidaiColors.secondary],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vos Récompenses',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Accomplissez des défis pour renforcer votre niveau',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Comparaison Communautaire
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? MegidaiColors.primary.withOpacity(0.2) : MegidaiColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: MegidaiColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.public, size: 48, color: MegidaiColors.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Classement Communautaire',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Votre score de 78/100 vous place dans le Top 15% de votre région !',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Défis Hebdomadaires
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.flash_on, color: MegidaiColors.warning),
                  const SizedBox(width: 8),
                  Text(
                    'Défis Hebdomadaires',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _defis.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final defi = _defis[index];
                final progress = defi['progress'] as double;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            defi['title'],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '+${defi['points']} pts',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: MegidaiColors.accent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: theme.dividerColor.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(MegidaiColors.primary),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 8,
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Badges et Niveaux
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.military_tech, color: MegidaiColors.success),
                  const SizedBox(width: 8),
                  Text(
                    'Vos Badges',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: _badges.length,
              itemBuilder: (context, index) {
                final badge = _badges[index];
                final unlocked = badge['unlocked'] as bool;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: unlocked ? badge['color'].withOpacity(0.1) : theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: unlocked ? badge['color'].withOpacity(0.3) : theme.dividerColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        badge['icon'],
                        size: 40,
                        color: badge['color'],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        badge['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: unlocked ? theme.textTheme.bodyLarge?.color : Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        badge['date'],
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const MegidaiBottomNav(currentRoute: '/resilience'),
    );
  }
}

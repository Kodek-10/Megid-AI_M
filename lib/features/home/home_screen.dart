import 'package:flutter/material.dart';
import '../../core/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isProtectionActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Megidai'),
        backgroundColor: MegidaiColors.darkSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre principal
            Text(
              'Bouclier Numérique',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Protection intelligente contre les menaces en ligne',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: MegidaiColors.textSecondary,
              ),
            ),
            const SizedBox(height: 40),

            // Carte principale de protection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isProtectionActive ? Icons.shield : Icons.shield_outlined,
                          color: _isProtectionActive ? MegidaiColors.success : MegidaiColors.textGray,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Protection en temps réel',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isProtectionActive
                                    ? 'Analyse en temps réel activée'
                                    : 'Appuyez pour activer la protection',
                                style: TextStyle(color: MegidaiColors.textGray, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Switch pour activer/désactiver
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Activer la protection'),
                        Switch(
                          value: _isProtectionActive,
                          onChanged: (value) {
                            setState(() {
                              _isProtectionActive = value;
                            });
                          },
                          activeColor: MegidaiColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Boutons de navigation
            Text(
              'Fonctionnalités',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Grille de fonctionnalités
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context,
                    'Ange Gardien',
                    Icons.security,
                    MegidaiColors.secondary,
                    () {
                      // Navigation vers Ange Gardien
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ange Gardien - Bientôt disponible')),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    'Résilience',
                    Icons.psychology,
                    MegidaiColors.accent,
                    () {
                      // Navigation vers Résilience
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Score de résilience - Bientôt disponible')),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    'Éducation',
                    Icons.school,
                    MegidaiColors.primary,
                    () {
                      // Navigation vers Éducation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Modules éducatifs - Bientôt disponible')),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    'Paramètres',
                    Icons.settings,
                    MegidaiColors.textGray,
                    () {
                      // Navigation vers Paramètres
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Paramètres - Bientôt disponible')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
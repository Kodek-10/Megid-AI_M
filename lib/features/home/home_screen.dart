import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/bottom_nav.dart';
import '../../core/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  final List<String> _searchHistory = ['example.com', 'google.com', 'facebook.com'];
  List<String> _filteredHistory = [];

  @override
  void initState() {
    super.initState();
    _filteredHistory = _searchHistory;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Analyse de $url en cours...')),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.push('/result', extra: {
        'url': url,
        'score': (50 + (url.length % 35)).toDouble(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Megidai'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [MegidaiColors.primary.withOpacity(0.9), MegidaiColors.secondary.withOpacity(0.9)]
                      : [MegidaiColors.primary, MegidaiColors.secondary],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour, bienvenue !',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Votre protection intelligente en un coup d’œil',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMiniStatCard(
                      context,
                      title: 'Score',
                      value: '78',
                      subtitle: 'Résilience',
                      icon: Icons.bar_chart,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMiniStatCard(
                      context,
                      title: 'Anges',
                      value: '03',
                      subtitle: 'Actifs',
                      icon: Icons.shield,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Scan section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // URL input with search icon
                  TextField(
                    controller: _urlController,
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          _filteredHistory = _searchHistory;
                        } else {
                          _filteredHistory = _searchHistory
                              .where((item) => item.toLowerCase().contains(value.toLowerCase()))
                              .toList();
                        }
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Analyser un lien...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _urlController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _urlController.clear();
                                setState(() {
                                  _filteredHistory = _searchHistory;
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.dividerColor.withOpacity(0.5),
                        ),
                      ),
                      filled: true,
                      fillColor: theme.cardColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Scan button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleSearch,
                      icon: const Icon(Icons.security),
                      label: const Text('Analyser'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  // Search history
                  if (_urlController.text.isNotEmpty && _filteredHistory.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Historique',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._filteredHistory.map((item) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: InkWell(
                                onTap: () {
                                  _urlController.text = item;
                                  _handleSearch();
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.history,
                                      size: 16,
                                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      item,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Features section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Fonctionnalités',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Feature cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildFeatureCard(
                    context,
                    'Ange Gardien',
                    Icons.shield,
                    'Surveillance active',
                    () => context.go('/guardian'),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureCard(
                    context,
                    'Résilience',
                    Icons.psychology,
                    'Évaluez votre niveau',
                    () => context.go('/resilience'),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureCard(
                    context,
                    'Éducation',
                    Icons.school,
                    'Apprenez à vous protéger',
                    () => context.go('/education'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const MegidaiBottomNav(currentRoute: '/'),
    );
  }

  Widget _buildMiniStatCard(
    BuildContext context,
    {required String title,
    required String value,
    required String subtitle,
    required IconData icon}) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MegidaiColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: MegidaiColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MegidaiColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: MegidaiColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.iconTheme.color?.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _analyzeUrl() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une URL')),
      );
      return;
    }

    _handleSearch();
  }
}
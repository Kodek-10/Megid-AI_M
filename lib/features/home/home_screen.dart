import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/bottom_nav.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
    required this.isBackendOnline,
  });

  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  final bool isBackendOnline;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;

  // Statistiques récupérées depuis le backend
  int _threatsBlocked = 0;
  final int _activeGuardians = 0;
  bool _statsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  // ── Charger les statistiques depuis le backend ────────────────────────────
  Future<void> _loadStats() async {
    if (!widget.isBackendOnline) return;
    try {
      final stats = await ApiService.getStats();
      if (!mounted) return;
      setState(() {
        _threatsBlocked = stats['threats_blocked'] as int? ?? 0;
        _statsLoaded = true;
      });
    } catch (_) {
      // Silencieux — stats non critiques
    }
  }

  // ── Analyser une URL via le backend ──────────────────────────────────────
  Future<void> _handleSearch() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une URL à analyser')),
      );
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      // Appel RÉEL au backend FastAPI
      final result = await ApiService.scanUrl(url, source: 'manual_scan');
      final score = (result['risk_score'] as int).toDouble();

      if (!mounted) return;

      // Naviguer vers l'écran de résultat avec les vraies données
      context.push('/result', extra: {
        'url': url,
        'score': score,
        'level': result['level'] ?? 'safe',
        'reasons': result['reasons'] ?? [],
        'analysis_time_ms': result['analysis_time_ms'] ?? 0,
        'community_reports': result['community_reports'] ?? 0,
      });

    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${e.message}'),
          backgroundColor: MegidaiColors.danger,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur inattendue : $e'),
          backgroundColor: MegidaiColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Megidai'),
        actions: [
          // Indicateur de connexion backend
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Tooltip(
              message: widget.isBackendOnline
                  ? 'Serveur connecté'
                  : 'Serveur hors ligne — mode local',
              child: Icon(
                widget.isBackendOnline ? Icons.cloud_done : Icons.cloud_off,
                color: widget.isBackendOnline
                    ? MegidaiColors.safe
                    : MegidaiColors.danger,
                size: 20,
              ),
            ),
          ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
            tooltip: widget.isDarkMode ? 'Mode jour' : 'Mode nuit',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header avec gradient ──────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            MegidaiColors.primary.withOpacity(0.9),
                            MegidaiColors.secondary.withOpacity(0.9)
                          ]
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
                      widget.isBackendOnline
                          ? 'Votre protection intelligente est active'
                          : 'Mode hors ligne — protection locale activée',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Statistiques dynamiques ───────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Score',
                        value: '78',
                        subtitle: 'Résilience',
                        icon: Icons.bar_chart,
                        onTap: () => context.push('/resilience'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Menaces',
                        value: _statsLoaded ? '$_threatsBlocked' : '—',
                        subtitle: 'Bloquées',
                        icon: Icons.shield,
                        onTap: () => context.push('/guardian'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Zone d'analyse d'URL ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analyser un lien',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _urlController,
                      keyboardType: TextInputType.url,
                      onSubmitted: (_) => _handleSearch(),
                      decoration: InputDecoration(
                        hintText: 'Coller un lien à analyser...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _urlController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _urlController.clear();
                                  setState(() {});
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
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleSearch,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.security),
                        label: Text(_isLoading ? 'Analyse en cours...' : 'Analyser'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Fonctionnalités ───────────────────────────────────────
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildFeatureCard(
                      context,
                      'Ange Gardien',
                      Icons.shield,
                      'Surveillance active de vos proches',
                      () => context.go('/guardian'),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      context,
                      'Résilience',
                      Icons.psychology,
                      'Évaluez votre niveau de protection',
                      () => context.go('/resilience'),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      context,
                      'Éducation',
                      Icons.school,
                      'Apprenez à vous protéger en ligne',
                      () => context.go('/education'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MegidaiBottomNav(currentRoute: '/'),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                child: Icon(icon, size: 24, color: MegidaiColors.primary),
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
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.7),
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
}
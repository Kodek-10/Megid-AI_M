import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/bottom_nav.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart';

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
  bool _isLoadingStats = false;

  // ── Facteurs de résilience — mis à jour dynamiquement ─────────────────────
  final List<Map<String, dynamic>> _factors = [
    {
      'name': 'Santé des accès',
      'score': 80,
      'pts': 30,
      'description': 'Applications bénéficiant d\'accès non justifiés',
      'icon': Icons.admin_panel_settings,
    },
    {
      'name': 'Exposition aux fuites',
      'score': 60,
      'pts': 25,
      'description': 'Nombre et gravité des fuites HIBP détectées',
      'icon': Icons.mail_lock,
    },
    {
      'name': 'Comportement',
      'score': 90,
      'pts': 25,
      'description': 'Réactivité aux alertes, taux de clics suspects',
      'icon': Icons.speed,
    },
    {
      'name': 'Bonnes pratiques',
      'score': 45,
      'pts': 20,
      'description': 'Biométrie, mises à jour, modules éducatifs',
      'icon': Icons.verified_user,
    },
  ];

  // Statistiques récupérées du backend
  int _threatsBlocked = 0;
  int _communityReports = 0;
  bool _statsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBackendStats();
  }

  // ── Charger les stats du backend pour enrichir le score ──────────────────
  Future<void> _loadBackendStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final stats = await ApiService.getStats();
      if (!mounted) return;
      setState(() {
        _threatsBlocked = stats['threats_blocked'] as int? ?? 0;
        _communityReports =
            stats['total_community_reports'] as int? ?? 0;
        _statsLoaded = true;

        // Mettre à jour dynamiquement le score "Comportement"
        // Plus on a bloqué de menaces, meilleur est le score comportemental
        if (_threatsBlocked > 0) {
          final behaviourScore = (_threatsBlocked * 10).clamp(0, 100);
          _factors[2]['score'] = behaviourScore;
        }
      });
    } catch (_) {
      // Silencieux — garder les valeurs par défaut
    } finally {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  // ── Score total calculé dynamiquement ─────────────────────────────────────
  double get _resilienceScore {
    double total = 0;
    for (var factor in _factors) {
      total +=
          (factor['score'] as int).toDouble() * (factor['pts'] as int) / 100.0;
    }
    return total;
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return MegidaiColors.safe;
    if (score >= 60) return MegidaiColors.caution;
    return MegidaiColors.danger;
  }

  String _getScoreLabel(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Bon';
    if (score >= 40) return 'Moyen';
    return 'À améliorer';
  }

  String _getScoreDescription(double score) {
    if (score >= 80) {
      return 'Votre niveau de résilience est excellent. Continuez ainsi !';
    }
    if (score >= 60) {
      return 'Bon niveau général, quelques améliorations possibles.';
    }
    if (score >= 40) {
      return 'Il y a des points à améliorer pour renforcer votre sécurité.';
    }
    return 'Votre résilience nécessite des améliorations importantes.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résilience'),
        actions: [
          // Bouton refresh pour recharger les stats backend
          IconButton(
            icon: _isLoadingStats
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh),
            onPressed: _loadBackendStats,
            tooltip: 'Actualiser le score',
          ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBackendStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            MegidaiColors.primary.withOpacity(0.8),
                            MegidaiColors.secondary.withOpacity(0.8)
                          ]
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
                      'Évaluez votre niveau de protection numérique',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Score principal ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: theme.dividerColor.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
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
                                    style:
                                        theme.textTheme.displaySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _getScoreColor(_resilienceScore),
                                    ),
                                  ),
                                  Text(
                                    '/100',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withOpacity(0.7),
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
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getScoreDescription(_resilienceScore),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Statistiques backend
                      if (_statsLoaded) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatPill(
                                '$_threatsBlocked', 'Menaces bloquées',
                                MegidaiColors.safe),
                            _buildStatPill(
                                '$_communityReports', 'Signalements',
                                MegidaiColors.primary),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Badges de synthèse ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildBadge(
                        title: 'Forts',
                        count: _factors
                            .where((f) => (f['score'] as int) >= 80)
                            .length,
                        color: MegidaiColors.safe,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildBadge(
                        title: 'Passables',
                        count: _factors
                            .where((f) =>
                                (f['score'] as int) >= 50 &&
                                (f['score'] as int) < 80)
                            .length,
                        color: MegidaiColors.caution,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildBadge(
                        title: 'Critiques',
                        count: _factors
                            .where((f) => (f['score'] as int) < 50)
                            .length,
                        color: MegidaiColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Facteurs de résilience ───────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Facteurs de résilience',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _factors.length,
                itemBuilder: (context, index) =>
                    _buildFactorCard(_factors[index]),
              ),

              const SizedBox(height: 24),

              // ── Outils de souveraineté numérique ────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Système de Gamification',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/gamification'),
                        icon: const Icon(Icons.emoji_events),
                        label: const Text('Voir mes Badges et Défis'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MegidaiColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Outils Souveraineté Numérique',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/hibp_audit'),
                        icon: const Icon(Icons.mail_lock),
                        label: const Text('Audit d\'Exposition aux Fuites'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/cgu_scanner'),
                        icon: const Icon(Icons.document_scanner),
                        label: const Text('Vérifier le Nutri-Score des CGU'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MegidaiColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/resilience_test'),
                        icon: const Icon(Icons.psychology),
                        label: const Text('Lancer le test de résilience'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MegidaiBottomNav(currentRoute: '/resilience'),
    );
  }

  Widget _buildStatPill(String value, String label, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildFactorCard(Map<String, dynamic> factor) {
    final theme = Theme.of(context);
    final score = factor['score'] as int;

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _getScoreColor(score.toDouble())
                          .withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24)),
                    ),
                    child: Row(
                      children: [
                        Icon(factor['icon'],
                            color: _getScoreColor(score.toDouble()),
                            size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            factor['name'],
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(score.toDouble()),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(factor['description'],
                            style:
                                theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.5)),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Row(
                            children: [
                              const Text('Score actuel',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Text(
                                '$score/100',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getScoreColor(score.toDouble()),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Conseil : améliorez ce facteur en suivant les exercices dans la section Éducation.',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.8),
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: theme.dividerColor.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getScoreColor(score.toDouble()).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(factor['icon'],
                  color: _getScoreColor(score.toDouble()), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    factor['name'],
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    factor['description'],
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  Widget _buildBadge(
      {required String title, required int count, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(count.toString(),
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}
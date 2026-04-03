import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/bottom_nav.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart';
import '../../services/device_service.dart';

class ResultScreen extends StatefulWidget {
  final String url;
  final double score; // Score de RISQUE : 0=sûr, 100=dangereux
  final String level; // safe | suspect | danger
  final List<dynamic> reasons;
  final int analysisTimeMs;
  final int communityReports;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const ResultScreen({
    super.key,
    required this.url,
    required this.score,
    required this.onThemeToggle,
    required this.isDarkMode,
    this.level = 'safe',
    this.reasons = const [],
    this.analysisTimeMs = 0,
    this.communityReports = 0,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _reportSent = false;

  // ── Logique corrigée : score de RISQUE (0=sûr, 100=dangereux) ───────────
  bool get _isSafe     => widget.score < 41;
  bool get _isSuspect  => widget.score >= 41 && widget.score < 71;
  bool get _isDanger   => widget.score >= 71;

  Color get _levelColor {
    if (_isSafe)    return MegidaiColors.safe;
    if (_isSuspect) return MegidaiColors.caution;
    return MegidaiColors.danger;
  }

  String get _levelLabel {
    if (_isSafe)    return '🟢  Lien Sûr';
    if (_isSuspect) return '🟠  Lien Suspect';
    return '🔴  Danger — Lien Bloqué';
  }

  String get _levelDescription {
    if (_isSafe)    return 'Aucun élément suspect détecté. Ce lien semble sûr.';
    if (_isSuspect) return 'Ce lien présente des caractéristiques inhabituelles. Procédez avec prudence.';
    return 'Ce lien présente plusieurs signaux critiques d\'arnaque. Megidai recommande de ne pas continuer.';
  }

  // Grade inversé : A=sûr (score bas), E=dangereux (score élevé)
  String get _grade {
    if (widget.score <= 20) return 'A';
    if (widget.score <= 40) return 'B';
    if (widget.score <= 60) return 'C';
    if (widget.score <= 80) return 'D';
    return 'E';
  }

  Color get _gradeColor {
    switch (_grade) {
      case 'A': return const Color(0xFF059669);
      case 'B': return const Color(0xFF10B981);
      case 'C': return const Color(0xFFF59E0B);
      case 'D': return const Color(0xFFF97316);
      case 'E': return const Color(0xFFEF4444);
      default:  return MegidaiColors.primary;
    }
  }

  // ── Signaler un faux positif ──────────────────────────────────────────────
  Future<void> _reportAsSafe() async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      await ApiService.reportUrl(
        widget.url,
        'safe', // Signaler comme sûr (faux positif)
        deviceId,
        source: 'result_screen',
      );
      if (!mounted) return;
      setState(() => _reportSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Signalement envoyé. Merci de contribuer à la communauté Megidai !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  // ── Signaler comme malveillant ────────────────────────────────────────────
  Future<void> _reportAsMalicious() async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      await ApiService.reportUrl(
        widget.url,
        'malicious',
        deviceId,
        category: 'phishing',
        source: 'result_screen',
      );
      if (!mounted) return;
      setState(() => _reportSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🚨 Arnaque signalée. Vous protégez la communauté Megidai !'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  // ── Ouvrir le lien (si l'utilisateur insiste) ─────────────────────────────
  void _openLink() {
    // TODO: utiliser url_launcher pour ouvrir dans le navigateur
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ouverture dans le navigateur...'),
        backgroundColor: _isSuspect ? MegidaiColors.caution : MegidaiColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Écran ROUGE — danger critique
    if (_isDanger) {
      return Scaffold(
        backgroundColor: MegidaiColors.danger,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => context.go('/'),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.gpp_bad, size: 100, color: Colors.white),
                const SizedBox(height: 24),
                Text(
                  'Danger — Lien Bloqué',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Carte de détail
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning, color: MegidaiColors.danger),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Action bloquée automatiquement',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: MegidaiColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      // Score
                      Row(
                        children: [
                          const Text('Score de risque : ',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            '${widget.score.round()}/100',
                            style: const TextStyle(
                              color: MegidaiColors.danger,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // URL
                      Row(
                        children: [
                          const Text('URL : ',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Expanded(
                            child: Text(
                              widget.url,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      // Signalements communautaires
                      if (widget.communityReports > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Signalements : ',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            Text(
                              '${widget.communityReports} signalement(s) malveillant(s)',
                              style: const TextStyle(color: MegidaiColors.danger),
                            ),
                          ],
                        ),
                      ],
                      // Raisons
                      if (widget.reasons.isNotEmpty) ...[
                        const Divider(height: 20),
                        const Text('Raisons :',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...widget.reasons.take(3).map((r) {
                          final reason = r as Map<String, dynamic>;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(reason['icon']?.toString() ?? '⚠️'),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    reason['text']?.toString() ?? '',
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Vos données personnelles et financières sont en danger. Ne continuez pas.',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),

                // Bouton retour
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => context.go('/'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: MegidaiColors.danger,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('QUITTER IMMÉDIATEMENT',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),

                // Signaler
                if (!_reportSent)
                  TextButton(
                    onPressed: _reportAsMalicious,
                    child: const Text(
                      'Signaler cette arnaque à la communauté',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),

                // Continuer quand même
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('⚠️ Risque confirmé'),
                        content: const Text(
                            'Ce lien a été identifié comme dangereux. Êtes-vous sûr de vouloir continuer ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _openLink();
                            },
                            child: const Text('Continuer quand même',
                                style: TextStyle(color: MegidaiColors.danger)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'Continuer à mes risques',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Écran VERT ou ORANGE ──────────────────────────────────────────────
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat d\'analyse'),
        backgroundColor: _levelColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Bandeau de niveau ───────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              color: _levelColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _levelLabel,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _levelDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── Carte principale ──────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: theme.dividerColor.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        // En-tête avec URL et grade
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: _levelColor.withOpacity(0.1),
                                ),
                                child: Icon(Icons.link,
                                    color: _levelColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getDomain(widget.url),
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      DateTime.now()
                                          .toString()
                                          .split(' ')[0],
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: theme
                                            .textTheme.bodySmall?.color
                                            ?.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Badge grade
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _gradeColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: _gradeColor.withOpacity(0.4)),
                                ),
                                child: Text(
                                  _grade,
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    color: _gradeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Raisons détaillées depuis le backend
                        if (widget.reasons.isNotEmpty) ...[
                          Divider(
                              height: 1,
                              color: theme.dividerColor.withOpacity(0.4)),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pourquoi ce score ?',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 12),
                                ...widget.reasons.map((r) {
                                  final reason = r as Map<String, dynamic>;
                                  final isPositive =
                                      reason['positive'] as bool? ?? false;
                                  final points =
                                      reason['points'] as int? ?? 0;
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          reason['icon']?.toString() ?? '•',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            reason['text']?.toString() ?? '',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: theme
                                                  .textTheme.bodySmall?.color
                                                  ?.withOpacity(0.8),
                                            ),
                                          ),
                                        ),
                                        if (points != 0)
                                          Text(
                                            isPositive
                                                ? '-$points'
                                                : '+$points',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isPositive
                                                  ? MegidaiColors.safe
                                                  : MegidaiColors.danger,
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],

                        // Signalements communautaires
                        if (widget.communityReports > 0) ...[
                          Divider(
                              height: 1,
                              color: theme.dividerColor.withOpacity(0.4)),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Icon(Icons.people,
                                    size: 16, color: MegidaiColors.danger),
                                const SizedBox(width: 8),
                                Text(
                                  'Signalé ${widget.communityReports} fois par la communauté Megidai',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      color: MegidaiColors.danger),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Barre de score
                        Divider(
                            height: 1,
                            color: theme.dividerColor.withOpacity(0.4)),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Score de risque : ${widget.score.round()}/100',
                                    style:
                                        theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (widget.analysisTimeMs > 0)
                                    Text(
                                      '${widget.analysisTimeMs} ms',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Échelle A→E corrigée
                              Row(
                                children: [
                                  _buildScaleItem(
                                      'A', widget.score <= 20,
                                      const Color(0xFF059669)),
                                  _buildScaleItem(
                                      'B',
                                      widget.score > 20 && widget.score <= 40,
                                      const Color(0xFF10B981)),
                                  _buildScaleItem(
                                      'C',
                                      widget.score > 40 && widget.score <= 60,
                                      const Color(0xFFF59E0B)),
                                  _buildScaleItem(
                                      'D',
                                      widget.score > 60 && widget.score <= 80,
                                      const Color(0xFFF97316)),
                                  _buildScaleItem(
                                      'E', widget.score > 80,
                                      const Color(0xFFEF4444)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('0 — Sûr',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF059669))),
                                  Text('100 — Danger',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFFEF4444))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Boutons d'action ────────────────────────────────────
                  // Bouton retour
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.home),
                      label: const Text('Retour à l\'accueil'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Continuer quand même (seulement si pas danger)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openLink,
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Continuer quand même'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: _isSuspect
                            ? MegidaiColors.caution
                            : Colors.grey,
                        side: BorderSide(
                          color: _isSuspect
                              ? MegidaiColors.caution
                              : Colors.grey.withOpacity(0.4),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Zone de signalement
                  if (!_reportSent)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: theme.dividerColor.withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aider la communauté',
                            style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _reportAsSafe,
                                  icon: const Icon(Icons.thumb_up, size: 16),
                                  label: const Text('Sûr',
                                      style: TextStyle(fontSize: 13)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: MegidaiColors.safe,
                                    side: const BorderSide(
                                        color: MegidaiColors.safe),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _reportAsMalicious,
                                  icon: const Icon(Icons.thumb_down, size: 16),
                                  label: const Text('Arnaque',
                                      style: TextStyle(fontSize: 13)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: MegidaiColors.danger,
                                    side: const BorderSide(
                                        color: MegidaiColors.danger),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.green.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle,
                              color: MegidaiColors.safe, size: 18),
                          SizedBox(width: 8),
                          Text('Signalement envoyé — merci !',
                              style: TextStyle(color: MegidaiColors.safe)),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MegidaiBottomNav(currentRoute: '/result'),
    );
  }

  Widget _buildScaleItem(String label, bool active, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: active ? color : color.withOpacity(0.25),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: active ? color : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _getDomain(String url) {
    try {
      final uri =
          Uri.parse(url.startsWith('http') ? url : 'https://$url');
      return uri.host;
    } catch (_) {
      return url;
    }
  }
}
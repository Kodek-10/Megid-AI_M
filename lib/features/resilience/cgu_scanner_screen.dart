import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart';

class CguScannerScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const CguScannerScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<CguScannerScreen> createState() => _CguScannerScreenState();
}

class _CguScannerScreenState extends State<CguScannerScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  bool _hasResult = false;
  String _grade = 'A';
  int _riskScore = 0;
  List<dynamic> _reasons = [];
  List<String> _categories = [];

  // ── Analyser les CGU via le VRAI backend NLP ──────────────────────────────
  Future<void> _analyzeCGU() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez coller le texte des CGU à analyser')),
      );
      return;
    }

    if (text.length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Le texte est trop court pour une analyse fiable (minimum 50 caractères)')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasResult = false;
    });

    FocusScope.of(context).unfocus();

    try {
      // Appel RÉEL au backend NLP — même moteur que pour les SMS
      // On indique 'cgu_scanner' comme source pour le contexte
      final result = await ApiService.analyzeSms(
        text,
        source: 'cgu_scanner',
      );

      if (!mounted) return;

      final score = result['risk_score'] as int? ?? 0;
      final categories =
          List<String>.from(result['categories'] as List? ?? []);
      final reasons = result['reasons'] as List? ?? [];

      // Convertir le score de risque en grade A→E
      String grade;
      if (score <= 20) {
        grade = 'A';
      } else if (score <= 40) grade = 'B';
      else if (score <= 60) grade = 'C';
      else if (score <= 80) grade = 'D';
      else                  grade = 'E';

      setState(() {
        _isLoading = false;
        _hasResult = true;
        _grade = grade;
        _riskScore = score;
        _reasons = reasons;
        _categories = categories;
      });

    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur backend : ${e.message}'),
          backgroundColor: MegidaiColors.danger,
          action: SnackBarAction(label: 'Réessayer', onPressed: _analyzeCGU),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A': return MegidaiColors.safe;
      case 'B': return const Color(0xFF10B981);
      case 'C': return MegidaiColors.caution;
      case 'D': return const Color(0xFFF97316);
      case 'E': return MegidaiColors.danger;
      default:  return MegidaiColors.safe;
    }
  }

  String _getGradeDescription(String grade) {
    switch (grade) {
      case 'A': return 'Excellentes CGU. Aucun risque significatif détecté pour votre vie privée.';
      case 'B': return 'Bonnes CGU. Quelques clauses mineures à surveiller, mais rien d\'alarmant.';
      case 'C': return 'CGU moyennes. Présence de clauses de collecte de données ou de publicité ciblée.';
      case 'D': return 'CGU risquées. Clauses de partage de données avec des tiers ou accès intrusifs.';
      case 'E': return 'CGU très problématiques. Vente de données, accès invasifs, clauses abusives détectées.';
      default:  return 'Analyse terminée.';
    }
  }

  String _getGradeEmoji(String grade) {
    switch (grade) {
      case 'A': return '🟢';
      case 'B': return '🟡';
      case 'C': return '🟠';
      case 'D': return '🔴';
      case 'E': return '⛔';
      default:  return '⚪';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutri-Score CGU'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          MegidaiColors.accent.withOpacity(0.8),
                          MegidaiColors.primary.withOpacity(0.8)
                        ]
                      : [MegidaiColors.accent, MegidaiColors.primary],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Décrypter les CGU',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Collez un extrait des conditions générales pour évaluer les risques '
                    'via notre analyse NLP. Comme le Nutri-Score alimentaire, mais pour votre vie privée.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // ── Zone de texte ─────────────────────────────────────
                  TextField(
                    controller: _textController,
                    maxLines: 7,
                    decoration: InputDecoration(
                      hintText:
                          'Collez ici un extrait des Conditions Générales d\'Utilisation...\n\nEx: "Nous pouvons partager vos données avec nos partenaires..."',
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

                  const SizedBox(height: 24),

                  // ── Bouton analyser ───────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _analyzeCGU,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.document_scanner),
                      label: Text(
                          _isLoading ? 'Analyse en cours...' : 'Évaluer les CGU'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MegidaiColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  // ── Résultat ──────────────────────────────────────────
                  if (_hasResult) ...[
                    const SizedBox(height: 40),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) => Transform.scale(
                        scale: value,
                        child: Opacity(opacity: value, child: child),
                      ),
                      child: Column(
                        children: [
                          // Carte du grade principal
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: _getGradeColor(_grade).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: _getGradeColor(_grade).withOpacity(0.5),
                                width: 3,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Nutri-Score CGU',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _getGradeColor(_grade),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _getGradeEmoji(_grade),
                                      style: const TextStyle(fontSize: 40),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      _grade,
                                      style:
                                          theme.textTheme.displayLarge?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 90,
                                        color: _getGradeColor(_grade),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Barre de score
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: _riskScore / 100,
                                    minHeight: 10,
                                    backgroundColor: Colors.white24,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getGradeColor(_grade),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Score de risque : $_riskScore/100',
                                  style: TextStyle(
                                    color: _getGradeColor(_grade),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _getGradeDescription(_grade),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          // Catégories détectées
                          if (_categories.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color:
                                        theme.dividerColor.withOpacity(0.4)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Catégories détectées',
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _categories.map((cat) {
                                      final color = cat.contains('sensible') ||
                                              cat.contains('usurpation')
                                          ? MegidaiColors.danger
                                          : MegidaiColors.caution;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color:
                                                  color.withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          cat.replaceAll('_', ' '),
                                          style: TextStyle(
                                              color: color,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Détail des raisons
                          if (_reasons.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color:
                                        theme.dividerColor.withOpacity(0.4)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Détail de l\'analyse',
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  ..._reasons.map((r) {
                                    final reason = r as Map<String, dynamic>;
                                    final isPositive =
                                        reason['positive'] as bool? ?? false;
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            reason['icon']?.toString() ?? '•',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              reason['text']?.toString() ?? '',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: theme.textTheme
                                                    .bodySmall?.color
                                                    ?.withOpacity(0.8),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            isPositive ? '✅' : '⚠️',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],

                          // Bouton réinitialiser
                          const SizedBox(height: 20),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _hasResult = false;
                                _textController.clear();
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Analyser un autre texte'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
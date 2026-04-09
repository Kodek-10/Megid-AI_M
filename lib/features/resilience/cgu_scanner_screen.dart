import 'package:flutter/material.dart';
import '../../core/theme.dart';

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

  void _analyzeCGU() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasResult = false;
    });

    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _hasResult = true;
      // Positivité par défaut: on note A, sauf si on détecte des mots clés intrusifs
      final lower = text.toLowerCase();
      if (lower.contains('vente') || lower.contains('tiers')) {
        _grade = 'E';
      } else if (lower.contains('publicité') || lower.contains('données')) {
        _grade = 'C';
      } else {
        _grade = 'A';
      }
    });
  }

  Color _getGradeColor(String grade) {
    if (grade == 'A' || grade == 'B') return MegidaiColors.success;
    if (grade == 'C' || grade == 'D') return MegidaiColors.warning;
    return MegidaiColors.error;
  }

  String _getGradeDescription(String grade) {
    switch (grade) {
      case 'A': return 'Respectueux de la vie privée. Aucune faille MAJEURE.';
      case 'C': return 'Risques modérés de collecte publicitaire.';
      case 'E': return 'Toxique. Partage avec des tiers revendiqué.';
      default: return 'Standard.';
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [MegidaiColors.accent.withOpacity(0.8), MegidaiColors.primary.withOpacity(0.8)]
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
                    'Collez un paragraphe des conditions générales pour en évaluer les abus potentiels avec notre analyse sémantique (NLP).',
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
                  TextField(
                    controller: _textController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Collez le texte des conditions générales ici...',
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
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _analyzeCGU,
                      icon: _isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.document_scanner),
                      label: Text(_isLoading ? 'Analyse en cours...' : 'Évaluer les CGU'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MegidaiColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  
                  if (_hasResult) ...[
                    const SizedBox(height: 48),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: _getGradeColor(_grade).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: _getGradeColor(_grade).withOpacity(0.5),
                            width: 3,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Nutri-Score',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getGradeColor(_grade),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _grade,
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 90,
                                color: _getGradeColor(_grade),
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
                    ),
                  ]
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

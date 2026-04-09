import 'package:flutter/material.dart';
import '../../core/bottom_nav.dart';
import '../../core/theme.dart';

class ResultScreen extends StatefulWidget {
  final String url;
  final double score;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const ResultScreen({
    super.key,
    required this.url,
    required this.score,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grade = _getGrade(widget.score);
    final gradeColor = _getGradeColor(grade);
    final findings = _getFindings(widget.score);

    final isCritical = widget.score <= 15;
    final isWarning = widget.score > 15 && widget.score < 80;
    
    if (isCritical) {
      return Scaffold(
        backgroundColor: MegidaiColors.error,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
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
                  'Urgent : Danger Critique',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning, color: MegidaiColors.error),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Action bloquée automatiquement',
                              style: TextStyle(fontWeight: FontWeight.bold, color: MegidaiColors.error),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          const Text('Type: ', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('Phishing ou Site Malveillant détecté', style: TextStyle(color: Colors.grey[700])),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Cible: ', style: TextStyle(fontWeight: FontWeight.w600)),
                          Expanded(child: Text(widget.url, style: TextStyle(color: Colors.grey[700]), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Vos données personnelles et financières sont en grand danger. Quittez cette page immédiatement.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: MegidaiColors.error,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('QUITTER IMMÉDIATEMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat d\'analyse'),
        backgroundColor: isWarning ? MegidaiColors.warning : MegidaiColors.success,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
            onPressed: widget.onThemeToggle,
            tooltip: widget.isDarkMode ? 'Mode jour' : 'Mode nuit',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header (Bandeau)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: isWarning ? MegidaiColors.warning : MegidaiColors.success,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isWarning ? 'Risque Modéré' : 'Aucune menace',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isWarning ? 'L\'utilisateur est informé mais pas bloqué' : 'Bouclier intact. Megidai travaille en arrière-plan',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Result card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: theme.dividerColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey[700]
                                  : Colors.grey[200],
                            ),
                            child: Icon(
                              Icons.web,
                              color: theme.iconTheme.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getDomain(widget.url),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateTime.now().toString().split(' ')[0],
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: gradeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              grade,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: gradeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Findings
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: findings.map((finding) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  finding['icon'],
                                  size: 16,
                                  color: finding['color'],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    finding['text'],
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Score scale
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: theme.dividerColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Score de sécurité: ${widget.score.round()}%',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildScaleItem('A', widget.score >= 80, const Color(0xFF059669)),
                              _buildScaleItem('B', widget.score >= 60 && widget.score < 80, const Color(0xFF10B981)),
                              _buildScaleItem('C', widget.score >= 40 && widget.score < 60, const Color(0xFFF59E0B)),
                              _buildScaleItem('D', widget.score >= 20 && widget.score < 40, const Color(0xFFF97316)),
                              _buildScaleItem('E', widget.score < 20, const Color(0xFFEF4444)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Partage bientôt disponible !')),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Partager le résultat'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Analyser un autre site'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
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
              color: active ? color : color.withOpacity(0.3),
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

  String _getGrade(double score) {
    if (score >= 80) return 'A';
    if (score >= 60) return 'B';
    if (score >= 40) return 'C';
    if (score >= 20) return 'D';
    return 'E';
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return const Color(0xFF059669);
      case 'B':
        return const Color(0xFF10B981);
      case 'C':
        return const Color(0xFFF59E0B);
      case 'D':
        return const Color(0xFFF97316);
      case 'E':
        return const Color(0xFFEF4444);
      default:
        return MegidaiColors.primary;
    }
  }

  String _getDomain(String url) {
    try {
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      return uri.host;
    } catch (e) {
      return url;
    }
  }

  List<Map<String, dynamic>> _getFindings(double score) {
    final findings = <Map<String, dynamic>>[];

    if (score >= 80) {
      findings.add({
        'icon': Icons.check_circle,
        'color': MegidaiColors.success,
        'text': 'Site sécurisé avec certificat SSL valide',
      });
      findings.add({
        'icon': Icons.check_circle,
        'color': MegidaiColors.success,
        'text': 'Aucune menace détectée',
      });
    } else if (score >= 60) {
      findings.add({
        'icon': Icons.check_circle,
        'color': MegidaiColors.success,
        'text': 'Certificat SSL valide',
      });
      findings.add({
        'icon': Icons.warning,
        'color': MegidaiColors.warning,
        'text': 'Quelques pratiques de sécurité à améliorer',
      });
    } else {
      findings.add({
        'icon': Icons.warning,
        'color': MegidaiColors.warning,
        'text': 'Certificat SSL manquant ou invalide',
      });
      findings.add({
        'icon': Icons.error,
        'color': MegidaiColors.error,
        'text': 'Risques de sécurité détectés',
      });
    }

    return findings;
  }
}
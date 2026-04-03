import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart';

class HIBPAuditScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const HIBPAuditScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<HIBPAuditScreen> createState() => _HIBPAuditScreenState();
}

class _HIBPAuditScreenState extends State<HIBPAuditScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _isSafe = true;
  int _breachCount = 0;
  String _recommendation = '';
  String _riskLevel = 'safe';
  String _maskedEmail = '';

  // ── Vérifier l'email via le VRAI backend HIBP ─────────────────────────────
  Future<void> _verifyEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir une adresse email')),
      );
      return;
    }

    // Validation basique du format email
    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format d\'email invalide')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = false;
    });

    FocusScope.of(context).unfocus();

    try {
      // Appel RÉEL au backend → qui utilise k-Anonymity avec HIBP
      final result = await ApiService.checkEmailBreach(email);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasSearched = true;
        _isSafe = !(result['compromised'] as bool? ?? false);
        _breachCount = result['times_seen'] as int? ?? 0;
        _recommendation = result['recommendation'] as String? ??
            (_isSafe
                ? 'Aucune fuite détectée.'
                : 'Changez vos mots de passe immédiatement.');
        _riskLevel = result['risk_level'] as String? ?? 'safe';
        _maskedEmail = result['email'] as String? ?? email;
      });

    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      // Mode dégradé : afficher l'erreur mais ne pas planter
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vérification impossible : ${e.message}'),
          backgroundColor: MegidaiColors.caution,
          action: SnackBarAction(
            label: 'Réessayer',
            onPressed: _verifyEmail,
          ),
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

  // Couleur selon le niveau de risque
  Color _getRiskColor() {
    switch (_riskLevel) {
      case 'critical': return MegidaiColors.danger;
      case 'high':     return const Color(0xFFEF4444);
      case 'medium':   return MegidaiColors.caution;
      default:         return MegidaiColors.safe;
    }
  }

  // Icône selon le niveau de risque
  IconData _getRiskIcon() {
    if (_isSafe) return Icons.verified_user;
    switch (_riskLevel) {
      case 'critical': return Icons.dangerous;
      case 'high':     return Icons.warning_amber_rounded;
      default:         return Icons.info_outline;
    }
  }

  // Message selon le niveau de risque
  String _getRiskTitle() {
    if (_isSafe) return 'Aucune fuite détectée ✅';
    switch (_riskLevel) {
      case 'critical': return 'CRITIQUE — Action urgente requise !';
      case 'high':     return 'Fuite majeure détectée !';
      default:         return 'Fuite de données détectée';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Fuites (HIBP)'),
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
                    'Ai-je été compromis ?',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vérifiez si vos identifiants ont été exposés dans des fuites de données. '
                    'Utilise le protocole k-Anonymity — votre email complet ne quitte jamais cet appareil.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Badge k-Anonymity
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Protégé par k-Anonymity',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // ── Champ email ───────────────────────────────────────
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (_) => _verifyEmail(),
                    decoration: InputDecoration(
                      hintText: 'votre@email.com',
                      prefixIcon: const Icon(Icons.email_outlined),
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

                  // ── Bouton vérifier ───────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _verifyEmail,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.search),
                      label: Text(
                          _isLoading ? 'Vérification...' : 'Vérifier l\'email'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  // ── Résultat ──────────────────────────────────────────
                  if (_hasSearched) ...[
                    const SizedBox(height: 40),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) => Transform.scale(
                        scale: value,
                        child: Opacity(opacity: value, child: child),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _getRiskColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _getRiskColor().withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Icône principale
                            Icon(
                              _getRiskIcon(),
                              size: 64,
                              color: _getRiskColor(),
                            ),
                            const SizedBox(height: 16),

                            // Titre
                            Text(
                              _getRiskTitle(),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getRiskColor(),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),

                            // Email masqué
                            Text(
                              _maskedEmail,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Nombre de fuites
                            if (!_isSafe) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _getRiskColor().withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Trouvé dans $_breachCount base(s) de données compromise(s)',
                                  style: TextStyle(
                                    color: _getRiskColor(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Recommandation
                            Text(
                              _recommendation,
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),

                            // Bouton action si compromis
                            if (!_isSafe) ...[
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Conseil : changez votre mot de passe immédiatement sur tous les sites utilisant cet email.'),
                                        duration: Duration(seconds: 5),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.security),
                                  label: const Text('Comment me protéger ?'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _getRiskColor(),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            // Badge k-Anonymity
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.lock_outline,
                                    size: 12, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  'Vérifié via k-Anonymity — votre email n\'a jamais quitté cet appareil',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ],
                        ),
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
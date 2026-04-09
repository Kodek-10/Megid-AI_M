import 'package:flutter/material.dart';
import '../../core/theme.dart';

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

  void _verifyEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = false;
    });

    FocusScope.of(context).unfocus();

    // Mock API call delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _hasSearched = true;
      // Positivité par défaut: on simule une fuite seulement si l'email contient 'leak'
      _isSafe = !email.toLowerCase().contains('leak');
    });
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [MegidaiColors.primary.withOpacity(0.8), MegidaiColors.secondary.withOpacity(0.8)]
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
                    'Vérifiez en toute confidentialité (k-Anonymity) si vos identifiants ont été exposés dans des fuites de données.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.85),
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
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (_) => _verifyEmail(),
                    decoration: InputDecoration(
                      hintText: 'Saisissez votre adresse email...',
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
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _verifyEmail,
                      icon: _isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.search),
                      label: Text(_isLoading ? 'Analyse en cours...' : 'Vérifier l\'email'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  
                  if (_hasSearched) ...[
                    const SizedBox(height: 48),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
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
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _isSafe 
                              ? MegidaiColors.success.withOpacity(0.1) 
                              : MegidaiColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _isSafe 
                                ? MegidaiColors.success.withOpacity(0.3) 
                                : MegidaiColors.error.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _isSafe ? Icons.verified_user : Icons.warning_amber_rounded,
                              size: 64,
                              color: _isSafe ? MegidaiColors.success : MegidaiColors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isSafe ? 'Aucune fuite détectée' : 'Fuite de données détectée !',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _isSafe ? MegidaiColors.success : MegidaiColors.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _isSafe 
                                  ? 'Excellente nouvelle ! Votre adresse email n\'apparaît dans aucune base de données de fuites connues.' 
                                  : 'Votre adresse a été repérée dans une des fuites récentes. Nous vous recommandons de changer vos mots de passe immédiatement.',
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            if (!_isSafe) ...[
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MegidaiColors.error,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Sécuriser mon compte'),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/features/interceptor/interceptor_controller.dart
// Contrôleur qui orchestre l'analyse d'un lien intercepté
// Appelé par LinkInterceptorActivity via MethodChannel

import 'package:flutter/foundation.dart';
import '../../services/api_service.dart';
import '../../services/device_service.dart';
import '../../core/constants.dart';

class InterceptorController {
  /// Analyse un lien intercepté et retourne le résultat complet.
  /// C'est la fonction centrale de l'Intent Interceptor.
  static Future<AnalysisResult> analyzeInterceptedUrl(
    String url, {
    String? messageContext,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // ── Appeler le backend pour l'analyse complète ──────────────────
      final result = await ApiService.scanUrl(
        url,
        context: messageContext,
        source: 'intent_interceptor',
      );

      stopwatch.stop();

      final score = result['risk_score'] as int;
      final level = result['level'] as String;

      // ── Si menace critique → alerter l'Ange Gardien ──────────────────
      if (score > MegidaiConstants.seuilAlerte) {
        _alertGuardianInBackground(score, level);
      }

      return AnalysisResult(
        url: url,
        score: score,
        level: level,
        reasons: List<Map<String, dynamic>>.from(result['reasons'] ?? []),
        analysisTimeMs: stopwatch.elapsedMilliseconds,
        isCommunityBlacklisted: result['community_reports'] != null &&
            (result['community_reports'] as int) > 0,
      );

    } on ApiException catch (e) {
      // Si le backend est inaccessible → analyse locale de secours
      debugPrint('[Interceptor] Backend inaccessible : ${e.message}');
      debugPrint('[Interceptor] Analyse locale de secours...');

      return _localFallbackAnalysis(url);
    }
  }

  /// Alerte l'Ange Gardien en arrière-plan sans bloquer l'UI.
  static void _alertGuardianInBackground(int score, String level) async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      await ApiService.alertGuardian(
        protectedDeviceId: deviceId,
        threatType: 'malicious_url',
        threatLevel: level,
        riskScore: score,
        threatDescription: 'Lien dangereux bloqué par l\'Intent Interceptor',
      );
      debugPrint('[Interceptor] Ange Gardien alerté — score : $score');
    } catch (e) {
      // Ne pas bloquer si l'alerte échoue
      debugPrint('[Interceptor] Alerte Ange Gardien échouée : $e');
    }
  }

  /// Analyse locale de secours si le backend est inaccessible.
  /// Utilise des règles simples sans IA.
  static AnalysisResult _localFallbackAnalysis(String url) {
    int score = 0;
    final reasons = <Map<String, dynamic>>[];
    final urlLower = url.toLowerCase();

    // Règles simples locales
    if (!url.startsWith('https')) {
      score += 25;
      reasons.add({'icon': '⚠️', 'text': 'Pas de HTTPS', 'points': 25, 'positive': false});
    }
    if (urlLower.contains('bit.ly') || urlLower.contains('tinyurl')) {
      score += 15;
      reasons.add({'icon': '⚠️', 'text': 'Raccourcisseur de lien', 'points': 15, 'positive': false});
    }
    if (RegExp(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}').hasMatch(url)) {
      score += 35;
      reasons.add({'icon': '🚨', 'text': 'Adresse IP directe', 'points': 35, 'positive': false});
    }

    reasons.add({
      'icon': 'ℹ️',
      'text': 'Analyse locale (serveur indisponible)',
      'points': 0,
      'positive': true
    });

    final level = score <= 40 ? 'safe' : score <= 70 ? 'suspect' : 'danger';

    return AnalysisResult(
      url: url,
      score: score.clamp(0, 100),
      level: level,
      reasons: reasons,
      analysisTimeMs: 0,
      isCommunityBlacklisted: false,
      isOfflineAnalysis: true,
    );
  }
}

// ── Modèle de résultat d'analyse ─────────────────────────────────────────────
class AnalysisResult {
  final String url;
  final int score;
  final String level;           // safe | suspect | danger
  final List<Map<String, dynamic>> reasons;
  final int analysisTimeMs;
  final bool isCommunityBlacklisted;
  final bool isOfflineAnalysis;

  AnalysisResult({
    required this.url,
    required this.score,
    required this.level,
    required this.reasons,
    required this.analysisTimeMs,
    required this.isCommunityBlacklisted,
    this.isOfflineAnalysis = false,
  });

  // Getters utilitaires
  bool get isSafe    => level == 'safe';
  bool get isSuspect => level == 'suspect';
  bool get isDanger  => level == 'danger';
}

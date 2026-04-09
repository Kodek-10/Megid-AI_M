// lib/services/sms_service.dart
// Service de lecture et analyse des SMS
// Utilise la permission READ_SMS pour accéder aux messages

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';
import 'api_service.dart';
import 'device_service.dart';
import '../core/constants.dart';

class SmsService {
  static final Telephony _telephony = Telephony.instance;

  // ── Demander les permissions ───────────────────────────────────────────────

  /// Demande les permissions READ_SMS et RECEIVE_SMS.
  /// Retourne true si les permissions sont accordées.
  static Future<bool> requestPermissions() async {
    final smsStatus = await Permission.sms.request();
    return smsStatus.isGranted;
  }

  // ── Écouter les SMS entrants en temps réel ────────────────────────────────

  /// Démarre l'écoute des SMS entrants.
  /// Chaque nouveau SMS est automatiquement analysé par le backend.
  static void startListening({
    required Function(SmsAnalysisEvent) onThreatDetected,
  }) {
    _telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) async {
        final body = message.body ?? '';
        if (body.isEmpty) return;

        debugPrint('[SMS] Nouveau SMS reçu — analyse en cours...');

        try {
          // Envoyer au backend pour analyse NLP
          final result = await ApiService.analyzeSms(body, source: 'sms');
          final score = result['risk_score'] as int;
          final level = result['level'] as String;

          debugPrint('[SMS] Score : $score/100 — Niveau : $level');

          // Notifier l'app si menace détectée
          if (score > MegidaiConstants.seuilVert) {
            onThreatDetected(SmsAnalysisEvent(
              smsBody: body,
              senderAddress: message.address ?? 'Inconnu',
              score: score,
              level: level,
              reasons: List<Map<String, dynamic>>.from(
                result['reasons'] ?? [],
              ),
            ));

            // Si critique → alerter l'Ange Gardien
            if (score > MegidaiConstants.seuilAlerte) {
              _alertGuardian(score, level);
            }
          }
        } catch (e) {
          debugPrint('[SMS] Erreur analyse : $e');
        }
      },
      // Écouter les SMS en arrière-plan aussi
      listenInBackground: false,
    );

    debugPrint('[SMS] Écoute des SMS démarrée');
  }

  // ── Scanner tous les SMS existants ────────────────────────────────────────

  /// Scanne tous les SMS de la boîte de réception.
  /// Appelé au premier lancement de l'app.
  /// Retourne un résumé des menaces trouvées.
  static Future<SmsScanSummary> scanAllSms({int limit = 50}) async {
    try {
      // Récupérer les SMS de la boîte de réception
      final messages = await _telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
        filter: SmsFilter.where(SmsColumn.BODY).greaterThan(''),
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
      );

      if (messages.isEmpty) {
        return SmsScanSummary(total: 0, dangerous: 0, suspect: 0);
      }

      // Prendre les N plus récents
      final recent = messages.take(limit).toList();
      final bodies = recent
          .map((sms) => sms.body ?? '')
          .where((body) => body.isNotEmpty)
          .toList();

      if (bodies.isEmpty) {
        return SmsScanSummary(total: 0, dangerous: 0, suspect: 0);
      }

      // Envoyer au backend pour analyse batch
      final result = await ApiService.analyzeSmsBatch(bodies);

      return SmsScanSummary(
        total: result['total_analyzed'] as int,
        dangerous: result['dangerous'] as int,
        suspect: result['suspect'] as int,
      );

    } catch (e) {
      debugPrint('[SMS] Erreur scan batch : $e');
      return SmsScanSummary(total: 0, dangerous: 0, suspect: 0);
    }
  }

  /// Alerte l'Ange Gardien en arrière-plan.
  static void _alertGuardian(int score, String level) async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      await ApiService.alertGuardian(
        protectedDeviceId: deviceId,
        threatType: 'phishing_sms',
        threatLevel: level,
        riskScore: score,
        threatDescription: 'SMS de phishing détecté',
      );
    } catch (e) {
      debugPrint('[SMS] Alerte Ange Gardien échouée : $e');
    }
  }
}

// ── Modèles de données ────────────────────────────────────────────────────────

class SmsAnalysisEvent {
  final String smsBody;
  final String senderAddress;
  final int score;
  final String level;
  final List<Map<String, dynamic>> reasons;

  SmsAnalysisEvent({
    required this.smsBody,
    required this.senderAddress,
    required this.score,
    required this.level,
    required this.reasons,
  });
}

class SmsScanSummary {
  final int total;
  final int dangerous;
  final int suspect;
  int get safe => total - dangerous - suspect;

  SmsScanSummary({
    required this.total,
    required this.dangerous,
    required this.suspect,
  });
}

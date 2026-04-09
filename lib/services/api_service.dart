// lib/services/api_service.dart
// Service central de communication avec le backend Megidai
// Tous les appels HTTP vers FastAPI passent par ce fichier

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

// Exception personnalisée pour les erreurs API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (code: $statusCode)';
}

class ApiService {
  // URL de base du backend — définie dans constants.dart
  static const String _base = MegidaiConstants.backendUrl;

  // Timeout par défaut pour toutes les requêtes
  static const Duration _timeout = Duration(seconds: 10);

  // Headers JSON standard
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ── Méthode utilitaire : envoyer une requête POST ─────────────────────────
  static Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_base$endpoint'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        'Impossible de joindre le serveur. Vérifiez votre connexion.',
      );
    } on TimeoutException {
      throw ApiException('Le serveur ne répond pas. Réessayez.');
    } catch (e) {
      throw ApiException('Erreur inattendue : $e');
    }
  }

  // ── Méthode utilitaire : envoyer une requête GET ──────────────────────────
  static Future<Map<String, dynamic>> _get(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('$_base$endpoint'), headers: _headers)
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Impossible de joindre le serveur.');
    } on TimeoutException {
      throw ApiException('Le serveur ne répond pas.');
    } catch (e) {
      throw ApiException('Erreur inattendue : $e');
    }
  }

  // ── Méthode utilitaire : traiter la réponse HTTP ──────────────────────────
  static Map<String, dynamic> _handleResponse(http.Response response) {
    // Décoder le JSON de la réponse
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    // Vérifier le code HTTP
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data; // Succès
    } else {
      // Erreur serveur
      final detail = data['detail'] ?? 'Erreur inconnue';
      throw ApiException(detail.toString(), statusCode: response.statusCode);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MODULE 1 — ANALYSE D'URLS (Intent Interceptor)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Analyse une URL et retourne le score de risque Megidai.
  /// Appelé par l'Intent Interceptor Flutter à chaque clic sur un lien.
  ///
  /// Retourne :
  /// - risk_score (int 0-100)
  /// - level (String : safe/suspect/danger)
  /// - reasons (List : raisons de la décision)
  static Future<Map<String, dynamic>> scanUrl(
    String url, {
    String? context,
    String source = 'flutter',
  }) async {
    return await _post('/reputation/scan', {
      'url': url,
      'context': context ?? '',
      'source': source,
    });
  }

  /// Signale une URL comme malveillante ou sûre (faux positif).
  static Future<void> reportUrl(
    String url,
    String reportType, // 'malicious' ou 'safe'
    String deviceId, {
    String? category,
    String source = 'flutter',
  }) async {
    await _post('/reputation/report', {
      'url': url,
      'report_type': reportType,
      'device_id': deviceId,
      'category': category,
      'source': source,
    });
  }

  /// Récupère les statistiques globales de la plateforme.
  static Future<Map<String, dynamic>> getStats() async {
    return await _get('/reputation/stats');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MODULE 2 — ANALYSE NLP (SMS et messages)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Analyse un SMS ou message pour détecter le phishing.
  /// Appelé pour chaque SMS reçu via READ_SMS.
  static Future<Map<String, dynamic>> analyzeSms(
    String text, {
    String source = 'sms',
  }) async {
    return await _post('/nlp/analyze', {
      'text': text,
      'source': source,
    });
  }

  /// Analyse plusieurs messages en une seule requête.
  /// Utilisé au premier lancement pour scanner toute la boîte SMS.
  static Future<Map<String, dynamic>> analyzeSmsBatch(
    List<String> messages,
  ) async {
    return await _post('/nlp/analyze-batch', {
      'messages': messages,
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MODULE 3 — HIBP (Fuites de données)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Vérifie si un email a été compromis dans une fuite de données.
  /// Utilise k-Anonymity — l'email complet ne quitte jamais l'appareil.
  static Future<Map<String, dynamic>> checkEmailBreach(String email) async {
    return await _post('/hibp/check-email', {'email': email});
  }

  /// Vérifie si un mot de passe a été compromis.
  static Future<Map<String, dynamic>> checkPasswordBreach(
    String password,
  ) async {
    return await _post('/hibp/check-password', {'password': password});
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MODULE 4 — FEDERATED LEARNING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Envoie les gradients au serveur pour le Federated Learning.
  /// Appelé automatiquement la nuit quand le téléphone est en charge + WiFi.
  static Future<Map<String, dynamic>> sendGradients({
    required String deviceId,
    required List<List<double>> gradients,
    required int numSamples,
    required String modelVersion,
  }) async {
    return await _post('/federated/gradients', {
      'device_id': deviceId,
      'model_version': modelVersion,
      'gradients': gradients,
      'num_samples': numSamples,
    });
  }

  /// Récupère les infos du modèle global actuel.
  /// L'app vérifie au démarrage si une mise à jour est disponible.
  static Future<Map<String, dynamic>> getLatestModel() async {
    return await _get('/federated/model/latest');
  }

  /// Récupère le statut du Federated Learning.
  static Future<Map<String, dynamic>> getFederatedStatus() async {
    return await _get('/federated/status');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MODULE 5 — MODE ANGE GARDIEN
  // ═══════════════════════════════════════════════════════════════════════════

  /// Enregistre le token FCM de l'appareil pour les notifications.
  /// Appelé au démarrage de l'app.
  static Future<void> registerDevice(
    String deviceId,
    String fcmToken,
  ) async {
    await _post('/guardian/register-device', {
      'device_id': deviceId,
      'fcm_token': fcmToken,
    });
  }

  /// Crée une relation Protégé ↔ Ange Gardien.
  static Future<Map<String, dynamic>> createGuardianPair({
    required String protectedDeviceId,
    required String guardianDeviceId,
    required String guardianFcmToken,
    required String protectedName,
    String sensitivityMode = 'balanced',
  }) async {
    return await _post('/guardian/pair', {
      'protected_device_id': protectedDeviceId,
      'guardian_device_id': guardianDeviceId,
      'guardian_fcm_token': guardianFcmToken,
      'protected_name': protectedName,
      'sensitivity_mode': sensitivityMode,
    });
  }

  /// Alerte les Anges Gardiens d'une menace critique.
  /// Appelé automatiquement quand score > 85.
  static Future<void> alertGuardian({
    required String protectedDeviceId,
    required String threatType,
    required String threatLevel,
    required int riskScore,
    String? threatDescription,
  }) async {
    await _post('/guardian/alert', {
      'protected_device_id': protectedDeviceId,
      'threat_type': threatType,
      'threat_level': threatLevel,
      'risk_score': riskScore,
      'threat_description': threatDescription ?? '',
    });
  }

  /// Récupère la liste des Anges Gardiens d'un utilisateur.
  static Future<Map<String, dynamic>> getMyGuardians(
    String deviceId,
  ) async {
    return await _get('/guardian/guardians/$deviceId');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILITAIRE — Vérifier la connectivité avec le backend
  // ═══════════════════════════════════════════════════════════════════════════

  /// Vérifie si le backend est accessible.
  /// Appelé au démarrage pour afficher l'état de la connexion.
  static Future<bool> isBackendReachable() async {
    try {
      final response = await http
          .get(Uri.parse('$_base/health'), headers: _headers)
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

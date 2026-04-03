// lib/services/device_service.dart
// Gère l'identifiant unique de l'appareil et le token FCM
// L'identifiant est généré localement — aucune donnée personnelle

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceService {
  // Stockage sécurisé local (chiffré sur l'appareil)
  static const _storage = FlutterSecureStorage();

  // Clés de stockage
  static const _keyDeviceId  = 'megidai_device_id';
  static const _keyFcmToken  = 'megidai_fcm_token';
  static const _keyModelVer  = 'megidai_model_version';

  // ── Identifiant anonyme de l'appareil ─────────────────────────────────────

  /// Retourne l'identifiant unique de l'appareil.
  /// Si l'identifiant n'existe pas encore, en crée un nouveau.
  /// Cet identifiant est aléatoire — pas lié à l'identité de l'utilisateur.
  static Future<String> getDeviceId() async {
    // Essayer de lire l'ID existant
    String? existingId = await _storage.read(key: _keyDeviceId);

    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }

    // Générer un nouvel ID aléatoire de 32 caractères
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure(); // Random.secure = cryptographiquement sûr
    final newId = List.generate(
      32,
      (_) => chars[random.nextInt(chars.length)],
    ).join();

    // Sauvegarder pour les prochaines sessions
    await _storage.write(key: _keyDeviceId, value: newId);

    debugPrint('[Device] Nouvel ID créé : ${newId.substring(0, 8)}...');
    return newId;
  }

  // ── Token FCM ──────────────────────────────────────────────────────────────

  /// Sauvegarde le token FCM Firebase.
  static Future<void> saveFcmToken(String token) async {
    await _storage.write(key: _keyFcmToken, value: token);
    debugPrint('[Device] FCM token sauvegardé : ${token.substring(0, 20)}...');
  }

  /// Récupère le token FCM sauvegardé.
  static Future<String?> getFcmToken() async {
    return await _storage.read(key: _keyFcmToken);
  }

  // ── Version du modèle ──────────────────────────────────────────────────────

  /// Sauvegarde la version du modèle IA actuel sur l'appareil.
  static Future<void> saveModelVersion(String version) async {
    await _storage.write(key: _keyModelVer, value: version);
  }

  /// Récupère la version du modèle IA actuel.
  static Future<String> getModelVersion() async {
    return await _storage.read(key: _keyModelVer) ?? '1.0.0';
  }

  // ── Réinitialisation ───────────────────────────────────────────────────────

  /// Supprime toutes les données locales de l'appareil.
  /// Appelé quand l'utilisateur supprime son compte Megidai.
  static Future<void> clearAll() async {
    await _storage.deleteAll();
    debugPrint('[Device] Toutes les données locales supprimées.');
  }
}

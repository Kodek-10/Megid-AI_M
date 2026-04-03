// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/api_service.dart';
import 'services/device_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Initialiser Firebase ──────────────────────────────────────────────
  await Firebase.initializeApp();

  // ── Enregistrer le token FCM au démarrage ────────────────────────────
  await _initializeNotifications();

  // ── Vérifier la connectivité avec le backend ─────────────────────────
  final isOnline = await ApiService.isBackendReachable();
  debugPrint('[Main] Backend accessible : $isOnline');

  runApp(MegidaiApp(isBackendOnline: isOnline));
}

Future<void> _initializeNotifications() async {
  final messaging = FirebaseMessaging.instance;

  // Demander la permission de notifications (iOS)
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Récupérer le token FCM
  final fcmToken = await messaging.getToken();
  if (fcmToken != null) {
    // Sauvegarder localement
    await DeviceService.saveFcmToken(fcmToken);

    // Enregistrer sur le backend
    final deviceId = await DeviceService.getDeviceId();
    try {
      await ApiService.registerDevice(deviceId, fcmToken);
      debugPrint('[Main] Appareil enregistré sur le backend');
    } catch (e) {
      debugPrint('[Main] Enregistrement backend échoué : $e');
    }
  }

  // Écouter les rafraîchissements du token FCM
  messaging.onTokenRefresh.listen((newToken) async {
    await DeviceService.saveFcmToken(newToken);
    final deviceId = await DeviceService.getDeviceId();
    try {
      await ApiService.registerDevice(deviceId, newToken);
    } catch (_) {}
  });
}

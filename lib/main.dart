// lib/main.dart

// 'import' = équivalent de 'import' en Python ou 'require' en Node.js
import 'package:flutter/material.dart';       // Framework Flutter de base
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart'; // Firebase (notifications)
import 'core/theme.dart';                     // Notre thème Megidai
import 'app.dart';                            // Notre widget racine (à créer)

// 'Future<void>' = fonction asynchrone qui ne retourne rien
// 'async' = permet d'utiliser 'await' dans la fonction
Future<void> main() async {

  // WidgetsFlutterBinding.ensureInitialized() DOIT être appelé en premier
  // quand on fait des opérations asynchrones avant runApp()
  // Il initialise le moteur Flutter avant que l'app démarre
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase seulement sur mobile (Android, iOS)
  // Sur le web, Firebase est initialisé automatiquement via le SDK web
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      // Firebase non configuré - continue sans Firebase
      print('Firebase init failed: $e');
    }
  }

  // runApp() lance l'application Flutter
  // Elle prend le widget racine en paramètre
  runApp(const MegidaiApp());
}

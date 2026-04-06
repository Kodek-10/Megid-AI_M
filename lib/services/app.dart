// lib/services/app.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Notre système de navigation
import '../core/theme.dart';
import '../features/home/home_screen.dart';               // Écran d'accueil
import '../features/interceptor/result_screen.dart';      // Résultat d'analyse
import '../features/angel_guardian/guardian_screen.dart'; // Ange Gardien
import '../features/resilience/resilience_screen.dart';   // Score de résilience
import '../features/education/education_screen.dart';     // Modules éducatifs

// Widget racine — Stateful pour gérer le thème
class MegidaiApp extends StatefulWidget {
  const MegidaiApp({super.key});

  @override
  State<MegidaiApp> createState() => _MegidaiAppState();
}

class _MegidaiAppState extends State<MegidaiApp> {
  ThemeMode _themeMode = ThemeMode.dark; // Commence en mode sombre

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  // _router définit toutes les routes (écrans) de l'application
  // 'static' : appartient à la classe, pas aux instances
  // 'final' : ne peut pas être réassigné après initialisation
  GoRouter get _router => GoRouter(
    // Route initiale : l'écran qui s'affiche au démarrage
    initialLocation: '/',

    // Liste de toutes les routes disponibles
    routes: [
      GoRoute(
        path: '/',               // URL de la route
        builder: (context, state) => HomeScreen(onThemeToggle: _toggleTheme, isDarkMode: _themeMode == ThemeMode.dark),
      ),
      GoRoute(
        path: '/result',         // Affiché après analyse d'un lien
        builder: (context, state) {
          // state.extra contient les données passées à cet écran
          // On les récupère et les transmet au widget
          final args = state.extra as Map<String, dynamic>?;
          return ResultScreen(
            url: args?['url'] ?? '',
            score: args?['score'] ?? 0.0,
          );
        },
      ),
      GoRoute(
        path: '/guardian',
        builder: (context, state) => const GuardianScreen(),
      ),
      GoRoute(
        path: '/resilience',
        builder: (context, state) => const ResilienceScreen(),
      ),
      GoRoute(
        path: '/education',
        builder: (context, state) => const EducationScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Megidai - Bouclier Numérique',
      theme: MegidaiTheme.lightTheme,
      darkTheme: MegidaiTheme.darkTheme,
      themeMode: _themeMode,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
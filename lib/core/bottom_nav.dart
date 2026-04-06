import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MegidaiBottomNav extends StatelessWidget {
  const MegidaiBottomNav({
    super.key,
    required this.currentRoute,
  });

  final String currentRoute;

  int get _currentIndex {
    switch (currentRoute) {
      case '/guardian':
        return 1;
      case '/resilience':
        return 2;
      case '/education':
        return 3;
      case '/result':
        return 0;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/guardian');
            break;
          case 2:
            context.go('/resilience');
            break;
          case 3:
            context.go('/education');
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        NavigationDestination(
          icon: Icon(Icons.shield_outlined),
          selectedIcon: Icon(Icons.shield),
          label: 'Protection',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: 'Score',
        ),
        NavigationDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school),
          label: 'Apprendre',
        ),
      ],
    );
  }
}

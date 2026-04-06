import 'package:flutter/material.dart';

class GuardianScreen extends StatelessWidget {
  const GuardianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ange Gardien'),
      ),
      body: const Center(
        child: Text('Écran Ange Gardien - Bientôt disponible'),
      ),
    );
  }
}
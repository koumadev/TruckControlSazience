import 'package:flutter/material.dart';

class ArriveeScreen extends StatelessWidget {
  const ArriveeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enregistrer une Arrivée')),
      body: const Center(
        child: Text('Formulaire de Recherche et d\'Arrivée ici'),
      ),
    );
  }
}

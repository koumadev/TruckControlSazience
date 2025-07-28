import 'package:flutter/material.dart';
import 'package:sazience_control/services/api_service.dart';

class ArriveeScreen extends StatefulWidget {
  const ArriveeScreen({super.key});

  @override
  State<ArriveeScreen> createState() => _ArriveeScreenState();
}

class _ArriveeScreenState extends State<ArriveeScreen> {
  static const Color orange = Color(0xFFec4400);
  static const OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white),
  );
  static const OutlineInputBorder focusedBorder = OutlineInputBorder(
    borderSide: BorderSide(color: orange, width: 2),
  );
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _immatriculationController =
      TextEditingController();
  final TextEditingController _quantiteArriveeController =
      TextEditingController();

  Map<String, dynamic>? _vehicule;
  bool _isLoading = false;
  bool _vehiculeNotFound = false;

  Future<void> _chercherVehicule() async {
    if (_immatriculationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une immatriculation')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _vehiculeNotFound = false;
    });

    final data = await ApiService.getDepartByImmatriculation(
      _immatriculationController.text.trim(),
    );

    setState(() {
      _vehicule = data;
      _isLoading = false;
      _vehiculeNotFound = data == null;
    });
  }

  Future<void> _enregistrerArrivee() async {
    if (_vehicule == null) return;

    final quantite = int.tryParse(_quantiteArriveeController.text);
    if (quantite == null || quantite <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Quantité invalide')));
      return;
    }

    final success = await ApiService.updateArrivee(_vehicule!['id'], quantite);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Arrivée enregistrée')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Erreur lors de l\'enregistrement ou quantité déjà enregistrée',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enregistrer une Arrivée')),
      backgroundColor: const Color(0xFFE8E5DE),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _immatriculationController,
                    decoration: const InputDecoration(
                      labelText: 'Immatriculation',
                      border: border,
                      focusedBorder: focusedBorder,
                      labelStyle: TextStyle(color: orange),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _chercherVehicule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFec4400),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Chercher'),
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator()),
                  if (_vehiculeNotFound)
                    const Text(
                      'Aucun véhicule trouvé pour cette immatriculation',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  if (_vehicule != null && !_vehiculeNotFound) ...[
                    Card(
                      color: Colors.grey.shade100,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Conducteur: ${_vehicule!['conducteur']}'),
                            Text(
                              'Destination: ${_vehicule!['site_destination']}',
                            ),
                            Text('Type: ${_vehicule!['type_chargement']}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantiteArriveeController,
                      decoration: const InputDecoration(
                        labelText: 'Quantité arrivée',
                        border: border,
                        focusedBorder: focusedBorder,
                        labelStyle: TextStyle(color: orange),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _enregistrerArrivee,
                      icon: const Icon(Icons.check),
                      label: const Text('Confirmer Arrivée'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFec4400),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

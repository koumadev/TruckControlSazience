// lib/screens/depart/depart_screen.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:developer';
import 'package:sazience_control/screens/depart/camera_scanner_screen.dart';

final List<String> sites = ['Usine A', 'Usine B', 'Usine C'];
final List<String> typesChargement = ['Farine', 'Matière Première', 'Vide'];

class DepartScreen extends StatefulWidget {
  final CameraDescription camera;

  const DepartScreen({super.key, required this.camera});

  @override
  State<DepartScreen> createState() => _DepartScreenState();
}

class _DepartScreenState extends State<DepartScreen> {
  final TextEditingController _immatriculationController =
      TextEditingController();
  final TextEditingController _sacsDepartController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedSiteDestination;
  String? _selectedTypeChargement;

  late DateTime _currentDateTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentDateTime = DateTime.now();
    // Mise à jour toutes les secondes
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentDateTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _immatriculationController.dispose();
    _sacsDepartController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _scanLicensePlate() async {
    final String? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScannerScreen(camera: widget.camera),
      ),
    );

    if (!mounted) return; // <-- correction pour éviter l'erreur

    if (result != null && result.isNotEmpty) {
      setState(() {
        _immatriculationController.text = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plaque d\'immatriculation détectée: $result')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune plaque détectée ou scan annulé.')),
      );
    }
  }

  void _submitDepart() {
    if (_formKey.currentState!.validate()) {
      if (_immatriculationController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Veuillez scanner ou saisir le numéro d\'immatriculation.',
            ),
          ),
        );
        return;
      }

      log('--- Données de Départ à envoyer à l\'API ---');
      log('Immatriculation: ${_immatriculationController.text}');
      log('Site Destination: ${_selectedSiteDestination ?? 'Non sélectionné'}');
      log(
        'Type de Chargement: ${_selectedTypeChargement ?? 'Non sélectionné'}',
      );
      log('Nombre de Sacs: ${_sacsDepartController.text}');
      log('Date/Heure Départ: $_currentDateTime');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Départ enregistré (simulation) !')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enregistrer un Départ')),
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
                  ElevatedButton.icon(
                    onPressed: _scanLicensePlate,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scanner la Plaque d\'Immatriculation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF191919),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Champ Immatriculation
                  TextFormField(
                    controller: _immatriculationController,
                    decoration: const InputDecoration(
                      labelText: 'Numéro d\'Immatriculation',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_shipping, size: 18),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFec4400),
                          width: 2,
                        ),
                      ),
                      labelStyle: TextStyle(color: Color(0xFF191919)),
                      floatingLabelStyle: TextStyle(color: Color(0xFFec4400)),
                    ),
                    style: const TextStyle(fontSize: 14),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le numéro d\'immatriculation';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Champ Conducteur
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nom du Conducteur',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_circle, size: 18),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFec4400),
                          width: 2,
                        ),
                      ),
                      labelStyle: TextStyle(color: Color(0xFF191919)),
                      floatingLabelStyle: TextStyle(color: Color(0xFFec4400)),
                    ),
                    style: const TextStyle(fontSize: 14),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le nom du conducteur';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Champ Site Destination
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Site de Destination',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.factory, size: 18),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFec4400),
                          width: 2,
                        ),
                      ),
                      labelStyle: TextStyle(color: Color(0xFF191919)),
                      floatingLabelStyle: TextStyle(color: Color(0xFFec4400)),
                    ),
                    value: _selectedSiteDestination,
                    hint: const Text(
                      'Sélectionner le site de destination',
                      style: TextStyle(fontSize: 14),
                    ),
                    items: sites.map((String site) {
                      return DropdownMenuItem<String>(
                        value: site,
                        child: Text(site, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSiteDestination = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez sélectionner un site de destination';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Champ Nature Chargement
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Nature du Chargement',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.archive, size: 18),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFec4400),
                          width: 2,
                        ),
                      ),
                      labelStyle: TextStyle(color: Color(0xFF191919)),
                      floatingLabelStyle: TextStyle(color: Color(0xFFec4400)),
                    ),
                    value: _selectedTypeChargement,
                    hint: const Text(
                      'Sélectionner le type de chargement',
                      style: TextStyle(fontSize: 14),
                    ),
                    items: typesChargement.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTypeChargement = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez sélectionner le type de chargement';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Champ Quantité
                  TextFormField(
                    controller: _sacsDepartController,
                    decoration: const InputDecoration(
                      labelText: 'Quantité',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory_2, size: 18),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFec4400),
                          width: 2,
                        ),
                      ),
                      labelStyle: TextStyle(color: Color(0xFF191919)),
                      floatingLabelStyle: TextStyle(color: Color(0xFFec4400)),
                    ),
                    style: const TextStyle(fontSize: 14),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer la quantité';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Veuillez entrer un nombre valide (> 0)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _submitDepart,
                    icon: const Icon(Icons.send),
                    label: const Text('Confirmer le Départ'),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

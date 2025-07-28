import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'package:sazience_control/screens/depart/camera_scanner_screen.dart';
import 'package:sazience_control/services/api_service.dart';

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
  final TextEditingController _conducteurController = TextEditingController();
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentDateTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _immatriculationController.dispose();
    _conducteurController.dispose();
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

    if (!mounted) return;

    if (result != null && result.isNotEmpty) {
      setState(() {
        _immatriculationController.text = result;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Plaque détectée: $result')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune plaque détectée ou scan annulé.')),
      );
    }
  }

  Future<void> _submitDepart() async {
    if (_formKey.currentState!.validate()) {
      final success = await ApiService.sendDepart(
        immatriculation: _immatriculationController.text,
        conducteur: _conducteurController.text,
        siteDestination: _selectedSiteDestination,
        typeChargement: _selectedTypeChargement,
        quantiteDepart: int.parse(_sacsDepartController.text),
        dateDepart: _currentDateTime,
        heureDepart: _currentDateTime,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Départ enregistré avec succès !')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'enregistrement.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFec4400);
    OutlineInputBorder border = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    );
    OutlineInputBorder focusedBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: orange, width: 2),
    );
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
                  TextFormField(
                    controller: _immatriculationController,
                    decoration: InputDecoration(
                      labelText: 'Numéro d\'Immatriculation',
                      border: border,
                      focusedBorder: focusedBorder,
                      labelStyle: const TextStyle(color: orange),
                      filled: true,
                      fillColor: Colors.white,
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
                  TextFormField(
                    controller: _conducteurController,
                    decoration: InputDecoration(
                      labelText: 'Nom du Conducteur',
                      border: border,
                      focusedBorder: focusedBorder,
                      labelStyle: const TextStyle(color: orange),
                      filled: true,
                      fillColor: Colors.white,
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
                  DropdownButtonFormField<String>(
                    value: _selectedSiteDestination,
                    decoration: InputDecoration(
                      labelText: 'Site de Destination',
                      border: border,
                      focusedBorder: focusedBorder,
                      labelStyle: const TextStyle(color: orange),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: sites.map((site) {
                      return DropdownMenuItem(
                        value: site,
                        child: Text(site, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedSiteDestination = value),
                    validator: (value) =>
                        value == null ? 'Veuillez sélectionner un site' : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedTypeChargement,
                    decoration: InputDecoration(
                      labelText: 'Nature du Chargement',
                      border: border,
                      focusedBorder: focusedBorder,
                      labelStyle: const TextStyle(color: orange),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: typesChargement.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedTypeChargement = value),
                    validator: (value) =>
                        value == null ? 'Veuillez sélectionner un type' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _sacsDepartController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantité',
                      border: border,
                      focusedBorder: focusedBorder,
                      labelStyle: const TextStyle(color: orange),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: const TextStyle(fontSize: 14),
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

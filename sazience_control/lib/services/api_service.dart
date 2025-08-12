import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // URL de base de ton API Express
  static const String baseUrl =
      'http://192.168.137.1:3000/api'; // utilise localhost pour l'émulateur Android

  /// ------------------------------
  ///   DÉPARTS
  /// ------------------------------

  // Envoyer un départ à l'API
  static Future<bool> sendDepart({
    required String immatriculation,
    required String conducteur,
    required String? siteDestination,
    required String? typeChargement,
    required int quantiteDepart,
    required DateTime dateDepart,
    required DateTime heureDepart,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/departs'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'immatriculation': immatriculation,
          'conducteur': conducteur,
          'siteDestination': siteDestination,
          'typeChargement': typeChargement,
          'quantiteDepart': quantiteDepart,
          'dateDepart': dateDepart.toIso8601String().split(
            'T',
          )[0], // format YYYY-MM-DD
          'heureDepart': heureDepart
              .toIso8601String()
              .split('T')[1]
              .substring(0, 8), // format HH:MM:SS
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Récupérer la liste des départs
  static Future<List<dynamic>> getDeparts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/departs'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// ------------------------------
  ///   ARRIVÉES
  /// ------------------------------

  // Chercher un départ par immatriculation pour l'arrivée
  static Future<Map<String, dynamic>?> getDepartByImmatriculation(
    String immatriculation,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/arrivees/$immatriculation'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Mettre à jour la quantité arrivée
  static Future<bool> updateArrivee(int id, int quantiteArrivee) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/arrivees/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'quantiteArrivee': quantiteArrivee}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

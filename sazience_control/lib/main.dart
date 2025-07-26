import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // Pour CameraDescription
import 'package:sazience_control/screens/home/home_screen.dart'; // Importez votre HomeScreen

// Déclarez la liste des caméras comme une variable globale.
// Elle sera initialisée dans la fonction main().
late List<CameraDescription> cameras;

Future<void> main() async {
  // S'assure que les bindings Flutter sont initialisés avant d'utiliser les plugins.
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Tente d'obtenir la liste de toutes les caméras disponibles sur l'appareil.
    cameras = await availableCameras();
  } on CameraException catch (e) {
    // Gère les erreurs si la caméra ne peut pas être initialisée.
    if (kDebugMode) {
      print('Erreur lors de l\'initialisation de la caméra: $e');
    }
    // En production, vous pourriez vouloir afficher un message à l'utilisateur ici
    // ou empêcher le lancement de l'application si la caméra est essentielle.
    cameras = []; // S'assurer que la liste est vide en cas d'erreur
  }

  // Lance l'application Flutter.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sazience Control',
      theme: ThemeData(
        // Définissez votre thème d'application.
        primarySwatch: Colors.blueGrey, // Une couleur primaire pour votre app.
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(
            0xFFE8E5DE,
          ), // Couleur d'arrière-plan de l'AppBar
          foregroundColor:
              Colors.black87, // Couleur du texte et des icônes de l'AppBar
          elevation: 0, // Supprime l'ombre de l'AppBar pour un look plus plat
        ),
      ),
      // Définit l'écran d'accueil de l'application.
      // Passe la première caméra disponible (ou null si aucune) à HomeScreen.
      home: HomeScreen(camera: cameras.isNotEmpty ? cameras.first : null),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sazience_control/screens/depart/depart_screen.dart';
import 'package:camera/camera.dart'; // Nécessaire pour CameraDescription
import 'package:sazience_control/screens/arrivee/arrivee_screen.dart'; // Importez le bon chemin

class HomeScreen extends StatelessWidget {
  // Le paramètre 'camera' est obligatoire pour ce widget.
  // Il peut être null, ce qui est géré dans le main.dart et dans le onTap.
  final CameraDescription? camera;

  const HomeScreen({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E5DE), // Couleur de fond personnalisée
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8E5DE),
        centerTitle: true,
        title: SizedBox(
          height: 150,
          child: Image.asset('assets/images/CargoC.png', fit: BoxFit.contain),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Bouton pour l'écran "Départ"
            SizedBox(
              width: 150, // Largeur fixe pour le conteneur de l'image
              height: 150, // Hauteur fixe pour le conteneur de l'image
              child: InkWell(
                onTap: () {
                  // Vérifie si une caméra est disponible avant de naviguer.
                  // La variable 'camera' est celle passée depuis main.dart.
                  if (camera != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DepartScreen(
                          camera: camera!,
                        ), // Passe la caméra non nulle
                      ),
                    );
                  } else {
                    // Affiche un message si aucune caméra n'est disponible.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Aucune caméra disponible sur cet appareil.',
                        ),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(
                  16,
                ), // Bords arrondis pour l'effet InkWell
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  // Assurez-vous que 'assets/images/parkout.png' existe dans votre pubspec.yaml
                  child: Image.asset(
                    'assets/images/parkout.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit
                        .contain, // S'assure que l'image tient dans le cadre
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40), // Espace entre les boutons
            // Bouton pour l'écran "Arrivée"
            SizedBox(
              width: 150, // Largeur fixe
              height: 150, // Hauteur fixe
              child: InkWell(
                onTap: () {
                  // Navigue simplement vers l'écran ArriveeScreen sans passer de caméra.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ArriveeScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  // Assurez-vous que 'assets/images/parkin.png' existe dans votre pubspec.yaml
                  child: Image.asset(
                    'assets/images/parkin.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

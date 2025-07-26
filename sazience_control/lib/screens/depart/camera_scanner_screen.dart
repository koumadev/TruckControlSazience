// lib/screens/depart/camera_scanner_screen.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:sazience_control/services/ocr_service.dart';

class CameraScannerScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScannerScreen({super.key, required this.camera});

  @override
  State<CameraScannerScreen> createState() => _CameraScannerScreenState();
}

class _CameraScannerScreenState extends State<CameraScannerScreen>
    with WidgetsBindingObserver {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late OCRService _ocrService;

  bool _isScanning = false;
  bool _ocrCompleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller.initialize().then((_) {
      if (!mounted) return;
      _startImageStream();
    });

    _ocrService = OCRService();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopImageStreamSafely();
    _controller.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _stopImageStreamSafely();
    } else if (state == AppLifecycleState.resumed && !_ocrCompleted) {
      _startImageStream();
    }
  }

  Future<void> _stopImageStreamSafely() async {
    try {
      if (_controller.value.isStreamingImages) {
        await _controller.stopImageStream();
      }
    } catch (e) {
      log("Erreur arrêt flux caméra: $e");
    }
  }

  void _startImageStream() {
    if (!_controller.value.isInitialized || _ocrCompleted) return;
    try {
      _controller.startImageStream((CameraImage image) async {
        if (!_isScanning && !_ocrCompleted) {
          _isScanning = true;
          await _processImage(image);
          _isScanning = false;
        }
      });
    } catch (e) {
      log("Erreur démarrage flux caméra: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'accéder à la caméra")),
      );
    }
  }

  Future<void> _processImage(CameraImage image) async {
    final plate = await _ocrService.processImage(
      cameraImage: image,
      sensorOrientation: widget.camera.sensorOrientation,
      platform: Theme.of(context).platform,
      deviceOrientation: _controller.value.deviceOrientation,
    );

    if (plate.isNotEmpty && !_ocrCompleted) {
      setState(() {
        _ocrCompleted = true;
      });
      await _stopImageStreamSafely();
      HapticFeedback.mediumImpact();
      if (mounted) Navigator.pop(context, plate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner la Plaque d\'Immatriculation'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Positioned.fill(child: CameraPreview(_controller)),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.15,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellow, width: 3),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: _ocrCompleted
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 60,
                            )
                          : const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _ocrCompleted
                            ? 'Plaque détectée !'
                            : 'Scannez la plaque...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

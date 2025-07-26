import 'dart:developer';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<String> processImage({
    required CameraImage cameraImage,
    required int sensorOrientation,
    required TargetPlatform platform,
    required DeviceOrientation deviceOrientation,
  }) async {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in cameraImage.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(
        cameraImage.width.toDouble(),
        cameraImage.height.toDouble(),
      );

      final metadata = InputImageMetadata(
        size: imageSize,
        rotation: _rotationIntToImageRotation(
          sensorOrientation,
          platform,
          deviceOrientation,
        ),
        format: InputImageFormat.nv21,
        bytesPerRow: cameraImage.planes.first.bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(bytes: bytes, metadata: metadata);

      final recognizedText = await _textRecognizer.processImage(inputImage);
      return _extractLicensePlate(recognizedText);
    } catch (e) {
      log('Erreur OCR: $e');
      return '';
    }
  }

  void dispose() {
    _textRecognizer.close();
  }

  InputImageRotation _rotationIntToImageRotation(
    int rotation,
    TargetPlatform platform,
    DeviceOrientation orientation,
  ) {
    if (platform == TargetPlatform.android) {
      switch (rotation) {
        case 0:
          return InputImageRotation.rotation0deg;
        case 90:
          return InputImageRotation.rotation90deg;
        case 180:
          return InputImageRotation.rotation180deg;
        case 270:
          return InputImageRotation.rotation270deg;
        default:
          return InputImageRotation.rotation0deg;
      }
    } else {
      final int actualRotation;
      if (orientation == DeviceOrientation.portraitUp) {
        actualRotation = rotation;
      } else if (orientation == DeviceOrientation.portraitDown) {
        actualRotation = rotation + 180;
      } else if (orientation == DeviceOrientation.landscapeLeft) {
        actualRotation = rotation + 90;
      } else {
        actualRotation = rotation + 270;
      }
      switch (actualRotation % 360) {
        case 0:
          return InputImageRotation.rotation0deg;
        case 90:
          return InputImageRotation.rotation90deg;
        case 180:
          return InputImageRotation.rotation180deg;
        case 270:
          return InputImageRotation.rotation270deg;
        default:
          return InputImageRotation.rotation0deg;
      }
    }
  }

  String _extractLicensePlate(RecognizedText recognizedText) {
    final regExp = RegExp(
      r'(\d{1,5}[A-Z]{2}\d{2})|([A-Z]{2}\d{3}[A-Z]{2})',
      caseSensitive: false,
    );

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final text = line.text.toUpperCase().replaceAll(
          RegExp(r'[^A-Z0-9]'),
          '',
        );
        final match = regExp.firstMatch(text);
        if (match != null) return match.group(0)!.toUpperCase();
      }
    }
    return '';
  }
}

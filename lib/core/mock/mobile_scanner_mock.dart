import 'package:flutter/material.dart';

class MobileScannerController {
  MobileScannerController({
    this.detectionSpeed,
    this.facing,
    this.torchEnabled,
  });

  final dynamic detectionSpeed;
  final dynamic facing;
  final bool? torchEnabled;

  void start() {}
  void stop() {}
  void dispose() {}
  void toggleTorch() {}
}

class Barcode {
  final String? rawValue;
  Barcode({this.rawValue});
}

class BarcodeCapture {
  final List<Barcode> barcodes;
  BarcodeCapture({required this.barcodes});
}

class MobileScanner extends StatelessWidget {
  const MobileScanner({
    super.key,
    required this.controller,
    required this.onDetect,
  });

  final MobileScannerController controller;
  final void Function(BarcodeCapture capture) onDetect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Mobile Scanner Disabled\n(Mock Mode)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                onDetect(
                  BarcodeCapture(
                    barcodes: [Barcode(rawValue: 'KENCANA_SESSION:1')],
                  ),
                );
              },
              child: const Text('Simulasi Scan Kencana'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                onDetect(
                  BarcodeCapture(
                    barcodes: [Barcode(rawValue: 'NIM:123456789')],
                  ),
                );
              },
              child: const Text('Simulasi Scan NIM (Ormawa/Nakes)'),
            ),
          ],
        ),
      ),
    );
  }
}

// Enums used by the original library if they exist in the code
enum DetectionSpeed { noDuplicates, normal, unrestricted }

enum CameraFacing { front, back }

import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/scanner_overlay.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_patient_provider.dart';
import '../../../../core/error/error_handler.dart';

class TkQrScanScreen extends StatefulWidget {
  const TkQrScanScreen({super.key});

  @override
  State<TkQrScanScreen> createState() => _TkQrScanScreenState();
}

class _TkQrScanScreenState extends State<TkQrScanScreen>
    with SingleTickerProviderStateMixin {
  late MobileScannerController _scannerController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isProcessing = false;
  bool _hasScanned = false;
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.onSurface,
      body: Stack(
        children: [
          // Camera Preview
          MobileScanner(controller: _scannerController, onDetect: _onDetect),

          // Overlay with Hole Punch
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: ScannerOverlayPainter(
                  overlayColor: context.appColors.onSurface.withAlpha(150),
                  animationValue: _animation.value,
                ),
              );
            },
          ),

          // Scan Area (transparent cutout)
          Center(
            child: SizedBox(
              width: 280,
              height: 280,
            ),
          ),

          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: context.appColors.surface.withAlpha(40),
                            borderRadius: AppRadius.radiusMd,
                          ),
                          child: Icon(Icons.close_rounded, color: context.appColors.surface,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scan QR Code',
                              style: AppTextStyles.titleLg.copyWith(
                                color: context.appColors.surface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Arahkan kamera ke QR Code mahasiswa',
                              style: AppTextStyles.bodySm.copyWith(
                                color: context.appColors.surface.withAlpha(179),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Torch Toggle
                      IconButton(
                        onPressed: () => _scannerController.toggleTorch(),
                        icon: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: context.appColors.surface.withAlpha(40),
                            borderRadius: AppRadius.radiusMd,
                          ),
                          child: Icon(Icons.flash_on_rounded, color: context.appColors.surface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Instructions at bottom
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_isProcessing) ...[
                  CircularProgressIndicator(color: context.appColors.surface),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Memproses data...',
                    style: AppTextStyles.bodyMd.copyWith(color: context.appColors.surface),
                  ),
                ] else if (_hasScanned) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: context
                          .watch<ThemeProvider>()
                          .colors
                          .success
                          .withAlpha(200),
                      borderRadius: AppRadius.radiusXl,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, color: context.appColors.surface,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'QR Terdeteksi!',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: context.appColors.surface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: context.appColors.surface.withAlpha(30),
                      borderRadius: AppRadius.radiusXl,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline_rounded, color: context.appColors.surface,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Posisi QR Code di dalam frame',
                          style: AppTextStyles.bodySm.copyWith(
                            color: context.appColors.surface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing || _hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final code = barcode.rawValue;
      if (code != null && code != _lastScannedCode) {
        _lastScannedCode = code;
        _processQrCode(code);
        break;
      }
    }
  }

  Future<void> _processQrCode(String code) async {
    setState(() => _isProcessing = true);

    try {
      // Parse QR code - expected format: "NIM:12345678" or just "12345678"
      String nim = code;
      if (code.contains(':')) {
        nim = code.split(':').last;
      }
      nim = nim.trim();

      // Search for patient by NIM
      final provider = context.read<TkPatientProvider>();
      final patients = await provider.searchPatients(nim);

      if (!mounted) return;

      if (patients.isNotEmpty) {
        // Find exact match
        final patient = patients.firstWhere(
          (p) => p.nim == nim,
          orElse: () => patients.first,
        );

        await provider.selectPatient(patient);
        if (!mounted) return;

        setState(() => _hasScanned = true);

        // Show success and navigate
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: context.appColors.surface),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text('Mahasiswa ditemukan: ${patient.nama}')),
              ],
            ),
            backgroundColor: context.watch<ThemeProvider>().colors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate to screening with patient
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go('/tk/screening?patient_id=${patient.id}');
        }
      } else {
        // No patient found
        setState(() {
          _isProcessing = false;
          _hasScanned = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: context.appColors.surface),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text('Mahasiswa dengan NIM $nim tidak ditemukan'),
                  ),
                ],
              ),
              backgroundColor: context.appColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _lastScannedCode = null;
        }
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _hasScanned = false;
      });

      if (mounted) {
        AppSnackbar.showError(context, 'Error: ${ErrorHandler.getMessage(e)}');
        _lastScannedCode = null;
      }
    }
  }
}

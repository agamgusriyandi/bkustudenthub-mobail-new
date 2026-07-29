import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          MobileScanner(controller: _scannerController, onDetect: _onDetect),

          // Overlay
          Container(
            decoration: BoxDecoration(color: Colors.black.withAlpha(150)),
          ),

          // Scan Area (transparent cutout)
          Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: 280 + _animation.value * 2,
                  height: 280 + _animation.value * 2,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.radiusXl,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withAlpha(40),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: AppRadius.radiusXl,
                    child: Container(color: Colors.transparent),
                  ),
                );
              },
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
                            color: Colors.white.withAlpha(40),
                            borderRadius: AppRadius.radiusMd,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
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
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Arahkan kamera ke QR Code mahasiswa',
                              style: AppTextStyles.bodySm.copyWith(
                                color: Colors.white70,
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
                            color: Colors.white.withAlpha(40),
                            borderRadius: AppRadius.radiusMd,
                          ),
                          child: const Icon(
                            Icons.flash_on_rounded,
                            color: Colors.white,
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
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Memproses data...',
                    style: AppTextStyles.bodyMd.copyWith(color: Colors.white),
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
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'QR Terdeteksi!',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: Colors.white,
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
                      color: Colors.white.withAlpha(30),
                      borderRadius: AppRadius.radiusXl,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Posisi QR Code di dalam frame',
                          style: AppTextStyles.bodySm.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Manual Input Button
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: SafeArea(
              child: OutlinedButton.icon(
                onPressed: () => _showManualInputDialog(),
                icon: const Icon(Icons.keyboard_rounded),
                label: const Text('Input NIM Manual'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
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
                const Icon(Icons.check_circle_rounded, color: Colors.white),
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
                  const Icon(Icons.error_outline_rounded, color: Colors.white),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text('Mahasiswa dengan NIM $nim tidak ditemukan'),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,

              action: SnackBarAction(
                label: 'Input Manual',
                textColor: Colors.white,
                onPressed: () => _showManualInputDialog(),
              ),
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

  void _showManualInputDialog() {
    final nimController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.radius20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral300,
                        borderRadius: AppRadius.radiusXs,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.neutral200,
                          borderRadius: AppRadius.radiusMd,
                        ),
                        child: Icon(
                          Icons.person_search_rounded,
                          color: AppColors.neutral600,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Input NIM Manual',
                              style: AppTextStyles.titleMd.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Cari mahasiswa berdasarkan NIM',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.neutral500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextField(
                    controller: nimController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'NIM',
                      hintText: 'Contoh: 12345678',
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                      ),
                      prefixIcon: const Icon(Icons.badge_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),

                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final nim = nimController.text.trim();
                            if (nim.isNotEmpty) {
                              Navigator.pop(context);
                              _processQrCode(nim);
                            }
                          },

                          child: const Text('Cari'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

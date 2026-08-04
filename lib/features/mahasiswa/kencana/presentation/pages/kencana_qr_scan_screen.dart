import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';

import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/kencana/presentation/providers/kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/scanner_overlay.dart';
import '../../../../../core/error/error_handler.dart';

class KencanaQrScanScreen extends StatefulWidget {
  const KencanaQrScanScreen({super.key});

  @override
  State<KencanaQrScanScreen> createState() => _KencanaQrScanScreenState();
}

class _KencanaQrScanScreenState extends State<KencanaQrScanScreen>
    with SingleTickerProviderStateMixin {
  late MobileScannerController _scannerController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isProcessing = false;
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

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

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
    _scannerController.stop();

    try {
      Map<String, dynamic> requestData = {};

      if (code.startsWith('KENCANA_SESSION:')) {
        final sessionIdStr = code.split(':')[1];
        final sessionId = int.tryParse(sessionIdStr);

        if (sessionId == null) {
          throw Exception('ID Sesi Kencana tidak valid pada QR Code ini.');
        }

        requestData = {'session_id': sessionId, 'status': 'present'};
      } else {
        requestData = {'qr_code': code, 'status': 'present'};
      }

      // Hit backend API to mark attendance
      final response = await ApiClient().client.post(
        '/kencana-student/attendance',
        data: requestData,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // success
        await context.read<KencanaProvider>().refreshAll();
        if (!mounted) return;

        AppSnackbar.showSuccess(
          context,
          'Kehadiran sesi Kencana Anda berhasil dicatat.',
        );

        // Auto close and go back after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.pop(); // go back to attendance list
          }
        });
      } else {
        throw Exception(
          response.data?['message'] ?? 'Gagal melakukan presensi.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      AppSnackbar.showError(context, ErrorHandler.getMessage(e));

      // Auto restart scanner after error
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isProcessing = false);
          _lastScannedCode = null;
          _scannerController.start();
        }
      });
    }
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

          // Scan Area Frame
          Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: 280 + _animation.value * 2,
                  height: 280 + _animation.value * 2,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.radiusXl,
                    border: Border.all(color: context.appColors.surface, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: context.appColors.surface.withAlpha(80),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
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
                            color: context.appColors.surface.withAlpha(40),
                            borderRadius: AppRadius.radiusMd,
                          ),
                           child: Icon(
                            Icons.close_rounded,
                            color: context.appColors.onPrimary,
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
                                color: context.appColors.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Arahkan kamera ke QR Code Sesi Kencana',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.neutral700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _scannerController.toggleTorch(),
                        icon: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: context.appColors.surface.withAlpha(40),
                            borderRadius: AppRadius.radiusMd,
                          ),
                           child: Icon(
                            Icons.flash_on_rounded,
                            color: context.appColors.onPrimary,
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
                    style: AppTextStyles.bodyMd.copyWith(color: context.appColors.onPrimary),
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
                        Icon(
                          Icons.info_outline_rounded,
                          color: context.appColors.onPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Posisi QR Code di dalam frame',
                          style: AppTextStyles.bodySm.copyWith(
                            color: context.appColors.onPrimary,
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
}

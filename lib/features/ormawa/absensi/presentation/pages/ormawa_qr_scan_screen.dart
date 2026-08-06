import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:bkuhub_mobile/core/widgets/scanner_overlay.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/ormawa_absensi_success_screen.dart';
import '../../../../../core/error/error_handler.dart';
import 'package:go_router/go_router.dart';

class OrmawaQrScanScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const OrmawaQrScanScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<OrmawaQrScanScreen> createState() => _OrmawaQrScanScreenState();
}

class _OrmawaQrScanScreenState extends State<OrmawaQrScanScreen>
    with SingleTickerProviderStateMixin {
  late MobileScannerController _scannerController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isProcessing = false;
  bool _hasScanned = false;
  String? _lastScannedCode;
  String? _scannedStudentName;
  List<Map<String, dynamic>> _studentsLookup = [];
  bool _isLoadingStudents = true;

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

    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    if (AuthService().currentRole != UserRole.ormawa) {
      if (mounted) {
        setState(() {
          _isLoadingStudents = false;
        });
      }
      return;
    }
    try {
      final students = <Map<String, dynamic>>[];
      if (mounted) {
        setState(() {
          _studentsLookup = students;
          _isLoadingStudents = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStudents = false;
        });
      }
    }
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

          // Glassmorphism/Dark Overlay with Hole Punch
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

          // Scan Area frame
          Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: 280 + _animation.value * 2,
                  height: 280 + _animation.value * 2,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.radiusXl,
                    border: Border.all(
                      color: _hasScanned ? AppColors.success : context.appColors.onPrimary,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _hasScanned
                            ? AppColors.success.withAlpha(60)
                            : context.appColors.onPrimary.withAlpha(40),
                        blurRadius: 15,
                        spreadRadius: 2,
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
                              'Scan Presensi',
                              style: AppTextStyles.titleLg.copyWith(
                                color: context.appColors.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.eventTitle,
                              style: AppTextStyles.bodySm.copyWith(
                                color: context.appColors.surface.withValues(alpha: 0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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

          // Feedback Status at bottom of scan area
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_isProcessing) ...[
                  CircularProgressIndicator(color: context.appColors.onPrimary),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Mencatat kehadiran...',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: context.appColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else if (_hasScanned) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(220),
                      borderRadius: AppRadius.radiusXl,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: context.appColors.onPrimary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _scannedStudentName != null
                              ? 'Hadir: $_scannedStudentName'
                              : 'Berhasil Terabsen!',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: context.appColors.onPrimary,
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
                        Icon(
                          Icons.qr_code_scanner_rounded,
                          color: context.appColors.onPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Arahkan kamera ke KTM Digital mahasiswa',
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
                  foregroundColor: context.appColors.onPrimary,
                  side: BorderSide(color: context.appColors.surface.withValues(alpha: 0.7)),
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
    setState(() {
      _isProcessing = true;
      _scannedStudentName = null;
    });

    try {
      final lowerCode = code.toLowerCase().trim();
      final isExternalUrl = lowerCode.contains('http://') ||
          lowerCode.contains('https://') ||
          lowerCode.startsWith('//') ||
          lowerCode.contains('.com') ||
          lowerCode.contains('.html') ||
          lowerCode.contains('.net') ||
          lowerCode.contains('.org');
      final isOfficialEventUrl = lowerCode.contains('eventid=') || lowerCode.contains('student/presensi');
      final isJwtToken = code.startsWith('eyJ') && code.split('.').length == 3;

      if (isExternalUrl && !isOfficialEventUrl && !isJwtToken) {
        throw Exception('QR Code tidak valid! Harap pindai QR Code Presensi Sesi Kencana / Kegiatan resmi.');
      }

      // Robust parsing of student NIM
      String nim = code;
      if (code.contains('?')) {
        try {
          final uri = Uri.parse(code);
          nim = uri.queryParameters['nim'] ?? uri.queryParameters['NIM'] ?? nim;
        } catch (_) { /* Silenced: non-critical lookup fallback */ }
      } else if (code.contains(':')) {
        nim = code.split(':').last;
      }
      nim = nim.trim();

      final provider = context.read<OrmawaProvider>();
      String? resolvedId;
      String? studentName;
      String targetEventId = widget.eventId;

      // Mode 3: Scanning a Kencana Mentor Session QR Code (JWT)
      if (code.startsWith('eyJ') && code.split('.').length == 3) {
        final response = await ApiClient().client.post(
          '/kencana-student/attendance',
          data: {'qr_code': code, 'status': 'present'},
        );

        if (!mounted) return;

        if (response.statusCode == 200 || response.statusCode == 201) {
          setState(() {
            _isProcessing = false;
            _hasScanned = true;
          });
          AppSnackbar.showSuccess(
            context,
            'Berhasil mencatat presensi Kencana (PKKMB) Anda!',
          );
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) context.pop();
          return;
        } else {
          throw Exception(response.data['message'] ?? 'Gagal mencatat presensi Kencana');
        }
      }

      if (code.contains('eventId=') || code.contains('student/presensi')) {
        // Mode 1: Scanning an Event QR Code to check in the logged-in student (Self-Presensi)

        String? parsedEventId;
        try {
          final uri = Uri.parse(code);
          parsedEventId =
              uri.queryParameters['eventId'] ?? uri.queryParameters['event_id'];
        } catch (_) { /* Silenced: non-critical lookup fallback */ }

        if (parsedEventId == null ||
            parsedEventId.isEmpty ||
            parsedEventId == 'undefined') {
          throw Exception('ID Kegiatan tidak valid pada QR Code ini.');
        }

        targetEventId = parsedEventId;

        // Get the logged-in student ID
        resolvedId = provider.mahasiswaId;
        if (resolvedId == null || resolvedId.isEmpty) {
          throw Exception(
            'Gagal melakukan presensi mandiri: Akun mahasiswa tidak terdeteksi.',
          );
        }

        // Get name and nim of the logged-in student
        final authData = AuthService().userData;
        studentName =
            authData?['mahasiswa']?['Nama'] ??
            authData?['mahasiswa']?['nama'] ??
            authData?['user']?['nama'] ??
            'Anda';
        nim =
            authData?['mahasiswa']?['NIM'] ??
            authData?['mahasiswa']?['nim'] ??
            authData?['user']?['nim'] ??
            'NIM Anda';

      } else {
        // Mode 2: Admin scanning student KTM/NIM QR

        if (nim.isEmpty) {
          throw Exception('Kode QR tidak valid.');
        }

        // 1. Check in provider.members
        try {
          final match = provider.members.firstWhere(
            (m) => m.nim.trim().toLowerCase() == nim.toLowerCase(),
          );
          resolvedId = match.mahasiswaId;
          studentName = match.name;
        } catch (_) { /* Silenced: non-critical lookup fallback */ }

        // 2. Check in provider.attendanceList
        if (resolvedId == null) {
          try {
            final match = provider.attendanceList.firstWhere(
              (e) => e.nim?.trim().toLowerCase() == nim.toLowerCase(),
            );
            resolvedId = match.mahasiswaId;
            studentName = match.mahasiswaName;
          } catch (_) { /* Silenced: non-critical lookup fallback */ }
        }

        // 3. Check in preloaded _studentsLookup
        if (resolvedId == null) {
          if (_studentsLookup.isNotEmpty) {
            try {
              final match = _studentsLookup.firstWhere(
                (s) =>
                    s['nim']?.toString().trim().toLowerCase() ==
                    nim.toLowerCase(),
              );
              resolvedId = match['id']?.toString();
              studentName = match['nama']?.toString();
            } catch (_) { /* Silenced: non-critical lookup fallback */ }
          }
        }

        // 4. Fallback if still loading students lookup
        if (resolvedId == null && _isLoadingStudents) {
          final students = <Map<String, dynamic>>[];
          setState(() {
            _studentsLookup = students;
            _isLoadingStudents = false;
          });
          try {
            final match = _studentsLookup.firstWhere(
              (s) =>
                  s['nim']?.toString().trim().toLowerCase() ==
                  nim.toLowerCase(),
            );
            resolvedId = match['id']?.toString();
            studentName = match['nama']?.toString();
          } catch (_) { /* Silenced: non-critical lookup fallback */ }
        }

        if (resolvedId == null) {
          throw Exception('Mahasiswa dengan NIM $nim tidak ditemukan.');
        }
      }

      // Submit attendance directly using the resolved database ID
      await provider.submitAttendance(targetEventId, resolvedId, 'hadir');

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _hasScanned = true;
        _scannedStudentName = studentName ?? 'Mahasiswa NIM $nim';
      });

      // Navigate to success screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => OrmawaAbsensiSuccessScreen(
                eventId: targetEventId,
                eventTitle: widget.eventTitle,
                studentName: studentName ?? 'Mahasiswa',
                nim: nim,
                timestamp: DateTime.now(),
              ),
        ),
      );

      // Reset state when returned from success screen
      if (mounted) {
        setState(() {
          _hasScanned = false;
          _lastScannedCode = null;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _hasScanned = false;
        _lastScannedCode = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline_rounded, color: context.appColors.onPrimary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Gagal mencatat presensi: ${ErrorHandler.getMessage(e)}',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.radius20)),
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
                              'Catat kehadiran berdasarkan NIM mahasiswa',
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
                    keyboardType: TextInputType.text,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'NIM Mahasiswa',
                      hintText: 'Contoh: 2204123001',
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
                          onPressed: () => context.pop(),

                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final nim = nimController.text.trim();
                            if (nim.isNotEmpty) {
                              context.pop();
                              _processQrCode(nim);
                            }
                          },

                          child: const Text(
                            'Submit',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
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
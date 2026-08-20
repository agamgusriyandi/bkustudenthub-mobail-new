import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/scanner_overlay.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/error/error_handler.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/ormawa_absensi_success_screen.dart';

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
  bool _isAlreadyScanned = false;
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(controller: _scannerController, onDetect: _onDetect),

          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: ScannerOverlayPainter(
                  overlayColor: Colors.black.withAlpha(150),
                  animationValue: _animation.value,
                ),
              );
            },
          ),

          const Center(
            child: SizedBox(
              width: 280,
              height: 280,
            ),
          ),

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
                            borderRadius: BkuTheme.r10,
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
                              'Scan Presensi',
                              style: BkuTheme.textPageTitle.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.eventTitle,
                              style: BkuTheme.textCaption.copyWith(
                                color: Colors.white.withAlpha(180),
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _scannerController.toggleTorch(),
                        icon: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BkuTheme.r10,
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

          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_isProcessing) ...[
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Mencatat kehadiran...',
                    style: BkuTheme.textBodyRegular.copyWith(
                      color: Colors.white,
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
                      color: BkuTheme.emerald.withAlpha(220),
                      borderRadius: BkuTheme.rPill,
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
                          _isAlreadyScanned
                              ? 'Anda Sudah Absen!'
                              : (_scannedStudentName != null
                                  ? 'Hadir: $_scannedStudentName'
                                  : 'Berhasil Terabsen!'),
                          style: BkuTheme.textBodyRegular.copyWith(
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
                      borderRadius: BkuTheme.rPill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Arahkan kamera ke KTM Digital mahasiswa',
                          style: BkuTheme.textCaption.copyWith(
                            color: Colors.white,
                            fontSize: 11.5,
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
    setState(() {
      _isProcessing = true;
      _hasScanned = false;
      _isAlreadyScanned = false;
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

      String nim = code;
      if (code.contains('?')) {
        try {
          final uri = Uri.parse(code);
          nim = uri.queryParameters['nim'] ?? uri.queryParameters['NIM'] ?? nim;
        } catch (_) {}
      } else if (code.contains(':')) {
        nim = code.split(':').last;
      }
      nim = nim.trim();

      final provider = context.read<OrmawaProvider>();
      String? resolvedId;
      String? studentName;
      String targetEventId = widget.eventId;

      if (code.startsWith('eyJ') && code.split('.').length == 3) {
        final response = await ApiClient().client.post(
          '/kencana-student/attendance',
          data: {'qr_code': code, 'status': 'present'},
        );

        if (!mounted) return;

        final resData = response.data;
        final resMessage = resData is Map ? (resData['message'] ?? resData['msg'] ?? '').toString() : '';
        final bool isAlready = resMessage.toLowerCase().contains('sudah') ||
            resMessage.toLowerCase().contains('already') ||
            resMessage.toLowerCase().contains('tercatat') ||
            resMessage.toLowerCase().contains('telah');

        if (response.statusCode == 200 || response.statusCode == 201) {
          setState(() {
            _isProcessing = false;
            _hasScanned = true;
            _isAlreadyScanned = isAlready;
          });
          AppSnackbar.showSuccess(
            context,
            isAlready
                ? 'Anda sudah berhasil absen pada sesi ini!'
                : 'Berhasil mencatat presensi Kencana (PKKMB) Anda!',
          );
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) context.pop();
          return;
        } else {
          throw Exception(response.data['message'] ?? 'Gagal mencatat presensi Kencana');
        }
      }

      if (code.contains('eventId=') || code.contains('student/presensi')) {
        String? parsedEventId;
        try {
          final uri = Uri.parse(code);
          parsedEventId = uri.queryParameters['eventId'] ?? uri.queryParameters['event_id'];
        } catch (_) {}

        if (parsedEventId == null || parsedEventId.isEmpty || parsedEventId == 'undefined') {
          throw Exception('ID Kegiatan tidak valid pada QR Code ini.');
        }

        targetEventId = parsedEventId;

        resolvedId = provider.mahasiswaId;
        if (resolvedId == null || resolvedId.isEmpty) {
          throw Exception('Gagal melakukan presensi mandiri: Akun mahasiswa tidak terdeteksi.');
        }

        final authData = AuthService().userData;
        studentName = authData?['mahasiswa']?['Nama'] ??
            authData?['mahasiswa']?['nama'] ??
            authData?['user']?['nama'] ??
            'Anda';
        nim = authData?['mahasiswa']?['NIM'] ??
            authData?['mahasiswa']?['nim'] ??
            authData?['user']?['nim'] ??
            'NIM Anda';
      } else {
        if (nim.isEmpty) {
          throw Exception('Kode QR tidak valid.');
        }

        try {
          final match = provider.members.firstWhere(
            (m) => m.nim.trim().toLowerCase() == nim.toLowerCase(),
          );
          resolvedId = match.mahasiswaId;
          studentName = match.name;
        } catch (_) {}

        if (resolvedId == null) {
          try {
            final match = provider.attendanceList.firstWhere(
              (e) => e.nim?.trim().toLowerCase() == nim.toLowerCase(),
            );
            resolvedId = match.mahasiswaId;
            studentName = match.mahasiswaName;
          } catch (_) {}
        }

        if (resolvedId == null) {
          if (_studentsLookup.isNotEmpty) {
            try {
              final match = _studentsLookup.firstWhere(
                (s) => s['nim']?.toString().trim().toLowerCase() == nim.toLowerCase(),
              );
              resolvedId = match['id']?.toString();
              studentName = match['nama']?.toString();
            } catch (_) {}
          }
        }

        if (resolvedId == null && _isLoadingStudents) {
          final students = <Map<String, dynamic>>[];
          setState(() {
            _studentsLookup = students;
            _isLoadingStudents = false;
          });
          try {
            final match = _studentsLookup.firstWhere(
              (s) => s['nim']?.toString().trim().toLowerCase() == nim.toLowerCase(),
            );
            resolvedId = match['id']?.toString();
            studentName = match['nama']?.toString();
          } catch (_) {}
        }

        if (resolvedId == null) {
          throw Exception('Mahasiswa dengan NIM $nim tidak ditemukan.');
        }
      }

      await provider.submitAttendance(targetEventId, resolvedId, 'hadir');

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _hasScanned = true;
        _scannedStudentName = studentName ?? 'Mahasiswa NIM $nim';
      });

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrmawaAbsensiSuccessScreen(
            eventId: targetEventId,
            eventTitle: widget.eventTitle,
            studentName: studentName ?? 'Mahasiswa',
            nim: nim,
            timestamp: DateTime.now(),
          ),
        ),
      );

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

      final msg = ErrorHandler.getMessage(e);
      final isAlreadyDone = msg.toLowerCase().contains('sudah') ||
          msg.toLowerCase().contains('already') ||
          msg.toLowerCase().contains('tercatat') ||
          msg.toLowerCase().contains('telah');

      if (isAlreadyDone) {
        setState(() {
          _isProcessing = false;
          _hasScanned = true;
          _isAlreadyScanned = true;
        });
        AppSnackbar.showSuccess(
          context,
          'Anda sudah berhasil absen pada sesi ini!',
        );
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) context.pop();
      } else {
        AppSnackbar.showError(context, 'Gagal mencatat presensi: $msg');
      }
    }
  }
}
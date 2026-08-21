import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/services/biometric_service.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/health_view_model.dart';
import 'package:bkuhub_mobile/core/providers/navigation_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final bioService = BiometricService();
    final enabled = await bioService.isBiometricEnabled();
    final creds = await bioService.getCredentials();

    if (enabled && creds != null) {
      if (mounted) {
        setState(() => _isBiometricEnabled = true);
        _handleBiometricLogin();
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    final bioService = BiometricService();
    final authenticated = await bioService.authenticate(
      reason: 'Pindai sidik jari Anda untuk masuk',
    );
    if (authenticated) {
      final creds = await bioService.getCredentials();
      if (creds != null) {
        _usernameController.text = creds['identifier']!;
        _passwordController.text = creds['password']!;
        _handleLogin();
      }
    }
  }

  Future<void> _navigateToDashboard() async {
    final allowedRoles = [
      UserRole.student,
      UserRole.psychologist,
      UserRole.tenagaKesehatan,
      UserRole.mentorKencana,
      UserRole.ormawa,
    ];

    if (!allowedRoles.contains(_authService.currentRole)) {
      await _authService.logout();
      if (mounted) context.go(AppRoutes.webRedirect);
      return;
    }

    if (mounted) {
      Provider.of<NavigationProvider>(context, listen: false).setIndex(0);
    }

    if (_authService.currentRole == UserRole.student) {
      Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
      Provider.of<HealthViewModel>(context, listen: false).loadInitialData();
      context.go(AppRoutes.studentMain);
    } else if (_authService.currentRole == UserRole.mentorKencana) {
      context.go(AppRoutes.mentorKencanaMain);
    } else if (_authService.currentRole == UserRole.psychologist) {
      context.go(AppRoutes.psychologistMain);
    } else if (_authService.currentRole == UserRole.tenagaKesehatan) {
      context.go(AppRoutes.tkMain);
    } else if (_authService.currentRole == UserRole.ormawa) {
      context.go(AppRoutes.ormawaMain);
    }
  }

  void _showRoleSelectionBottomSheet(String tempToken, List<dynamic> roles) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RoleSelectionSheet(
        tempToken: tempToken,
        roles: roles,
        email: _usernameController.text,
        authService: _authService,
        onSuccess: _navigateToDashboard,
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_usernameController.text.isEmpty) {
      _showSnackBar('NIM / Email tidak boleh kosong');
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showSnackBar('Password tidak boleh kosong');
      return;
    }

    setState(() => _isLoading = true);

    String errorMessage = 'Login gagal. Periksa kembali NIM/Email dan Password Anda.';

    try {
      final result = await _authService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.success) {
        final bioService = BiometricService();
        if (await bioService.isBiometricEnabled()) {
          await bioService.saveCredentials(
            _usernameController.text,
            _passwordController.text,
          );
        }

        if (result.requiresRoleSelection) {
          _showRoleSelectionBottomSheet(result.tempToken!, result.roles!);
        } else {
          _navigateToDashboard();
        }
      } else {
        _showSnackBar(result.message ?? errorMessage);
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final responseData = e.response?.data;
      if (responseData != null &&
          responseData is Map &&
          responseData['message'] != null) {
        errorMessage = responseData['message'].toString();
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi Anda.';
      }

      _showSnackBar(errorMessage);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar(errorMessage);
    }
  }

  void _showSnackBar(String message) {
    AppSnackbar.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Semantics(
              excludeSemantics: true,
              child: Image.asset(
                'assets/images/gedung.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                cacheWidth: 800,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    BkuTheme.primary.withAlpha(140),
                    BkuTheme.primary.withAlpha(217),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.lg),
                          _buildCenteredLogo(),
                          const SizedBox(height: AppSpacing.lg),
                          const Spacer(),
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 480),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: BkuTheme.cardSurface,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(28),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(30),
                                      blurRadius: 32,
                                      offset: const Offset(0, -12),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 12),
                                    Center(
                                      child: Container(
                                        width: 40,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: BkuTheme.border,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          FadeInAnimation(
                                            delay: 0.2,
                                            child: Text(
                                              'Selamat Datang',
                                              style: BkuTheme.textPageTitle.copyWith(
                                                fontSize: 21,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          FadeInAnimation(
                                            delay: 0.25,
                                            child: Text(
                                              'Silakan masuk ke akun Anda',
                                              style: BkuTheme.textCardSubtitle,
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.lg),
                                          FadeInAnimation(
                                            delay: 0.3,
                                            child: _buildTextField(
                                              label: 'NIM / Email',
                                              placeholder: 'Masukkan NIM atau email',
                                              icon: Icons.person_outline_rounded,
                                              controller: _usernameController,
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.md),
                                          FadeInAnimation(
                                            delay: 0.35,
                                            child: _buildTextField(
                                              label: 'Kata Sandi',
                                              placeholder: 'Masukkan kata sandi',
                                              icon: Icons.lock_outline_rounded,
                                              isPassword: true,
                                              controller: _passwordController,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          FadeInAnimation(
                                            delay: 0.4,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton(
                                                onPressed: () => context.push(AppRoutes.forgotPassword),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: const Color(0xFF475569),
                                                  padding: EdgeInsets.zero,
                                                  minimumSize: Size.zero,
                                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                ),
                                                child: Text(
                                                  'Lupa Sandi?',
                                                  style: BkuTheme.textButton.copyWith(
                                                    color: const Color(0xFF475569),
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.lg),
                                          FadeInAnimation(
                                            delay: 0.45,
                                            child: _buildLoginButton(),
                                          ),
                                          const SizedBox(height: AppSpacing.lg),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenteredLogo() {
    return FadeInAnimation(
      delay: 0.15,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(28),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withAlpha(60), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Semantics(
                  excludeSemantics: true,
                  child: Image.asset(
                    'assets/images/icons.png',
                    width: 58,
                    height: 58,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'BKU Student HUB',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Color(0x66000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3.5),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(35),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withAlpha(65), width: 0.8),
            ),
            child: const Text(
              'SMART CAMPUS ECOSYSTEM',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Row(
      children: [
        Expanded(
          child: BkuButton(
            text: 'Masuk ke Portal',
            onPressed: _isLoading ? null : _handleLogin,
            isLoading: _isLoading,
            trailingIcon: Icons.arrow_forward_rounded,
          ),
        ),
        if (_isBiometricEnabled) ...[
          const SizedBox(width: AppSpacing.md),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: BkuTheme.cardSurface,
              borderRadius: BkuTheme.r16,
              border: Border.all(color: BkuTheme.border),
              boxShadow: BkuTheme.cardShadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isLoading ? null : _handleBiometricLogin,
                borderRadius: BkuTheme.r16,
                child: Center(
                  child: Icon(
                    Icons.fingerprint_rounded,
                    size: 24,
                    color: BkuTheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String placeholder,
    required IconData icon,
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: BkuTheme.textSectionTitle.copyWith(fontSize: 12.5),
        ),
        const SizedBox(height: 6),
        BkuTextField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          style: BkuTheme.textCardTitle.copyWith(fontSize: 13.5),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: BkuTheme.textCaption.copyWith(color: BkuTheme.textPlaceholder),
            prefixIcon: Icon(icon, color: BkuTheme.textPlaceholder, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: BkuTheme.textPlaceholder,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: BkuTheme.scaffoldBg,
            border: OutlineInputBorder(
              borderRadius: BkuTheme.r12,
              borderSide: BorderSide(color: BkuTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BkuTheme.r12,
              borderSide: BorderSide(color: BkuTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BkuTheme.r12,
              borderSide: BorderSide(color: BkuTheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BkuTheme.r12,
              borderSide: BorderSide(color: BkuTheme.rose, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _RoleItemData {
  final String roleCode;
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final Color primaryColor;
  final Color softBgColor;
  final Color borderColor;

  _RoleItemData({
    required this.roleCode,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.primaryColor,
    required this.softBgColor,
    required this.borderColor,
  });
}

class _RoleSelectionSheet extends StatefulWidget {
  final String tempToken;
  final List<dynamic> roles;
  final String email;
  final AuthService authService;
  final Function() onSuccess;

  const _RoleSelectionSheet({
    required this.tempToken,
    required this.roles,
    required this.email,
    required this.authService,
    required this.onSuccess,
  });

  @override
  State<_RoleSelectionSheet> createState() => _RoleSelectionSheetState();
}

class _RoleSelectionSheetState extends State<_RoleSelectionSheet> {
  bool _isLoading = false;
  String? _selectedRoleCode;
  String? _errorMessage;

  _RoleItemData _parseRole(dynamic roleObj) {
    String roleCode = '';
    String rawName = '';
    String rawDesc = '';
    String rawNim = '';

    if (roleObj is Map) {
      roleCode = roleObj['role']?.toString() ?? roleObj['id']?.toString() ?? '';
      rawName = roleObj['name']?.toString() ?? roleObj['label']?.toString() ?? '';
      rawDesc = roleObj['description']?.toString() ?? roleObj['desc']?.toString() ?? '';
      rawNim = roleObj['nim']?.toString() ?? roleObj['NIM']?.toString() ?? '';
    } else if (roleObj != null) {
      roleCode = roleObj.toString();
      rawName = roleCode;
    }

    final codeLower = roleCode.toLowerCase();
    final nameLower = rawName.toLowerCase();

    if (codeLower.contains('-')) {
      final parts = codeLower.split('-');
      if (rawNim.isEmpty && parts.length > 1) {
        rawNim = parts[1];
      }
    }

    if (codeLower.contains('mentor') ||
        codeLower.contains('kencana') ||
        nameLower.contains('kencana') ||
        nameLower.contains('mentor')) {
      return _RoleItemData(
        roleCode: roleCode,
        title: 'Mentor Program Kencana',
        subtitle: rawDesc.isNotEmpty
            ? rawDesc
            : 'Bimbingan mahasiswa, evaluasi tugas & buku saku Kencana',
        badge: 'Mentor',
        icon: Icons.supervisor_account_rounded,
        primaryColor: BkuTheme.emerald,
        softBgColor: BkuTheme.emeraldSoft,
        borderColor: BkuTheme.emeraldBorder,
      );
    } else if (codeLower.contains('tenaga_kesehatan') ||
        codeLower.contains('tenagakes') ||
        codeLower.contains('nakes') ||
        codeLower.contains('kesehatan') ||
        codeLower.contains('health') ||
        codeLower.contains('klinik') ||
        nameLower.contains('nakes') ||
        nameLower.contains('kesehatan')) {
      return _RoleItemData(
        roleCode: roleCode,
        title: 'Tenaga Kesehatan',
        subtitle: rawDesc.isNotEmpty
            ? rawDesc
            : 'Pemeriksaan kesehatan, rekam medis & screening klinis',
        badge: 'Nakes',
        icon: Icons.medical_services_rounded,
        primaryColor: BkuTheme.rose,
        softBgColor: BkuTheme.roseSoft,
        borderColor: BkuTheme.roseBorder,
      );
    } else if (codeLower.contains('psychologist') ||
        codeLower.contains('psikolog') ||
        codeLower.contains('konsel') ||
        nameLower.contains('psikolog') ||
        nameLower.contains('konselor')) {
      return _RoleItemData(
        roleCode: roleCode,
        title: 'Psikolog / Konselor',
        subtitle: rawDesc.isNotEmpty
            ? rawDesc
            : 'Layanan konseling & pendampingan psikologi mahasiswa',
        badge: 'Konselor',
        icon: Icons.psychology_rounded,
        primaryColor: BkuTheme.purple,
        softBgColor: BkuTheme.purpleSoft,
        borderColor: BkuTheme.purpleBorder,
      );
    } else if (codeLower.contains('ormawa') ||
        codeLower.contains('organisasi') ||
        nameLower.contains('ormawa')) {
      return _RoleItemData(
        roleCode: roleCode,
        title: 'Pengurus Ormawa',
        subtitle: rawDesc.isNotEmpty
            ? rawDesc
            : 'Manajemen kegiatan, proposal & program kerja organisasi',
        badge: 'Ormawa',
        icon: Icons.domain_rounded,
        primaryColor: BkuTheme.amber,
        softBgColor: BkuTheme.amberSoft,
        borderColor: BkuTheme.amberBorder,
      );
    } else if (codeLower.contains('student') ||
        codeLower.contains('mahasiswa') ||
        nameLower.contains('student') ||
        nameLower.contains('mahasiswa') ||
        RegExp(r'^\d+$').hasMatch(codeLower)) {
      final nimText = rawNim.isNotEmpty ? ' ($rawNim)' : '';
      return _RoleItemData(
        roleCode: roleCode,
        title: 'Mahasiswa$nimText',
        subtitle: rawDesc.isNotEmpty
            ? rawDesc
            : 'Akses portal akademik, beasiswa, prestasi & layanan kampus',
        badge: 'Mahasiswa',
        icon: Icons.school_rounded,
        primaryColor: BkuTheme.indigo,
        softBgColor: BkuTheme.indigoSoft,
        borderColor: BkuTheme.indigoBorder,
      );
    } else {
      String cleanTitle = rawName.isNotEmpty ? rawName : roleCode;
      cleanTitle = cleanTitle.replaceAll('role_', '').replaceAll('_', ' ');
      cleanTitle = cleanTitle
          .split(' ')
          .map((w) => w.isNotEmpty
              ? '${w[0].toUpperCase()}${w.substring(1)}'
              : '')
          .join(' ');
      return _RoleItemData(
        roleCode: roleCode,
        title: cleanTitle,
        subtitle: rawDesc.isNotEmpty
            ? rawDesc
            : 'Masuk dan akses dashboard peran ini',
        badge: 'Peran',
        icon: Icons.person_rounded,
        primaryColor: BkuTheme.sky,
        softBgColor: BkuTheme.skySoft,
        borderColor: BkuTheme.skyBorder,
      );
    }
  }

  Future<void> _selectRole(String role) async {
    setState(() {
      _isLoading = true;
      _selectedRoleCode = role;
      _errorMessage = null;
    });

    try {
      final success = await widget.authService.loginSelectRole(
        widget.tempToken,
        role,
      );
      if (!mounted) return;

      setState(() => _isLoading = false);
      if (success) {
        context.pop();
        widget.onSuccess();
      } else {
        setState(() {
          _errorMessage = 'Gagal masuk dengan peran ini. Silakan coba lagi.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan sistem. Silakan coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: BkuTheme.glowShadow,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: BkuTheme.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: BkuTheme.primarySoft,
                    borderRadius: BkuTheme.r10,
                  ),
                  child: Icon(
                    Icons.badge_rounded,
                    color: BkuTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Peran Akses',
                        style: BkuTheme.textPageTitle.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Akun Anda memiliki beberapa peran terdaftar.',
                        style: BkuTheme.textCardSubtitle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_errorMessage != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: BkuTheme.statusDangerBg,
                  borderRadius: BkuTheme.r12,
                  border: Border.all(color: BkuTheme.statusDangerBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: BkuTheme.statusDangerText,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: BkuTheme.textCaption.copyWith(
                          color: BkuTheme.statusDangerText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            ...widget.roles.map((roleObj) {
              final item = _parseRole(roleObj);
              final isCurrentSelecting = _isLoading && _selectedRoleCode == item.roleCode;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: BkuTheme.cardSurface,
                  borderRadius: BkuTheme.r16,
                  border: Border.all(
                    color: isCurrentSelecting ? item.primaryColor : BkuTheme.border,
                    width: isCurrentSelecting ? 1.5 : 1,
                  ),
                  boxShadow: BkuTheme.cardShadow,
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BkuTheme.r16,
                  child: InkWell(
                    onTap: _isLoading ? null : () => _selectRole(item.roleCode),
                    borderRadius: BkuTheme.r16,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: item.softBgColor,
                              borderRadius: BkuTheme.r12,
                              border: Border.all(
                                color: item.borderColor.withAlpha(120),
                              ),
                            ),
                            child: Icon(
                              item.icon,
                              color: item.primaryColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: BkuTheme.textCardTitle.copyWith(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: item.softBgColor,
                                        borderRadius: BkuTheme.rPill,
                                        border: Border.all(
                                          color: item.borderColor,
                                        ),
                                      ),
                                      child: Text(
                                        item.badge,
                                        style: BkuTheme.textBadge.copyWith(
                                          color: item.primaryColor,
                                          fontSize: 9.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.subtitle,
                                  style: BkuTheme.textCardSubtitle.copyWith(
                                    fontSize: 11.5,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (isCurrentSelecting)
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: item.primaryColor,
                              ),
                            )
                          else
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: BkuTheme.slateSoft,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                color: BkuTheme.textMuted,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
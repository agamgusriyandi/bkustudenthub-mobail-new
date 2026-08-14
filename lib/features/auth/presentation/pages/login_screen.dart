import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:dio/dio.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/services/biometric_service.dart';
import 'package:provider/provider.dart';
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
        // Automatically prompt for fingerprint
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
      builder:
          (context) => _RoleSelectionSheet(
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

    String errorMessage =
        'Login gagal. Periksa kembali NIM/Email dan Password Anda.';

    try {
      final result = await _authService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.success) {
        // Save credentials if biometric is enabled (to keep them updated)
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
      backgroundColor: context.appColors.surface,
      body: Stack(
        children: [
          // 1. Full Screen Background Image
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
          // 2. Background Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.appColors.primary.withAlpha(140),
                    context.appColors.primary.withAlpha(217),
                  ],
                ),
              ),
            ),
          ),

          // 4. Main Content Fixed Architecture
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: constraints.maxHeight * 0.12,
                            ),
                            // LOGO SECTION (Centered & Fixed)
                            _buildCenteredLogo(),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        // BOTTOM CARD
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: context.appColors.surface,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(AppRadius.xxl),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.appColors.onSurface.withValues(alpha: 0.15),
                                    blurRadius: 32,
                                    offset: const Offset(0, -12),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: AppSpacing.s20),
                                  // Elegant accent line at top of card
                                  Center(
                                    child: Container(
                                      width: 48,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: AppColors.neutral300,
                                        borderRadius: AppRadius.radiusMd,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  // Form Content
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: AppSpacing.xxl,
                                      right: AppSpacing.xxl,
                                      top: 0,
                                      bottom: AppSpacing.xl,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FadeInAnimation(
                                          delay: 0.5,
                                          child: Text(
                                            'Selamat Datang',
                                            style: AppTextStyles.headlineLarge.copyWith(
                                              color: AppColors.neutral800,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.sm),
                                        FadeInAnimation(
                                          delay: 0.6,
                                          child: Text(
                                            'Silakan masuk ke akun Anda',
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              color: AppColors.neutral500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.xxl),
                                        FadeInAnimation(
                                          delay: 0.7,
                                          child: _buildTextField(
                                            label: 'NIM / Email',
                                            placeholder: 'Masukkan NIM atau email',
                                            icon: Icons.person_outline_rounded,
                                            controller: _usernameController,
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.xl),
                                        FadeInAnimation(
                                          delay: 0.8,
                                          child: _buildTextField(
                                            label: 'Kata Sandi',
                                            placeholder: 'Masukkan kata sandi',
                                            icon: Icons.lock_outline_rounded,
                                            isPassword: true,
                                            controller: _passwordController,
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.md),
                                        FadeInAnimation(
                                          delay: 0.9,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                              onPressed:
                                                  () => context.push(
                                                    AppRoutes.forgotPassword,
                                                  ),
                                              style: TextButton.styleFrom(
                                                foregroundColor: context.appColors.primary,
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                  horizontal: AppSpacing.sm,
                                                  vertical: AppSpacing.xs,
                                                ),
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              child: Text(
                                                'Lupa Sandi?',
                                                style: AppTextStyles.labelMd
                                                    .copyWith(
                                                  color: AppColors.neutral800,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.lg),
                                        FadeInAnimation(
                                          delay: 1.0,
                                          child: _buildLoginButton(),
                                        ),
                                        const SizedBox(height: AppSpacing.xxl),
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
      delay: 0.2,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Colors.white.withAlpha(50),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: BorderRadius.circular(22),
              ),
              child: ClipRRect(
                borderRadius: AppRadius.radiusMd,
                child: Semantics(
                  excludeSemantics: true,
                  child: Image.asset(
                    'assets/images/icons.png',
                    width: 62,
                    height: 62,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s18),
          Text(
            'BKU Student HUB',
            style: AppTextStyles.headlineMedium.copyWith(
              color: context.appColors.onPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: Colors.black.withAlpha(60),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withAlpha(50),
                width: 0.5,
              ),
            ),
            child: Text(
              'SMART CAMPUS ECOSYSTEM',
              style: AppTextStyles.eyebrowSmall.copyWith(
                color: context.appColors.onPrimary,
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
          child: BkuButton.pill(
            text: 'Masuk ke Portal',
            onPressed: _isLoading ? null : _handleLogin,
            isLoading: _isLoading,
            trailingIcon: Icons.arrow_forward_rounded,
          ),
        ),
        if (_isBiometricEnabled) ...[
          const SizedBox(width: AppSpacing.md),
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: context.appColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: context.appColors.outlineVariant.withAlpha(60),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isLoading ? null : _handleBiometricLogin,
                customBorder: const CircleBorder(),
                child: Center(
                  child: Icon(
                    Icons.fingerprint_rounded,
                    size: 26,
                    color: context.appColors.primary,
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
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.neutral800,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.s10),
        BkuTextField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.neutral400,
            ),
            prefixIcon: Icon(icon, color: AppColors.neutral400, size: 22),
            suffixIcon:
                isPassword
                    ? IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: AppColors.neutral400,
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                    : null,
            filled: true,
            fillColor: AppColors.neutral50, // White background
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: AppColors.neutral300, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: AppColors.neutral300, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(
                color: context.appColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: BorderSide(color: context.appColors.error, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg, // Adjusted to match mockup
            ),
          ),
        ),
      ],
    );
  }
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
  String? _errorMessage;

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'shield':
        return Icons.shield_rounded;
      case 'building-2':
        return Icons.domain_rounded;
      case 'brain':
        return Icons.psychology_rounded;
      case 'heart-pulse':
        return Icons.medical_services_rounded;
      case 'users':
        return Icons.people_alt_rounded;
      case 'graduation-cap':
        return Icons.school_rounded;
      case 'book-open':
        return Icons.menu_book_rounded;
      case 'sparkles':
        return Icons.auto_awesome_rounded;
      case 'hand-helping':
        return Icons.handshake_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Color _getColor(String? hexColor) {
    if (hexColor == null || !hexColor.startsWith('#')) {
      return context.appColors.primary;
    }
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (_) {
      return context.appColors.primary;
    }
  }

  Future<void> _selectRole(String role) async {
    setState(() {
      _isLoading = true;
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
        context.pop(); // Close bottom sheet
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
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(AppRadius.radius28),
                                  topRight: Radius.circular(AppRadius.radius28),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: AppRadius.radiusMd,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Pilih Peran Anda',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.neutral800,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            RichText(
              text: TextSpan(
                text: 'Halo, ',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.neutral600,
                  fontSize: 15,
                ),
                children: [
                  TextSpan(
                    text: widget.email,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral800,
                    ),
                  ),
                  const TextSpan(text: '! 👋'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Akun Anda memiliki beberapa peran. Silakan pilih salah satu untuk melanjutkan.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.neutral500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_errorMessage != null) ...[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: context.watch<ThemeProvider>().colors.errorContainer,
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: context.watch<ThemeProvider>().colors.error,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.onErrorContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.roles.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final roleItem = widget.roles[index] as Map<String, dynamic>;
                final roleKey = roleItem['role'] as String;
                final label = roleItem['label'] as String? ?? roleKey;
                final desc = roleItem['description'] as String? ?? '';
                final iconName = roleItem['icon'] as String? ?? 'user';
                final colorStr = roleItem['color'] as String?;

                final roleColor = _getColor(colorStr);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isLoading ? null : () => _selectRole(roleKey),
                    borderRadius: AppRadius.radiusLg,
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: context.appColors.surface,
                        border: Border.all(
                          color: AppColors.neutral200,
                          width: 1.5,
                        ),
                        borderRadius: AppRadius.radiusLg,
                        boxShadow: [
                          BoxShadow(
                            color: context.appColors.onSurface.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Watermark Icon
                          if (iconName == 'graduation-cap')
                            Positioned(
                              right: -10,
                              top: -10,
                              bottom: -10,
                              child: Opacity(
                                opacity: 0.03,
                                child: Icon(Icons.school_rounded, size: 120),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: roleColor.withAlpha(15),
                                    borderRadius: AppRadius.radiusLg,
                                    border: Border.all(
                                      color: roleColor.withAlpha(30),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    _getIconData(iconName),
                                    color: roleColor,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        label,
                                        style: AppTextStyles.titleMd.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.neutral800,
                                        ),
                                      ),
                                      if (desc.isNotEmpty) ...[
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          desc,
                                          style: AppTextStyles.bodySm.copyWith(
                                            color: AppColors.neutral500,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                if (_isLoading)
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 20,
                                    color: AppColors.neutral400,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

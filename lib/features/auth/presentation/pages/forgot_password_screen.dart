import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:pinput/pinput.dart';

enum ForgotPasswordStep { email, otp, newPassword }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  ForgotPasswordStep _currentStep = ForgotPasswordStep.email;
  final AuthService _authService = AuthService();

  // Timer for OTP resend
  Timer? _timer;
  int _start = 60;
  bool _canResendOtp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _start = 60;
    _canResendOtp = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_start == 0) {
        setState(() {
          _canResendOtp = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  Future<void> _requestOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showErrorSnackBar('Silakan masukkan NIM atau Email');
      return;
    }

    setState(() => _isLoading = true);

    final success = await _authService.requestOtp(email);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        setState(() {
          _currentStep = ForgotPasswordStep.otp;
        });
        _startTimer();
      } else {
        _showErrorSnackBar('Gagal mengirim OTP. Pastikan Email/NIM terdaftar.');
      }
    }
  }

  Future<void> _verifyOtp() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();

    if (otp.length < 6) {
      _showErrorSnackBar('Silakan masukkan 6 digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    final success = await _authService.verifyOtp(email, otp);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        setState(() {
          _currentStep = ForgotPasswordStep.newPassword;
        });
      } else {
        _showErrorSnackBar('OTP tidak valid atau telah kadaluarsa.');
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty) {
      _showErrorSnackBar('Kata sandi tidak boleh kosong');
      return;
    }

    if (password != confirmPassword) {
      _showErrorSnackBar('Kata sandi tidak cocok');
      return;
    }

    setState(() => _isLoading = true);

    final success = await _authService.resetPassword(email, otp, password);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Kata sandi berhasil diatur ulang. Silakan masuk.',
            ),
            backgroundColor: Colors.green.shade600,
          ),
        );
        context.go(AppRoutes.login);
      } else {
        _showErrorSnackBar('Gagal mengatur ulang kata sandi.');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    AppSnackbar.showSuccess(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral900,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/gedung.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withAlpha(140),
                    Theme.of(context).colorScheme.primary.withAlpha(217),
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
                          // Back Button
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16, top: 16),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  if (_currentStep == ForgotPasswordStep.otp) {
                                    setState(
                                      () =>
                                          _currentStep =
                                              ForgotPasswordStep.email,
                                    );
                                  } else if (_currentStep ==
                                      ForgotPasswordStep.newPassword) {
                                    setState(
                                      () =>
                                          _currentStep = ForgotPasswordStep.otp,
                                    );
                                  } else {
                                    context.pop();
                                  }
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                          _buildCenteredLogo(),
                          const Spacer(),

                          // The Card
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 480),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(35),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 24,
                                      offset: const Offset(0, -8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    Center(
                                      child: Container(
                                        width: 48,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0E0E0),
                                          borderRadius: AppRadius.radiusMd,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.xl,
                                      ),
                                      child: _buildTimeline(),
                                    ),

                                    const SizedBox(height: 24),

                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 32,
                                        right: 32,
                                        bottom: 40,
                                      ),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 300),
                                        child: _buildCurrentStepContent(),
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
      delay: 0.2,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.radiusXl,
            ),
            child: ClipRRect(
              borderRadius: AppRadius.radiusMd,
              child: Image.asset(
                'assets/images/icons.png',
                width: 65,
                height: 65,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'BKU Student HUB',
            style: AppTextStyles.titleLg.copyWith(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Smart Campus Ecosystem',
            style: AppTextStyles.bodySm.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return FadeInAnimation(
      delay: 0.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimelineNode(1, 'EMAIL', _currentStep.index >= 0),
          _buildTimelineLine(_currentStep.index >= 1),
          _buildTimelineNode(2, 'OTP', _currentStep.index >= 1),
          _buildTimelineLine(_currentStep.index >= 2),
          _buildTimelineNode(3, 'SANDI', _currentStep.index >= 2),
        ],
      ),
    );
  }

  Widget _buildTimelineNode(int stepNum, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isActive ? Theme.of(context).colorScheme.primary : Colors.white,
            border: Border.all(
              color:
                  isActive
                      ? Theme.of(context).colorScheme.primary
                      : AppColors.neutral200,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              stepNum.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.neutral400,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color:
                isActive
                    ? Theme.of(context).colorScheme.primary
                    : AppColors.neutral400,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
      color:
          isActive
              ? Theme.of(context).colorScheme.primary
              : AppColors.neutral200,
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case ForgotPasswordStep.email:
        return _buildEmailStep();
      case ForgotPasswordStep.otp:
        return _buildOtpStep();
      case ForgotPasswordStep.newPassword:
        return _buildNewPasswordStep();
    }
  }

  Widget _buildEmailStep() {
    return KeyedSubtree(
      key: const ValueKey('email_step'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lupa Sandi?',
            style: AppTextStyles.titleLg.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Masukkan email atau NIM Anda, dan kami akan mengirimkan OTP untuk mengatur ulang kata sandi.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.neutral500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField(
            label: 'Email atau NIM',
            placeholder: 'Masukkan email atau NIM',
            icon: Icons.person_outline_rounded,
            controller: _emailController,
          ),
          const SizedBox(height: 32),
          _buildActionButton(label: 'Kirim OTP', onPressed: _requestOtp),
        ],
      ),
    );
  }

  Widget _buildOtpStep() {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        color: AppColors.neutral800,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutral300),
        borderRadius: AppRadius.radiusMd,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(
        color: Theme.of(context).colorScheme.primary,
        width: 1.5,
      ),
      borderRadius: AppRadius.radiusMd,
    );

    return KeyedSubtree(
      key: const ValueKey('otp_step'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Verifikasi OTP',
            style: AppTextStyles.titleLg.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Masukkan 6 digit kode yang telah dikirim ke\n${_emailController.text}',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.neutral500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Pinput(
            length: 6,
            controller: _otpController,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            onCompleted: (pin) => _verifyOtp(),
          ),
          const SizedBox(height: 32),
          _buildActionButton(label: 'Verifikasi OTP', onPressed: _verifyOtp),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Belum menerima kode? ',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
              GestureDetector(
                onTap: _canResendOtp ? _requestOtp : null,
                child: Text(
                  _canResendOtp ? 'Kirim Ulang' : '$_start detik',
                  style: AppTextStyles.labelMd.copyWith(
                    color:
                        _canResendOtp
                            ? Theme.of(context).colorScheme.primary
                            : AppColors.neutral400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewPasswordStep() {
    return KeyedSubtree(
      key: const ValueKey('new_password_step'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buat Sandi Baru',
            style: AppTextStyles.titleLg.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sandi baru Anda harus unik dan berbeda dari sandi sebelumnya.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.neutral500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField(
            label: 'Kata Sandi Baru',
            placeholder: 'Masukkan kata sandi baru',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            isPasswordVisible: _isPasswordVisible,
            onVisibilityToggle: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            controller: _passwordController,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Konfirmasi Sandi Baru',
            placeholder: 'Ulangi kata sandi baru',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            isPasswordVisible: _isConfirmPasswordVisible,
            onVisibilityToggle: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
            controller: _confirmPasswordController,
          ),
          const SizedBox(height: 32),
          _buildActionButton(
            label: 'Simpan Sandi Baru',
            onPressed: _resetPassword,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String placeholder,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            color: AppColors.neutral800,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        BkuTextField(
          controller: controller,
          obscureText: isPassword && !isPasswordVisible,
          style: AppTextStyles.bodyMd.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.neutral800,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AppTextStyles.bodyMd.copyWith(
              color: AppColors.neutral400,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            prefixIcon: Icon(icon, color: AppColors.neutral400, size: 22),
            suffixIcon:
                isPassword
                    ? IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: AppColors.neutral400,
                        size: 22,
                      ),
                      onPressed: onVisibilityToggle,
                    )
                    : null,
            filled: true,
            fillColor: AppColors.neutral50,
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
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: AppRadius.radiusXl,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,

        child:
            _isLoading
                ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3.0,
                  ),
                )
                : Text(
                  label,
                  style: AppTextStyles.titleMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
      ),
    );
  }
}

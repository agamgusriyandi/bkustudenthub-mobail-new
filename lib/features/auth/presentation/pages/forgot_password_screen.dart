import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
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
  String? _resetToken;
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
        AppSnackbar.showSuccess(context, 'OTP berhasil dikirim ke email Anda');
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

    final token = await _authService.verifyOtp(email, otp);

    if (mounted) {
      setState(() => _isLoading = false);
      if (token != null) {
        _resetToken = token;
        AppSnackbar.showSuccess(context, 'OTP berhasil diverifikasi');
        setState(() {
          _currentStep = ForgotPasswordStep.newPassword;
        });
      } else {
        _showErrorSnackBar('OTP tidak valid atau telah kadaluarsa.');
      }
    }
  }

  Future<void> _resetPassword() async {
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

    if (_resetToken == null) {
      _showErrorSnackBar('Sesi tidak valid, silakan ulangi dari awal');
      return;
    }

    setState(() => _isLoading = true);

    final success = await _authService.resetPassword(_resetToken!, password, confirmPassword);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        AppSnackbar.showSuccess(
          context,
          'Kata sandi berhasil diatur ulang. Silakan masuk.',
        );
        context.go(AppRoutes.login);
      } else {
        _showErrorSnackBar('Gagal mengatur ulang kata sandi.');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    AppSnackbar.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: Stack(
        children: [
          // Background Image - 1:1 dengan login
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
          // Gradient Overlay - 1:1 dengan login
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
                          // Logo centered 1:1 dengan login
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.lg,
                                ),
                                child: _buildCenteredLogo(),
                              ),
                            ),
                          ),

                          // The Card - 1:1 dengan login
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
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: _buildTimeline(),
                                          ),
                                          const SizedBox(height: AppSpacing.lg),
                                          AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 300),
                                            child: _buildCurrentStepContent(),
                                          ),
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
          // Back button overlay - tetap ada tapi gak ganggu centering logo (1:1 login)
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 12),
                child: InkWell(
                  onTap: () {
                    if (_currentStep == ForgotPasswordStep.otp) {
                      setState(() => _currentStep = ForgotPasswordStep.email);
                    } else if (_currentStep == ForgotPasswordStep.newPassword) {
                      setState(() => _currentStep = ForgotPasswordStep.otp);
                    } else {
                      context.pop();
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withAlpha(70), width: 0.8),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
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
            color: isActive ? BkuTheme.primary : BkuTheme.cardSurface,
            border: Border.all(
              color: isActive ? BkuTheme.primary : BkuTheme.border,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              stepNum.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : BkuTheme.textPlaceholder,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: TextStyle(
            color: isActive ? BkuTheme.primary : BkuTheme.textPlaceholder,
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
      margin: const EdgeInsets.only(bottom: AppSpacing.xl, left: AppSpacing.sm, right: AppSpacing.sm),
      color: isActive ? BkuTheme.primary : BkuTheme.border,
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
            style: BkuTheme.textPageTitle.copyWith(fontSize: 21, letterSpacing: -0.3),
          ),
          const SizedBox(height: 2),
          Text(
            'Masukkan email atau NIM Anda, dan kami akan mengirimkan OTP untuk mengatur ulang kata sandi.',
            style: BkuTheme.textCardSubtitle.copyWith(height: 1.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildTextField(
            label: 'Email atau NIM',
            placeholder: 'Masukkan email atau NIM',
            icon: Icons.person_outline_rounded,
            controller: _emailController,
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildActionButton(label: 'Kirim OTP', onPressed: _requestOtp),
        ],
      ),
    );
  }

  Widget _buildOtpStep() {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: TextStyle(
        fontSize: 20,
        color: BkuTheme.textHeading,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        border: Border.all(color: BkuTheme.border),
        borderRadius: BkuTheme.r12,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(
        color: BkuTheme.primary,
        width: 1.5,
      ),
      borderRadius: BkuTheme.r12,
    );

    return KeyedSubtree(
      key: const ValueKey('otp_step'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Verifikasi OTP',
            style: BkuTheme.textPageTitle.copyWith(fontSize: 21, letterSpacing: -0.3),
          ),
          const SizedBox(height: 2),
          Text(
            'Masukkan 6 digit kode yang telah dikirim ke\n${_emailController.text}',
            textAlign: TextAlign.center,
            style: BkuTheme.textCardSubtitle.copyWith(height: 1.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Pinput(
            length: 6,
            controller: _otpController,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            onCompleted: (pin) => _verifyOtp(),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildActionButton(label: 'Verifikasi OTP', onPressed: _verifyOtp),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Belum menerima kode? ',
                style: BkuTheme.textCardSubtitle,
              ),
              GestureDetector(
                onTap: _canResendOtp ? _requestOtp : null,
                child: Text(
                  _canResendOtp ? 'Kirim Ulang' : '$_start detik',
                  style: BkuTheme.textButton.copyWith(
                    color: _canResendOtp ? BkuTheme.primary : BkuTheme.textPlaceholder,
                    fontSize: 12.5,
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
            style: BkuTheme.textPageTitle.copyWith(fontSize: 21, letterSpacing: -0.3),
          ),
          const SizedBox(height: 2),
          Text(
            'Sandi baru Anda harus unik dan berbeda dari sandi sebelumnya.',
            style: BkuTheme.textCardSubtitle.copyWith(height: 1.5),
          ),
          const SizedBox(height: AppSpacing.lg),
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
          const SizedBox(height: AppSpacing.md),
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
          const SizedBox(height: AppSpacing.lg),
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
          style: BkuTheme.textSectionTitle.copyWith(fontSize: 12.5),
        ),
        const SizedBox(height: 6),
        BkuTextField(
          controller: controller,
          obscureText: isPassword && !isPasswordVisible,
          style: BkuTheme.textCardTitle.copyWith(fontSize: 13.5),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: BkuTheme.textCaption.copyWith(color: BkuTheme.textPlaceholder),
            prefixIcon: Icon(icon, color: BkuTheme.textPlaceholder, size: 20),
            suffixIcon:
                isPassword
                    ? IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: BkuTheme.textPlaceholder,
                        size: 20,
                      ),
                      onPressed: onVisibilityToggle,
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
              borderSide: BorderSide(
                color: BkuTheme.primary,
                width: 1.5,
              ),
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

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return BkuButton(
      text: label,
      onPressed: _isLoading ? null : onPressed,
      isLoading: _isLoading,
      variant: BkuButtonVariant.primary,
    );
  }
}

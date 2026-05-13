import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';

/// 3-step forgot password flow: Email → OTP → New Password
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _step = 0; // 0=email, 1=otp, 2=new password
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;
  String? _resetToken;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _animateStep() {
    _fadeCtrl.reset();
    _fadeCtrl.forward();
  }

  Future<void> _handleSubmitEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    final authService = ref.read(authServiceProvider);
    final result = await authService.requestPasswordReset(
      _emailController.text.trim(),
    );

    if (!mounted) return;

    result.when(
      success: (_) {
        setState(() { _step = 1; _isLoading = false; });
        _animateStep();
      },
      failure: (f) {
        setState(() {
          _isLoading = false;
          _errorMessage = f.message ?? 'Failed to send reset code';
        });
      },
    );
  }

  Future<void> _handleVerifyOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    final authService = ref.read(authServiceProvider);
    final result = await authService.verifyResetOtp(
      _emailController.text.trim(),
      _otpController.text.trim(),
    );

    if (!mounted) return;

    result.when(
      success: (token) {
        _resetToken = token;
        setState(() { _step = 2; _isLoading = false; });
        _animateStep();
      },
      failure: (f) {
        setState(() {
          _isLoading = false;
          _errorMessage = f.message ?? 'Invalid verification code';
        });
      },
    );
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    final authService = ref.read(authServiceProvider);
    final result = await authService.resetPassword(
      _emailController.text.trim(),
      _resetToken!,
      _passwordController.text,
    );

    if (!mounted) return;

    result.when(
      success: (_) {
        // Show success and go back to login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Password reset successful! Please log in.',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF5E35B1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          ),
        );
        context.pop();
      },
      failure: (f) {
        setState(() {
          _isLoading = false;
          _errorMessage = f.message ?? 'Failed to reset password';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Background gradient ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6A1FDB),
                  Color(0xFF8C52FF),
                  Color(0xFF7B9EFF),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // ── Orbs ──
          Positioned(
            top: -60, right: -50,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -40, left: -30,
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF64B5F6).withValues(alpha: 0.18),
              ),
            ),
          ),

          // ── Main content ──
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── Icon ──
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _step == 0
                                ? Icons.lock_reset_rounded
                                : _step == 1
                                    ? Icons.mark_email_read_rounded
                                    : Icons.check_circle_outline_rounded,
                            size: 38, color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Title ──
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              const LinearGradient(
                                colors: [Colors.white, Color(0xFFD4B8FF)],
                              ).createShader(bounds),
                          child: Text(
                            _step == 0
                                ? 'Forgot Password'
                                : _step == 1
                                    ? 'Check Your Email'
                                    : 'New Password',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _step == 0
                              ? 'Enter your email to receive a reset code'
                              : _step == 1
                                  ? 'Enter the 6-digit code sent to your email'
                                  : 'Choose a strong new password',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // ── Card ──
                        Container(
                          padding: const EdgeInsets.fromLTRB(26, 28, 26, 24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.93),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.7),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6A1FDB).withValues(alpha: 0.25),
                                blurRadius: 40,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Progress indicator
                              Row(
                                children: [
                                  for (int i = 0; i < 3; i++) ...[
                                    Expanded(
                                      child: Container(
                                        height: 4,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(2),
                                          color: i <= _step
                                              ? const Color(0xFF8C52FF)
                                              : const Color(0xFFDDD5FF),
                                        ),
                                      ),
                                    ),
                                    if (i < 2) const SizedBox(width: 6),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Step-specific fields
                              if (_step == 0) ...[
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'Email Address',
                                  icon: Icons.alternate_email_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Please enter your email';
                                    if (!v.contains('@')) return 'Invalid email address';
                                    return null;
                                  },
                                ),
                              ],

                              if (_step == 1) ...[
                                _buildTextField(
                                  controller: _otpController,
                                  label: 'Verification Code',
                                  icon: Icons.pin_rounded,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Please enter the code';
                                    if (v.length < 6) return 'Code must be 6 digits';
                                    return null;
                                  },
                                ),
                              ],

                              if (_step == 2) ...[
                                _buildTextField(
                                  controller: _passwordController,
                                  label: 'New Password',
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF8C52FF), size: 20,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Please enter a password';
                                    if (v.length < 6) return 'Password must be at least 6 characters';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  controller: _confirmPasswordController,
                                  label: 'Confirm Password',
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: _obscureConfirm,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirm
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF8C52FF), size: 20,
                                    ),
                                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Please confirm your password';
                                    if (v != _passwordController.text) return 'Passwords do not match';
                                    return null;
                                  },
                                ),
                              ],

                              // Error message
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF0F0),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFFFCDD2)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline, color: Color(0xFFE53935), size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: const TextStyle(color: Color(0xFFE53935), fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 20),

                              // Submit button
                              _buildGradientButton(
                                label: _step == 0
                                    ? 'Send Reset Code'
                                    : _step == 1
                                        ? 'Verify Code'
                                        : 'Reset Password',
                                isLoading: _isLoading,
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        if (_step == 0) _handleSubmitEmail();
                                        else if (_step == 1) _handleVerifyOtp();
                                        else _handleResetPassword();
                                      },
                              ),

                              const SizedBox(height: 12),

                              // Back to login
                              Center(
                                child: TextButton(
                                  onPressed: () => context.pop(),
                                  child: const Text(
                                    'Back to Login',
                                    style: TextStyle(
                                      color: Color(0xFF8C52FF),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shield_outlined,
                                size: 13,
                                color: Colors.white.withValues(alpha: 0.7)),
                            const SizedBox(width: 5),
                            Text(
                              'Your data is private & encrypted',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: Color(0xFF2D1B6B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF9E9EB8)),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF8C52FF)),
        suffixIcon: suffixIcon,
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFF5F3FF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDDD5FF), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF8C52FF), width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF5252), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF5252), width: 1.8),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String label,
    required bool isLoading,
    VoidCallback? onPressed,
  }) {
    final enabled = onPressed != null;
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.65,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(
                    colors: [Color(0xFF6A1FDB), Color(0xFF8C52FF), Color(0xFFB47CFF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : const LinearGradient(colors: [Color(0xFFBDBDBD), Color(0xFFBDBDBD)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: const Color(0xFF6A1FDB).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 22, width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

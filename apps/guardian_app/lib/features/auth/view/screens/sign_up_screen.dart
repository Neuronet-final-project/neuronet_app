import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:guardian_app/features/auth/providers/auth_provider.dart';
import 'package:guardian_app/config/router/app_router.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with TickerProviderStateMixin {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();
  
  final _fullNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _otpFocus = FocusNode();
  
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isInitialized = false;

  // Countdown for resend
  int _resendCountdown = 0;
  math.Timer? _resendTimer;

  // Entrance animation
  late AnimationController _enterCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Logo pulse ring
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Entrance
    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut));
    _enterCtrl.forward();

    // Pulse ring (slower for signup)
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    
    _isInitialized = true;
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _enterCtrl.dispose();
    _pulseCtrl.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _resendCountdown = 60);
    _resendTimer?.cancel();
    _resendTimer = math.Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown == 0) {
        timer.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      ref.read(authControllerProvider.notifier).signUp(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  void _handleVerifyOtp() {
    if (_otpController.text.length == 6) {
      ref.read(authControllerProvider.notifier).verifyRegistration(
            _emailController.text.trim(),
            _otpController.text.trim(),
          );
    }
  }

  void _handleResendOtp() {
    if (_resendCountdown == 0) {
      ref.read(authControllerProvider.notifier).resendRegistrationOtp(
            _emailController.text.trim(),
          );
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new verification code has been sent'),
          backgroundColor: NeuroColors.guardianPrimary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final size = MediaQuery.of(context).size;

    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: NeuroColors.guardianPrimary,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // Existing signup logic: Listen for state changes
    ref.listen(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? context.localizations.errorDuringSignUp),
            backgroundColor: NeuroColors.error,
          ),
        );
      } else if (previous?.status == AuthStatus.loading && next.status == AuthStatus.unauthenticated) {
        // Success! Redirect to login (either from signup without verification or after OTP success)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? context.localizations.signUpSuccess),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go(GuardianRoutes.login);
      } else if (previous?.status == AuthStatus.loading && next.status == AuthStatus.verificationRequired) {
        // Just transitioned to verification step
        _startResendTimer();
      }
    });

    final isVerificationStep = authState.status == AuthStatus.verificationRequired;

    return Scaffold(
      body: Stack(
        children: [
          // ── Background gradient ──────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  NeuroColors.guardianPrimary,
                  NeuroColors.guardianPrimaryLight,
                  Color(0xFFFFB2C1), 
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // ── Decorative floating orbs ─────────────────────────────────────
          Positioned(
            top: -40, left: -60,
            child: _Orb(size: 240, color: Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            top: size.height * 0.4, right: -100,
            child: _Orb(size: 260, color: Colors.white.withValues(alpha: 0.05)),
          ),
          Positioned(
            bottom: -50, left: size.width * 0.1,
            child: _Orb(size: 200, color: NeuroColors.guardianPrimaryLight.withValues(alpha: 0.15)),
          ),
          ..._sparkles(size),

          // ── Main Content ─────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Form(
                      key: isVerificationStep ? null : _formKey,
                      child: Column(
                        children: [
                          // ── Pulsing Brand Icon ────────────────────────────────
                          AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (_, child) => Transform.scale(
                              scale: _pulseAnim.value,
                              child: child,
                            ),
                            child: Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                              ),
                              child: Icon(
                                isVerificationStep ? Icons.mark_email_read_rounded : Icons.shield_rounded, 
                                size: 38, 
                                color: Colors.white
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Card ───────────────────────────────────────────
                          Container(
                            padding: const EdgeInsets.fromLTRB(26, 32, 26, 28),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: NeuroColors.guardianPrimary.withValues(alpha: 0.2),
                                  blurRadius: 40,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(isVerificationStep ? 'Verify Email' : context.localizations.createAccount,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF4A0E1C),
                                        letterSpacing: -0.5,
                                      )),
                                  const SizedBox(height: 8),
                                  Text(isVerificationStep 
                                      ? 'Enter the 6-digit code sent to\n${_emailController.text}'
                                      : context.localizations.empowerParentingJourney,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF8A6E75),
                                      )),
                                  const SizedBox(height: 32),

                                  if (!isVerificationStep) ...[
                                    // Full Name
                                    _GuardianTextField(
                                      controller: _fullNameController,
                                      focusNode: _fullNameFocus,
                                      label: context.localizations.fullName,
                                      icon: Icons.person_outline_rounded,
                                      textInputAction: TextInputAction.next,
                                      validator: (v) => (v == null || v.isEmpty) ? context.localizations.enterFullName : null,
                                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                                    ),
                                    const SizedBox(height: 12),

                                    // Email
                                    _GuardianTextField(
                                      controller: _emailController,
                                      focusNode: _emailFocus,
                                      label: context.localizations.guardianEmail,
                                      icon: Icons.alternate_email_rounded,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      validator: (v) {
                                        if (v == null || v.isEmpty) return context.localizations.pleaseEnterEmail;
                                        if (!v.contains('@')) return context.localizations.invalidEmail;
                                        return null;
                                      },
                                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
                                    ),
                                    const SizedBox(height: 12),

                                    // Password
                                    _GuardianTextField(
                                      controller: _passwordController,
                                      focusNode: _passwordFocus,
                                      label: context.localizations.createPassword,
                                      icon: Icons.lock_outline_rounded,
                                      obscureText: _obscurePassword,
                                      textInputAction: TextInputAction.next,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: NeuroColors.guardianPrimary,
                                          size: 20,
                                        ),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                      validator: (v) => (v == null || v.length < 6) ? context.localizations.min6Characters : null,
                                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmPasswordFocus),
                                    ),
                                    const SizedBox(height: 12),

                                    // Confirm Password
                                    _GuardianTextField(
                                      controller: _confirmPasswordController,
                                      focusNode: _confirmPasswordFocus,
                                      label: context.localizations.confirmPassword,
                                      icon: Icons.lock_reset_rounded,
                                      obscureText: _obscureConfirmPassword,
                                      textInputAction: TextInputAction.done,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: NeuroColors.guardianPrimary,
                                          size: 20,
                                        ),
                                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                      ),
                                      validator: (v) => (v != _passwordController.text) ? context.localizations.passwordsDoNotMatch : null,
                                      onFieldSubmitted: (_) => _handleSignUp(),
                                    ),
                                    const SizedBox(height: 24),

                                    // Sign Up button
                                    _GradientButton(
                                      onPressed: authState.status == AuthStatus.loading ? null : _handleSignUp,
                                      isLoading: authState.status == AuthStatus.loading,
                                      label: context.localizations.signUpNow,
                                    ),
                                  ] else ...[
                                    // OTP Verification UI
                                    TextFormField(
                                      controller: _otpController,
                                      focusNode: _otpFocus,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                        fontSize: 32, 
                                        fontWeight: FontWeight.w900, 
                                        letterSpacing: 20,
                                        color: Color(0xFF4A0E1C),
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLength: 6,
                                      decoration: InputDecoration(
                                        counterText: '',
                                        hintText: '000000',
                                        hintStyle: TextStyle(color: const Color(0xFF8A6E75).withValues(alpha: 0.3)),
                                        filled: true,
                                        fillColor: const Color(0xFFFFF7F8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20), 
                                          borderSide: const BorderSide(color: Color(0xFFF0DCE0), width: 1.5)
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20), 
                                          borderSide: const BorderSide(color: NeuroColors.guardianPrimary, width: 2.0)
                                        ),
                                      ),
                                      onChanged: (v) {
                                        if (v.length == 6) _handleVerifyOtp();
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    
                                    _GradientButton(
                                      onPressed: authState.status == AuthStatus.loading || _otpController.text.length < 6 
                                          ? null 
                                          : _handleVerifyOtp,
                                      isLoading: authState.status == AuthStatus.loading,
                                      label: 'Verify Code',
                                    ),

                                    const SizedBox(height: 20),
                                    
                                    Center(
                                      child: TextButton(
                                        onPressed: _resendCountdown == 0 ? _handleResendOtp : null,
                                        child: Text(
                                          _resendCountdown == 0 
                                              ? 'Resend code' 
                                              : 'Resend code in ${_resendCountdown}s',
                                          style: TextStyle(
                                            color: _resendCountdown == 0 
                                                ? NeuroColors.guardianPrimary 
                                                : const Color(0xFF8A6E75),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Center(
                                      child: TextButton(
                                        onPressed: () {
                                           // Allow going back to fix registration details
                                           ref.read(authControllerProvider.notifier).logout(); // This clears state
                                        },
                                        child: const Text(
                                          'Change email address',
                                          style: TextStyle(
                                            color: Color(0xFF8A6E75),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 24),

                                  // Back to login (only on first step)
                                  if (!isVerificationStep)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(context.localizations.alreadyGuardian,
                                            style: const TextStyle(fontSize: 13, color: Color(0xFF8A6E75))),
                                        TextButton(
                                          onPressed: () => context.go(GuardianRoutes.login),
                                          child: Text(context.localizations.login,
                                              style: const TextStyle(
                                                color: NeuroColors.guardianPrimary,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13,
                                              )),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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

  List<Widget> _sparkles(Size size) {
    final rng = math.Random(123);
    return List.generate(6, (i) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.7;
      final s = rng.nextDouble() * 4 + 2;
      return Positioned(
        left: x, top: y,
        child: Container(
          width: s, height: s,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), shape: BoxShape.circle),
        ),
      );
    });
  }
}

// ─── Shared Components (Replicated from Login for visual consistency) ────────

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
}

class _GuardianTextField extends StatelessWidget {
  const _GuardianTextField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.validator,
    this.onFieldSubmitted,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: Color(0xFF4A0E1C)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF8A6E75)),
        prefixIcon: Icon(icon, size: 20, color: NeuroColors.guardianPrimary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFFFF7F8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFF0DCE0), width: 1.2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: NeuroColors.guardianPrimary, width: 1.8)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: NeuroColors.error, width: 1.2)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: NeuroColors.error, width: 1.8)),
      ),
    );
  }
}

class _GradientButton extends StatefulWidget {
  const _GradientButton({required this.label, this.onPressed, this.isLoading = false});
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.65,
          duration: const Duration(milliseconds: 200),
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: enabled ? NeuroGradients.guardian : const LinearGradient(colors: [Color(0xFFBDBDBD), Color(0xFFBDBDBD)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: enabled ? [BoxShadow(color: NeuroColors.guardianPrimary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))] : [],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

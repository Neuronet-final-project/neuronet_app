import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:guardian_app/features/auth/providers/auth_provider.dart';
import 'package:guardian_app/config/router/app_router.dart';

class ActivationScreen extends ConsumerStatefulWidget {
  const ActivationScreen({super.key});

  @override
  ConsumerState<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends ConsumerState<ActivationScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _codeFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isInitialized = false;

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

    // Pulse ring
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _isInitialized = true;
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _pulseCtrl.dispose();
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _codeFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _handleActivate() {
    if (_formKey.currentState!.validate()) {
      ref.read(authControllerProvider.notifier).activate(
            _emailController.text.trim(),
            _codeController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: NeuroColors.guardianPrimary,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // Existing logic: Listen for state changes
    ref.listen(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.error &&
          previous?.status != AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'An error occurred'),
            backgroundColor: NeuroColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.status == AuthStatus.unauthenticated &&
          previous?.status == AuthStatus.loading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account activated! Please login.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go(GuardianRoutes.login);
      }
    });

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
            top: -50,
            right: -80,
            child: _Orb(size: 260, color: Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            bottom: size.height * 0.1,
            left: -60,
            child: _Orb(size: 220, color: Colors.white.withValues(alpha: 0.05)),
          ),
          Positioned(
            bottom: -60,
            right: size.width * 0.2,
            child: _Orb(
                size: 180,
                color: NeuroColors.guardianPrimaryLight.withValues(alpha: 0.15)),
          ),
          ..._sparkles(size),

          // ── Main Content ─────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Form(
                      key: _formKey,
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
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    width: 2),
                              ),
                              child: const Icon(Icons.vpn_key_rounded,
                                  size: 38, color: Colors.white),
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
                                  color: NeuroColors.guardianPrimary
                                      .withValues(alpha: 0.2),
                                  blurRadius: 40,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text('Activate Account',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF4A0E1C),
                                      letterSpacing: -0.5,
                                    )),
                                const SizedBox(height: 8),
                                const Text('Secure your access with your code',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF8A6E75),
                                    )),
                                const SizedBox(height: 32),

                                // Email
                                _GuardianTextField(
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                  label: 'Account Email',
                                  icon: Icons.alternate_email_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) => (v == null || !v.contains('@')) ? 'Invalid email' : null,
                                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_codeFocus),
                                ),
                                const SizedBox(height: 12),

                                // Activation Code
                                _GuardianTextField(
                                  controller: _codeController,
                                  focusNode: _codeFocus,
                                  label: 'Activation Code',
                                  icon: Icons.vpn_key_outlined,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) => (v == null || v.isEmpty) ? 'Enter activation code' : null,
                                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
                                ),
                                const SizedBox(height: 12),

                                // New Password
                                _GuardianTextField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  label: 'New Password',
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
                                  validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
                                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmPasswordFocus),
                                ),
                                const SizedBox(height: 12),

                                // Confirm Password
                                _GuardianTextField(
                                  controller: _confirmPasswordController,
                                  focusNode: _confirmPasswordFocus,
                                  label: 'Confirm Password',
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
                                  validator: (v) => (v != _passwordController.text) ? 'Passwords do not match' : null,
                                  onFieldSubmitted: (_) => _handleActivate(),
                                ),
                                const SizedBox(height: 24),

                                // Activate button
                                _GradientButton(
                                  onPressed: authState.status == AuthStatus.loading ? null : _handleActivate,
                                  isLoading: authState.status == AuthStatus.loading,
                                  label: 'Activate Account',
                                ),
                                const SizedBox(height: 20),

                                // Back button
                                TextButton(
                                  onPressed: () => context.pop(),
                                  child: const Text('Back to Login',
                                      style: TextStyle(
                                        color: NeuroColors.guardianPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      )),
                                ),
                              ],
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
    final rng = math.Random(777);
    return List.generate(6, (i) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.7;
      final s = rng.nextDouble() * 4 + 2;
      return Positioned(
        left: x,
        top: y,
        child: Container(
          width: s,
          height: s,
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle),
        ),
      );
    });
  }
}

// ─── Shared Components ──────────────────────────────────────────────────────

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFF0DCE0), width: 1.2)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
                color: NeuroColors.guardianPrimary, width: 1.8)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: NeuroColors.error, width: 1.2)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: NeuroColors.error, width: 1.8)),
      ),
    );
  }
}

class _GradientButton extends StatefulWidget {
  const _GradientButton(
      {required this.label, this.onPressed, this.isLoading = false});
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
              gradient: enabled
                  ? NeuroGradients.guardian
                  : const LinearGradient(
                      colors: [Color(0xFFBDBDBD), Color(0xFFBDBDBD)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                          color: NeuroColors.guardianPrimary
                              .withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ]
                  : [],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.label,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 18),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

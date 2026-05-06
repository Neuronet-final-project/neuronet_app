import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:adolescent_app/features/auth/providers/auth_provider.dart';
import 'package:adolescent_app/config/router/app_router.dart';

// ─── Rotating taglines shown under the logo ────────────────────────────────
List<String> _getTaglines(AppLocalizations l10n) => [
  l10n.loginTagline1,
  l10n.loginTagline2,
  l10n.loginTagline3,
];

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isInitialized = false;

  // Entrance animation
  late AnimationController _enterCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Logo pulse ring
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // Tagline rotation
  int _taglineIndex = 0;
  late AnimationController _taglineCtrl;
  late Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {

    // Entrance
    _enterCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut));
    _enterCtrl.forward();

    // Pulse ring
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.08)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Tagline fade cycle
    _taglineCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _taglineFade = CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeInOut);
    _taglineCtrl.value = 1.0;
    _isInitialized = true;
    _startTaglineCycle();
  }

  void _startTaglineCycle() async {
    await Future.delayed(const Duration(seconds: 3));
    while (mounted) {
      await _taglineCtrl.reverse();
      if (!mounted) break;
      final taglines = _getTaglines(context.localizations);
      setState(() => _taglineIndex = (_taglineIndex + 1) % taglines.length);
      await _taglineCtrl.forward();
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _pulseCtrl.dispose();
    _taglineCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref.read(authControllerProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final size = MediaQuery.of(context).size;

    // Guard against hot-reload before initState completes
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF6A1FDB),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    ref.listen(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.error &&
          previous?.status != AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.errorMessage ?? context.localizations.anErrorOccurred,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            backgroundColor: const Color(0xFF5E35B1),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );
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
                  Color(0xFF6A1FDB),
                  Color(0xFF8C52FF),
                  Color(0xFF7B9EFF),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // ── Decorative floating orbs ─────────────────────────────────────
          Positioned(
            top: -60, right: -50,
            child: _Orb(size: 220, color: Colors.white.withValues(alpha: 0.07)),
          ),
          Positioned(
            top: size.height * 0.28, left: -80,
            child: _Orb(size: 200, color: Colors.white.withValues(alpha: 0.05)),
          ),
          Positioned(
            bottom: -40, right: -30,
            child: _Orb(size: 180, color: const Color(0xFF64B5F6).withValues(alpha: 0.18)),
          ),
          Positioned(
            bottom: size.height * 0.2, left: size.width * 0.6,
            child: _Orb(size: 100, color: Colors.white.withValues(alpha: 0.06)),
          ),
          // Small sparkle dots
          ..._sparkles(size),

          // ── Main content ─────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ── Pulsing logo ───────────────────────────────────
                          AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (_, child) => Transform.scale(
                              scale: _pulseAnim.value,
                              child: child,
                            ),
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    blurRadius: 24,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.self_improvement_rounded,
                                size: 44,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Brand name ─────────────────────────────────────
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                const LinearGradient(
                                  colors: [Colors.white, Color(0xFFD4B8FF)],
                                ).createShader(bounds),
                            child: const Text(
                              'NEURONET',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // ── Rotating tagline ───────────────────────────────
                          FadeTransition(
                            opacity: _taglineFade,
                            child: Text(
                              _getTaglines(context.localizations)[_taglineIndex],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.85),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),

                          // ── Card ───────────────────────────────────────────
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
                                // Card header
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: NeuroGradients.adolescent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.lock_open_rounded,
                                          color: Colors.white, size: 18),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(context.localizations.welcomeBack,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF2D1B6B),
                                            )),
                                        Text(context.localizations.signInToContinue,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF9E9EB8),
                                            )),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 22),

                                // Email field
                                _PurpleTextField(
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                  label: context.localizations.emailHint,
                                  icon: Icons.alternate_email_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return context.localizations.pleaseEnterEmail;
                                    if (!v.contains('@')) return context.localizations.emailAddress;
                                    return null;
                                  },
                                  onFieldSubmitted: (_) =>
                                      FocusScope.of(context).requestFocus(_passwordFocus),
                                ),
                                const SizedBox(height: 12),

                                // Password field
                                _PurpleTextField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  label: context.localizations.passwordHint,
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF8C52FF),
                                      size: 20,
                                    ),
                                    onPressed: () => setState(
                                        () => _obscurePassword = !_obscurePassword),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return context.localizations.pleaseEnterPassword;
                                    if (v.length < 6) return context.localizations.passwordMinLength;
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _handleLogin(),
                                ),

                                // Forgot password row
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: null, // TODO: add forgot password
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.only(top: 4, bottom: 0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      context.localizations.forgotPassword,
                                      style: const TextStyle(
                                        color: Color(0xFF8C52FF),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Sign in button
                                _GradientButton(
                                  onPressed: authState.status == AuthStatus.loading
                                      ? null
                                      : _handleLogin,
                                  isLoading: authState.status == AuthStatus.loading,
                                  label: context.localizations.login,
                                ),
                                const SizedBox(height: 20),

                                // Divider
                                Row(
                                  children: [
                                    Expanded(
                                        child: Divider(
                                            color: const Color(0xFFDDD5FF),
                                            thickness: 1)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(context.localizations.newToNeuroNet,
                                          style: const TextStyle(
                                              fontSize: 11, color: Color(0xFF9E9EB8))),
                                    ),
                                    Expanded(
                                        child: Divider(
                                            color: const Color(0xFFDDD5FF),
                                            thickness: 1)),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // Activate account
                                OutlinedButton(
                                  onPressed: () => context.push(AdolescentRoutes.activate),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Color(0xFF8C52FF), width: 1.5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14)),
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                  ),
                                  child: Text(
                                    context.localizations.activateMyAccount,
                                    style: const TextStyle(
                                      color: Color(0xFF7C4DFF),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
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
                                context.localizations.dataPrivateEncrypted,
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
          ),
        ],
      ),
    );
  }

  // Generate tiny sparkle dot decorations
  List<Widget> _sparkles(Size size) {
    final rng = math.Random(42);
    return List.generate(8, (i) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.5;
      final s = rng.nextDouble() * 4 + 2;
      return Positioned(
        left: x, top: y,
        child: Container(
          width: s, height: s,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }
}

// ─── Decorative Orb Background Widget ────────────────────────────────────────
class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

// ─── Purple-styled TextField ──────────────────────────────────────────────────
class _PurpleTextField extends StatelessWidget {
  const _PurpleTextField({
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
      style: const TextStyle(fontSize: 14, color: Color(0xFF2D1B6B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF9E9EB8)),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF8C52FF)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF5F3FF),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFDDD5FF), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFF8C52FF), width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFFF5252), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFFF5252), width: 1.8),
        ),
      ),
    );
  }
}

// ─── Gradient Login Button ────────────────────────────────────────────────────
class _GradientButton extends StatefulWidget {
  const _GradientButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

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
            height: 52,
            decoration: BoxDecoration(
              gradient: enabled
                  ? const LinearGradient(
                      colors: [Color(0xFF6A1FDB), Color(0xFF8C52FF), Color(0xFFB47CFF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFBDBDBD), Color(0xFFBDBDBD)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: enabled
                  ? const [NeuroShadows.adolescentGlow]
                  : [],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
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

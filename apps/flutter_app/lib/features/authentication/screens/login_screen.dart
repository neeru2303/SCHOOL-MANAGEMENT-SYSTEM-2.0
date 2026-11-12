import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../widgets/school_background.dart';
import '../providers/platform_auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _schoolCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordVisible = false;
  bool _rememberMe = true;
  bool _isLoading = false;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _schoolCodeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await PlatformAuthController.instance.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // AuthGate automatically opens the dashboard
      // after the server verifies SUPER_ADMIN.
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SchoolBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = MediaQuery.sizeOf(context).width;
                      final isDesktop = screenWidth >= 900;

                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1180),
                          child: _buildGlassCard(isDesktop: isDesktop),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required bool isDesktop}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 50,
                offset: const Offset(0, 25),
              ),
            ],
          ),
          child: isDesktop
              ? IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(flex: 5, child: _buildSchoolIdentity()),
                      Container(
                        width: 1,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      Expanded(flex: 5, child: _buildLoginForm()),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildSchoolIdentity(compact: true),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                      child: _buildLoginForm(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSchoolIdentity({bool compact = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 24 : 48,
        vertical: compact ? 30 : 55,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 170, // Increased size
            width: 170, // Increased size
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // ✅ Glowing effect
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(
                    255,
                    240,
                    235,
                    235,
                  ).withValues(alpha: 0.25), // Soft white glow
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: const Color.fromARGB(
                    255,
                    243,
                    242,
                    241,
                  ).withValues(alpha: 0.5), // Blue accent glow
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/sandipani_logo.png',
              fit: BoxFit.contain,

              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 80,
                );
              },
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'SANDIPANI ACADEMY',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40,
              fontFamily: 'BauhausBold',
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(255, 177, 5, 5),
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'CBSE Affiliation No. 1030400',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
              color: const Color.fromARGB(
                255,
                240,
                239,
                237,
              ).withValues(alpha: 0.95),
            ),
          ),

          const SizedBox(height: 26),

          Container(
            width: 65,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'SANDIPANI ETHOS',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 23,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Celebrating 25 Years of Excellence in Education',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.8,
              color: Colors.white.withValues(alpha: 0.68),
            ),
          ),

          if (!compact) ...[
            const Spacer(),
            const Text(
              'EDUTECH PVT. LTD.',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Developed & Managed By',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 45),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Sign in to access your school dashboard.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.68),
              ),
            ),

            const SizedBox(height: 34),

            _buildLabel('School Code (For School Login)'),

            const SizedBox(height: 10),

            _buildTextField(
              controller: _schoolCodeController,
              hint: 'Enter your school code',
              icon: Icons.apartment_rounded,
              validator: null,
            ),

            const SizedBox(height: 22),

            _buildLabel('Email Address'),

            const SizedBox(height: 10),

            _buildTextField(
              controller: _emailController,
              hint: 'Enter your email address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }

                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                    .hasMatch(value.trim())) {
                  return 'Please enter a valid email';
                }

                return null;
              },
            ),

            const SizedBox(height: 22),

            _buildLabel('Password'),

            const SizedBox(height: 10),

            _buildTextField(
              controller: _passwordController,
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              obscureText: !_passwordVisible,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
                icon: Icon(
                  _passwordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white70,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                SizedBox(
                  height: 35,
                  child: Checkbox(
                    value: _rememberMe,
                    activeColor: AppColors.accent,
                    checkColor: AppColors.backgroundDark,
                    side: const BorderSide(color: Colors.white70),
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                  ),
                ),

                const Text(
                  'Remember me',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),

                const Spacer(),

                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Forgot password will be connected to the backend.',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.backgroundDark,
                  disabledBackgroundColor: AppColors.accent.withValues(
                    alpha: 0.6,
                  ),
                  elevation: 8,
                  shadowColor: AppColors.accent.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.backgroundDark,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'SIGN IN',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.arrow_forward_rounded, size: 19),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 25),

            Center(
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 10,
                    height: 1.8,
                  ),
                  children: const [
                    TextSpan(text: 'By signing in, you agree to our\n'),
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: Text(
                'SECURE SCHOOL MANAGEMENT PLATFORM',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.4,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      cursorColor: AppColors.accent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.42),
          fontSize: 12,
        ),
        prefixIcon: Icon(icon, color: Colors.white70, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}

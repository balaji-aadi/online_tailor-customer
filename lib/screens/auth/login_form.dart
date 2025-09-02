// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khyate_tailor_app/common_widget/custom_button.dart';
import 'package:khyate_tailor_app/common_widget/custom_textfield.dart';
// import 'package:khyate_tailor_app/common_widget/custom_textbutton.dart';
import 'package:khyate_tailor_app/constants/color_constant.dart';
import 'package:khyate_tailor_app/constants/storage_constants.dart';
import 'package:khyate_tailor_app/core/services/storage_services/storage_service.dart';
import 'package:khyate_tailor_app/models/models.dart';
import 'package:khyate_tailor_app/screens/home/home_screen.dart';
import 'package:khyate_tailor_app/utils/get_it.dart';

class LoginScreen extends StatefulWidget {
  final Function(String) onLanguageChanged;
  const LoginScreen({super.key, required this.onLanguageChanged});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  String _selectedLanguage = 'en';
  bool _isLoading = false;
  bool _isGuestMode = false;
  bool _obscurePassword = true;
  final _storageService = locator<StorageService>();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  AnimationController? _fadeController;
  AnimationController? _slideController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadLanguage();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController!, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController!, curve: Curves.easeOutCubic),
    );

    _fadeController?.forward();
    _slideController?.forward();
  }

  Future<void> _loadLanguage() async {
    final language = await _storageService.getString(StorageConstants.selectedLanguage) ?? 'en';
    if (!mounted) return;
    setState(() => _selectedLanguage = language);
  }

  String _tr(String en, String ar) => _selectedLanguage == 'ar' ? ar : en;
  bool get isRTL => _selectedLanguage == 'ar';

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    final user = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: _tr('Customer', 'العميل'),
      email: _emailController.text,
      phone: '+971501234567',
      preferredLanguage: _selectedLanguage,
    );

    // await StorageService.saveUser(user);
    await _storageService.setString(StorageConstants.selectedLanguage, _selectedLanguage);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() => _isGuestMode = true);
    await _storageService.getString(_selectedLanguage);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _navigateToRegister() {
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => RegisterScreen(
    //       onLanguageChanged: widget.onLanguageChanged,
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Background Blobs
            Positioned(
              top: -60,
              left: -40,
              child: _Blob(
                size: 220,
                colors: [
                  colorScheme.primary.withOpacity(0.10),
                  colorScheme.secondary.withOpacity(0.20),
                ],
              ),
            ),
            Positioned(
              bottom: -80,
              right: -60,
              child: _Blob(
                size: 260,
                colors: [
                  colorScheme.secondary.withOpacity(0.10),
                  Colors.white.withOpacity(0.7),
                ],
              ),
            ),

            SafeArea(
              child: Directionality(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 480;
                    final horizontalPadding = isWide ? (constraints.maxWidth - 420) / 2 : 24.0;

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 40),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Language Selector
                            FadeTransition(
                              opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 40),
                                  child: Semantics(
                                    label: _tr('Language selector', 'اختيار اللغة'),
                                    child: SegmentedButton<String>(
                                      style: SegmentedButton.styleFrom(
                                        backgroundColor: ColorConstants.deepNavy,
                                        selectedBackgroundColor: ColorConstants.accentTeal,
                                        selectedForegroundColor: Colors.white,
                                        side: BorderSide.none,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(28),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                      ),
                                      segments: [
                                        ButtonSegment<String>(
                                          value: 'en',
                                          label: Text(
                                            'EN',
                                            style: theme.textTheme.labelLarge?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        ButtonSegment<String>(
                                          value: 'ar',
                                          label: Text(
                                            'عربي',
                                            style: theme.textTheme.labelLarge?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                      selected: {_selectedLanguage},
                                      onSelectionChanged: (Set<String> selection) {
                                        setState(() => _selectedLanguage = selection.first);
                                        widget.onLanguageChanged(_selectedLanguage);
                                        HapticFeedback.selectionClick();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Logo & Branding
                            SlideTransition(
                              position:
                                  _slideAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
                              child: FadeTransition(
                                opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/khyate_logo.png',
                                      height: 72,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(height: 12),
                                    const SizedBox(height: 6),
                                    Text(
                                      _tr('UAE Heritage Tailoring', 'خياطة تراث الإمارات'),
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: ColorConstants.darkNavy,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),

                            // Divider with Icon
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                                  Icon(
                                    Icons.design_services_outlined,
                                    size: 47,
                                    color: colorScheme.primary.withOpacity(1.0),
                                  ),
                                  Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Login Form Card
                            SlideTransition(
                              position:
                                  _slideAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.92),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 24,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                                  child: Column(
                                    children: [
                                      // Login Title
                                      Text(
                                        _tr('Sign In', 'تسجيل الدخول'),
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 28),

                                      // Form Fields
                                      CustomTextField(
                                        controller: _emailController,
                                        labelText: _tr('Email', 'البريد الإلكتروني'),
                                        prefixIcon: Icons.email_outlined,
                                        keyboardType: TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                                        validator: (value) {
                                          if (value?.isEmpty ?? true) {
                                            return _tr('Please enter email', 'يرجى إدخال البريد');
                                          }
                                          if (!(value?.contains('@') ?? false)) {
                                            return _tr('Invalid email', 'بريد إلكتروني غير صحيح');
                                          }
                                          return null;
                                        },
                                        semanticLabel: _tr('Email', 'البريد الإلكتروني'),
                                        isRTL: isRTL,
                                      ),
                                      const SizedBox(height: 16),
                                      CustomTextField(
                                        controller: _passwordController,
                                        labelText: _tr('Password', 'كلمة المرور'),
                                        prefixIcon: Icons.lock_outline,
                                        obscureText: _obscurePassword,
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) => _handleLogin(),
                                        suffixIcon: IconButton(
                                          tooltip: _tr('Toggle password visibility',
                                              'إظهار/إخفاء كلمة المرور'),
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: Colors.grey[600],
                                          ),
                                          onPressed: _togglePasswordVisibility,
                                        ),
                                        validator: (value) {
                                          if (value?.isEmpty ?? true) {
                                            return _tr('Password required', 'كلمة المرور مطلوبة');
                                          }
                                          if ((value?.length ?? 0) < 6) {
                                            return _tr('Min 6 characters', 'الحد الأدنى 6 أحرف');
                                          }
                                          return null;
                                        },
                                        semanticLabel: _tr('Password', 'كلمة المرور'),
                                        isRTL: isRTL,
                                      ),
                                      const SizedBox(height: 20),
                                      CustomButton(
                                        text: _tr('Sign In', 'تسجيل الدخول'),
                                        onPressed: _isLoading ? null : _handleLogin,
                                        isLoading: _isLoading,
                                        semanticLabel: _tr('Sign In', 'تسجيل الدخول'),
                                      ),
                                      const SizedBox(height: 16),
                                      TextButton(
                                        onPressed: _navigateToRegister,
                                        child: Text(
                                          _tr('Create new account', 'إنشاء حساب جديد'),
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      CustomTextButton(
                                        text: _tr('Continue as Guest', 'المتابعة كضيف'),
                                        onPressed: _continueAsGuest,
                                        icon: Icons.person_outline,
                                        semanticLabel: _tr('Continue as Guest', 'المتابعة كضيف'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Footer
                            Column(
                              children: [
                                Text(
                                  _tr('Crafted with care in the UAE', 'مصنوعة بعناية في الإمارات'),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    _slideController?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _Blob({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors, radius: 0.8),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.25),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}

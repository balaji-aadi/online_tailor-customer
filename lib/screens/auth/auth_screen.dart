import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khyate_tailor_app/constants/color_constant.dart';
import 'package:khyate_tailor_app/models/models.dart';
import 'package:khyate_tailor_app/screens/home/home_screen.dart';
import 'package:khyate_tailor_app/services/storage_service.dart';

class AuthScreen extends StatefulWidget {
  final Function(String) onLanguageChanged;
  const AuthScreen({super.key, required this.onLanguageChanged});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  String _selectedLanguage = 'en';
  bool _isLogin = true;
  bool _isLoading = false;
  bool _isGuestMode = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _otpController = TextEditingController();

  bool _showOtpField = false;
  bool _obscurePassword = true;

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
    final language = await StorageService.getLanguage();
    if (!mounted) return;
    setState(() => _selectedLanguage = language);
  }

  String _tr(String en, String ar) => _selectedLanguage == 'ar' ? ar : en;

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (_isLogin) {
      await _login();
    } else {
      if (!_showOtpField) {
        setState(() => _showOtpField = true);
      } else {
        await _register();
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _login() async {
    final user = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: _tr('Customer', 'العميل'),
      email: _emailController.text,
      phone: _phoneController.text.isNotEmpty
          ? _phoneController.text
          : '+971501234567',
      preferredLanguage: _selectedLanguage,
    );

    await StorageService.saveUser(user);
    await StorageService.setLanguage(_selectedLanguage);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  Future<void> _register() async {
    if (_otpController.text.isEmpty || _otpController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
              _tr('Please enter valid OTP', 'يرجى إدخال رمز التحقق الصحيح')),
        ),
      );
      return;
    }

    final user = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      preferredLanguage: _selectedLanguage,
    );

    await StorageService.saveUser(user);
    await StorageService.setLanguage(_selectedLanguage);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() => _isGuestMode = true);
    await StorageService.setLanguage(_selectedLanguage);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = _selectedLanguage == 'ar';
    final double _fieldSpacing = !_isLogin ? 16.0 : 24.0;
    final double _sectionSpacing = !_isLogin ? 20.0 : 28.0;
    final colorScheme = theme.colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark
          .copyWith(statusBarColor: Colors.transparent),
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
                    final horizontalPadding =
                        isWide ? (constraints.maxWidth - 420) / 2 : 24.0;

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                          horizontalPadding, 20, horizontalPadding, 40),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Language Selector
                            FadeTransition(
                              opacity: _fadeAnimation ??
                                  const AlwaysStoppedAnimation(1.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Semantics(
                                      label: _tr(
                                          'Language selector', 'اختيار اللغة'),
                                      child: SegmentedButton<String>(
                                        style: SegmentedButton.styleFrom(
                                          backgroundColor:
                                              ColorConstants.deepNavy,
                                          selectedBackgroundColor:
                                              ColorConstants.accentTeal,
                                          selectedForegroundColor: Colors.white,
                                          side: BorderSide(
                                              color: Colors.grey.shade200),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                        ),
                                        segments: [
                                          ButtonSegment<String>(
                                            value: 'en',
                                            label: Text(
                                              'EN',
                                              style: theme.textTheme.labelLarge
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700),
                                            ),
                                          ),
                                          ButtonSegment<String>(
                                            value: 'ar',
                                            label: Text(
                                              'عربي',
                                              style: theme.textTheme.labelLarge
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                        selected: {_selectedLanguage},
                                        onSelectionChanged:
                                            (Set<String> selection) {
                                          setState(() => _selectedLanguage =
                                              selection.first);
                                          widget.onLanguageChanged(
                                              _selectedLanguage);
                                          HapticFeedback.selectionClick();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Logo & Branding
                            SlideTransition(
                              position: _slideAnimation ??
                                  const AlwaysStoppedAnimation(Offset.zero),
                              child: FadeTransition(
                                opacity: _fadeAnimation ??
                                    const AlwaysStoppedAnimation(1.0),
                                child: Column(
                                  children: [
                                    // Logo (no container around it)
                                    Image.asset(
                                      'assets/images/khyate_logo.png',
                                      height: 72,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(height: 12),

                                    // Brand Name with Gradient
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
                                        colors: [
                                          colorScheme.primary,
                                          colorScheme.secondary
                                        ],
                                      ).createShader(bounds),
                                    ),
                                    const SizedBox(height: 6),

                                    // Tagline
                                    Text(
                                      _tr('UAE Heritage Tailoring',
                                          'خياطة تراث الإمارات'),
                                      textAlign: TextAlign.center,
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
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
                                  Expanded(
                                      child: Divider(
                                          color: Colors.grey[300],
                                          thickness: 1)),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          colorScheme.primary.withOpacity(0.10),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.design_services_outlined,
                                        size: 30,
                                        color: colorScheme.primary
                                            .withOpacity(0.8)),
                                  ),
                                  Expanded(
                                      child: Divider(
                                          color: Colors.grey[300],
                                          thickness: 1)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Auth Form Card
                            SlideTransition(
                              position: _slideAnimation ??
                                  const AlwaysStoppedAnimation(Offset.zero),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.92),
                                  borderRadius: BorderRadius.circular(22),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 24,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 20, 20, 16),
                                  child: Column(
                                    children: [
                                      // Login / Register Tabs
                                      Semantics(
                                        label: _tr('Authentication mode',
                                            'وضع المصادقة'),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: _Segment(
                                                  active: _isLogin,
                                                  label: _tr(
                                                      'Login', 'تسجيل الدخول'),
                                                  onTap: () {
                                                    setState(() {
                                                      _isLogin = true;
                                                      _showOtpField = false;
                                                    });
                                                    HapticFeedback
                                                        .lightImpact();
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: _Segment(
                                                  active: !_isLogin,
                                                  label: _tr(
                                                      'Register', 'تسجيل جديد'),
                                                  onTap: () {
                                                    setState(() {
                                                      _isLogin = false;
                                                      _showOtpField = false;
                                                    });
                                                    HapticFeedback
                                                        .lightImpact();
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: _sectionSpacing),

                                      // Form Fields
                                      AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        switchInCurve: Curves.easeOut,
                                        switchOutCurve: Curves.easeIn,
                                        child: Column(
                                          key: ValueKey(_isLogin.toString() +
                                              _showOtpField.toString()),
                                          children: [
                                            if (!_isLogin)
                                              _buildEnhancedTextField(
                                                controller: _nameController,
                                                labelText: _tr('Full Name',
                                                    'الاسم الكامل'),
                                                prefixIcon:
                                                    Icons.person_outline,
                                                isRTL: isRTL,
                                                textInputAction:
                                                    TextInputAction.next,
                                                onFieldSubmitted: (_) =>
                                                    FocusScope.of(context)
                                                        .nextFocus(),
                                                validator: (value) {
                                                  if (!_isLogin &&
                                                      (value?.isEmpty ??
                                                          true)) {
                                                    return _tr(
                                                        'Please enter your name',
                                                        'يرجى إدخال الاسم');
                                                  }
                                                  return null;
                                                },
                                              ),
                                            if (!_isLogin)
                                              SizedBox(height: _fieldSpacing),
                                            _buildEnhancedTextField(
                                              controller: _emailController,
                                              labelText: _tr(
                                                  'Email', 'البريد الإلكتروني'),
                                              prefixIcon: Icons.email_outlined,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              textInputAction:
                                                  TextInputAction.next,
                                              onFieldSubmitted: (_) =>
                                                  FocusScope.of(context)
                                                      .nextFocus(),
                                              validator: (value) {
                                                if (value?.isEmpty ?? true) {
                                                  return _tr(
                                                      'Please enter email',
                                                      'يرجى إدخال البريد');
                                                }
                                                if (!(value?.contains('@') ??
                                                    false)) {
                                                  return _tr('Invalid email',
                                                      'بريد إلكتروني غير صحيح');
                                                }
                                                return null;
                                              },
                                            ),
                                            SizedBox(height: _fieldSpacing),
                                            if (!_isLogin)
                                              _buildEnhancedTextField(
                                                controller: _phoneController,
                                                labelText:
                                                    _tr('Phone', 'رقم الهاتف'),
                                                prefixIcon:
                                                    Icons.phone_outlined,
                                                keyboardType:
                                                    TextInputType.phone,
                                                hintText: '+97150XXXXXXX',
                                                textInputAction: _showOtpField
                                                    ? TextInputAction.next
                                                    : TextInputAction.done,
                                                onFieldSubmitted: (_) =>
                                                    _showOtpField
                                                        ? FocusScope.of(context)
                                                            .nextFocus()
                                                        : FocusScope.of(context)
                                                            .unfocus(),
                                                validator: (value) {
                                                  if (!_isLogin &&
                                                      (value?.isEmpty ??
                                                          true)) {
                                                    return _tr('Phone required',
                                                        'رقم الهاتف مطلوب');
                                                  }
                                                  return null;
                                                },
                                              ),
                                            if (!_isLogin)
                                              SizedBox(height: _fieldSpacing),
                                            if (!_isLogin && _showOtpField)
                                              Column(
                                                children: [
                                                  _buildEnhancedTextField(
                                                    controller: _otpController,
                                                    labelText:
                                                        _tr('Code', 'الرمز'),
                                                    prefixIcon:
                                                        Icons.sms_outlined,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    maxLength: 6,
                                                    hintText: '123456',
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    onFieldSubmitted: (_) =>
                                                        FocusScope.of(context)
                                                            .nextFocus(),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    width: double.infinity,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    decoration: BoxDecoration(
                                                      color: colorScheme.primary
                                                          .withOpacity(0.08),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Text(
                                                      _tr('Enter 6-digit code sent to your phone',
                                                          'أدخل الرمز المرسل إلى هاتفك'),
                                                      style: theme
                                                          .textTheme.bodySmall
                                                          ?.copyWith(
                                                        color:
                                                            colorScheme.primary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: _fieldSpacing),
                                                ],
                                              ),
                                            if (_isLogin ||
                                                (!_isLogin && _showOtpField))
                                              _buildEnhancedTextField(
                                                controller: _passwordController,
                                                labelText: _tr(
                                                    'Password', 'كلمة المرور'),
                                                prefixIcon: Icons.lock_outline,
                                                obscureText: _obscurePassword,
                                                textInputAction:
                                                    TextInputAction.done,
                                                onFieldSubmitted: (_) =>
                                                    _handleAuth(),
                                                suffixIcon: IconButton(
                                                  tooltip: _tr(
                                                      'Toggle password visibility',
                                                      'إظهار/إخفاء كلمة المرور'),
                                                  icon: Icon(
                                                    _obscurePassword
                                                        ? Icons
                                                            .visibility_off_outlined
                                                        : Icons
                                                            .visibility_outlined,
                                                    color: Colors.grey[600],
                                                  ),
                                                  onPressed: () => setState(
                                                      () => _obscurePassword =
                                                          !_obscurePassword),
                                                ),
                                                validator: (value) {
                                                  if (value?.isEmpty ?? true) {
                                                    return _tr(
                                                        'Password required',
                                                        'كلمة المرور مطلوبة');
                                                  }
                                                  if ((value?.length ?? 0) <
                                                      6) {
                                                    return _tr(
                                                        'Min 6 characters',
                                                        'الحد الأدنى 6 أحرف');
                                                  }
                                                  return null;
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: _sectionSpacing),

                                      // Submit Button
                                      SizedBox(
                                        height: 52,
                                        child: Semantics(
                                          button: true,
                                          label: _isLogin
                                              ? _tr('Sign In', 'تسجيل الدخول')
                                              : _showOtpField
                                                  ? _tr('Verify & Continue',
                                                      'التحقق')
                                                  : _tr('Send Code',
                                                      'إرسال الرمز'),
                                          child: ElevatedButton(
                                            onPressed:
                                                _isLoading ? null : _handleAuth,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  ColorConstants.accentTeal,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          14)),
                                              elevation: 0,
                                              shadowColor: Colors.transparent,
                                            ),
                                            child: Center(
                                              child: _isLoading
                                                  ? const SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2.5,
                                                              color:
                                                                  Colors.white),
                                                    )
                                                  : Text(
                                                      _isLogin
                                                          ? _tr('Sign In',
                                                              'تسجيل الدخول')
                                                          : _showOtpField
                                                              ? _tr(
                                                                  'Verify & Continue',
                                                                  'التحقق')
                                                              : _tr('Send Code',
                                                                  'إرسال الرمز'),
                                                      style: const TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w800),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 55),

                            // Guest Mode
                            Semantics(
                              button: true,
                              label: _tr('Continue as Guest', 'المتابعة كضيف'),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: TextButton(
                                  onPressed: _continueAsGuest,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.person_outline,
                                          color: ColorConstants.primaryGold,
                                          size: 20),
                                      const SizedBox(width: 10),
                                      Text(
                                        _tr('Continue as Guest',
                                            'المتابعة كضيف'),
                                        style: TextStyle(
                                          color: ColorConstants.primaryGold,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
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
                                  _tr('Crafted with care in the UAE',
                                      'مصنوعة بعناية في الإمارات'),
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

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? hintText,
    int? maxLength,
    bool isRTL = false,
    String? Function(String?)? validator,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      textField: true,
      label: labelText,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLength: maxLength,
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: ColorConstants.primaryGold,
          ),
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            prefixIcon: Icon(prefixIcon, color: ColorConstants.primaryGold),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            counterText: '',
            labelStyle:
                WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
              if (states.contains(WidgetState.focused)) {
                return TextStyle(color: ColorConstants.primaryGold);
              }
              return TextStyle(color: Colors.grey[600]); // Default gray
            }),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: ColorConstants.primaryGold, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          validator: validator,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    _slideController?.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}

// === UI Helpers ===
class _Segment extends StatelessWidget {
  final bool active;
  final String label;
  final VoidCallback onTap;

  const _Segment(
      {required this.active, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? ColorConstants.accentTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
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

import 'package:flutter/material.dart';
import 'package:zayyan/models/models.dart';
import 'package:zayyan/screens/home/home_screen.dart';
import 'package:zayyan/services/storage_service.dart';

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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController!, curve: Curves.elasticOut),
    );

    _fadeController?.forward();
    _slideController?.forward();
  }

  Future<void> _loadLanguage() async {
    final language = await StorageService.getLanguage();
    setState(() => _selectedLanguage = language);
  }

  String _tr(String en, String ar) => _selectedLanguage == 'ar' ? ar : en;

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call delay
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

    // 🔽 Dynamic spacing: compact in register mode
    final double _fieldSpacing = !_isLogin ? 16.0 : 24.0;
    final double _sectionSpacing = !_isLogin ? 20.0 : 28.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.12),
              theme.colorScheme.secondary.withOpacity(0.06),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Directionality(
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Language Selector
                    FadeTransition(
                      opacity:
                          _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
                      child: Container(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: SegmentedButton<String>(
                            style: SegmentedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              selectedBackgroundColor:
                                  theme.colorScheme.primary,
                              selectedForegroundColor: Colors.white,
                              elevation: 0,
                            ),
                            segments: const [
                              ButtonSegment<String>(
                                value: 'en',
                                label: Text('EN',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              ButtonSegment<String>(
                                value: 'ar',
                                label: Text('عربي',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                            selected: {_selectedLanguage},
                            onSelectionChanged: (Set<String> selection) {
                              setState(
                                  () => _selectedLanguage = selection.first);
                              widget.onLanguageChanged(_selectedLanguage);
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Logo & Branding
                    SlideTransition(
                      position: _slideAnimation ??
                          const AlwaysStoppedAnimation(Offset.zero),
                      child: FadeTransition(
                        opacity:
                            _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.secondary,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.4),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.cut, // ✅ Real Material icon for tailoring
                                size: 56,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.secondary,
                                ],
                              ).createShader(bounds),
                              child: Text(
                                'Khyate - خياطة',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _tr(
                                'UAE Heritage Tailoring',
                                'خياطة تراث الإمارات',
                              ),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Divider with Ornament
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey[300],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              Icons.design_services_outlined,
                              size: 18,
                              color: theme.colorScheme.primary.withOpacity(0.7),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Auth Form Card
                    SlideTransition(
                      position: _slideAnimation ??
                          const AlwaysStoppedAnimation(Offset.zero),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            children: [
                              // Login / Register Tabs
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() {
                                          _isLogin = true;
                                          _showOtpField = false;
                                        }),
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 250),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          decoration: BoxDecoration(
                                            color: _isLogin
                                                ? theme.colorScheme.primary
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            _tr('Login', 'تسجيل الدخول'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: _isLogin
                                                  ? Colors.white
                                                  : Colors.grey[600],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() {
                                          _isLogin = false;
                                          _showOtpField = false;
                                        }),
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 250),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          decoration: BoxDecoration(
                                            color: !_isLogin
                                                ? theme.colorScheme.primary
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            _tr('Register', 'تسجيل جديد'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: !_isLogin
                                                  ? Colors.white
                                                  : Colors.grey[600],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: _sectionSpacing),

                              // Form Fields (Compact in Register Mode)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                child: Column(
                                  children: [
                                    if (!_isLogin)
                                      _buildEnhancedTextField(
                                        controller: _nameController,
                                        labelText:
                                            _tr('Full Name', 'الاسم الكامل'),
                                        prefixIcon: Icons.person_outline,
                                        isRTL: isRTL,
                                        validator: (value) {
                                          if (!_isLogin &&
                                              (value?.isEmpty ?? true)) {
                                            return _tr('Please enter your name',
                                                'يرجى إدخال الاسم');
                                          }
                                          return null;
                                        },
                                      ),
                                    if (!_isLogin)
                                      SizedBox(height: _fieldSpacing),
                                    _buildEnhancedTextField(
                                      controller: _emailController,
                                      labelText:
                                          _tr('Email', 'البريد الإلكتروني'),
                                      prefixIcon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value?.isEmpty ?? true) {
                                          return _tr('Please enter email',
                                              'يرجى إدخال البريد');
                                        }
                                        if (!value!.contains('@')) {
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
                                        labelText: _tr('Phone', 'رقم الهاتف'),
                                        prefixIcon: Icons.phone_outlined,
                                        keyboardType: TextInputType.phone,
                                        hintText: '+97150XXXXXXX',
                                        validator: (value) {
                                          if (!_isLogin &&
                                              (value?.isEmpty ?? true)) {
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
                                            labelText: _tr('Code', 'الرمز'),
                                            prefixIcon: Icons.sms_outlined,
                                            keyboardType: TextInputType.number,
                                            maxLength: 6,
                                            hintText: '123456',
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _tr(
                                                'Enter 6-digit code sent to your phone',
                                                'أدخل الرمز المرسل إلى هاتفك',
                                              ),
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color:
                                                    theme.colorScheme.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          SizedBox(height: _fieldSpacing),
                                        ],
                                      ),
                                    if (_isLogin ||
                                        (!_isLogin && _showOtpField))
                                      _buildEnhancedTextField(
                                        controller: _passwordController,
                                        labelText:
                                            _tr('Password', 'كلمة المرور'),
                                        prefixIcon: Icons.lock_outline,
                                        obscureText: _obscurePassword,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: Colors.grey[600],
                                          ),
                                          onPressed: () => setState(() =>
                                              _obscurePassword =
                                                  !_obscurePassword),
                                        ),
                                        validator: (value) {
                                          if (value?.isEmpty ?? true) {
                                            return _tr('Password required',
                                                'كلمة المرور مطلوبة');
                                          }
                                          if (value!.length < 6) {
                                            return _tr('Min 6 characters',
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
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.secondary,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleAuth,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          _isLogin
                                              ? _tr('Sign In', 'تسجيل الدخول')
                                              : _showOtpField
                                                  ? _tr('Verify & Continue',
                                                      'التحقق')
                                                  : _tr('Send Code',
                                                      'إرسال الرمز'),
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Guest Mode
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: _continueAsGuest,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_outline,
                                color: theme.colorScheme.secondary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _tr('Continue as Guest', 'المتابعة كضيف'),
                              style: TextStyle(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Footer
                    Text(
                      _tr('Crafted with care in the UAE',
                          'مصنوعة بعناية في الإمارات'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'v1.0.0',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
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
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLength: maxLength,
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Icon(prefixIcon, color: theme.colorScheme.primary),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.grey[600]),
          counterText: '',
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
        validator: validator,
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

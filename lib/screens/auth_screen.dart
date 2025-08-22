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
        CurvedAnimation(parent: _slideController!, curve: Curves.elasticOut));

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
    // Simulate login
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
                _tr('Please enter valid OTP', 'يرجى إدخال رمز التحقق الصحيح'))),
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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Directionality(
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Language Selection with enhanced styling
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
                                label: Text('English',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              ButtonSegment<String>(
                                value: 'ar',
                                label: Text('العربية',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)),
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

                    const SizedBox(height: 40),

                    // App Logo and Title with animations
                    SlideTransition(
                      position: _slideAnimation ??
                          const AlwaysStoppedAnimation(Offset.zero),
                      child: FadeTransition(
                        opacity:
                            _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
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
                                        .withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.content_cut,
                                size: 50,
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
                                'Zayyan - زين',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _tr('UAE Traditional Dress Tailors',
                                  'خياطو الأزياء التقليدية الإماراتية'),
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

                    // Enhanced Auth Form
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
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              // Enhanced Toggle Login/Register
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
                                              const Duration(milliseconds: 200),
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
                                              const Duration(milliseconds: 200),
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

                              const SizedBox(height: 24),

                              // Enhanced Form Fields
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                child: Column(
                                  children: [
                                    // Name Field (Register only)
                                    if (!_isLogin)
                                      _buildEnhancedTextField(
                                        controller: _nameController,
                                        labelText:
                                            _tr('Full Name', 'الاسم الكامل'),
                                        prefixIcon: Icons.person_outline,
                                        isRTL: isRTL,
                                        validator: (value) {
                                          if (!_isLogin &&
                                              (value == null ||
                                                  value.isEmpty)) {
                                            return _tr('Please enter your name',
                                                'يرجى إدخال الاسم');
                                          }
                                          return null;
                                        },
                                      ),

                                    if (!_isLogin) const SizedBox(height: 16),

                                    // Email Field
                                    _buildEnhancedTextField(
                                      controller: _emailController,
                                      labelText:
                                          _tr('Email', 'البريد الإلكتروني'),
                                      prefixIcon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return _tr('Please enter email',
                                              'يرجى إدخال البريد الإلكتروني');
                                        }
                                        if (!value.contains('@')) {
                                          return _tr('Please enter valid email',
                                              'يرجى إدخال بريد إلكتروني صحيح');
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 16),

                                    // Phone Field (Register only)
                                    if (!_isLogin)
                                      _buildEnhancedTextField(
                                        controller: _phoneController,
                                        labelText:
                                            _tr('Phone Number', 'رقم الهاتف'),
                                        prefixIcon: Icons.phone_outlined,
                                        keyboardType: TextInputType.phone,
                                        hintText: '+971501234567',
                                        validator: (value) {
                                          if (!_isLogin &&
                                              (value == null ||
                                                  value.isEmpty)) {
                                            return _tr(
                                                'Please enter phone number',
                                                'يرجى إدخال رقم الهاتف');
                                          }
                                          return null;
                                        },
                                      ),

                                    if (!_isLogin) const SizedBox(height: 16),

                                    // OTP Field (Register - after phone)
                                    if (!_isLogin && _showOtpField)
                                      Column(
                                        children: [
                                          _buildEnhancedTextField(
                                            controller: _otpController,
                                            labelText: _tr('Verification Code',
                                                'رمز التحقق'),
                                            prefixIcon: Icons.security_outlined,
                                            keyboardType: TextInputType.number,
                                            maxLength: 6,
                                            hintText: '123456',
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _tr('Enter the 6-digit code sent to your phone',
                                                  'أدخل الرمز المكون من 6 أرقام المرسل إلى هاتفك'),
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color:
                                                    theme.colorScheme.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      ),

                                    // Password Field (Login only, or Register after OTP)
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
                                          if (value == null || value.isEmpty) {
                                            return _tr('Please enter password',
                                                'يرجى إدخال كلمة المرور');
                                          }
                                          if (value.length < 6) {
                                            return _tr(
                                                'Password must be at least 6 characters',
                                                'كلمة المرور يجب أن تكون 6 أحرف على الأقل');
                                          }
                                          return null;
                                        },
                                      ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Enhanced Submit Button
                              Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.secondary,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleAuth,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          _isLogin
                                              ? _tr('Login', 'تسجيل الدخول')
                                              : _showOtpField
                                                  ? _tr('Verify & Complete',
                                                      'تحقق وإكمال')
                                                  : _tr('Send Code',
                                                      'إرسال الرمز'),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
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

                    const SizedBox(height: 20),

                    // Enhanced Guest Mode Button
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: TextButton(
                        onPressed: _continueAsGuest,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: theme.colorScheme.secondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _tr('Continue as Guest', 'المتابعة كضيف'),
                              style: TextStyle(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
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
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
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

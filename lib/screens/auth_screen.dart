import 'package:flutter/material.dart';
import 'package:zayyan/models/models.dart';
import 'package:zayyan/screens/home/home_screen.dart';
import 'package:zayyan/services/storage_service.dart';
import 'package:zayyan/screens/main_navigation.dart';

class AuthScreen extends StatefulWidget {
  final Function(String) onLanguageChanged;

  const AuthScreen({super.key, required this.onLanguageChanged});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
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

  @override
  void initState() {
    super.initState();
    _loadLanguage();
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
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : '+971501234567',
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
        SnackBar(content: Text(_tr('Please enter valid OTP', 'يرجى إدخال رمز التحقق الصحيح'))),
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
      body: SafeArea(
        child: Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  
                  // Language Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment<String>(
                            value: 'en',
                            label: Text('English'),
                          ),
                          ButtonSegment<String>(
                            value: 'ar',
                            label: Text('العربية'),
                          ),
                        ],
                        selected: {_selectedLanguage},
                        onSelectionChanged: (Set<String> selection) {
                          setState(() => _selectedLanguage = selection.first);
                          widget.onLanguageChanged(_selectedLanguage);
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // App Logo and Title
                  Icon(
                    Icons.content_cut,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Zayyan - زين',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _tr(
                      'UAE Traditional Dress Tailors',
                      'خياطو الأزياء التقليدية الإماراتية'
                    ),
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Auth Form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Toggle Login/Register
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => setState(() {
                                    _isLogin = true;
                                    _showOtpField = false;
                                  }),
                                  child: Text(
                                    _tr('Login', 'تسجيل الدخول'),
                                    style: TextStyle(
                                      fontWeight: _isLogin ? FontWeight.bold : FontWeight.normal,
                                      color: _isLogin ? theme.colorScheme.primary : null,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextButton(
                                  onPressed: () => setState(() {
                                    _isLogin = false;
                                    _showOtpField = false;
                                  }),
                                  child: Text(
                                    _tr('Register', 'تسجيل جديد'),
                                    style: TextStyle(
                                      fontWeight: !_isLogin ? FontWeight.bold : FontWeight.normal,
                                      color: !_isLogin ? theme.colorScheme.primary : null,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Name Field (Register only)
                          if (!_isLogin)
                            TextFormField(
                              controller: _nameController,
                              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: _tr('Full Name', 'الاسم الكامل'),
                                prefixIcon: const Icon(Icons.person),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (!_isLogin && (value == null || value.isEmpty)) {
                                  return _tr('Please enter your name', 'يرجى إدخال الاسم');
                                }
                                return null;
                              },
                            ),
                          
                          if (!_isLogin) const SizedBox(height: 16),
                          
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: _tr('Email', 'البريد الإلكتروني'),
                              prefixIcon: const Icon(Icons.email),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return _tr('Please enter email', 'يرجى إدخال البريد الإلكتروني');
                              }
                              if (!value.contains('@')) {
                                return _tr('Please enter valid email', 'يرجى إدخال بريد إلكتروني صحيح');
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Phone Field (Register only)
                          if (!_isLogin)
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: _tr('Phone Number', 'رقم الهاتف'),
                                prefixIcon: const Icon(Icons.phone),
                                border: const OutlineInputBorder(),
                                hintText: '+971501234567',
                              ),
                              validator: (value) {
                                if (!_isLogin && (value == null || value.isEmpty)) {
                                  return _tr('Please enter phone number', 'يرجى إدخال رقم الهاتف');
                                }
                                return null;
                              },
                            ),
                          
                          if (!_isLogin) const SizedBox(height: 16),
                          
                          // OTP Field (Register - after phone)
                          if (!_isLogin && _showOtpField)
                            Column(
                              children: [
                                TextFormField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  decoration: InputDecoration(
                                    labelText: _tr('Verification Code', 'رمز التحقق'),
                                    prefixIcon: const Icon(Icons.security),
                                    border: const OutlineInputBorder(),
                                    hintText: '123456',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _tr(
                                    'Enter the 6-digit code sent to your phone',
                                    'أدخل الرمز المكون من 6 أرقام المرسل إلى هاتفك'
                                  ),
                                  style: theme.textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          
                          // Password Field (Login only, or Register after OTP)
                          if (_isLogin || (!_isLogin && _showOtpField))
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: _tr('Password', 'كلمة المرور'),
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return _tr('Please enter password', 'يرجى إدخال كلمة المرور');
                                }
                                if (value.length < 6) {
                                  return _tr('Password must be at least 6 characters', 'كلمة المرور يجب أن تكون 6 أحرف على الأقل');
                                }
                                return null;
                              },
                            ),
                          
                          const SizedBox(height: 24),
                          
                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleAuth,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text(
                                      _isLogin
                                          ? _tr('Login', 'تسجيل الدخول')
                                          : _showOtpField
                                              ? _tr('Verify & Complete', 'تحقق وإكمال')
                                              : _tr('Send Code', 'إرسال الرمز'),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Guest Mode Button
                  TextButton(
                    onPressed: _continueAsGuest,
                    child: Text(
                      _tr('Continue as Guest', 'المتابعة كضيف'),
                      style: TextStyle(color: theme.colorScheme.secondary),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
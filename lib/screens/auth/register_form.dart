// // lib/screens/auth/register_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:khyate_tailor_app/common_widget/custom_button.dart';
// import 'package:khyate_tailor_app/common_widget/custom_textfield.dart';
// import 'package:khyate_tailor_app/constants/color_constant.dart';
// import 'package:khyate_tailor_app/core/services/storage_services/storage_service.dart';
// import 'package:khyate_tailor_app/models/models.dart';
// import 'package:khyate_tailor_app/services/storage_service.dart';
// // import 'package:flutter/services.dart';
// // import 'package:intl/intl.dart';
// // import 'package:khyate_tailor_app/common_widget/custom_button.dart';
// // import 'package:khyate_tailor_app/common_widget/custom_textfield.dart';
// // import 'package:khyate_tailor_app/constants/color_constant.dart';
// // import 'package:khyate_tailor_app/models/models.dart';
// // import 'package:khyate_tailor_app/services/storage_service.dart';

// class RegisterScreen extends StatefulWidget {
//   final Function(String) onLanguageChanged;
//   const RegisterScreen({super.key, required this.onLanguageChanged});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
//   String _selectedLanguage = 'en';
//   bool _isLoading = false;
//   bool _obscurePassword = true;
//   String? _selectedGender;

//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _contactNumberController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _dobController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _cityController = TextEditingController();
//   final _ageController = TextEditingController();

//   AnimationController? _fadeController;
//   AnimationController? _slideController;
//   Animation<double>? _fadeAnimation;
//   Animation<Offset>? _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _loadLanguage();

//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController!, curve: Curves.easeInOut),
//     );
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.2),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(parent: _slideController!, curve: Curves.easeOutCubic),
//     );

//     _fadeController?.forward();
//     _slideController?.forward();
//   }

//   Future<void> _loadLanguage() async {
//     final language = await StorageService.getLanguage();
//     if (!mounted) return;
//     setState(() => _selectedLanguage = language);
//   }

//   String _tr(String en, String ar) => _selectedLanguage == 'ar' ? ar : en;
  
//   // Method to check if RTL
//   bool _isRTL() => _selectedLanguage == 'ar';

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
        
//         // Calculate age based on DOB
//         final now = DateTime.now();
//         int age = now.year - picked.year;
//         if (now.month < picked.month || 
//             (now.month == picked.month && now.day < picked.day)) {
//           age--;
//         }
//         _ageController.text = age.toString();
//       });
//     }
//   }

//   Future<void> _handleRegistration() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     await Future.delayed(const Duration(seconds: 2));

//     final user = User(
//       id: 'user_${DateTime.now().millisecondsSinceEpoch}',
//       name: _nameController.text,
//       email: _emailController.text,
//       phone: _contactNumberController.text,
//       preferredLanguage: _selectedLanguage,
//       dateOfBirth: _dobController.text,
//       address: _addressController.text,
//       city: _cityController.text,
//       gender: _selectedGender,
//       age: _ageController.text,
//     );

//     // await StorageService.saveUser(user);
//     // await StorageService.setLanguage(_selectedLanguage);

//     if (mounted) {
//       Navigator.of(context).pop(); // Return to login screen
//     }
//   }

//   void _togglePasswordVisibility() {
//     setState(() => _obscurePassword = !_obscurePassword);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
    
//     // Determine text direction - FIXED: Use enum values directly
//     // final textDirection = _selectedLanguage == 'ar' ? TextDirection.rtl : TextDirection.ltr;

//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           leading: IconButton(
//             icon: Icon(
//               _isRTL() ? Icons.arrow_forward : Icons.arrow_back,
//               color: ColorConstants.darkNavy,
//             ),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           title: Text(
//             _tr('Create Account', 'إنشاء حساب'),
//             style: theme.textTheme.titleLarge?.copyWith(
//               color: ColorConstants.darkNavy,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           centerTitle: true,
//         ),
//         body: Stack(
//           children: [
//             // Background Blobs
//             Positioned(
//               top: -60,
//               left: -40,
//               child: _Blob(
//                 size: 220,
//                 colors: [
//                   colorScheme.primary.withOpacity(0.10),
//                   colorScheme.secondary.withOpacity(0.20),
//                 ],
//               ),
//             ),
//             Positioned(
//               bottom: -80,
//               right: -60,
//               child: _Blob(
//                 size: 260,
//                 colors: [
//                   colorScheme.secondary.withOpacity(0.10),
//                   Colors.white.withOpacity(0.7),
//                 ],
//               ),
//             ),

//             SafeArea(
//               child: Directionality(
//                 textDirection: textDirection, // Use the variable here
//                 child: LayoutBuilder(
//                   builder: (context, constraints) {
//                     final isWide = constraints.maxWidth > 480;
//                     final horizontalPadding = isWide ? (constraints.maxWidth - 420) / 2 : 24.0;

//                     return SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 40),
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           children: [
//                             // Language Selector
//                             FadeTransition(
//                               opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
//                               child: Align(
//                                 alignment: Alignment.center,
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 40),
//                                   child: Semantics(
//                                     label: _tr('Language selector', 'اختيار اللغة'),
//                                     child: SegmentedButton<String>(
//                                       style: SegmentedButton.styleFrom(
//                                         backgroundColor: ColorConstants.deepNavy,
//                                         selectedBackgroundColor: ColorConstants.accentTeal,
//                                         selectedForegroundColor: Colors.white,
//                                         side: BorderSide.none,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(28),
//                                         ),
//                                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                                       ),
//                                       segments: [
//                                         ButtonSegment<String>(
//                                           value: 'en',
//                                           label: Text(
//                                             'EN',
//                                             style: theme.textTheme.labelLarge?.copyWith(
//                                               fontWeight: FontWeight.w700,
//                                             ),
//                                           ),
//                                         ),
//                                         ButtonSegment<String>(
//                                           value: 'ar',
//                                           label: Text(
//                                             'عربي',
//                                             style: theme.textTheme.labelLarge?.copyWith(
//                                               fontWeight: FontWeight.w700,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                       selected: {_selectedLanguage},
//                                       onSelectionChanged: (Set<String> selection) {
//                                         setState(() => _selectedLanguage = selection.first);
//                                         widget.onLanguageChanged(_selectedLanguage);
//                                         HapticFeedback.selectionClick();
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 28),

//                             // Registration Form Card
//                             SlideTransition(
//                               position: _slideAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
//                               child: DecoratedBox(
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.92),
//                                   borderRadius: BorderRadius.circular(22),
//                                   border: Border.all(color: Colors.grey.shade200),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.06),
//                                       blurRadius: 24,
//                                       offset: const Offset(0, 12),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
//                                   child: Column(
//                                     children: [
//                                       // Registration Title
//                                       Text(
//                                         _tr('Create Account', 'إنشاء حساب'),
//                                         style: theme.textTheme.headlineSmall?.copyWith(
//                                           fontWeight: FontWeight.bold,
//                                           color: colorScheme.primary,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 20),

//                                       // Personal Information Fields
//                                       CustomTextField(
//                                         controller: _nameController,
//                                         labelText: _tr('Full Name', 'الاسم الكامل'),
//                                         prefixIcon: Icons.person_outline,
//                                         keyboardType: TextInputType.name,
//                                         textInputAction: TextInputAction.next,
//                                         validator: (value) {
//                                           if (value?.isEmpty ?? true) {
//                                             return _tr('Please enter your name', 'يرجى إدخال الاسم');
//                                           }
//                                           return null;
//                                         },
//                                         semanticLabel: _tr('Full Name', 'الاسم الكامل'),
//                                         isRTL: _isRTL(),
//                                       ),
//                                       const SizedBox(height: 16),

//                                       CustomTextField(
//                                         controller: _contactNumberController,
//                                         labelText: _tr('Contact Number', 'رقم الاتصال'),
//                                         prefixIcon: Icons.phone_outlined,
//                                         keyboardType: TextInputType.phone,
//                                         textInputAction: TextInputAction.next,
//                                         validator: (value) {
//                                           if (value?.isEmpty ?? true) {
//                                             return _tr('Please enter contact number', 'يرجى إدخال رقم الاتصال');
//                                           }
//                                           if ((value?.length ?? 0) < 10) {
//                                             return _tr('Invalid phone number', 'رقم هاتف غير صحيح');
//                                           }
//                                           return null;
//                                         },
//                                         semanticLabel: _tr('Contact Number', 'رقم الاتصال'),
//                                         isRTL: _isRTL(),
//                                       ),
//                                       const SizedBox(height: 16),

//                                       CustomTextField(
//                                         controller: _emailController,
//                                         labelText: _tr('Email', 'البريد الإلكتروني'),
//                                         prefixIcon: Icons.email_outlined,
//                                         keyboardType: TextInputType.emailAddress,
//                                         textInputAction: TextInputAction.next,
//                                         validator: (value) {
//                                           if (value?.isEmpty ?? true) {
//                                             return _tr('Please enter email', 'يرجى إدخال البريد');
//                                           }
//                                           if (!(value?.contains('@') ?? false)) {
//                                             return _tr('Invalid email', 'بريد إلكتروني غير صحيح');
//                                           }
//                                           return null;
//                                         },
//                                         semanticLabel: _tr('Email', 'البريد الإلكتروني'),
//                                         isRTL: _isRTL(),
//                                       ),
//                                       const SizedBox(height: 16),

//                                       CustomTextField(
//                                         controller: _passwordController,
//                                         labelText: _tr('Password', 'كلمة المرور'),
//                                         prefixIcon: Icons.lock_outline,
//                                         obscureText: _obscurePassword,
//                                         textInputAction: TextInputAction.next,
//                                         suffixIcon: IconButton(
//                                           tooltip: _tr('Toggle password visibility', 'إظهار/إخفاء كلمة المرور'),
//                                           icon: Icon(
//                                             _obscurePassword
//                                                 ? Icons.visibility_off_outlined
//                                                 : Icons.visibility_outlined,
//                                             color: Colors.grey[600],
//                                           ),
//                                           onPressed: _togglePasswordVisibility,
//                                         ),
//                                         validator: (value) {
//                                           if (value?.isEmpty ?? true) {
//                                             return _tr('Password required', 'كلمة المرور مطلوبة');
//                                           }
//                                           if ((value?.length ?? 0) < 6) {
//                                             return _tr('Min 6 characters', 'الحد الأدنى 6 أحرف');
//                                           }
//                                           return null;
//                                         },
//                                         semanticLabel: _tr('Password', 'كلمة المرور'),
//                                         isRTL: _isRTL(),
//                                       ),
//                                       const SizedBox(height: 16),

//                                       // Date of Birth Field
//                                       CustomTextField(
//                                         controller: _dobController,
//                                         labelText: _tr('Date of Birth', 'تاريخ الميلاد'),
//                                         prefixIcon: Icons.calendar_today_outlined,
//                                         readOnly: true,
//                                         onTap: () => _selectDate(context),
//                                         validator: (value) {
//                                           if (value?.isEmpty ?? true) {
//                                             return _tr('Please select date of birth', 'يرجى اختيار تاريخ الميلاد');
//                                           }
//                                           return null;
//                                         },
//                                         semanticLabel: _tr('Date of Birth', 'تاريخ الميلاد'),
//                                         isRTL: _isRTL(),
//                                       ),
//                                       const SizedBox(height: 16),

//                                       // Age Field (auto-calculated from DOB)
//                                       CustomTextField(
//                                         controller: _ageController,
//                                         labelText: _tr('Age', 'العمر'),
//                                         prefixIcon: Icons.cake_outlined,
//                                         keyboardType: TextInputType.number,
//                                         readOnly: true,
//                                         validator: (value) {
//                                           if (value?.isEmpty ?? true) {
//                                             return _tr('Age is required', 'العمر مطلوب');
//                                           }
//                                           return null;
//                                         },
//                                         semanticLabel: _tr('Age', 'العمر'),
//                                         isRTL: _isRTL(),
//                                       ),
//                                       const SizedBox(height: 16),

//                                       // Gender Selection
//                                       DropdownButtonFormField<String>(
//                                         value: _selectedGender,
//                                         decoration: InputDecoration(
//                                           labelText: _tr('Gender', 'الجنس'),
//                                           prefixIcon: const Icon(Icons.person_outline),
//                                           border: OutlineInputBorder(
//                                             borderRadius: BorderRadius.circular(12),
//                                             borderSide: BorderSide(color: Colors.grey.shade400),
//                                           ),
//                                           enabledBorder: OutlineInputBorder(
//                                             borderRadius: BorderRadius.circular(12),
//                                             borderSide: BorderSide(color: Colors.grey.shade400),
//                                           ),
//                                           filled: true,
//                                           fillColor: Colors.grey.shade50,
//                                           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                                           alignLabelWithHint: true,
//                                         ),
//                                         items: [
//                                           DropdownMenuItem(
//                                             value: 'male',
//                                             child: Text(_tr('Male', 'ذكر')),
//                                           ),
//                                           DropdownMenuItem(
//                                             value: 'female',
//                                             child: Text(_tr('Female', 'أنثى')),
//                                           ),
//                                         ],
//                                         onChanged: (value) {
//                                           setState(() {
//                                             _selectedGender = value;
//                                           });
//                                         },
//                                         validator: (value) {
//                                           if (value == null) {
//                                             return _tr('Please select gender', 'يرجى اختيار الجنس');
//                                           }
//                                           return null;
//                                         },
//                                       ),
//                                       const SizedBox(height: 16),

//                                       // Address Field
//                                       CustomTextField(
//                                         controller: _addressController,
//                                         labelText: _tr('Address', 'العنوان'),
//                                         prefixIcon: Icons.home_outlined,
//                                         keyboardType: TextInputType.streetAddress,
//                                         textInputAction: TextInputAction.next,
//                                         validator: (value) {
//                                           if (value?.isEmpty ?? true) {
//                                             return _tr('Please enter address', 'يرجى إدخال العنوان');
//                                           }
//                                           return null;
//                                         },
//                                         semanticLabel: _tr('Address', 'العنوان'),
//                                         isRTL: _isRTL(),
//                                       ),
//                                       const SizedBox(height: 16),

//                                       // City Field
//                                       CustomTextField(
//                                         controller: _cityController,
//                                         labelText: _tr('City', 'المدينة'),
//                                         prefixIcon: Icons.location_city_outlined,
//                                         keyboardType: TextInputType.text,
//                                         textInputAction: TextInputAction.done,
//                                         validator: (value) {
//                                           if (value?.isEmpty ?? true) {
//                                             return _tr('Please enter city', 'يرجى إدخال المدينة');
//                                           }
//                                           return null;
//                                         },
//                                         semanticLabel: _tr('City', 'المدينة'),
//                                         isRTL: _isRTL(),
//                                       ),
//                                       const SizedBox(height: 24),

//                                       CustomButton(
//                                         text: _tr('Create Account', 'إنشاء حساب'),
//                                         onPressed: _isLoading ? null : _handleRegistration,
//                                         isLoading: _isLoading,
//                                         semanticLabel: _tr('Create Account', 'إنشاء حساب'),
//                                       ),
//                                       const SizedBox(height: 16),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),

//                             const SizedBox(height: 18),

//                             // Footer
//                             Column(
//                               children: [
//                                 Text(
//                                   _tr('Crafted with care in the UAE', 'مصنوعة بعناية في الإمارات'),
//                                   style: theme.textTheme.bodySmall?.copyWith(
//                                     color: Colors.grey[600],
//                                     fontStyle: FontStyle.italic,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                                 const SizedBox(height: 6),
//                                 const SizedBox(height: 12),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _fadeController?.dispose();
//     _slideController?.dispose();
//     _nameController.dispose();
//     _contactNumberController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _dobController.dispose();
//     _addressController.dispose();
//     _cityController.dispose();
//     _ageController.dispose();
//     super.dispose();
//   }
// }

// class _Blob extends StatelessWidget {
//   final double size;
//   final List<Color> colors;

//   const _Blob({required this.size, required this.colors});

//   @override
//   Widget build(BuildContext context) {
//     return IgnorePointer(
//       child: Container(
//         width: size,
//         height: size,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           gradient: RadialGradient(colors: colors, radius: 0.8),
//           boxShadow: [
//             BoxShadow(
//               color: colors.first.withOpacity(0.25),
//               blurRadius: 40,
//               spreadRadius: 10,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
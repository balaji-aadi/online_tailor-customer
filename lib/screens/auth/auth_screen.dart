// // lib/screens/auth/auth_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:khyate_tailor_app/common_widget/custom_button.dart';
// import 'package:khyate_tailor_app/common_widget/custom_textfield.dart';
// import 'package:khyate_tailor_app/constants/color_constant.dart';
// import 'package:khyate_tailor_app/models/models.dart';
// import 'package:khyate_tailor_app/screens/auth/login_form.dart';

// import 'package:khyate_tailor_app/screens/auth/register_form.dart';

// import 'package:khyate_tailor_app/screens/home/home_screen.dart';
// import 'package:khyate_tailor_app/services/storage_service.dart';

// class AuthScreen extends StatefulWidget {
//   final Function(String) onLanguageChanged;
//   const AuthScreen({super.key, required this.onLanguageChanged});

//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
//   String _selectedLanguage = 'en';
//   bool _isLogin = true;
//   bool _isLoading = false;
//   bool _isGuestMode = false;

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

//   Future<void> _continueAsGuest() async {
//     setState(() => _isGuestMode = true);
//     await StorageService.setLanguage(_selectedLanguage);

//     if (mounted) {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => const HomeScreen()),
//       );
//     }
//   }

//   void _toggleAuthMode() {
//     setState(() {
//       _isLogin = !_isLogin;
//     });
//     HapticFeedback.lightImpact();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isRTL = _selectedLanguage == 'ar';
//     final colorScheme = theme.colorScheme;

//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
//       child: Scaffold(
//         backgroundColor: Colors.white,
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
//                 textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
//                 child: LayoutBuilder(
//                   builder: (context, constraints) {
//                     final isWide = constraints.maxWidth > 480;
//                     final horizontalPadding = isWide ? (constraints.maxWidth - 420) / 2 : 24.0;

//                     return SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 40),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           // Language Selector
//                           FadeTransition(
//                             opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
//                             child: Align(
//                               alignment: Alignment.center,
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 40),
//                                 child: Semantics(
//                                   label: _tr('Language selector', 'اختيار اللغة'),
//                                   child: SegmentedButton<String>(
//                                     style: SegmentedButton.styleFrom(
//                                       backgroundColor: ColorConstants.deepNavy,
//                                       selectedBackgroundColor: ColorConstants.accentTeal,
//                                       selectedForegroundColor: Colors.white,
//                                       side: BorderSide.none,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(28),
//                                       ),
//                                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                                     ),
//                                     segments: [
//                                       ButtonSegment<String>(
//                                         value: 'en',
//                                         label: Text(
//                                           'EN',
//                                           style: theme.textTheme.labelLarge?.copyWith(
//                                             fontWeight: FontWeight.w700,
//                                           ),
//                                         ),
//                                       ),
//                                       ButtonSegment<String>(
//                                         value: 'ar',
//                                         label: Text(
//                                           'عربي',
//                                           style: theme.textTheme.labelLarge?.copyWith(
//                                             fontWeight: FontWeight.w700,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                     selected: {_selectedLanguage},
//                                     onSelectionChanged: (Set<String> selection) {
//                                       setState(() => _selectedLanguage = selection.first);
//                                       widget.onLanguageChanged(_selectedLanguage);
//                                       HapticFeedback.selectionClick();
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 28),

//                           // Logo & Branding
//                           SlideTransition(
//                             position: _slideAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
//                             child: FadeTransition(
//                               opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
//                               child: Column(
//                                 children: [
//                                   Image.asset(
//                                     'assets/images/khyate_logo.png',
//                                     height: 72,
//                                     fit: BoxFit.contain,
//                                   ),
//                                   const SizedBox(height: 12),
//                                   const SizedBox(height: 6),
//                                   Text(
//                                     _tr('UAE Heritage Tailoring', 'خياطة تراث الإمارات'),
//                                     textAlign: TextAlign.center,
//                                     style: theme.textTheme.titleMedium?.copyWith(
//                                       color: ColorConstants.darkNavy,
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 36),

//                           // Divider with Icon
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8),
//                             child: Row(
//                               children: [
//                                 Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
//                                 Icon(
//                                   Icons.design_services_outlined,
//                                   size: 47,
//                                   color: colorScheme.primary.withOpacity(1.0),
//                                 ),
//                                 Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 10),

//                           // Auth Form Card
//                           SlideTransition(
//                             position: _slideAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
//                             child: DecoratedBox(
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.92),
//                                 borderRadius: BorderRadius.circular(22),
//                                 border: Border.all(color: Colors.grey.shade200),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.06),
//                                     blurRadius: 24,
//                                     offset: const Offset(0, 12),
//                                   ),
//                                 ],
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
//                                 child: Column(
//                                   children: [
//                                     // Login / Register Tabs
//                                     Semantics(
//                                       label: _tr('Authentication mode', 'وضع المصادقة'),
//                                       child: Container(
//                                         padding: const EdgeInsets.all(6),
//                                         decoration: BoxDecoration(
//                                           color: Colors.grey[100],
//                                           borderRadius: BorderRadius.circular(14),
//                                         ),
//                                         child: Row(
//                                           children: [
//                                             Expanded(
//                                               child: _Segment(
//                                                 active: _isLogin,
//                                                 label: _tr('Login', 'تسجيل الدخول'),
//                                                 onTap: () {
//                                                   if (!_isLogin) _toggleAuthMode();
//                                                 },
//                                               ),
//                                             ),
//                                             const SizedBox(width: 6),
//                                             Expanded(
//                                               child: _Segment(
//                                                 active: !_isLogin,
//                                                 label: _tr('Register', 'تسجيل جديد'),
//                                                 onTap: () {
//                                                   if (_isLogin) _toggleAuthMode();
//                                                 },
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 28),

//                                     // Show either Login or Register screen
//                                     AnimatedSwitcher(
//                                       duration: const Duration(milliseconds: 300),
//                                       child: _isLogin
//                                           ? LoginScreen(
//                                               key: const ValueKey('login_screen'),
//                                               onLanguageChanged: widget.onLanguageChanged,
//                                               selectedLanguage: _selectedLanguage,
//                                               onToggleAuthMode: _toggleAuthMode,
//                                               onContinueAsGuest: _continueAsGuest,
//                                             )
//                                           : RegisterScreen(
//                                               key: const ValueKey('register_screen'),
//                                               onLanguageChanged: widget.onLanguageChanged,
//                                               selectedLanguage: _selectedLanguage,
//                                               onToggleAuthMode: _toggleAuthMode,
//                                               onContinueAsGuest: _continueAsGuest,
//                                             ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
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
//     super.dispose();
//   }
// }

// // === UI Helpers ===
// class _Segment extends StatelessWidget {
//   final bool active;
//   final String label;
//   final VoidCallback onTap;

//   const _Segment({required this.active, required this.label, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 220),
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: active ? ColorConstants.accentTeal : Colors.transparent,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Text(
//           label,
//           style: theme.textTheme.labelLarge?.copyWith(
//             fontWeight: FontWeight.w800,
//             color: active ? Colors.white : Colors.grey[700],
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
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
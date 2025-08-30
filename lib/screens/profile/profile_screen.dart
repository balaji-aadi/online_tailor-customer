// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:khyate_tailor_app/constants/color_constant.dart';
import 'package:khyate_tailor_app/models/models.dart';
import 'package:khyate_tailor_app/screens/auth/auth_screen.dart';
import 'package:khyate_tailor_app/screens/measurement_screen.dart';
import 'package:khyate_tailor_app/services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedLanguage = 'en';
  User? _currentUser;
  Map<String, bool> _notificationSettings = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final language = await StorageService.getLanguage();
    final user = await StorageService.getCurrentUser();
    final settings = await StorageService.getNotificationSettings();

    setState(() {
      _selectedLanguage = language;
      _currentUser = user;
      _notificationSettings = settings;
    });
  }

  String _tr(String en, String ar) => _selectedLanguage == 'ar' ? ar : en;

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: color.withOpacity(0.3),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    if (_currentUser == null) return;

    final nameController = TextEditingController(text: _currentUser!.name);
    final emailController = TextEditingController(text: _currentUser!.email);
    final phoneController = TextEditingController(text: _currentUser!.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _tr('Edit Profile', 'تعديل الملف الشخصي'),
          style: const TextStyle(color: ColorConstants.deepNavy),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: _tr('Name', 'الاسم'),
                  labelStyle: const TextStyle(color: ColorConstants.accentTeal),
                  filled: true,
                  fillColor: ColorConstants.softIvory,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: _tr('Email', 'البريد الإلكتروني'),
                  labelStyle: const TextStyle(color: ColorConstants.accentTeal),
                  filled: true,
                  fillColor: ColorConstants.softIvory,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: _tr('Phone', 'الهاتف'),
                  labelStyle: const TextStyle(color: ColorConstants.accentTeal),
                  filled: true,
                  fillColor: ColorConstants.softIvory,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              _tr('Cancel', 'إلغاء'),
              style: TextStyle(color: ColorConstants.accentTeal),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedUser = User(
                id: _currentUser!.id,
                name: nameController.text.trim(),
                email: emailController.text.trim(),
                phone: phoneController.text.trim(),
                profileImage: _currentUser!.profileImage,
                preferredLanguage: _currentUser!.preferredLanguage,
                addresses: _currentUser!.addresses,
                favoriteTailorIds: _currentUser!.favoriteTailorIds,
              );

              await StorageService.saveUser(updatedUser);
              Navigator.of(context).pop();
              _loadData();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(_tr('Profile updated', 'تم تحديث الملف الشخصي')),
                  backgroundColor: ColorConstants.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.primaryGold,
              foregroundColor: ColorConstants.warmIvory,
            ),
            child: Text(_tr('Save', 'حفظ')),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _tr('Select Language', 'اختر اللغة'),
          style: const TextStyle(color: ColorConstants.deepNavy),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged: (value) => _changeLanguage(value!),
            ),
            RadioListTile<String>(
              title: const Text('العربية'),
              value: 'ar',
              groupValue: _selectedLanguage,
              onChanged: (value) => _changeLanguage(value!),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeLanguage(String language) async {
    await StorageService.setLanguage(language);
    Navigator.of(context).pop();

    // Restart the app to apply language changes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => AuthScreen(onLanguageChanged: (_) {}),
      ),
      (route) => false,
    );
  }

  Future<void> _updateNotificationSetting(String key, bool value) async {
    _notificationSettings[key] = value;
    await StorageService.updateNotificationSettings(_notificationSettings);
    setState(() {});
  }

  void _showFavorites() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(_tr('Favorites feature coming soon', 'ميزة المفضلة قريباً')),
        backgroundColor: ColorConstants.warning,
      ),
    );
  }

  void _showHelpCenter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _tr('Help Center', 'مركز المساعدة'),
          style: TextStyle(color: ColorConstants.deepNavy),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _tr('Frequently Asked Questions', 'الأسئلة الشائعة'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: ColorConstants.deepNavy,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _FAQItem(
                question: _tr('How do I place an order?', 'كيف أضع طلباً؟'),
                answer: _tr(
                  'Browse tailors, select a service, provide measurements (if needed), and place your order.',
                  'تصفح الخياطين، اختر خدمة، قدم القياسات (إذا لزم الأمر)، واضع طلبك.',
                ),
              ),
              _FAQItem(
                question:
                    _tr('How do I save my measurements?', 'كيف أحفظ قياساتي؟'),
                answer: _tr(
                  'Go to Profile > My Measurements and add your body measurements.',
                  'اذهب إلى الملف الشخصي > قياساتي وأضف قياسات جسمك.',
                ),
              ),
              _FAQItem(
                question:
                    _tr('How can I track my order?', 'كيف يمكنني تتبع طلبي؟'),
                answer: _tr(
                  'Check the Orders tab to see the status of all your orders.',
                  'تحقق من تبويب الطلبات لرؤية حالة جميع طلباتك.',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              _tr('Close', 'إغلاق'),
              style: TextStyle(color: ColorConstants.accentTeal),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _tr('Contact Us', 'اتصل بنا'),
          style: TextStyle(color: ColorConstants.deepNavy),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ContactItem(
              icon: Icons.phone,
              label: _tr('Phone', 'الهاتف'),
              value: '+971 4 123 4567',
            ),
            _ContactItem(
              icon: Icons.email,
              label: _tr('Email', 'البريد الإلكتروني'),
              value: 'support@zayyan.ae',
            ),
            _ContactItem(
              icon: Icons.location_on,
              label: _tr('Address', 'العنوان'),
              value: _tr('Dubai, United Arab Emirates',
                  'دبي، الإمارات العربية المتحدة'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              _tr('Close', 'إغلاق'),
              style: TextStyle(color: ColorConstants.accentTeal),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Zayyan - زين',
      applicationVersion: '1.0.0',
      applicationLegalese: _tr(
        '© 2025 Zayyan. All rights reserved.',
        '© 2025 زين. جميع الحقوق محفوظة.',
      ),
      children: [
        Text(
          _tr(
            'Connecting you to UAE\'s finest traditional dress tailors.',
            'نربطك بأفضل خياطي الأزياء التقليدية في الإمارات.',
          ),
          style: TextStyle(color: ColorConstants.deepNavy),
        ),
      ],
    );
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _tr('Sign Out', 'تسجيل الخروج'),
          style: TextStyle(color: ColorConstants.deepNavy),
        ),
        content: Text(
          _tr(
            'Are you sure you want to sign out?',
            'هل أنت متأكد من تسجيل الخروج؟',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              _tr('Cancel', 'إلغاء'),
              style: TextStyle(color: ColorConstants.accentTeal),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.error,
              foregroundColor: ColorConstants.warmIvory,
            ),
            child: Text(_tr('Sign Out', 'تسجيل الخروج')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.clearUser();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => AuthScreen(onLanguageChanged: (_) {}),
          ),
          (route) => false,
        );
      }
    }
  }

  void _signIn() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => AuthScreen(onLanguageChanged: (_) {}),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = _selectedLanguage == 'ar';

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: ColorConstants.warmIvory,
        appBar: AppBar(
          backgroundColor: ColorConstants.accentTeal,
          foregroundColor: ColorConstants.warmIvory,
          title: Text(
            _tr('Profile', 'الملف الشخصي'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          elevation: 1,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // === User Info Card ===
              if (_currentUser != null) ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Profile Avatar
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: ColorConstants.accentTeal,
                              child: _currentUser!.profileImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(40),
                                      child: Image.network(
                                        _currentUser!.profileImage!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient:
                                            ColorConstants.primaryGradient,
                                      ),
                                      child: Center(
                                        child: Text(
                                          _currentUser!.name
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 28,
                                            color: ColorConstants.warmIvory,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: ColorConstants.primaryGold,
                                  shape: BoxShape.circle,
                                  border: Border.fromBorderSide(
                                    BorderSide(
                                        color: ColorConstants.warmIvory,
                                        width: 2),
                                  ),
                                ),
                                child: const Icon(Icons.edit,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentUser!.name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: ColorConstants.deepNavy,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentUser!.email,
                                style: const TextStyle(
                                  color: ColorConstants.accentTeal,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                _currentUser!.phone,
                                style: const TextStyle(
                                  color: ColorConstants.accentTeal,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Guest Mode
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor:
                              ColorConstants.accentTeal.withOpacity(0.2),
                          child: Icon(
                            Icons.person_outline,
                            size: 50,
                            color: ColorConstants.accentTeal,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _tr('Guest User', 'مستخدم ضيف'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: ColorConstants.deepNavy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _tr(
                            'Sign in to access all features',
                            'سجل دخولك للوصول لجميع الميزات',
                          ),
                          style: const TextStyle(
                            color: ColorConstants.accentTeal,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // === Menu Sections ===
              _MenuSection(
                title: _tr('Account', 'الحساب'),
                items: [
                  if (_currentUser != null)
                    _MenuItem(
                      icon: Icons.straighten,
                      iconColor: ColorConstants.primaryGold,
                      title: _tr('My Measurements', 'قياساتي'),
                      subtitle: _tr(
                          'Manage your body measurements', 'إدارة قياسات جسمك'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MeasurementScreen(),
                        ),
                      ),
                    ),
                  if (_currentUser != null)
                    _MenuItem(
                      icon: Icons.favorite,
                      iconColor: ColorConstants.primaryGold,
                      title: _tr('Favorites', 'المفضلة'),
                      subtitle: _tr(
                          'Your favorite tailors', 'الخياطون المفضلون لديك'),
                      onTap: () => _showFavorites(),
                    ),
                  _MenuItem(
                    icon: Icons.language,
                    iconColor: ColorConstants.primaryGold,
                    title: _tr('Language', 'اللغة'),
                    subtitle: _selectedLanguage == 'ar' ? 'العربية' : 'English',
                    onTap: () => _showLanguageDialog(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _MenuSection(
                title: _tr('Notifications', 'الإشعارات'),
                items: [
                  _MenuItem(
                    icon: Icons.notifications,
                    iconColor: ColorConstants.primaryGold,
                    title: _tr('Order Updates', 'تحديثات الطلبات'),
                    trailing: Switch(
                      activeColor: ColorConstants.primaryGold,
                      inactiveTrackColor:
                          ColorConstants.accentTeal.withOpacity(0.3),
                      value: _notificationSettings['orderUpdates'] ?? true,
                      onChanged: (value) =>
                          _updateNotificationSetting('orderUpdates', value),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.message,
                    iconColor: ColorConstants.primaryGold,
                    title: _tr('Messages', 'الرسائل'),
                    trailing: Switch(
                      activeColor: ColorConstants.primaryGold,
                      inactiveTrackColor:
                          ColorConstants.accentTeal.withOpacity(0.3),
                      value: _notificationSettings['messages'] ?? true,
                      onChanged: (value) =>
                          _updateNotificationSetting('messages', value),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.straighten,
                    iconColor: ColorConstants.primaryGold,
                    title: _tr('Measurement Requests', 'طلبات القياسات'),
                    trailing: Switch(
                      activeColor: ColorConstants.primaryGold,
                      inactiveTrackColor:
                          ColorConstants.accentTeal.withOpacity(0.3),
                      value: _notificationSettings['measurements'] ?? true,
                      onChanged: (value) =>
                          _updateNotificationSetting('measurements', value),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.local_offer,
                    iconColor: ColorConstants.primaryGold,
                    title: _tr('Promotions', 'العروض'),
                    trailing: Switch(
                      activeColor: ColorConstants.primaryGold,
                      inactiveTrackColor:
                          ColorConstants.accentTeal.withOpacity(0.3),
                      value: _notificationSettings['promotions'] ?? false,
                      onChanged: (value) =>
                          _updateNotificationSetting('promotions', value),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _MenuSection(
                title: _tr('Support', 'الدعم'),
                items: [
                  _MenuItem(
                    icon: Icons.help,
                    iconColor: ColorConstants.primaryGold,
                    title: _tr('Help Center', 'مركز المساعدة'),
                    subtitle: _tr('FAQ and support', 'الأسئلة الشائعة والدعم'),
                    onTap: () => _showHelpCenter(),
                  ),
                  _MenuItem(
                    icon: Icons.contact_support,
                    iconColor: ColorConstants.primaryGold,
                    title: _tr('Contact Us', 'اتصل بنا'),
                    subtitle:
                        _tr('Get in touch with our team', 'تواصل مع فريقنا'),
                    onTap: () => _showContactInfo(),
                  ),
                  _MenuItem(
                    icon: Icons.info,
                    iconColor: ColorConstants.primaryGold,
                    title: _tr('About', 'حول التطبيق'),
                    subtitle: _tr('Version 1.0.0', 'الإصدار 1.0.0'),
                    onTap: () => _showAboutDialog(),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // === Sign In / Out Button ===
              if (_currentUser != null)
                _buildActionButton(
                  text: _tr('Sign Out', 'تسجيل الخروج'),
                  icon: Icons.logout,
                  color: ColorConstants.error,
                  onPressed: _signOut,
                )
              else
                _buildActionButton(
                  text: _tr('Sign In', 'تسجيل الدخول'),
                  icon: Icons.login,
                  color: ColorConstants.accentTeal,
                  onPressed: _signIn,
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// === Reusable Components ===

class _MenuSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _MenuSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              color: ColorConstants.accentTeal,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Card(
          color: ColorConstants.softIvory,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? ColorConstants.accentTeal,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: ColorConstants.deepNavy,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: ColorConstants.accentTeal,
                fontSize: 13,
              ),
            )
          : null,
      trailing: trailing ??
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: ColorConstants.accentTeal,
          ),
      onTap: onTap,
    );
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              color: ColorConstants.deepNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: TextStyle(
              color: ColorConstants.accentTeal,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: ColorConstants.primaryGold),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: ColorConstants.accentTeal,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: ColorConstants.deepNavy,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

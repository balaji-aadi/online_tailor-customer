import 'package:flutter/material.dart';
import 'package:zayyan/models/models.dart';
import 'package:zayyan/services/storage_service.dart';
import 'package:zayyan/screens/measurement_screen.dart';
import 'package:zayyan/screens/auth_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = _selectedLanguage == 'ar';

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_tr('Profile', 'الملف الشخصي')),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // User Info Card
              if (_currentUser != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: _currentUser!.profileImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(32),
                                  child: Image.network(
                                    _currentUser!.profileImage!,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Text(
                                  _currentUser!.name
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentUser!.name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentUser!.email,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                              Text(
                                _currentUser!.phone,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showEditProfileDialog(),
                          icon: const Icon(Icons.edit),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Guest user
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _tr('Guest User', 'مستخدم ضيف'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _tr('Sign in to access all features',
                              'سجل دخولك للوصول لجميع الميزات'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Menu Items
              _MenuSection(
                title: _tr('Account', 'الحساب'),
                items: [
                  if (_currentUser != null) ...[
                    _MenuItem(
                      icon: Icons.straighten,
                      title: _tr('My Measurements', 'قياساتي'),
                      subtitle: _tr(
                          'Manage your body measurements', 'إدارة قياسات جسمك'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MeasurementScreen(),
                        ),
                      ),
                    ),
                    _MenuItem(
                      icon: Icons.favorite,
                      title: _tr('Favorites', 'المفضلة'),
                      subtitle: _tr(
                          'Your favorite tailors', 'الخياطون المفضلون لديك'),
                      onTap: () => _showFavorites(),
                    ),
                  ],
                  _MenuItem(
                    icon: Icons.language,
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
                    title: _tr('Order Updates', 'تحديثات الطلبات'),
                    trailing: Switch(
                      value: _notificationSettings['orderUpdates'] ?? true,
                      onChanged: (value) =>
                          _updateNotificationSetting('orderUpdates', value),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.message,
                    title: _tr('Messages', 'الرسائل'),
                    trailing: Switch(
                      value: _notificationSettings['messages'] ?? true,
                      onChanged: (value) =>
                          _updateNotificationSetting('messages', value),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.straighten,
                    title: _tr('Measurement Requests', 'طلبات القياسات'),
                    trailing: Switch(
                      value: _notificationSettings['measurements'] ?? true,
                      onChanged: (value) =>
                          _updateNotificationSetting('measurements', value),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.local_offer,
                    title: _tr('Promotions', 'العروض'),
                    trailing: Switch(
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
                    title: _tr('Help Center', 'مركز المساعدة'),
                    subtitle: _tr('FAQ and support', 'الأسئلة الشائعة والدعم'),
                    onTap: () => _showHelpCenter(),
                  ),
                  _MenuItem(
                    icon: Icons.contact_support,
                    title: _tr('Contact Us', 'اتصل بنا'),
                    subtitle:
                        _tr('Get in touch with our team', 'تواصل مع فريقنا'),
                    onTap: () => _showContactInfo(),
                  ),
                  _MenuItem(
                    icon: Icons.info,
                    title: _tr('About', 'حول التطبيق'),
                    subtitle: _tr('Version 1.0.0', 'الإصدار 1.0.0'),
                    onTap: () => _showAboutDialog(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Sign Out Button
              if (_currentUser != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _signOut(),
                    icon: const Icon(Icons.logout),
                    label: Text(_tr('Sign Out', 'تسجيل الخروج')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _signIn(),
                    icon: const Icon(Icons.login),
                    label: Text(_tr('Sign In', 'تسجيل الدخول')),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
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
        title: Text(_tr('Edit Profile', 'تعديل الملف الشخصي')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: _tr('Name', 'الاسم'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: _tr('Email', 'البريد الإلكتروني'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: _tr('Phone', 'الهاتف'),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_tr('Cancel', 'إلغاء')),
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
                  backgroundColor: Colors.green,
                ),
              );
            },
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
        title: Text(_tr('Select Language', 'اختر اللغة')),
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
          content: Text(
              _tr('Favorites feature coming soon', 'ميزة المفضلة قريباً'))),
    );
  }

  void _showHelpCenter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_tr('Help Center', 'مركز المساعدة')),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _tr('Frequently Asked Questions', 'الأسئلة الشائعة'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _FAQItem(
                question: _tr('How do I place an order?', 'كيف أضع طلباً؟'),
                answer: _tr(
                    'Browse tailors, select a service, provide measurements (if needed), and place your order.',
                    'تصفح الخياطين، اختر خدمة، قدم القياسات (إذا لزم الأمر)، واضع طلبك.'),
              ),
              _FAQItem(
                question:
                    _tr('How do I save my measurements?', 'كيف أحفظ قياساتي؟'),
                answer: _tr(
                    'Go to Profile > My Measurements and add your body measurements.',
                    'اذهب إلى الملف الشخصي > قياساتي وأضف قياسات جسمك.'),
              ),
              _FAQItem(
                question:
                    _tr('How can I track my order?', 'كيف يمكنني تتبع طلبي؟'),
                answer: _tr(
                    'Check the Orders tab to see the status of all your orders.',
                    'تحقق من تبويب الطلبات لرؤية حالة جميع طلباتك.'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_tr('Close', 'إغلاق')),
          ),
        ],
      ),
    );
  }

  void _showContactInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_tr('Contact Us', 'اتصل بنا')),
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
            child: Text(_tr('Close', 'إغلاق')),
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
      applicationLegalese: _tr('© 2025 Zayyan. All rights reserved.',
          '© 2025 زين. جميع الحقوق محفوظة.'),
      children: [
        Text(_tr('Connecting you to UAE\'s finest traditional dress tailors.',
            'نربطك بأفضل خياطي الأزياء التقليدية في الإمارات.')),
      ],
    );
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_tr('Sign Out', 'تسجيل الخروج')),
        content: Text(_tr('Are you sure you want to sign out?',
            'هل أنت متأكد من تسجيل الخروج؟')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_tr('Cancel', 'إلغاء')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
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
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _MenuSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
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

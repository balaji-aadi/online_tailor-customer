// messages_screen.dart
import 'package:flutter/material.dart';
import 'package:khyate_tailor_app/constants/color_constant.dart';
import 'package:khyate_tailor_app/constants/storage_constants.dart';
import 'package:khyate_tailor_app/core/services/storage_services/storage_service.dart';
import 'package:khyate_tailor_app/utils/get_it.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  // Creates the State instance for MessagesScreen.
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String _selectedLanguage = 'en';
  final _storageService = locator<StorageService>();

  // Initializes state and triggers language loading.
  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  // Fetches saved language from StorageService and updates state if mounted.
  Future<void> _loadLanguage() async {
    final language = await _storageService.getString(StorageConstants.selectedLanguage);
    if (mounted) {
      setState(() {
        _selectedLanguage = language.toString();
      });
    }
  }

  // Returns Arabic or English text depending on selected language.
  String _tr(String en, String ar) => _selectedLanguage == 'ar' ? ar : en;

  // Builds the Messages screen UI with appropriate text direction.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = _selectedLanguage == 'ar';

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: ColorConstants.accentTeal,
          title: Text(_tr('Messages', 'الرسائل')),
          centerTitle: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.message_outlined, size: 64, color: ColorConstants.deepNavy),
              const SizedBox(height: 16),
              Text(
                _tr('No messages right now', 'لا توجد رسائل في الوقت الحالي'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ColorConstants.deepNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _tr(
                  'When you receive messages, they will appear here',
                  'عند تلقي الرسائل، ستظهر هنا',
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ColorConstants.deepNavy,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

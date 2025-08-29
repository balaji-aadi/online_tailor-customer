import 'package:flutter/material.dart';
import 'package:khyate_tailor_app/constants/color_constant.dart';
import 'package:khyate_tailor_app/screens/home/home_page_screen.dart';
import 'package:khyate_tailor_app/screens/message/messages_screen.dart';
import 'package:khyate_tailor_app/screens/order/orders_screen.dart';
import 'package:khyate_tailor_app/screens/profile/profile_screen.dart';
import 'package:khyate_tailor_app/services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _selectedLanguage = 'en';

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

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return Scaffold(
          body: const HomePageScreen(),
        );
      case 1:
        return const OrdersScreen();
      case 2:
        return const MessagesScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const HomePageScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = _selectedLanguage == 'ar';

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: _getCurrentScreen(),
        bottomNavigationBar: NavigationBar(
          backgroundColor: ColorConstants.accentTeal,
          selectedIndex: _selectedIndex,
          indicatorColor: ColorConstants.primaryGold.withOpacity(0.2),
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined,
                  color: ColorConstants.warmIvory),
              selectedIcon:
                  const Icon(Icons.home, color: ColorConstants.primaryGold),
              label: _tr('Home', 'الرئيسية'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.shopping_bag_outlined,
                  color: ColorConstants.warmIvory),
              selectedIcon: const Icon(Icons.shopping_bag,
                  color: ColorConstants.primaryGold),
              label: _tr('Orders', 'الطلبات'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.chat_outlined,
                  color: ColorConstants.warmIvory),
              selectedIcon:
                  const Icon(Icons.chat, color: ColorConstants.primaryGold),
              label: _tr('Messages', 'الرسائل'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline,
                  color: ColorConstants.warmIvory),
              selectedIcon:
                  const Icon(Icons.person, color: ColorConstants.primaryGold),
              label: _tr('Profile', 'الملف الشخصي'),
            ),
          ],
        ),
      ),
    );
  }
}

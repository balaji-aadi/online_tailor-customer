import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:zayyan/screens/home/home_screen.dart';
import 'package:zayyan/theme.dart';
import 'package:zayyan/services/storage_service.dart';
import 'package:zayyan/screens/auth_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const ZayyanApp());
}

class ZayyanApp extends StatefulWidget {
  const ZayyanApp({super.key});

  @override
  State<ZayyanApp> createState() => _ZayyanAppState();
}

class _ZayyanAppState extends State<ZayyanApp> {
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zayyan - زين',
      debugShowCheckedModeBanner: false,
      locale: Locale(_selectedLanguage),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
      ],
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: FutureBuilder<bool>(
        future: StorageService.isUserLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.data == true) {
            return const HomeScreen();
          }
          
          return AuthScreen(onLanguageChanged: (language) {
            setState(() => _selectedLanguage = language);
          });
        },
      ),
    );
  }
}

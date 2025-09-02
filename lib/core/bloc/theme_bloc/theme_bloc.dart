import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:khyate_tailor_app/core/services/storage_services/storage_service.dart';
import 'package:khyate_tailor_app/utils/get_it.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final _storageService = locator<StorageService>();
  static const String _themeKey = 'isDarkTheme';

  ThemeBloc() : super(ThemeState(themeMode: ThemeMode.light)) {
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetInitialThemeEvent>(_onSetInitialTheme);

    _loadTheme(); // Load the saved theme mode on init
  }

  void _onToggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) async {
    final isCurrentlyDark = state.themeMode == ThemeMode.dark;
    final newThemeMode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;

    await _storageService.setBool(_themeKey, newThemeMode == ThemeMode.dark);
    emit(ThemeState(themeMode: newThemeMode));
  }

  void _onSetInitialTheme(
      SetInitialThemeEvent event, Emitter<ThemeState> emit) {
    emit(
        ThemeState(themeMode: event.isDark ? ThemeMode.dark : ThemeMode.light));
  }

  Future<void> _loadTheme() async {
    final isDarkMode = await _storageService.getBool(_themeKey) ?? false;
    add(SetInitialThemeEvent(isDarkMode));
  }
}

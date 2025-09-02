abstract class ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

class SetInitialThemeEvent extends ThemeEvent {
  final bool isDark;
  SetInitialThemeEvent(this.isDark);
}

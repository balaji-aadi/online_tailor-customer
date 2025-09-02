part of 'language_bloc.dart';

abstract class LanguageEvent {}

class InitializeLanguage extends LanguageEvent {}

class ChangeLanguage extends LanguageEvent {
  final String languageCode;
  ChangeLanguage(this.languageCode);
}

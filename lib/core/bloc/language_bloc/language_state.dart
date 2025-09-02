part of 'language_bloc.dart';

abstract class LanguageState {}

class LanguageInitial extends LanguageState {}

class LanguageLoaded extends LanguageState {
  final String languageCode;
  LanguageLoaded(this.languageCode);
}

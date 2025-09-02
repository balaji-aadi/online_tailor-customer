import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khyate_tailor_app/constants/storage_constants.dart';
import 'package:khyate_tailor_app/core/services/storage_services/storage_service.dart';


part 'language_event.dart';
part 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final  StorageService storageService;

  LanguageBloc(this.storageService) : super(LanguageInitial()) {
    on<InitializeLanguage>(_onInitializeLanguage);
    on<ChangeLanguage>(_onChangeLanguage);
  }

  /// Load language when app starts
  Future<void> _onInitializeLanguage(
      InitializeLanguage event, Emitter<LanguageState> emit) async {
    await storageService.init(); // ensure initialized
    final language = await storageService.getString(StorageConstants.selectedLanguage) ?? 'en';
    emit(LanguageLoaded(language));
  }

  /// Change language and save
  Future<void> _onChangeLanguage(
      ChangeLanguage event, Emitter<LanguageState> emit) async {
    await storageService.setString(StorageConstants.selectedLanguage, event.languageCode);
    emit(LanguageLoaded(event.languageCode));
  }
}

import 'package:get_it/get_it.dart';
import 'package:khyate_tailor_app/core/bloc/connectivity_bloc.dart/connectivity_bloc.dart';
import 'package:khyate_tailor_app/core/network/dio_client.dart';
import 'package:khyate_tailor_app/core/services/navigator_services/navigator_service.dart';
import 'package:khyate_tailor_app/core/services/storage_services/storage_service.dart';
import 'package:khyate_tailor_app/data/repositories/auth_repository.dart';

// Global instance to access classes registered with GetIt.
final GetIt locator = GetIt.instance;

// Register services with GetIt.
void registerServicesWithGetIt() {
  // Core Services
  locator.registerLazySingleton(() => NavigatorService());
  locator.registerLazySingleton(() => ConnectivityBloc());
  locator.registerLazySingleton(() => StorageService());
  // locator.registerLazySingleton(() => CartTimerService());

  // Network
  locator.registerLazySingleton<DioClient>(() => DioClientImpl());

  // Repositories
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepository(dioClient: locator<DioClient>()),
  );
}

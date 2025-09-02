
import 'package:dio/dio.dart';
import 'package:khyate_tailor_app/constants/storage_constants.dart';
import 'package:khyate_tailor_app/core/services/storage_services/storage_service.dart';
import 'package:khyate_tailor_app/services/storage_service.dart';
import 'package:khyate_tailor_app/utils/get_it.dart';


class AuthInterceptor extends Interceptor {
  final _storageService = locator<StorageService>();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get the auth token from storage
    final token = await _storageService.getString(StorageConstants.authToken);

    // If token exists, add it to the header
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Continue with the request
    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    // Handle 401 Unauthorized errors
    if (err.response?.statusCode == 401) {
      // Clear token and trigger logout flow
      _handleUnauthorized();
    }
    
    handler.next(err);
  }

  Future<void> _handleUnauthorized() async {
    // Clear the stored token
    await _storageService.remove(StorageConstants.authToken);
    
    // Navigate to login screen
    // You might want to use a navigation service or other method to handle this
    // locator<NavigatorService>().pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
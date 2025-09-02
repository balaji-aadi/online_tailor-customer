import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log the error details
    debugPrint('❌ Dio Error!');
    debugPrint('❌ Error: ${err.error}');
    debugPrint('❌ Response: ${err.response?.data}');
    debugPrint('❌ Stack Trace: ${err.stackTrace}');
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        handler.next(_createNewDioException(
          err,
          'Connection timeout. Please check your internet connection.',
        ));
        break;

      case DioExceptionType.badResponse:
        handler.next(_handleResponseError(err));
        break;

      case DioExceptionType.cancel:
        handler.next(_createNewDioException(
          err,
          'Request was cancelled',
        ));
        break;

      case DioExceptionType.connectionError:
        handler.next(_createNewDioException(
          err,
          'Connection error. Please check your internet connection.',
        ));
        break;

      default:
        handler.next(_createNewDioException(
          err,
          'Something went wrong. Please try again.',
        ));
        break;
    }
  }

  DioException _handleResponseError(DioException err) {
    switch (err.response?.statusCode) {
      case 400:
        return _createNewDioException(
          err,
          err.response?.data['message'] ?? 'Bad request',
        );
      case 401:
        return _createNewDioException(err, 'Unauthorized access');
      case 403:
        return _createNewDioException(err, 'Access denied');
      case 404:
        return _createNewDioException(err, 'Resource not found');
      case 500:
        return _createNewDioException(err, 'Internal server error');
      default:
        return _createNewDioException(
          err,
          err.response?.data['message'] ?? 'Something went wrong',
        );
    }
  }

  DioException _createNewDioException(DioException err, String message) {
    return DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: message,
    );
  }
}

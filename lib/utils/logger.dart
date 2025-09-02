import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class Logger {
  static void d(String message) {
    if (kDebugMode) {
      developer.log('💡 $message');
    }
  }

  static void e(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log(
        '❌ $message',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static void api(String message) {
    if (kDebugMode) {
      developer.log('🌐 $message');
    }
  }

  static void json(String message) {
    if (kDebugMode) {
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      final dynamic object = jsonDecode(message);
      developer.log('📝 ${encoder.convert(object)}');
    }
  }
}
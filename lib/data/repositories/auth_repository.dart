import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:khyate_tailor_app/core/network/dio_client.dart';
import 'package:khyate_tailor_app/core/services/storage_services/storage_service.dart';
import 'package:khyate_tailor_app/data/api/api_client.dart';
import 'package:khyate_tailor_app/services/storage_service.dart';
import 'package:khyate_tailor_app/utils/get_it.dart';
import 'package:khyate_tailor_app/utils/logger.dart';


class AuthRepository {
  final DioClient dioClient;
  late final ApiClient _apiClient;
  final _storageService = locator<StorageService>();

  AuthRepository({required this.dioClient}) {
    // Initialize ApiClient with the Dio instance from DioClient
    _apiClient = ApiClient((dioClient as DioClientImpl).dioInstance);
  }




}

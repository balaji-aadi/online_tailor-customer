import 'package:dio/dio.dart';
import 'package:khyate_tailor_app/core/config/env_config.dart';
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  // Factory constructor to set the baseUrl
  factory ApiClient(Dio dio) {
    return _ApiClient(dio, baseUrl: EnvConfig.baseUrl);
  }




 
}

//add to multi

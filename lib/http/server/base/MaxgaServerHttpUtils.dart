import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:maxga/base/error/MaxgaHttpError.dart';
import 'package:maxga/constant/TestValue.dart';

import '../../../MangaRepoPool.dart';
import 'MaxgaRequestError.dart';
import 'MaxgaServerResponseStatus.dart';

typedef _ModelFactory<T> = T Function(dynamic json);


class MaxgaServerHttpUtils {


  static Future<T> requestMaxgaServer<T>(String url,data, _ModelFactory<T> factory, {String method = 'post'}) async {
    var jsonMap;
    Dio dio = MangaRepoPool.getInstance().dio;
    var retryTimes = 3;
    MaxgaServerResponseStatus status;
    while (retryTimes > 0) {
      try {
        Response<String> response = await dio.request('http://192.168.1.113:8080$url',
            data: data,
            options: Options(
              method: method,
              contentType: 'application/json',
              headers: {
                TestValue.authHeader: TestValue.token,
              },
            ));
        jsonMap = json.decode(response.data);
        status = _getStatusFromCode(jsonMap['status']);
        if (status == MaxgaServerResponseStatus.JWT_TIMEOUT) {
          
        } else if (status != MaxgaServerResponseStatus.SUCCESS) {
          throw MaxgaRequestError(status, jsonMap['message']);
        }
        break;
      } on DioError catch (e) {
        retryTimes--;
        if (e.type == DioErrorType.CONNECT_TIMEOUT) {
          throw MaxgaRequestError(MaxgaServerResponseStatus.TIMEOUT, jsonMap['message']);
        }
        if (retryTimes == 0 || e.type == DioErrorType.DEFAULT) {
          throw MaxgaRequestError(MaxgaServerResponseStatus.SERVICE_FAILED, '请求失败');
        }
      }
    }
   return factory(jsonMap['data']);
  }


  static MaxgaServerResponseStatus _getStatusFromCode(int code) {
    switch(code) {
      case 200: return MaxgaServerResponseStatus.SUCCESS;
      case 10000: return MaxgaServerResponseStatus.PARAM_ERROR;
      case 50001: return MaxgaServerResponseStatus.SHOULD_LOGIN;
      case 50002: return MaxgaServerResponseStatus.AUTH_PASSWORD_ERROR;
      case 51001: return MaxgaServerResponseStatus.USER_NOT_EXIST;
      case 51002: return MaxgaServerResponseStatus.USERNAME_EXISTED;
      case 51003: return MaxgaServerResponseStatus.JWT_TIMEOUT;
      case 70900: return MaxgaServerResponseStatus.OPERATION_NOT_PERMIT;
      case 99999:
      default:return MaxgaServerResponseStatus.SERVICE_FAILED;
    }
  }
}
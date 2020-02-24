import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:maxga/base/error/MaxgaHttpError.dart';
import 'package:maxga/constant/TestValue.dart';
import 'package:maxga/provider/public/UserProvider.dart';

import '../../../MangaRepoPool.dart';
import 'MaxgaRequestError.dart';
import 'MaxgaServerResponseStatus.dart';

typedef _ModelFactory<T> = T Function(dynamic json);


class MaxgaServerHttpUtils {

  static Future<T> get<T>(String url, {_ModelFactory<T> factory,bool needAuth = false}) {
    String token = UserProvider.getInstance()?.token;
    if (token == null) {
      throw MaxgaRequestError(
          MaxgaServerResponseStatus.SHOULD_LOGIN
      );
    }
    return requestMaxgaServer(url, null, factory, method: 'get');
  }

  static Future<T> post<T>(String url, data, { _ModelFactory<T> factory,bool needAuth = false}) {
    return requestMaxgaServer(url, data, factory, method: 'post');
  }
  static Future<T> requestMaxgaServer<T>(String url, data, _ModelFactory<T> factory, {String method = 'post'}) async {

    var jsonMap;
    Dio dio = MangaRepoPool.getInstance().dio;
    var retryTimes = 3;
    MaxgaServerResponseStatus status;
    while (retryTimes > 0) {
      try {
        Response<String> response = await dio.request('http://xiaopo.xyz:8080$url',
            data: data,
            options: Options(
              method: method,
              contentType: 'application/json',
              headers: {
                "auth-token": UserProvider.getInstance()?.token,
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
    if(factory != null) {
      return factory(jsonMap['data']);
    } else {
      return jsonMap['data'];
    }
  }


  static MaxgaServerResponseStatus _getStatusFromCode(int code) {
    switch(code) {
      case 200: return MaxgaServerResponseStatus.SUCCESS;

      case 10000: return MaxgaServerResponseStatus.PARAM_ERROR;
      case 50001: return MaxgaServerResponseStatus.SHOULD_LOGIN;
      case 50002: return MaxgaServerResponseStatus.AUTH_PASSWORD_ERROR;
      case 50003: return MaxgaServerResponseStatus.JWT_TIMEOUT;
      case 50004: return MaxgaServerResponseStatus.USER_NOT_EXIST;
      case 51002: return MaxgaServerResponseStatus.USERNAME_INVALID;
      case 51002: return MaxgaServerResponseStatus.PASSWORD_INVALID;
      case 51003: return MaxgaServerResponseStatus.EMAIL_INVALID;
      case 52003: return MaxgaServerResponseStatus.ACTIVE_TOKEN_OUT_OF_DATE;
      case 52004: return MaxgaServerResponseStatus.ANOTHER_ACTIVE_TOKEN_EXIST;
      case 52005: return MaxgaServerResponseStatus.RESET_EMAIL_LIMITED;
      case 70100: return MaxgaServerResponseStatus.UPDATE_VALUE_EXIST;
      case 70101: return MaxgaServerResponseStatus.UPDATE_VALUE_OUT_OF_DATE;
      case 70900: return MaxgaServerResponseStatus.OPERATION_NOT_PERMIT;
      case 99999:
      default:return MaxgaServerResponseStatus.SERVICE_FAILED;
    }
  }
}
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:maxga/base/error/MaxgaHttpError.dart';
import 'package:maxga/model/manga/MangaSource.dart';

import '../../MangaRepoPool.dart';

class MaxgaHttpUtils {
  final MangaSource source;

  MaxgaHttpUtils(this.source);

  Future<T> requestApi<T>(String url,
      {T Function(Response<String> response) parser}) async {
    Response<String> response;
    Dio dio = MangaRepoPool.getInstance().dio;
    var retryTimes = 3;
    while (retryTimes > 0) {
      try {
        
        response = await dio.get(url, options: Options(
            headers: Map.from(source?.headers ?? {}),
        ));
        break;
      } on DioError catch(e) {
        retryTimes--;
        if (e.type == DioErrorType.CONNECT_TIMEOUT) {
          throw MangaHttpError( MangaHttpErrorType.CONNECT_TIMEOUT, source);
        }
        if (retryTimes == 0) {
          throw MangaHttpError(MangaHttpErrorType.RESPONSE_ERROR, source);
        }
      }
    }

    try {
      return parser(response);
    } catch (e) {
      throw MangaHttpError(MangaHttpErrorType.PARSE_ERROR,source);
    }
  }
}

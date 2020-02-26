import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:maxga/base/error/MaxgaHttpError.dart';
import 'package:maxga/constant/SettingValue.dart';
import 'package:maxga/constant/TestValue.dart';
import 'package:maxga/model/manga/MangaSource.dart';
import 'package:maxga/provider/public/SettingProvider.dart';

import '../../MangaRepoPool.dart';




class MaxgaHttpUtils {
  final MangaSource source;

  MaxgaHttpUtils(this.source);

  Future<T> requestMangaSourceApi<T>(String url,
      {T Function(Response<String> response) parser}) async {
    Response<String> response;
    Dio dio = MangaRepoPool.getInstance().dio;
    var retryTimes = 3;
    final isUseProxy = SettingProvider.getInstance()
        .getBoolItemValue(MaxgaSettingItemType.useMaxgaProxy);
    final requestUrl = isUseProxy ? source.replaceUrlToProxy(url) : url;
    while (retryTimes > 0) {
      try {
        response = await dio.get(requestUrl,
            options: Options(
              headers: Map.from(source?.headers ?? {}),
            ));
        break;
      } on DioError catch (e) {
        retryTimes--;
        if (e.type == DioErrorType.CONNECT_TIMEOUT) {
          throw MangaRepoError(MangaHttpErrorType.CONNECT_TIMEOUT, source);
        }
        if (retryTimes == 0) {
          throw MangaRepoError(MangaHttpErrorType.RESPONSE_ERROR, source);
        }
      }
    }
    try {
      final T result = parser(response);
      return result;
    } catch (e) {
      throw MangaRepoError(MangaHttpErrorType.PARSE_ERROR, source);
    }
  }



}


import 'package:dio/dio.dart';
import 'package:maxga/base/error/maxga-http-error.dart';
import 'package:maxga/constant/setting-value.dart';
import 'package:maxga/manga-repo-pool.dart';
import 'package:maxga/model/manga/manga-source.dart';
import 'package:maxga/provider/public/setting-provider.dart';





class MangaHttpUtils {
  final MangaSource source;

  MangaHttpUtils(this.source);

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

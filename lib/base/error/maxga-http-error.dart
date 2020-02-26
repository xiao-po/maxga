import 'package:maxga/model/manga/manga-source.dart';

enum MangaHttpErrorType {
  NULL_PARAM,
  ERROR_PARAM,
  RESPONSE_ERROR,
  CONNECT_TIMEOUT,
  PARSE_ERROR,

}


class MangaRepoError extends Error {
  String get message {
    switch(this.type) {
      case MangaHttpErrorType.NULL_PARAM:
        return '参数不允许为空值';
      case MangaHttpErrorType.ERROR_PARAM:
        return '参数错误';
      case MangaHttpErrorType.RESPONSE_ERROR:
        return '${source.name} api 出现异常';
      case MangaHttpErrorType.CONNECT_TIMEOUT:
        return '${source.name} api 超时';
      case MangaHttpErrorType.PARSE_ERROR:
        return '序列化异常, ${source.name} 解析异常';
      default:
        return '未知错误';
    }
  }
  final MangaSource source;
  final MangaHttpErrorType type;
  MangaRepoError(this.type, this.source);
}

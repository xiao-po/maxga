import 'package:maxga/model/manga/MangaSource.dart';

class MangaHttpError extends Error {
  final String message;
  final MangaSource source;

  MangaHttpError(this.message, this.source);
}


class MangaHttpNullParamError extends MangaHttpError {
  MangaHttpNullParamError(MangaSource source): super('参数错误，不允许为空值', source);
}

class MangaHttpResponseError extends MangaHttpError {
  MangaHttpResponseError(MangaSource source): super('${source.name} api 出现异常',source);
}

class MangaHttpApiTimeoutError extends MangaHttpError {
  MangaHttpApiTimeoutError(MangaSource source): super('${source.name} api 超时', source);
}

class MangaHttpHtmlParserError extends MangaHttpConvertError {
  MangaHttpHtmlParserError(MangaSource source): super('${source.name} 解析 html 异常', source);
}

class MangaHttpJsonParserError extends MangaHttpConvertError {
  MangaHttpJsonParserError(MangaSource source): super('${source.name} 解析 JSON 异常', source);
}

class MangaHttpConvertError extends MangaHttpError {
  MangaHttpConvertError(String msg,MangaSource source): super('序列化异常, $msg', source);
}
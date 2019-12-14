import 'package:maxga/model/manga/MangaSource.dart';

class MaxgaHttpError extends Error {
  final String message;
  final MangaSource source;

  MaxgaHttpError(this.message, this.source);
}


class MaxgaHttpNullParamError extends MaxgaHttpError {
  MaxgaHttpNullParamError(MangaSource source): super('参数错误，不允许为空值', source);
}
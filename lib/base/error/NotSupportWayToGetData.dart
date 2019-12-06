

import 'package:maxga/model/manga/MangaSource.dart';

import 'MaxgaHttpError.dart';

class MaxgaNotSupportApi extends MaxgaHttpError {
  MaxgaNotSupportApi(MangaSource source) : super( '${source.name} 不允许使用这个通过这个方法获取漫画数据', source);
}

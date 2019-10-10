import 'package:maxga/http/error/MaxgaHttpError.dart';
import 'package:maxga/model/MangaSource.dart';

class MaxgaNotSupportApi extends MaxgaHttpError {
  MaxgaNotSupportApi(MangaSource source) : super( '${source.name} 不允许使用这个通过这个方法获取漫画数据', source);
}

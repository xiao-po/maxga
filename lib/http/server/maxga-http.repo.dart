import 'package:maxga/http/server/base/maxga-server-http-utils.dart';
import 'package:maxga/http/server/base/maxga-server.contants.dart';
import 'package:maxga/model/maxga/hidden-manga.dart';

class MaxgaMangaHttpRepo {
  static Future<List<HiddenManga>> getHiddenManga(int page,
      [String keywords = '']) {
    return MaxgaServerHttpUtils.get<List<HiddenManga>>(
      MaxgaServerApi.hiddenManga
          .replaceFirst('{page}', '$page')
          .replaceFirst('{keywords}', keywords),
      factory: (v) => (v as List<dynamic>)
          .map((v) => HiddenManga.fromJson(v as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

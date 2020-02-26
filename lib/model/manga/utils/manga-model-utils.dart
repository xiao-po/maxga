import 'dart:convert';

import '../manga.dart';

class MangaModelDatabaseUtils {
  static Map<String, dynamic> toSqlEntity(Manga manga) {
    return  {
      'sourceKey': manga.sourceKey,
      'authors': json.encode(manga.authors),
      'id': manga.id,
      'infoUrl': manga.infoUrl,
      'status': manga.status,
      'coverImgUrl': manga.coverImgUrl,
      'title': manga.title,
      'introduce': manga.introduce,
      'hasUpdate': manga.hasUpdate ? 1 : 0,
      'typeList': json.encode(manga.typeList),
      'chapterList': json.encode(manga.chapterList)
    };
  }

  static Manga fromSql(Map<String, dynamic> map) {
    Map<String, dynamic> value = Map.from(map);

    value['hasUpdate'] = map['hasUpdate'] == 1;
    value['authors'] = json.decode(map['authors']);
    value['typeList'] = json.decode(map['typeList']);
    value['chapterList'] = json.decode(map['chapterList']);
    return Manga.fromJson(value);
  }
}
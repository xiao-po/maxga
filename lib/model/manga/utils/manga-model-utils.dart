import 'package:maxga/model/manga/chapter.dart';

import '../manga.dart';

class MangaModelDatabaseUtils {
  static Map<String, dynamic> toSqlEntity(Manga manga) {
    return {
      'sourceKey': manga.sourceKey,
      'authors': manga.authors.join(','),
      'id': manga.id,
      'infoUrl': manga.infoUrl,
      'status': manga.status,
      'coverImgUrl': manga.coverImgUrl,
      'title': manga.title,
      'introduce': manga.introduce,
      'typeList': manga.typeList.join(','),
      'lastChapterTitle': manga.latestChapter.title,
      'lastChapterUpdateTime': manga.latestChapter?.updateTime?.toIso8601String() ?? null,
    };
  }

  static Manga fromSql(Map<String, dynamic> map) {
    Map<String, dynamic> value = Map.from(map);

    value['hasUpdate'] = map['hasUpdate'] == 1;
    value['authors'] = (map['authors'] as String).split(',');
    value['typeList'] = (map['typeList'] as String).split(',');
    value['latestChapter'] = Chapter.fromJson({
      'title': value['lastChapterTitle'],
      'updateTime': value['lastChapterUpdateTime'] != null ? DateTime.parse(value['lastChapterUpdateTime']) : null
    });
    return Manga.fromJson(value);
  }
}

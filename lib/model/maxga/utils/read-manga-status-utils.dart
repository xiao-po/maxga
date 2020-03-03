

import 'package:maxga/database/database-value.dart';

import '../read-manga-status.dart';

class ReadMangaStatusUtils {
  static Map<String, dynamic> toMangaReadStatusTableEntity(ReadMangaStatus manga) {
    return  {
      MangaReadStatusTableColumns.infoUrl: manga.infoUrl,
      MangaReadStatusTableColumns.lastReadImageIndex: manga.pageIndex,
      MangaReadStatusTableColumns.lastReadChapterId: manga.chapterId,
      MangaReadStatusTableColumns.readUpdateTime: manga?.updateTime?.toIso8601String() ?? null,
      MangaReadStatusTableColumns.sourceKey: manga.sourceKey,
    };
  }

}
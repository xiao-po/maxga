

import '../ReadMangaStatus.dart';

class ReadMangaStatusUtils {
  static ReadMangaStatus mergeMangaReadStatusmergeMangaReadStatus(ReadMangaStatus curr, ReadMangaStatus preReadMangaStatus) {
//    final status = ReadMangaStatus.fromManga(curr);
//    status.readChapterId = preReadMangaStatus.readChapterId;
//    status.readImageIndex = preReadMangaStatus.readImageIndex;
//    status.isCollected = preReadMangaStatus.isCollected;
//    status.hasUpdate = preReadMangaStatus.hasUpdate;
//    if (preReadMangaStatus.chapterList.length !=
//        status.chapterList.length) {
//      status.chapterList
//          .forEach((item) => item.isLatestUpdate = true);
//      var list = status.chapterList
//          .where((currChapter) =>
//      preReadMangaStatus.chapterList.indexWhere(
//              (preChapter) => preChapter.url == currChapter.url) !=
//          -1)
//          .toList();
//      list.forEach((item) => item.isLatestUpdate = false);
//      status.hasUpdate = true;
//    }
    return curr;
  }
  static Map<String, dynamic> toMangaReadStatusTableEntity(ReadMangaStatus manga) {
    return  {
      'infoUrl': manga.infoUrl,
      'readImageIndex': manga.readImageIndex,
      'readChapterId': manga.readChapterId,
      'isCollect': manga.isCollect ? 1 : 0,
    };
  }

  static ReadMangaStatus fromMangaReadStatusTable(Map<String, dynamic> map) {
    Map<String, dynamic> value = Map.from(map);
    value['isCollect'] = value['isCollect'] == 1;
    return ReadMangaStatus.fromJson(value);
  }
}
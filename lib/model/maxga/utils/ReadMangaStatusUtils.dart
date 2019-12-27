import '../ReadMangaStatus.dart';

class ReadMangaStatusUtils {
  static ReadMangaStatus mergeMangaReadStatus(ReadMangaStatus curr, ReadMangaStatus preReadMangaStatus) {
    final status = ReadMangaStatus.fromManga(curr);
    status.readChapterId = preReadMangaStatus.readChapterId;
    status.readImageIndex = preReadMangaStatus.readImageIndex;
    status.isCollected = preReadMangaStatus.isCollected;
    status.hasUpdate = preReadMangaStatus.hasUpdate;
    if (preReadMangaStatus.chapterList.length !=
        status.chapterList.length) {
      status.chapterList
          .forEach((item) => item.isLatestUpdate = true);
      var list = status.chapterList
          .where((currChapter) =>
      preReadMangaStatus.chapterList.indexWhere(
              (preChapter) => preChapter.url == currChapter.url) !=
          -1)
          .toList();
      list.forEach((item) => item.isLatestUpdate = false);
      status.hasUpdate = true;
    }
    return status;
  }
}
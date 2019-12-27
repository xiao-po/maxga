import '../manga/Chapter.dart';
import '../manga/Manga.dart';

class ReadMangaStatus extends Manga {
  int readChapterId;
  int readImageIndex;
  bool isCollected = false;
  bool hasUpdate = false;
  Chapter lastUpdateChapter;
  List<Chapter> chapterList;

  ReadMangaStatus.fromManga(Manga manga)
      : super.fromMangaInfoRequest(
          id: manga.id,
          sourceKey: manga.sourceKey,
          authors: manga.author,
          infoUrl: manga.infoUrl,
          status: manga.status,
          coverImgUrl: manga.coverImgUrl,
          title: manga.title,
          types: manga.typeList,
          introduce: manga.introduce,
          chapterList: manga.chapterList,
        ) {
    introduce = manga.introduce;
    chapterList = manga.chapterList.toList(growable: true)
      ..sort((a, b) => b.order - a.order)
      ..forEach((item) => item.isLatestUpdate = false);
    lastUpdateChapter = chapterList.first;
  }

  ReadMangaStatus.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    isCollected = json['collected'];
    readImageIndex = json['readImageIndex'];
    hasUpdate = json['hasUpdate'];
    readChapterId = json['readChapterId'];
    lastUpdateChapter = Chapter.fromJson(json['lastUpdateChapter']);
  }

  Map<String, dynamic> toJson() => {
        'sourceKey': sourceKey,
        'author': author,
        'id': id,
        'infoUrl': infoUrl,
        'status': status,
        'coverImgUrl': coverImgUrl,
        'title': title,
        'introduce': introduce,
        'readImageIndex': readImageIndex,
        'readChapterId': readChapterId,
        'hasUpdate': hasUpdate,
        'collected': isCollected,
        'typeList': typeList,
        'chapterList': chapterList,
        'lastUpdateChapter': lastUpdateChapter
      };
}

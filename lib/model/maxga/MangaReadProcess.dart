import '../manga/Chapter.dart';
import '../manga/Manga.dart';

class ReadMangaStatus extends SimpleMangaInfo {
  int readChapterId;
  int readImageIndex;
  bool collected = false;
  List<Chapter> chapterList;

  ReadMangaStatus.fromSimpleMangaInfo(Manga manga) {
    sourceKey = manga.sourceKey;
    author = manga.author;
    id = manga.id;
    infoUrl = manga.infoUrl;
    status = manga.status;
    coverImgUrl = manga.coverImgUrl;
    title = manga.title;
    introduce = manga.introduce;
    typeList = manga?.typeList?.cast<String>() ?? [];
    chapterList = manga.chapterList.toList(growable: false)
      ..sort((a, b) => b.order - a.order)
      ..forEach((item) => item.isCollectionLatestUpdate = false);
    lastUpdateChapter = chapterList.first;
  }

  ReadMangaStatus.fromJson(Map<String, dynamic> json) {
    sourceKey = json['sourceKey'];
    author = json['author'].cast<String>();
    id = json['id'];
    infoUrl = json['infoUrl'];
    status = json['status'];
    coverImgUrl = json['coverImgUrl'];
    title = json['title'];
    introduce = json['introduce'];
    typeList = json['typeList'].cast<String>();
    collected = json['collected'];
    readImageIndex = json['readImageIndex'];
    readChapterId = json['readChapterId'];
    List<Chapter> chapterArray = (json['chapterList'] as List<dynamic>).map((item) => Chapter.fromJson(item)).cast<Chapter>().toList(growable: false);
    chapterList = chapterArray;
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
        'collected': collected,
        'typeList': typeList,
        'chapterList': chapterList,
        'lastUpdateChapter': lastUpdateChapter
      };
}

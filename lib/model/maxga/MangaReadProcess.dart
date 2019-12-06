import '../manga/Chapter.dart';
import '../manga/Manga.dart';
import '../manga/MangaSource.dart';

class ReadMangaStatus extends SimpleMangaInfo {
  int readChapterId;
  int readImageIndex;
  bool collected = false;

  ReadMangaStatus.fromSimpleMangaInfo(SimpleMangaInfo manga) {
    sourceKey = manga.sourceKey;
    author = manga.author;
    id = manga.id;
    infoUrl = manga.infoUrl;
    status = manga.status;
    coverImgUrl = manga.coverImgUrl;
    title = manga.title;
    introduce = manga.introduce;
    typeList = manga.typeList.cast<String>();
    lastUpdateChapter = manga.lastUpdateChapter;
  }

  ReadMangaStatus.fromJson(Map<String, dynamic> json) {
    sourceKey = json['source'];
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
        'lastUpdateChapter': lastUpdateChapter
      };
}

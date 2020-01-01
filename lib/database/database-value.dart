const MaxgaDataBaseName = 'maxga';

class MaxgaDatabaseTableValue {
  static const String manga = 'manga';
  static const String mangaReadStatus = 'manga_read_status';
}

class MaxgaDatabaseMangaTableValue {
  static const String sourceKey = 'sourceKey';
  static const String authors = 'authors';
  static const String id = 'id';
  static const String infoUrl = 'infoUrl';
  static const String status = 'status';
  static const String coverImgUrl = 'coverImgUrl';
  static const String title = 'title';
  static const String introduce = 'introduce';
  static const String typeList = 'typeList';
  static const String chapterList = 'chapterList';
  static const String hasUpdate = 'hasUpdate';

  static List<String> values() {
    return [
      MaxgaDatabaseMangaTableValue.sourceKey,
      MaxgaDatabaseMangaTableValue.authors,
      MaxgaDatabaseMangaTableValue.id,
      MaxgaDatabaseMangaTableValue.infoUrl,
      MaxgaDatabaseMangaTableValue.status,
      MaxgaDatabaseMangaTableValue.coverImgUrl,
      MaxgaDatabaseMangaTableValue.title,
      MaxgaDatabaseMangaTableValue.introduce,
      MaxgaDatabaseMangaTableValue.typeList,
      MaxgaDatabaseMangaTableValue.chapterList,
      MaxgaDatabaseMangaTableValue.hasUpdate
    ];
  }

}

class MaxgaDatabaseMangaReadStatusTableValue {
  static const String infoUrl = 'infoUrl';
  static const String isCollect = 'isCollect';
  static const String lastReadDate = 'lastReadDate';
  static const String lastReadChapterId = 'lastReadChapterId';
  static const String lastReadImageIndex = 'lastReadImageIndex';


  static List<String> values() {
    return [
      MaxgaDatabaseMangaReadStatusTableValue.isCollect,
      MaxgaDatabaseMangaReadStatusTableValue.lastReadDate,
      MaxgaDatabaseMangaReadStatusTableValue.lastReadChapterId,
      MaxgaDatabaseMangaReadStatusTableValue.infoUrl,
      MaxgaDatabaseMangaReadStatusTableValue.lastReadImageIndex,
    ];
  }

}
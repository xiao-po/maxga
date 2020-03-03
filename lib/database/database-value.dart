const MaxgaDataBaseName = 'maxga';

class DatabaseTables {
  static const String manga = 'manga';
  static const String mangaReadStatus = 'manga_read_status';
  static const String collect_status = 'manga_read_status';
}

class MangaTableColumns {
  static const String sourceKey = 'sourceKey';
  static const String authors = 'authors';
  static const String id = 'id';
  static const String infoUrl = 'infoUrl';
  static const String status = 'status';
  static const String coverImgUrl = 'coverImgUrl';
  static const String title = 'title';
  static const String introduce = 'introduce';
  static const String typeList = 'typeList';
  static const String lastChapterTitle = 'lastChapterTitle';
  static const String lastChapterUpdateTime = 'lastChapterUpdateTime';

  static List<String> values() {
    return [
      MangaTableColumns.sourceKey,
      MangaTableColumns.authors,
      MangaTableColumns.id,
      MangaTableColumns.infoUrl,
      MangaTableColumns.status,
      MangaTableColumns.coverImgUrl,
      MangaTableColumns.title,
      MangaTableColumns.introduce,
      MangaTableColumns.typeList,
      MangaTableColumns.lastChapterTitle,
      MangaTableColumns.lastChapterUpdateTime
    ];
  }

}

class MangaReadStatusTableColumns {
  static const String infoUrl = 'infoUrl';
  static const String sourceKey = 'sourceKey';
  static const String lastReadChapterId = 'chapterId';
  static const String lastReadImageIndex = 'pageIndex';
  static const String readUpdateTime = 'updateTime';
  static const String collected = 'collected';
  static const String collectUpdateTime = 'collectUpdateTime';
  static const String mangaUpdateTime = 'mangaUpdateTime';


  static List<String> values() {
    return [
      MangaReadStatusTableColumns.sourceKey,
      MangaReadStatusTableColumns.lastReadChapterId,
      MangaReadStatusTableColumns.infoUrl,
      MangaReadStatusTableColumns.lastReadImageIndex,
      MangaReadStatusTableColumns.readUpdateTime,
      MangaReadStatusTableColumns.collected,
      MangaReadStatusTableColumns.collectUpdateTime,
      MangaReadStatusTableColumns.mangaUpdateTime
    ];
  }
}

class CollectStatusTableColumns {
  static const String infoUrl = 'infoUrl';
  static const String sourceKey = 'sourceKey';
  static const String collected = 'collected';
  static const String collectUpdateTime = 'updateTime';

  static List<String> values() {
    return [
      CollectStatusTableColumns.sourceKey,
      CollectStatusTableColumns.infoUrl,
      CollectStatusTableColumns.collected,
      CollectStatusTableColumns.collectUpdateTime,
    ];
  }
}

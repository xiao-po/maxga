import 'package:maxga/http/repo/dmzj/model/DmzjMangaInfo.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/manga/MangaSource.dart';

class DmzjModelConvertUtils {
  static Manga convertToMangaFromMangaInfo(DmzjMangaInfo dmzjMangaInfo, MangaSource source) {
    final Manga manga = Manga();
    manga.author =
        dmzjMangaInfo.authors.map((tag) => tag.tagName).toList(growable: false);
    manga.introduce = dmzjMangaInfo.description;
    manga.typeList = dmzjMangaInfo.types.map((type) => type.tagName).toList();
    manga.title = dmzjMangaInfo.title;
    manga.coverImgUrl = dmzjMangaInfo.cover;
    manga.id = dmzjMangaInfo.id;
    manga.status = dmzjMangaInfo.status[0].tagName;
    manga.chapterList =
        dmzjMangaInfo.chapters.singleWhere((item) => item.title == '连载').data;
    manga.chapterList.forEach((chapter) {
      chapter.url = '${source.domain}/chapter/${dmzjMangaInfo.id}/${chapter.id}.json';
    });
    manga.sourceKey = source.key;
    return manga;
  }
}
import 'package:maxga/http/repo/dmzj/constants/DmzjMangaSource.dart';
import 'package:maxga/model/manga/Chapter.dart';
import 'package:maxga/model/manga/Manga.dart';

class DmzjLatestUpdateManga {
  int id;
  String title;
  int islong;
  String authors;
  String types;
  String cover;
  String status;
  String lastUpdateChapterName;
  int lastUpdateChapterId;
  int lastUpdatetime;

  DmzjLatestUpdateManga(
      {this.id,
      this.title,
      this.islong,
      this.authors,
      this.types,
      this.cover,
      this.status,
      this.lastUpdateChapterName,
      this.lastUpdateChapterId,
      this.lastUpdatetime});

  DmzjLatestUpdateManga.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    islong = json['islong'];
    authors = json['authors'];
    types = json['types'];
    cover = json['cover'];
    status = json['status'];
    lastUpdateChapterName = json['last_update_chapter_name'];
    lastUpdateChapterId = json['last_update_chapter_id'];
    lastUpdatetime = json['last_updatetime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['islong'] = this.islong;
    data['authors'] = this.authors;
    data['types'] = this.types;
    data['cover'] = this.cover;
    data['status'] = this.status;
    data['last_update_chapter_name'] = this.lastUpdateChapterName;
    data['last_update_chapter_id'] = this.lastUpdateChapterId;
    data['last_updatetime'] = this.lastUpdatetime;
    return data;
  }

  /// 用于 动漫之家 列表拿到的接口返回的数据
  SimpleMangaInfo convertToSimpleMangaInfoForLatestUpdate() {
    final Chapter latestChapter = Chapter();
    latestChapter.id = lastUpdateChapterId;
    latestChapter.title = lastUpdateChapterName;
    latestChapter.updateTime = lastUpdatetime * 1000;
    return SimpleMangaInfo.fromMangaRepo(
        sourceKey: DmzjMangaSource.key,
        id: id,
        infoUrl: 'http://v3api.dmzj.com/comic/comic_$id.json',
        coverImgUrl: cover,
        title: title,
        typeList: types.split('/'),
        authors: authors.split('/'),
        lastUpdateChapter: latestChapter);
  }
}

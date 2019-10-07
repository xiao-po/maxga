import 'package:maxga/http/repo/dmzj/model/DmzjTag.dart';
import 'DmzjChapterData.dart';

class DmzjMangaInfo {
  int id;
  int islong;
  int direction;
  String title;
  int isDmzj;
  String cover;
  String description;
  int lastUpdatetime;
  String lastUpdateChapterName;
  int copyright;
  String firstLetter;
  String comicPy;
  int hidden;
  int hotNum;
  int hitNum;
  Null uid;
  int isLock;
  int lastUpdateChapterId;
  List<DmzjTag> status;
  List<DmzjTag> types;
  List<DmzjTag> authors;
  int subscribeNum;
  List<DmzjChapterData> chapters;
  List<Null> urlLinks;
  String isHideChapter;

  DmzjMangaInfo({this.id, this.islong, this.direction, this.title, this.isDmzj, this.cover, this.description, this.lastUpdatetime, this.lastUpdateChapterName, this.copyright, this.firstLetter, this.comicPy, this.hidden, this.hotNum, this.hitNum, this.uid, this.isLock, this.lastUpdateChapterId, this.status, this.types, this.authors, this.subscribeNum, this.chapters, this.urlLinks, this.isHideChapter});

  DmzjMangaInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    islong = json['islong'];
    direction = json['direction'];
    title = json['title'];
    isDmzj = json['is_dmzj'];
    cover = json['cover'];
    description = json['description'];
    lastUpdatetime = json['last_updatetime'];
    lastUpdateChapterName = json['last_update_chapter_name'];
    copyright = json['copyright'];
    firstLetter = json['first_letter'];
    comicPy = json['comic_py'];
    hidden = json['hidden'];
    hotNum = json['hot_num'];
    hitNum = json['hit_num'];
    uid = json['uid'];
    isLock = json['is_lock'];
    lastUpdateChapterId = json['last_update_chapter_id'];
    if (json['status'] != null) {
      status = new List<DmzjTag>();
      json['status'].forEach((v) { status.add(new DmzjTag.fromJson(v)); });
    }
    if (json['types'] != null) {
      types = new List<DmzjTag>();
      json['types'].forEach((v) { types.add(new DmzjTag.fromJson(v)); });
    }
    if (json['authors'] != null) {
      authors = new List<DmzjTag>();
      json['authors'].forEach((v) { authors.add(new DmzjTag.fromJson(v)); });
    }
    subscribeNum = json['subscribe_num'];
    if (json['chapters'] != null) {
      chapters = new List<DmzjChapterData>();
      json['chapters'].forEach((v) { chapters.add(new DmzjChapterData.fromJson(v)); });
    }
    isHideChapter = json['isHideChapter'];
  }
}





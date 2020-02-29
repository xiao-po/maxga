
import 'package:maxga/model/manga/manga.dart';

class HiddenManga extends MangaBase{
  bool lock;
  bool hidden;

  HiddenManga.fromJson(Map<String, dynamic> json) {
    sourceKey = json['sourceKey'];
    authors = (json['authors'] as String).split(",");
    id = int.parse(json['id']);
    infoUrl = json['infoUrl'];
    status = json['status'];
    coverImgUrl = json['coverImgUrl'];
    title = json['title'];
    introduce = json['introduce'];
    typeList = (json['typeList'] as String).split(",");
    lock = json['lock'];
    hidden = json['hidden'];
  }

}
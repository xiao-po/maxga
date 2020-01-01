import 'package:maxga/http/repo/dmzj/constants/DmzjMangaSource.dart';
import 'package:maxga/model/manga/Chapter.dart';
import 'package:maxga/model/manga/Manga.dart';

class DmzjMangaSearchResult {
  String sBiz;
  int addtime;
  String aliasName;
  String authors;
  int copyright;
  String cover;
  int deviceShow;
  int grade;
  int hidden;
  int hotHits;
  String lastName;
  int quality;
  int status;
  String title;
  String types;
  int id;

  DmzjMangaSearchResult({this.sBiz,
    this.addtime,
    this.aliasName,
    this.authors,
    this.copyright,
    this.cover,
    this.deviceShow,
    this.grade,
    this.hidden,
    this.hotHits,
    this.lastName,
    this.quality,
    this.status,
    this.title,
    this.types,
    this.id});

  DmzjMangaSearchResult.fromJson(Map<String, dynamic> json) {
    sBiz = json['_biz'];
    addtime = json['addtime'];
    aliasName = json['alias_name'];
    authors = json['authors'];
    copyright = json['copyright'];
    cover = json['cover'];
    deviceShow = json['device_show'];
    grade = json['grade'];
    hidden = json['hidden'];
    hotHits = json['hot_hits'];
    lastName = json['last_name'];
    quality = json['quality'];
    status = json['status'];
    title = json['title'];
    types = json['types'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_biz'] = this.sBiz;
    data['addtime'] = this.addtime;
    data['alias_name'] = this.aliasName;
    data['authors'] = this.authors;
    data['copyright'] = this.copyright;
    data['cover'] = this.cover;
    data['device_show'] = this.deviceShow;
    data['grade'] = this.grade;
    data['hidden'] = this.hidden;
    data['hot_hits'] = this.hotHits;
    data['last_name'] = this.lastName;
    data['quality'] = this.quality;
    data['status'] = this.status;
    data['title'] = this.title;
    data['types'] = this.types;
    data['id'] = this.id;
    return data;
  }

  /// 用于 动漫之家 列表拿到的接口返回的数据
  SimpleMangaInfo convertToSimpleMangaInfoForSearchResult() {
    final Chapter latestChapter = Chapter();
    latestChapter.title = lastName;
    return SimpleMangaInfo.fromMangaRepo(sourceKey: DmzjMangaSource.key,
        authors: authors.split('/'),
        id: id,
        infoUrl: '${DmzjMangaSource.domain}/comic/comic_$id.json',
        coverImgUrl: cover,
        title: lastName,
        lastUpdateChapter: latestChapter,
        typeList: types.split('/'));
  }


}
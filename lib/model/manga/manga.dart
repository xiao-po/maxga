import 'package:flutter/cupertino.dart';

import 'chapter.dart';

@immutable
class Manga extends MangaBase {
  final List<Chapter> chapterList;
  final Chapter latestChapter;

  Map<String, dynamic> toJson() => {
        'sourceKey': sourceKey,
        'authors': authors,
        'id': id,
        'infoUrl': infoUrl,
        'status': status,
        'coverImgUrl': coverImgUrl,
        'title': title,
        'introduce': introduce,
        'typeList': typeList,
        'chapterList': chapterList
      };

  Manga.fromJson(Map<String, dynamic> json)
      : chapterList = json['chapterList'],
        latestChapter = json['latestChapter'],
        super(
            sourceKey: json['sourceKey'],
            authors: json['authors'].cast<String>(),
            id: json['id'],
            infoUrl: json['infoUrl'],
            status: json['status'],
            coverImgUrl: json['coverImgUrl'],
            title: json['title'],
            introduce: json['introduce'],
            typeList: json['typeList'].cast<String>());

  Manga.fromMangaInfoRequest({
    @required List<String> authors,
    @required List<String> types,
    @required String introduce,
    @required String title,
    @required String id,
    @required String infoUrl,
    @required String status,
    @required String coverImgUrl,
    @required String sourceKey,
    @required List<Chapter> chapterList,
    @required Chapter latestChapter,
  })  : chapterList = chapterList,
        latestChapter = latestChapter,
        super(
            sourceKey: sourceKey,
            authors: authors,
            id: id,
            infoUrl: infoUrl,
            status: status,
            coverImgUrl: coverImgUrl,
            title: title,
            introduce: introduce,
            typeList: types);

  factory Manga.fromSyncItem(Map<String, dynamic> map) {
    map['authors'] = (map['authors'] as String).split(',');
    map['typeList'] = (map['typeList'] as String).split(',');
    var lastChapter = Chapter();
    lastChapter.title = map['lastChapterTitle'];
    lastChapter.updateTime =  map['lastChapterUpdateTime'] != null ? DateTime.parse( map['lastChapterUpdateTime']) : null;
    map['latestChapter'] = lastChapter;
    return Manga.fromJson(map);
  }

  @override
  Manga copyWith(
      {String sourceKey,
      List<String> authors,
      String id,
      String infoUrl,
      String status,
      String coverImgUrl,
      String title,
      String introduce,
      List<String> typeList,
      List<Chapter> chapterList}) {
    return Manga.fromJson({
      'sourceKey': sourceKey ?? this.sourceKey,
      'authors': authors ?? this.authors,
      'id': id ?? this.id,
      'infoUrl': infoUrl ?? this.infoUrl,
      'status': status ?? this.status,
      'coverImgUrl': coverImgUrl ?? this.coverImgUrl,
      'title': title ?? this.title,
      'introduce': introduce ?? this.introduce,
      'typeList': typeList ?? this.typeList,
      'chapterList': chapterList ?? this.chapterList,
      'latestChapter': latestChapter ?? this.latestChapter
    });
  }
}

abstract class MangaBase {
  final String sourceKey;
  final List<String> authors;
  final String id;
  final String infoUrl;
  final String status; // "连载中" "已完结"
  final String coverImgUrl;
  final String title;
  final String introduce;
  final List<String> typeList;

  MangaBase(
      {this.sourceKey,
      this.authors,
      this.id,
      this.infoUrl,
      this.status,
      this.coverImgUrl,
      this.title,
      this.introduce,
      this.typeList});

  MangaBase copyWith(
      {String sourceKey,
      List<String> authors,
      String id,
      String infoUrl,
      String status,
      String coverImgUrl,
      String title,
      String introduce,
      List<String> typeList});
}

import 'package:flutter/cupertino.dart';

import 'chapter.dart';


class Manga extends MangaBase {
  List<Chapter> chapterList;
  bool hasUpdate = false;

  Map<String, dynamic> toJson() => {
        'sourceKey': sourceKey,
        'authors': authors,
        'id': id,
        'infoUrl': infoUrl,
        'status': status,
        'coverImgUrl': coverImgUrl,
        'hasUpdate': hasUpdate,
        'title': title,
        'introduce': introduce,
        'typeList': typeList,
        'chapterList': chapterList
      };

  Manga.fromJson(Map<String, dynamic> json) {
    sourceKey = json['sourceKey'];
    hasUpdate = json['hasUpdate'];
    authors = json['authors'].cast<String>();
    id = json['id'];
    infoUrl = json['infoUrl'];
    status = json['status'];
    coverImgUrl = json['coverImgUrl'];
    title = json['title'];
    introduce = json['introduce'];
    typeList = json['typeList'].cast<String>();
    chapterList = (json['chapterList'] as List<dynamic>)
        .map((item) => Chapter.fromJson(item))
        .cast<Chapter>()
        .toList(growable: true);
  }

  Manga.fromMangaInfoRequest({
    @required List<String> authors,
    @required List<String> types,
    @required String introduce,
    @required String title,
    @required int id,
    @required String infoUrl,
    @required String status,
    @required String coverImgUrl,
    @required String sourceKey,
    @required List<Chapter> chapterList,
  }) {
    this.infoUrl = infoUrl;
    this.authors = authors;
    this.introduce = introduce;
    this.typeList = types;
    this.title = title;
    this.coverImgUrl = coverImgUrl;
    this.id = id;
    this.status = status;
    this.chapterList = chapterList;
    this.sourceKey = sourceKey;
  }
}

class SimpleMangaInfo extends MangaBase {
  Chapter lastUpdateChapter;

  /// 准备给 [Manga] 使用的 factory
  SimpleMangaInfo.fromMangaInfo({
    @required String sourceKey,
    @required List<String> author,
    @required int id,
    @required String infoUrl,
    @required String status, // "连载中" "已完结"
    @required String coverImgUrl,
    @required String title,
    @required List<String> typeList,
    @required Chapter lastUpdateChapter,
  }) {
    this.sourceKey = sourceKey;
    this.authors = author;
    this.id = id;
    this.infoUrl = infoUrl;
    this.status = status;
    this.coverImgUrl = coverImgUrl;
    this.title = title;
    this.typeList = typeList;
    this.lastUpdateChapter = lastUpdateChapter;
  }

  SimpleMangaInfo.fromMangaRepo({
    @required String sourceKey,
    List<String> authors,
    @required int id,
    @required String infoUrl,
    String status, // "连载中" "已完结"
    @required String coverImgUrl,
    @required String title,
    List<String> typeList,
    Chapter lastUpdateChapter,
  }) {
    this.sourceKey = sourceKey;
    this.authors = authors;
    this.id = id;
    this.infoUrl = infoUrl;
    this.status = status;
    this.coverImgUrl = coverImgUrl;
    this.title = title;
    this.typeList = typeList;
    this.lastUpdateChapter = lastUpdateChapter;
  }

  SimpleMangaInfo.fromJson(Map<String, dynamic> json) {
    sourceKey = json['sourceKey'];
    authors = json['authors'].cast<String>();
    id = json['id'];
    infoUrl = json['infoUrl'];
    status = json['status'];
    coverImgUrl = json['coverImgUrl'];
    title = json['title'];
    introduce = json['introduce'];
    typeList = json['typeList'].cast<String>();
    lastUpdateChapter = Chapter.fromJson(json['lastUpdateChapter']);
  }

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
        'lastUpdateChapter': lastUpdateChapter
      };
}

abstract class MangaBase {
  String sourceKey;
  List<String> authors;
  int id;
  String infoUrl;
  String status; // "连载中" "已完结"
  String coverImgUrl;
  String title;
  String introduce;
  List<String> typeList;
}

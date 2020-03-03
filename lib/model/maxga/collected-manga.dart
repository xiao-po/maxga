import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:maxga/model/manga/chapter.dart';
import 'package:maxga/model/manga/manga.dart';
import 'package:maxga/model/manga/simple-manga-info.dart';

@immutable
class CollectedManga extends SimpleMangaInfo {
  final DateTime mangaUpdateTime;
  final DateTime readUpdateTime;

  bool get hasUpdate => mangaUpdateTime?.isAfter(readUpdateTime ?? DateTime(2000)) ?? false;

  factory CollectedManga.fromDbJson(Map<String, dynamic> map) {
    map['mangaUpdateTime'] = map['mangaUpdateTime'] != null
        ? DateTime.parse(map['mangaUpdateTime'])
        : null;
    map['readUpdateTime'] = map['updateTime'] != null
        ? DateTime.parse(map['updateTime'])
        : null;
    var lastUpdateChapter = Chapter.fromJson({
      'title': map['lastChapterTitle'],
      'updateTime':
          DateTime.parse(map['lastChapterUpdateTime'])
    });
    map['authors'] = (map['authors'] as String).split(',');
    map['typeList'] = (map['typeList'] as String).split(',');
    map['lastUpdateChapter'] = lastUpdateChapter;
    return CollectedManga.fromJson(map);
  }

  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      'mangaUpdateTime': mangaUpdateTime,
      'readUpdateTime': readUpdateTime,
    });

  Map<String, dynamic> toDbJson() => toJson()
    ..addAll({
      'lastChapterTitle': lastUpdateChapter.title,
      'lastChapterUpdateTime': lastUpdateChapter.updateTime.toIso8601String(),
    });

  @override
  CollectedManga copyWith(
      {String sourceKey,
      List<String> authors,
      String id,
      String infoUrl,
      String status,
      String coverImgUrl,
      String title,
      String introduce,
      List<String> typeList,
      Chapter lastUpdateChapter,
      DateTime mangaUpdateTime,
      DateTime readUpdateTime}) {
    return CollectedManga.fromJson({
      'sourceKey': sourceKey ?? this.sourceKey,
      'authors': authors ?? this.authors,
      'id': id ?? this.id,
      'infoUrl': infoUrl ?? this.infoUrl,
      'status': status ?? this.status,
      'coverImgUrl': coverImgUrl ?? this.coverImgUrl,
      'title': title ?? this.title,
      'introduce': introduce ?? this.introduce,
      'typeList': typeList ?? this.typeList,
      'mangaUpdateTime': mangaUpdateTime ?? this.mangaUpdateTime,
      'readUpdateTime': readUpdateTime ?? this.readUpdateTime,
      'lastUpdateChapter': lastUpdateChapter ?? this.lastUpdateChapter,
    });
  }

  CollectedManga.fromJson(Map<String, Object> json)
      : mangaUpdateTime = json['mangaUpdateTime'],
        readUpdateTime =  json['readUpdateTime'],
        super.fromJson(json);

  CollectedManga.fromMangaInfo(
      {@required Manga manga,
      DateTime mangaUpdateTime,
      DateTime readUpdateTime})
      : mangaUpdateTime = mangaUpdateTime,
        readUpdateTime = readUpdateTime,
        super.fromJson({
          'sourceKey': manga.sourceKey,
          'authors': manga.authors,
          'id': manga.id,
          'infoUrl': manga.infoUrl,
          'status': manga.status,
          'coverImgUrl': manga.coverImgUrl,
          'title': manga.title,
          'introduce': manga.introduce,
          'typeList': manga.typeList,
          'lastUpdateChapter': manga.latestChapter,
        });
}

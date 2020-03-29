import 'package:flutter/cupertino.dart';

import 'chapter.dart';
import 'manga.dart';

@immutable
class SimpleMangaInfo extends MangaBase {
  final Chapter lastUpdateChapter;
  final bool collected;

  /// 准备给 [Manga] 使用的 factory
  SimpleMangaInfo.fromMangaInfo({
    @required String sourceKey,
    @required List<String> authors,
    @required String id,
    @required String infoUrl,
    @required String status, // "连载中" "已完结"
    @required String coverImgUrl,
    @required String title,
    @required List<String> typeList,
    @required Chapter lastUpdateChapter,
    bool collected,
  })  : this.lastUpdateChapter = lastUpdateChapter,
        this.collected = collected ?? false,
        super(
            sourceKey: sourceKey,
            authors: authors,
            id: id,
            infoUrl: infoUrl,
            status: status,
            coverImgUrl: coverImgUrl,
            title: title,
            introduce: null,
            typeList: typeList);

  factory SimpleMangaInfo.fromMangaRepo({
    @required String sourceKey,
    List<String> authors,
    @required String id,
    @required String infoUrl,
    String status, // "连载中" "已完结"
    @required String coverImgUrl,
    @required String title,
    List<String> typeList,
    Chapter lastUpdateChapter,
  }) {
    return SimpleMangaInfo.fromJson({
      'lastUpdateChapter': lastUpdateChapter,
      'sourceKey': sourceKey,
      'authors': authors ?? [],
      'id': id,
      'infoUrl': infoUrl,
      'status': status,
      'coverImgUrl': coverImgUrl,
      'title': title,
      'introduce': null,
      'typeList': typeList ?? [],
    });
  }

  SimpleMangaInfo.fromJson(Map<String, dynamic> json)
      : lastUpdateChapter = json['lastUpdateChapter'],

        collected = json['collected'] ?? false,
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

  Map<String, dynamic> toJson() => {
        'collected': collected,
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

  @override
  SimpleMangaInfo copyWith({
    String sourceKey,
    List<String> authors,
    String id,
    String infoUrl,
    String status,
    String coverImgUrl,
    String title,
    String introduce,
    List<String> typeList,
    Chapter lastUpdateChapter,
    bool collected
  }) {
    return SimpleMangaInfo.fromJson({
      'sourceKey': sourceKey ?? this.sourceKey,
      'authors': authors ?? this.authors,
      'id': authors ?? this.id,
      'infoUrl': infoUrl ?? this.infoUrl,
      'status': status ?? this.status,
      'coverImgUrl': coverImgUrl ?? this.coverImgUrl,
      'title': title ?? this.title,
      'introduce': introduce ?? this.introduce,
      'typeList': typeList ?? this.typeList,
      'lastUpdateChapter': lastUpdateChapter ?? this.lastUpdateChapter,
      'collected': collected ?? this.collected,
    });
  }
}

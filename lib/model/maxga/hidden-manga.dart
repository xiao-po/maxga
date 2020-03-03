import 'package:flutter/cupertino.dart';
import 'package:maxga/model/manga/manga.dart';

@immutable
class HiddenManga extends MangaBase {
  final bool lock;
  final bool hidden;

  HiddenManga.fromServerJson(Map<String, dynamic> json)
      : lock = json['lock'],
        hidden = json['hidden'],
        super(
            sourceKey: json['sourceKey'],
            authors: (json['authors'] as String).split(","),
            id: json['id'],
            infoUrl: json['infoUrl'],
            status: json['status'],
            coverImgUrl: json['coverImgUrl'],
            title: json['title'],
            introduce: json['introduce'],
            typeList: (json['typeList'] as String).split(","));

  HiddenManga.fromJson(Map<String, dynamic> json)
      : lock = json['lock'],
        hidden = json['hidden'],
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

  @override
  HiddenManga copyWith({
    String sourceKey,
    List<String> authors,
    String id,
    String infoUrl,
    String status,
    String coverImgUrl,
    String title,
    String introduce,
    List<String> typeList,
    bool lock,
    bool hidden,
  }) {
    return HiddenManga.fromJson({
      'sourceKey': sourceKey ?? this.sourceKey,
      'authors': authors ?? this.authors,
      'id': authors ?? this.authors,
      'infoUrl': infoUrl ?? this.infoUrl,
      'status': status ?? this.status,
      'coverImgUrl': coverImgUrl ?? this.coverImgUrl,
      'title': title ?? this.title,
      'introduce': introduce ?? this.introduce,
      'typeList': typeList ?? this.typeList,
      'lock': lock ?? this.lock,
      'hidden': hidden ?? this.hidden,
    });
  }
}

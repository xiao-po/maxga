import 'package:flutter/cupertino.dart';

@immutable
class ReadMangaStatus {
  final String infoUrl;
  final int chapterId;
  final int pageIndex;
  final DateTime updateTime;
  final DateTime mangaUpdateTime;
  final String sourceKey;

  ReadMangaStatus(
      {@required this.infoUrl,
      this.pageIndex,
      this.chapterId,
      DateTime updateTime,
      this.sourceKey,
      this.mangaUpdateTime})
      : this.updateTime = updateTime ?? DateTime.now();

  ReadMangaStatus.fromJson(Map<String, dynamic> json)
      : updateTime = json['updateTime'],
        mangaUpdateTime = json['mangaUpdateTime'],
        infoUrl = json['infoUrl'],
        sourceKey = json['sourceKey'],
        pageIndex = json['pageIndex'],
        chapterId = json['chapterId'];

  Map<String, dynamic> toJson() => {
        'infoUrl': infoUrl,
        'pageIndex': pageIndex,
        'chapterId': chapterId,
        'updateTime': updateTime.toIso8601String(),
        'sourceKey': sourceKey,
      };

  copyWith(
          {String infoUrl,
          int pageIndex,
          int chapterId,
          DateTime updateTime,
          String sourceKey,
          DateTime mangaUpdateTime}) =>
      ReadMangaStatus.fromJson({
        'infoUrl': infoUrl ?? this.infoUrl,
        'chapterId': chapterId ?? this.chapterId,
        'pageIndex': pageIndex ?? this.pageIndex,
        'updateTime': updateTime ?? this.updateTime,
        'sourceKey': sourceKey ?? this.sourceKey,
        'mangaUpdateTime': mangaUpdateTime ?? this.mangaUpdateTime
      });

  factory ReadMangaStatus.fromSql(Map<String, dynamic> json) {
    json['updateTime'] = json['updateTime'] != null ? DateTime.parse(json['updateTime']) : null;
    json['mangaUpdateTime'] = json['mangaUpdateTime'] != null ? DateTime.parse(json['mangaUpdateTime']) : null;
    return ReadMangaStatus.fromJson(json);

  }

  factory ReadMangaStatus.fromSyncItem(Map<String, dynamic> json) {
    json['updateTime'] = json['readUpdateTime'];
    json['pageIndex'] = json['lastReadImageIndex'];
    json['chapterId'] = json['lastReadChapterId'];
    return ReadMangaStatus.fromJson(json);
  }
}

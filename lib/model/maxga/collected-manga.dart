import 'package:flutter/cupertino.dart';
import 'package:maxga/base/status/update-status.dart';
import 'package:maxga/database/database-value.dart';
import 'package:maxga/model/manga/chapter.dart';
import 'package:maxga/model/manga/manga.dart';
import 'package:maxga/model/manga/simple-manga-info.dart';

@immutable
class CollectedManga extends SimpleMangaInfo {
  final CollectedUpdateStatus updateStatus;

  bool get hasUpdate => updateStatus == CollectedUpdateStatus.hasUpdate;

  factory CollectedManga.fromDbJson(Map<String, dynamic> map) {
    var lastUpdateChapter = Chapter.fromJson({
      'title': map['lastChapterTitle'],
      'updateTime': map['lastChapterUpdateTime'] != null
          ? DateTime.parse(map['lastChapterUpdateTime'])
          : null,
    });
    map['updateStatus'] = map[MangaReadStatusTableColumns.mangaHasUpdate] == 1
        ? CollectedUpdateStatus.hasUpdate
        : CollectedUpdateStatus.noUpdate;
    map['authors'] = (map['authors'] as String).split(',');
    map['typeList'] = (map['typeList'] as String).split(',');
    map['lastUpdateChapter'] = lastUpdateChapter;
    map['collected'] = true;
    return CollectedManga.fromJson(map);
  }

  Map<String, dynamic> toJson() => super.toJson();

  Map<String, dynamic> toDbJson() {
    var json = toJson()
      ..addAll({
        'lastChapterTitle': lastUpdateChapter.title,
        'lastChapterUpdateTime': lastUpdateChapter.updateTime.toIso8601String(),
      });
    json[MangaReadStatusTableColumns.mangaHasUpdate] =
        updateStatus == CollectedUpdateStatus.hasUpdate;
    return json;
  }

  @override
  CollectedManga copyWith({
    String sourceKey,
    List<String> authors,
    String id,
    String infoUrl,
    String status,
    String coverImgUrl,
    String title,
    CollectedUpdateStatus updateStatus,
    String introduce,
    List<String> typeList,
    Chapter lastUpdateChapter,
    DateTime readUpdateTime,
    bool collected,
  }) {
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
      'updateStatus': updateStatus ?? this.updateStatus,
      'lastUpdateChapter': lastUpdateChapter ?? this.lastUpdateChapter,
      'collected' : true,
    });
  }

  CollectedManga.fromJson(Map<String, Object> json)
      : updateStatus = json['updateStatus'] ?? CollectedUpdateStatus.noUpdate,
        super.fromJson(json..addAll({'collected': true}));

  factory CollectedManga.fromMangaInfo(
      {@required Manga manga, bool hasUpdate = false}) {
    return CollectedManga.fromJson({
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
      'updateStatus': hasUpdate
          ? CollectedUpdateStatus.hasUpdate
          : CollectedUpdateStatus.noUpdate,
    });
  }
}

import 'package:flutter/cupertino.dart';


class ReadMangaStatus {
  String infoUrl;
  int chapterId;
  int pageIndex;
  DateTime updateTime;
  String sourceKey;

  ReadMangaStatus({
    @required this.infoUrl,
    this.pageIndex,
    this.chapterId,
    DateTime updateTime,
    this.sourceKey
}): this.updateTime = updateTime ?? DateTime.now();

  ReadMangaStatus.fromJson(Map<String, dynamic> json) {
    if (json['updateTime'] != null) {
      updateTime = DateTime.parse(json['updateTime']);
    }
    infoUrl = json['infoUrl'];
    sourceKey = json['sourceKey'];
    pageIndex = json['pageIndex'];
    chapterId = json['chapterId'];
  }

  Map<String, dynamic> toJson() => {
        'infoUrl': infoUrl,
        'pageIndex': pageIndex,
        'chapterId': chapterId,
        'updateTime': updateTime.toIso8601String(),
        'sourceKey': sourceKey,
      };
}

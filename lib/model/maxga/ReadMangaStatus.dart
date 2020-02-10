import 'package:flutter/cupertino.dart';

import '../manga/Chapter.dart';
import '../manga/Manga.dart';

class ReadMangaStatus {
  String infoUrl;
  int chapterId;
  int pageIndex;
  DateTime updateTime;
  ReadMangaStatus({
    @required this.infoUrl,
    this.pageIndex,
    this.chapterId,
    this.updateTime,
});

  ReadMangaStatus.fromJson(Map<String, dynamic> json) {
    if (json['updateTime'] != null) {
      updateTime = DateTime.parse(json['updateTime']);
    }
    infoUrl = json['infoUrl'];
    pageIndex = json['pageIndex'];
    chapterId = json['chapterId'];
  }

  Map<String, dynamic> toJson() => {
        'infoUrl': infoUrl,
        'pageIndex': pageIndex,
        'chapterId': chapterId,
        'updateTime': updateTime,
      };
}

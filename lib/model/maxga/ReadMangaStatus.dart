import 'package:flutter/cupertino.dart';

import '../manga/Chapter.dart';
import '../manga/Manga.dart';

class ReadMangaStatus {
  String infoUrl;
  int readChapterId;
  int readImageIndex;
  bool isCollect;
  ReadMangaStatus({
    @required this.infoUrl,
    this.readImageIndex,
    this.readChapterId,
    this.isCollect = false,
});

  ReadMangaStatus.fromJson(Map<String, dynamic> json) {
    isCollect = json['isCollect'];
    infoUrl = json['infoUrl'];
    readImageIndex = json['readImageIndex'];
    readChapterId = json['readChapterId'];
  }

  Map<String, dynamic> toJson() => {
        'infoUrl': infoUrl,
        'readImageIndex': readImageIndex,
        'readChapterId': readChapterId,
        'isCollect': isCollect,
      };
}

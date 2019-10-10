import 'package:maxga/model/MangaSource.dart';

import 'Chapter.dart';

class Manga {
  String author;
  int id;
  String infoUrl;
  List<Chapter> chapterList;
  String status; // "连载中" "已完结"
  String cover;
  String title;
  String introduce;
  List<String> typeList;

  MangaSource source;

  Manga();

  Chapter getLatestChapter() {
    Chapter lastestChapter = null;
    for(var chapter in chapterList) {
      if (lastestChapter == null || lastestChapter.order < chapter.order) {
        lastestChapter = chapter;
      }
    }
    return lastestChapter;
  }


}



import 'package:maxga/model/MangaSource.dart';

import 'Chapter.dart';

class Manga extends MangaBase { 
  
  List<Chapter> chapterList;
  String status; // "连载中" "已完结"


  Manga();

  Chapter getLatestChapter() {
    Chapter latestChapter;
    for(var chapter in chapterList) {
      if (latestChapter == null || latestChapter.order < chapter.order) {
        latestChapter = chapter;
      }
    }
    return latestChapter;
  }
  Chapter getFirstChapter() {
    Chapter firstChapter;
    for(var chapter in chapterList) {
      if (firstChapter == null || firstChapter.order > chapter.order) {
        firstChapter = chapter;
      }
    }
    return firstChapter;
  }




}


class MangaBase {
  MangaSource source;
  String author;
  int id;
  String infoUrl;
  String coverImgUrl;
  String title;
  String introduce;
  List<String> typeList;
}



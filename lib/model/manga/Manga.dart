import 'package:maxga/model/manga/MangaSource.dart';

import 'Chapter.dart';

class Manga extends MangaBase {

  List<Chapter> chapterList;


  Manga();



}

class SimpleMangaInfo extends MangaBase {
  Chapter lastUpdateChapter;
  SimpleMangaInfo();

  SimpleMangaInfo.fromJson(Map<String, dynamic> json) {
    sourceKey = json['sourceKey'];
    author = json['author'].cast<String>();
    id = json['id'];
    infoUrl = json['infoUrl'];
    status = json['status'];
    coverImgUrl = json['coverImgUrl'];
    title = json['title'];
    introduce = json['introduce'];
    typeList = json['typeList'].cast<String>();
    lastUpdateChapter = Chapter.fromJson(json['lastUpdateChapter']);
  }

  Map<String, dynamic> toJson()=>
      {
        'sourceKey': sourceKey,
        'author': author,
        'id': id,
        'infoUrl': infoUrl,
        'status': status,
        'coverImgUrl': coverImgUrl,
        'title': title,
        'introduce': introduce,
        'typeList': typeList,
        'lastUpdateChapter': lastUpdateChapter
      };
}

class MangaBase {
  String sourceKey;
  List<String> author;
  int id;
  String infoUrl;
  String status; // "连载中" "已完结"
  String coverImgUrl;
  String title;
  String introduce;
  List<String> typeList;
}




import 'package:maxga/model/manga/Chapter.dart';

class DmzjChapterData {
  String title;
  List<Chapter> data;

  DmzjChapterData({this.title, this.data});

  DmzjChapterData.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    if (json['data'] != null) {
      data = new List<Chapter>();
      json['data'].forEach((v) {
        final chapter = Chapter();
        chapter.id = v['chapter_id'];
        chapter.title = v['chapter_title'];
        chapter.order = v['chapter_order'];
        chapter.updateTime = v['updatetime'] * 1000;
        data.add(chapter);
      });
    }
  }

  convertToChapter() {
  }

}

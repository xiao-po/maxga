
import 'package:maxga/model/Chapter.dart';

class DmzjChapterData {
  String title;
  List<Chapter> data;

  DmzjChapterData({this.title, this.data});

  DmzjChapterData.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    if (json['data'] != null) {
      data = new List<Chapter>();
      json['data'].forEach((v) { data.add(new Chapter.fromJson(v)); });
    }
  }

}

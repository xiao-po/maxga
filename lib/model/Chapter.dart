class Chapter {
  int id;
  int order;
  int comicId;
  String title;
  int updateTime;
  String url;
  List<String> imgUrlList;

  // 条漫还是翻页
  int direction;

  Chapter();

  Chapter.fromJson(Map<String, dynamic> json) {
    id = json['chapter_id'];
    title = json['chapter_title'];
    order = json['chapter_order'];
    updateTime = json['updatetime'] * 1000;
  }
}

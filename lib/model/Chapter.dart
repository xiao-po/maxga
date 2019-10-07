class Chapter {
  int id;
  int order;
  int comicId;
  String title;
  int fileSize;
  int updateTime;
  String url;
  List<String> imgUrlList;
  int imageCount;

  // 条漫还是翻页
  int direction;

  Chapter();

  Chapter.fromJson(Map<String, dynamic> json) {
    id = json['chapter_id'];
    title = json['chapter_title'];
    order = json['chapter_order'];
    fileSize = json['filesize'];
    updateTime = json['updatetime'] * 1000;
  }
}

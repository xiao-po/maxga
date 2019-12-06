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

  Chapter.fromDmzjJson(Map<String, dynamic> json) {
    id = json['chapter_id'];
    title = json['chapter_title'];
    order = json['chapter_order'];
    updateTime = json['updatetime'] * 1000;
  }

  Chapter.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    order = json['order'];
    updateTime = json['updateTime'];
    comicId = json['comicId'];
    url = json['url'];
    imgUrlList = json['imgUrlList'];
  }

  Map<String, dynamic> toJson()=>
      {
        'id': id,
        'title': title,
        'order': order,
        'updateTime': updateTime,
        'comicId': comicId,
        'url': url,
        'imgUrlList': imgUrlList
      };
}

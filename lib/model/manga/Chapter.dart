class Chapter {
  int id;
  int order;
  int comicId;
  String title;
  int updateTime;
  bool isCollectionLatestUpdate;
  String url;
  List<String> imgUrlList;


  // 条漫还是翻页
  int direction;

  Chapter();


  Chapter.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    order = json['order'];
    updateTime = json['updateTime'];
    isCollectionLatestUpdate = json['isCollectionLatestUpdate'];
    comicId = json['comicId'];
    url = json['url'];
    imgUrlList = json['imgUrlList']?.cast<String>() ?? [];
  }

  Map<String, dynamic> toJson()=>
      {
        'id': id,
        'title': title,
        'order': order,
        'isCollectionLatestUpdate': isCollectionLatestUpdate,
        'updateTime': updateTime,
        'comicId': comicId,
        'url': url,
        'imgUrlList': imgUrlList
      };
}

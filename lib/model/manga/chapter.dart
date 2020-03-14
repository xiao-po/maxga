class Chapter {
  int id;
  int order;
  String comicId;
  String title;
  DateTime updateTime;
  bool isLatestUpdate;
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
    isLatestUpdate = json['isLatestUpdate'];
    comicId = json['comicId'];
    url = json['url'];
    imgUrlList = json['imgUrlList']?.cast<String>() ?? [];
  }

  Map<String, dynamic> toJson()=>
      {
        'id': id,
        'title': title,
        'order': order,
        'isLatestUpdate': isLatestUpdate,
        'updateTime': updateTime,
        'comicId': comicId,
        'url': url,
        'imgUrlList': imgUrlList
      };

  copyWith({
    int id,
    int order,
    String comicId,
    String title,
    DateTime updateTime,
    bool isLatestUpdate,
    String url,
    List<String> imgUrlList,


    // 条漫还是翻页
    int direction,
}) => Chapter.fromJson({
    'id': id ?? this.id,
    'title': title ?? this.title,
    'order': order ?? this.order,
    'isLatestUpdate': isLatestUpdate ?? this.isLatestUpdate,
    'updateTime': updateTime ?? this.updateTime,
    'comicId': comicId ?? this.comicId,
    'url': url ?? this.url,
    'imgUrlList': imgUrlList ?? this.imgUrlList
  });
}

class MaxgaSyncItem {
  String sourceKey;
  String authors;
  String id;
  String infoUrl;
  String status;
  String coverImgUrl;
  String title;
  String introduce;
  String typeList;
  String lastChapterTitle;
  DateTime lastChapterUpdateTime;

  int lastReadChapterId;
  int lastReadImageIndex;
  DateTime readUpdateTime;
  bool collected;
  DateTime collectUpdateTime;
  DateTime mangaUpdateTime;

  MaxgaSyncItem.fromJson(Map<String, dynamic> json)
      : sourceKey = json['sourceKey'],
        authors = json['authors'],
        id = json['id'],
        infoUrl = json['infoUrl'],
        status = json['status'],
        coverImgUrl = json['coverImgUrl'],
        title = json['title'],
        introduce = json['introduce'],
        typeList = json['typeList'],
        lastChapterTitle = json['lastChapterTitle'],
        lastChapterUpdateTime = json['lastChapterUpdateTime'] != null ? DateTime.parse(json['lastChapterUpdateTime']):null,
        lastReadChapterId = json['lastReadChapterId'],
        lastReadImageIndex = json['lastReadImageIndex'],
        readUpdateTime = json['readUpdateTime'] != null ? DateTime.parse(json['readUpdateTime']):null,
        collected = json['collected'],
        collectUpdateTime = json['collectUpdateTime'] != null ? DateTime.parse(json['collectUpdateTime']):null,
        mangaUpdateTime = json['mangaUpdateTime'] != null ? DateTime.parse(json['mangaUpdateTime']):null;

  Map<String, dynamic> toJson() => {
        'sourceKey': sourceKey,
        'authors': authors,
        'id': id,
        'infoUrl': infoUrl,
        'status': status,
        'coverImgUrl': coverImgUrl,
        'title': title,
        'introduce': introduce,
        'typeList': typeList,
        'lastChapterTitle': lastChapterTitle,
        'lastChapterUpdateTime': lastChapterUpdateTime?.toIso8601String() ?? null,
        'lastReadChapterId': lastReadChapterId,
        'lastReadImageIndex': lastReadImageIndex,
        'readUpdateTime': readUpdateTime?.toIso8601String() ?? null,
        'collected': collected,
        'collectUpdateTime': collectUpdateTime?.toIso8601String() ?? null,
        'mangaUpdateTime': mangaUpdateTime?.toIso8601String() ?? null
      };




  factory MaxgaSyncItem.fromSql(Map<String, dynamic> json) {
    json['collected'] = json['collected'] == 1;
    json['lastReadChapterId'] = json['chapterId'];
    json['lastReadImageIndex'] = json['pageIndex'];
    return MaxgaSyncItem.fromJson(json);
   }
}

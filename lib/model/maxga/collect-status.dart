class CollectStatus {
  bool collected;
  String infoUrl;
  DateTime collectUpdateTime;
  String sourceKey;

  CollectStatus(
      {this.collected, this.infoUrl, this.collectUpdateTime, this.sourceKey});

  factory CollectStatus.fromJson(Map<String, dynamic> json) {
    return CollectStatus(
        infoUrl: json['infoUrl'],
        sourceKey: json['sourceKey'],
        collected: json['collected'],
        collectUpdateTime: json['updateTime']);
  }

  CollectStatus.fromDatabase(Map map) {
    collected = map['collected'] == 1;
    infoUrl = map['infoUrl'];
    sourceKey = map['sourceKey'];
    collectUpdateTime = map['collectUpdateTime'] != null?DateTime.parse(map['collectUpdateTime']) : null;
  }

  Map<String, dynamic> toJson() => {
        'collected': collected,
        'infoUrl': infoUrl,
        'sourceKey': sourceKey,
        'collectUpdateTime': collectUpdateTime.toIso8601String(),
      };

  Map<String, dynamic> toSqlJson() => {
        'collected': collected ? 1 : 0,
        'infoUrl': infoUrl,
        'sourceKey': sourceKey,
        'collectUpdateTime': collectUpdateTime?.toIso8601String() ?? null,
      };

  factory CollectStatus.fromSyncItem(Map<String, dynamic> json) {

    return CollectStatus.fromJson(json);
  }
}

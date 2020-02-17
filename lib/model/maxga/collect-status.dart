class CollectStatus {
  bool collected;
  String infoUrl;
  DateTime updateTime;
  String sourceKey;

  CollectStatus(
      {this.collected, this.infoUrl, this.updateTime, this.sourceKey});

  factory CollectStatus.fromJson(Map<String, dynamic> json) {
    return CollectStatus(
        infoUrl: json['infoUrl'],
        sourceKey: json['sourceKey'],
        collected: json['collected'],
        updateTime: json['updateTime'] != null
            ? DateTime.parse(json['updateTime'])
            : null);
  }

  CollectStatus.fromDatabase(Map map) {
    collected = map['collected'] == 1;
    infoUrl = map['infoUrl'];
    sourceKey = map['sourceKey'];
    updateTime = DateTime.parse(map['updateTime']);
  }

  Map<String, dynamic> toJson() => {
        'collected': collected,
        'infoUrl': infoUrl,
        'sourceKey': sourceKey,
        'updateTime': updateTime.toIso8601String(),
      };

  Map<String, dynamic> toSqlJson() => {
        'collected': collected ? 1 : 0,
        'infoUrl': infoUrl,
        'sourceKey': sourceKey,
        'updateTime': updateTime.toIso8601String(),
      };
}

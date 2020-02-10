class CollectStatus {
  bool isCollected;
  String infoUrl;
  DateTime updateTime;

  CollectStatus({
    this.isCollected,
    this.infoUrl,
    this.updateTime
});

  CollectStatus.fromDatabase(Map map) {
    isCollected = map['isCollected'] == 1;
    infoUrl = map['infoUrl'];
    updateTime = DateTime.parse(map['updateTime']);
  }

  Map<String, dynamic> toJson() => {
    'isCollected': isCollected,
    'infoUrl': infoUrl,
    'updateTime': updateTime,
  };

  Map<String, dynamic> toSqlJson() => {
    'isCollected': isCollected ? 1 : 0,
    'infoUrl': infoUrl,
    'updateTime': updateTime.toIso8601String(),
  };

}
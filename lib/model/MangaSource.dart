import 'package:flutter/cupertino.dart';

class MangaSource {
  String name;
  String domain;
  String key;
  String iconUrl;

  Map<String, String> headers;

  MangaSource(
      {@required this.name,
      @required this.key,
      @required this.iconUrl,
      this.headers,
      @required this.domain});

  MangaSource.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    domain = json['domain'];
    key = json['key'];
    headers = json['headers'] != null
        ? new Map<String, String>.from(json['headers'])
        : null;
  }

  Map<String, dynamic> toJson() =>
      {'name': name, 'key': key, 'headers': headers, 'domain': domain};
}

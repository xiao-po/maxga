class MangaSource {
  String name;
  String key;

  Map<String, String> headers;

  MangaSource({this.name, this.key, this.headers});


  MangaSource.fromJson(Map<String, dynamic> json)  {
    name = json['name'];
    key = json['key'];
    headers = new Map<String, String>.from(json['headers']);
  }

  Map<String, dynamic> toJson()=>
      {
        'name': name,
        'key': key,
        'headers': headers
      };
}

class MangaSource {
  String name;
  String key;

  MangaSource({this.name, this.key});


  MangaSource.fromJson(Map<String, dynamic> json)  {
    name = json['name'];
    key = json['key'];
  }

  Map<String, dynamic> toJson()=>
      {
        'name': name,
        'key': key
      };
}

import 'Manga.dart';

class MangaReadProcess {
  String sourceKey;
  int id;
  int chapterId;
  int imageIndex;
  bool collected;


  MangaReadProcess(this.sourceKey, this.id, this.chapterId, this.imageIndex, this.collected);

  MangaReadProcess.empty(Manga manga){
    sourceKey = manga.source.key;
    id = manga.id;
    collected = false;
  }
  MangaReadProcess.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chapterId = json['chapterId'];
    imageIndex = json['imageIndex'];
    sourceKey = json['sourceKey'];
    collected = json['collected'];
  }

  Map<String, dynamic> toJson() =>
      {
        'sourceKey': sourceKey,
        'id': id,
        'chapterId': chapterId,
        'imageIndex': imageIndex,
        'collected': collected,
      };


}
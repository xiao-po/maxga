import 'MangaSource.dart';

class MangaReadProcess {
  String sourceKey;
  int id;
  int chapterId;
  int imageIndex;


  MangaReadProcess(this.sourceKey, this.id, this.chapterId, this.imageIndex);

  MangaReadProcess.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chapterId = json['chapterId'];
    imageIndex = json['imageIndex'];
    sourceKey = json['sourceKey'];
  }

  Map<String, dynamic> toJson() =>
      {
        'sourceKey': sourceKey,
        'id': id,
        'chapterId': chapterId,
        'imageIndex': imageIndex,
      };


}
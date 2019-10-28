import 'package:maxga/model/Manga.dart';

abstract class MaxgaDataHttpRepo {
  Future<List<Manga>>  search();

  Future<Manga> getMangaInfo({int id, String url});


  Future<List<Manga>> getLatestUpdate(int page);

  Future<List<String>> getChapterImageList(String url);

}

import 'package:maxga/model/Manga.dart';

abstract class MaxgaDataHttpRepo {

  Future<Manga> getMangaInfo({int id, String url});


  Future<List<Manga>> getLatestUpdate(int page);

  Future<List<String>> getChapterImageList(String url);

  Future<List<String>> getSuggestion(String words);

  Future<List<Manga>> getSearchManga(String keywords);
}

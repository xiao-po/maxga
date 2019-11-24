import 'package:maxga/model/Manga.dart';
import 'package:maxga/model/MangaSource.dart';

abstract class MaxgaDataHttpRepo {

  Future<Manga> getMangaInfo({int id, String url});


  Future<List<SimpleMangaInfo>> getLatestUpdate(int page);

  Future<List<String>> getChapterImageList(String url);

  Future<List<String>> getSuggestion(String words);

  Future<List<SimpleMangaInfo>> getSearchManga(String keywords);

  MangaSource get mangaSource;
}

import 'package:maxga/model/manga/manga.dart';
import 'package:maxga/model/manga/simple-manga-info.dart';
import 'package:maxga/model/manga/manga-source.dart';

abstract class MaxgaDataHttpRepo {

  Future<Manga> getMangaInfo(String url);

  Future<List<SimpleMangaInfo>> getRankedManga(int page);

  Future<List<SimpleMangaInfo>> getLatestUpdate(int page);

  Future<List<String>> getChapterImageList(String url);

  Future<List<String>> getSuggestion(String words);

  Future<List<SimpleMangaInfo>> getSearchManga(String keywords);

  Future<String> generateShareLink(Manga manga);

  MangaSource get mangaSource;
}

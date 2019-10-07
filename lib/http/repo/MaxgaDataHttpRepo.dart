import 'package:maxga/model/Chapter.dart';
import 'package:maxga/model/Manga.dart';

abstract class MaxgaDataHttpRepo {
  Future<List<Manga>>  search();

  Future<Manga> getMangaInfo(int mnagaId);

  Future<List<Manga>> getLatestUpdate(int page);

  Future<Chapter> getChapterInfo(int comicId, int chapterId);

}

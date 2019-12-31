import 'package:maxga/database/database.utils.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/maxga/ReadMangaStatus.dart';
import 'package:sqflite/sqflite.dart';

class MangaReadStatusRepository {
  static Future<ReadMangaStatus> findByUrl(String url, {Database database}) {
    return MaxgaDataBaseUtils.openSearchTransaction<ReadMangaStatus>(
      action: (db) async {
        // todo: sql
        return null;
      },
      database: database,
    );
  }

  static Future<bool> insert(ReadMangaStatus manga, {Database database}) {
    return MaxgaDataBaseUtils.openUpdateTransaction(
      action: (db) async {

        // todo: sql
        return true;
      },
      database: database,
    );
  }

  static Future<bool> update(ReadMangaStatus manga, {Database database}) {
    return MaxgaDataBaseUtils.openUpdateTransaction(
      action: (db) async {
        // todo: sql
        return true;
      },
      database: database,
    );
  }

  static Future<bool> isExist(String url, {Database database}) async {
    return MaxgaDataBaseUtils.openSearchTransaction<bool>(
      action: (db) async {
        MangaBase manga = await MangaReadStatusRepository.findByUrl(url, database: db);
        return manga != null;
      },
      database: database,
    );
  }
}

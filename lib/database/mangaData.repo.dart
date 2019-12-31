import 'package:maxga/database/database.utils.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:sqflite/sqflite.dart';

class MangaDataRepository {
  static Future<MangaBase> findByUrl(String url, {Database database}) {
    return MaxgaDataBaseUtils.openSearchTransaction<MangaBase>(
      action: (db) async {
        // todo: sql
        return null;
      },
      database: database,
    );
  }

  static Future<bool> insert(MangaBase manga, {Database database}) {
    return MaxgaDataBaseUtils.openUpdateTransaction(
      action: (db) async {
        // todo: sql
        return true;
      },
      database: database,
    );
  }

  static Future<bool> update(MangaBase manga, {Database database}) {
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
        MangaBase manga = await MangaDataRepository.findByUrl(url, database: db);
        return manga != null;
      },
      database: database,
    );
  }

  static Future<bool> clearDataBase({Database database}) {
    return MaxgaDataBaseUtils.openSearchTransaction<bool>(
      action: (db) async {
        return true;
      },
      database: database,
    );
  }
}

import 'package:maxga/database/database.utils.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/manga/utils/MangaModelUtils.dart';
import 'package:sqflite/sqflite.dart';

import 'database-value.dart';

class MangaDataRepository {
  static Future<List<Manga>> findAll({Database database}) {
    return MaxgaDataBaseUtils.openSearchTransaction<List<Manga>>(
      action: (db) async {
        List<Map> maps = await db.query(MaxgaDatabaseTableValue.manga);
        return maps.map((item) => MangaModelDatabaseUtils.fromSql(item)).toList();
      },
      database: database,
    );
  }

  static Future<List<Manga>> findByUrlList(List<String> urlList, {Database database}) {
    return MaxgaDataBaseUtils.openSearchTransaction<List<Manga>>(
      action: (db) async {
        List<Map> maps = await db.query(MaxgaDatabaseTableValue.manga,
            where: '${MaxgaDatabaseMangaTableValue.infoUrl} in (${urlList.map((v) => '?').join(',')})',
            whereArgs: urlList);
        if (maps.isEmpty) {
          return null;
        }
        return maps.map((item) => MangaModelDatabaseUtils.fromSql(item)).toList();
      },
      database: database,
    );
  }

  static Future<Manga> findByUrl(String url, {Database database}) {
    return MaxgaDataBaseUtils.openSearchTransaction<Manga>(
      action: (db) async {
        List<Map> maps = await db.query(MaxgaDatabaseTableValue.manga,
            where: '${MaxgaDatabaseMangaTableValue.infoUrl} = ?',
            limit: 1,
            whereArgs: [url]);
        if (maps.isEmpty) {
          return null;
        }
        return MangaModelDatabaseUtils.fromSql(maps[0]);
      },
      database: database,
    );
  }

  static Future<List<Manga>> findByIsCollected(bool isCollected,
      {Database database}) {
    return MaxgaDataBaseUtils.openSearchTransaction<List<Manga>>(
      action: (db) async {
        List<Map> maps = await db.rawQuery(
            'select ${MaxgaDatabaseMangaTableValue.values().join(',').replaceFirst(MaxgaDatabaseMangaTableValue.infoUrl, 'a.${MaxgaDatabaseMangaTableValue.infoUrl}')} '
            'from ${MaxgaDatabaseTableValue.manga} as a left join ${MaxgaDatabaseTableValue.mangaReadStatus} as b '
            'on a.infoUrl = b.infoUrl '
            'where ${MaxgaDatabaseMangaReadStatusTableValue.isCollect} = ?',
            [isCollected ? 1 : 0]);
        return maps.map((item) => MangaModelDatabaseUtils.fromSql(item)).toList();
      },
      database: database,
    );
  }

  static Future<bool> insert(Manga manga, {Database database}) {
    return MaxgaDataBaseUtils.openUpdateTransaction(
      action: (db) async {
        final value = await db.insert(MaxgaDatabaseTableValue.manga,
            MangaModelDatabaseUtils.toSqlEntity(manga));
        return true;
      },
      database: database,
    );
  }

  static Future<bool> update(Manga manga, {Database database}) {
    return MaxgaDataBaseUtils.openUpdateTransaction(
      action: (db) async {
        final value = await db.update(MaxgaDatabaseTableValue.manga,
            MangaModelDatabaseUtils.toSqlEntity(manga),
            where: 'infoUrl = ?', whereArgs: [manga.infoUrl]);
        return true;
      },
      database: database,
    );
  }

  static Future<bool> isExist(String url, {Database database}) async {
    return MaxgaDataBaseUtils.openSearchTransaction<bool>(
      action: (db) async {
        MangaBase manga =
            await MangaDataRepository.findByUrl(url, database: db);
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

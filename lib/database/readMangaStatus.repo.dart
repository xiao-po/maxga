import 'package:maxga/database/database-value.dart';
import 'package:maxga/database/database.utils.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/maxga/ReadMangaStatus.dart';
import 'package:maxga/model/maxga/utils/ReadMangaStatusUtils.dart';
import 'package:sqflite/sqflite.dart';

class MangaReadStatusRepository {
  static Future<ReadMangaStatus> findByUrl(String url, {Database database}) {
    return MaxgaDataBaseUtils.openSearchTransaction<ReadMangaStatus>(
      action: (db) async {
        final List<Map<String, dynamic>> result = await db.query(
            MaxgaDatabaseTableValue.mangaReadStatus,
            where: '${MaxgaDatabaseMangaReadStatusTableValue.infoUrl} = ?',
            limit: 1,
            whereArgs: [url]);
        return result.length != 0 ? ReadMangaStatusUtils.fromMangaReadStatusTable(result[0]) : null;
      },
      database: database,
    );
  }

  static Future<List<ReadMangaStatus>> findByCollected(bool isCollected,
      {Database database}) {
    return MaxgaDataBaseUtils.openSearchTransaction<List<ReadMangaStatus>>(
      action: (db) async {
        final List<Map<String, dynamic>> result = await db.query(
            MaxgaDatabaseTableValue.mangaReadStatus,
            where: '${MaxgaDatabaseMangaReadStatusTableValue.isCollect} = ?',
            whereArgs: [isCollected ? 1 : 0]);

        return result.length != 0 ? result.map((item) => ReadMangaStatusUtils.fromMangaReadStatusTable(item)) : null;
      },
      database: database,
    );
  }


  static Future<bool> insert(ReadMangaStatus manga, {Database database}) {
    return MaxgaDataBaseUtils.openUpdateTransaction(
      action: (db) async {
        final value = await db.insert(MaxgaDatabaseTableValue.mangaReadStatus,
            ReadMangaStatusUtils.toMangaReadStatusTableEntity(manga));
        return true;
      },
      database: database,
    );
  }

  static Future<bool> update(ReadMangaStatus status, {Database database}) {
    return MaxgaDataBaseUtils.openUpdateTransaction(
      action: (db) async {
        await db.update(MaxgaDatabaseTableValue.mangaReadStatus, ReadMangaStatusUtils.toMangaReadStatusTableEntity(status),where: '${MaxgaDatabaseMangaReadStatusTableValue.infoUrl} = ?',whereArgs: [status.infoUrl] );
        return true;
      },
      database: database,
    );
  }

  static Future<bool> isExist(String url, {Database database}) async {
    return MaxgaDataBaseUtils.openSearchTransaction<bool>(
      action: (db) async {
        var status = await MangaReadStatusRepository.findByUrl(
            url, database: db);
        return status != null;
      },
      database: database,
    );
  }

  static Future<List<ReadMangaStatus>> findAll({Database database}) async {
    return MaxgaDataBaseUtils.openSearchTransaction<List<ReadMangaStatus>>(
      action: (db) async {
        final List<Map<String, dynamic>> result = await db.query(
            MaxgaDatabaseTableValue.mangaReadStatus);
        return result.length != 0 ? result.map((item) => ReadMangaStatusUtils.fromMangaReadStatusTable(item)).toList() : null;
      },
      database: database,
    );
  }
}

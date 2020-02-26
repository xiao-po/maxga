import 'package:maxga/database/manga-data.repo.dart';
import 'package:sqflite/sqflite.dart';

import 'database-value.dart';

class MaxgaDatabaseInitializr {
  static Future<void> initDataBase() async {
    final databasePath = await getDatabasesPath();
    Database database;
    try {
      database = await openDatabase(
        '$databasePath/$MaxgaDataBaseName.db',
        version: 1,
        onCreate: (db, version) => MaxgaDatabaseInitializr._onCreate(db, version),
        onUpgrade: (db, oldVersion, newVersion) =>
            MaxgaDatabaseInitializr._onUpdate(db, oldVersion),
      );
      final test = await MangaDataRepository.findAll(database: database);
      print(test.length);
      print('database init success');
    } catch (e) {
      print(e);
    } finally {
      database.close();
    }
  }

  static _onUpdate(Database database, int oldVersion) async {
    switch (oldVersion) {
      case 1: {
        await database.execute('ALTER TABLE "${DatabaseTables.mangaReadStatus}" RENAME TO "_${DatabaseTables.mangaReadStatus}_old_v1";');
        await database.execute('create table manga_read_status ('
            'infoUrl text,'
            'sourceKey text,'
            'updateTime TEXT,'
            'pageIndex integer,'
            'chapterId integer'
            ');');

        await database.execute('INSERT INTO "manga_read_status" SELECT "infoUrl", "lastReadDate", "readImageIndex","readChapterId"  FROM "_${DatabaseTables.mangaReadStatus}_old_v1";');
        await database.execute("create table collect_status ("
            "infoUrl text,"
            'sourceKey text,'
            "updateTime text,"
            "isCollected integer"
            ")");
        await database.execute('insert into collect_status select "infoUrl", "lastReadDate", "lastReadDate" from "_${DatabaseTables.mangaReadStatus}_old_v1"');
      }
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    switch (version) {
      case 1:
        await _MaxgaDataBaseFirstVersionHelper.initTable(db);
        break;
    }
  }
}
class _MaxgaDataBaseFirstVersionHelper {
  static initTable(Database db) async {
    await db.execute('create table manga ('
        'sourceKey text,'
        'authors text,'
        'id integer,'
        'infoUrl text,'
        'status text,'
        'coverImgUrl text,'
        'title text,'
        'introduce text,'
        'typeList text,'
        'hasUpdate integer,'
        'chapterList text'
        ');');

    await db.execute('create table ${DatabaseTables.mangaReadStatus} ('
        'infoUrl text,'
        'updateTime TEXT,'
        'sourceKey text,'
        'pageIndex integer,'
        'chapterId integer'
        ');');

    await db.execute("create table ${DatabaseTables.collect_status} ("
        "${CollectStatusTableColumns.infoUrl} text,"
        "${CollectStatusTableColumns.updateTime} text,"
        "${CollectStatusTableColumns.collected} integer,"
        "${CollectStatusTableColumns.sourceKey} text"
        ")");
  }
}

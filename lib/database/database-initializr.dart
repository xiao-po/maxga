import 'package:sqflite/sqflite.dart';

class MaxgaDatabaseInitializr {
  static initDataBase() async {
    final databasePath = await getDatabasesPath();
    Database database;
    try {
      database = await openDatabase(
        '$databasePath/maxga.db',
        version: 1,
        onCreate: (db, version) => MaxgaDatabaseInitializr._onCreate(db, version),
        onUpgrade: (db, oldVersion, newVersion) =>
            MaxgaDatabaseInitializr._onUpdate(db, oldVersion),
      );
    } catch (e) {} finally {
      database.close();
    }
  }

  static _onUpdate(Database database, int oldVersion) {
    switch (oldVersion) {
    }
  }

  static _onCreate(Database db, int version) {
    if (!db.isOpen) {
      return null;
    }
    switch (version) {
      case 1:
        break;
    }
  }
}
class _MaxgaDataBaseFirstVersionHelper {
  static initTable(Database db) async {
    await db.execute('create table manga ('
        'sourceKey text,'
        'author text,'
        'id integer,'
        'infoUrl text,'
        'status text,'
        'coverImageUrl text,'
        'title text,'
        'intorduce text,'
        'typeList text,'
        'chapterList text,'
        ')');

    await db.execute('create table manga_read_status ('
        'infoUrl text,'
        'isCollect INTEGER'
        'lastReadDate TEXT'
        'lastReadChapterId integer,'
        'lastReadImageIndex integer,'
        'hasUpdate integer,'
        ')');
  }
}

import 'package:sqflite/sqflite.dart';

class MaxgaDataBaseUtils {
  static initDataBase() async {
    final databasePath = await getDatabasesPath();
    Database database;
    try {
      database = await openDatabase(
        '$databasePath/maxga.db',
        version: 1,
        onCreate: (db, version) => {},
        onUpgrade: (db, oldVersion, newVersion) => MaxgaDataBaseUtils.onUpdate(db, oldVersion),
      );
    }catch(e) {
      
    } finally {
      database.close();
      
    }
  }

  static onUpdate(Database database, int oldVersion) {
    switch(oldVersion) {

    }
  }

  static onCreate(Database db,int  version) {
    if (!db.isOpen) {
      return null;
    }
    switch(version) {
      case 1:

        break;
    }
  }
}

class _MaxgaDataBaseFirstVersionHelper {
  static initTable(Database db) async {

    await db.execute('create table manga_status ('
        'sourceKey text,'
        'author text,'
        'id integer,'
        'infoUrl text,'
        'status text,'
        'coverImageUrl text,'
        'title text,'
        'intorduce text,'
        'typeList text,'
        'lastReadDate TEXT'
        'lastReadChapterId integer,'
        'lastReadImageIndex integer,'
        'hasUpdate integer,'
        'chapterList text,'
        ')');

    await db.execute('create table collect_manga ('
        'isCollect INTEGER'
        'infoUrl'
        ')');

  }
}
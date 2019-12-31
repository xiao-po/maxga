import 'package:maxga/base/error/MaxgaSqlError.dart';
import 'package:sqflite/sqflite.dart';

typedef DatabaseGetterAction<T> = Future<T> Function(Database database);
typedef DatabaseSetterAction = Future<bool> Function(Database database);



class MaxgaDataBaseUtils {
  static Future<T> openSearchTransaction<T>({
    DatabaseGetterAction<T> action,
    Database database,
  }) async {
    bool isEarlyOpen = database == null;
    final db = isEarlyOpen ? await _openDatabase() : database;
    try {
      return await action(db);
    } catch (e) {
      throw MaxgaSqlError();
    } finally {
      if (!isEarlyOpen) {
        database.close();
      }
    }
  }

  static Future<bool> openUpdateTransaction({
    DatabaseSetterAction action,
    Database database,
  }) async {
    bool isEarlyOpen = database == null;
    final db = isEarlyOpen ? await _openDatabase() : database;
    try {
      await action(database);
      return true;
    } catch (e) {
      throw MaxgaSqlError();
    } finally {
      if (!isEarlyOpen) {
        database.close();
      }
    }
  }



  static Future<Database> _openDatabase() async {
    final databasePath = await getDatabasesPath();
    return await openDatabase('$databasePath/maxga.db');
  }
}


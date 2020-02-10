import 'package:maxga/model/maxga/collect-status.dart';
import 'package:sqflite/sqflite.dart';

import 'database-value.dart';
import 'database.utils.dart';

class CollectStatusRepo {
  static Future<List<CollectStatus>> findAllCollect({Database database}) {
    return MaxgaDataBaseUtils.openSearchTransaction<List<CollectStatus>>(
        action: (database) async {
          List<Map> maps = await database.query(
            DatabaseTables.collect_status,
            where: "${CollectStatusTableColumns.isCollected} = ?",
            whereArgs: [1],
          );
          if (maps.isEmpty) {
            return null;
          }
          return maps.map((map) => CollectStatus.fromDatabase(map)).toList();
        },
        database: database);
  }

  static Future<CollectStatus> findByInfoUrl(String infoUrl,
      {Database database}) {
    return MaxgaDataBaseUtils.openSearchTransaction<CollectStatus>(
        action: (database) async {
          List<Map> maps = await database.query(
            DatabaseTables.collect_status,
            where: "${CollectStatusTableColumns.infoUrl} = ? ",
            whereArgs: [infoUrl],
          );
          if (maps.isEmpty) {
            return null;
          }
          return CollectStatus.fromDatabase(maps[0]);
        },
        database: database);
  }

  static Future<bool> insert(CollectStatus collectStatus, {Database database}) {
    return MaxgaDataBaseUtils.openUpdateTransaction(
      action: (database) async {
        await database.insert(
            DatabaseTables.collect_status, collectStatus.toSqlJson());
        return true;
      },
      database: database,
    );
  }

  static Future<bool> update(CollectStatus collectStatus, {Database database}) {
    return MaxgaDataBaseUtils.openUpdateTransaction(
      action: (database) async {
        await database.update(
            DatabaseTables.collect_status,
            collectStatus.toSqlJson(),
            where: '${CollectStatusTableColumns.infoUrl} = ?',
            whereArgs: [collectStatus.infoUrl]
        );
        return true;
      },
      database: database,
    );
  }
}

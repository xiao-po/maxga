import 'package:maxga/database/database.utils.dart';
import 'package:maxga/model/maxga/collected-manga.dart';
import 'package:maxga/model/maxga/maxga-sync-item.dart';
import 'package:sqflite/sqflite.dart';

import 'database-value.dart';

class CollectMangaDataRepository {
  static Future<List<CollectedManga>> findByPage({int page, Database database}) {
    return MaxgaDataBaseUtils.openSearchTransaction<List<CollectedManga>>(
      action: (db) async {
        List<Map> maps = await db.rawQuery(
            'select * from ${DatabaseTables.manga}  as a left join ${DatabaseTables.collect_status} as b '
                'on a.infoUrl = b.infoUrl '
                'where ${CollectStatusTableColumns.collected} = 1 limit 20 offset ${page * 20}');
        return maps.map((item) => CollectedManga.fromDbJson(Map.from(item))).toList();
      },
      database: database,
    );
  }

  static Future<List<CollectedManga>> findAll({Database database}) {
    return MaxgaDataBaseUtils.openSearchTransaction<List<CollectedManga>>(
      action: (db) async {
        List<Map> maps = await db.rawQuery(
            'select * from ${DatabaseTables.manga}  as a left join ${DatabaseTables.collect_status} as b '
            'on a.infoUrl = b.infoUrl '
            'where ${CollectStatusTableColumns.collected} = 1');
        return maps.map((item) => CollectedManga.fromDbJson(Map.from(item))).toList();
      },
      database: database,
    );
  }

  static Future<List<MaxgaSyncItem>> findAllSyncItem({Database database}) {
    return MaxgaDataBaseUtils.openSearchTransaction<List<MaxgaSyncItem>>(
      action: (db) async {
        List<Map> maps = await db.rawQuery(
            'select * from ${DatabaseTables.manga}  as a left join ${DatabaseTables.collect_status} as b '
                'on a.infoUrl = b.infoUrl ');
        return maps.map((item) => MaxgaSyncItem.fromSql(Map.from(item))).toList();
      },
      database: database,
    );
  }
}

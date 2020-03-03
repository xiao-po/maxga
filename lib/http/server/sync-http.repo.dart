import 'package:maxga/http/server/base/maxga-server.contants.dart';
import 'package:maxga/model/maxga/collect-status.dart';
import 'package:maxga/model/maxga/maxga-sync-item.dart';
import 'package:maxga/model/maxga/read-manga-status.dart';

import 'base/maxga-server-http-utils.dart';

class SyncHttpRepo {

  static Future<List<MaxgaSyncItem>> sync(
      List<MaxgaSyncItem> queryList) {
    return MaxgaServerHttpUtils.post<List<MaxgaSyncItem>>(
        MaxgaServerApi.sync, queryList,
        factory: (list) => (list as List<dynamic>)
            .map((item) => MaxgaSyncItem.fromJson(item))
            .toList());
  }

}

import 'package:maxga/http/server/base/maxga-server.contants.dart';
import 'package:maxga/http/utils/maxga-http-utils.dart';
import 'package:maxga/model/maxga/read-manga-status.dart';
import 'package:maxga/model/maxga/collect-status.dart';

import 'base/maxga-server-http-utils.dart';

class SyncHttpRepo {
  static Future<List<CollectStatus>> syncCollectApi(
      List<CollectStatus> queryList) {
    return MaxgaServerHttpUtils.requestMaxgaServer<List<CollectStatus>>(
        MaxgaServerApi.syncCollectStatus,
        queryList,
        (list) => (list as List<dynamic>).map((item) => CollectStatus.fromJson(item)).toList());
  }

  static syncStatusApi(List<ReadMangaStatus> queryList) {

    return MaxgaServerHttpUtils.requestMaxgaServer<List<ReadMangaStatus>>(
        MaxgaServerApi.syncReadStatus,
        queryList,
            (list) => (list as List<dynamic>).map((item) => ReadMangaStatus.fromJson(item)).toList());
  }
}

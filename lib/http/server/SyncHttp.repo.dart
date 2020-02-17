import 'package:maxga/http/server/base/MaxgaServer.contants.dart';
import 'package:maxga/http/utils/MaxgaHttpUtils.dart';
import 'package:maxga/model/maxga/ReadMangaStatus.dart';
import 'package:maxga/model/maxga/collect-status.dart';

import 'base/MaxgaServerHttpUtils.dart';

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

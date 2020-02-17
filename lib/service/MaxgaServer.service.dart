import 'package:maxga/MangaRepoPool.dart';
import 'package:maxga/database/collect-status.repo.dart';
import 'package:maxga/database/readMangaStatus.repo.dart';
import 'package:maxga/http/server/SyncHttp.repo.dart';
import 'package:maxga/model/maxga/ReadMangaStatus.dart';
import 'package:maxga/model/maxga/collect-status.dart';
import 'package:maxga/provider/public/CollectionProvider.dart';
import 'package:maxga/service/MangaReadStorage.service.dart';

class MaxgaServerService {
  static Future<bool> sync() async {
    var collectStatusList = await CollectStatusRepo.findAll();
    var shouldUpdateCollectStatusList = await
        SyncHttpRepo.syncCollectApi(collectStatusList);
    for (CollectStatus value in shouldUpdateCollectStatusList) {
      final sourceRepo = MangaRepoPool.getInstance().getRepo(key: value.sourceKey);
      final manga = await sourceRepo.getMangaInfo(value.infoUrl);
      await MangaStorageService.saveManga(manga);
      CollectionProvider.getInstance()
          .setMangaCollectStatus(manga, isCollected: value.collected);
    }


    return true;
  }

  static Future<bool> syncReadStatus() async {
    var readStatusList = await MangaReadStatusRepository.findAll();
    var shouldUpdateReadStatusList = await
    SyncHttpRepo.syncStatusApi(readStatusList);
    for (ReadMangaStatus item in shouldUpdateReadStatusList) {

      await MangaStorageService.saveMangaStatus(item);
    }
    return true;
  }


}

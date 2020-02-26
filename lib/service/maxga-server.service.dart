import 'package:maxga/manga-repo-pool.dart';
import 'package:maxga/database/collect-status.repo.dart';
import 'package:maxga/database/read-manga-status.repo.dart';
import 'package:maxga/http/server/sync-http.repo.dart';
import 'package:maxga/model/maxga/read-manga-status.dart';
import 'package:maxga/model/maxga/collect-status.dart';
import 'package:maxga/provider/public/collection-provider.dart';
import 'package:maxga/service/manga-read-storage.service.dart';

class MaxgaServerService {
  static Future<bool> sync() async {
    var collectStatusList = (await CollectStatusRepo.findAll()) ?? [];
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
    var readStatusList = (await MangaReadStatusRepository.findAll()) ?? [];
    var shouldUpdateReadStatusList = await
    SyncHttpRepo.syncStatusApi(readStatusList);
    for (ReadMangaStatus item in shouldUpdateReadStatusList) {

      await MangaStorageService.saveMangaStatus(item);
    }
    return true;
  }


}

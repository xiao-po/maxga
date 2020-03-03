import 'package:maxga/database/collect-manga-data.repo.dart';
import 'package:maxga/database/collect-status.repo.dart';
import 'package:maxga/database/manga-data.repo.dart';
import 'package:maxga/database/read-manga-status.repo.dart';
import 'package:maxga/http/server/sync-http.repo.dart';
import 'package:maxga/model/manga/manga.dart';
import 'package:maxga/model/maxga/collect-status.dart';
import 'package:maxga/model/maxga/read-manga-status.dart';
import 'package:maxga/provider/public/collection-provider.dart';

class MaxgaServerService {
  static Future<bool> sync() async {
    var data = await CollectMangaDataRepository.findAllSyncItem();
    print(data.length);
    var shouldUpdateSyncItem = await SyncHttpRepo.sync(data);
    print(shouldUpdateSyncItem.length);
    for (var item in shouldUpdateSyncItem) {
      print(item.infoUrl);
      var manga = await MangaDataRepository.findByUrl(item.infoUrl);
      if (manga == null) {
        await MangaDataRepository.insert(Manga.fromSyncItem(item.toJson()));
      } else {
        if (item.lastChapterUpdateTime
            .isAfter(manga.latestChapter.updateTime)) {
          await MangaDataRepository.update(Manga.fromSyncItem(item.toJson()));
        }
      }
      var readStatus = await MangaReadStatusRepository.findByUrl(item.infoUrl);
      if (readStatus == null) {
        await MangaReadStatusRepository.insert(
            ReadMangaStatus.fromSyncItem(item.toJson()));
      } else {
        if (item.readUpdateTime != null &&
            item.readUpdateTime.isAfter(readStatus.updateTime)) {
          await MangaDataRepository.update(Manga.fromSyncItem(item.toJson()));
        }
      }
      var collectStatus = await CollectStatusRepo.findByInfoUrl(item.infoUrl);
      if (item.collectUpdateTime != null &&
          (collectStatus.collectUpdateTime == null ||
              item.collectUpdateTime
                  .isAfter(collectStatus.collectUpdateTime))) {
        await CollectStatusRepo.update(CollectStatus.fromSyncItem(item.toJson()));
      }
      await CollectionProvider.getInstance().init();
    }

//    var collectStatusList = (await CollectStatusRepo.findAll()) ?? [];
//    var shouldUpdateCollectStatusList = await
//        SyncHttpRepo.syncCollectApi(collectStatusList);
//    for (CollectStatus value in shouldUpdateCollectStatusList) {
//      final sourceRepo = MangaRepoPool.getInstance().getRepo(key: value.sourceKey);
//      final manga = await sourceRepo.getMangaInfo(value.infoUrl);
//      await MangaStorageService.saveManga(manga);
//      CollectionProvider.getInstance()
//          .setMangaCollectStatus(manga, isCollected: value.collected);
//    }

    return true;
  }
}

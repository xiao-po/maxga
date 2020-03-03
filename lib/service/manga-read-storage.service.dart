import 'package:maxga/base/error/maxga-sql-error.dart';
import 'package:maxga/database/collect-manga-data.repo.dart';
import 'package:maxga/database/collect-status.repo.dart';
import 'package:maxga/database/manga-data.repo.dart';
import 'package:maxga/database/read-manga-status.repo.dart';
import 'package:maxga/model/manga/manga.dart';
import 'package:maxga/model/maxga/collected-manga.dart';
import 'package:maxga/model/maxga/read-manga-status.dart';
import 'package:maxga/model/maxga/collect-status.dart';

class MangaStorageService {
  static final String _key = 'manga_process_';

  static Future<bool> saveManga(Manga manga) async {
    final isMangaExist = await MangaDataRepository.isExist(manga.infoUrl);
    bool isSaveToMangaTableSuccess = false;
    if (isMangaExist) {
      isSaveToMangaTableSuccess = await MangaDataRepository.update(manga);
    } else {
      isSaveToMangaTableSuccess = await MangaDataRepository.insert(manga);
    }
    return isSaveToMangaTableSuccess;
  }

  static Future<bool> updateManga(Manga manga) async {
    final isMangaExist = await MangaDataRepository.isExist(manga.infoUrl);
    bool isSaveToMangaTableSuccess = false;
    if (isMangaExist) {
      isSaveToMangaTableSuccess = await MangaDataRepository.update(manga);
      isSaveToMangaTableSuccess = await updateMangaUpdateTime(manga);
    } else {
      throw MaxgaSqlError();
    }
    return isSaveToMangaTableSuccess;
  }

  static Future<Manga> getMangaByUrl(String url) {
    return MangaDataRepository.findByUrl(url);
  }

  static Future<List<CollectedManga>> getCollectedManga() {
    return CollectMangaDataRepository.findAll();
  }

  static Future<ReadMangaStatus> getMangaStatusByUrl(String url) async {
    return (await MangaReadStatusRepository.findByUrl(url)) ??
        ReadMangaStatus(infoUrl: url);
  }

  static Future<bool> saveMangaStatus(ReadMangaStatus status) async {
    final isMangaReadStatusExist =
        await MangaReadStatusRepository.isExist(status.infoUrl);
    bool isSaveToMangaReadStatusTableSuccess = false;
    if (isMangaReadStatusExist) {
      isSaveToMangaReadStatusTableSuccess =
          await MangaReadStatusRepository.update(status);
    } else {
      isSaveToMangaReadStatusTableSuccess =
          await MangaReadStatusRepository.insert(status);
    }

    return isSaveToMangaReadStatusTableSuccess;
  }

  static Future<List<Manga>> getMangaByUrlList(List<String> urlList) {
    if (urlList == null || urlList.isEmpty) {
      return Future.value([]);
    }
    return MangaDataRepository.findByUrlList(urlList);
  }

  static Future<bool> setMangaCollectedStatus(Manga manga,
      {bool isCollected = true}) async {
    CollectStatus collectStatus =
        await CollectStatusRepo.findByInfoUrl(manga.infoUrl);
    final isExist = collectStatus != null;
    if (isExist) {
      collectStatus.sourceKey = manga.sourceKey;
      collectStatus.collectUpdateTime = DateTime.now();
      collectStatus.collected = isCollected;
      return CollectStatusRepo.update(collectStatus);
    } else {
      return CollectStatusRepo.insert(CollectStatus(
          infoUrl: manga.infoUrl,
          collected: isCollected,
          sourceKey: manga.sourceKey,
          collectUpdateTime: DateTime.now()));
    }
  }

//  static Future<ReadMangaStatus> getMangaStatus(Manga manga) async {
//    final allReadManga = (await _getAllReadManga()).toList();
//    final index = allReadManga.indexWhere((el) => el.infoUrl == manga.infoUrl);
//    if (index == -1) {
//      return null;
//    }
//    final mangaReadProcess = allReadManga[index]..chapterList.forEach((item) => item.isLatestUpdate = false);
//    return mangaReadProcess;
//  }
//
//  static Future<List<Manga>> getAllCollectedManga() async {
//    final allReadManga = (await _getAllReadManga()).toList();
//    allReadManga.removeWhere((el) => el.isCollected == false);
//    return allReadManga.toList();
//  }
//
//  static Future<bool> setMangaStatus(Manga process) async {
//    final allReadManga = await _getAllReadManga();
//    allReadManga..removeWhere((el) => el.infoUrl == process.infoUrl)..add(process);
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    await prefs.setStringList(_key, allReadManga?.map((el) => json.encode(el))?.toList(growable: false) ?? []);
//    return true;
//  }
//
//  static Future<List<ReadMangaStatus>> _getAllReadManga() async {
//    if (MangaStorageService._readMangaStatusList == null) {
//      SharedPreferences prefs = await SharedPreferences.getInstance();
//      MangaStorageService._readMangaStatusList = prefs
//          .getStringList(_key)
//          ?.map((el) => ReadMangaStatus.fromJson(json.decode(el)))
//          ?.toList() ??
//          [];
//    }
//    return MangaStorageService._readMangaStatusList;

//  }

  static Future<void> clearDatabase() async {
    await CollectStatusRepo.deleteAll();
    await MangaDataRepository.deleteAll();
    await MangaReadStatusRepository.deleteAll();
  }

  static updateMangaUpdateTime(MangaBase mangaBase) async {
    await MangaReadStatusRepository.updateMangaUpdateTimeByInfoUrl(mangaBase.infoUrl, DateTime.now());
  }

  static updateReadTime(MangaBase mangaBase) async {
    await MangaReadStatusRepository.updateReadUpdateTimeByInfoUrl(mangaBase.infoUrl, DateTime.now());
  }
}

import 'package:flutter/cupertino.dart';
import 'package:maxga/MangaRepoPool.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/model/manga/Chapter.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/maxga/ReadMangaStatus.dart';
import 'package:maxga/model/maxga/utils/ReadMangaStatusUtils.dart';
import 'package:maxga/provider/base/BaseProvider.dart';
import 'package:maxga/service/MangaReadStorage.service.dart';

enum CollectionLoadingState { loading, over, error, empty }

class CollectionProvider extends BaseProvider {
  List<ReadMangaStatus> _collectedMangaList;

  List<ReadMangaStatus> get collectionMangaList => _collectedMangaList;

  bool get loadOver => this._collectedMangaList != null;

  bool get isEmpty => this._collectedMangaList?.length == 0 ?? true;
  bool _isOnUpdate = false;

  final String _key = 'mangaCollectionList_';

  static CollectionProvider _instance;

  static CollectionProvider getInstance() {
    if (_instance == null) {
      _instance = CollectionProvider();
    }
    return _instance;
  }

  CollectionProvider() {
    this.initAction();
  }

  initAction() async {
    try {
      final collectedMangaList =
          await MangaReadStorageService.getAllCollectedManga();
      this._collectedMangaList = collectedMangaList;
    } catch (e) {
      this._collectedMangaList = [];
      debugPrint('加载 collection list 失败');
    } finally {
      notifyListeners();
    }
  }

  Future<CollectionMangaUpdateResult> checkAndUpdateCollectManga() async {
    final CollectionMangaUpdateResult result = CollectionMangaUpdateResult();
    var index = 0;
    if (this._isOnUpdate) {
      return null;
    }
    this._isOnUpdate = true;

    await Future.wait(
        this._collectedMangaList.toList(growable: false).map((manga) async {
      var sourceKey = manga.sourceKey;
      var infoUrl = manga.infoUrl;
      var i = index++;
      ReadMangaStatus currentMangaInfo =
          await _getCurrentMangaStatus(sourceKey, infoUrl);
      final resultStatus =
          ReadMangaStatusUtils.mergeMangaReadStatus(currentMangaInfo, manga);
      if (currentMangaInfo.chapterList.length != manga.chapterList.length) {
        await this.updateCollectionAction(resultStatus);
      }
      this._collectedMangaList[i] = resultStatus;
      notifyListeners();
      return resultStatus;
    }));

    this._isOnUpdate = false;
    return result;
  }

  Future<ReadMangaStatus> _getCurrentMangaStatus(
      String sourceKey, String infoUrl) async {
    final MaxgaDataHttpRepo httpRepo =
        MangaRepoPool.getInstance().getRepo(key: sourceKey);
    Manga manga = await httpRepo.getMangaInfo(infoUrl);
    /// 测试代码
//    Chapter test = Chapter();
//    test.title = 'test';
//    test.url = 'test';
//    test.order = -1;
//    manga.chapterList = [
//      test,
//      ...manga.chapterList,
//    ];

    final currentMangaInfo =
        ReadMangaStatus.fromManga(manga);

    return currentMangaInfo;
  }

  Future<bool> addCollectionAction(ReadMangaStatus manga) async {
    try {
      final status = ReadMangaStatus.fromManga(manga);
      status.isCollected = true;
      await MangaReadStorageService.setMangaStatus(status);

      if (status.isCollected) {
        // update
        this._collectedMangaList.add(status);
      }
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateCollectionAction(ReadMangaStatus manga) async {
    try {
      await MangaReadStorageService.setMangaStatus(manga);

      final index = this._collectedMangaList.indexWhere((item) => item.infoUrl == manga.infoUrl);
      this._collectedMangaList[index] = manga;
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }


  Future<bool> deleteCollectionAction(ReadMangaStatus manga) async {
    try {
      final status = ReadMangaStatus.fromManga(manga);
      status.isCollected = false;
      await MangaReadStorageService.setMangaStatus(status);
      this
          ._collectedMangaList
          .removeWhere((item) => status.infoUrl == item.infoUrl);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  ReadMangaStatus getMangaFromInfoUrl(String infoUrl) {
    return this
        ._collectedMangaList
        .firstWhere((item) => item.infoUrl == infoUrl);
  }
}

class CollectionMangaUpdateResult {
  int updateCount = 0;
  int failCount = 0;
  int timeoutCount = 0;
}

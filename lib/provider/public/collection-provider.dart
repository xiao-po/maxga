import 'package:flutter/cupertino.dart';
import 'package:maxga/manga-repo-pool.dart';
import 'package:maxga/http/repo/maxga-data-http-repo.dart';
import 'package:maxga/model/manga/manga.dart';
import 'package:maxga/provider/base/base-provider.dart';
import 'package:maxga/service/manga-read-storage.service.dart';

enum CollectionLoadingState { loading, over, error, empty }

class CollectionProvider extends BaseProvider {
  List<Manga> _collectedMangaList;

  List<Manga> get collectionMangaList => _collectedMangaList;

  bool get loadOver => this._collectedMangaList != null;

  bool get isEmpty => this._collectedMangaList?.length == 0 ?? true;
  bool _isOnUpdate = false;


  static CollectionProvider _instance;

  static CollectionProvider getInstance() {
    if (_instance == null) {
      _instance = CollectionProvider();
    }
    return _instance;
  }

  CollectionProvider();

  Future<void> init() async {
    try {
      final collectedMangaList = await MangaStorageService.getCollectedManga();
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
      Manga currentMangaInfo = await _getCurrentMangaStatus(sourceKey, infoUrl);
      if (currentMangaInfo.chapterList.length != manga.chapterList.length) {
        currentMangaInfo.hasUpdate = true;
        await MangaStorageService.saveManga(currentMangaInfo);
        this._collectedMangaList[i] = currentMangaInfo;
        notifyListeners();
      }
      return currentMangaInfo;
    }));

    this._isOnUpdate = false;
    return result;
  }

  Future<Manga> _getCurrentMangaStatus(String sourceKey, String infoUrl) async {
    final MaxgaDataHttpRepo httpRepo =
        MangaRepoPool.getInstance().getRepo(key: sourceKey);
    Manga manga = await httpRepo.getMangaInfo(infoUrl);

    /// 测试代码 --------------------------------
//    Chapter test = Chapter();
//    test.title = 'test';
//    test.url = 'test';
//    test.order = -1;
//    manga.chapterList = [
//      test,
//      ...manga.chapterList,
//    ];
    /// 测试代码 --------------------------------

    return manga;
  }

  Future<bool> setMangaNoUpdate(Manga manga) async {
    manga.hasUpdate = false;
    await MangaStorageService.saveManga(manga);
    return true;
  }

  Future<bool> setMangaCollectStatus(Manga manga, {isCollected = true}) async {
    try {
      if (isCollected) {
        final index = this.collectionMangaList.indexWhere((item) => manga.infoUrl == item.infoUrl);
        if (index ==  -1) {
          this._collectedMangaList.add(manga);
        }
      } else {
        this._collectedMangaList.removeWhere((item) => item.infoUrl == manga.infoUrl);
      }
      await MangaStorageService.setMangaCollectedStatus(manga, isCollected: isCollected);
      notifyListeners();
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

  Manga getMangaFromInfoUrl(String infoUrl) {
    return this
        ._collectedMangaList
        .firstWhere((item) => item.infoUrl == infoUrl);
  }

  clearData() {
    this._collectedMangaList = [];
    notifyListeners();
  }
}

class CollectionMangaUpdateResult {
  int updateCount = 0;
  int failCount = 0;
  int timeoutCount = 0;
}
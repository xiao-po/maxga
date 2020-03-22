import 'package:flutter/cupertino.dart';
import 'package:maxga/base/delay.dart';
import 'package:maxga/base/error/maxga-http-error.dart';
import 'package:maxga/base/status/update-status.dart';
import 'package:maxga/constant/setting-value.dart';
import 'package:maxga/http/repo/maxga-data-http-repo.dart';
import 'package:maxga/manga-repo-pool.dart';
import 'package:maxga/model/manga/manga.dart';
import 'package:maxga/model/maxga/collected-manga.dart';
import 'package:maxga/provider/base/base-provider.dart';
import 'package:maxga/provider/public/setting-provider.dart';
import 'package:maxga/service/manga-read-storage.service.dart';
import 'package:maxga/service/setting.service.dart';

class UpdateCollectionMangaResult {
  int get failedCount =>
      timeoutMangaList.length +
      parserErrorMangaList.length +
      unknownErrorMangaList.length;

  int get updatedCount => updatedMangaList.length;

  int get notUpdateCount => notUpdateMangaList.length;

  final List<CollectedManga> timeoutMangaList = [];
  final List<CollectedManga> parserErrorMangaList = [];
  final List<CollectedManga> unknownErrorMangaList = [];
  final List<CollectedManga> updatedMangaList = [];
  final List<CollectedManga> notUpdateMangaList = [];

  UpdateCollectionMangaResult();

  addToResult(CollectedManga manga) {
    switch (manga.updateStatus) {
      case CollectedUpdateStatus.hasUpdate:
        return updatedMangaList.add(manga);
      case CollectedUpdateStatus.timeout:
        return timeoutMangaList.add(manga);
      case CollectedUpdateStatus.parserError:
        return parserErrorMangaList.add(manga);
      case CollectedUpdateStatus.unknownError:
        return unknownErrorMangaList.add(manga);
      case CollectedUpdateStatus.noUpdate:
        return notUpdateMangaList.add(manga);
    }
  }

  List<CollectedManga> getAllManga() {
    return []
      ..addAll(updatedMangaList)
      ..addAll(timeoutMangaList)
      ..addAll(parserErrorMangaList)
      ..addAll(unknownErrorMangaList)
      ..addAll(notUpdateMangaList);
  }
}

class CollectionProvider extends BaseProvider {
  List<CollectedManga> _collectedMangaList;

  List<CollectedManga> get collectionMangaList => _collectedMangaList;

  bool get loadOver => this._collectedMangaList != null;

  bool get isEmpty => this._collectedMangaList?.length == 0 ?? true;
  CollectionUpdateStatus updateStatus = CollectionUpdateStatus.none;

  UpdateCollectionMangaResult updateResult;

  static CollectionProvider _instance;

  bool get hasCollectedManga => _collectedMangaList.length > 0;

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
      collectedMangaList.sort((a, b) => b.lastUpdateChapter.updateTime
          .compareTo(a.lastUpdateChapter.updateTime));
      this._collectedMangaList = collectedMangaList;
      updateResult = null;
      updateStatus = CollectionUpdateStatus.none;
    } catch (e) {
      this._collectedMangaList = [];
      debugPrint('加载 collection list 失败');
    } finally {
      notifyListeners();
    }
  }

  Future<void> checkAndUpdateCollectManga() async {
    if (updateStatus == CollectionUpdateStatus.processing) {
      return null;
    }
    this.updateStatus = CollectionUpdateStatus.processing;
    notifyListeners();
    var updateResult = UpdateCollectionMangaResult();
    var iterator = _collectedMangaList.iterator;
    final counts = int.parse(
        SettingProvider.getInstance().getItem(MaxgaSettingItemType.updateChannelCount).value
    );
    print('unpdate channel counts is $counts');
    await Future.wait(List.generate(
        counts,
        (i) => _updateChannel(iterator, afterUpdate: (result) {
              updateResult.addToResult(result);
            })));

    this._collectedMangaList = updateResult.getAllManga()
      ..sort((a, b) => b.lastUpdateChapter.updateTime
          .compareTo(a.lastUpdateChapter.updateTime));
    this.updateResult = updateResult;
    if (updateResult.failedCount > 0) {
      this.updateStatus = CollectionUpdateStatus.warning;
    } else {
      this.updateStatus = CollectionUpdateStatus.success;
    }
    await LongAnimationDelay();
    notifyListeners();
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

  Future<bool> setMangaNoUpdate(CollectedManga manga) async {
    await MangaStorageService.updateReadTime(manga);
    var index = this._collectedMangaList.indexOf(manga);
    this._collectedMangaList[index] = manga.copyWith(
        readUpdateTime: DateTime.now(),
        updateStatus: CollectedUpdateStatus.noUpdate);
    notifyListeners();
    return true;
  }

  Future<bool> setMangaCollectStatus(Manga manga, {isCollected = true}) async {
    try {
      if (isCollected) {
        final index = this
            .collectionMangaList
            .indexWhere((item) => manga.infoUrl == item.infoUrl);
        if (index == -1) {
          this._collectedMangaList.add(CollectedManga.fromMangaInfo( manga: manga));
        }
      } else {
        this._collectedMangaList
            .removeWhere((item) => item.infoUrl == manga.infoUrl);
      }
      await MangaStorageService.setMangaCollectedStatus(manga,
          isCollected: isCollected);
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

  CollectedManga getMangaFromInfoUrl(String infoUrl) {
    return this
        ._collectedMangaList
        .firstWhere((item) => item.infoUrl == infoUrl);
  }

  clearData() {
    this._collectedMangaList = [];
    notifyListeners();
  }

  _updateChannel(Iterator<CollectedManga> iterator,
      {@required ValueChanged<CollectedManga> afterUpdate}) async {
    var isLast = !(iterator.moveNext());
    if (isLast) return null;
    var manga = iterator.current;
    var sourceKey = manga.sourceKey;
    var infoUrl = manga.infoUrl;

    try {
      Manga currentMangaInfo = await _getCurrentMangaStatus(sourceKey, infoUrl);
      if (currentMangaInfo.latestChapter.updateTime
          .isAfter(manga.lastUpdateChapter.updateTime)) {
        await MangaStorageService.updateManga(currentMangaInfo);
        afterUpdate(CollectedManga.fromMangaInfo(
          manga: currentMangaInfo,
        ).copyWith(updateStatus: CollectedUpdateStatus.hasUpdate));
      } else {
        afterUpdate(CollectedManga.fromMangaInfo(
          manga: currentMangaInfo,
          hasUpdate: manga.hasUpdate,
        ));
      }
    } on MangaRepoError catch (e) {
      switch (e.type) {
        case MangaHttpErrorType.NULL_PARAM:
        case MangaHttpErrorType.ERROR_PARAM:
        case MangaHttpErrorType.RESPONSE_ERROR:
          afterUpdate(
              manga.copyWith(updateStatus: CollectedUpdateStatus.unknownError));
          break;
        case MangaHttpErrorType.CONNECT_TIMEOUT:
          afterUpdate(
              manga.copyWith(updateStatus: CollectedUpdateStatus.timeout));
          break;
        case MangaHttpErrorType.PARSE_ERROR:
          afterUpdate(
              manga.copyWith(updateStatus: CollectedUpdateStatus.parserError));
          break;
      }
    } catch (e) {
      afterUpdate(
          manga.copyWith(updateStatus: CollectedUpdateStatus.unknownError));
    }

    await _updateChannel(iterator, afterUpdate: afterUpdate);
  }
}

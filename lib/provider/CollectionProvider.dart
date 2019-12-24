import 'package:flutter/cupertino.dart';
import 'package:maxga/model/maxga/ReadMangaStatus.dart';
import 'package:maxga/provider/base/BaseProvider.dart';
import 'package:maxga/service/MangaReadStorage.service.dart';

enum CollectionLoadingState { loading, over, error, empty }

class CollectionProvider extends BaseProvider {
  List<ReadMangaStatus> _collectedMangaList;

  List<ReadMangaStatus> get collectionMangaList => _collectedMangaList;

  bool get loadOver => this._collectedMangaList != null;

  bool get isEmpty => this._collectedMangaList?.length == 0 ?? true;
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

  Future<bool> addAndUpdateAction(ReadMangaStatus manga) async {
    try {

      final status = ReadMangaStatus.fromManga(manga);
      status.isCollected = true;
      final isSuccess = await this._updateDb(status);
      if (!isSuccess) {
        return false;
      }

      if (manga.isCollected) {
        // update
        this._collectedMangaList.add(status);
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> deleteAction(ReadMangaStatus manga) async {
    try {

      final status = ReadMangaStatus.fromManga(manga);
      status.isCollected = false;
      final isSuccess = await this._updateDb(status);
      if (!isSuccess) {
        return false;
      }
      this
          ._collectedMangaList
          .removeWhere((item) => status.infoUrl == item.infoUrl);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> _updateDb(ReadMangaStatus manga) {
    return MangaReadStorageService.setMangaStatus(manga);
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

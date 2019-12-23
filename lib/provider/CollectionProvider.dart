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

  Future<bool> updateAction() async {
    return Future.value(true);
  }

  Future<bool> addAction(ReadMangaStatus manga) async {
    try {
      final status = ReadMangaStatus.fromManga(manga);
      await this._addToDb(status);
      this._collectedMangaList.add(status);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> deleteAction(ReadMangaStatus manga) async {
    try {
      await this._addToDb(manga);
      this
          ._collectedMangaList
          .removeWhere((item) => manga.infoUrl == item.infoUrl);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> _addToDb(ReadMangaStatus manga) {
    // TODO: storage add
    return Future.value(true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  getMangaFromInfoUrl(String infoUrl) {
    return this
        ._collectedMangaList
        .firstWhere((item) => item.infoUrl == infoUrl);
  }
}

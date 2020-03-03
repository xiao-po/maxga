import 'dart:async';

import 'package:maxga/model/manga/manga.dart';
import 'package:maxga/model/manga/simple-manga-info.dart';
import 'package:maxga/provider/base/base-provider.dart';
import 'package:maxga/service/local-storage.service.dart';
import 'package:maxga/service/manga-read-storage.service.dart';

class HistoryProvider extends BaseProvider {
  List<SimpleMangaInfo> _items;

  List<SimpleMangaInfo> get historyMangaList => _items;
  final String _key = 'mangaHistroy_';

  static HistoryProvider _instance;

  static HistoryProvider getInstance() {
    if (_instance == null) {
      _instance = HistoryProvider();
    }
    return _instance;
  }

  HistoryProvider();

  Future<bool> init() async {
    final List<Manga> valueList = await LocalStorage.getStringList(_key)
        .then((list) => MangaStorageService.getMangaByUrlList(list));
    final List<SimpleMangaInfo> value = valueList != null ? valueList
        .map((manga) => SimpleMangaInfo.fromMangaInfo(
            sourceKey: manga.sourceKey,
            authors: manga.authors,
            id: manga.id,
            infoUrl: manga.infoUrl,
            status: manga.status,
            coverImgUrl: manga.coverImgUrl,
            title: manga.title,
            typeList: manga.typeList,
            lastUpdateChapter: manga.latestChapter))
        .toList() : [];

    _items = value ?? [];

    notifyListeners();
    return true;
  }

  Future<bool> addToHistory(SimpleMangaInfo manga) async {
    var list = _items
      ..removeWhere((el) => el.id == manga.id)
      ..insert(0, manga);
    if (list.length > 30) {
      list = list.sublist(0, 29);
    }
    final isSuccess = await LocalStorage.setStringList(
        _key, list.map((item) => item.infoUrl).toList());

    notifyListeners();
    return isSuccess;
  }

  Future<void> clearHistory() async {
    await LocalStorage.clearItem(_key);
    _items = [];

    notifyListeners();
  }
}

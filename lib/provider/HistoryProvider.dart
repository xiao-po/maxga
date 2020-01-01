import 'dart:async';

import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/provider/base/BaseProvider.dart';
import 'package:maxga/service/LocalStorage.service.dart';
import 'package:maxga/service/MangaReadStorage.service.dart';

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
            author: manga.authors,
            id: manga.id,
            infoUrl: manga.infoUrl,
            status: manga.status,
            coverImgUrl: manga.status,
            title: manga.title,
            typeList: manga.typeList,
            lastUpdateChapter: manga.chapterList.first))
        .toList() : [];

    _items = value ?? [];

    notifyListeners();
    return true;
  }

  Future<bool> addToHistory(SimpleMangaInfo manga) async {
    final list = _items
      ..removeWhere((el) => el.id == manga.id)
      ..insert(0, manga);
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

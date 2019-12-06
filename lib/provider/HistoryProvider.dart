import 'dart:async';
import 'dart:convert';

import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/provider/base/BaseProvider.dart';
import 'package:maxga/service/LocalStorage.service.dart';

class HistoryProvider extends BaseProvider {
  List<SimpleMangaInfo> _items;
  List<SimpleMangaInfo> get historyMangaList => _items;
  final String _key = 'mangaHistroy_';



  HistoryProvider() {
    this.init();
  }

  Future<bool> init() async {
    await LocalStorage.clearItem(_key);
    final List<SimpleMangaInfo>  value = (await LocalStorage.getStringList(_key))?.map((el) => SimpleMangaInfo.fromJson(json.decode(el)))?.toList() ?? [];

    _items = value ?? [];

    notifyListeners();
    return true;
  }

  Future<bool> addToHistory(SimpleMangaInfo manga) async {
    final list = _items
      ..removeWhere((el) => el.id == manga.id)
      ..insert(0, manga);
    await LocalStorage.setStringList(_key, list.map((item) => json.encode(item)).toList(growable: false));


    notifyListeners();
    return true;
  }


  void clearHistory() async {
    await LocalStorage.clearItem(_key);
    _items = [];

    notifyListeners();
  }

}

import 'dart:async';
import 'dart:convert';

import 'package:maxga/model/Manga.dart';
import 'package:maxga/service/LocalStorage.service.dart';

// TODO： Provider 改造
class HistoryProvider {
  List<SimpleMangaInfo> _items;
  StreamController<List<SimpleMangaInfo>> _streamController = StreamController();

  static final _instance = HistoryProvider();

  final String _key = 'mangaHistroy_';

  static HistoryProvider getInstance() => _instance;

  get stream => _streamController.stream;

  HistoryProvider() {
    this.init();
  }

  Future<bool> init() async {
    final List<SimpleMangaInfo>  value = (await LocalStorage.getStringList(_key))?.map((el) => SimpleMangaInfo.fromJson(json.decode(el)))?.toList() ?? [];

    _items = value;
    this._streamController.add(value);
    return true;
  }

  Future<bool> addToHistory(SimpleMangaInfo manga) async {
    final list = _items
      ..removeWhere((el) => el.id == manga.id)
      ..insert(0, manga);
    this._streamController.add(_items);
    await LocalStorage.setStringList(_key, list.map((item) => json.encode(item)).toList(growable: false));
    return true;
  }


  dispose() {
    _streamController.close();
  }

  void clearHistory() async {
    await LocalStorage.clearItem(_key);
    _items = [];
    this._streamController.add(_items);
  }

}

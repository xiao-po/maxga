import 'dart:async';
import 'dart:convert';

import 'package:maxga/model/Manga.dart';
import 'package:maxga/service/LocalStorage.service.dart';

class HistoryProvider {
  List<SimpleMangaInfo> _items;
  StreamController<List<SimpleMangaInfo>> _streamController = StreamController();

  static final _instance = HistoryProvider();

  final String _key = 'histroy_';

  static HistoryProvider getInstance() => _instance;

  get stream => _streamController.stream;

  HistoryProvider() {
    this.init();
  }

  Future<bool> init() async {
    final List<SimpleMangaInfo>  value = (await LocalStorage.getStringList(_key)).map((el) => SimpleMangaInfo.fromJson(json.decode(el))).toList();

    _items = value;
    this._streamController.add(value);
    return true;
  }

  Future<bool> addToHistory(SimpleMangaInfo manga) {
    final list = <SimpleMangaInfo>[manga]
      ..addAll(_items)
      ..removeWhere((el) => el.id == manga.id);

  }


  dispose() {
    _streamController.close();
  }

}

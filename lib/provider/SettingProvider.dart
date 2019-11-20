import 'dart:async';

import 'package:maxga/base/setting/Setting.model.dart';
import 'package:maxga/base/setting/SettingValue.dart';
import 'package:maxga/service/Setting.service.dart';

class SettingProvider {
  List<MaxgaSettingItem> _items;
  StreamController<List<MaxgaSettingItem>> _streamController = StreamController();

  static final _instance = SettingProvider();

  static SettingProvider getInstance() => _instance;

  get stream => _streamController.stream;

  SettingProvider() {
    this.init();
  }

  MaxgaSettingItem getItem(MaxgaSettingItemType type) {
    return this._items.firstWhere((el) => el.name == type);

  }

  Future<bool> init() async {
    final value = await SettingService.getInitValue();
    _items = value;
    this._streamController.add(value);
    return true;
  }

  Future<bool> modifySetting(MaxgaSettingItem item, value) async {
    final isSuccess = await SettingService.saveItem(SettingTypeNameList[item.name], value);
    item.value = value;
    this._streamController.add(_items.toList(growable: false));
    return isSuccess;
  }

  dispose() {
    _streamController.close();
  }
}

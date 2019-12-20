import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:maxga/base/setting/Setting.model.dart';
import 'package:maxga/base/setting/SettingValue.dart';
import 'package:maxga/provider/base/BaseProvider.dart';
import 'package:maxga/service/Setting.service.dart';



class SettingProvider extends BaseProvider {
  List<MaxgaSettingItem> _items;

  List<MaxgaSettingItem> get itemList => _items;

  static SettingProvider _instance;

  static SettingProvider getInstance() {
    if (_instance == null) {
      _instance = SettingProvider();
    }
    return _instance;
  }

  SettingProvider() {
    this.init();
  }

  MaxgaSettingItem getItem(MaxgaSettingItemType type) {
    return this._items.firstWhere((el) => el.key == type);
  }

  String getItemValue(MaxgaSettingItemType type) {
    return this.getItem(type).value;
  }

  bool getBoolItemValue(MaxgaSettingItemType type) {
    final value = this._items.firstWhere((el) => el.key == type).value;
    return value == '1';
  }

  Future<bool> init() async {
    final value = await SettingService.getInitValue();
    List<MaxgaSettingItem> itemList = <MaxgaSettingItem>[];
    SettingCategoryList.keys.forEach((type) {
      var titleItem = _createTitleItem(type);
      itemList
        ..add(titleItem)
        ..addAll(value.where((item) => item.category == type));
    });
    _items = itemList;
    notifyListeners();
    return true;
  }

  MaxgaSettingItem _createTitleItem(MaxgaSettingCategoryType type) {
    return MaxgaSettingItem(
        subTitle: SettingCategoryList[type],
        type: MaxgaSettingListTileType.title,
        category: type);
  }

  Future<bool> modifySetting(MaxgaSettingItem item, value) async {
    final isSuccess =
        await SettingService.saveItem(SettingTypeNameList[item.key], value);
    item.value = value;
    notifyListeners();
    return isSuccess;
  }

  Future<bool> dispatchCommand(MaxgaSettingItem setting) async {
    switch(setting.key) {
      case MaxgaSettingItemType.cleanCache:
        var cacheManager = DefaultCacheManager();
        await cacheManager.emptyCache();
        return true;
      case MaxgaSettingItemType.readOnlyOnWiFi:
      case MaxgaSettingItemType.useMaxgaProxy:
      case MaxgaSettingItemType.timeoutLimit:
      default:
        return false;
    }
  }
}

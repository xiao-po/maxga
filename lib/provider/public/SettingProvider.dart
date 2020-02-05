import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:maxga/MangaRepoPool.dart';
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

  SettingProvider();

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
    print('setting init over');
    return true;
  }

  MaxgaSettingItem _createTitleItem(MaxgaSettingCategoryType type) {
    return MaxgaSettingItem.title(
        subTitle: SettingCategoryList[type],
        category: type);
  }

  Future<bool> modifySetting(MaxgaSettingItem item,String v) async {
    final isSuccess =
        await SettingService.saveItem(item.key.toString(), v);
    final index = _items.indexOf(item);
    _items[index] = item.copyWith(value: v);
    notifyListeners();
    return isSuccess;
  }

  Future<bool> onChange(MaxgaSettingItem setting) async {
    switch(setting.key) {
      case MaxgaSettingItemType.cleanCache:
        var cacheManager = DefaultCacheManager();
        await cacheManager.emptyCache();
        return Future.value(true);
      case MaxgaSettingItemType.timeoutLimit:
        MangaRepoPool.getInstance().changeTimeoutLimit(int.parse(setting.value));
        break;
      case MaxgaSettingItemType.resetSetting:
        final isSuccess = await SettingService.resetAllValue();
        if (isSuccess) {
          return this.init();
        }
        return Future.value(true);
      case MaxgaSettingItemType.readOnlyOnWiFi:
      case MaxgaSettingItemType.useMaxgaProxy:
      default:
        return false;
    }
    return false;
  }
}

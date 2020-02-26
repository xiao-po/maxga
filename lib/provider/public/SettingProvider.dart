import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:maxga/MangaRepoPool.dart';
import 'package:maxga/base/setting/setting.model.dart';
import 'package:maxga/constant/SettingValue.dart';
import 'package:maxga/provider/base/BaseProvider.dart';
import 'package:maxga/service/Setting.service.dart';

class SettingGroup {
  final String title;
  final List<MaxgaSettingItem> items;
  final MaxgaSettingCategoryType category;
  SettingGroup({ this.items, this.category}): this.title = SettingCategoryList[category];


}


class SettingProvider extends BaseProvider {
  List<SettingGroup> _items;

  List<SettingGroup> get itemList => _items;

  static SettingProvider _instance;

  static SettingProvider getInstance() {
    if (_instance == null) {
      _instance = SettingProvider();
    }
    return _instance;
  }

  SettingProvider();

  MaxgaSettingItem getItem(MaxgaSettingItemType type) {
    for(final group in itemList) {
      for(final item in group.items) {
        if (item.key == type) {
          return item;
        }
      }
    }
    return null;
  }

  String getItemValue(MaxgaSettingItemType type) {
    return this.getItem(type)?.value ?? '0';
  }

  bool getBoolItemValue(MaxgaSettingItemType type) {
    final value = getItem(type).value ?? '0';
    return value == '1';
  }

  Future<bool> init() async {
    final value = await SettingService.getInitValue();
    List<SettingGroup> itemList = [];
    SettingCategoryList.keys.forEach((type) {
      itemList.add(
        SettingGroup(
          category: type,
          items: value.where((item) => item.category == type).toList(growable: false),
        )
      );
    });
    _items = itemList;
    notifyListeners();
    print('setting init over');
    return true;
  }



  Future<bool> modifySetting(MaxgaSettingItem item,String v) async {
    final isSuccess =
        await SettingService.saveItem(item.key.toString(), v);
    final group = _items.firstWhere((group) => group.category == item.category);
    final index = group.items.indexWhere((config) => config.key == item.key);
    group.items[index] = item.copyWith(value: v);
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

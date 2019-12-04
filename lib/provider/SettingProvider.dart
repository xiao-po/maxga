import 'dart:async';

import 'package:maxga/base/setting/Setting.model.dart';
import 'package:maxga/base/setting/SettingValue.dart';
import 'package:maxga/provider/base/BaseProvider.dart';
import 'package:maxga/service/Setting.service.dart';

class SettingProvider extends BaseProvider {
  List<MaxgaSettingItem> _items;

  SettingProvider() {
    this.init();
  }

  MaxgaSettingItem getItem(MaxgaSettingItemType type) {
    return this._items.firstWhere((el) => el.name == type);

  }

  Future<bool> init() async {
    final value = await SettingService.getInitValue();
    _items = value;
    return true;
  }

  Future<bool> modifySetting(MaxgaSettingItem item, value) async {
    final isSuccess = await SettingService.saveItem(SettingTypeNameList[item.name], value);
    item.value = value;
    return isSuccess;
  }
}

import 'package:maxga/base/setting/Setting.model.dart';
import 'package:maxga/base/setting/SettingValue.dart';

import 'LocalStorage.service.dart';

class SettingService {
  static String _key = 'Setting_Value';

  static Future<List<MaxgaSettingItem>> getInitValue() async {
    final List<MaxgaSettingItem> settingList = [];

    for (MaxgaSettingItem item in SettingItemListValue.value) {
      final v = await LocalStorage.getString('$_key${item.key.toString()}');
      final MaxgaSettingItem settingItem = item.copyWith(value: v);
      settingList.add(settingItem);
    }
    return settingList;
  }

  static Future<bool> resetAllValue() async {
    for (var item in SettingItemListValue.value) {
      await LocalStorage.clearItem('$_key${item.key.toString()}');
    }
    return true;
  }

  static Future<bool> saveItem(String name, String value) {
    return LocalStorage.setString('$_key$name', value);
  }
}

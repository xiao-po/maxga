import 'package:maxga/base/setting/Setting.model.dart';
enum MaxgaSettingCategoryType {
  application,
}

enum MaxgaSettingItemType {
  readOnlyOnWiFi,

}

final Map<MaxgaSettingItemType, String> SettingTypeNameList =  {
  MaxgaSettingItemType.readOnlyOnWiFi: 'readOnlyOnWiFi',
};

final Map<MaxgaSettingCategoryType, String> SettingCategoryList =  {
  MaxgaSettingCategoryType.application: '应用设置',
};

final List<MaxgaSettingItem> SettingItemList = [
  MaxgaSettingItem(
    name: MaxgaSettingItemType.readOnlyOnWiFi,
    title: '仅 wifi 下阅读漫画',
    value: '0',
    category: MaxgaSettingCategoryType.application,
  ),

];
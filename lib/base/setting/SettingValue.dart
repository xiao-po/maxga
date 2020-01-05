import 'package:flutter/material.dart';
import 'package:maxga/base/setting/Setting.model.dart';

enum MaxgaSettingCategoryType {
  application,
  network,
  other,
}

enum MaxgaSettingListTileType { none, checkbox, text, select, title, command, confirmCommand }

enum MaxgaSettingItemType {
  readOnlyOnWiFi,
  timeoutLimit,
  cleanCache,
  useMaxgaProxy,
  resetSetting,
}

const Map<MaxgaSettingItemType, List<DropdownMenuItem<String>>>
    MaxgaDropDownOptionsMap = const {
  MaxgaSettingItemType.timeoutLimit: [
    DropdownMenuItem(
      value: '5000',
      child: const Text('5s'),
    ),
    DropdownMenuItem(
      value: '10000',
      child: const Text('10s'),
    ),
    DropdownMenuItem(
      value: '15000',
      child: const Text('15s'),
    ),
    DropdownMenuItem(
      value: '30000',
      child: const Text('30s'),
    ),
  ]
};

// ignore: non_constant_identifier_names
final Map<MaxgaSettingItemType, String> SettingTypeNameList = {
  MaxgaSettingItemType.readOnlyOnWiFi: 'readOnlyOnWiFi',
  MaxgaSettingItemType.timeoutLimit: 'timeoutLimit',
  MaxgaSettingItemType.useMaxgaProxy: 'useMaxgaProxy',
  MaxgaSettingItemType.cleanCache: 'cleanCache',
};

// ignore: non_constant_identifier_names
final Map<MaxgaSettingCategoryType, String> SettingCategoryList = {
  MaxgaSettingCategoryType.application: '应用设置',
  MaxgaSettingCategoryType.network: '网络设置',
  MaxgaSettingCategoryType.other: '其他设置',
};

// ignore: non_constant_identifier_names
final List<MaxgaSettingItem> SettingItemList = [
  MaxgaSettingItem(
    key: MaxgaSettingItemType.readOnlyOnWiFi,
    type: MaxgaSettingListTileType.checkbox,
    title: '仅 wifi 下阅读漫画',
    value: '0',
    category: MaxgaSettingCategoryType.application,
  ),
//  MaxgaSettingItem(
//    key: MaxgaSettingItemType.useMaxgaProxy,
//    title: '使用内置代理',
//    type: MaxgaSettingListTileType.checkbox,
//    subTitle: '针对部分网站加入代理加速 (不包括图片)',
//    value: '0',
//    category: MaxgaSettingCategoryType.network,
//  ),
  MaxgaSettingItem(
    key: MaxgaSettingItemType.timeoutLimit,
    type: MaxgaSettingListTileType.select,
    title: '超时时间',
    value: '15000',
    category: MaxgaSettingCategoryType.network,
  ),
  MaxgaSettingItem(
    key: MaxgaSettingItemType.cleanCache,
    type: MaxgaSettingListTileType.command,
    title: '清除缓存',
    category: MaxgaSettingCategoryType.network,
  ),
  MaxgaSettingItem(
    key: MaxgaSettingItemType.resetSetting,
    type: MaxgaSettingListTileType.confirmCommand,
    title: '重置设置',
    category: MaxgaSettingCategoryType.other,
  )

];

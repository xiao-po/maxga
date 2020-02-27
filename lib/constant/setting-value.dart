import 'package:flutter/material.dart';
import 'package:maxga/base/setting/setting.model.dart';
import 'package:maxga/http/repo/dmzj/constants/dmzj-manga-source.dart';
import 'package:maxga/http/repo/hanhan/constant/hanhan-repo-value.dart';
import 'package:maxga/http/repo/manhuadui/constants/manhuadui-manga-source.dart';
import 'package:maxga/http/repo/manhuagui/constants/manhuagui-manga-source.dart';

enum MaxgaSettingCategoryType {
  application,
  network,
  other,
}

enum MaxgaSettingListTileType {
  checkbox,
  text,
  select,
  title,
  command,
  confirmCommand
}

enum MaxgaSettingItemType {
  readOnlyOnWiFi,
  timeoutLimit,
  cleanCache,
  useMaxgaProxy,
  resetSetting,
  defaultIndexPage,
  defaultMangaSource,
}

enum DefaultIndexPage {
  collect,
  sourceViewer
}

class SelectOption<T> {
  final String title;
  final T value;
  final String content;

  const SelectOption({@required this.title,@required this.value, this.content});

}

const Map<MaxgaSettingItemType, List<SelectOption<String>>>
    MaxgaSelectOptionsMap = const {
  MaxgaSettingItemType.timeoutLimit: [
    SelectOption(
      value: '5000',
      title: '5s',
    ),
    SelectOption(
      value: '10000',
      title: '10s',
    ),
    SelectOption(
      value: '15000',
      title: '15s',
    ),
    SelectOption(
      value: '30000',
      title: '30s',
    ),

    SelectOption(
      value: '60000',
      title: '60s',
    ),
  ],
  MaxgaSettingItemType.defaultIndexPage: [
    SelectOption(
      value: '0',
      title: '收藏',
    ),
    SelectOption(
      value: '1',
      title: '图源',
    ),
  ],
  MaxgaSettingItemType.defaultMangaSource: [
    SelectOption(
      value: DmzjMangaSourceKey,
      title: '动漫之家',
    ),
    SelectOption(
      value: HanhanMangaSourceKey,
      title: '汗汗漫画',
    ),
    SelectOption(
      value: ManhuaguiMangaSourceKey,
      title: '漫画柜',
    ),
    SelectOption(
      value: ManhuaduiMangaSourceKey,
      title: '漫画堆',
    ),
  ]
};


// ignore: non_constant_identifier_names
final Map<MaxgaSettingCategoryType, String> SettingCategoryList = {
  MaxgaSettingCategoryType.application: '应用设置',
  MaxgaSettingCategoryType.network: '网络设置',
  MaxgaSettingCategoryType.other: '其他设置',
};


const _ApplicationSettingValueList = [
  MaxgaSettingItem(
    key: MaxgaSettingItemType.defaultIndexPage,
    type: MaxgaSettingListTileType.select,
    title: '默认主页',
    value: '0',
    category: MaxgaSettingCategoryType.application,
  ),
  MaxgaSettingItem(
    key: MaxgaSettingItemType.defaultMangaSource,
    type: MaxgaSettingListTileType.select,
    title: '默认漫画源',
    value: DmzjMangaSourceKey,
    category: MaxgaSettingCategoryType.application,
  ),
  MaxgaSettingItem(
    key: MaxgaSettingItemType.readOnlyOnWiFi,
    type: MaxgaSettingListTileType.checkbox,
    title: '仅 wifi 下阅读漫画',
    value: '0',
    category: MaxgaSettingCategoryType.application,
  ),
  MaxgaSettingItem(
    key: MaxgaSettingItemType.useMaxgaProxy,
    title: 'Api 加速访问',
    type: MaxgaSettingListTileType.checkbox,
    subTitle: '针对部分海外网站的 api 提供加速 \n'
        '（不包括图片, 无法正常使用时请关闭）',
    value: '0',
    category: MaxgaSettingCategoryType.network,
  ),
];

const _NetworkSettingItemList = [
  MaxgaSettingItem(
    key: MaxgaSettingItemType.useMaxgaProxy,
    title: '使用内置代理',
    type: MaxgaSettingListTileType.checkbox,
    subTitle: '针对部分网站加入代理加速 (不包括图片)',
    value: '0',
    hidden: true,
    category: MaxgaSettingCategoryType.network,
  ),
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
];

class SettingItemListValue {
  static const _value = [
    ..._ApplicationSettingValueList,
    ..._NetworkSettingItemList,
    MaxgaSettingItem(
      key: MaxgaSettingItemType.resetSetting,
      type: MaxgaSettingListTileType.confirmCommand,
      title: '重置设置',
      category: MaxgaSettingCategoryType.other,
    )
  ];

  static get value => _value.toList()..removeWhere((item) => item.hidden);

  static get allValue => _value;

  static get hiddenValue => _value.toList()..removeWhere((item) => !item.hidden);

}

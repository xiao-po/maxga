import 'package:flutter/cupertino.dart';

import 'SettingValue.dart';

class MaxgaSettingItem {
  final MaxgaSettingItemType key;
  final MaxgaSettingListTileType type;
  final String title;
  final String subTitle;
  final String description;
  final MaxgaSettingCategoryType category;
  final bool hidden;
  final String value;

  const MaxgaSettingItem(
      {@required this.type,
      @required this.key,
      this.subTitle,
      this.hidden = false,
      this.description,
      @required this.category,
      this.value,
      @required this.title});

//  MaxgaSettingItem.formJson(Map<String, dynamic> settingItem) {
//    type = settingItem['name'];
//    title = settingItem['title'];
//    subTitle = settingItem['subTitle'];
//    description = settingItem['description'];
//    category = settingItem['category'];
//    value = settingItem['value'];
//  }

  MaxgaSettingItem copy() {
    return this.copyWith();
  }

  MaxgaSettingItem copyWith({String value, bool hidden}) {
    return MaxgaSettingItem(
        key: key,
        title: title,
        type: type,
        hidden: hidden ?? this.hidden,
        subTitle: subTitle,
        description: description,
        category: category,
        value: value ?? this.value);
  }
}

import 'package:flutter/cupertino.dart';

import 'SettingValue.dart';

class MaxgaSettingItem {
  final MaxgaSettingItemType key;
  final MaxgaSettingListTileType type;
  final String title;
  final String subTitle;
  final String description;
  final MaxgaSettingCategoryType category;
  String value;

  MaxgaSettingItem(
      {@required this.type,
      @required this.key,
      this.subTitle,
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
    return MaxgaSettingItem(
        key: key,
        title: title,
        type: type,
        subTitle: subTitle,
        description: description,
        category: category,
        value: value);
  }
}

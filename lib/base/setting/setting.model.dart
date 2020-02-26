import 'package:flutter/cupertino.dart';
import 'package:maxga/constant/setting-value.dart';


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
      @required this.title})
      : assert(type != null);

  const MaxgaSettingItem.title(
      {this.key,
      MaxgaSettingListTileType type,
      this.title,
      @required this.subTitle,
      this.description,
      @required this.category,
      this.hidden,
      this.value})
      : this.type = MaxgaSettingListTileType.title;

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

class MaxgaSettingPageItem extends MaxgaSettingItem {
  final WidgetBuilder pageBuilder;

  MaxgaSettingPageItem({
    @required MaxgaSettingItemType key,
    String title,
    String subTitle,
    String description,
    @required MaxgaSettingCategoryType category,
    bool hidden,
    String value,
    this.pageBuilder,
  }) : super(
            key: key,
            title: title,
            type: MaxgaSettingListTileType.page,
            hidden: hidden,
            subTitle: subTitle,
            description: description,
            category: category,
            value: value);
}

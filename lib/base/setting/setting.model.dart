import 'package:flutter/cupertino.dart';
import 'package:maxga/constant/setting-value.dart';

class MaxgaSettingItem {
  /// 具体相关项目
  final MaxgaSettingItemType key;

  /// 设定 form 种类
  final MaxgaSettingListTileType type;

  /// 设定的 title
  final String title;

  /// 设定非激活时的小标题
  final String subTitle;

  /// 设定激活时的标题
  final String activeSubTitle;

  /// 设定归属大类
  final MaxgaSettingCategoryType category;

  /// 是否隐藏
  /// 该配置是准备给相关需要隐藏的设置选项准备的
  final bool hidden;

  /// value
  final String value;


  const MaxgaSettingItem(
      {@required this.type,
      @required this.key,
      this.subTitle,
      this.hidden = false,
      this.activeSubTitle,
      @required this.category,
      this.value,
      @required this.title})
      : assert(type != null);

  const MaxgaSettingItem.title(
      {this.key,
      this.activeSubTitle,
      MaxgaSettingListTileType type,
      this.title,
      @required this.subTitle,
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
        category: category,
        value: value ?? this.value);
  }
}

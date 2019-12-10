

import 'package:flutter/material.dart';
import 'package:maxga/base/drawer/menu-item.dart';

const List<MaxgaMenuItem> DrawerMenuList = [
  const MaxgaMenuItem('收藏', Icons.collections_bookmark, MaxgaMenuItemType.collect),
  const MaxgaMenuItem('图源', Icons.view_list, MaxgaMenuItemType.mangaSourceViewer),
  const MaxgaMenuItem('历史记录', Icons.history, MaxgaMenuItemType.history),
  const MaxgaMenuItem('设置', Icons.settings, MaxgaMenuItemType.setting),
  const MaxgaMenuItem('关于', Icons.info_outline, MaxgaMenuItemType.about),
];
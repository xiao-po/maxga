
import 'package:flutter/cupertino.dart';

enum MaxgaMenuItemType {
  collect,
  history,
  mangaSourceViewer,
  setting,
  about,
}

class DrawerMenuItem {
  final String title;
  final IconData icon;
  final MaxgaMenuItemType type;

  const DrawerMenuItem(this.title, this.icon, this.type);


}
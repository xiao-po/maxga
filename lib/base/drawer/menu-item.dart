
import 'package:flutter/cupertino.dart';

enum MaxgaMenuItemType {
  collect,
  history,
  mangaSourceViewer,
  setting,
  about,
}

class MaxgaMenuItem {
  final String title;
  final IconData icon;
  final MaxgaMenuItemType type;

  const MaxgaMenuItem(this.title, this.icon, this.type);


}
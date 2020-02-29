
import 'package:flutter/cupertino.dart';

enum MaxgaMenuItemType {
  collect,
  history,
  mangaSourceViewer,
  setting,
  about,
  hiddenMangaViewer,
}

class DrawerMenuItem {
  final String title;
  final IconData icon;
  final MaxgaMenuItemType type;
  final bool shouldLogin;

  const DrawerMenuItem(this.title, this.icon, this.type, {this.shouldLogin = false});


}
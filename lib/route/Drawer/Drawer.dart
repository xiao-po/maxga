import 'package:flutter/material.dart';
import 'package:maxga/base/drawer/menu-item.dart';
import 'package:maxga/constant/DrawerValue.dart';
import 'package:maxga/provider/IndexPageTypeProvider.dart';
import 'package:maxga/route/Drawer/about/about-page.dart';
import 'package:maxga/route/index/sub-page/collection.dart';
import 'package:maxga/route/Drawer/history/history-page.dart';
import 'package:maxga/route/Drawer/setting/Setting-page.dart';
import 'package:provider/provider.dart';

class MaxgaDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MaxgaDrawerState();
}

class MaxgaDrawerState extends State<MaxgaDrawer> {
  @override
  Widget build(BuildContext context) {
    IndexPageTypeProvider indexPageTypeProvider =
        Provider.of<IndexPageTypeProvider>(context);
    final list = DrawerMenuList.map((menuItem) => ListTile(
        title: Text(menuItem.title),
        leading: Icon(menuItem.icon),
        selected: menuItem.type == indexPageTypeProvider.type,
        onTap: () => _handleMenuItemChoose(menuItem.type))).toList(growable: false);
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: const Text('MaxGa'),
          ),
          MediaQuery.removePadding(
              context: context,
              child: Expanded(
                child: ListView(
                  children: list,
                ),
              ))
        ],
      ),
    );
  }

  _handleMenuItemChoose(MaxgaMenuItemType type) async {
    switch (type) {
      case MaxgaMenuItemType.collect:
      case MaxgaMenuItemType.mangaSourceViewer:
        Navigator.pop(context);
//        await Future.delayed(Duration(milliseconds: 100));
        IndexPageTypeProvider indexPageTypeProvider =
            Provider.of<IndexPageTypeProvider>(context);
        indexPageTypeProvider.changeIndexPageType(type);
        break;
      case MaxgaMenuItemType.history:
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoryPage(),
            ));
        break;
      case MaxgaMenuItemType.setting:
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingPage(),
            ));
        break;
      case MaxgaMenuItemType.about:
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AboutPage(),
            ));
        break;
    }
  }
}

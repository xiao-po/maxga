import 'package:flutter/material.dart';
import 'package:maxga/route/Drawer/about/about-page.dart';
import 'package:maxga/route/Drawer/history/history-page.dart';
import 'package:maxga/route/Drawer/setting/Setting-page.dart';

class MaxgaDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: const Text('maxga'),
          ),
          MediaQuery.removePadding(
              context: context,
              child: Expanded(
                child: ListView(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: const Text('历史记录'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => HistoryPage(),
                        ));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: const Text('设置'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => SettingPage(),
                        ));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.info_outline),
                      title: const Text('关于'),
                      onTap: (){
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => AboutPage(),
                        ));
                      },
                    )
                  ],
                ),
              )
          )
        ],
      ),
    );
  }

}
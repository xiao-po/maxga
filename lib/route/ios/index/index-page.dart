import 'package:flutter/cupertino.dart';
import 'package:maxga/route/ios/index/sub-page/cupertino-source-viewer.dart';

class CupertinoIndexPage extends StatefulWidget  {
  @override
  State<StatefulWidget> createState() => _CupertinoIndexPage();
}

class _CupertinoIndexPage extends State<CupertinoIndexPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book),
            title: Text('漫画'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bookmark_solid),
            title: Text('书架'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            title: Text('设置'),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) => CupertinoSourceViewer(),
        );
      },
    );
  }

}
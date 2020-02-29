import 'package:flutter/material.dart';
import 'package:maxga/base/delay.dart';
import 'package:maxga/route/android/hidden-manga/hidden-manga-page.dart';
import 'package:maxga/route/android/search/search-page.dart';
import 'package:maxga/route/android/source-viewer/source-viewer.dart';

class CollectEmptyTipBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('居然一个收藏的漫画都没有...', style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 8),
          Text('那...那我给你三个建议 :', style: TextStyle(color: Colors.grey[500])),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ViewSourceFlatButton(),
              const SizedBox(width: 8),
              SearchFlatButton()
            ],
          ),
          Text('等...等等，第三个呢？',style: TextStyle(color: Colors.grey[500])),
          HiddenMangaFlatButton()
        ],
      ),
    );
  }
}

class HiddenMangaFlatButton extends StatelessWidget {
  const HiddenMangaFlatButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return FlatButton(
      child: Text('神隐的漫画', style: TextStyle(color: theme.scaffoldBackgroundColor)),
      onPressed: () async {
        await LongAnimationDelay();
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  HiddenMangaPage(),
            ));
      },
    );
  }
}

class ViewSourceFlatButton extends StatelessWidget {
  const ViewSourceFlatButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text('查看画廊'),
      onPressed: () async {
        await LongAnimationDelay();
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  SourceViewerPage(),
            ));
      },
    );
  }
}

class SearchFlatButton extends StatelessWidget {
  const SearchFlatButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text('搜索画廊'),
      onPressed: () async {
        await LongAnimationDelay();
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SearchPage(),
            ));
      },
    );
  }
}

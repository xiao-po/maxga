import 'package:flutter/material.dart';
import 'package:maxga/base/delay.dart';
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
              FlatButton(
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
              ),
              const SizedBox(width: 8),
              FlatButton(
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
              )
            ],
          ),
          Text('等...等等，第三个呢？',style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}

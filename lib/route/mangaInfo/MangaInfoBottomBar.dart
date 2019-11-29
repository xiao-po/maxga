
import 'package:flutter/material.dart';

typedef OnCollectCallBack = void Function();
typedef OnResumeCallBack = void Function();

class MangaInfoBottomBar extends StatelessWidget {
  final OnCollectCallBack onCollect;
  final OnResumeCallBack onResume;
  final bool readed;
  final bool collected;

  const MangaInfoBottomBar({Key key, this.onCollect, this.onResume, this.readed = false, this.collected = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(width: 1, color: Color(0xffeaeaea)))),
      padding: EdgeInsets.only(left: 10, top: 2, bottom: 2, right: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton.icon(
              onPressed: onCollect,
              icon: Icon(Icons.star_border, color: collected ? Colors.orangeAccent : Colors.black,),
              label: const Text('收藏')),
          buildResumeButton()
        ],
      ),
    );
  }

  FlatButton buildResumeButton() {
    return FlatButton(
      onPressed: onResume,
      textColor: Colors.white,
      color: Colors.blueAccent,
      shape:  RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(25.0)
      ),
      child: readed ? Text('  继续阅读  ') : Text('  开始阅读  '),
    );
  }
}

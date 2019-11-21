import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/model/Manga.dart';

class MangaInfoIntro extends StatelessWidget {
  final String intro;

  const MangaInfoIntro({Key key, this.intro}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry containerPadding = const EdgeInsets.only(top: 10, bottom: 10);
    final EdgeInsetsGeometry containerMargin = const EdgeInsets.only(left: 20, right: 20);
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Color(0xffefefef))
          )
      ),
      padding: containerPadding,
      margin: containerMargin,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              intro,
              overflow: TextOverflow.fade,
              style: TextStyle(
                  color: Color(0xff7b7b7b)
              ),
            ),
          )
        ],
      ),
    );
  }


}

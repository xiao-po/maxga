import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/model/Manga.dart';

class MangaInfoIntro extends StatefulWidget {
  final Manga manga;

  const MangaInfoIntro({Key key, this.manga}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MangaInfoIntroState();



}

class _MangaInfoIntroState extends State<MangaInfoIntro> {

  int maxLines = 4;

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
              widget.manga.introduce,
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

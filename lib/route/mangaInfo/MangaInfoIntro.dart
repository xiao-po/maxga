import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/skeleton.dart';
import 'package:maxga/model/Manga.dart';
import 'package:shimmer/shimmer.dart';

class MangaInfoIntro extends StatelessWidget {
  final String intro;

  const MangaInfoIntro({Key key, this.intro}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry containerMargin = const EdgeInsets.only(
        left: 20, right: 20);
    final EdgeInsetsGeometry containerPadding = const EdgeInsets.only(
        top: 10, bottom: 10);
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Color(0xffefefef))
          )
      ),
      padding: containerPadding,
      margin: containerMargin,
      child: Text(
        intro,
        overflow: TextOverflow.fade,
        style: TextStyle(
            color: Color(0xff7b7b7b)
        ),
      ),
    );
  }


}

class MangaInfoIntroSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry containerMargin = const EdgeInsets.only(
        left: 20, right: 20);
    final EdgeInsetsGeometry containerPadding = const EdgeInsets.only(
        top: 10, bottom: 10);
    final intro = Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Color(0xffefefef))
          )
      ),
      height: 100,
      padding: containerPadding,
      margin: containerMargin,
      child: Shimmer.fromColors(
          period: Duration(milliseconds: 1200),
          baseColor: Colors.grey[350],
          highlightColor: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(height: 14, decoration: SkeletonDecoration()),
              Container(height: 14, decoration: SkeletonDecoration()),
              Container(height: 14, margin: EdgeInsets.only(right: 40), decoration: SkeletonDecoration()),
            ],
          )
      ),
    );
    return intro;
  }


}

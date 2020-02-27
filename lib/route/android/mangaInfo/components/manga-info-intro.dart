import 'package:flutter/material.dart';
import 'package:maxga/components/skeleton.dart';
import 'package:shimmer/shimmer.dart';

class MangaInfoIntro extends StatefulWidget {
  final String intro;

  const MangaInfoIntro({Key key, this.intro}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MangaInfoIntroState();

}

class MangaInfoIntroState extends State<MangaInfoIntro> {
  bool isExpand = false;


  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry containerMargin = const EdgeInsets.only(
        left: 20, right: 20);
    final EdgeInsetsGeometry containerPadding = const EdgeInsets.only(
        top: 10, bottom: 10);
    var introText = Text(
      widget.intro,
      overflow: TextOverflow.ellipsis,
      maxLines: isExpand ? 100 : 3,
      style: TextStyle(
          color: Color(0xff7b7b7b),
          height: 1.3
      ),
    );
    final body = Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Color(0xffefefef))
          )
      ),
      padding: containerPadding,
      margin: containerMargin,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: introText,
          ),
          SizedBox(
            height: 20,
            child: Icon(
                isExpand ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.grey[500],
            ),
          )
        ],
      ),
    );
    return GestureDetector(
      child: body,
      onTap: () => changeExpandStatus(),
    );
  }


  changeExpandStatus() {
    setState(() {
      isExpand = !isExpand;
    });
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
              Container(height: 14,
                  margin: EdgeInsets.only(right: 40),
                  decoration: SkeletonDecoration()),
            ],
          )
      ),
    );
    return intro;
  }


}

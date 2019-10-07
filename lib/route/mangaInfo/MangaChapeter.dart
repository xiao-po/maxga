import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/Utils/DateUtils.dart';
import 'package:maxga/components/MangaOutlineButton.dart';
import 'package:maxga/constant/SortValue.dart';
import 'package:maxga/model/Chapter.dart';
import 'package:maxga/model/Manga.dart';
import 'package:maxga/route/mangaViewer/MangaViewer.dart';

typedef EnjoyMangaCallback = void Function(Chapter chapter);

class MangaInfoChapter extends StatefulWidget {
  final Manga manga;


  const MangaInfoChapter({Key key, this.manga}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MangaInfoChapterState();
}

class _MangaInfoChapterState extends State<MangaInfoChapter> {
  SortType sortType = SortType.asc;
  List<Chapter> chapterList;

  @override
  void initState() {
    super.initState();
    chapterList = widget.manga.chapterList.toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry containerPadding =
        const EdgeInsets.only(top: 0, bottom: 0);
    final EdgeInsetsGeometry containerMargin =
        const EdgeInsets.only(left: 20, right: 20);
    return Container(
      padding: containerPadding,
//      margin: containerMargin,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20, right: 10),
            child: buildChapterStatus(
              status: widget.manga.status,
            ),
          ),
          _MangaChapterGrid(
              chapterList: chapterList,
              onOpenChapter: (item) => enjoyMangaContent(context, item),
          ),
        ],
      ),
    );
  }

  Widget buildChapterStatus({String status}) {
    final Color textColor = Color(0xff7b7b7b);
    final TextStyle textStyle = TextStyle(color: textColor);
    final TextStyle highlightTextStyle = TextStyle(color: Colors.lightBlue);
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(status, style: textStyle,),
          Row(
            children: <Widget>[
              FlatButton(
                child: Row(
                  children: <Widget>[
                    Text('正序',
                        textAlign: TextAlign.center,
                        style: sortType == SortType.asc
                            ? highlightTextStyle
                            : textStyle),
                    Icon(Icons.swap_horiz, size: 18, color: textColor),
                    Text('倒序',
                        textAlign: TextAlign.center,
                        style: sortType == SortType.desc
                            ? highlightTextStyle
                            : textStyle)
                  ],
                ),
                onPressed: () => changeSortType(),
              )
            ],
          )
        ]);
  }


  void enjoyMangaContent(BuildContext context, Chapter chapter) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => MangaViewer(
          manga: widget.manga,
          currentChapter: chapter,
        )
    ));
  }

  changeSortType() {
    if (sortType == SortType.asc) {
      sortType = SortType.desc;
      chapterList.sort((a, b) => a.order - b.order);
    } else {
      sortType = SortType.asc;
      chapterList.sort((a, b) => b.order - a.order);
    }



    setState(() {});
  }
}

class _MangaChapterGrid extends StatelessWidget {
  final List<Chapter> chapterList;
  final EnjoyMangaCallback onOpenChapter;

  const _MangaChapterGrid({Key key, this.chapterList, this.onOpenChapter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry gridPadding =
      const EdgeInsets.only(top: 0, bottom: 0, left: 5, right: 5);
    return GridView.count(
        padding: gridPadding,
        crossAxisCount: 3,
        childAspectRatio: 2.0,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: chapterList
            .map((item) => Align(
                  child: MangaOutlineButton(
                      active: true,
                      text: Text(item.title, textAlign: TextAlign.center, style: TextStyle()),
                      onPressed: () => onOpenChapter(item),
                  ),
                ))
            .toList(growable: false));
  }


}

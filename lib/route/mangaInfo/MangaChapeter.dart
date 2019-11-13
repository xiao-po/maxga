import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/MangaOutlineButton.dart';
import 'package:maxga/constant/SortValue.dart';
import 'package:maxga/model/Chapter.dart';
import 'package:maxga/model/Manga.dart';
import 'package:maxga/model/MangaReadProcess.dart';

typedef EnjoyMangaCallback = void Function(Chapter chapter);

class MangaInfoChapter extends StatefulWidget {
  final Manga manga;

  final EnjoyMangaCallback onClickChapter;
  final MangaReadProcess readStatus;


  const MangaInfoChapter({Key key, this.manga, this.onClickChapter, this.readStatus}) : super(key: key);

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
              readStatus: widget.readStatus,
              chapterList: chapterList,
              onOpenChapter: (item) => widget.onClickChapter(item),
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
                    Text('正序 ',
                        textAlign: TextAlign.center,
                        style: sortType == SortType.asc
                            ? highlightTextStyle
                            : textStyle),
                    Icon(Icons.swap_horiz, size: 18, color: textColor),
                    Text(' 倒序',
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

  final MangaReadProcess readStatus;

  const _MangaChapterGrid({Key key, this.chapterList, this.onOpenChapter, this.readStatus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry gridPadding =
      const EdgeInsets.only(top: 0, bottom: 0, left: 5, right: 5);
    print(readStatus);
    return GridView.count(
        padding: gridPadding,
        crossAxisCount: 3,
        childAspectRatio: 2.0,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: chapterList
            .map((item) => Align(
                  child: MangaOutlineButton(
                      active: readStatus?.chapterId == item.id ?? null,
                      text: Text(item.title, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,),
                      onPressed: () => onOpenChapter(item),
                  ),
                ))
            .toList(growable: false));
  }


}

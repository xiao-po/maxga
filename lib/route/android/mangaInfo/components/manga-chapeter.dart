import 'package:flutter/material.dart';
import 'package:maxga/components/button/manga-outline-button.dart';
import 'package:maxga/constant/sort-value.dart';
import 'package:maxga/model/manga/chapter.dart';
import 'package:maxga/model/manga/manga.dart';
import 'package:maxga/model/maxga/read-manga-status.dart';
import 'package:shimmer/shimmer.dart';

typedef EnjoyMangaCallback = void Function(Chapter chapter);

class MangaInfoChapter extends StatefulWidget {
  final List<Chapter> chapterList;

  final EnjoyMangaCallback onClickChapter;
  final Manga manga;
  final ReadMangaStatus readStatus;

  const MangaInfoChapter(
      {Key key, this.onClickChapter, this.manga, this.chapterList, this.readStatus})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MangaInfoChapterState();
}

class _MangaInfoChapterState extends State<MangaInfoChapter> {
  SortType sortType = SortType.asc;
  List<Chapter> chapterList;

  @override
  void initState() {
    super.initState();
    chapterList = widget.chapterList.toList(growable: false);
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
    final theme = Theme.of(context);
    final Color textColor = Color(0xff7b7b7b);
    final TextStyle textStyle = TextStyle(color: textColor);
    final TextStyle highlightTextStyle = TextStyle(color: theme.accentColor);
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            status ?? '漫画状态未知',
            style: textStyle,
          ),
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

  final ReadMangaStatus readStatus;

  const _MangaChapterGrid(
      {Key key, this.chapterList, this.onOpenChapter, this.readStatus})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry gridPadding =
        const EdgeInsets.only(top: 0, bottom: 0, left: 5, right: 5);

    double deviceWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (deviceWidth / 120).floor();
    return GridView.count(
        padding: gridPadding,
        crossAxisCount: crossAxisCount,
        childAspectRatio: 2.0,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: chapterList
            .map((item) => Align(
                  child: MangaOutlineButton(
                    active: readStatus?.chapterId == item.id ?? null,
                    text: Text(
                      item.title,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () => onOpenChapter(item),
                  ),
                ))
            .toList(growable: false));
  }
}

class SkeletonMangaChapterGrid extends StatelessWidget {
  final int colCount;

  const SkeletonMangaChapterGrid({Key key, this.colCount = 3})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (deviceWidth / 120).floor();
    final skeletonButtonRow = List(crossAxisCount)
      ..fillRange(0, crossAxisCount, 0);
    final skeletonButtonCol = List(colCount)..fillRange(0, colCount, 0);
    var skeletonGridView = skeletonButtonCol
        .map((item) => buildGridViewRow(skeletonButtonRow))
        .toList();
    var body = Column(children: [
      Padding(
        padding: EdgeInsets.only(left: 20,right: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            buildSkeletonRect(width: 100, height: 20),
            buildSkeletonRect(width: 100, height: 20),
          ],
        ),
      ),
      ...skeletonGridView
    ]);
    return Shimmer.fromColors(
        period: Duration(milliseconds: 1200),
        baseColor: Colors.grey[350],
        highlightColor: Colors.grey[200],
        child: body);
  }

  Widget buildGridViewRow(List skeletonButtonRow) {
    return Row(
        children: skeletonButtonRow
            .map((item) => Expanded(
                  flex: 1,
                  child: buildButtonSkeleton(),
                ))
            .toList());
  }

  Widget buildButtonSkeleton() {
    return buildSkeletonRect(
        width: 100,
        height: 35,
        borderRadius: BorderRadius.circular(5.0)
    );
  }

  Widget buildSkeletonRect({
    double width,
    double height,
    BorderRadius borderRadius}) {
    return Align(
      child: Container(
        width: width,
        height: height,
        margin: EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
            color: Colors.grey[350], borderRadius: borderRadius),
      ),
    );
  }
}

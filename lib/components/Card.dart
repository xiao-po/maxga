import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/skeleton.dart';
import 'package:maxga/model/Manga.dart';

typedef CoverBuilder = Widget Function(BuildContext context);

class MangaCard extends StatelessWidget {
  final GestureTapCallback onTap;
  final Widget cover;
  final Widget title;
  final List<MangaLabel> labels;
  final CoverBuilder coverBuilder;
  final Widget extra;

  MangaCard(
      {this.onTap,
      this.cover,
      this.coverBuilder,
      @required this.title,
      this.labels,
      this.extra});

  final Color grayFontColor = Color(0xff9e9e9e);

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry cardPadding = EdgeInsets.only(
      left: 0,
      right: 10,
      top: 10,
      bottom: 10,
    );
    final double cardHeight = 120;
    final double coverWidth = 100;
    final double coverHorizonPadding = (cardHeight - coverWidth) / 2;
    var edgeInsets = EdgeInsets.only(top: 0, left: 10);
    var bodyColumn = <Widget>[title];
    if (labels != null && labels.length > 0) {
      bodyColumn.addAll(labels);
    }
    Widget body = Container(
      height: cardHeight,
      padding: cardPadding,
      child: Row(
        children: <Widget>[
          Center(
            child: Container(
              height: cardHeight,
              width: coverWidth,
              padding: EdgeInsets.only(
                  left: coverHorizonPadding,
                  right: coverHorizonPadding,
                  top: 0,
                  bottom: 0),
              child: cover ?? coverBuilder(context),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: edgeInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: bodyColumn,
              ),
            ),
          ),
          extra
        ],
      ),
    );
    if (this.onTap != null) {
      body = Material(
        child: InkWell(
          onTap: this.onTap,
          child: body,
        ),
      );
    }
    return Card(
      child: body
    );
  }

  Container buildMangaTitle(String title) {
    var titleTextStyle = TextStyle(fontSize: 16);
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: titleTextStyle,
        ),
      ),
    );
  }
}

class MangaLabel extends StatelessWidget {
  final Widget text;
  final IconData icon;

  const MangaLabel({Key key, this.text, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var containerPadding = EdgeInsets.only(top: 5);
    return Container(
      padding: containerPadding,
      child: Row(
        children: <Widget>[
          buildMangaInfoIcon(icon),
          Text(' '),
          Expanded(
            child: text,
          ),
        ],
      ),
    );
  }

  Icon buildMangaInfoIcon(IconData icon) {
    return Icon(
      icon,
      size: 16,
      color: Color(0xffffac38),
    );
  }
}

class MangaExtra extends StatelessWidget {
  final Widget body;
  final Widget bottom;

  const MangaExtra({Key key, @required this.body, this.bottom})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widgetWidget = MediaQuery.of(context).size.width;
    return Container(
      width: widgetWidget * 0.18,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.topRight,
              child: body,
            ),
          ),
          bottom,
        ],
      ),
    );
  }
}

class MangaInfoCardExtra extends StatelessWidget {
  final SimpleMangaInfo manga;
  final Color textColor;

  const MangaInfoCardExtra({
    Key key,
    this.manga,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: textColor);
    return MangaExtra(
      body: Text(
        manga.source.name,
        textAlign: TextAlign.right,
        style: textStyle,
      ),
      bottom: manga.lastUpdateChapter != null
          ? Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${manga.lastUpdateChapter.title} \n' +
                    (manga.lastUpdateChapter.updateTime != null
                        ? this.convertTimeToYYYYMMDD(
                            DateTime.fromMillisecondsSinceEpoch(
                                manga.lastUpdateChapter.updateTime))
                        : ''),
                textAlign: TextAlign.right,
                style: textStyle,
              ),
            )
          : Container(),
    );
  }

  String convertTimeToYYYYMMDD(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }
}

class SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color grayFontColor = Colors.grey[350] ;
    final EdgeInsetsGeometry cardPadding = EdgeInsets.only(
      left: 0,
      right: 0,
      top: 10,
      bottom: 10,
    );
    var edgeInsets = EdgeInsets.only(top: 0, left: 10);
    final double cardHeight = 120;
    final double coverWidth = 100;
    final double coverHorizonPadding = (cardHeight - coverWidth) / 2;
    return  Container(
      height: cardHeight,
      padding: cardPadding,
      child: Row(
        children: <Widget>[
          Center(
            child: Container(
              height: cardHeight,
              width: coverWidth - coverHorizonPadding,
              decoration: SkeletonDecoration(),
              margin: EdgeInsets.only(
                  left: coverHorizonPadding,
                  right: coverHorizonPadding,
                  top: 0,
                  bottom: 0),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: edgeInsets,
              margin: EdgeInsets.only(
                  left: 0,
                  right: coverHorizonPadding,
                  top: 0 ,
                  bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20, decoration: SkeletonDecoration()),
                  Container(height: 20, width: 100, margin: EdgeInsets.only(top: 10), decoration: SkeletonDecoration()),
                  Container(height: 20, width: 100, margin: EdgeInsets.only(top: 10), decoration: SkeletonDecoration())
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: 0,
                right: coverHorizonPadding,
                top: 0,
                bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(height: 20, width: 80, decoration: SkeletonDecoration()),
                Column(
                  children: <Widget>[
                    Container(height: 15, width: 80, margin: EdgeInsets.only(bottom: 5), decoration: SkeletonDecoration()),
                    Container(height: 15, width: 80, decoration: SkeletonDecoration()),

                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

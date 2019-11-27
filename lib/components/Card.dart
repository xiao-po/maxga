import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/model/Manga.dart';

typedef CoverBuilder = Widget Function(BuildContext context, SimpleMangaInfo manga);


class MangaCard extends StatelessWidget {
  final SimpleMangaInfo manga;
  final GestureTapCallback onTap;
  final Widget cover;
  final Widget title;
  final CoverBuilder coverBuilder;

  MangaCard({this.manga, this.onTap, this.cover, this.coverBuilder,@required this.title});

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
    final double coverHorizonPadding =( cardHeight - coverWidth ) / 2;
    var edgeInsets = EdgeInsets.only(top: 0, left: 10);
    return  Card(
      child: Material(
        child: InkWell(
          onTap: this.onTap,
          child: Container(
            height: cardHeight,
            padding: cardPadding,
            child:  Row(
              children: <Widget>[
                Center(
                  child: Container(
                    height: cardHeight,
                    width: coverWidth,
                    padding: EdgeInsets.only(left: coverHorizonPadding, right: coverHorizonPadding,top: 0,bottom: 0),
                    child: cover ?? coverBuilder(context, manga),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: edgeInsets,
                    child: Column(
                      children: <Widget>[
                        buildMangaTitle(manga.title),
                        buildLabelInfo(Icons.edit, manga.author),
                        buildLabelInfo(Icons.label_outline, manga.typeList.join(' / ')),
                      ],
                    ),
                  ),
                ),
                buildMangaMoreInfo()
              ],
            ),
          ),
        ),
      ),
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

  Container buildLabelInfo(IconData icon, String val) {
    var containerPadding = EdgeInsets.only(top: 5);
    return Container(
      padding: containerPadding,
      child: Row(
        children: <Widget>[
          buildMangaInfoIcon(icon),
          Text(' '),
          Expanded(
            child: Text(val, overflow: TextOverflow.ellipsis,),
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

  Container buildMangaMoreInfo() {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.topRight,
              child: Text(manga.source.name,textAlign: TextAlign.right, style: TextStyle(color: grayFontColor)),
            ),
          ),
          manga.lastUpdateChapter != null ? Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${manga.lastUpdateChapter.title} \n' +
                  (manga.lastUpdateChapter.updateTime != null ? this.convertTimeToYYYYMMDD(
                  DateTime.fromMillisecondsSinceEpoch(
                      manga.lastUpdateChapter.updateTime)) : ''),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: grayFontColor
              ),
            ),
          ) : Container()
        ],
      ),
    );
  }

  String convertTimeToYYYYMMDD(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }
}

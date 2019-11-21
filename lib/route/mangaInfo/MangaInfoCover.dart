import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/Utils/DateUtils.dart';
import 'package:maxga/model/Manga.dart';

class MangaInfoCover extends StatelessWidget {
  final SimpleMangaInfo manga;
  final bool loadEnd;

  final int  updateTime;

  const MangaInfoCover({Key key, this.manga, this.updateTime, this.loadEnd}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double topCoverImageHeight = 300;

    return Container(
      height: topCoverImageHeight,
      child: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            child: buildCoverImage(manga),
          ),
          loadEnd ? buildCoverMessage() : Container(),
        ],
      ),
    );
  }

  Widget buildCoverImage(SimpleMangaInfo item) {
    return Hero(
      tag: '${item.coverImgUrl}',
      child:  CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: item.coverImgUrl),
    );
  }

  buildCoverMessage() {
    var messagePadding = EdgeInsets.only(left: 20, right: 20);
    var messageBoxPadding = EdgeInsets.only(bottom: 10);
    var subTitleTextColor = Color(0xffe6e6e6);
    double subtitleTextSize = 14;
    double mangaTitleFontSize = 22;
    var messageBoxBackground = BoxDecoration(
      gradient: new LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0x5b000000),
            Color(0x3b8e8e8e),
          ]),
    );
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: messageBoxPadding,
      decoration: messageBoxBackground,
      child: Padding(
        padding: messagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                manga.title,
                style: TextStyle(color: Colors.white, fontSize: mangaTitleFontSize),
                textAlign: TextAlign.left,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${DateUtils.formatTime(timestamp: manga.lastUpdateChapter.updateTime, template: "yyyy-MM-dd")}',
                style: TextStyle(color: subTitleTextColor, fontSize: subtitleTextSize),
                textAlign: TextAlign.left,

              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  LimitedBox(
                    maxWidth: 220,
                    child: Text(
                      '${manga.author} · ${manga.typeList.join('/')}',
                      style: TextStyle(color: subTitleTextColor, fontSize: subtitleTextSize),
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '来源： ${manga.source.name}',
                    style: TextStyle(color: subTitleTextColor, fontSize: subtitleTextSize),
                    textAlign: TextAlign.left,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

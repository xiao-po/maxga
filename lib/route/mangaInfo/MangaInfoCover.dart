import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/model/Manga.dart';

class MangaInfoCover extends StatelessWidget {
  final Manga manga;
  final String updateTime;

  const MangaInfoCover({Key key, this.manga, this.updateTime}) : super(key: key);

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
            child: buildCoverImage(),
          ),
          buildCoverMessage(),
        ],
      ),
    );
  }

  CachedNetworkImage buildCoverImage() {
    return CachedNetworkImage(
      placeholder: (context, url) => Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      imageUrl: manga.coverImgUrl,
      alignment: Alignment.topCenter,
      fit: BoxFit.cover,
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
                updateTime,
                style: TextStyle(color: subTitleTextColor, fontSize: subtitleTextSize),
                textAlign: TextAlign.left,

              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '${manga.author} · ${manga.typeList.join('/')}',
                    style: TextStyle(color: subTitleTextColor, fontSize: subtitleTextSize),
                    textAlign: TextAlign.left,
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

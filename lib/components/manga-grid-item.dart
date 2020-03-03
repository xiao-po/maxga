import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:maxga/model/manga/manga.dart';
import 'package:maxga/model/manga/manga-source.dart';
import 'package:maxga/model/maxga/collected-manga.dart';

import 'base/manga-cover-image.dart';

class MangaGridItem extends StatelessWidget {
  final CollectedManga manga;
  final String tagPrefix;
  final double width;

  final MangaSource source;

  final Color textColor;

  const MangaGridItem(
      {Key key,
      @required this.manga,
      @required this.tagPrefix,
      @required this.source,
      this.textColor,
      this.width = 130})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var gridCover = buildCover();
    if (manga.hasUpdate) {
      gridCover = Stack(
          fit: StackFit.expand,
          children: <Widget>[gridCover, buildHasUpdateIcon()]);
    }
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              width: width,
              height: width / 13 * 15,
              margin: EdgeInsets.only(bottom: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: gridCover,
              )),
          SizedBox(
            height: 20,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(manga.title,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: textColor)),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(manga.lastUpdateChapter.title,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor,
                      textBaseline: TextBaseline.alphabetic,
                    )),
              ),
              Text(source.name,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 12,color: textColor, textBaseline: TextBaseline.alphabetic))
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCover() {
    return MangaCoverImage(
      url: manga.coverImgUrl,
      source: source,
      fit: BoxFit.fitWidth,
      tagPrefix: tagPrefix,
    );
  }

  Widget buildHasUpdateIcon() {
    const body = const Positioned(
      child: const Text('NEW'),
    );
    return Positioned(
      right: -22,
      top: 5,
      child: Transform.rotate(
        angle: math.pi / 4,
        child: Container(
          height: 14,
          width: 70,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(blurRadius: 5.0, color: const Color(0xffdbdbdb))
            ],
            color: Colors.redAccent,
          ),
          child: const Text(
            'NEW',
            textAlign: TextAlign.center,
            style:
                const TextStyle(height: 1.5, color: Colors.white, fontSize: 8),
          ),
        ),
      ),
    );
  }
}

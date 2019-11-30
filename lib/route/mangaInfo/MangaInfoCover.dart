import 'package:flutter/material.dart';
import 'package:maxga/Utils/DateUtils.dart';
import 'package:maxga/model/Manga.dart';

typedef CoverImageBuilder = Widget Function(BuildContext context);

class MangaInfoCover extends StatelessWidget {
  final SimpleMangaInfo manga;
  final bool loadEnd;
  final CoverImageBuilder coverImageBuilder;

  final int  updateTime;

  const MangaInfoCover({Key key, this.manga, this.updateTime, this.loadEnd, this.coverImageBuilder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    var coverMessage;
    if (loadEnd) {
      coverMessage = buildCoverMessage();
    }
    return Container(
      height: deviceHeight / 2,
      child: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            child: coverImageBuilder(context),
          ),
          coverMessage,
        ]..removeWhere((el) => el == null),
      ),
    );
  }

  buildCoverMessage() {
    var messagePadding = EdgeInsets.only(left: 20, right: 20);
    var messageBoxPadding = EdgeInsets.only(bottom: 10);
    const coverStringColor = Color(0xffe6e6e6);
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
    var mangaTitle = Text(
                manga.title,
                style: TextStyle(color: Colors.white, fontSize: mangaTitleFontSize),
                textAlign: TextAlign.left,
              );
    var mangaUpdateTime = Text(
                '${manga.lastUpdateChapter.updateTime != null ? DateUtils.formatTime(timestamp: manga.lastUpdateChapter.updateTime, template: "yyyy-MM-dd") : ''}',
                style: TextStyle(color: coverStringColor, fontSize: subtitleTextSize),
                textAlign: TextAlign.left
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
              child: mangaTitle,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: mangaUpdateTime,
            ),
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child:  Row(
                            children: <Widget>[
                              const Text('作者: ',style: TextStyle(color: coverStringColor)),
                              CoverMessageTag(
                                child: Text(
                                  manga.author,
                                  style: TextStyle(color: coverStringColor, fontSize: subtitleTextSize),
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )

                            ],
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            const Text('标签: ',style: TextStyle(color: coverStringColor)),
                            ...manga.typeList.map((text) => CoverMessageTag(
                              child: Text(
                                text,
                                style: TextStyle(color: coverStringColor, fontSize: subtitleTextSize),
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                          ],
                        )
                      ],
                    )
                  ),
                  Text(
                    '来源: ${manga.source.name}',
                    style: TextStyle(color: coverStringColor, fontSize: subtitleTextSize),
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

class CoverMessageTag extends StatelessWidget {
  final Widget child;

  const CoverMessageTag({Key key, this.child}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 4, bottom: 4, left: 10, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Colors.white24,
      ),
      child: child,
    );
  }

}
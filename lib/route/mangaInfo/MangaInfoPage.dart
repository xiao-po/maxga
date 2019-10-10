import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/Utils/DateUtils.dart';
import 'package:maxga/http/repo/dmzj/DmzjDataRepo.dart';
import 'package:maxga/http/repo/manhuadui/ManhuaduiDataRepo.dart';
import 'package:maxga/model/Chapter.dart';
import 'package:maxga/model/Manga.dart';
import 'package:maxga/route/error-page/ErrorPage.dart';
import 'package:maxga/route/mangaInfo/MaganInfoWrapper.dart';
import 'package:maxga/route/mangaInfo/MangaInfoCover.dart';

import 'MangaChapeter.dart';
import 'MangaInfoIntro.dart';

class MangaInfoPage extends StatefulWidget {
  final int id;
  const MangaInfoPage({Key key, this.id, this.url}) : super(key: key);

  final String url;

  @override
  State<StatefulWidget> createState() => _MangaInfoPageState();
}

class _MangaInfoPageState extends State<MangaInfoPage> {
  var loading = 0;
  Manga manga;

  Chapter latestChapter;

  @override
  void initState()  {
    super.initState();

    initMangaInfo();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MangaInfoWrapper(
        title: manga != null ? manga.title : '',
        children: buildBody(),
      )
    );
  }


  List<Widget> buildBody() {

    switch(loading) {
      case 1 : {
        final String lastUpdate = latestChapter.updateTime != null ? DateUtils.formatTime(
            timestamp: latestChapter.updateTime,
            template: 'YYYY-MM-DD'
        ) : '';
        return  <Widget>[
          MangaInfoCover(manga: manga, updateTime: '最后更新：$lastUpdate',),
          MangaInfoIntro(manga: manga),
          MangaInfoChapter(manga: manga),
        ];
      }
      case 0 : {
        return [
          buildLoadPage()
        ];
      }
      default: {
        return [
          ErrorPage(
              "读取漫画信息发生了错误呢~~~"
          )
        ];
      }

    }
  }

  Widget buildLoadPage() {
    return Container(
      height: 300,
      child: Center(
        child: SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(strokeWidth: 2,),
        ),
      ),
    );
  }

  void initMangaInfo() async {
    try {
      manga = await ManhuaduiDataRepo().getMangaInfo(
        id: widget.id,
        url: widget.url,
      );
      loading = 1;
    } catch (e) {
      loading = -1;
    }


    latestChapter = manga.getLatestChapter();

    setState(() {});
  }
}

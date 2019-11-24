import 'package:connectivity/connectivity.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/Application.dart';
import 'package:maxga/Utils/MaxgaUtils.dart';
import 'package:maxga/Utils/DateUtils.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/model/Chapter.dart';
import 'package:maxga/model/Manga.dart';
import 'package:maxga/model/MangaReadProcess.dart';
import 'package:maxga/provider/HistoryProvider.dart';
import 'package:maxga/route/error-page/ErrorPage.dart';
import 'package:maxga/route/mangaInfo/MaganInfoWrapper.dart';
import 'package:maxga/route/mangaInfo/MangaInfoCover.dart';
import 'package:maxga/route/mangaViewer/MangaViewer.dart';
import 'package:maxga/service/MangaReadStorage.service.dart';

import 'MangaChapeter.dart';
import 'MangaInfoBottomBar.dart';
import 'MangaInfoIntro.dart';

enum _MangaInfoPageStatus {
  loading,
  over,
  error,
}

class MangaInfoPage extends StatefulWidget {
  final SimpleMangaInfo manga;
  final CoverImageBuilder coverImageBuilder;
  const MangaInfoPage({Key key,@required this.manga,@required this.coverImageBuilder}) : super(key: key);


  @override
  State<StatefulWidget> createState() => _MangaInfoPageState();
}

class _MangaInfoPageState extends State<MangaInfoPage> {
  _MangaInfoPageStatus loading = _MangaInfoPageStatus.loading;
  MangaReadProcess mangaReadProcess;
  List<Chapter> chapterList = [];

  String introduce;


  @override
  void initState() {
    super.initState();
    initMangaInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: buildBody());
  }

  Widget buildBody() {
    MangaInfoIntro mangaInfoIntro;
    MangaInfoChapter mangaInfoChapter;
    MangaInfoBottomBar mangaInfoBottomBar;
    bool loadOver = false;
    switch (loading) {
      case _MangaInfoPageStatus.over:
        {
          mangaInfoIntro = MangaInfoIntro(intro: introduce);
          mangaInfoChapter = MangaInfoChapter(
            manga: widget.manga,
            chapterList: chapterList,
            readStatus: mangaReadProcess,
            onClickChapter: (chapter) => enjoyMangaContent(chapter),
          );
          loadOver = true;
          mangaInfoBottomBar = MangaInfoBottomBar(
              onResume: () => onResumeProcess(), readed: mangaReadProcess != null);
          break;
        }
      case _MangaInfoPageStatus.error:
        {
          return ErrorPage("读取漫画信息发生了错误呢~~~");
        }
      default:
        {}
    }
    return MangaInfoWrapper(
      title: widget.manga?.title ?? '',
      children: [
        MangaInfoCover(
          manga: widget.manga,
          loadEnd: loadOver,
          coverImageBuilder: widget.coverImageBuilder,
//          updateTime: '最后更新：$lastUpdate',
        ),
        mangaInfoIntro ?? Container(),
        mangaInfoChapter ??  buildChapterLoading(),
      ],
      bottomBar: mangaInfoBottomBar ?? Container(),
    );
  }

  Row buildChapterLoading() {
    return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 60),
              child: SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          ]
      );
  }

  Widget buildLoadPage() {
    return Container(
      height: 300,
      child: Center(
        child: SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  void initMangaInfo() async {
    MaxgaDataHttpRepo repo = Application.getInstance().getMangaSource(key: widget.manga.source.key);
    try {
      final manga = await repo.getMangaInfo(
        id: widget.manga.id,
        url: widget.manga.infoUrl,
      );

      chapterList = manga.chapterList;
      introduce = manga.introduce;

      mangaReadProcess = await MangaReadStorageService.getMangaStatus(manga);
      await Future.delayed(Duration(milliseconds: 500));
      loading = _MangaInfoPageStatus.over;
    } catch (e) {
      print(e);
      loading = _MangaInfoPageStatus.error;
    }

    print(mangaReadProcess?.chapterId);
    if (mounted) {
      setState(() { });
    }
  }

  void enjoyMangaContent(Chapter chapter, {int imagePage = 0}) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MangaViewer(
                  manga: widget.manga,
                  currentChapter: chapter,
                  chapterList: chapterList,
                  initIndex: imagePage,
                )));
    mangaReadProcess = await MangaReadStorageService.getMangaStatus(widget.manga);
    HistoryProvider.getInstance().addToHistory(widget.manga);
  }

  onResumeProcess() {
    if (mangaReadProcess != null) {
      var chapter = chapterList
          .firstWhere((item) => item.id == mangaReadProcess.chapterId);
      this.enjoyMangaContent(chapter, imagePage: mangaReadProcess.imageIndex);
    } else {
      var chapter = getFirstChapter();
      this.enjoyMangaContent(chapter, imagePage: 0);
    }
  }

  Chapter getLatestChapter() {
    Chapter latestChapter;
    for(var chapter in chapterList) {
      if (latestChapter == null || latestChapter.order < chapter.order) {
        latestChapter = chapter;
      }
    }
    return latestChapter;
  }
  Chapter getFirstChapter() {
    Chapter firstChapter;
    for(var chapter in chapterList) {
      if (firstChapter == null || firstChapter.order > chapter.order) {
        firstChapter = chapter;
      }
    }
    return firstChapter;
  }


}

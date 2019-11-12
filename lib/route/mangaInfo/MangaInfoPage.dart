import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/Application.dart';
import 'package:maxga/Utils/DateUtils.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/model/Chapter.dart';
import 'package:maxga/model/Manga.dart';
import 'package:maxga/model/MangaReadProcess.dart';
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
  error
}

class MangaInfoPage extends StatefulWidget {
  final int id;


  const MangaInfoPage({Key key, @required this.url,@required  this.id}) : super(key: key);

  final String url;

  @override
  State<StatefulWidget> createState() => _MangaInfoPageState();
}


class _MangaInfoPageState extends State<MangaInfoPage> {
  _MangaInfoPageStatus loading = _MangaInfoPageStatus.loading;
  MangaReadProcess mangaReadProcess;
  Manga manga;

  Chapter latestChapter;

  @override
  void initState() {
    super.initState();
    initMangaInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: buildBody()
    );
  }

  Widget buildBody() {
    switch (loading) {
      case _MangaInfoPageStatus.over:
        {
          final String lastUpdate = latestChapter.updateTime != null
              ? DateUtils.formatTime(
                  timestamp: latestChapter.updateTime, template: 'YYYY-MM-DD')
              : '';
          return MangaInfoWrapper(
            title: manga != null ? manga.title : '',
            children: [
              MangaInfoCover(
                manga: manga,
                updateTime: '最后更新：$lastUpdate',
              ),
              MangaInfoIntro(manga: manga),
              MangaInfoChapter(
                  manga: manga,
                  readStatus: mangaReadProcess,
                  onClickChapter: (chapter) => enjoyMangaContent(chapter),
              ),
            ],
            bottomBar: MangaInfoBottomBar(
              onResume: () => onResumeProcess(),
                readed: mangaReadProcess != null
            ),
          );
        }
      case _MangaInfoPageStatus.loading:
        {
          return buildLoadPage();
        }
      default:
        {
          return ErrorPage("读取漫画信息发生了错误呢~~~");
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
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  void initMangaInfo() async {
    MaxgaDataHttpRepo repo = Application.getInstance().currentDataRepo;
    try {
      manga = await repo.getMangaInfo(
        id: widget.id,
        url: widget.url,
      );

      await initMangaReadProcess();

      loading = _MangaInfoPageStatus.over;
    } catch (e) {
      print(e);
      loading = _MangaInfoPageStatus.error;
    }

    latestChapter = manga.getLatestChapter();
    print(mangaReadProcess?.chapterId);
    setState(() {});
  }

  void enjoyMangaContent(Chapter chapter, {int imagePage = 1}) async {
    await Navigator.push(context, MaterialPageRoute(
        builder: (context) => MangaViewer(
          manga: manga,
          currentChapter: chapter,
        )
    ));
    initMangaReadProcess();
  }

  onResumeProcess() {
    if (mangaReadProcess != null ) {
      var chapter = manga.chapterList.firstWhere((item) => item.id == mangaReadProcess.chapterId);
      this.enjoyMangaContent(chapter, imagePage: mangaReadProcess.imageIndex);
    } else {
      var chapter = manga.getFirstChapter();
      this.enjoyMangaContent(chapter, imagePage: 0);
    }
  }

  Future<void> initMangaReadProcess() async {
    mangaReadProcess = await MangaReadStorageService.getMangaStatus(manga);
  }
}

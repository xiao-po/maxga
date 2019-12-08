import 'package:flutter/material.dart';
import 'package:maxga/Application.dart';
import 'package:maxga/MangaRepoPool.dart';
import 'package:maxga/Utils/MaxgaUtils.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/model/manga/Chapter.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/manga/MangaSource.dart';
import 'package:maxga/model/maxga/MangaReadProcess.dart';
import 'package:maxga/model/maxga/MangaViewerPopResult.dart';
import 'package:maxga/provider/HistoryProvider.dart';
import 'package:maxga/route/error-page/ErrorPage.dart';
import 'package:maxga/route/mangaInfo/MaganInfoWrapper.dart';
import 'package:maxga/route/mangaInfo/MangaInfoCover.dart';
import 'package:maxga/route/mangaViewer/MangaViewer.dart';
import 'package:maxga/service/MangaReadStorage.service.dart';
import 'package:provider/provider.dart';

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

  const MangaInfoPage(
      {Key key, @required this.manga, @required this.coverImageBuilder})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MangaInfoPageState();
}

class _MangaInfoPageState extends State<MangaInfoPage> {
  _MangaInfoPageStatus loading = _MangaInfoPageStatus.loading;
  ReadMangaStatus readMangaStatus;
  MangaSource source;
  List<Chapter> chapterList = [];

  String introduce;

  @override
  void initState() {
    super.initState();
    initMangaInfo();
    source =
        MangaRepoPool.getInstance().getMangaSourceByKey(widget.manga.sourceKey);
  }

  @override
  Widget build(BuildContext context) {
    Widget mangaInfoIntro;
    Widget mangaInfoChapter;
    MangaInfoBottomBar mangaInfoBottomBar;
    bool loadOver = false;
    switch (loading) {
      case _MangaInfoPageStatus.over:
        {
          mangaInfoIntro = MangaInfoIntro(intro: introduce);
          mangaInfoChapter = MangaInfoChapter(
            chapterList: chapterList,
            readStatus: readMangaStatus,
            onClickChapter: (chapter) => enjoyMangaContent(chapter),
          );
          loadOver = true;
          mangaInfoBottomBar = MangaInfoBottomBar(
            onResume: () => onResumeProcess(),
            readed: readMangaStatus.readChapterId != null,
            collected: readMangaStatus.collected,
            onCollect: () => collectManga(),
          );
          break;
        }
      case _MangaInfoPageStatus.error:
        {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(color: Colors.black45),
              elevation: 0,
              backgroundColor: Color(0xfffafafa),
            ),
            body: ErrorPage("读取漫画信息发生了错误呢~~~", onTap: () {
              print('error page on tap');
            }),
          );
        }
      case _MangaInfoPageStatus.loading:
        {
          mangaInfoIntro = MangaInfoIntroSkeleton();
          mangaInfoChapter = SkeletonMangaChapterGrid(colCount: 6);
          break;
        }
      default:
        {}
    }
    return Scaffold(
        body: MangaInfoWrapper(
      title: widget.manga?.title ?? '',
      appbarActions: <Widget>[
        IconButton(
          icon: Icon(Icons.share, color: Colors.white),
          onPressed: () {
            MaxgaUtils.shareUrl(readMangaStatus.infoUrl);
          },
        )
      ],
      children: [
        MangaInfoCover(
          manga: widget.manga,
          loadEnd: loadOver,
          source: source,
          coverImageBuilder: widget.coverImageBuilder,
        ),
        mangaInfoIntro,
        mangaInfoChapter ?? Container(),
      ],
      bottomBar: mangaInfoBottomBar ?? Container(),
    ));
  }

  Row buildChapterLoading() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Padding(
        padding: EdgeInsets.only(top: 60),
        child: SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      )
    ]);
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
    MaxgaDataHttpRepo repo =
        MangaRepoPool.getInstance().getRepo(key: widget.manga.sourceKey);
    try {
      final manga = await repo.getMangaInfo(
        id: widget.manga.id,
        url: widget.manga.infoUrl,
      );

      chapterList = manga.chapterList;
      introduce = manga.introduce;

      readMangaStatus =
          await MangaReadStorageService.getMangaStatus(widget.manga);
      await Future.delayed(Duration(milliseconds: 500));
      loading = _MangaInfoPageStatus.over;
    } catch (e) {
      print(e);
      loading = _MangaInfoPageStatus.error;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void enjoyMangaContent(Chapter chapter, {int imagePage = 0}) async {
    var result = await Navigator.push<MangaViewerPopResult>(
        context,
        MaterialPageRoute(
            builder: (context) => MangaViewer(
                  manga: widget.manga,
                  currentChapter: chapter,
                  chapterList: chapterList,
                  initIndex: imagePage,
                )));
    if (result.loadOver) {
      readMangaStatus.readChapterId = result.chapterId;
      readMangaStatus.readImageIndex = result.mangaImageIndex;
      await Future.wait([
        MangaReadStorageService.setMangaStatus(readMangaStatus),
        Provider.of<HistoryProvider>(context).addToHistory(widget.manga),
      ]);
      if (mounted) setState(() {});
    }
    MaxgaUtils.showStatusBar();
  }

  onResumeProcess() {
    if (readMangaStatus.readChapterId != null) {
      var chapter = chapterList
          .firstWhere((item) => item.id == readMangaStatus.readChapterId);
      this.enjoyMangaContent(chapter,
          imagePage: readMangaStatus.readImageIndex);
    } else {
      var chapter = getFirstChapter();
      this.enjoyMangaContent(chapter, imagePage: 0);
    }
  }

  Chapter getLatestChapter() {
    Chapter latestChapter;
    for (var chapter in chapterList) {
      if (latestChapter == null || latestChapter.order < chapter.order) {
        latestChapter = chapter;
      }
    }
    return latestChapter;
  }

  Chapter getFirstChapter() {
    Chapter firstChapter;
    for (var chapter in chapterList) {
      if (firstChapter == null || firstChapter.order > chapter.order) {
        firstChapter = chapter;
      }
    }
    return firstChapter;
  }

  collectManga() async {
    readMangaStatus.collected = !readMangaStatus.collected;
    await MangaReadStorageService.setMangaStatus(readMangaStatus);
    if (mounted) setState(() {});
  }
}

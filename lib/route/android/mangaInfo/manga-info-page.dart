import 'package:flutter/material.dart';
import 'package:maxga/base/delay.dart';
import 'package:maxga/http/repo/maxga-data-http-repo.dart';
import 'package:maxga/manga-repo-pool.dart';
import 'package:maxga/model/manga/chapter.dart';
import 'package:maxga/model/manga/manga-source.dart';
import 'package:maxga/model/manga/manga.dart';
import 'package:maxga/model/maxga/read-manga-status.dart';
import 'package:maxga/provider/public/collection-provider.dart';
import 'package:maxga/route/android/search/search-result-page.dart';
import 'package:maxga/service/manga-read-storage.service.dart';
import 'package:maxga/utils/maxga-utils.dart';

import '../mangaViewer/manga-viewer.dart';
import 'components/magan-info-wrapper.dart';
import 'components/manga-chapeter.dart';
import 'components/manga-info-bottom-bar.dart';
import 'components/manga-info-cover.dart';
import 'components/manga-info-intro.dart';
import 'error-page/manga-info-error-page.dart';

enum _MangaInfoPageStatus {
  loading,
  over,
  error,
}

class MangaInfoPage extends StatefulWidget {
  final String sourceKey;
  final String infoUrl;
  final String title;
  final CoverImageBuilder coverImageBuilder;

  const MangaInfoPage(
      {Key key,
      @required this.coverImageBuilder,
      @required this.sourceKey,
      @required this.infoUrl,
      @required this.title})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MangaInfoPageState();
}

class _MangaInfoPageState extends State<MangaInfoPage> {
  _MangaInfoPageStatus loading = _MangaInfoPageStatus.loading;
  ReadMangaStatus readMangaStatus;
  Manga manga;
  MangaSource source;
  bool isCollected;
  List<Chapter> chapterList = [];
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initInfo(url: widget.infoUrl, sourceKey: widget.sourceKey)
        .then((Manga manga) async {
      var isCollected = CollectionProvider.getInstance()
          .collectionMangaList
          .indexWhere((item) => item.infoUrl ==  widget.infoUrl) !=
          -1;
      if (mounted) {
        setState(() {
          this.isCollected = isCollected;
        });
      }
    });
    source = MangaRepoPool.getInstance().getMangaSourceByKey(widget.sourceKey);
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
          mangaInfoIntro = MangaInfoIntro(intro: manga.introduce);
          mangaInfoChapter = MangaInfoChapter(
            chapterList: chapterList,
            manga: manga,
            readStatus: readMangaStatus,
            onClickChapter: (chapter) => enjoyMangaContent(chapter),
          );
          loadOver = true;
          mangaInfoBottomBar = MangaInfoBottomBar(
            onResume: () => onResumeProcess(),
            isRead: readMangaStatus.chapterId != null,
            collected: isCollected,
            onCollect: () => collectManga(),
            onSearchMangaName: searchMangaName,
          );
          break;
        }
      case _MangaInfoPageStatus.error:
        {
          return MangaInfoErrorPage(
            source: source,
            title: widget.title,
            message: "读取漫画信息发生错误了呢~~~",
          );
        }
      case _MangaInfoPageStatus.loading:
        {
          mangaInfoIntro = MangaInfoIntroSkeleton();
          mangaInfoChapter = SkeletonMangaChapterGrid(colCount: 6);
          break;
        }
    }
    return Scaffold(
        key: scaffoldKey,
        body: MangaInfoWrapper(
          title: manga?.title ?? '',
          appbarActions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () => this.shareLink(),
            )
          ],
          children: [
            MangaInfoCover(
              manga: manga,
              loadEnd: loadOver,
              lastUpdateChapter: manga?.latestChapter ?? Chapter(),
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

  Future<Manga> _initInfo(
      {@required String sourceKey, @required String url}) async {
    MaxgaDataHttpRepo repo =
        MangaRepoPool.getInstance().getRepo(key: sourceKey);
    Manga manga;
    await Future.wait<dynamic>([
      Future.microtask(() async {
        try {
          manga = await repo.getMangaInfo(url);
          final Manga preMangaData =
              (await MangaStorageService.getMangaByUrl(url)) ?? manga;
          final ReadMangaStatus readMangaStatus =
              await MangaStorageService.getMangaStatusByUrl(url);
          final Manga resultMangaData = manga;
          chapterList = resultMangaData.chapterList;
          if (preMangaData.latestChapter.updateTime == null ||
              !preMangaData.latestChapter.updateTime
                  .isBefore(preMangaData.latestChapter.updateTime)) {
            await MangaStorageService.saveManga(resultMangaData);
          }
          loading = _MangaInfoPageStatus.over;
          this.manga = manga;
          this.readMangaStatus = readMangaStatus;
        } catch (e) {
          if (mounted) {
            setState(() {
              loading = _MangaInfoPageStatus.error;
              this.manga = null;
            });
          }
        }
      }),
      Future.delayed(Duration(milliseconds: 500))
    ]);
    return manga;
  }

  void enjoyMangaContent(Chapter chapter, {int imagePage = 0}) async {
    var result = await Navigator.push<ViewerReadProcess>(
        context,
        MaterialPageRoute(
            builder: (context) => MangaViewer(
                  manga: manga,
                  currentChapter: chapter,
                  chapterList: chapterList,
                  initIndex: imagePage,
                )));
    if (result != null) {
      readMangaStatus = readMangaStatus.copyWith(
          sourceKey: source.key,
          chapterId: result.chapter.id,
          pageIndex: result.pageIndex,
          updateTime: DateTime.now());
      await Future.wait([
        MangaStorageService.saveMangaStatus(readMangaStatus),
      ]);
      if (mounted) setState(() {});
    }
    MaxgaUtils.showStatusBar();
  }

  onResumeProcess() {
    if (readMangaStatus.chapterId != null) {
      var chapter = chapterList
          .firstWhere((item) => item.id == readMangaStatus.chapterId);
      this.enjoyMangaContent(chapter, imagePage: readMangaStatus.pageIndex);
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
    try {
      await Future.wait([
        CollectionProvider.getInstance()
            .setMangaCollectStatus(manga, isCollected: !isCollected),
      ]);
      if (mounted)
        setState(() {
          isCollected = !isCollected;
        });
    } catch (e) {
      print(e);
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: const Text('发生错误，收藏失败'),
      ));
    }
  }

  shareLink() async {
    MaxgaDataHttpRepo repo =
        MangaRepoPool.getInstance().getRepo(key: widget.sourceKey);
    String shareUrl = await repo.generateShareLink(manga);
    MaxgaUtils.shareUrl(shareUrl);
  }

  void searchMangaName() async {
    await AnimationDelay();
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return SearchResultPage(
        keyword: manga.title,
      );
    }));
  }
}

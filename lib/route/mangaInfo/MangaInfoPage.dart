import 'package:flutter/material.dart';
import 'package:maxga/MangaRepoPool.dart';
import 'package:maxga/Utils/MaxgaUtils.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/model/manga/Chapter.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/manga/MangaSource.dart';
import 'package:maxga/model/maxga/ReadMangaStatus.dart';
import 'package:maxga/model/maxga/MangaViewerPopResult.dart';
import 'package:maxga/provider/CollectionProvider.dart';
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
  final String sourceKey;
  final String infoUrl;
  final CoverImageBuilder coverImageBuilder;

  const MangaInfoPage(
      {Key key,
      @required this.coverImageBuilder,
      @required this.sourceKey,
      @required this.infoUrl}):
        super(key: key);


  @override
  State<StatefulWidget> createState() => _MangaInfoPageState();
}

class _MangaInfoPageState extends State<MangaInfoPage> {
  _MangaInfoPageStatus loading = _MangaInfoPageStatus.loading;
  ReadMangaStatus readMangaStatus;
  Manga manga;
  MangaSource source;
  List<Chapter> chapterList = [];

  @override
  void initState() {
    super.initState();
    _initInfo(
      url: widget.infoUrl,
      sourceKey: widget.sourceKey,);
    source = MangaRepoPool.getInstance()
        .getMangaSourceByKey(widget.sourceKey);
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
            readed: readMangaStatus.readChapterId != null,
            collected: readMangaStatus.isCollect,
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
              debugPrint('error page on tap');
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
          title: manga?.title ?? '',
          appbarActions: <Widget>[
            IconButton(
              icon: Icon(Icons.share, color: Colors.white),
              onPressed: () => this.shareLink(),
            )
          ],
          children: [
            MangaInfoCover(
              manga: manga,
              loadEnd: loadOver,
              lastUpdateChapter: manga?.chapterList?.first ?? Chapter(),
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

  Future<void> _initInfo({@required String sourceKey,
    @required String url}) async {
    MaxgaDataHttpRepo repo =
    MangaRepoPool.getInstance().getRepo(key: sourceKey);
    await Future.wait<dynamic>([
      Future.microtask(() async {
        try {
          final Manga manga = await repo.getMangaInfo(url);
          final Manga preMangaData = (await MangaStorageService.getMangaByUrl(
              url)) ?? manga;
          final ReadMangaStatus readMangaStatus = await MangaStorageService
              .getMangaStatusByUrl(url);
          // todo: 合并 chapter list
          final Manga resultMangaData = manga;
          chapterList = resultMangaData.chapterList;
          await MangaStorageService.saveManga(resultMangaData);
          // -----------
          //  await MangaDataRepository.insert(manga);
          //  Manga test = await MangaDataRepository.findByUrl(manga.infoUrl);
          // ------------
          loading = _MangaInfoPageStatus.over;
          this.manga = manga;
          this.readMangaStatus = readMangaStatus;
        } catch (e) {
          print(e);
          loading = _MangaInfoPageStatus.error;
        }
      }),
      Future.delayed(Duration(milliseconds: 500))
    ]);
    if (mounted) {
      setState(() {});
    }
  }
  

  void enjoyMangaContent(Chapter chapter, {int imagePage = 0}) async {
    Provider.of<HistoryProvider>(context).addToHistory(
        SimpleMangaInfo.fromMangaInfo(
            sourceKey: manga.sourceKey,
            author: manga.authors,
            id: manga.id,
            infoUrl: manga.infoUrl,
            status: manga.status,
            coverImgUrl: manga.coverImgUrl,
            title: manga.title,
            typeList: manga.typeList,
            lastUpdateChapter: chapterList[0])
    );
    var result = await Navigator.push<MangaViewerPopResult>(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MangaViewer(
                  manga: manga,
                  currentChapter: chapter,
                  chapterList: chapterList,
                  initIndex: imagePage,
                )));
    if (result.loadOver) {
      readMangaStatus.readChapterId = result.chapterId;
      readMangaStatus.readImageIndex = result.mangaImageIndex;
      await Future.wait([
        MangaStorageService.saveMangaStatus(readMangaStatus),

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
    try {
      await Future.wait([
        CollectionProvider.getInstance()
            .setMangaCollectStatus(
            manga, isCollected: !readMangaStatus.isCollect),
      ]);
      readMangaStatus.isCollect = !readMangaStatus.isCollect;
      if (mounted) setState(() {});
    } catch (e) {
      print(e);
      Scaffold.of(context).showSnackBar(SnackBar(
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
}

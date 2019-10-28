import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/Application.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/model/Chapter.dart';
import 'package:maxga/model/Manga.dart';
import 'package:maxga/route/error-page/ErrorPage.dart';
import 'package:maxga/route/mangaViewer/MangaTab.dart';
import 'package:maxga/route/mangaViewer/MangaViewerFutureView.dart';

class MangaViewer extends StatefulWidget {
  final Manga manga;
  final Chapter currentChapter;

  const MangaViewer({Key key, this.manga, this.currentChapter})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MangaViewerState();
}

class _MangaViewerState extends State<MangaViewer> {
  final mangaViewerKey = GlobalKey<ScaffoldState>();

  Timer chapterChangeTimer;
  Timer scrollEventTimer;
  Timer futureViewVisitableTimer;
  bool NEXT_PAGE_CHANGE_TRUST = true;

  Map<int, Chapter> cachedChapterData = {};
  int loadStatus = 0;
  bool mangaFutureViewVisitable = false;
  double mangaFutureViewOpacity = 0;
  List<Chapter> chapterList;
  final futureViewAnimationDuration =  Duration(milliseconds: 200);
  PageController tabController;
  Chapter currentChapter;
  Chapter preChapter;
  Chapter nextChapter;

  List<String> imagePageUrlList = <String>[];

  int _currentPageIndex = 0;

  get chapterImageIndex => _currentPageIndex - (preChapter != null ? 1 : 0);

  get chapterImageCount =>
      imagePageUrlList.length -
      (preChapter != null ? 1 : 0) -
      (nextChapter != null ? 1 : 0) - 1;

  @override
  void initState() {
    super.initState();
    currentChapter = widget.currentChapter;
    chapterList = widget.manga.chapterList.toList();
    chapterList.sort((a, b) => a.order.compareTo(b.order));
    initChapterState(currentChapter).then((val) {
      _currentPageIndex = preChapter != null ? 1 : 0;
      tabController = PageController(initialPage: _currentPageIndex);
      this.loadStatus = 1;

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (loadStatus) {
      case 0:
        {
          return Scaffold(
            body: buildLoadingPage(),
          );
        }
      case 1:
        {
          return Scaffold(
            backgroundColor: Colors.black,
            key: mangaViewerKey,
            body: Stack(
              children: <Widget>[
                NotificationListener<ScrollEndNotification>(
                  onNotification: (scrollNotification) => onPageViewScroll(scrollNotification),
                  child: GestureDetector(
                    onTapUp: (details) => dispatchTapUpEvent(details, context),
                    child: MangaTabView(
                      controller: tabController,
                      onPageChanged: (index) => changePage(index),
                      imgUrlList: imagePageUrlList,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: mangaFutureViewOpacity,
                  duration: futureViewAnimationDuration,
                  child: mangaFutureViewVisitable ? MangaFutureView(
                    onPageChange: (index) => changePage(
                        index.floor() + (preChapter != null ? 1 : 0),
                        shouldJump: true),
                    imageCount: chapterImageCount + 1,
                    pageIndex: chapterImageIndex < 1
                        ? 0
                        : (chapterImageIndex >= chapterImageCount
                            ? chapterImageCount
                            : chapterImageIndex),
                    title: currentChapter.title,
                  ) : null,
                )
              ],
            ),
          );
        }
      default:
        {
          return ErrorPage('加载失败');
        }
    }
  }

  buildLoadingPage() {
    return Align(
      child: SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<Chapter> getChapterData(Chapter chapter) async {
    if (cachedChapterData.containsKey(chapter.id)) {
      return cachedChapterData[chapter.id];
    } else {
      MaxgaDataHttpRepo repo = Application.getInstance().currentDataRepo;
      final result = await repo.getChapterImageList(chapter.url);
      chapter.imgUrlList = result;
      cachedChapterData.addAll({
        chapter.id: chapter
      });
      return chapter;
    }

  }

  dispatchTapUpEvent(TapUpDetails details, BuildContext context) {

    print('tap up');
    final width = MediaQuery.of(context).size.width;

    if (details.localPosition.dx / width > 0.33 &&
        details.localPosition.dx / width < 0.66) {

      updateFutureViewVisitable();

    } else if (details.localPosition.dx / width < 0.33) {
      goPrePage();
    } else if (details.localPosition.dx / width > 0.66) {
      goNextPage();
    }

    setState(() {});
  }

  void updateFutureViewVisitable() {
    mangaFutureViewOpacity = mangaFutureViewOpacity == 0 ? 1 : 0;
    if (futureViewVisitableTimer != null) {
      futureViewVisitableTimer.cancel();
    }
    if (mangaFutureViewOpacity == 1) {
      this.mangaFutureViewVisitable = !this.mangaFutureViewVisitable;
    } else {
      futureViewVisitableTimer = Timer(futureViewAnimationDuration, () {
        this.mangaFutureViewVisitable = !this.mangaFutureViewVisitable;
        setState(() {});
      });
    }

    setState(() {});
  }

  void toastMessage(String s, [TextAlign alignment = TextAlign.left]) {
    mangaViewerKey.currentState.removeCurrentSnackBar();
    mangaViewerKey.currentState.showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text(s, textAlign: alignment),
    ));
  }

  void zoomImageAction() {
    print('zoom image');
  }

  goPrePage() {
    if (_currentPageIndex != 0) {
      changePage(_currentPageIndex - 1, shouldJump: true);
    } else {
      if (preChapter != null) {
        _currentPageIndex = _currentPageIndex - 1;
        changeChapter();
      } else {
        toastMessage('已经是第一页了');
      }
    }
  }

  goNextPage() {
    if (_currentPageIndex != (chapterImageCount)) {
      changePage(_currentPageIndex + 1, shouldJump: true);
    } else {
      if (nextChapter != null) {
        _currentPageIndex = _currentPageIndex + 1;
        changeChapter();
      } else {
        toastMessage('已经是最后一页了');
      }
    }
  }

  changePage(int index, {bool shouldJump = false}) async {
    if (!NEXT_PAGE_CHANGE_TRUST) {
      NEXT_PAGE_CHANGE_TRUST = true;
      return null;
    }
    if (chapterChangeTimer != null) {
      print('chapterChangeTimer cancel');
      chapterChangeTimer.cancel();
    }
    _currentPageIndex = index;
    if (shouldJump) {
      tabController.jumpToPage(_currentPageIndex);
    }

    setState(() {});
  }

  Chapter getPreChapter(Chapter chapter) {
    int index = chapterList.indexWhere((item) => item.id == chapter.id);
    return index != 0 ? chapterList[index - 1] : null;
  }

  Chapter getNextChapter(Chapter chapter) {
    int index = chapterList.indexWhere((item) => item.id == chapter.id);
    return index != (chapterList.length - 1) ? chapterList[index + 1] : null;
  }

  Future<void> initChapterState(Chapter chapter) async {
    currentChapter = await getChapterData(chapter);
    final simplePreChapterData = getPreChapter(currentChapter);
    this.imagePageUrlList = [];
    if (simplePreChapterData != null) {
      preChapter = await getChapterData(simplePreChapterData);
      this.imagePageUrlList.add(preChapter.imgUrlList.last);
    } else {
      preChapter = null;
    }

    this.imagePageUrlList.addAll(currentChapter.imgUrlList);

    final simpleNextChapterData = getNextChapter(currentChapter);
    if (simpleNextChapterData != null) {
      nextChapter = await getChapterData(simpleNextChapterData);
      this.imagePageUrlList.add(nextChapter.imgUrlList.first);
    } else {
      nextChapter = null;
    }

    return null;
  }

  void changeChapter() async {
    print('changeChapter');
    if (_currentPageIndex == 0 && preChapter != null) {
      print('will visit preChapter');
      toastMessage('进入上一章节');
      await initChapterState(preChapter);
      _currentPageIndex = imagePageUrlList.length - 2;
      // TODO： notify just preChapter
      setState(() {});

      NEXT_PAGE_CHANGE_TRUST = false;
      tabController.jumpToPage(_currentPageIndex);
      chapterChangeTimer = null;
    }

    if (_currentPageIndex == (imagePageUrlList.length - 1) &&
        nextChapter != null) {
      print('will visit nextChapter');
      toastMessage('进入下一章节', TextAlign.right);
      await initChapterState(nextChapter);
      _currentPageIndex = 1;

      // TODO： notify just preChapter
      setState(() {});
      NEXT_PAGE_CHANGE_TRUST = false;
      tabController.jumpToPage(_currentPageIndex);
      chapterChangeTimer = null;
    }

  }

  onPageViewScroll(ScrollNotification scrollNotification) {
    if (scrollEventTimer != null) {
      scrollEventTimer.cancel();
      scrollEventTimer = null;
    }
    scrollEventTimer = Timer(
      Duration(milliseconds: 300),
        (){
          changeChapter();
        }
    );


    return true;
  }

}

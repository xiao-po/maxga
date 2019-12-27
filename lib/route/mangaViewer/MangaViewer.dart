import 'dart:async';
import 'dart:ui';

import 'package:connectivity/connectivity.dart';

import 'package:flutter/material.dart';
import 'package:maxga/MangaRepoPool.dart';
import 'package:maxga/Utils/MaxgaUtils.dart';
import 'package:maxga/base/setting/SettingValue.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/model/manga/Chapter.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/maxga/MangaViewerPopResult.dart';
import 'package:maxga/provider/SettingProvider.dart';
import 'package:maxga/route/error-page/ErrorPage.dart';
import 'package:maxga/route/mangaViewer/MangaTab.dart';
import 'package:maxga/route/mangaViewer/baseComponent/MangaViewerFutureView.dart';
import 'package:provider/provider.dart';

import 'MangaStatusBar.dart';

enum _MangaViewerLoadState { checkNetState, loadingMangaData, over, error }

enum _PageChangeOrigin { onTap, scroll, none }

class MangaViewer extends StatefulWidget {
  final Manga manga;
  final Chapter currentChapter;
  final List<Chapter> chapterList;
  final int initIndex;

  const MangaViewer(
      {Key key,
      this.manga,
      this.currentChapter,
      this.initIndex = 0,
      this.chapterList})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MangaViewerState();
}

class _MangaViewerState extends State<MangaViewer> {
  final mangaViewerKey = GlobalKey<ScaffoldState>();
  final futureViewAnimationDuration = Duration(milliseconds: 200);
  MaxgaDataHttpRepo dataHttpRepo;
  List<Chapter> chapterList;
  PageController tabController;

  Map<int, Chapter> cachedChapterData = {};
  bool isOnScroll = false;
  Chapter currentChapter;
  Chapter preChapter;
  Chapter nextChapter;

  _PageChangeOrigin _pageChangeOrigin = _PageChangeOrigin.none;
  _MangaViewerLoadState loadStatus = _MangaViewerLoadState.loadingMangaData;

  Timer scrollEventTimer;
  Timer futureViewVisitableTimer;

  bool loadingChapter = false;
  List<String> imagePageUrlList = <String>[];
  bool mangaFutureViewVisitable = false;
  double mangaFutureViewOpacity = 0;

  int _currentPageIndex = 0;

  int get pageOffsetFix => preChapter != null ? 1 : 0;

  int get chapterImageIndex => _currentPageIndex - (pageOffsetFix);

  int get chapterImageCount =>
      imagePageUrlList.length - (pageOffsetFix) - (nextChapter != null ? 1 : 0);

  int get radioPageIndex {
    return chapterImageIndex < 1
        ? 0
        : (chapterImageIndex >= (chapterImageCount - 1)
            ? (chapterImageCount - 1)
            : chapterImageIndex);
  }

  @override
  void initState() {
    super.initState();
    MaxgaUtils.hiddenStatusBar();
    dataHttpRepo =
        MangaRepoPool.getInstance().getRepo(key: widget.manga.sourceKey);
    Connectivity().checkConnectivity().then((connectivityResult) async {
      final readOnWiFi = Provider.of<SettingProvider>(context)
          .getItem(MaxgaSettingItemType.readOnlyOnWiFi);
      if (connectivityResult == ConnectivityResult.wifi ||
          readOnWiFi.value == '0') {
        initMangaViewer();
      } else {
        setState(() {
          loadStatus = _MangaViewerLoadState.checkNetState;
        });
      }
    });
  }

  void initMangaViewer() async {
    loadStatus = _MangaViewerLoadState.loadingMangaData;
    setState(() {});
    try {
      currentChapter = widget.currentChapter;
      chapterList = widget.chapterList.toList();
      chapterList.sort((a, b) => a.order.compareTo(b.order));
      final simplePreChapterData = getPreChapter(currentChapter);
      final simpleNextChapterData = getNextChapter(currentChapter);
      final resultChapterList = await Future.wait<Chapter>([
        getChapterData(simplePreChapterData),
        getChapterData(currentChapter),
        getChapterData(simpleNextChapterData),
      ]);
      Chapter preChapterData = resultChapterList[0];
      Chapter currentChapterData = resultChapterList[1];
      Chapter nextChapterData = resultChapterList[2];

      if (mounted) {
        setState(() {
          nextChapter = nextChapterData;
          preChapter = preChapterData;
          currentChapter = currentChapterData;
          this.imagePageUrlList = getImagePageUrlListFormChapter();
          _currentPageIndex = widget.initIndex + (pageOffsetFix);
          tabController = PageController(initialPage: _currentPageIndex);
          this.loadStatus = _MangaViewerLoadState.over;
        });
      }
    } catch (e) {
      debugPrint(e.message);
      if (mounted) {
        setState(() {
          this.loadStatus = _MangaViewerLoadState.error;
        });
      }
    }
  }

  List<String> getImagePageUrlListFormChapter() {
    List<String> imageUrlList = [];
    if (preChapter != null) {
      imageUrlList.add(preChapter.imgUrlList.last);
    }
    imageUrlList.addAll(currentChapter.imgUrlList);
    if (nextChapter != null) {
      imageUrlList.add(nextChapter.imgUrlList.first);
    }
    return imageUrlList;
  }

  @override
  Widget build(BuildContext context) {
    AppBar appbar;
    Widget body;
    switch (loadStatus) {
      case _MangaViewerLoadState.loadingMangaData:
        {
          appbar = AppBar(
            backgroundColor: Colors.transparent,
            leading: BackButton(
              color: Colors.white,
            ),
          );
          body = buildLoadingPage();
          break;
        }
      case _MangaViewerLoadState.over:
        {
          body = Stack(
            children: <Widget>[
              NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) =>
                    handleTabViewScroll(scrollNotification),
                child: GestureDetector(
                  onTapUp: (details) => dispatchTapUpEvent(details, context),
                  child: MangaTabView(
                    source: dataHttpRepo.mangaSource,
                    controller: tabController,
                    hasPrechapter: preChapter != null,
                    imgUrlList: imagePageUrlList,
                  ),
                ),
              ),
              MangaStatusBar(currentChapter, chapterImageIndex + 1),
              AnimatedOpacity(
                opacity: mangaFutureViewOpacity,
                duration: futureViewAnimationDuration,
                child: mangaFutureViewVisitable
                    ? MangaFeatureView(
                        onPageChange: (index) =>
                            changePage(index.floor() + (pageOffsetFix)),
                        imageCount: chapterImageCount,
                        pageIndex: radioPageIndex,
                        title: currentChapter.title,
                      )
                    : null,
              ),
            ],
          );
          break;
        }
      case _MangaViewerLoadState.checkNetState:
        appbar = buildAppbarOnOtherStatus();
        body = buildCheckNetStatePage();
        break;
      case _MangaViewerLoadState.error:
        {
          appbar = buildAppbarOnOtherStatus();
          body = ErrorPage('加载失败');
          break;
        }
    }

    return WillPopScope(
      child: Scaffold(
        key: mangaViewerKey,
        appBar: appbar,
        backgroundColor: Colors.black,
        body: body,
      ),
      onWillPop: () => onBack(),
    );
  }

  AppBar buildAppbarOnOtherStatus() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: BackButton(),
    );
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
    if (chapter == null) {
      return null;
    }
    if (cachedChapterData.containsKey(chapter.id)) {
      return cachedChapterData[chapter.id];
    } else {
      final result = await dataHttpRepo.getChapterImageList(chapter.url);
      chapter.imgUrlList = result;
      cachedChapterData.addAll({chapter.id: chapter});
      return chapter;
    }
  }

  dispatchTapUpEvent(TapUpDetails details, BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (details.localPosition.dx / width > 0.33 &&
        details.localPosition.dx / width < 0.66) {
      updateFutureViewVisitable();
    } else {
      _pageChangeOrigin = _PageChangeOrigin.onTap;
      if (details.localPosition.dx / width < 0.33) {
        changePage(_currentPageIndex - 1);
      } else if (details.localPosition.dx / width > 0.66) {
        changePage(_currentPageIndex + 1);
      }
      Future.delayed(Duration(milliseconds: 100))
          .then((value) => _pageChangeOrigin = _PageChangeOrigin.none);
    }
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
        setState(() {
          this.mangaFutureViewVisitable = !this.mangaFutureViewVisitable;
        });
      });
    }

    setState(() {});
  }

  void toastMessage(String s, [TextAlign alignment = TextAlign.left]) {
    mangaViewerKey.currentState.hideCurrentSnackBar();
    mangaViewerKey.currentState.showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text(s, textAlign: alignment),
    ));
  }

  changePage(int index) async {
    if (index < 0 && preChapter == null) {
      toastMessage('已经是第一页了');
      return;
    } else if (index > (imagePageUrlList.length - 1) && nextChapter == null) {
      toastMessage('已经是最后一页了', TextAlign.right);
      return;
    }

    _currentPageIndex = index;
    tabController.jumpToPage(_currentPageIndex);
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
    this.imagePageUrlList = [];

    return null;
  }

  void changeChapter() async {
    if (_currentPageIndex == 0) {
      if (preChapter == null) {
        toastMessage('已经是第一页了');
        return;
      }
      toastMessage('正在加载上一章节');
      final simplePreChapterData = getPreChapter(nextChapter);
      if (mounted) {
        setState(() {
          loadingChapter = true;
        });
      } else {
        return null;
      }
      var preChapterData = await getChapterData(simplePreChapterData);
      if (mounted && !isOnScroll && _currentPageIndex == 0) {
        toastMessage('进入上一章节');
        setState(() {
          nextChapter = currentChapter;
          currentChapter = preChapter;
          preChapter = preChapterData;
          imagePageUrlList = getImagePageUrlListFormChapter();
          _currentPageIndex = imagePageUrlList.length - 2;
          _pageChangeOrigin = _PageChangeOrigin.scroll;
          loadingChapter = false;
        });
        tabController.jumpToPage(_currentPageIndex);
        Future.delayed(Duration(milliseconds: 100))
            .then((v) => _pageChangeOrigin = _PageChangeOrigin.none);
      } else {
        return null;
      }
    } else if (_currentPageIndex == (imagePageUrlList.length - 1)) {
      if (nextChapter == null) {
        toastMessage('已经是最后一页了', TextAlign.right);
        return;
      }

      loadingChapter = true;
      toastMessage('正在加载下一章节', TextAlign.right);
      if (mounted) {
        setState(() {
          loadingChapter = true;
        });
      } else {
        return null;
      }
      final simpleNextChapterData = getNextChapter(nextChapter);
      final nextChapterData = await getChapterData(simpleNextChapterData);
      if (mounted &&
          !isOnScroll &&
          _currentPageIndex == (imagePageUrlList.length - 1)) {
        toastMessage('进入下一章节', TextAlign.right);
        setState(() {
          preChapter = currentChapter;
          currentChapter = nextChapter;
          _pageChangeOrigin = _PageChangeOrigin.scroll;
          nextChapter = nextChapterData;
          imagePageUrlList = getImagePageUrlListFormChapter();
          _currentPageIndex = pageOffsetFix;
          loadingChapter = false;
        });
        Future.delayed(Duration(milliseconds: 100))
            .then((v) => _pageChangeOrigin = _PageChangeOrigin.none);
      } else {
        return null;
      }
      tabController.jumpToPage(_currentPageIndex);
    }
  }

  onPageViewScroll(ScrollNotification scrollNotification) {
    final tabControllerPage = tabController.page.floor();
    _currentPageIndex = tabControllerPage;
    changeChapter();
    if (tabControllerPage > pageOffsetFix &&
        _PageChangeOrigin.none == _pageChangeOrigin) {
      setState(() {});
    }
    return true;
  }

  @override
  void dispose() {
    super.dispose();
    tabController?.dispose();
  }

  onBack() {
    if (loadStatus == _MangaViewerLoadState.over) {
      Navigator.pop<MangaViewerPopResult>(
          context,
          MangaViewerPopResult(
              loadOver: loadStatus == _MangaViewerLoadState.over,
              mangaImageIndex: _currentPageIndex - (pageOffsetFix),
              chapterId: currentChapter.id));
    } else {
      Navigator.pop<MangaViewerPopResult>(
          context,
          MangaViewerPopResult(
            loadOver: loadStatus == _MangaViewerLoadState.over,
          ));
    }
    return Future.value(false);
  }

  Widget buildCheckNetStatePage() {
    return buildCenterContainer(
      children: [
        buildCenterText('检测到你现在正使用移动网络'),
        buildCenterText('是否继续阅读？'),
        OutlineButton(
            borderSide: BorderSide(color: Colors.white),
            highlightedBorderColor: Colors.white,
            child: const Text('继续阅读',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center),
            onPressed: () {
              initMangaViewer();
            }),
      ],
    );
  }

  Container buildCenterContainer({List<Widget> children}) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }

  Widget buildCenterText(String text) => Padding(
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );

  handleTabViewScroll(ScrollNotification scrollNotification) {
    if (scrollNotification is ScrollEndNotification) {
      isOnScroll = false;
      onPageViewScroll(scrollNotification);
    } else if (scrollNotification is ScrollStartNotification) {
      isOnScroll = true;
    }
  }
}

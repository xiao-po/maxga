import 'dart:async';
import 'dart:ui';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:maxga/MangaRepoPool.dart';
import 'package:maxga/Utils/MaxgaUtils.dart';
import 'package:maxga/base/delay.dart';
import 'package:maxga/constant/SettingValue.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/model/manga/Chapter.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/provider/public/SettingProvider.dart';
import 'package:maxga/route/error-page/ErrorPage.dart';
import 'package:provider/provider.dart';

import '../mangaViewer/MangaImage.dart';
import '../mangaViewer/components/base/MangaViewerFutureView.dart';
import 'MangaStatusBar.dart';
import 'MangaTab.dart';

enum _MangaViewerLoadState { checkNetState, loadingMangaData, over, error }

enum _ChangeChapterAction {
  loadNextChapter,
  loadPreviousChapter,
  goNextChapter,
  goPreviousChapter,
  firstImage,
  lastImage,
  none
}

enum _ChapterUpdateOrigin { onTap, scroll, none }

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

  PageController pageController;

//  ItemScrollController itemScrollController;
//  ItemPositionsListener positionsListener = ItemPositionsListener.create();

  int chapterIndex;
  Map<int, Chapter> cachedChapterData = {};
  bool isOnScroll = false;
  Chapter currentChapter;

  Chapter get preChapter =>
      chapterIndex != 0 ? chapterList[chapterIndex - 1] : null;

  Chapter get nextChapter => chapterIndex != (chapterList.length - 1)
      ? chapterList[chapterIndex + 1]
      : null;

  _ChapterUpdateOrigin _chapterUpdateOrigin = _ChapterUpdateOrigin.none;
  _MangaViewerLoadState loadStatus = _MangaViewerLoadState.loadingMangaData;

  Timer futureViewVisitableTimer;
  bool mangaFutureViewVisitable = false;
  double mangaFutureViewOpacity = 0;

  int _pageIndex = 0;

  int get pageIndex => _pageIndex;

  set pageIndex(val) {
    _pageIndex = val;
    pageKey = UniqueKey();
    if (viewerPageStatus != null) {
      viewerPageStatus.pageIndex = (val - pageOffsetFix);
    }
  }

  List<Chapter> onPageListChapters = [];
  List<String> imagePageUrlList = <String>[];

  Key chapterChangeKey;

  int _pageOffsetFix = 0;

  int get pageOffsetFix {
    if (viewerPageStatus != null && chapterChangeKey == viewerPageStatus.key) {
      return _pageOffsetFix;
    } else {
      final index =
          onPageListChapters.indexWhere((el) => currentChapter.url == el.url);
      var length = 0;
      for (var i = 0; i < index; i++) {
        length += onPageListChapters[i].imgUrlList.length;
      }
      _pageOffsetFix = length;
      chapterChangeKey = viewerPageStatus?.key ?? UniqueKey();
      return length;
    }
  }

  ViewerReadProcess viewerPageStatus;

  int get viewerImageIndex => pageIndex - (pageOffsetFix);

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
//    positionsListener.itemPositions.addListener(() {
//      if (!isOnScroll) {
//        return null;
//      }
//      var positions = positionsListener.itemPositions.value;
//      int min;
//      int max;
//      if (positions.isNotEmpty) {
//        min = positions
//            .where((ItemPosition position) => position.itemTrailingEdge > 0)
//            .reduce((ItemPosition min, ItemPosition position) =>
//        position.itemTrailingEdge < min.itemTrailingEdge
//            ? position
//            : min)
//            .index;
//        max = positions
//            .where((ItemPosition position) => position.itemLeadingEdge < 1)
//            .reduce((ItemPosition max, ItemPosition position) =>
//        position.itemLeadingEdge > max.itemLeadingEdge
//            ? position
//            : max)
//            .index;
//        this.onPageViewScroll(min, max);
//      }
//    });
    setState(() {});
    try {
      chapterList = widget.chapterList
          .map((item) => Chapter.fromJson(item.toJson()))
          .toList()
            ..sort((a, b) => a.order.compareTo(b.order));
      chapterIndex =
          chapterList.indexWhere((el) => el.url == widget.currentChapter.url);
      currentChapter = chapterList[chapterIndex];
      final resultChapterList = await Future.wait([
        getChapterData(currentChapter),
        getChapterData(preChapter),
        getChapterData(nextChapter),
        AnimationDelay(),
      ]);
      Chapter currentChapterData = resultChapterList[0] as Chapter;

      if (mounted) {
        setState(() {
          currentChapter = currentChapterData;
          this.imagePageUrlList.addAll(currentChapter.imgUrlList);
          this.onPageListChapters.add(currentChapter);
          pageIndex = widget.initIndex;
          // ---------------
//          itemScrollController = ItemScrollController();
          // ---------------
          pageController = PageController(initialPage: pageIndex);

          viewerPageStatus =
              ViewerReadProcess(currentChapterData, viewerImageIndex);
          this.loadStatus = _MangaViewerLoadState.over;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          this.loadStatus = _MangaViewerLoadState.error;
        });
      }
      rethrow;
    }
  }

  List<String> getImagePageUrlListFormChapter() {
    List<String> imageUrlList = [];
    if (preChapter != null) {
      imageUrlList.addAll(preChapter.imgUrlList);
    }
    imageUrlList.addAll(currentChapter.imgUrlList);
    if (nextChapter != null) {
      imageUrlList.addAll(nextChapter.imgUrlList);
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
          var tabMangaViewer = MangaTabView(
              controller: pageController,
              hasPrechapter: preChapter != null,
              itemCount: imagePageUrlList.length,
              itemBuilder: (context, index) => Tab(
                child: MangaImage(
                  url: imagePageUrlList[index],
                  headers: dataHttpRepo.mangaSource.headers,
                  index: index - pageOffsetFix + 1,
                ),
              )
          );
//          var tabMangaViewer = MangaListViewer(
//            itemPositionsListener: positionsListener,
//            imageUrlList: imagePageUrlList,
//            itemScrollController: itemScrollController,
//            initialScrollIndex: pageIndex,
//            headers: dataHttpRepo.mangaSource.headers,
//          );
          body = Stack(
            children: <Widget>[
              NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) =>
                      handleTabViewScroll(scrollNotification),
                  child: GestureDetector(
                    onTapUp: (details) => dispatchTapUpEvent(details, context),
                    child: tabMangaViewer,
                  )),
              MangaStatusBar(currentChapter, viewerPageStatus.pageIndex + 1),
              AnimatedOpacity(
                opacity: mangaFutureViewOpacity,
                duration: futureViewAnimationDuration,
                child: mangaFutureViewVisitable
                    ? MangaFeatureView(
                        onPageChange: (index) =>
                            changePage(index.floor() + (pageOffsetFix)),
                        imageCount: viewerPageStatus.chapter.imgUrlList.length,
                        pageIndex: viewerPageStatus.pageIndex,
                        title: viewerPageStatus.chapter.title,
                      )
                    : null,
              )
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

  Future<Chapter> getChapterData(
    Chapter chapter, {
    void Function() onLoad,
  }) async {
    if (chapter == null) {
      return null;
    }
    if (cachedChapterData.containsKey(chapter.id)) {
      return cachedChapterData[chapter.id];
    } else {
      if (onLoad != null) {
        onLoad();
      }
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
      if (details.localPosition.dx / width < 0.33) {
        goPreviousPage();
      } else if (details.localPosition.dx / width > 0.66) {
        goNextPage();
      }
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

  goNextPage() {
    int target = pageIndex + 1;
    var action = checkIndexStatus(pageIndex, pageIndex);
    bool canJump = true;
    if (action == _ChangeChapterAction.lastImage) {
      canJump = false;
      toastMessage('已经是最后一页了', TextAlign.right);
    }
    if (canJump) {
      changePage(target);
    }
  }
  
  goPreviousPage() {
    int target = pageIndex - 1;
    var action = checkIndexStatus(pageIndex, pageIndex);
    bool canJump = true;
    if (action == _ChangeChapterAction.firstImage) {
      canJump = false;
      toastMessage('已经是第一页了');
    }
    if (canJump) {
      changePage(target);
    }
  }

  changePage(int target) async {
    if (mounted) {
      setState(() {
        pageIndex = target;
        pageController.jumpToPage(target);
      });
    }
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

  Key pageKey;


  bool isChapterLoad(Chapter willLoadChapter) =>
      this
          .onPageListChapters
          .indexWhere((el) => willLoadChapter.url == el.url) !=
      -1;

  onPageViewScroll(int min, int max) async {
    if (_chapterUpdateOrigin == _ChapterUpdateOrigin.none) {
      setState(() {
        pageIndex = min;
      });
    }
    var act = checkIndexStatus(min, max);
    Key fireKey = pageKey;
    switch (act) {
      case _ChangeChapterAction.loadNextChapter:
        {
          if (!mounted && pageKey != null) {
            return null;
          }
          final nextChapterData = await getChapterData(nextChapter, onLoad: () {
            toastMessage('正在加载下一章节', TextAlign.right);
          });
          if (!mounted && pageKey != null) {
            return null;
          }
          if (!isOnScroll && pageKey == fireKey) {
            setState(() {
              if (this.onPageListChapters.indexOf(nextChapter) == -1) {
                toastMessage('加载完毕', TextAlign.right);
                this.onPageListChapters.add(nextChapterData);
                viewerPageStatus.key = UniqueKey();
                imagePageUrlList.addAll(nextChapterData.imgUrlList);
              }
              _chapterUpdateOrigin = _ChapterUpdateOrigin.scroll;
            });
            Future.delayed(Duration(milliseconds: 50)).then((v) {
              _chapterUpdateOrigin = _ChapterUpdateOrigin.none;
            });
          } else {
            pageKey = null;
          }
        }
        break;
      case _ChangeChapterAction.loadPreviousChapter:
        {
          var willLoadChapter = preChapter;
          if (!mounted && pageKey != null) {
            return null;
          }
          var preChapterData =
              await getChapterData(willLoadChapter, onLoad: () {
            toastMessage('正在加载上一章节');
          });
          if (!mounted && pageKey != null) {
            return null;
          }
          if (!isOnScroll && pageKey == fireKey) {
            if (this.onPageListChapters.indexOf(preChapterData) == -1) {
              setState(() {
                toastMessage('加载完毕', TextAlign.left);
                this.onPageListChapters.insert(0, preChapterData);
                imagePageUrlList.insertAll(0, preChapterData.imgUrlList);
                viewerPageStatus.key = UniqueKey();
                pageIndex += preChapterData.imgUrlList.length;
                _chapterUpdateOrigin = _ChapterUpdateOrigin.scroll;
              });
            }
            pageController.jumpToPage(pageIndex);
            Future.delayed(Duration(milliseconds: 50)).then((v) {
              setState(() {
                _chapterUpdateOrigin = _ChapterUpdateOrigin.none;
              });
            });
          } else {
            pageKey = null;
          }
          break;
        }
      case _ChangeChapterAction.goNextChapter:
        setState(() {
          currentChapter = nextChapter;
          chapterIndex++;
          viewerPageStatus = ViewerReadProcess(currentChapter, 0);
        });
        break;
      case _ChangeChapterAction.goPreviousChapter:
        setState(() {
          currentChapter = preChapter;
          chapterIndex--;
          viewerPageStatus = ViewerReadProcess(
              currentChapter, currentChapter.imgUrlList.length - 1);
        });
        break;
      case _ChangeChapterAction.firstImage:
        toastMessage('已经是第一页了');
        break;
      case _ChangeChapterAction.lastImage:
        toastMessage('已经是最后一页了', TextAlign.right);
        break;
      case _ChangeChapterAction.none:
        break;
    }

    return true;
  }

  @override
  void dispose() {
    super.dispose();
    pageController?.dispose();
  }

  onBack() {
    if (loadStatus == _MangaViewerLoadState.over) {
      Navigator.pop<ViewerReadProcess>(context, viewerPageStatus);
    } else {
      Navigator.pop<ViewerReadProcess>(context, viewerPageStatus);
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
      final tabControllerPage = pageController.page.floor();
      onPageViewScroll(tabControllerPage, tabControllerPage);
    } else if (scrollNotification is ScrollStartNotification) {
      isOnScroll = true;
    }
  }


  _ChangeChapterAction checkIndexStatus(int min,int max) {
    if (nextChapter == null && max == (imagePageUrlList.length - 1)) {
      return _ChangeChapterAction.lastImage;
    } else if (preChapter == null && min == 0) {
      return _ChangeChapterAction.firstImage;
    } else if (min < pageOffsetFix) {
      return _ChangeChapterAction.goPreviousChapter;
    } else if (min <= (pageOffsetFix) && preChapter != null) {
      return _ChangeChapterAction.loadPreviousChapter;
    } else if (max ==
        (pageOffsetFix + currentChapter.imgUrlList.length)) {
      return _ChangeChapterAction.goNextChapter;
    } else if (max == (imagePageUrlList.length - 1)) {
      return _ChangeChapterAction.loadNextChapter;
    } else {
      return _ChangeChapterAction.none;
    }
  }


}

class AllowMultipleGestureRecognizer extends TapGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}

class ViewerReadProcess {
  Chapter chapter;
  int pageIndex;
  Key key;

  ViewerReadProcess(this.chapter, this.pageIndex) : key = UniqueKey();
}

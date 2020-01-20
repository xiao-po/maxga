import 'dart:async';
import 'dart:ui';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/gestures.dart';
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
import 'package:maxga/route/mangaViewer/MangaImage.dart';
import 'package:maxga/route/mangaViewer/components/base/MangaViewerFutureView.dart';
import 'package:provider/provider.dart';

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
  PageController tabController;

  int chapterIndex;
  Map<int, Chapter> cachedChapterData = {};
  bool isOnScroll = false;
  Chapter currentChapter;

  Chapter get preChapter => chapterIndex != 0 ? chapterList[chapterIndex - 1] : null;

  Chapter get nextChapter => chapterIndex != (chapterList.length - 1) ? chapterList[chapterIndex + 1] : null;

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

  int currentChapterIndexInImageList;

  List<Chapter> onPageListChapters = [];
  List<String> imagePageUrlList = <String>[];

  Key chapterChangeKey;
  int _pageOffsetFix = 0;

  int get pageOffsetFix {
    if (viewerPageStatus != null &&
        chapterChangeKey == viewerPageStatus.key) {
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
    setState(() {});
    try {
      currentChapter = widget.currentChapter;
      chapterList = widget.chapterList
          .map((item) => Chapter.fromJson(item.toJson()))
          .toList()
            ..sort((a, b) => a.order.compareTo(b.order));
      chapterIndex =
          chapterList.indexWhere((el) => el.url == currentChapter.url);
      final resultChapterList = await Future.wait<Chapter>([
        getChapterData(currentChapter),
        getChapterData(preChapter),
        getChapterData(nextChapter),
        Future.delayed(Duration(milliseconds: 300)),
      ]);
      Chapter currentChapterData = resultChapterList[0];

      if (mounted) {
        setState(() {
          currentChapter = currentChapterData;
          this.imagePageUrlList.addAll(currentChapter.imgUrlList);
          this.onPageListChapters.add(currentChapter);
          pageIndex = widget.initIndex;
          tabController = PageController(initialPage: pageIndex);

          viewerPageStatus = ViewerReadProcess(currentChapterData, viewerImageIndex);
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
          var tabMangaViewer = NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) =>
                  handleTabViewScroll(scrollNotification),
              child: GestureDetector(
                onTapUp: (details) => dispatchTapUpEvent(details, context),
                child: MangaTabView(
                    controller: tabController,
                    hasPrechapter: preChapter != null,
                    children: imagePageUrlList
                        .map((item) => Tab(
                              child: MangaImage(
                                url: item,
                                headers: dataHttpRepo.mangaSource.headers,
                                index: viewerImageIndex + 1,
                              ),
                            ))
                        .toList()),
              ));
//          var tabMangaViewer = RawGestureDetector(
//            gestures: {
//              AllowMultipleGestureRecognizer: GestureRecognizerFactoryWithHandlers<
//                  AllowMultipleGestureRecognizer>(
//                    () => AllowMultipleGestureRecognizer(),
//                    (AllowMultipleGestureRecognizer instance) {
//                  instance.onTapUp = (details) => dispatchTapUpEvent(details, context);
//                },
//              )
//            },
//            child:  MangaListViewer(
//              imageUrlList: imagePageUrlList,
//              headers: dataHttpRepo.mangaSource.headers,
//            ),
//          );
          body = Stack(
            children: <Widget>[
              tabMangaViewer,
              MangaStatusBar(currentChapter, viewerPageStatus.pageIndex + 1),
              AnimatedOpacity(
                  opacity: mangaFutureViewOpacity,
                  duration: futureViewAnimationDuration,
                  child: mangaFutureViewVisitable
                      ? MangaFeatureView(
                    onPageChange: (index) =>
                        changePage(index.floor() + (pageOffsetFix)),
                    imageCount:
                    viewerPageStatus.chapter.imgUrlList.length,
                    pageIndex: viewerPageStatus.pageIndex,
                    title: viewerPageStatus.chapter.title,
                  ): null,
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
    print(pageIndex);
    final width = MediaQuery.of(context).size.width;

    if (details.localPosition.dx / width > 0.33 &&
        details.localPosition.dx / width < 0.66) {
      updateFutureViewVisitable();
    } else {
      _chapterUpdateOrigin = _ChapterUpdateOrigin.onTap;
      if (details.localPosition.dx / width < 0.33) {
        changePage(pageIndex - 1);
      } else if (details.localPosition.dx / width > 0.66) {
        changePage(pageIndex + 1);
      }
      Future.delayed(Duration(milliseconds: 100))
          .then((value) => _chapterUpdateOrigin = _ChapterUpdateOrigin.none);
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
    if (index < 0 ) {
      if(preChapter == null){
        toastMessage('已经是第一页了');
      } else {
        changeChapter();
      }
    } else if (index > (imagePageUrlList.length - 1) && nextChapter == null) {
      if(nextChapter == null) {
        toastMessage('已经是最后一页了', TextAlign.right);
      } else {
        changeChapter();
      }
    } else {
      setState(() {
        pageIndex = index;
        tabController.jumpToPage(pageIndex);
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

  void changeChapter() async {
    if (checkChapterChange() == _ChangeChapterAction.loadPreviousChapter) {
      var willLoadChapter = preChapter;
      if (!mounted) {
        return null;
      } else if (willLoadChapter == null) {
        toastMessage('已经是第一页了');
        return;
      }

      Key fireKey = pageKey;
      var preChapterData = await getChapterData(willLoadChapter, onLoad: () {
        toastMessage('正在加载上一章节');
      });
      if (!mounted) {
        return null;
      }
      if (!isOnScroll && pageKey == fireKey) {
        _chapterUpdateOrigin = _ChapterUpdateOrigin.scroll;


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
        Future.microtask(() {
          tabController.jumpToPage(pageIndex);
        });
        Future.delayed(Duration(milliseconds: 50)).then((v) {
          setState(() {
            _chapterUpdateOrigin = _ChapterUpdateOrigin.none;
          });
        });
      } else {
        return null;
      }
    } else if (checkChapterChange() == _ChangeChapterAction.loadNextChapter) {
      if (!mounted) {
        return null;
      } else if (nextChapter == null) {
        toastMessage('已经是最后一页了', TextAlign.right);
        return;
      }
      Key fireKey = pageKey;
      final nextChapterData = await getChapterData(nextChapter, onLoad: () {
        toastMessage('正在加载下一章节', TextAlign.right);
      });
      if (!mounted) {
        return null;
      }
      if (!isOnScroll &&
          pageKey == fireKey) {
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
        return null;
      }
    }
  }

  bool isChapterLoad(Chapter willLoadChapter) =>
      this
          .onPageListChapters
          .indexWhere((el) => willLoadChapter.url == el.url) !=
      -1;

  onPageViewScroll() {
    if (_chapterUpdateOrigin == _ChapterUpdateOrigin.none) {
      final tabControllerPage = tabController.page.floor();
      setState(() {
        pageIndex = tabControllerPage;
      });
    }
    if (pageIndex < pageOffsetFix && preChapter != null) {
      setState(() {
        currentChapter = preChapter;
        chapterIndex--;
        viewerPageStatus = ViewerReadProcess(currentChapter, currentChapter.imgUrlList.length - 1);
      });
    } else if (pageIndex >=
        (pageOffsetFix + currentChapter.imgUrlList.length) && nextChapter != null) {
      setState(() {
        currentChapter = nextChapter;
        chapterIndex++;
        viewerPageStatus = ViewerReadProcess(currentChapter, 0);
      });
    }

    changeChapter();
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
              mangaImageIndex: pageIndex - (pageOffsetFix),
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
      onPageViewScroll();
    } else if (scrollNotification is ScrollStartNotification) {
      isOnScroll = true;
    }
  }

  _ChangeChapterAction checkChapterChange() {
    if (nextChapter == null && pageIndex == (imagePageUrlList.length -1 )) {
      print('最后一张');
      return _ChangeChapterAction.lastImage;
    } else if (preChapter == null && pageIndex == 0) {
      print('第一张');
      return _ChangeChapterAction.firstImage;
    } else if (pageIndex < pageOffsetFix) {
      print('进入上一章');
      return _ChangeChapterAction.goPreviousChapter;
    } else if (pageIndex <= (pageOffsetFix) && preChapter != null) {
      print('加载上一章');
      return _ChangeChapterAction.loadPreviousChapter;
    } else if (pageIndex ==
        (pageOffsetFix + currentChapter.imgUrlList.length )) {
      print('进入下一章');
      return _ChangeChapterAction.goNextChapter;
    } else if (pageIndex == (imagePageUrlList.length - 1)) {
      print('加载下一章');
      return _ChangeChapterAction.loadNextChapter;
    } else {
      print('none');
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
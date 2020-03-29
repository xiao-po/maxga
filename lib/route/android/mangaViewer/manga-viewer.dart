import 'dart:async';
import 'dart:ui';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:maxga/base/delay.dart';
import 'package:maxga/components/dialog/dialog.dart';
import 'package:maxga/constant/setting-value.dart';
import 'package:maxga/http/repo/maxga-data-http-repo.dart';
import 'package:maxga/manga-repo-pool.dart';
import 'package:maxga/model/manga/chapter.dart';
import 'package:maxga/model/manga/manga.dart';
import 'package:maxga/provider/public/setting-provider.dart';
import 'package:maxga/route/android/error-page/error-page.dart';
import 'package:maxga/utils/maxga-utils.dart';
import 'package:provider/provider.dart';

import '../mangaViewer/components/base/manga-viewer-future-view.dart';
import 'base/manga-viewer-divider-width.dart';
import 'manga-image-list-viewer.dart';
import 'manga-image.dart';
import 'manga-status-bar.dart';
import 'manga-tab.dart';

enum _MangaViewerLoadState { checkNetState, loadingMangaData, over, error }

enum _MangaOrientation {
  leftToRight,
  rightToLeft,
  topToBottom,
}

_MangaOrientation getOrientationFromIndex(int value) {
  return _MangaOrientation.values[value] ?? _MangaOrientation.leftToRight;
}


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

  const MangaViewer({Key key,
    this.manga,
    this.currentChapter,
    this.initIndex = 0,
    this.chapterList})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MangaViewerState();
}

class _MangaViewerState extends State<MangaViewer>
    with SingleTickerProviderStateMixin {
  final mangaViewerKey = GlobalKey<ScaffoldState>();
  final futureViewAnimationDuration = Duration(milliseconds: 200);
  MaxgaDataHttpRepo dataHttpRepo;
  List<Chapter> chapterList;

  PageController pageController;

  AnimationController animationController;

  ItemScrollController itemScrollController = ItemScrollController();
  ItemPositionsListener positionsListener = ItemPositionsListener.create();

  _MangaOrientation orientation;

  int chapterIndex;
  Map<int, Chapter> cachedChapterData = {};
  bool isOnScroll = false;
  Chapter currentChapter;


  MangaViewerDividerWidth mangaViewerDividerWidth;

  Chapter get preChapter =>
      chapterIndex != 0 ? chapterList[chapterIndex - 1] : null;

  Chapter get nextChapter =>
      chapterIndex != (chapterList.length - 1)
          ? chapterList[chapterIndex + 1]
          : null;

  _ChapterUpdateOrigin _chapterUpdateOrigin = _ChapterUpdateOrigin.none;
  _MangaViewerLoadState loadStatus = _MangaViewerLoadState.loadingMangaData;

  int _pageIndex = 0;

  int get pageIndex => _pageIndex;

  set pageIndex(val) {
    _pageIndex = val;
    pageKey = UniqueKey();
    if (viewerPageStatus != null) {
      if (orientation != _MangaOrientation.rightToLeft) {
        viewerPageStatus.pageIndex = (val - pageOffsetFix);
      } else {
        viewerPageStatus.pageIndex =
            imagePageUrlList.length - 1 - pageOffsetFix - val;
      }
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
      switch (orientation) {
        case _MangaOrientation.leftToRight:
        case _MangaOrientation.topToBottom:
          final index = onPageListChapters
              .indexWhere((el) => currentChapter.url == el.url);
          var length = 0;
          for (var i = 0; i < index; i++) {
            length += onPageListChapters[i].imgUrlList.length;
          }
          _pageOffsetFix = length;
          chapterChangeKey = viewerPageStatus?.key ?? UniqueKey();
          return length;
        case _MangaOrientation.rightToLeft:
          final index = onPageListChapters
              .indexWhere((el) => currentChapter.url == el.url);
          var length = 0;
          for (var i = onPageListChapters.length; i > index; i--) {
            length += onPageListChapters[i].imgUrlList.length;
          }
          _pageOffsetFix = length;
          chapterChangeKey = viewerPageStatus?.key ?? UniqueKey();
          return length;
      }
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

    animationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
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
    final SettingProvider settingProvider = SettingProvider.getInstance();
    final MangaViewerDividerWidth mangaViewerDividerWidth = getDividerWidthFromString(
        settingProvider.getItemValue(
            MaxgaSettingItemType.defaultVerticalDividerWidth)
    );

    this.mangaViewerDividerWidth = mangaViewerDividerWidth;
  }

  void initMangaViewer() async {
    loadStatus = _MangaViewerLoadState.loadingMangaData;
    setState(() {});
    var settingProvider = Provider.of<SettingProvider>(context);
    final orientationValue = int.parse(
        settingProvider.getItemValue(MaxgaSettingItemType.defaultOrientation)
    );

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
        setMangaOrientation(
            getOrientationFromIndex(orientationValue)
        );
        setState(() {
          currentChapter = currentChapterData;
          this.imagePageUrlList.addAll(currentChapter.imgUrlList);
          this.onPageListChapters.add(currentChapter);
          pageIndex = widget.initIndex;
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
          Widget tabMangaViewer = MangaTabView(
              controller: pageController,
              hasPrechapter: preChapter != null,
              onPageChanged: (page) => onPageViewScroll(page, page),
              itemCount: imagePageUrlList.length,
              itemBuilder: (context, index) =>
                  Tab(
                    child: MangaImage(
                      url: imagePageUrlList[index],
                      headers: dataHttpRepo.mangaSource.headers,
                      index: index - pageOffsetFix + 1,
                    ),
                  ));
          if (orientation == _MangaOrientation.topToBottom) {
            tabMangaViewer = MangaListViewer(
              itemPositionsListener: positionsListener,
              imageUrlList: imagePageUrlList,
              mangaViewerDividerWidth: mangaViewerDividerWidth,
              itemScrollController: itemScrollController,
              initialScrollIndex: pageIndex,
              headers: dataHttpRepo.mangaSource.headers,
            );
          }
          body = Stack(
            children: <Widget>[
              NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) =>
                      handleTabViewScroll(scrollNotification),
                  child: tabMangaViewer),
              MangaStatusBar(currentChapter, viewerPageStatus.pageIndex + 1),
              GestureDetector(
                onTapUp: (details) => dispatchTapUpEvent(details, context),
                onLongPress: () => openMenuDialog(),
                behavior: HitTestBehavior.translucent,
                child: MangaFeatureView(
                  animation: animationController,
                  onPageChange: (index) =>
                      changePage(index.floor() + (pageOffsetFix)),
                  imageCount: viewerPageStatus.chapter.imgUrlList.length,
                  pageIndex: viewerPageStatus.pageIndex,
                  title: viewerPageStatus.chapter.title,
                ),
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

  Future<Chapter> getChapterData(Chapter chapter, {
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

  dispatchTapUpEvent(TapUpDetails details, BuildContext context) async {
    final width = MediaQuery
        .of(context)
        .size
        .width;

    if (details.localPosition.dx / width > 0.33 &&
        details.localPosition.dx / width < 0.66) {
      switch (animationController.status) {
        case AnimationStatus.completed:
        case AnimationStatus.forward:
          await MaxgaUtils.hiddenStatusBar();
          animationController.reverse();
          break;
        case AnimationStatus.reverse:
        default:
          await MaxgaUtils.showStatusBar();
          animationController.forward();
      }
    } else {
      if (orientation != _MangaOrientation.topToBottom) {
        if (details.localPosition.dx / width < 0.33) {
          goPreviousPage();
        } else if (details.localPosition.dx / width > 0.66) {
          goNextPage();
        }
      }
    }
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
      });

      switch (orientation) {
        case _MangaOrientation.rightToLeft:
        case _MangaOrientation.leftToRight:
          pageController.jumpToPage(target);
          break;
        case _MangaOrientation.topToBottom:
          itemScrollController.jumpTo(index: target);
          break;
      }
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

  onPageViewScroll(int min, int max, [double offset]) async {
    if (_chapterUpdateOrigin == _ChapterUpdateOrigin.none) {
      setState(() {
        pageIndex = min;
      });
      var act = checkIndexStatus(min, max);
      switch (act) {
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
        default:
      }
    }

    return true;
  }

  onScrollEnd(int min, int max) async {
    Key fireKey = pageKey;
    var act = checkIndexStatus(min, max);
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
          if ((!isOnScroll && pageKey == fireKey)) {
            setState(() {
              if (this.onPageListChapters.indexOf(nextChapter) == -1) {
                toastMessage('加载完毕');
                viewerPageStatus.key = UniqueKey();
                switch (orientation) {
                  case _MangaOrientation.rightToLeft:
                    this.onPageListChapters.insert(0, nextChapterData);
                    imagePageUrlList.insertAll(
                        0, nextChapterData.imgUrlList.reversed.toList());
                    pageIndex += nextChapterData.imgUrlList.length;
                    pageController.jumpToPage(pageIndex);
                    break;
                  case _MangaOrientation.leftToRight:
                  case _MangaOrientation.topToBottom:
                    this.onPageListChapters.add(nextChapterData);
                    imagePageUrlList.addAll(nextChapterData.imgUrlList);
                    break;
                }
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
          if (orientation == _MangaOrientation.topToBottom) {
            break;
          }
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
                toastMessage('加载完毕');
                viewerPageStatus.key = UniqueKey();
                switch (orientation) {
                  case _MangaOrientation.rightToLeft:
                    this.onPageListChapters.add(preChapterData);
                    imagePageUrlList
                        .addAll(preChapterData.imgUrlList.reversed.toList());
                    break;
                  case _MangaOrientation.leftToRight:
                  case _MangaOrientation.topToBottom:
                    this.onPageListChapters.insert(0, preChapterData);
                    imagePageUrlList.insertAll(0, preChapterData.imgUrlList);
                    pageIndex += preChapterData.imgUrlList.length;
                    pageController.jumpToPage(pageIndex);
                    break;
                }
                _chapterUpdateOrigin = _ChapterUpdateOrigin.scroll;
              });
            }
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
      default:
    }
  }

  @override
  void dispose() {
    pageController?.dispose();
    super.dispose();
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

  Widget buildCenterText(String text) =>
      Padding(
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

      if (orientation != _MangaOrientation.topToBottom) {
        final tabControllerPage = pageController.page.round();
        onScrollEnd(tabControllerPage, tabControllerPage);
      } else {
        if (scrollNotification.metrics.maxScrollExtent -
            scrollNotification.metrics.pixels <
            0) {
          return null;
        }
        final positions = positionsListener.itemPositions.value.toList();
        final min = positions.first.index;
        final max = positions.last.index;
        this.onScrollEnd(min, max);
      }
    } else if (scrollNotification is ScrollStartNotification) {
      isOnScroll = true;
    }
  }

  _ChangeChapterAction checkIndexStatus(int min, int max) {
    switch (orientation) {
      case _MangaOrientation.rightToLeft:
        if (nextChapter == null && max == (imagePageUrlList.length - 1)) {
          return _ChangeChapterAction.lastImage;
        } else if (preChapter == null && min == 0) {
          return _ChangeChapterAction.firstImage;
        } else if (min < pageOffsetFix) {
          return _ChangeChapterAction.goPreviousChapter;
        } else if (min <= (pageOffsetFix) && preChapter != null) {
          return _ChangeChapterAction.loadPreviousChapter;
        } else if (min == (pageOffsetFix + currentChapter.imgUrlList.length)) {
          return _ChangeChapterAction.goNextChapter;
        } else if (max == (imagePageUrlList.length - 1)) {
          return _ChangeChapterAction.loadNextChapter;
        } else {
          return _ChangeChapterAction.none;
        }
        break;
      case _MangaOrientation.leftToRight:
        if (nextChapter == null && max == (imagePageUrlList.length - 1)) {
          return _ChangeChapterAction.lastImage;
        } else if (preChapter == null && min == 0) {
          return _ChangeChapterAction.firstImage;
        } else if (min < pageOffsetFix) {
          return _ChangeChapterAction.goPreviousChapter;
        } else if (min <= (pageOffsetFix) && preChapter != null) {
          return _ChangeChapterAction.loadPreviousChapter;
        } else if (max == (pageOffsetFix + currentChapter.imgUrlList.length)) {
          return _ChangeChapterAction.goNextChapter;
        } else if (max == (imagePageUrlList.length - 1)) {
          return _ChangeChapterAction.loadNextChapter;
        } else {
          return _ChangeChapterAction.none;
        }
        break;
      case _MangaOrientation.topToBottom:
      default:
        if (nextChapter == null &&
            (max - min < 2) &&
            max == (imagePageUrlList.length - 1)) {
          return _ChangeChapterAction.lastImage;
        } else if (preChapter == null && min == 0) {
          return _ChangeChapterAction.firstImage;
        } else if (min < pageOffsetFix) {
          return _ChangeChapterAction.goPreviousChapter;
        } else if (min <= (pageOffsetFix) && preChapter != null) {
          return _ChangeChapterAction.loadPreviousChapter;
        } else if (min == (pageOffsetFix + currentChapter.imgUrlList.length)) {
          return _ChangeChapterAction.goNextChapter;
        } else if (max == (imagePageUrlList.length - 1)) {
          return _ChangeChapterAction.loadNextChapter;
        } else {
          return _ChangeChapterAction.none;
        }
        break;
    }
  }

  setMangaOrientation(_MangaOrientation orientation) {
    final previousOrientation = this.orientation;
    if (orientation == previousOrientation) {
      return null;
    }
    var isShouldReversed =
        previousOrientation == _MangaOrientation.rightToLeft ||
            orientation == _MangaOrientation.rightToLeft;
    var pageIndex = this.pageIndex;
    var imagePageUrlList = this.imagePageUrlList;
    var onPageListChapters = this.onPageListChapters;
    if (isShouldReversed) {
      pageIndex = imagePageUrlList.length - 1 - pageIndex;
      imagePageUrlList = imagePageUrlList.reversed.toList();
      onPageListChapters = onPageListChapters.reversed.toList();
    }
    switch (orientation) {
      case _MangaOrientation.rightToLeft:
        latestMin = -1;
        latestMax = -1;
        positionsListener.itemPositions
            .removeListener(this.listenScrollableList);
        setState(() {
          this.orientation = _MangaOrientation.rightToLeft;
          this.pageIndex = pageIndex;
          this.imagePageUrlList = imagePageUrlList;
          this.onPageListChapters = onPageListChapters;
          if (pageController == null) {
            this.pageController = PageController(initialPage: pageIndex);
          } else {
            this.pageController.jumpToPage(pageIndex);
          }
        });
        break;
      case _MangaOrientation.leftToRight:
        latestMin = -1;
        latestMax = -1;
        positionsListener.itemPositions
            .removeListener(this.listenScrollableList);
        setState(() {
          this.orientation = _MangaOrientation.leftToRight;
          this.pageIndex = pageIndex;
          this.imagePageUrlList = imagePageUrlList;
          this.onPageListChapters = onPageListChapters;
          if (pageController == null) {
            this.pageController = PageController(initialPage: pageIndex);
          } else {
            this.pageController.jumpToPage(pageIndex);
          }
        });
        break;
      case _MangaOrientation.topToBottom:
        setState(() {
          this.pageIndex = pageIndex;
          this.onPageListChapters = onPageListChapters;
          this.orientation = _MangaOrientation.topToBottom;
          this.imagePageUrlList = imagePageUrlList;
          pageController?.dispose();
          pageController = null;
        });
        positionsListener.itemPositions.addListener(this.listenScrollableList);
        break;
    }
  }

  var latestMin = -1;
  var latestMax = -1;

  listenScrollableList() {
    var positions = positionsListener.itemPositions.value;
    int min;
    int max;
    if (positions.isNotEmpty) {
      min = positions.first.index;
      max = positions.last.index;
      if (min == latestMin && max == latestMax) {
        return null;
      }
      latestMin = min ?? -1;
      latestMax = max ?? -1;
      this.onPageViewScroll(min, max);
    }
  }

  openMenuDialog() async {
    _MangaOrientation ori = orientation;
    MangaViewerDividerWidth dividerWidth = mangaViewerDividerWidth;
    final result = await showDialog(
        context: context,
        child: OptionDialog(
          title: '菜单',
          children: <Widget>[
            ListTile(
              title: const Text('阅读方向'),
              trailing: SizedBox(
                width: 100,
                child: DropdownButtonFormField<int>(
                  value: orientation.index,
                  onChanged: (value) {
                    ori = getOrientationFromIndex(value);
                  },
                  items: [
                    DropdownMenuItem(
                      value: 0,
                      child: const Text('从左至右'),
                    ),
//                        DropdownMenuItem(
//                          value: 1,
//                          child: const Text('从右至左'),
//                        ),
                    DropdownMenuItem(
                      value: 2,
                      child: const Text('卷纸模式'),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: const Text('图片间隔'),
              trailing:  SizedBox(
                width: 100,
                child: DropdownButtonFormField<String>(
                    value: '${mangaViewerDividerWidth.index}',
                    onChanged: (value) {
                      dividerWidth = getDividerWidthFromString(value);
                    },
                    items: MaxgaSelectOptionsMap[MaxgaSettingItemType.defaultVerticalDividerWidth].map((e) => DropdownMenuItem(
                      value: e.value,
                      child: Text(e.title),
                    )).toList()
                ),
              ),
            )
          ],
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            FlatButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('确定'),
            ),
          ],
        ));

    if (result != null) {
      setMangaOrientation(ori);
      setState(() {
        this.mangaViewerDividerWidth = dividerWidth;
      });
    }
  }

  MangaViewerDividerWidth getDividerWidthFromString(String value) {

    switch (value) {
      case '0':
        return MangaViewerDividerWidth.none;
      case '1':
        return MangaViewerDividerWidth.small;
      case '2':
        return MangaViewerDividerWidth.middle;
      case '3':
        return MangaViewerDividerWidth.large;
      default:
        return MangaViewerDividerWidth.none;
    }
  }
}

class ViewerReadProcess {
  Chapter chapter;
  int pageIndex;
  Key key;

  ViewerReadProcess(this.chapter, this.pageIndex) : key = UniqueKey();
}

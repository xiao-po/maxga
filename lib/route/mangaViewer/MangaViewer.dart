import 'dart:async';
import 'dart:ui';

import 'package:battery/battery.dart';
import 'package:connectivity/connectivity.dart';

import 'package:flutter/material.dart';
import 'package:maxga/Application.dart';
import 'package:maxga/MangaRepoPool.dart';
import 'package:maxga/Utils/MaxgaUtils.dart';
import 'package:maxga/base/setting/SettingValue.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/model/manga/Chapter.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/provider/SettingProvider.dart';
import 'package:maxga/route/error-page/ErrorPage.dart';
import 'package:maxga/route/mangaViewer/MangaTab.dart';
import 'package:maxga/route/mangaViewer/baseComponent/MangaViewerFutureView.dart';
import 'package:provider/provider.dart';

enum _MangaViewerLoadState {
  checkNetState,
  loadingMangaData,
  over
}



class MangaViewerPopResult {
  bool loadOver;
  int mangaImageIndex;
  int chapterId;

  MangaViewerPopResult({this.loadOver, this.mangaImageIndex, this.chapterId});
}

class MangaViewer extends StatefulWidget {
  final SimpleMangaInfo manga;
  final Chapter currentChapter;
  final List<Chapter> chapterList;
  final int initIndex;

  const MangaViewer(
      {Key key, this.manga, this.currentChapter, this.initIndex = 0, this.chapterList})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MangaViewerState();
}


class _MangaViewerState extends State<MangaViewer> {
  final mangaViewerKey = GlobalKey<ScaffoldState>();

  Timer chapterChangeTimer;
  Timer scrollEventTimer;
  Timer futureViewVisitableTimer;
  // ignore: non_constant_identifier_names
  bool NEXT_PAGE_CHANGE_TRUST = true;

  Map<int, Chapter> cachedChapterData = {};
  _MangaViewerLoadState loadStatus = _MangaViewerLoadState.loadingMangaData;
  bool mangaFutureViewVisitable = false;
  double mangaFutureViewOpacity = 0;
  List<Chapter> chapterList;
  final futureViewAnimationDuration = Duration(milliseconds: 200);
  PageController tabController;
  Chapter currentChapter;
  Chapter preChapter;
  Chapter nextChapter;

  List<String> imagePageUrlList = <String>[];

  int _currentPageIndex = 0;

  bool loadingChapter = false;

  get chapterImageIndex => _currentPageIndex - (preChapter != null ? 1 : 0);

  get chapterImageCount =>
      imagePageUrlList.length -
      (preChapter != null ? 1 : 0) -
      (nextChapter != null ? 1 : 0) ;

  @override
  void initState() {
    super.initState();
    MaxgaUtils.hiddenStatusBar();
    Connectivity().checkConnectivity().then((connectivityResult) async {
      final readOnWiFi = Provider.of<SettingProvider>(context).getItem(MaxgaSettingItemType.readOnlyOnWiFi);
      if (connectivityResult == ConnectivityResult.wifi  || readOnWiFi.value == '0') {
        initMangaViewer();
      } else {
        loadStatus = _MangaViewerLoadState.checkNetState;
        setState(() {

        });
      }
    });
  }

  void initMangaViewer() async {
    loadStatus = _MangaViewerLoadState.loadingMangaData;
    setState(() {});
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
    print(currentChapterData.imgUrlList[0]);

    nextChapter = nextChapterData;
    preChapter = preChapterData;
    currentChapter = currentChapterData;
    this.imagePageUrlList = getImagePageUrlListFormChapter();
    _currentPageIndex = widget.initIndex + (preChapter != null ? 1 : 0);

    tabController = PageController(initialPage: _currentPageIndex);
    this.loadStatus = _MangaViewerLoadState.over;

    if (mounted) {
      setState(() {});
    }
  }

  List<String> getImagePageUrlListFormChapter() {
    List<String> imageUrlList = [];
    if(preChapter != null) {
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
    var body;
    switch (loadStatus) {
      case _MangaViewerLoadState.checkNetState: {
        return buildCheckNetStatePage();
      }
      case _MangaViewerLoadState.loadingMangaData:
        {
          body = buildLoadingPage();
          break;
        }
      case _MangaViewerLoadState.over:
        {
          body = Stack(
            children: <Widget>[
              NotificationListener<ScrollEndNotification>(
                onNotification: (scrollNotification) =>
                    onPageViewScroll(scrollNotification),
                child: GestureDetector(
                  onTapUp: (details) => dispatchTapUpEvent(details, context),
                  child: MangaTabView(
                    source: MangaRepoPool.getInstance().getMangaSourceByKey(widget.manga.sourceKey),
                    controller: tabController,
                    onPageChanged: (index) => changePage(index),
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
                        onPageChange: (index) => changePage(
                            index.floor() + (preChapter != null ? 1 : 0),
                            shouldJump: true),
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
      default:
        {
          body = ErrorPage('加载失败');
        }
    }
    return WillPopScope(
      child: Scaffold(
        key: mangaViewerKey,
        backgroundColor: Colors.black,
        body: body,
      ),
      onWillPop: () => onBack(),
    );
  }

  int get radioPageIndex {
    return chapterImageIndex < 1
                          ? 0
                          : (chapterImageIndex >= (chapterImageCount - 1)
                              ?  (chapterImageCount - 1)
                              : chapterImageIndex);
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
      MaxgaDataHttpRepo repo = MangaRepoPool.getInstance().getRepo(key: widget.manga.sourceKey);
      print(chapter.url);
      final result = await repo.getChapterImageList(chapter.url);
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
    if (loadingChapter) {
      return null;
    }
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
    this.imagePageUrlList = [];

    return null;
  }

  void changeChapter() async {
    if (_currentPageIndex == 0 && preChapter != null) {
      toastMessage('正在加载上一章节');
      loadingChapter = true;
      nextChapter = currentChapter;
      currentChapter = preChapter;
      preChapter = null;
      if (mounted) {
        setState(() { });
      } else {
        return null;
      }

      final simplePreChapterData = getPreChapter(currentChapter);
      var preChapterData = await getChapterData(simplePreChapterData);
      preChapter = preChapterData;
      this.imagePageUrlList = getImagePageUrlListFormChapter();
      _currentPageIndex = imagePageUrlList.length - 2;
      if (mounted) {
        toastMessage('进入上一章节');
        loadingChapter = false;
        setState(() { });
      } else {
        return null;
      }

      NEXT_PAGE_CHANGE_TRUST = false;
      tabController.jumpToPage(_currentPageIndex);
      chapterChangeTimer = null;
    } else if (_currentPageIndex == (imagePageUrlList.length - 1) &&
        nextChapter != null) {
      toastMessage('正在加载下一章节');
      loadingChapter = true;
      preChapter = currentChapter;
      currentChapter = nextChapter;
      nextChapter = null;
      if (mounted) {
        setState(() { });
      } else {
        return null;
      }

      final simpleNextChapterData = getNextChapter(currentChapter);
      var nextChapterData = await getChapterData(simpleNextChapterData);
      nextChapter = nextChapterData;
      this.imagePageUrlList = getImagePageUrlListFormChapter();
      _currentPageIndex = preChapter != null ? 1 : 0;
      if (mounted) {
        toastMessage('进入下一章节', TextAlign.right);
    loadingChapter = false;
        setState(() { });
      } else {
        return null;
      }

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
    scrollEventTimer =
        Timer(Duration(milliseconds: 300), () => changeChapter());
    return true;
  }

  @override
  void dispose() {
    super.dispose();
    tabController?.dispose();
  }

  onBack() {
    if (loadStatus == _MangaViewerLoadState.over) {
      Navigator.pop<MangaViewerPopResult>(context, MangaViewerPopResult(
          loadOver: loadStatus == _MangaViewerLoadState.over,
          mangaImageIndex: _currentPageIndex - (preChapter != null ? 1 : 0),
          chapterId: currentChapter.id
      ));
    } else {
      Navigator.pop<MangaViewerPopResult>(context, MangaViewerPopResult(
          loadOver: loadStatus == _MangaViewerLoadState.over,
      ));
    }
  }

  Widget buildCheckNetStatePage() {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(color: Colors.white),
      ),
      body: buildCenterContainer(
        children: [
          buildCenterText('检测到你现在正使用移动网络'),
          buildCenterText('是否继续阅读？'),
          OutlineButton(
            borderSide: BorderSide(color: Colors.white),
            highlightedBorderColor: Colors.white,

            child: const Text('继续阅读',style: TextStyle(color: Colors.white,fontSize: 16),textAlign: TextAlign.center),
            onPressed: () {initMangaViewer();}
            ),
        ],
      )
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
    child: Text(text,style: TextStyle(color: Colors.white,fontSize: 16),textAlign: TextAlign.center,),
  );
}

class MangaStatusBar extends StatefulWidget {
  final Chapter currentChapter;
  final int currentIndex;

  MangaStatusBar(this.currentChapter, this.currentIndex);

  @override
  State<StatefulWidget> createState() => _MangaStatusBarState();
}

class _MangaStatusBarState extends State<MangaStatusBar> {
  final Battery _battery = Battery();
  StreamSubscription batteryStatusSubscription;

  DateTime currentTime;
  Timer timer;
  BatteryState batteryState = BatteryState.discharging;
  int currentBattery = 100;

  @override
  void initState() {
    super.initState();
    this.updateTimeAndBattery();
    waitUpdateTimeByMinute();
    batteryStatusSubscription =
        _battery.onBatteryStateChanged.listen((state) => batteryState = state);
  }

  @override
  Widget build(BuildContext context) {
    const defaultTextStyle = TextStyle(color: Color(0xffeaeaea), fontSize: 13);
    int index = widget.currentIndex;
    if (index > widget.currentChapter.imgUrlList.length) {
      index = widget.currentChapter.imgUrlList.length;
    } else if (index == 0) {
      index = 1;
    }

    return Align(
        alignment: Alignment.bottomRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
                padding:
                    EdgeInsets.only(left: 10, right: 20, top: 7, bottom: 4),
                decoration: BoxDecoration(color: Color(0xff263238)),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      LimitedBox(
                        maxWidth: 130,
                        child: Text(
                          '${widget.currentChapter.title} ',
                          overflow: TextOverflow.ellipsis,
                          style: defaultTextStyle,
                        ),
                      ),
                      Text(
                        ' $index/${widget.currentChapter.imgUrlList.length} '
                        ' ${currentTime.hour}:${currentTime.minute}  $currentBattery%',
                        style: defaultTextStyle,
                      ),
                    ]))
          ],
        ));
  }

  void waitUpdateTimeByMinute() {
    int restSeconds = 60 - currentTime.second;
    this.timer = Timer(Duration(seconds: restSeconds), () {
      waitUpdateTimeByMinute();
      updateTimeAndBattery();
    });
  }

  void updateTimeAndBattery() async {
    currentTime = DateTime.now();

    currentBattery = await _battery.batteryLevel;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    batteryStatusSubscription.cancel();
  }
}

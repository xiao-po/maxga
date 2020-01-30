import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maxga/base/drawer/menu-item.dart';
import 'package:maxga/base/error/MaxgaHttpError.dart';
import 'package:maxga/components/Card.dart';
import 'package:maxga/components/MangaCoverImage.dart';
import 'package:maxga/components/MangaListTabView.dart';
import 'package:maxga/components/MaxgaButton.dart';
import 'package:maxga/components/TabBar.dart';
import 'package:maxga/components/dialog.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/manga/MangaSource.dart';
import 'package:maxga/model/maxga/MaxgaReleaseInfo.dart';
import 'package:maxga/route/drawer/drawer.dart';
import 'package:maxga/route/mangaInfo/MangaInfoPage.dart';
import 'package:maxga/route/search/search-page.dart';
import 'package:maxga/service/UpdateService.dart';

import '../../MangaRepoPool.dart';
import 'error-page/error-page.dart';

enum _SourceViewType {
  latestUpdate,
  rank,
}

enum _MangaSourceViewerPageLoadState { none, loading, over, error }


class MangaSourceViewerPage {
  final MangaSource source;
  String title;
  _SourceViewType type;
  MangaHttpErrorType errorType;
  ScrollController controller = ScrollController(initialScrollOffset: 0);
  List<SimpleMangaInfo> mangaList = [];
  bool isLast = false;
  int page = 0;
  _MangaSourceViewerPageLoadState loadState =
      _MangaSourceViewerPageLoadState.none;

  MangaSourceViewerPage(this.title, this.type, this.source);

  Future<List<SimpleMangaInfo>> getMangaList(int page) async {
    MaxgaDataHttpRepo repo =
    MangaRepoPool.getInstance().getRepo(key: source.key);
    if (type == _SourceViewType.latestUpdate) {
      final mangaList = await repo.getLatestUpdate(page);
      debugPrint('更新列表已经加载完毕， 数量：${mangaList.length}');
      initOver = true;
      return mangaList;
    } else {
      final mangaList = await repo.getRankedManga(page);
      debugPrint('排行列表已经加载完毕， 数量：${mangaList.length}');
      initOver = true;
      return mangaList;
    }
  }

  bool initOver = false;
}


class SourceViewerPage extends StatefulWidget {
  final String name = 'source_viewer';

  @override
  State<StatefulWidget> createState() => _SourceViewerPageState();
}

class _SourceViewerPageState extends State<SourceViewerPage>  with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();



  void showSnack(String message) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }

  toSearch() {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return SearchPage();
    }));
  }


  DateTime _lastPressedAt; // 上次点击时间
  Future<bool> onBack() async {
    if (_lastPressedAt == null ||
        DateTime.now().difference(_lastPressedAt) > Duration(seconds: 2)) {
      // 两次点击间隔超过1秒则重新计时
      _lastPressedAt = DateTime.now();
      showSnack('再按一次退出程序');
      return false;
    } else {
      hiddenSnack();
      await Future.delayed(Duration(milliseconds: 100));
      return true;
    }
  }

  void hiddenSnack() {
    scaffoldKey.currentState.hideCurrentSnackBar();
  }

  checkUpdate() async {
    try {
      final nextVersion = await UpdateService.checkUpdateStatus();
      if (nextVersion != null) {
        final buttonPadding = const EdgeInsets.fromLTRB(15, 5, 15, 5);
        scaffoldKey.currentState.showSnackBar(SnackBar(
            duration: Duration(seconds: 3),
            content: GestureDetector(
              child: Padding(
                padding: buttonPadding,
                child: Text('有新版本更新, 点击查看'),
              ),
              onTap: () {
                hiddenSnack();
                openUpdateDialog(nextVersion);
              },
            ),
            action: SnackBarAction(
              label: '忽略',
              textColor: Colors.greenAccent,
              onPressed: () {
                openUpdateDialog(nextVersion);
              },
            )));
      }
    } catch(e) {
      debugPrint('检查更新失败');
    }
  }

  openUpdateDialog(MaxgaReleaseInfo nextVersion) {
    showDialog(
        context: context,
        builder: (context) => UpdateDialog(
          text: nextVersion.description,
          url: nextVersion.url,
          onIgnore: () => UpdateService.ignoreUpdate(nextVersion),
        ));
  }

  _SourceViewType pageType = _SourceViewType.latestUpdate;
  TabController tabController;
  bool isPageCanChanged = true;
  bool isTabChange = true;

  List<MangaSourceViewerPage> tabs;

  String sourceName;

  @override
  void initState() {
    super.initState();
    final source = MangaRepoPool.getInstance().currentSource;
    setMangaSource(source);

    tabController = TabController(vsync: this, length: 2, initialIndex: 0);
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
    tabs.forEach((state) => state.controller.dispose());
  }

  void setMangaSource(MangaSource source) async {
    tabs = [
      MangaSourceViewerPage('最近更新', _SourceViewType.latestUpdate, source),
      MangaSourceViewerPage('排名', _SourceViewType.rank, source),
    ];
    await Future.wait(
        tabs.map((state) => this.getMangaList(state)).toList(growable: false));
  }

  @override
  Widget build(BuildContext context) {
    final body  = Scaffold(
      key: scaffoldKey,
      drawer: MaxgaDrawer(
        active: MaxgaMenuItemType.mangaSourceViewer,
      ),
      appBar: AppBar(
        title: Text(sourceName),
        actions: buildAppBarActions(),
        elevation: 1,
        bottom:  ColoredTabBar(
          color: Colors.white,
          tabBar: TabBar(
            controller: tabController,
            labelColor: Colors.black87,
            indicatorColor: Colors.black38,
            unselectedLabelColor: Colors.grey,
            tabs: tabs
                .map((item) => Tab(
              text: item.title,
            ))
                .toList(growable: false),
          ),
        ),
      ),
      body: MangaListTabBarView(
        controller: this.tabController,
        children: tabs
            .map((state) => RefreshIndicator(
          onRefresh: () => refreshPage(state),
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: buildIndexBody(state),
          ),
        ))
            .toList(growable: false),
      ),
    );

    return WillPopScope(
      child: body,
      onWillPop: () => onBack(),
    );
  }

  List<Widget> buildAppBarActions() {
    return <Widget>[
      MaxgaSearchButton(),
      MaxgaSourceSelectButton(
        onSelect: (source) => this.setMangaSource(source),
      )
    ];
  }

  buildIndexBody(MangaSourceViewerPage state) {
    if (!state.initOver) {
      switch (state.loadState) {
        case _MangaSourceViewerPageLoadState.none:
        case _MangaSourceViewerPageLoadState.loading:
          return Align(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black26)),
              ));
          break;
        case _MangaSourceViewerPageLoadState.over:
          return buildMangaListView(state);
        case _MangaSourceViewerPageLoadState.error:
          return MangaSourceViewerErrorPage(
            errorType: state.errorType,
            source: state.source,
            onTap: () => this.getMangaList(state),
          );
      }
    } else {
      return buildMangaListView(state);
    }
  }

  ListView buildMangaListView(MangaSourceViewerPage state) {
    return ListView.separated(
      controller: state.controller,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        if (index == state.mangaList.length) {
          if (state.isLast) {
            return Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Center(
                child: SizedBox(height: 20, child: Text('没有更多的漫画了')),
              ),
            );
          } else {
            Future.microtask(() => this.getMangaList(state));
            return buildProcessIndicator();
          }
        } else {
          if (state.type == _SourceViewType.latestUpdate) {
            return buildMangaCard(state.mangaList[index],
                tagPrefix: '${state.type}${index}state.title');
          } else {
            return buildMangaCard(state.mangaList[index],
                tagPrefix: '${state.type}${index}state.title', rank: index + 1);
          }
        }
      },
      itemCount: state.mangaList.length + 1,
    );
  }

  MangaListTile buildMangaCard(SimpleMangaInfo mangaInfo,
      {String tagPrefix, int rank}) {
    final Color grayFontColor = Color(0xff9e9e9e);
    MangaSource source =
    MangaRepoPool.getInstance().getMangaSourceByKey(mangaInfo.sourceKey);
    Widget mangaCoverImage = MangaCoverImage(
      source: source,
      url: mangaInfo.coverImgUrl,
      tagPrefix: '$tagPrefix${widget.name}',
    );
    if (rank != null) {
      mangaCoverImage = rankedCoverImage(mangaCoverImage, rank);
    }
    return MangaListTile(
      title: Text(mangaInfo.title),
      extra: MangaListTileExtra(
          manga: mangaInfo, textColor: grayFontColor, source: source),
      cover: mangaCoverImage,
      onTap: () => this.goMangaInfoPage(mangaInfo, tagPrefix: tagPrefix),
    );
  }

  Stack rankedCoverImage(MangaCoverImage mangaCoverImage, int rank) {
    Color rankColor;
    switch (rank) {
      case 1:
        rankColor = Colors.redAccent;
        break;
      case 2:
        rankColor = Colors.orangeAccent;
        break;
      case 3:
        rankColor = Colors.amberAccent;
        break;
      default:
        rankColor = Colors.blueGrey;
    }

    var textStyle;
    if (rank >= 100) {
      textStyle = TextStyle(color: Colors.white, fontSize: 10);
    } else {
      textStyle = TextStyle(color: Colors.white, fontSize: 12);
    }
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        mangaCoverImage,
        Positioned(
          top: -5,
          left: -3,
          child: Icon(Icons.bookmark, size: 35, color: rankColor),
        ),
        Positioned(
          top: 4,
          left: 3,
          child: SizedBox(
            width: 22,
            height: 20,
            child: Text(
              '$rank',
              style: textStyle,
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    );
  }

  DateTime pageChangeDebounceTime = DateTime.now();

  refreshPage(MangaSourceViewerPage state) =>
      this.getMangaList(state, isRefresh: true);

  Future<void> getMangaList(MangaSourceViewerPage state,
      {bool isRefresh = false}) async {
    if (state.loadState == _MangaSourceViewerPageLoadState.loading) {
      return null;
    }
    try {
      sourceName = state.source.name;
      if (isRefresh) {
        state.page = 0;
      }
      state.loadState = _MangaSourceViewerPageLoadState.loading;
      setState(() {});
      final mangaList = await state.getMangaList(state.page++);
      if (mangaList.length == 0) {
        state.isLast = true;
      }
      if (isRefresh) {
        state.mangaList = mangaList;
      } else {
        state.mangaList.addAll(mangaList);
      }

      state.errorType = null;
      state.loadState = _MangaSourceViewerPageLoadState.over;
    } on MangaHttpError catch (e) {
      debugPrint(e.message);
      state.errorType = e.type;
      state.loadState = _MangaSourceViewerPageLoadState.error;
    } finally {
      setState(() {});
    }
  }

  Widget buildProcessIndicator() {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Center(
        child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }


  goMangaInfoPage(SimpleMangaInfo item, {String tagPrefix}) {
    MangaSource source =
    MangaRepoPool.getInstance().getMangaSourceByKey(item.sourceKey);
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return MangaInfoPage(
        coverImageBuilder: (context) => MangaCoverImage(
          source: source,
          url: item.coverImgUrl,
          tagPrefix: '$tagPrefix${widget.name}',
          fit: BoxFit.cover,
        ),
        infoUrl: item.infoUrl,
        sourceKey: item.sourceKey,
      );
    }));
  }

}
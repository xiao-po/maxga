import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maxga/base/drawer/menu-item.dart';
import 'package:maxga/base/error/MaxgaHttpError.dart';
import 'package:maxga/components/Card.dart';
import 'package:maxga/components/MangaCoverImage.dart';
import 'package:maxga/components/base/MaxgaTabView.dart';
import 'package:maxga/components/MaxgaButton.dart';
import 'package:maxga/components/TabBar.dart';
import 'package:maxga/components/base/WillExitScope.dart';
import 'package:maxga/components/dialog.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/manga/MangaSource.dart';
import 'package:maxga/model/maxga/MaxgaReleaseInfo.dart';
import 'package:maxga/provider/public/HistoryProvider.dart';
import 'package:maxga/provider/source-viewer/source-viwer-provider.dart';
import 'package:maxga/service/UpdateService.dart';
import 'package:maxga/MangaRepoPool.dart';
import 'package:provider/provider.dart';

import '../drawer/drawer.dart';
import '../mangaInfo/MangaInfoPage.dart';
import '../search/search-page.dart';
import 'error-page/error-page.dart';

class SourceViewerPage extends StatefulWidget {
  final String name = 'source_viewer';

  @override
  State<StatefulWidget> createState() => _SourceViewerPageState();
}

class _SourceViewerPageState extends State<SourceViewerPage>
    with SingleTickerProviderStateMixin {
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
    } catch (e) {
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

  TabController tabController;

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
    setState(() {
      sourceName = source.name;
      tabs = [
        MangaSourceViewerPage('最近更新', SourceViewType.latestUpdate, source),
        MangaSourceViewerPage('排名', SourceViewType.rank, source),
      ];
    });
    await Future.wait(
        tabs.map((state) => this.loadNextPage(state)).toList(growable: false));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    var tabBarLabelColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black87;
    var tabBarIndicator =
        theme.brightness == Brightness.dark ? Colors.white24 : Colors.black38;
    var appBar = AppBar(
        title: Text(sourceName),
        actions: <Widget>[
          MaxgaSearchButton(),
          MaxgaSourceSelectButton(
            onSelect: (source) => this.setMangaSource(source),
          )
        ],
        elevation: 1,
        bottom: ColoredTabBar(
          color: Colors.white,
          tabBar: TabBar(
            controller: tabController,
            labelColor: tabBarLabelColor,
            indicatorColor: tabBarIndicator,
            unselectedLabelColor: Colors.grey,
            tabs: tabs
                .map((item) => Tab(
                      text: item.title,
                    ))
                .toList(growable: false),
          ),
        ),
      );
    var tabViewer = MaxgaTabBarView(
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
      );
    return Scaffold(
      key: scaffoldKey,
      drawer: MaxgaDrawer(
        active: MaxgaMenuItemType.mangaSourceViewer,
      ),
      appBar: appBar,
      body: WillExitScope(
        child: tabViewer,
      ),
    );

  }


  buildIndexBody(MangaSourceViewerPage state) {
    if (!state.initOver) {
      switch (state.loadState) {
        case MangaSourceViewerPageLoadState.none:
        case MangaSourceViewerPageLoadState.loading:
          return Align(
              child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ));
          break;
        case MangaSourceViewerPageLoadState.over:
          return buildMangaListView(state);
        case MangaSourceViewerPageLoadState.error:
          return MangaSourceViewerErrorPage(
            errorType: state.errorType,
            source: state.source,
            onTap: () => this.loadNextPage(state),
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
            Future.microtask(() => this.loadNextPage(state));
            return buildProcessIndicator();
          }
        } else {
          if (state.type == SourceViewType.latestUpdate) {
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
      title: Text(
        mangaInfo.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
      ),
      labels: [
        mangaInfo.authors.join(' / '),
        mangaInfo.typeList.join(' / '),
      ].map((item) => MangaListTileLabel(text: item)).toList(growable: false),
      extra: MangaListTileExtra(
          manga: mangaInfo, source: source),
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

  Future<void> refreshPage(MangaSourceViewerPage state) async {
    sourceName = state.source.name;
    try {
      await state.refreshPage();
    } on MangaHttpError catch (e) {
      debugPrint(e.message);
    } finally {
      if (state.loadState != MangaSourceViewerPageLoadState.loading) {
        setState(() {});
      }
    }
  }

  Future<void> loadNextPage(MangaSourceViewerPage state) async {
    try {
      await state.loadNextPage();
    } on MangaHttpError catch (e) {
      debugPrint(e.message);
    } finally {
      if (state.loadState != MangaSourceViewerPageLoadState.loading) {
        setState(() {});
      }
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

  goMangaInfoPage(SimpleMangaInfo manga, {String tagPrefix}) {
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
            lastUpdateChapter: manga.lastUpdateChapter));
    MangaSource source =
        MangaRepoPool.getInstance().getMangaSourceByKey(manga.sourceKey);
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return MangaInfoPage(
        coverImageBuilder: (context) => MangaCoverImage(
          source: source,
          url: manga.coverImgUrl,
          tagPrefix: '$tagPrefix${widget.name}',
          fit: BoxFit.cover,
        ),
        infoUrl: manga.infoUrl,
        sourceKey: manga.sourceKey,
      );
    }));
  }
}

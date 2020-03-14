import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:maxga/base/delay.dart';
import 'package:maxga/base/drawer/drawer-menu-item.dart';
import 'package:maxga/base/error/maxga-http-error.dart';
import 'package:maxga/components/base/confirm-exit-scope.dart';
import 'package:maxga/components/base/manga-cover-image.dart';
import 'package:maxga/components/base/maxga-tab-view.dart';
import 'package:maxga/components/base/zero-divider.dart';
import 'package:maxga/components/button/search-button.dart';
import 'package:maxga/components/card/card.dart';
import 'package:maxga/components/dialog/dialog.dart';
import 'package:maxga/constant/setting-value.dart';
import 'package:maxga/manga-repo-pool.dart';
import 'package:maxga/model/manga/manga-source.dart';
import 'package:maxga/model/manga/simple-manga-info.dart';
import 'package:maxga/model/maxga/maxga-release-info.dart';
import 'package:maxga/provider/public/history-provider.dart';
import 'package:maxga/provider/public/setting-provider.dart';
import 'package:maxga/provider/source-viewer/source-viwer-provider.dart';
import 'package:maxga/route/android/search/search-result-page.dart';
import 'package:maxga/route/android/user/auth-page.dart';
import 'package:maxga/route/android/user/base/login-page-result.dart';
import 'package:maxga/service/update-service.dart';
import 'package:maxga/utils/maxga-utils.dart';
import 'package:provider/provider.dart';

import '../drawer/drawer.dart';
import '../mangaInfo/manga-info-page.dart';
import '../search/search-page.dart';
import 'components/manga-list-tile-menu-dialog.dart';
import 'components/maxga-source-select-button.dart';
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
    final sourceKey = SettingProvider.getInstance()
        .getItemValue(MaxgaSettingItemType.defaultMangaSource);
    final source = MangaRepoPool.getInstance().getMangaSourceByKey(sourceKey);
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
      bottom: TabBar(
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
        loginCallback: toLogin,
      ),
      appBar: appBar,
      body: ConfirmExitScope(
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
            onTap: () => this.setState(() {
              state.loadState = MangaSourceViewerPageLoadState.none;
              this.refreshPage(state);
            }),
          );
      }
    } else {
      return buildMangaListView(state);
    }
  }

  ListView buildMangaListView(MangaSourceViewerPage state) {
    return ListView.separated(
      controller: state.controller,
      separatorBuilder: (context, index) => ZeroDivider(),
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
            return buildMangaListTile(state.mangaList[index],
                tagPrefix: '${state.type}${index}state.title');
          } else {
            return buildMangaListTile(state.mangaList[index],
                tagPrefix: '${state.type}${index}state.title', rank: index + 1);
          }
        }
      },
      itemCount: state.mangaList.length + 1,
    );
  }

  MangaListTile buildMangaListTile(SimpleMangaInfo mangaInfo,
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
      extra: MangaListTileExtra(manga: mangaInfo, source: source),
      cover: mangaCoverImage,
      onTap: () => this.goMangaInfoPage(mangaInfo, tagPrefix: tagPrefix),
      onLongPress: () => this.openMangaItemMenu(mangaInfo, tagPrefix),
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
    } on MangaRepoError catch (e) {
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
    } on MangaRepoError catch (e) {
      debugPrint(e.message);
    } finally {
      if (state.loadState != MangaSourceViewerPageLoadState.loading) {
        if (mounted) {
          setState(() {});
        }
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
            authors: manga.authors,
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
        title: manga.title,
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

  void toLogin() async {
    AuthPageResult result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AuthPage()));
    if (result != null && result.success) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('登录成功'),
      ));
    }
  }

  openMangaItemMenu(SimpleMangaInfo mangaInfo, String tagPrefix) {
    showDialog(
      context: context,
      child: MangaListTileMenuDialog(
          onSelect: (option) =>
              this.handleMangaDialogMenuSelect(mangaInfo, option),
          manga: mangaInfo),
    );
  }

  handleMangaDialogMenuSelect(
      SimpleMangaInfo manga, MangaListTileMenuOption option) async {
    Navigator.pop(context);
    await AnimationDelay();
    switch (option) {
      case MangaListTileMenuOption.read:
        goMangaInfoPage(manga);
        break;
      case MangaListTileMenuOption.collect:
        // TODO: Handle this case.
        break;
      case MangaListTileMenuOption.cancelCollect:
        // TODO: Handle this case.
        break;
      case MangaListTileMenuOption.shareLink:
        String link = await MangaRepoPool.getInstance()
            .getDataRepo(manga.sourceKey)
            .generateShareLink(manga);
        MaxgaUtils.shareUrl(link);
        break;
      case MangaListTileMenuOption.shareCoverImage:
        var cacheManager = DefaultCacheManager();
        var file = await Future.any([
          cacheManager.getFileFromCache(manga.coverImgUrl),
          AnimationDelay(),
        ]);
        if (file is FileInfo) {
          var path = file.file.path;
          await MaxgaUtils.shareImage(path);
        } else {
          scaffoldKey.currentState
              .showSnackBar(SnackBar(content: const Text("封面暂未加载完成")));
        }
        break;
      case MangaListTileMenuOption.searchAuthor:
        this.toSearchAuthor(manga);
        break;
    }
  }

  toSearchAuthor(SimpleMangaInfo mangaInfo) async {
    var author = mangaInfo.authors[0];
    const optionTextStyle = TextStyle(fontSize: 18);
    if (mangaInfo.authors.length > 1) {
      final result = await showDialog(
          context: context,
          child: OptionDialog(
              title: '作者',
              children: mangaInfo.authors
                  .map(
                    (str) => ListTile(
                        onTap: () async {
                          await AnimationDelay();
                          Navigator.pop(context, str);
                        },
                        title: Text(str, style: optionTextStyle)),
                  )
                  .toList()));
      if (result == null) return;
      author = result;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SearchResultPage(
                  keyword: author,
                )));
  }
}

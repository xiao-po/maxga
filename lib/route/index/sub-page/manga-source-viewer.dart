import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/Card.dart';
import 'package:maxga/components/MangaCoverImage.dart';
import 'package:maxga/components/MaxgaButton.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/manga/MangaSource.dart';
import 'package:maxga/route/error-page/ErrorPage.dart';
import 'package:maxga/route/index/base/IndexSliverAppBarDelegate.dart';
import 'package:maxga/route/mangaInfo/MangaInfoPage.dart';
import 'package:maxga/route/mangaViewer/baseComponent/MangaPageView.dart';
import 'package:maxga/route/search/search-page.dart';
import 'package:maxga/service/MangaReadStorage.service.dart';

import '../../../MangaRepoPool.dart';

enum _SourceViewType {
  latestUpdate,
  rank,
}

enum _MangaSourceViewerPageLoadState { none,loading, over, error }

class MangaSourceViewerPage {
  final MangaSource source;
  String title;
  _SourceViewType type;
  ScrollController controller = ScrollController(initialScrollOffset: 0);
  List<SimpleMangaInfo> mangaList = [];
  bool isLast = false;
  int page = 0;
  _MangaSourceViewerPageLoadState loadState =
      _MangaSourceViewerPageLoadState.none;

  MangaSourceViewerPage(this.title, this.type, this.source);

  Future<List<SimpleMangaInfo>> getMangaList(int page)  async {
    MaxgaDataHttpRepo repo =
        MangaRepoPool.getInstance().getRepo(key: source.key);
    if (type == _SourceViewType.latestUpdate) {
      final mangaList = await repo.getLatestUpdate(page);
      print('更新列表已经加载完毕， 数量：${mangaList.length}');
      return mangaList;
    } else {
      final mangaList = await repo.getRankedManga(page);
      print('排行列表已经加载完毕， 数量：${mangaList.length}');
      return mangaList;
    }
  }

  bool get initOver => isLast || mangaList.length > 0;
}

class MangaSourceViewer extends StatefulWidget {
  final name = 'MangaSourceViewer';

  @override
  State<StatefulWidget> createState() => MangaSourceViewerState();
}

class MangaSourceViewerState extends State<MangaSourceViewer>
    with SingleTickerProviderStateMixin {
  _SourceViewType pageType = _SourceViewType.latestUpdate;
  TabController tabController;
  ScrollController scrollController = ScrollController();
  bool isPageCanChanged = true;
  bool isTabChange = true;

  PageController pageController = PageController(initialPage: 0);
  List<MangaSourceViewerPage> tabs;
  List<MangaSource> allMangaSource;

  String sourceName;

  @override
  void initState() {
    super.initState();
    final source = MangaRepoPool.getInstance().currentSource;
    setMangaSource(source);

    tabController = TabController(vsync: this, length: 2, initialIndex: 0);
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        //判断TabBar是否切换
        if (isTabChange) {
          onPageChange(tabController.index, pageController);
        } else {
          isTabChange = true;
        }
      }
    });
    allMangaSource = MangaRepoPool.getInstance()?.allDataSource;
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
    pageController.dispose();
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
    var page = NestedScrollView(
      headerSliverBuilder: (context, isScrolled) => [
        SliverAppBar(
          title: Text(sourceName),
          leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer()),
          actions: buildAppBarActions(),
          pinned: true,
        ),
        SliverPersistentHeader(
          delegate: IndexSliverAppBarDelegate(
            TabBar(
              controller: tabController,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey,
              tabs: tabs.map((item) => Tab(
                text: item.title,
              )).toList(growable: false),
            ),
          ),
          pinned: true,
        ),
      ],
      body: MangaPageView(
        controller: pageController,
        preloadPageCount: 1,
        onPageChanged: (index) =>
            isPageCanChanged ? this.onPageChange(index) : null,
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
    return SafeArea(
      child: page,
    );
  }

  List<Widget> buildAppBarActions() {
    return <Widget>[
      MaxgaSearchButton(),
      IconButton(
        icon: Icon(
          Icons.delete,
          color: Colors.white,
        ),
        onPressed: () => this.deleteUserData(),
      ),
      PopupMenuButton<MangaSource>(
        itemBuilder: (context) => allMangaSource
            .map((el) => PopupMenuItem(
                  value: el,
                  child: Text(el.name),
                ))
            .toList(),
        onSelected: (value) => this.setMangaSource(value),
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
          return ErrorPage(
            '加载失败了呢~~~，\n我们点击之后继续吧',
            onTap: () => getMangaList(state),
          );
      }
    } else {
      return buildMangaListView(state);
    }
  }

  ListView buildMangaListView(MangaSourceViewerPage state) {
    return ListView.builder(
      controller: state.controller,
      itemBuilder: (context, index) {
        if (index == state.mangaList.length) {
          Future.microtask(() => this.getMangaList(state));
          return buildProcessIndicator();
        } else {
          if (state.type == _SourceViewType.latestUpdate) {
            return buildMangaCard(state.mangaList[index],
                tagPrefix: state.title);
          } else {
            return buildMangaCard(state.mangaList[index],
                tagPrefix: state.title, rank: index + 1);
          }
        }
      },
      itemCount: state.mangaList.length + (state.isLast ? 0 : 1),
    );
  }

  MangaCard buildMangaCard(SimpleMangaInfo mangaInfo,
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
    return MangaCard(
      title: Text(mangaInfo.title),
      extra: MangaInfoCardExtra(
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
    return Stack(
      children: <Widget>[
        mangaCoverImage,
        Positioned(
          top: -5,
          left: -3,
          child: Icon(Icons.bookmark, size: 35, color: rankColor),
        ),
        Padding(
          padding: EdgeInsets.only(left: 3, top: 4),
          child: SizedBox(
            width: 22,
            child: Text(
              '$rank',
              style: TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    );
  }

  DateTime pageChangeDebounceTime = DateTime.now();

  void onPageChange(int index, [PageController pageController]) async {
    if (pageController == null) {
      isTabChange = false;
      tabController.animateTo(index);
    } else if (isTabChange) {
      isPageCanChanged = false;
      await pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
      isPageCanChanged = true;
      isTabChange = true;
    }
  }

  refreshPage(MangaSourceViewerPage state) {
    state.mangaList = [];
    state.page = 0;
    return this.getMangaList(state);
  }

  Future<void> getMangaList(MangaSourceViewerPage state) async {
    if (state.loadState == _MangaSourceViewerPageLoadState.loading) {
      return null;
    }
    try {
      sourceName = state.source.name;
      state.loadState = _MangaSourceViewerPageLoadState.loading;
      setState(() {});
      final mangaList = await state.getMangaList(state.page++);
      if (mangaList.length == 0) {
        state.isLast = true;
      }
      state.mangaList.addAll(mangaList);
      state.loadState = _MangaSourceViewerPageLoadState.over;
    } catch (e) {
      print(e);
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

  toSearch() {

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
          manga: item);
    }));
  }

  deleteUserData() {
    MangaReadStorageService.clearStatus();
//    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
//      return TestPage();
//    }));
  }
}


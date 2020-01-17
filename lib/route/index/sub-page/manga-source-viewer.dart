import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/base/error/MaxgaHttpError.dart';
import 'package:maxga/components/Card.dart';
import 'package:maxga/components/MangaCoverImage.dart';
import 'package:maxga/components/MangaOutlineButton.dart';
import 'package:maxga/components/MaxgaButton.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/manga/MangaSource.dart';
import 'package:maxga/route/error-page/ErrorPage.dart';
import 'package:maxga/route/index/base/MangaListTabView.dart';
import 'package:maxga/route/mangaInfo/MangaInfoPage.dart';
import 'package:maxga/service/MangaReadStorage.service.dart';

import '../../../MangaRepoPool.dart';

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

class MangaSourceViewer extends StatefulWidget {
  final name = 'MangaSourceViewer';

  @override
  State<StatefulWidget> createState() => MangaSourceViewerState();
}

class MangaSourceViewerState extends State<MangaSourceViewer>
    with SingleTickerProviderStateMixin {
  _SourceViewType pageType = _SourceViewType.latestUpdate;
  TabController tabController;
  bool isPageCanChanged = true;
  bool isTabChange = true;

  List<MangaSourceViewerPage> tabs;
  List<MangaSource> allMangaSource;

  String sourceName;

  @override
  void initState() {
    super.initState();
    final source = MangaRepoPool.getInstance().currentSource;
    setMangaSource(source);

    tabController = TabController(vsync: this, length: 2, initialIndex: 0);
    allMangaSource = MangaRepoPool.getInstance()?.allDataSource;
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
    return Scaffold(
        appBar: AppBar(
        title: Text(sourceName),
        leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer()),
        actions: buildAppBarActions(),
        bottom:  TabBar(
          controller: tabController,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey,
          tabs: tabs
              .map((item) => Tab(
            text: item.title,
          ))
              .toList(growable: false),
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
  }

  List<Widget> buildAppBarActions() {
    return <Widget>[
      MaxgaSearchButton(),
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
                tagPrefix: '${index}state.title');
          } else {
            return buildMangaCard(state.mangaList[index],
                tagPrefix: '${index}state.title', rank: index + 1);
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

  toSearch() {}

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

  deleteUserData() {
    MangaStorageService.clearStatus();
//    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
//      return TestPage();
//    }));
  }

  test() async {
    final data = await MangaStorageService.getMangaStatusByUrl(
        'http://v3api.dmzj.com/comic/comic_12393.json');
    print(data.readChapterId);
  }
}

class MangaSourceViewerErrorPage extends StatelessWidget {
  final MangaHttpErrorType errorType;
  final MangaSource source;
  final VoidCallback onTap;

  MangaSourceViewerErrorPage({this.errorType, this.source, this.onTap});

  @override
  Widget build(BuildContext context) {
    switch (this.errorType) {
      case MangaHttpErrorType.NULL_PARAM:
      case MangaHttpErrorType.ERROR_PARAM:
        return ErrorPage('${source.name}接口参数错误，暂时无法提供服务\n'
            '请等待更新或者联系作者');
      case MangaHttpErrorType.RESPONSE_ERROR:
        return ErrorPage(
          '${source.name}接口请求失败，点击重试',
          onTap: this.onTap,
        );
      case MangaHttpErrorType.CONNECT_TIMEOUT:
        return ErrorPage(
          '${source.name}接口请求超时，点击重试',
          onTap: this.onTap,
        );
      case MangaHttpErrorType.PARSE_ERROR:
        return ErrorPage(
          '${source.name}接口解析失败，暂时无法提供服务\n'
          '请等待更新或者联系作者',
          onTap: this.onTap,
        );
      default:
        return ErrorPage('未知错误，暂时无法使用');
    }
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/Card.dart';
import 'package:maxga/components/MangaCoverImage.dart';
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

enum _MangaSourceViewerPageLoadState {
  init,
  initOver,
  initError
}

class MangaSourceViewerPage {
  final MangaSource source;
  String title;
  _SourceViewType type;
  ScrollController controller = ScrollController();
  List<SimpleMangaInfo> mangaList = [];
  int page = 0;
  _MangaSourceViewerPageLoadState loadState = _MangaSourceViewerPageLoadState.init;
  MangaSourceViewerPage(this.title, this.type, this.source);


}

class MangaSourceViewer extends StatefulWidget {
  final name = 'MangaSourceViewer';


  @override
  State<StatefulWidget> createState() => MangaSourceViewerState();

}
class MangaSourceViewerState extends State<MangaSourceViewer> with SingleTickerProviderStateMixin {

  _SourceViewType pageType = _SourceViewType.latestUpdate;
  TabController tabController;
  ScrollController scrollController = ScrollController();
  bool isPageCanChanged = true;

  PageController pageController = PageController(initialPage: 0);
  List<MangaSourceViewerPage> tabs;
  List<MangaSource> allMangaSource;


  @override
  void initState() {
    super.initState();
    final source = MangaRepoPool.getInstance().currentSource;
    tabs = [
      MangaSourceViewerPage('最近更新', _SourceViewType.latestUpdate, source),
      MangaSourceViewerPage('排名', _SourceViewType.rank, source),
    ]..forEach((state) {
      this.getMangaList(state);
    });

    tabController = TabController(vsync: this, length: 2, initialIndex: 0);
    tabController.addListener(() {
      if (tabController.indexIsChanging) {//判断TabBar是否切换
        onPageChange(tabController.index, pageController);
      }
    });
    allMangaSource = MangaRepoPool.getInstance()?.allDataSource;
  }

  @override
  Widget build(BuildContext context) {
    var page = NestedScrollView(
      headerSliverBuilder: (context, isScrolled) => [
        SliverAppBar(
          title: const Text('MaxGa'),
          leading: IconButton(icon: Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
          actions: buildAppBarActions(),
          pinned: true,
        ),
        SliverPersistentHeader(
          delegate: IndexSliverAppBarDelegate(
            TabBar(
              controller: tabController,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab( text: "最近更新"),
                Tab( text: "排名"),
              ],
            ),
          ),
          pinned: true,
        ),
      ],
      body: MangaPageView(
        controller: pageController,
        preloadPageCount: 1,
        onPageChanged: (index) => isPageCanChanged ? this.onPageChange(index) : null,
        children: tabs.map((state) =>  RefreshIndicator(
          onRefresh: () => refreshPage(state),
          child:  Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: buildIndexBody(state),
          ),
        )).toList(growable: false),
      ),
    );
    return SafeArea(
      child: page,
    );
  }

  List<Widget> buildAppBarActions() {
    return <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: this.toSearch,
          ),
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
            onSelected: (value) => changeMangaSource(value),
          )
        ];
  }

  buildIndexBody(MangaSourceViewerPage state) {
    switch(state.loadState) {
      case _MangaSourceViewerPageLoadState.init:
        return Container();
        break;
      case _MangaSourceViewerPageLoadState.initOver:
        return ListView.builder(
          controller: state.controller,
          itemBuilder: (context, index) {
            if (index == state.mangaList.length) {
              this.getMangaList(state);
              return buildProcessIndicator();
            } else {
              if (state.type == _SourceViewType.latestUpdate) {
                return buildMangaCard(state.mangaList[index], tagPrefix: state.title);
              } else {
                return buildMangaCard(state.mangaList[index], tagPrefix: state.title, rank: index + 1);
              }
            }
          },
          itemCount: state.mangaList.length + 1,
        );
        break;
      case _MangaSourceViewerPageLoadState.initError:
        return ErrorPage(
          '加载失败了呢~~~，\n我们点击之后继续吧',
          onTap: () => getMangaList(state),
        );
    }
  }

  MangaCard buildMangaCard(SimpleMangaInfo mangaInfo, {String tagPrefix, int rank}) {
    final Color grayFontColor = Color(0xff9e9e9e);
    MangaSource source = MangaRepoPool.getInstance().getMangaSourceByKey(mangaInfo.sourceKey);
    Widget mangaCoverImage = MangaCoverImage(
        source: source,
        url: mangaInfo.coverImgUrl,
        tagPrefix: '$tagPrefix${widget.name}',
      );
    if (rank != null) {
      mangaCoverImage = RankedCoverImage(mangaCoverImage, rank);
    }
    return MangaCard(
      title: Text(mangaInfo.title),
      extra: MangaInfoCardExtra(
          manga: mangaInfo,
          textColor: grayFontColor,
          source: source
      ),
      cover: mangaCoverImage,
      onTap: () => this.goMangaInfoPage(mangaInfo, tagPrefix: tagPrefix),
    );
  }

  Stack RankedCoverImage(MangaCoverImage mangaCoverImage, int rank) {
    Color rankColor;
    switch(rank) {
      case 1: rankColor = Colors.redAccent;break;
      case 2: rankColor = Colors.orangeAccent;break;
      case 3: rankColor = Colors.amberAccent; break;
      default: rankColor = Colors.blueGrey;
    }
    return Stack(
      children: <Widget>[
        mangaCoverImage,

        Positioned(
          top: -5,
          left: -3,
          child: Icon(Icons.bookmark,size: 35,color: rankColor),
        ),
        Padding(
          padding: EdgeInsets.only(left: 3, top: 4),
          child: SizedBox(
            width: 22,
            child: Text('$rank', style: TextStyle(color: Colors.white,fontSize: 12),textAlign:  TextAlign.center,),
          ),
        )
      ],
    );
  }

  void onPageChange(int index, [PageController pageController]) async {
    if (pageController == null ) {
      tabController.animateTo(index);
    } else {
      isPageCanChanged = false;
      await pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
      isPageCanChanged = true;
    }
  }

  refreshPage(MangaSourceViewerPage state) {
    state.mangaList = [];
    state.page = 0;
    return this.getMangaList(state);
  }

  void getMangaList(MangaSourceViewerPage state) async {
    try {
      MaxgaDataHttpRepo repo = MangaRepoPool.getInstance().getRepo(key: state.source.key);
      state.mangaList.addAll(await repo.getLatestUpdate(state.page++));
      state.loadState = _MangaSourceViewerPageLoadState.initOver;
    } catch (e) {
      print(e);
      state.loadState = _MangaSourceViewerPageLoadState.initError;
    } finally {
      setState(() {});
    }
  }

  Widget buildProcessIndicator() {
    return Padding(
      padding: EdgeInsets.only(top:10, bottom: 10),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2)
        ),
      ),
    );
  }


  toSearch() {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return SearchPage();
    }));
  }

  goMangaInfoPage(SimpleMangaInfo item, {String tagPrefix}) {
    MangaSource source = MangaRepoPool.getInstance().getMangaSourceByKey(item.sourceKey);
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



  changeMangaSource(MangaSource value) {
    tabs = [
      MangaSourceViewerPage('最近更新', _SourceViewType.latestUpdate, value),
      MangaSourceViewerPage('排名', _SourceViewType.rank, value),
    ]..forEach((state) {
      this.getMangaList(state);
    });
    // TODO 更新漫画源
    if(mounted) {
      setState(() {});
    }
  }

  deleteUserData() {
    MangaReadStorageService.clearStatus();
//    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
//      return TestPage();
//    }));
  }

}

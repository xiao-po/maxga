
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/Card.dart';
import 'package:maxga/components/MangaCoverImage.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/manga/MangaSource.dart';
import 'package:maxga/provider/base/BaseProvider.dart';
import 'package:maxga/route/error-page/ErrorPage.dart';
import 'package:maxga/route/index/base/IndexSliverAppBarDelegate.dart';
import 'package:maxga/route/mangaInfo/MangaInfoPage.dart';
import 'package:maxga/route/mangaViewer/baseComponent/MangaPageView.dart';
import 'package:maxga/route/search/search-page.dart';
import 'package:maxga/service/MangaReadStorage.service.dart';
import 'package:provider/provider.dart';

import '../../../MangaRepoPool.dart';

enum _SourceViewType {
  latestUpdate,
  rank,
}

enum _MangaSourceViewerPageLoadState {
  init,
  loading,
  over,
  initError
}

class MangaSourceViewerPage {
  final MangaSource source;
  String title;
  _SourceViewType type;
  ScrollController controller = ScrollController();
  List<SimpleMangaInfo> mangaList;
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
  final source = MangaRepoPool.getInstance().currentSource;

  PageController pageController = PageController(initialPage: 0);
  List<MangaSourceViewerPage> tabs;
  List<MangaSource> allMangaSource;


  @override
  void initState() {
    super.initState();
    tabs = [
      MangaSourceViewerPage('最近更新', _SourceViewType.latestUpdate, source),
      MangaSourceViewerPage('排名', _SourceViewType.latestUpdate, source),
    ]..forEach((state) => this.getMangaList(state));

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
      case _MangaSourceViewerPageLoadState.loading:
        return Container();
        break;
      case _MangaSourceViewerPageLoadState.over:
        return ListView.builder(
          controller: state.controller,
            dragStartBehavior: DragStartBehavior.start,
          itemBuilder:   (context, index) => buildMangaCard(state.mangaList[index], tagPrefix: state.title),
          itemCount: state.mangaList.length,
        );
        break;
      case _MangaSourceViewerPageLoadState.initError:
        return ErrorPage(
          '加载失败了呢~~~，\n我们点击之后继续吧',
          onTap: () => getMangaList(state),
        );
    }
  }

  MangaCard buildMangaCard(SimpleMangaInfo mangaInfo, {String tagPrefix}) {
    final Color grayFontColor = Color(0xff9e9e9e);
    MangaSource source = MangaRepoPool.getInstance().getMangaSourceByKey(mangaInfo.sourceKey);
    return MangaCard(
      title: Text(mangaInfo.title),
      extra: MangaInfoCardExtra(
          manga: mangaInfo,
          textColor: grayFontColor,
          source: source
      ),
      cover: MangaCoverImage(
        source: source,
        url: mangaInfo.coverImgUrl,
        tagPrefix: '$tagPrefix${widget.name}',
      ),
      onTap: () => this.goMangaInfoPage(mangaInfo, tagPrefix: tagPrefix),
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

  refreshPage(MangaSourceViewerPage state) {}

  void getMangaList(MangaSourceViewerPage state) async {
    setState(() {
      state.loadState = _MangaSourceViewerPageLoadState.loading;
    });
    try {
      MaxgaDataHttpRepo repo = MangaRepoPool.getInstance().currentDataRepo;
      state.mangaList = await repo.getLatestUpdate(state.page++);
      state.loadState = _MangaSourceViewerPageLoadState.over;
    } catch (e) {
      state.loadState = _MangaSourceViewerPageLoadState.initError;
    } finally {
      setState(() {});
    }
  }

  Center buildProcessIndicator() {
    return Center(
      child: SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(),
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
    MangaRepoPool.getInstance().changeMangaSource(value);
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

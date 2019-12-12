
import 'package:flutter/cupertino.dart';
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

class MangaSourceViewerPage extends BaseProvider {
  final MangaSource source;
  String title;
  _SourceViewType type;
  ScrollController controller = ScrollController();
  List<SimpleMangaInfo> mangaList;
  int page = 0;
  _MangaSourceViewerPageLoadState loadState = _MangaSourceViewerPageLoadState.init;
  MangaSourceViewerPage(this.title, this.type, this.source) {
    this.getMangaList();
  }

  void getMangaList() async {
    this.loadState = _MangaSourceViewerPageLoadState.loading;
    notifyListeners();
    try {
      MaxgaDataHttpRepo repo = MangaRepoPool.getInstance().currentDataRepo;
      mangaList = await repo.getLatestUpdate(page++);
      await Future.delayed(Duration(seconds: 2));
      this.loadState = _MangaSourceViewerPageLoadState.over;
    } catch (e) {
      this.loadState = _MangaSourceViewerPageLoadState.initError;
    } finally {
      notifyListeners();
    }
  }

  refreshPage() {}

}

class MangaSourceViewer extends StatefulWidget {
  final name = 'MangaSourceViewer';


  @override
  State<StatefulWidget> createState() => MangaSourceViewerState();

}
class MangaSourceViewerState extends State<MangaSourceViewer> with SingleTickerProviderStateMixin {

  _SourceViewType pageType = _SourceViewType.latestUpdate;
  TabController tabController;
  final source = MangaRepoPool.getInstance().currentSource;

  PageController pageController = PageController(initialPage: 0);
  List<MangaSourceViewerPage> tabs;

  List<SimpleMangaInfo> mangaList;
  List<MangaSource> allMangaSource;


  @override
  void initState() {
    super.initState();
    tabs = [
      MangaSourceViewerPage('最近更新', _SourceViewType.latestUpdate, source),
      MangaSourceViewerPage('最近更新', _SourceViewType.latestUpdate, source),
    ];
    tabController = TabController(vsync: this, length: 2, initialIndex: 0);
    tabController.addListener(() => this.pageController.animateToPage(tabController.index, duration: Duration(milliseconds: 300)));
    allMangaSource = MangaRepoPool.getInstance()?.allDataSource;
  }

  @override
  Widget build(BuildContext context) {
    const indexPageBackGround = Color(0xfff5f5f5);

    var page = NestedScrollView(
      headerSliverBuilder: (context, isScrolled) => [
        SliverAppBar(
          title: const Text('MaxGa'),
          leading: IconButton(icon: Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
          actions: buildAppBarActions(),
          floating: true,
          snap: true,
          pinned: false,
        ),
        SliverPersistentHeader(
          delegate: IndexSliverAppBarDelegate(
            TabBar(
              controller: tabController,
              indicatorColor: Theme.of(context).scaffoldBackgroundColor,
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
      body: PageView(
        controller: pageController,
        children: tabs.map((state) =>  ChangeNotifierProvider(
          builder: (context) => state,
          child: RefreshIndicator(
            onRefresh: () => state.refreshPage(),
            child:  Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: buildIndexBody(state),
            ),
          )),
        ).toList(growable: false),
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
      case _MangaSourceViewerPageLoadState.loading:
      case _MangaSourceViewerPageLoadState.over:
        return ListView.builder(
          itemBuilder:   (context, index) => buildMangaCard(index),
          itemCount: mangaList.length,
        );
        break;
      case _MangaSourceViewerPageLoadState.initError:
        return ErrorPage(
          '加载失败了呢~~~，\n我们点击之后继续吧',
          onTap: () => state.getMangaList(),
        );
    }
  }

  MangaCard buildMangaCard(int index) {
    final Color grayFontColor = Color(0xff9e9e9e);
    MangaSource source = MangaRepoPool.getInstance().getMangaSourceByKey(mangaList[index].sourceKey);
    return MangaCard(
      title: Text(mangaList[index].title),
      extra: MangaInfoCardExtra(
          manga: mangaList[index],
          textColor: grayFontColor,
          source: source
      ),
      cover: MangaCoverImage(
        source: source,
        url: mangaList[index].coverImgUrl,
        tagPrefix: widget.name,
      ),
      onTap: () => this.goMangaInfoPage(mangaList[index]),
    );
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

  goMangaInfoPage(SimpleMangaInfo item) {
    MangaSource source = MangaRepoPool.getInstance().getMangaSourceByKey(item.sourceKey);
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return MangaInfoPage(
          coverImageBuilder: (context) => MangaCoverImage(
            source: source,
            url: item.coverImgUrl,
            tagPrefix: widget.name,
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

  refreshPage() {}

}

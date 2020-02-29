import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maxga/components/base/zero-divider.dart';
import 'package:maxga/components/button/copy-action-button.dart';
import 'package:maxga/components/card/card.dart';
import 'package:maxga/components/base/manga-cover-image.dart';
import 'package:maxga/model/manga/manga.dart';
import 'package:maxga/model/manga/manga-source.dart';
import 'package:maxga/provider/public/history-provider.dart';
import 'package:maxga/manga-repo-pool.dart';
import 'package:provider/provider.dart';

import '../mangaInfo/components/manga-info-cover.dart';
import '../mangaInfo/manga-info-page.dart';

enum _LoadingState { loading, over, error, empty }

class _SearchResult {
  final MangaSource source;
  List<MangaBase> mangaList = [];
  bool isExpanded = false;
  int retryTimes = 0;
  _LoadingState status = _LoadingState.loading;
  String errorMessage;

  _SearchResult(this.source);
}

class SearchResultPage extends StatefulWidget {
  final String name = 'search_result';
  final String keyword;

  const SearchResultPage({Key key, this.keyword}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<_SearchResult> searchResultList = [];
  DateTime searchTime = DateTime.now();
  int expandCount = 0;

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    searchResultList = MangaRepoPool.getInstance()
        .allDataRepo
        .map((repo) => _SearchResult(repo.mangaSource))
        .toList(growable: false)
          ..forEach((item) => searchAction(item));
  }

  void searchAction(resultItem) async {
    final repo = MangaRepoPool.getInstance().getDataRepo(resultItem.source.key);
    setState(() {
      resultItem.status = _LoadingState.loading;
    });
    try {
      final resultList = await repo.getSearchManga(widget.keyword);
      if (resultList != null && resultList.length > 0) {
        resultItem.mangaList = resultList;
        resultItem.status = _LoadingState.over;
      } else {
        resultItem.status = _LoadingState.empty;
      }
    } catch (e) {
      resultItem.status = _LoadingState.error;
    } finally {
      debugPrint('$mounted');
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(widget.keyword),
        actions: <Widget>[
          CopyActionButton(keyword: widget.keyword)
        ],
      ),
      body: buildBodyByState(),
      floatingActionButton: expandCount > 0
          ? FloatingActionButton(
              onPressed: () => unCollapseAll(),
              child: Icon(Icons.unfold_less),
            )
          : null,
    );
  }

  goMangaInfoPage(SimpleMangaInfo manga) {
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
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return MangaInfoPage(
        title: manga.title,
        coverImageBuilder: (context) => MangaCoverImage(
          source:
              MangaRepoPool.getInstance().getMangaSourceByKey(manga.sourceKey),
          url: manga.coverImgUrl,
          tagPrefix: '${widget.name}${searchTime.toIso8601String()}',
          fit: BoxFit.cover,
        ),
        sourceKey: manga.sourceKey,
        infoUrl: manga.infoUrl,
      );
    }));
  }

  buildBodyByState() {
    return SingleChildScrollView(
      controller: scrollController,
      child: ExpansionPanelList(
        expansionCallback: (panelIndex, isExpanded) =>
            handleExpansionPanelClick(panelIndex, isExpanded),
        children: searchResultList
            .map(
              (item) => ExpansionPanel(
                canTapOnHeader: true,
                isExpanded: item.isExpanded,
                headerBuilder: (context, isExpand) =>
                    buildExpansionPanelHeader(item),
                body: item.mangaList.length > 0
                    ? Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: item.mangaList.length,
                          separatorBuilder: (context, index) => ZeroDivider(),
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) =>
                              buildMangaTile(item.mangaList[index]),
                        ),
                      )
                    : Container(),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  void handleExpansionPanelClick(int panelIndex, bool isExpanded) {
    final resultItem = searchResultList[panelIndex];
    if (resultItem.status == _LoadingState.over) {
      expandCount = isExpanded ? expandCount - 1 : expandCount + 1;
      resultItem.isExpanded = !resultItem.isExpanded;
      setState(() {});
    } else if (resultItem.status == _LoadingState.error) {
      searchAction(resultItem);
    }
  }

  Widget buildExpansionPanelHeader(_SearchResult item) {
    var sourceName = Text(item.source.name);
    var extra;
    var searchResultCountTag;
    const extraTextStyle = const TextStyle(color: Colors.black12);
    const errorTextStyle = const TextStyle(color: Colors.redAccent);
    const progressColor = const AlwaysStoppedAnimation<Color>(Colors.black12);
    double extraWidth = 100;
    switch (item.status) {
      case _LoadingState.loading:
        extra = Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Text('搜索中...', style: extraTextStyle),
            ),
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: progressColor,
              ),
            )
          ],
        );
        break;
      case _LoadingState.error:
        extraWidth = 140;
        extra = Text('搜索失败，点击重试', style: errorTextStyle);
        break;
      case _LoadingState.over:
      case _LoadingState.empty:
        searchResultCountTag = CoverMessageTag(
            margin: EdgeInsets.only(top: 2, right: 5, left: 5),
            padding: EdgeInsets.only(top: 2, bottom: 1, left: 7, right: 7),
            child: Text(
              '${item.mangaList.length}',
              style: TextStyle(fontSize: 10, color: Colors.white),
            ),
            backgroundColor: Colors.redAccent);
        break;
//      case _LoadingState.retry:
//        extraWidth = 180;
//        extra = Row(
//          children: <Widget>[
//            Padding(
//              padding: EdgeInsets.only(right: 10),
//              child: Text(
//                '搜索失败，重试第 ${item.retryTimes} 次',
//                style: extraTextStyle,
//              ),
//            ),
//            SizedBox(
//              height: 20,
//              width: 20,
//              child: CircularProgressIndicator(
//                  strokeWidth: 2, valueColor: progressColor),
//            )
//          ],
//        );
        break;
    }
//    final useMaxgaProxy = Provider.of<SettingProvider>(context)
//        .getBoolItemValue(MaxgaSettingItemType.useMaxgaProxy);
    var body = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(
              height: 20,
              width: 20,
              child: CachedNetworkImage(
                imageUrl: item.source.iconUrl,
              ),
            ),
            sourceName,
            searchResultCountTag ?? Container()
          ],
        ),
        SizedBox(
          width: extraWidth,
          child: extra,
        ),
      ],
    );
    return Padding(
      padding: EdgeInsets.only(left: 20),
      child: body,
    );
  }

  MangaListTile buildMangaTile(MangaBase item) {
    MangaSource source =
        MangaRepoPool.getInstance().getMangaSourceByKey(item.sourceKey);
    return MangaListTile(
      title: Text(item.title),
      labels: [
        item.authors.join(' / '),
        item.typeList.join(' / '),
      ].map((item) => MangaListTileLabel(text: item)).toList(growable: false),
      extra: MangaListTileExtra(
        manga: item,

        source: source,
      ),
      cover: MangaCoverImage(
        source: source,
        url: item.coverImgUrl,
        tagPrefix: '${widget.name}${searchTime.toIso8601String()}',
      ),
      onTap: () => this.goMangaInfoPage(item),
    );
  }

  unCollapseAll() {
    setState(() {
      for (var i = 0; i < searchResultList.length; i++) {
        final item = searchResultList[i];
        item.isExpanded = false;
      }
      scrollController.jumpTo(0);
    });
  }
}


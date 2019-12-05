import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/Card.dart';
import 'package:maxga/components/MangaCoverImage.dart';
import 'package:maxga/components/skeleton.dart';
import 'package:maxga/model/Manga.dart';
import 'package:maxga/model/MangaSource.dart';
import 'package:maxga/route/mangaInfo/MangaInfoPage.dart';

import '../../Application.dart';

enum _LoadingState { loading, over, error, empty }

class _SearchResult {
  final MangaSource source;
  List<MangaBase> mangaList = [];
  bool isExpanded = false;
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

  List<_SearchResult> searchResultList = [];
  DateTime searchTime = DateTime.now();
  int expandCount = 0;

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Application application = Application.getInstance();
    application.allDataRepo.forEach((repo) async {
      final resultItem = _SearchResult(repo.mangaSource);
      searchResultList.add(resultItem);
      try {
        final resultList = await repo.getSearchManga(widget.keyword);
        if (resultList != null && resultList.length > 0) {
          resultItem.mangaList = resultList;
          resultItem.status = _LoadingState.over;
        } else {
          resultItem.status = _LoadingState.empty;
        }
      } catch (e) {
        print(e);
        resultItem.status = _LoadingState.error;
      } finally {

        print('${repo.mangaSource.name} loadover');
        if (mounted) {setState(() {});}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff8f8f8),
      appBar: AppBar(
        title: Text(widget.keyword),
      ),
      body: buildBodyByState(),
      floatingActionButton: expandCount > 0 ? FloatingActionButton(
        onPressed: () => unCollapseAll(),
        child: Icon(Icons.unfold_less),
      ) : null,
    );
  }

  Container buildActionProgressIndicator() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(right: 20),
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
      ),
    );
  }

  goMangaInfoPage(SimpleMangaInfo item) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return MangaInfoPage(
        coverImageBuilder: (context) => MangaCoverImage(
          source: item.source,
          url: item.coverImgUrl,
          tagPrefix: '${widget.name}${searchTime.toIso8601String()}',
          fit: BoxFit.cover,
        ),
        manga: item,
      );
    }));
  }

  buildBodyByState() {
    return SingleChildScrollView(
      controller: scrollController,
      child: ExpansionPanelList(
        expansionCallback: (panelIndex, isExpanded) {
          final resultItem = searchResultList[panelIndex];
          if (resultItem.status == _LoadingState.over) {
            expandCount = isExpanded ? expandCount - 1 : expandCount + 1;
            resultItem.isExpanded = !resultItem.isExpanded;
            setState(() {});
          }
        },
        children: searchResultList.map(
          (item) => ExpansionPanel(
            canTapOnHeader: true,
            isExpanded: item.isExpanded,
            headerBuilder: (context, isExpand) => buildExpansionPanelHeader(item),
            body: item.mangaList.length > 0 ? ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: buildMangaCardList(item.mangaList),
            ) : Container(),
          ),
        ).toList(growable: false),
      ),
    );
  }

  Widget buildExpansionPanelHeader(_SearchResult item) {
    var sourceName = Text(item.source.name);
    var extra;
    const extraTextStyle = const TextStyle(color: Colors.black12);
    const errorTextStyle = const TextStyle(color: Colors.redAccent);
    switch(item.status) {
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
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          ],
        );
        break;
      case _LoadingState.error:
        extra = Text('搜索失败，点击重试', style: errorTextStyle);
        break;
      case _LoadingState.over:
      case _LoadingState.empty:
        extra = Text('搜索结果: ${item.mangaList.length}',);
        break;
    }
    var body =  Row(
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
          ],
        ),
        SizedBox(
          width: 100,
          child: extra,
        )
      ],
    );
    return Padding(
      padding: EdgeInsets.only(left: 20),
      child: body,
    );
  }

  List<MangaCard> buildMangaCardList(List<MangaBase> mangaList) {
    return mangaList
        .map((item) => MangaCard(
              title: Text(item.title),
              extra: MangaInfoCardExtra(manga: item),
              cover: MangaCoverImage(
                source: item.source,
                url: item.coverImgUrl,
                tagPrefix: '${widget.name}${searchTime.toIso8601String()}',
              ),
              onTap: () => this.goMangaInfoPage(item),
            ))
        .toList();
  }

  unCollapseAll() {
    setState(() {
      for(var i = 0; i < searchResultList.length; i++) {
        final item = searchResultList[i];
        item.isExpanded = false;
      }
      scrollController.jumpTo(0);
    });
  }

}

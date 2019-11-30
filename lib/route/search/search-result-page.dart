import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/Card.dart';
import 'package:maxga/components/MangaCoverImage.dart';
import 'package:maxga/components/skeleton.dart';
import 'package:maxga/model/Manga.dart';
import 'package:maxga/route/error-page/EmptyPage.dart';
import 'package:maxga/route/error-page/ErrorPage.dart';
import 'package:maxga/route/mangaInfo/MangaInfoPage.dart';

import '../../Application.dart';

enum LoadingState { loading, loadHalf, over, error, empty }

class SearchResultPage extends StatefulWidget {
  final String name = 'search_result';
  final String keyword;

  const SearchResultPage({Key key, this.keyword}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  List<SimpleMangaInfo> mangaResultList = [];
  LoadingState pageState = LoadingState.loading;
  DateTime searchTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    this.getResult();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xfff8f8f8),
        appBar: AppBar(
          title: Text(widget.keyword),
          actions: <Widget>[
            pageState == LoadingState.loading
                ? buildActionProgressIndicator()
                : Container()
          ],
        ),
        body: buildBodyByState());
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

  void getResult() async {
    Application application = Application.getInstance();
    try {
      final resultList =
          await application.getMangaSource().getSearchManga(widget.keyword);

      if (resultList != null && resultList.length > 0) {
        mangaResultList = resultList;
        pageState = LoadingState.over;
      } else {
        pageState = LoadingState.empty;
      }
    } catch (e) {
      print(e);
      pageState = LoadingState.error;
    } finally {
      setState(() {});
    }
  }

  Widget _loadingSkeleton() {
    final itemCount = (MediaQuery.of(context).size.height - 100) / 120;
    return SkeletonList(
      length: itemCount.floor(),
      builder: (context, index) => SkeletonCard(),
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
    switch (pageState) {
      case LoadingState.loading:
        return _loadingSkeleton();
      case LoadingState.loadHalf:
      case LoadingState.over:
        return ListView(
            children: mangaResultList
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
                .toList());
        break;
      case LoadingState.error:
        return ErrorPage('请求出错，可能是网络不稳定\n 点击重试吧', onTap: () => getResult());
      case LoadingState.empty:
        return EmptyPage('没有搜索到任何的漫画');
    }
  }
}
